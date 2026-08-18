//
//  WhackAMoleView.swift
//  Bored Mini Games
//
//  Moles pop up from a 3x3 grid of holes. Tap them before they duck back
//  down to score points. You have 30 seconds — go for a high score.
//

import SwiftUI

struct WhackAMoleView: View {
    private static let holeCount = 9
    private static let roundLength = 30

    @State private var activeMoles: Set<Int> = []
    @State private var whacked: Set<Int> = []
    @State private var score = 0
    @State private var timeRemaining = WhackAMoleView.roundLength
    @State private var roundEndsAt: Date?
    @State private var isRunning = false
    @AppStorage("difficulty.whackAMole") private var difficulty: Difficulty = .medium

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        VStack(spacing: 20) {
            DifficultyPicker(difficulty: $difficulty)

            HStack(spacing: 40) {
                scoreLabel("Score", score, .primary)
                scoreLabel("Time", timeRemaining, timeRemaining <= 5 ? .red : .secondary)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0..<Self.holeCount, id: \.self) { hole in
                    holeView(hole)
                }
            }
            .padding(.horizontal, 24)
            .disabled(!isRunning)

            if !isRunning {
                VStack(spacing: 12) {
                    if timeRemaining == 0 {
                        Text("Time's up! You scored \(score).")
                            .font(.headline)
                    }
                    Button(timeRemaining == 0 ? "Play Again" : "Start") { startGame() }
                        .buttonStyle(.borderedProminent)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .task {
            // Master loop: advances the timer and spawns moles once per tick
            // while a round is running. Ends automatically with the view.
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(difficulty.moleTickMilliseconds))
                guard isRunning else { continue }
                tick()
            }
        }
    }

    private func scoreLabel(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.bold().monospacedDigit()).foregroundStyle(color)
        }
    }

    private func holeView(_ hole: Int) -> some View {
        let isActive = activeMoles.contains(hole)
        let isWhacked = whacked.contains(hole)
        return ZStack {
            Circle()
                .fill(Color.brown.opacity(0.35))
            if isActive {
                Image(systemName: isWhacked ? "burst.fill" : "hare.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(isWhacked ? .orange : .brown)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            Circle().stroke(.brown.opacity(0.4), lineWidth: 2)
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isActive)
        .onTapGesture { whack(hole) }
    }

    private func startGame() {
        score = 0
        timeRemaining = Self.roundLength
        roundEndsAt = Date.now.addingTimeInterval(TimeInterval(Self.roundLength))
        activeMoles = []
        whacked = []
        isRunning = true
    }

    private func tick() {
        // The countdown follows the wall clock so the round is always the
        // same length no matter how fast the moles cycle.
        guard let roundEndsAt else { return }
        timeRemaining = max(0, Int(roundEndsAt.timeIntervalSinceNow.rounded(.up)))
        if timeRemaining <= 0 {
            isRunning = false
            self.roundEndsAt = nil
            activeMoles = []
            whacked = []
            HighScoreStore.save(score, for: .whackAMole)
            return
        }

        // Refresh the moles: clear the old set and pop up one or two new ones.
        whacked = []
        let count = Int.random(in: 1...2)
        activeMoles = Set((0..<Self.holeCount).shuffled().prefix(count))
    }

    private func whack(_ hole: Int) {
        guard isRunning, activeMoles.contains(hole), !whacked.contains(hole) else { return }
        whacked.insert(hole)
        score += 1
    }
}

private extension Difficulty {
    /// Milliseconds each batch of moles stays up before the next batch —
    /// lower means less time to react.
    var moleTickMilliseconds: Int {
        switch self {
        case .easy: 1000
        case .medium: 700
        case .hard: 450
        }
    }
}

#Preview {
    WhackAMoleView()
}
