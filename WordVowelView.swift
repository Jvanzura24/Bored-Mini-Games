import SwiftUI

// How many vowels does this word have? Quick-fire quiz.
struct WordVowelView: View {
    private let words = [
        "cat","elephant","rhythm","audio","strength","beautiful","queue","mysterious",
        "sphinx","umbrella","fly","easy","crypt","education","gym","onomatopoeia",
        "sky","area","owl","crystal","ice","azure","echo","epoch",
        "byte","style","even","open","urn","ivy","old","app",
        "unique","abstract","island","hour","ocean","youth","empty","exit",
    ]

    @State private var word = ""
    @State private var correctCount = 0
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [String] = []

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
                    Text(fb ? "✓" : "✗ \(correctCount) vowel\(correctCount == 1 ? "" : "s")").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            VStack(spacing: 8) {
                Text("How many vowels?")
                    .font(.headline).foregroundStyle(.secondary)
                Text(word)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 24)
            }

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

    private func vowelCount(_ w: String) -> Int {
        w.lowercased().filter { "aeiou".contains($0) }.count
    }

    private func guess(_ n: Int) {
        let correct = n == correctCount
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = words.shuffled() }
        word = queue.removeFirst()
        correctCount = vowelCount(word)
        var pool: Set<Int> = [correctCount]
        while pool.count < 4 {
            let c = Int.random(in: max(0, correctCount - 3)...min(8, correctCount + 3))
            pool.insert(c)
        }
        choices = Array(pool).sorted().shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil; queue = []
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

#Preview { WordVowelView() }
