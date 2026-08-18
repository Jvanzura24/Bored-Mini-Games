import SwiftUI

struct LightsOutView: View {
    private let size = 5
    @State private var grid: [[Bool]] = []
    @State private var moves = 0
    @State private var solved = false
    @State private var difficulty: Difficulty = .medium

    var body: some View {
        VStack(spacing: 20) {
            DifficultyPicker(difficulty: $difficulty)
                .onChange(of: difficulty) { _, _ in newPuzzle() }

            Text("Moves: \(moves)").font(.headline)

            if solved {
                solvedView
            } else {
                gameGrid
                Button("New Puzzle") { newPuzzle() }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .onAppear { newPuzzle() }
    }

    private var gameGrid: some View {
        VStack(spacing: 6) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<size, id: \.self) { col in
                        Button {
                            tap(row: row, col: col)
                        } label: {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(grid[row][col] ? Color.yellow : Color(.systemGray5))
                                .shadow(
                                    color: grid[row][col] ? Color.yellow.opacity(0.55) : .clear,
                                    radius: 8
                                )
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.12), value: grid[row][col])
                    }
                }
            }
        }
        .padding(.horizontal, 28)
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Puzzle Solved! ✓")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.green)
            Text("\(moves) move\(moves == 1 ? "" : "s")")
                .font(.title2)
                .foregroundStyle(.secondary)
            Button("New Puzzle") { newPuzzle() }
                .buttonStyle(.borderedProminent)
                .font(.headline)
        }
    }

    private func tap(row: Int, col: Int) {
        let neighbors = [(0,0),(1,0),(-1,0),(0,1),(0,-1)]
        for (dr, dc) in neighbors {
            let r = row + dr, c = col + dc
            if r >= 0 && r < size && c >= 0 && c < size {
                grid[r][c].toggle()
            }
        }
        moves += 1
        if grid.allSatisfy({ $0.allSatisfy { !$0 } }) {
            withAnimation { solved = true }
        }
    }

    private func newPuzzle() {
        moves = 0; solved = false
        grid = Array(repeating: Array(repeating: false, count: size), count: size)
        let taps: Int
        switch difficulty {
        case .easy:   taps = 5
        case .medium: taps = 13
        case .hard:   taps = 22
        }
        for _ in 0..<taps {
            let r = Int.random(in: 0..<size)
            let c = Int.random(in: 0..<size)
            for (dr, dc) in [(0,0),(1,0),(-1,0),(0,1),(0,-1)] {
                let nr = r + dr, nc = c + dc
                if nr >= 0 && nr < size && nc >= 0 && nc < size {
                    grid[nr][nc].toggle()
                }
            }
        }
        // Ensure puzzle is not already solved
        if grid.allSatisfy({ $0.allSatisfy { !$0 } }) { newPuzzle() }
    }
}

#Preview { LightsOutView() }
