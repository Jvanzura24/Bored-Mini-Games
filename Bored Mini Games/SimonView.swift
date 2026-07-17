//
//  SimonView.swift
//  Bored Mini Games
//
//  Watch the pattern, then repeat it. The sequence grows by one each round —
//  see how long a chain you can remember.
//

import SwiftUI

struct SimonView: View {
    private enum Pad: Int, CaseIterable, Identifiable {
        case green, red, yellow, blue

        var id: Int { rawValue }

        var color: Color {
            switch self {
            case .green: .green
            case .red: .red
            case .yellow: .yellow
            case .blue: .blue
            }
        }
    }

    private enum Phase {
        case idle          // waiting to start
        case showing       // replaying the sequence for the player
        case awaitingInput // player's turn to repeat
        case gameOver
    }

    @State private var sequence: [Pad] = []
    @State private var inputIndex = 0
    @State private var phase: Phase = .idle
    @State private var litPad: Pad?
    @State private var bestScore = 0

    private var score: Int { max(0, sequence.count - (phase == .gameOver ? 1 : 0)) }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                scoreLabel("Round", score, .primary)
                scoreLabel("Best", bestScore, .secondary)
            }

            Text(statusText)
                .font(.headline)
                .frame(height: 24)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Pad.allCases) { pad in
                    padView(pad)
                }
            }
            .padding(.horizontal, 24)
            .disabled(phase != .awaitingInput)

            Button(phase == .idle ? "Start" : "Restart") { startGame() }
                .buttonStyle(.borderedProminent)
                .opacity(phase == .idle || phase == .gameOver ? 1 : 0)

            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }

    private var statusText: String {
        switch phase {
        case .idle: "Repeat the pattern"
        case .showing: "Watch carefully…"
        case .awaitingInput: "Your turn"
        case .gameOver: "Game over — you reached \(score)"
        }
    }

    private func scoreLabel(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.bold().monospacedDigit()).foregroundStyle(color)
        }
    }

    private func padView(_ pad: Pad) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(pad.color.gradient)
            .aspectRatio(1, contentMode: .fit)
            .opacity(litPad == pad ? 1 : 0.45)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(litPad == pad ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.12), value: litPad)
            .onTapGesture { handleTap(pad) }
    }

    private func startGame() {
        sequence = []
        inputIndex = 0
        phase = .showing
        addStepAndShow()
    }

    private func addStepAndShow() {
        sequence.append(Pad.allCases.randomElement()!)
        inputIndex = 0
        Task { await playSequence() }
    }

    private func playSequence() async {
        phase = .showing
        // Brief pause before the pattern starts.
        try? await Task.sleep(for: .milliseconds(500))
        for pad in sequence {
            litPad = pad
            try? await Task.sleep(for: .milliseconds(400))
            litPad = nil
            try? await Task.sleep(for: .milliseconds(200))
        }
        phase = .awaitingInput
    }

    private func handleTap(_ pad: Pad) {
        guard phase == .awaitingInput else { return }

        // Flash the tapped pad for feedback.
        Task {
            litPad = pad
            try? await Task.sleep(for: .milliseconds(150))
            if phase != .gameOver { litPad = nil }
        }

        if pad == sequence[inputIndex] {
            inputIndex += 1
            if inputIndex == sequence.count {
                // Round complete — grow the sequence.
                bestScore = max(bestScore, sequence.count)
                phase = .showing
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    addStepAndShow()
                }
            }
        } else {
            phase = .gameOver
        }
    }
}

#Preview {
    SimonView()
}
