import SwiftUI

// Stroop-style: a color name is shown in a different ink color.
// Tap the button matching the INK color, not the word.
struct ColorFlashView: View {
    private let palette: [(name: String, color: Color)] = [
        ("Red", .red), ("Blue", .blue), ("Green", .green),
        ("Yellow", .yellow), ("Purple", .purple), ("Orange", .orange)
    ]

    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var wordIdx = 0
    @State private var inkIdx = 0
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
                    Text(fb ? "✓" : "✗").foregroundStyle(fb ? .green : .red)
                } else {
                    Text(" ")
                }
            }
            .font(.system(size: 40, weight: .black))
            .frame(height: 52)

            VStack(spacing: 8) {
                Text("Tap the INK color").font(.subheadline).foregroundStyle(.secondary)
                Text(palette[wordIdx].name)
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(palette[inkIdx].color)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { idx in
                    Button {
                        guess(idx)
                    } label: {
                        Text(palette[idx].name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(palette[idx].color, in: RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
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

    private func guess(_ idx: Int) {
        let correct = idx == inkIdx
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            await MainActor.run { withAnimation { feedback = nil }; nextRound() }
        }
    }

    private func nextRound() {
        wordIdx = Int.random(in: 0..<palette.count)
        inkIdx = Int.random(in: 0..<palette.count)
        var pool = Array(palette.indices.filter { $0 != inkIdx }.shuffled().prefix(3))
        pool.append(inkIdx)
        choices = pool.shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        nextRound()
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
}

#Preview { ColorFlashView() }
