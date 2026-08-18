import SwiftUI

struct CoinStreakView: View {
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var totalScore = 0
    @State private var lastFlip: String? = nil
    @State private var animating = false
    @State private var gameOver = false
    @State private var roundsLeft = 10

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                VStack { Text("Score").font(.caption).foregroundStyle(.secondary); Text("\(totalScore)").font(.title2.bold()) }
                Spacer()
                VStack { Text("Streak").font(.caption).foregroundStyle(.secondary); Text("\(streak)").font(.title2.bold()).foregroundStyle(.orange) }
                Spacer()
                VStack { Text("Best").font(.caption).foregroundStyle(.secondary); Text("\(bestStreak)").font(.title2.bold()).foregroundStyle(.blue) }
                Spacer()
                VStack { Text("Flips").font(.caption).foregroundStyle(.secondary); Text("\(roundsLeft)").font(.title2.bold()) }
            }
            .padding(.horizontal, 28).padding(.top, 8)

            Spacer()

            if gameOver {
                gameOverView
            } else {
                gameplayView
            }

            Spacer()
        }
        .onAppear { newGame() }
    }

    private var coinDisplay: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.80, blue: 0.20), Color(red: 0.75, green: 0.60, blue: 0.10)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

            if let flip = lastFlip {
                Text(flip == "H" ? "H" : "T")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Text("?")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .scaleEffect(animating ? 1.15 : 1.0)
        .animation(.spring(duration: 0.2), value: animating)
    }

    private var gameplayView: some View {
        VStack(spacing: 32) {
            coinDisplay

            if let flip = lastFlip {
                Text(flip == "H" ? "Heads!" : "Tails!")
                    .font(.title2.bold())
                    .foregroundStyle(flip == "H" ? .blue : .red)
            } else {
                Text("Predict the next flip").font(.headline).foregroundStyle(.secondary)
            }

            Text("Streak bonus: +\(streak) per correct").font(.caption).foregroundStyle(.secondary)

            HStack(spacing: 24) {
                Button {
                    predict("H")
                } label: {
                    VStack(spacing: 6) {
                        Text("H").font(.system(size: 32, weight: .black))
                        Text("Heads").font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Button {
                    predict("T")
                } label: {
                    VStack(spacing: 6) {
                        Text("T").font(.system(size: 32, weight: .black))
                        Text("Tails").font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(totalScore)").font(.title2).foregroundStyle(.secondary)
            Text("Best Streak: \(bestStreak)").font(.headline).foregroundStyle(.orange)
            Button("Play Again") { newGame() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func predict(_ call: String) {
        let result = Bool.random() ? "H" : "T"
        animating = true
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            await MainActor.run { animating = false }
        }
        lastFlip = result
        roundsLeft -= 1

        if call == result {
            streak += 1
            if streak > bestStreak { bestStreak = streak }
            totalScore += 1 + streak
        } else {
            streak = 0
            totalScore = max(0, totalScore - 1)
        }

        if roundsLeft <= 0 { withAnimation { gameOver = true } }
    }

    private func newGame() {
        streak = 0; totalScore = 0; roundsLeft = 10; lastFlip = nil; gameOver = false
    }
}

#Preview { CoinStreakView() }
