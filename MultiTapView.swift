import SwiftUI

// Multiple targets appear. Tap all of them before time runs out.
struct MultiTapView: View {
    private struct Target: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var tapped = false
        var timeLeft: Double
    }

    @State private var targets: [Target] = []
    @State private var score = 0
    @State private var round = 0
    @State private var phase: Phase = .idle
    @State private var roundTime = 3.0
    @State private var elapsed = 0.0
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var best: Int? = nil

    private enum Phase { case idle, playing, result }

    var allTapped: Bool { targets.allSatisfy { $0.tapped } }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack {
                        Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                        Spacer()
                        Text("Round \(round)").font(.headline)
                        Spacer()
                        if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
                    }
                    .font(.headline).padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                if phase == .playing {
                    ForEach($targets) { $target in
                        Button {
                            tapTarget(&target)
                        } label: {
                            Circle()
                                .fill(target.tapped ?
                                    LinearGradient(colors: [.green, .green.opacity(0.5)], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                                .frame(width: target.size, height: target.size)
                                .overlay(
                                    Circle().stroke(.white.opacity(0.4), lineWidth: 2)
                                )
                                .shadow(color: target.tapped ? .green.opacity(0.4) : .orange.opacity(0.5), radius: 6)
                                .scaleEffect(target.tapped ? 0.7 : 1.0)
                                .animation(.spring(duration: 0.2), value: target.tapped)
                        }
                        .buttonStyle(.plain)
                        .position(x: target.x * geo.size.width, y: target.y * geo.size.height)
                    }

                    // Progress
                    VStack {
                        Spacer()
                        ProgressView(value: elapsed, total: roundTime)
                            .tint(.orange)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                    }
                }

                if phase == .idle {
                    idleView
                }

                if phase == .result {
                    resultView
                }
            }
        }
        .onAppear { phase = .idle }
        .onDisappear { timerTask?.cancel() }
    }

    private var idleView: some View {
        VStack(spacing: 20) {
            Text("Tap all targets\nbefore time runs out!")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            Text("Rounds get faster and add more targets")
                .font(.subheadline).foregroundStyle(.secondary)
            Button("Start!") { startRound() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            let success = allTapped
            Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(success ? .green : .red)
            Text(success ? "Got them all! +" : "Too slow!")
                .font(.system(.title, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button(success ? "Next Round" : "Play Again") {
                if success { startRound() } else { resetGame() }
            }
            .buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }

    private func tapTarget(_ target: inout Target) {
        guard !target.tapped, phase == .playing else { return }
        target.tapped = true
        if allTapped {
            score += round
            if best == nil || score > best! { best = score }
            timerTask?.cancel()
            withAnimation { phase = .result }
        }
    }

    private func startRound() {
        round += 1
        let count = min(2 + round, 8)
        roundTime = max(1.5, 4.0 - Double(round) * 0.2)
        elapsed = 0
        targets = (0..<count).map { _ in
            Target(x: CGFloat.random(in: 0.12...0.88),
                   y: CGFloat.random(in: 0.18...0.82),
                   size: CGFloat.random(in: 40...70),
                   timeLeft: roundTime)
        }
        phase = .playing

        timerTask?.cancel()
        timerTask = Task {
            let steps = Int(roundTime / 0.05)
            for _ in 0..<steps {
                try? await Task.sleep(for: .milliseconds(50))
                guard !Task.isCancelled else { return }
                await MainActor.run { elapsed += 0.05 }
            }
            await MainActor.run {
                if phase == .playing {
                    if !allTapped { phase = .result } // time ran out
                }
            }
        }
    }

    private func resetGame() {
        score = 0; round = 0; phase = .idle; targets = []; elapsed = 0
    }
}

#Preview { MultiTapView() }
