import SwiftUI

struct SpellingCheckView: View {
    private struct Word { let shown: String; let correct: Bool }

    private let words: [Word] = [
        Word(shown:"Receive",correct:true),    Word(shown:"Beleive",correct:false),
        Word(shown:"Necessary",correct:true),  Word(shown:"Accomodate",correct:false),
        Word(shown:"Separate",correct:true),   Word(shown:"Occured",correct:false),
        Word(shown:"Embarrass",correct:true),  Word(shown:"Begining",correct:false),
        Word(shown:"Definitely",correct:true), Word(shown:"Publically",correct:false),
        Word(shown:"Grammar",correct:true),    Word(shown:"Mischievous",correct:true),
        Word(shown:"Wierd",correct:false),     Word(shown:"Rhythm",correct:true),
        Word(shown:"Privilege",correct:true),  Word(shown:"Existance",correct:false),
        Word(shown:"Recommend",correct:true),  Word(shown:"Independant",correct:false),
        Word(shown:"Conscientious",correct:true), Word(shown:"Questionaire",correct:false),
        Word(shown:"Entrepreneur",correct:true),  Word(shown:"Occassion",correct:false),
        Word(shown:"Colleague",correct:true),  Word(shown:"Aquire",correct:false),
        Word(shown:"Millennium",correct:true), Word(shown:"Tommorow",correct:false),
        Word(shown:"Perseverance",correct:true), Word(shown:"Perseverence",correct:false),
        Word(shown:"Conscience",correct:true), Word(shown:"Liason",correct:false),
        Word(shown:"Supercede",correct:false),  Word(shown:"Supersede",correct:true),
    ]

    @State private var queue: [Word] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Word? { queue.first }

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
                    Text(fb ? "✓ Correct!" : "✗ Wrong!").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            if let w = current {
                VStack(spacing: 12) {
                    Text("Is this spelled correctly?").font(.subheadline).foregroundStyle(.secondary)
                    Text(w.shown)
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                HStack(spacing: 20) {
                    answerBtn("✓ Correct", .green) { answer(true) }
                    answerBtn("✗ Wrong", .red)    { answer(false) }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func answerBtn(_ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.title3.bold())
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(color, in: RoundedRectangle(cornerRadius: 14))
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

    private func answer(_ isCorrect: Bool) {
        guard let w = current else { return }
        let ok = isCorrect == w.correct
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = words.shuffled() }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = words.shuffled()
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

#Preview { SpellingCheckView() }
