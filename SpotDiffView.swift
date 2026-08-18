import SwiftUI

// Two emoji grids shown side by side. One cell differs. Find it.
struct SpotDiffView: View {
    private let emojis = ["🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐨","🐯",
                          "🦁","🐮","🐷","🐸","🐵","🐔","🐧","🐦","🦆","🦅"]
    private let gridSize = 4

    @State private var leftGrid: [String] = []
    @State private var rightGrid: [String] = []
    @State private var diffIdx = -1
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 16) {
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
        VStack(spacing: 12) {
            Group {
                if let fb = feedback {
                    Text(fb ? "Found it! ✓" : "✗ Wrong side").foregroundStyle(fb ? .green : .red)
                } else {
                    Text("Tap the different emoji on the RIGHT")
                }
            }
            .font(.headline)
            .frame(height: 30)

            HStack(spacing: 8) {
                gridView(grid: leftGrid, isRight: false)
                Divider().frame(width: 2).background(Color.primary.opacity(0.3))
                gridView(grid: rightGrid, isRight: true)
            }
            .padding(.horizontal, 8)
        }
    }

    private func gridView(grid: [String], isRight: Bool) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize), spacing: 4) {
            ForEach(0..<grid.count, id: \.self) { i in
                Button {
                    if isRight { tap(i) }
                } label: {
                    Text(grid[i])
                        .font(.system(size: 28))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(!isRight)
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

    private func tap(_ i: Int) {
        let correct = i == diffIdx
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { feedback = nil; newPuzzle() }
        }
    }

    private func newPuzzle() {
        let count = gridSize * gridSize
        let pool = emojis.shuffled()
        var base = Array(pool.prefix(count))
        leftGrid = base
        // Pick a different emoji for one cell on the right
        diffIdx = Int.random(in: 0..<count)
        var replacement = pool.randomElement()!
        while replacement == base[diffIdx] { replacement = emojis.randomElement()! }
        base[diffIdx] = replacement
        rightGrid = base
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        newPuzzle()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { SpotDiffView() }
