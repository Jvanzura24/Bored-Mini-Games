import SwiftUI

struct RhymePickView: View {
    private struct Q {
        let word: String; let rhyme: String; let wrong: [String]
        var choices: [String] { ([rhyme] + wrong).shuffled() }
    }

    private let questions: [Q] = [
        Q(word:"CAT",    rhyme:"HAT",    wrong:["DOG","SUN","TREE"]),
        Q(word:"CAKE",   rhyme:"LAKE",   wrong:["BIRD","MOON","FISH"]),
        Q(word:"BALL",   rhyme:"TALL",   wrong:["RAIN","BOOK","LAMP"]),
        Q(word:"NIGHT",  rhyme:"LIGHT",  wrong:["BLUE","SAND","FROG"]),
        Q(word:"RING",   rhyme:"SING",   wrong:["DOOR","WINE","BOLT"]),
        Q(word:"STAR",   rhyme:"CAR",    wrong:["FERN","DUCK","PINK"]),
        Q(word:"TREE",   rhyme:"FREE",   wrong:["MINT","GOLD","BEAR"]),
        Q(word:"HAND",   rhyme:"SAND",   wrong:["KITE","DRUM","VINE"]),
        Q(word:"RAIN",   rhyme:"TRAIN",  wrong:["SOCK","MIST","LEAF"]),
        Q(word:"CLOCK",  rhyme:"ROCK",   wrong:["WAVE","DUSK","GRAY"]),
        Q(word:"BLUE",   rhyme:"FLEW",   wrong:["DARK","PINE","RUST"]),
        Q(word:"MOON",   rhyme:"SPOON",  wrong:["FAST","DIVE","CORD"]),
        Q(word:"HOOK",   rhyme:"BOOK",   wrong:["LIME","WAND","SKIP"]),
        Q(word:"DREAM",  rhyme:"STREAM", wrong:["GLAD","HORN","PUFF"]),
        Q(word:"HEAT",   rhyme:"FEET",   wrong:["SNAP","GLOW","CRISP"]),
        Q(word:"GROW",   rhyme:"SNOW",   wrong:["LOCK","DAMP","CHIP"]),
        Q(word:"MIND",   rhyme:"FIND",   wrong:["PLUM","WICK","SAGE"]),
        Q(word:"GATE",   rhyme:"LATE",   wrong:["FLIP","BLUR","CHILL"]),
        Q(word:"FISH",   rhyme:"DISH",   wrong:["GUST","PEAR","DULL"]),
        Q(word:"BRIGHT", rhyme:"NIGHT",  wrong:["COLD","DAMP","SOUR"]),
    ]

    @State private var queue: [Q] = []
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Q? { queue.first }

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
                    Text(fb ? "✓" : "✗ \(current?.rhyme ?? "")").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            if let q = current {
                VStack(spacing: 8) {
                    Text("Which word rhymes with…").font(.subheadline).foregroundStyle(.secondary)
                    Text(q.word).font(.system(size: 64, weight: .black, design: .rounded)).foregroundStyle(.blue)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(choices, id: \.self) { w in
                        Button { pick(w, correct: q.rhyme) } label: {
                            Text(w).font(.title2.bold())
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

    private func pick(_ w: String, correct: String) {
        let ok = w == correct
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = questions.shuffled() }
        choices = queue.first!.choices
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = questions.shuffled()
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

#Preview { RhymePickView() }
