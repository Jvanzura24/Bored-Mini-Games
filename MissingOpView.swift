import SwiftUI

// Fill in the missing operator: 3 ? 4 = 12. Tap +, -, ×, ÷. 60s, 3 lives.
struct MissingOpView: View {
    private struct Question {
        let a: Int
        let b: Int
        let result: Int
        let op: String
    }

    @State private var question = Question(a: 0, b: 0, result: 0, op: "+")
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil

    private let ops = ["+", "−", "×", "÷"]

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
                    Text(fb ? "✓" : "✗ \(question.op)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("\(question.a)  ?  \(question.b)  =  \(question.result)")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 16)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(ops, id: \.self) { op in
                    Button { guess(op) } label: {
                        Text(op)
                            .font(.system(size: 32, weight: .black))
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ op: String) {
        let correct = op == question.op
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        let op = ops.randomElement()!
        let a, b, result: Int
        switch op {
        case "+":
            a = Int.random(in: 1...50); b = Int.random(in: 1...50); result = a + b
        case "−":
            a = Int.random(in: 10...99); b = Int.random(in: 1...a); result = a - b
        case "×":
            a = Int.random(in: 2...12); b = Int.random(in: 2...12); result = a * b
        default: // ÷
            b = Int.random(in: 2...10); result = Int.random(in: 2...10); a = b * result
        }
        question = Question(a: a, b: b, result: result, op: op)
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

#Preview { MissingOpView() }
