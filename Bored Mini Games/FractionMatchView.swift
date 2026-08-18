import SwiftUI

struct FractionMatchView: View {
    private struct Frac {
        let top: Int; let bot: Int
        var label: String { "\(top)/\(bot)" }
        var value: Double { Double(top) / Double(bot) }
    }

    private let fractions: [Frac] = [
        Frac(top:1,bot:2), Frac(top:1,bot:4), Frac(top:3,bot:4), Frac(top:1,bot:3),
        Frac(top:2,bot:3), Frac(top:1,bot:5), Frac(top:2,bot:5), Frac(top:3,bot:5),
        Frac(top:4,bot:5), Frac(top:1,bot:8), Frac(top:3,bot:8), Frac(top:5,bot:8),
        Frac(top:7,bot:8), Frac(top:1,bot:10), Frac(top:3,bot:10), Frac(top:7,bot:10),
        Frac(top:9,bot:10), Frac(top:1,bot:6), Frac(top:5,bot:6), Frac(top:1,bot:20),
    ]

    @State private var current = Frac(top: 1, bot: 2)
    @State private var choices: [Double] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
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
                    Text(fb ? "✓" : "✗ \(String(format: "%.2f", current.value))")
                        .foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            VStack(spacing: 4) {
                Text("Convert to decimal").font(.subheadline).foregroundStyle(.secondary)
                Text(current.label)
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundStyle(.blue)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(0..<choices.count, id: \.self) { i in
                    Button { guess(choices[i]) } label: {
                        Text(String(format: "%.2f", choices[i]))
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

    private func guess(_ v: Double) {
        let ok = abs(v - current.value) < 0.001
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil }; nextQuestion() }
        }
    }

    private func nextQuestion() {
        current = fractions.randomElement()!
        var pool: [Double] = [current.value]
        let all = fractions.map(\.value)
        while pool.count < 4 {
            let candidate = all.randomElement()!
            if !pool.contains(where: { abs($0 - candidate) < 0.001 }) { pool.append(candidate) }
        }
        choices = pool.shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        nextQuestion()
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

#Preview { FractionMatchView() }
