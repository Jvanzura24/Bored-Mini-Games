import SwiftUI

struct OddEvenRushView: View {
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var current = 0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 24) {
            hud
            Spacer()
            if gameOver { gameOverView } else { gameplayView }
            Spacer()
        }
        .onAppear { reset() }
        .onDisappear { timerTask?.cancel() }
    }

    private var hud: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart").foregroundStyle(.red)
                }
            }
            Spacer()
            Label(String(format: "%.0f", timeLeft), systemImage: "timer")
        }
        .font(.headline)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var gameplayView: some View {
        VStack(spacing: 32) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗")
                        .foregroundStyle(fb ? .green : .red)
                } else {
                    Text(" ")
                }
            }
            .font(.system(size: 48, weight: .black))
            .frame(height: 60)

            Text("\(current)")
                .font(.system(size: 100, weight: .black, design: .rounded))
                .contentTransition(.numericText())
                .animation(.default, value: current)

            HStack(spacing: 20) {
                answerButton("ODD", color: .blue) { guess(isOdd: true) }
                answerButton("EVEN", color: .orange) { guess(isOdd: false) }
            }
        }
    }

    private func answerButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title2.bold())
                .frame(minWidth: 130, minHeight: 60)
                .background(color, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(isOdd: Bool) {
        let correct = (current % 2 != 0) == isOdd
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); HighScoreStore.save(score, for: .oddEvenRush); return }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await MainActor.run { withAnimation { feedback = nil; current = Int.random(in: 1...99) } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        current = Int.random(in: 1...99)
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    timeLeft -= 1
                    if timeLeft <= 0 { gameOver = true; HighScoreStore.save(score, for: .oddEvenRush) }
                }
            }
        }
    }
}

#Preview { OddEvenRushView() }
