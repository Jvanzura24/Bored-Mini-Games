import SwiftUI

// Quick quiz: squares, cubes, and simple powers. 4 choices, 60s, 3 lives.
struct PowersQuizView: View {
    private struct Question {
        let prompt: String
        let answer: Int
    }

    @State private var question = Question(prompt: "", answer: 0)
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
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
        VStack(spacing: 32) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ = \(question.answer)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text(question.prompt)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .minimumScaleFactor(0.5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { n in
                    Button { guess(n) } label: {
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
        let correct = n == question.answer
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        let type = Int.random(in: 0...2)
        switch type {
        case 0:
            let base = Int.random(in: 2...12)
            let answer = base * base
            question = Question(prompt: "\(base)²", answer: answer)
            makeChoices(around: answer)
        case 1:
            let base = Int.random(in: 2...5)
            let answer = base * base * base
            question = Question(prompt: "\(base)³", answer: answer)
            makeChoices(around: answer)
        default:
            let base = Int.random(in: 2...4)
            let exp = Int.random(in: 4...5)
            let answer = Int(pow(Double(base), Double(exp)))
            let expStr = exp == 4 ? "⁴" : "⁵"
            question = Question(prompt: "\(base)\(expStr)", answer: answer)
            makeChoices(around: answer)
        }
    }

    private func makeChoices(around answer: Int) {
        var pool: Set<Int> = [answer]
        let spread = max(3, answer / 5)
        while pool.count < 4 {
            let off = Int.random(in: 1...spread) * (Bool.random() ? 1 : -1)
            let c = answer + off
            if c > 0 { pool.insert(c) }
        }
        choices = Array(pool).shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        next()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { PowersQuizView() }
