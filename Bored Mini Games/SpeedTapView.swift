import SwiftUI

struct SpeedTapView: View {
    private enum Phase { case idle, playing, done }

    @State private var phase: Phase = .idle
    @State private var count = 0
    @State private var timeLeft = 10.0
    @AppStorage("highScore.Speed Tap") private var best = 0
    @State private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 24) {
            if best > 0 {
                Text("Best: \(best) taps").font(.headline).foregroundStyle(.secondary)
            }

            Spacer()

            switch phase {
            case .idle:
                VStack(spacing: 12) {
                    Text("Tap as fast as you can!").font(.title2.bold())
                    Text("10 seconds").foregroundStyle(.secondary)
                }
            case .playing:
                VStack(spacing: 12) {
                    Text(String(format: "%.0fs left", timeLeft))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(timeLeft <= 3 ? .red : .primary)
                        .contentTransition(.numericText())
                    Text("\(count)")
                        .font(.system(size: 96, weight: .black, design: .rounded))
                        .contentTransition(.numericText())
                        .animation(.default, value: count)
                }
            case .done:
                VStack(spacing: 12) {
                    Text("Done!").font(.largeTitle.bold())
                    Text("\(count) taps").font(.title2)
                    if count > 0 && count == best {
                        Text("New best!").font(.headline).foregroundStyle(.yellow)
                    }
                }
            }

            Spacer()

            Button { handleTap() } label: {
                Text(phase == .idle ? "Start" : phase == .done ? "Play Again" : "TAP!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(
                        phase == .playing ? Color.blue : Color(.systemGray4),
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .foregroundStyle(phase == .playing ? .white : .primary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onDisappear { timerTask?.cancel() }
    }

    private func handleTap() {
        switch phase {
        case .idle: startGame()
        case .playing: count += 1
        case .done: startGame()
        }
    }

    private func startGame() {
        count = 0; timeLeft = 10; phase = .playing
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    timeLeft = max(0, timeLeft - 0.1)
                    if timeLeft <= 0 {
                        phase = .done
                        if count > best { best = count }
                        timerTask?.cancel()
                    }
                }
            }
        }
    }
}

#Preview { SpeedTapView() }
