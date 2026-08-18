import SwiftUI

// A 3×3 grid with the bottom-right missing. Pick which shape completes the pattern.
struct VisualPatternView: View {
    // Patterns: each row shares shape, each column shares color
    private let shapes = ["circle", "square", "triangle.fill"]
    private let colors: [Color] = [.red, .blue, .green]

    @State private var patternColors: [Color] = []     // 9 cells (row-major), color per cell
    @State private var patternShapes: [String] = []    // 9 cells, shape per cell
    @State private var choices: [(String, Color)] = [] // 4 answer options (shape, color)
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
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("Which completes the pattern?").font(.headline).foregroundStyle(.secondary)

            // 3×3 grid with bottom-right as "?"
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { i in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                        if i == 8 {
                            Text("?").font(.system(size: 28, weight: .black)).foregroundStyle(.secondary)
                        } else if i < patternShapes.count {
                            Image(systemName: patternShapes[i])
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(patternColors[i])
                        }
                    }
                }
            }
            .padding(.horizontal, 60)

            // 4 choice buttons
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices.indices, id: \.self) { i in
                    Button { guess(i) } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray5))
                                .frame(maxWidth: .infinity, minHeight: 56)
                            Image(systemName: choices[i].0)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(choices[i].1)
                        }
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
        let correct = choices[idx].0 == patternShapes[8] && choices[idx].1 == patternColors[8]
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        // Each row has same shape, each column has same color
        let rowShapes = shapes.shuffled()
        let colColors = colors.shuffled()
        var ps: [String] = []; var pc: [Color] = []
        for r in 0..<3 { for c in 0..<3 { ps.append(rowShapes[r]); pc.append(colColors[c]) } }
        patternShapes = ps; patternColors = pc
        // Correct answer is cell 8
        let correctShape = ps[8]; let correctColor = pc[8]
        var pool: [(String, Color)] = [(correctShape, correctColor)]
        while pool.count < 4 {
            let s = shapes.randomElement()!; let c = colors.randomElement()!
            if !(s == correctShape && c == correctColor) { pool.append((s, c)) }
        }
        choices = Array(pool.prefix(4)).shuffled()
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

#Preview { VisualPatternView() }
