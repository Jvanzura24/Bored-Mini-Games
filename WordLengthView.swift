import SwiftUI

// Which word is longer? Quick visual perception game.
struct WordLengthView: View {
    private let wordPool = [
        "cat","fish","tiger","elephant","ant","buffalo","rat","salamander",
        "bat","crocodile","bee","rhinoceros","ox","caterpillar","fly","hippopotamus",
        "emu","flamingo","hen","albatross","jay","woodpecker","wren","nightingale",
        "oak","pine","sequoia","fir","elm","magnolia","ash","pomegranate",
        "cup","plate","refrigerator","pan","fork","colander","lid","tablespoon",
        "sun","moon","asteroid","star","planet","nebula","sky","atmosphere",
        "run","jump","sprint","stroll","dash","accelerate","hop","somersault",
        "red","blue","violet","green","tan","ultraviolet","gold","chartreuse",
    ]

    @State private var wordA = ""
    @State private var wordB = ""
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
                    let longer = wordA.count >= wordB.count ? wordA : wordB
                    Text(fb ? "✓" : "✗ \"\(longer)\" (\(max(wordA.count, wordB.count)))").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("Tap the LONGER word")
                .font(.headline).foregroundStyle(.secondary)

            VStack(spacing: 16) {
                Button { tapped("A") } label: {
                    Text(wordA)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Text("or").font(.headline).foregroundStyle(.secondary)

                Button { tapped("B") } label: {
                    Text(wordB)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .background(Color.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                        .foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
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

    private func tapped(_ choice: String) {
        let correct: Bool
        if wordA.count == wordB.count {
            correct = true // tie always correct
        } else {
            correct = (choice == "A") == (wordA.count > wordB.count)
        }
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        let a = wordPool.randomElement()!
        var b = wordPool.randomElement()!
        while b == a { b = wordPool.randomElement()! }
        wordA = a; wordB = b
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

#Preview { WordLengthView() }
