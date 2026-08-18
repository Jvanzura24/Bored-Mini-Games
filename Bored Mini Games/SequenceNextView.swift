import SwiftUI

struct SequenceNextView: View {
    private struct Sequence {
        let shown: [Int]
        let answer: Int
        let rule: String
    }

    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var current: Sequence = SequenceNextView.makeSequence()
    @State private var choices: [Int] = []
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
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private var gameplayView: some View {
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ \(current.answer)").foregroundStyle(fb ? .green : .red)
                } else {
                    Text(" ")
                }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("What comes next?").font(.headline).foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(current.shown, id: \.self) { n in
                    Text("\(n)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(width: 52, height: 52)
                        .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                Text("?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .frame(width: 52, height: 52)
                    .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            }

            Text(current.rule).font(.caption).foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { n in
                    Button {
                        guess(n)
                    } label: {
                        Text("\(n)")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ n: Int) {
        let correct = n == current.answer
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run {
                withAnimation { feedback = nil }
                current = Self.makeSequence()
                makeChoices()
            }
        }
    }

    private func makeChoices() {
        var pool: Set<Int> = [current.answer]
        while pool.count < 4 {
            pool.insert(current.answer + Int.random(in: -8...8))
        }
        choices = pool.shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        current = Self.makeSequence()
        makeChoices()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    timeLeft -= 1
                    if timeLeft <= 0 { gameOver = true }
                }
            }
        }
    }

    private static func makeSequence() -> Sequence {
        let step = Int.random(in: 2...6)
        let start = Int.random(in: 2...12)
        let type = Int.random(in: 0...1) // only use add/subtract for safety
        let shown = (0..<4).map { start + (type == 0 ? step : -step) * $0 }
        let answer = start + (type == 0 ? step : -step) * 4
        let rule = type == 0 ? "Each term +\(step)" : "Each term −\(step)"
        return Sequence(shown: shown, answer: answer, rule: rule)
    }
}

#Preview { SequenceNextView() }
