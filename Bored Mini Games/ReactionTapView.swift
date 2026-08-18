//
//  ReactionTapView.swift
//  Bored Mini Games
//

import SwiftUI

private enum ReactPhase {
    case idle, waiting, ready, tooEarly, result(Double)
}

struct ReactionTapView: View {
    @State private var phase: ReactPhase = .idle
    @State private var tapStart = Date.now
    @State private var best: Double? = nil
    @State private var waitTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 0) {
            if let b = best {
                Text("Best: \(Int(b * 1000)) ms")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 24)
            }

            Spacer()

            tapBox
                .padding(.horizontal, 28)
                .onTapGesture { handleTap() }

            Spacer()

            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
        }
        .onAppear { phase = .idle }
        .onDisappear { waitTask?.cancel() }
    }

    private var tapBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(boxColor)
                .shadow(color: boxColor.opacity(0.45), radius: 24, y: 12)

            VStack(spacing: 14) {
                Text(headline)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if case .result(let t) = phase {
                    Text("\(Int(t * 1000)) ms")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(44)
        }
        .frame(maxWidth: .infinity, minHeight: 270)
    }

    private var boxColor: Color {
        switch phase {
        case .idle:     return .gray
        case .waiting:  return Color(red: 0.85, green: 0.25, blue: 0.25)
        case .ready:    return Color(red: 0.15, green: 0.70, blue: 0.34)
        case .tooEarly: return Color(red: 0.92, green: 0.54, blue: 0.10)
        case .result:   return Color(red: 0.22, green: 0.45, blue: 0.95)
        }
    }

    private var headline: String {
        switch phase {
        case .idle:     return "Tap to begin"
        case .waiting:  return "Wait for green…"
        case .ready:    return "TAP!"
        case .tooEarly: return "Too soon!"
        case .result(let t):
            if t < 0.20 { return "Lightning! ⚡️" }
            if t < 0.30 { return "Excellent!" }
            if t < 0.40 { return "Good!" }
            return "Keep trying!"
        }
    }

    private var hint: String {
        switch phase {
        case .idle:             return "Tap the box when it turns green"
        case .waiting:          return "Not yet…"
        case .ready:            return ""
        case .tooEarly, .result: return "Tap to try again"
        }
    }

    private func handleTap() {
        switch phase {
        case .idle:
            beginWait()
        case .waiting:
            waitTask?.cancel()
            withAnimation { phase = .tooEarly }
        case .ready:
            let elapsed = Date.now.timeIntervalSince(tapStart)
            if best == nil || elapsed < best! { best = elapsed }
            withAnimation { phase = .result(elapsed) }
        case .tooEarly, .result:
            beginWait()
        }
    }

    private func beginWait() {
        phase = .waiting
        let delay = Double.random(in: 1.8...4.5)
        waitTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                tapStart = .now
                withAnimation { phase = .ready }
            }
        }
    }
}

#Preview { ReactionTapView() }
