import SwiftUI

// Letters fall. Tap only the vowels before they hit the bottom.
struct LetterBombView: View {
    private struct FallingLetter: Identifiable {
        let id = UUID()
        let char: Character
        var y: CGFloat = 0.05
        var x: CGFloat
        var done = false
        var isVowel: Bool { "AEIOUaeiou".contains(char) }
    }

    @State private var letters: [FallingLetter] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 45.0
    @State private var gameOver = false
    @State private var loopTask: Task<Void, Never>? = nil
    @State private var spawnTask: Task<Void, Never>? = nil

    private let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
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
                    Text("Tap only VOWELS (A E I O U)")
                        .font(.subheadline).foregroundStyle(.secondary).padding(.top, 4)
                    Spacer()
                }

                ForEach(letters) { item in
                    if !item.done {
                        letterTile(item: item, geo: geo)
                    }
                }

                if gameOver { gameOverOverlay(geo: geo) }
            }
        }
        .onAppear { startGame() }
        .onDisappear { loopTask?.cancel(); spawnTask?.cancel() }
    }

    private func letterTile(item: FallingLetter, geo: GeometryProxy) -> some View {
        Button {
            tap(item)
        } label: {
            Text(String(item.char))
                .font(.system(size: 32, weight: .black, design: .rounded))
                .frame(width: 52, height: 52)
                .background(
                    item.isVowel ? Color.orange.opacity(0.2) : Color(.systemGray5),
                    in: Circle()
                )
                .foregroundStyle(item.isVowel ? .orange : .primary)
        }
        .buttonStyle(.plain)
        .position(x: item.x * geo.size.width, y: item.y * geo.size.height)
    }

    private func gameOverOverlay(geo: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                Button("Play Again") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func tap(_ item: FallingLetter) {
        guard !gameOver else { return }
        if let idx = letters.firstIndex(where: { $0.id == item.id }) {
            if item.isVowel {
                score += 1
                withAnimation { letters[idx].done = true }
            } else {
                lives -= 1
                withAnimation { letters[idx].done = true }
                if lives <= 0 { gameOver = true }
            }
        }
    }

    private func startGame() {
        score = 0; lives = 3; timeLeft = 45; gameOver = false; letters = []
        loopTask?.cancel(); spawnTask?.cancel()

        loopTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    timeLeft -= 1
                    if timeLeft <= 0 { gameOver = true; return }
                    // Drop fallen letters that reached bottom
                    for i in letters.indices where !letters[i].done && letters[i].y > 0.90 {
                        if letters[i].isVowel { lives -= 1; if lives <= 0 { gameOver = true } }
                        letters[i].done = true
                    }
                }
            }
        }

        spawnTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1200))
                guard !gameOver else { return }
                await MainActor.run {
                    let char = alphabet.randomElement()!
                    let x = CGFloat.random(in: 0.12...0.88)
                    letters.append(FallingLetter(char: char, x: x))
                    // Advance all active letters downward
                    for i in letters.indices where !letters[i].done {
                        letters[i].y += 0.12
                    }
                }
            }
        }
    }
}

#Preview { LetterBombView() }
