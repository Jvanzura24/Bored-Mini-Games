import SwiftUI

// Two-side tap race: tap your half as fast as possible. Left vs Right.
struct TapSpeedDuelView: View {
    @State private var leftCount = 0
    @State private var rightCount = 0
    @State private var timeLeft = 10.0
    @State private var started = false
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil

    private var winner: String {
        if leftCount == rightCount { return "Tie!" }
        return leftCount > rightCount ? "Left Wins! 🎉" : "Right Wins! 🎉"
    }

    var body: some View {
        VStack(spacing: 0) {
            timerBar

            if gameOver {
                gameOverView
            } else {
                HStack(spacing: 0) {
                    tapSide(label: "L", count: leftCount, color: .blue) {
                        if started { leftCount += 1 }
                    }
                    Divider()
                        .frame(width: 2)
                        .background(Color.primary.opacity(0.2))
                    tapSide(label: "R", count: rightCount, color: .red) {
                        if started { rightCount += 1 }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if !started {
                    Button("Start!") { start() }
                        .buttonStyle(.borderedProminent)
                        .font(.title2.bold())
                        .padding(.bottom, 32)
                }
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    private var timerBar: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", timeLeft))
                .font(.system(size: 36, weight: .black, design: .monospaced))
            ProgressView(value: timeLeft, total: 10.0)
                .tint(.blue)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 12)
    }

    private func tapSide(label: String, count: Int, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Text(label)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(color)
                Text("\(count)")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(color.opacity(0.85))
                Text("taps").font(.subheadline).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(0.06))
        }
        .buttonStyle(.plain)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text(winner)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            HStack(spacing: 40) {
                VStack { Text("Left").font(.headline).foregroundStyle(.blue); Text("\(leftCount)").font(.system(size: 48, weight: .black)).foregroundStyle(.blue) }
                Text("vs").font(.title2).foregroundStyle(.secondary)
                VStack { Text("Right").font(.headline).foregroundStyle(.red); Text("\(rightCount)").font(.system(size: 48, weight: .black)).foregroundStyle(.red) }
            }
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func start() {
        started = true
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run {
                    timeLeft = max(0, timeLeft - 0.1)
                    if timeLeft <= 0 { gameOver = true; timerTask?.cancel() }
                }
            }
        }
    }

    private func reset() {
        leftCount = 0; rightCount = 0; timeLeft = 10; started = false; gameOver = false
        timerTask?.cancel()
    }
}

#Preview { TapSpeedDuelView() }
