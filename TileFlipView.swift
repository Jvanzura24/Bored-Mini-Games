import SwiftUI

// A 4×4 board of colored tiles. Tap to cycle color. Fill all tiles with the same color.
struct TileFlipView: View {
    private let colors: [Color] = [.red, .blue, .green, .yellow]
    private let colorNames = ["Red", "Blue", "Green", "Yellow"]
    private let size = 4

    @State private var grid: [[Int]] = []
    @State private var moves = 0
    @State private var best: Int? = nil
    @State private var solved = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Moves: \(moves)").font(.headline)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 24)

            if solved {
                solvedView
            } else {
                Text("Make all tiles the same color")
                    .font(.subheadline).foregroundStyle(.secondary)
                boardView
                    .padding(.horizontal, 24)
                Button("Shuffle") { setupGrid() }
                    .buttonStyle(.bordered).font(.headline)
            }

            Spacer()
        }
        .onAppear { setupGrid() }
    }

    private var boardView: some View {
        VStack(spacing: 8) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<size, id: \.self) { col in
                        let c = grid.indices.contains(row) && grid[row].indices.contains(col) ? grid[row][col] : 0
                        Button {
                            tap(row: row, col: col)
                        } label: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colors[c])
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .shadow(color: colors[c].opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Solved! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("\(moves) moves").font(.title2).foregroundStyle(.secondary)
            Button("New Puzzle") { setupGrid() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func tap(row: Int, col: Int) {
        guard !solved else { return }
        grid[row][col] = (grid[row][col] + 1) % colors.count
        moves += 1
        checkSolved()
    }

    private func checkSolved() {
        let first = grid[0][0]
        if grid.allSatisfy({ row in row.allSatisfy({ $0 == first }) }) {
            if best == nil || moves < best! { best = moves }
            withAnimation { solved = true }
        }
    }

    private func setupGrid() {
        repeat {
            grid = (0..<size).map { _ in (0..<size).map { _ in Int.random(in: 0..<colors.count) } }
        } while grid.allSatisfy({ row in row.allSatisfy({ $0 == grid[0][0] }) })
        moves = 0; solved = false
    }
}

#Preview { TileFlipView() }
