import SwiftUI

// Each puzzle assigns values to two emoji, then asks you to solve for a third.
struct EmojiMathView: View {
    private struct Puzzle {
        let lines: [String]   // display lines like "🍕 + 🍕 = 10"
        let question: String  // "🍕 × 🎮 = ?"
        let answer: Int
        let distractors: [Int]
        var choices: [Int] { ([answer] + distractors).shuffled() }
    }

    private let puzzles: [Puzzle] = [
        Puzzle(lines:["🍕 + 🍕 = 10","🎮 + 🎮 + 🎮 = 9"],
               question:"🍕 + 🎮 = ?", answer:8, distractors:[6,9,7]),
        Puzzle(lines:["⭐ × ⭐ = 16","🌙 + 🌙 = 6"],
               question:"⭐ + 🌙 = ?", answer:7, distractors:[5,9,10]),
        Puzzle(lines:["🍎 + 🍎 + 🍎 = 12","🍋 × 2 = 6"],
               question:"🍎 × 🍋 = ?", answer:12, distractors:[9,15,18]),
        Puzzle(lines:["🚀 − 🚀 + 10 = 10","🌈 × 🌈 = 25"],
               question:"🌈 + 🚀 = ?", answer:5 + Int.random(in:1...5), distractors:[3,8,12]),
        Puzzle(lines:["🔥 + 🔥 = 14","💧 + 💧 + 💧 = 9"],
               question:"🔥 − 💧 = ?", answer:4, distractors:[3,5,6]),
        Puzzle(lines:["🎯 × 3 = 15","🏆 + 🏆 = 8"],
               question:"🎯 + 🏆 = ?", answer:9, distractors:[8,10,11]),
        Puzzle(lines:["🌟 + 🌟 + 🌟 = 18","🎵 × 4 = 20"],
               question:"🌟 × 🎵 = ?", answer:30, distractors:[24,36,25]),
        Puzzle(lines:["🐉 − 2 = 6","🦋 + 🦋 = 10"],
               question:"🐉 + 🦋 = ?", answer:13, distractors:[11,14,12]),
        Puzzle(lines:["🍩 × 🍩 = 9","🌺 + 3 = 7"],
               question:"🍩 × 🌺 = ?", answer:12, distractors:[9,15,6]),
        Puzzle(lines:["⚡ + ⚡ + ⚡ = 15","🎃 × 2 = 12"],
               question:"⚡ + 🎃 = ?", answer:11, distractors:[9,12,13]),
    ]

    @State private var queue: [Puzzle] = []
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 90.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Puzzle? { queue.first }

    var body: some View {
        VStack(spacing: 20) {
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
        VStack(spacing: 24) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓ Correct!" : "✗ It was \(current?.answer ?? 0)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            if let p = current {
                VStack(spacing: 8) {
                    ForEach(p.lines, id: \.self) { line in
                        Text(line).font(.system(size: 22, weight: .semibold))
                    }
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

                Text(p.question)
                    .font(.system(size: 28, weight: .black))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(choices, id: \.self) { n in
                        Button { guess(n) } label: {
                            Text("\(n)").font(.title2.bold())
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
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
        guard let p = current else { return }
        let ok = n == p.answer
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = puzzles.shuffled() }
        choices = queue.first!.choices
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 90; gameOver = false; feedback = nil
        queue = puzzles.shuffled()
        choices = queue.first!.choices
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { EmojiMathView() }
