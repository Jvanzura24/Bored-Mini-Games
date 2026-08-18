//
//  MergeTilesView.swift
//  Bored Mini Games
//
//  Swipe to slide the tiles; equal tiles merge and double. Chase a high score.
//

import SwiftUI

struct MergeTilesView: View {
    private static let size = 4

    @State private var grid: [[Int]] = MergeTilesView.emptyGrid()
    @State private var score = 0
    @AppStorage("mergeTilesBestScore") private var bestScore = 0
    @State private var isGameOver = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 24) {
                scoreBox("Score", score)
                scoreBox("Best", bestScore)
            }

            GeometryReader { geo in
                let boardSide = min(geo.size.width, geo.size.height)
                let spacing: CGFloat = 8
                let tileSide = (boardSide - spacing * CGFloat(Self.size + 1)) / CGFloat(Self.size)

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.73, green: 0.68, blue: 0.63))
                        .frame(width: boardSide, height: boardSide)

                    VStack(spacing: spacing) {
                        ForEach(0..<Self.size, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(0..<Self.size, id: \.self) { col in
                                    tileView(grid[row][col], side: tileSide)
                                }
                            }
                        }
                    }

                    if isGameOver {
                        VStack(spacing: 12) {
                            Text("Game Over")
                                .font(.largeTitle.bold())
                            Button("Try Again") { resetGame() }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        let t = value.translation
                        if abs(t.width) > abs(t.height) {
                            move(t.width > 0 ? .right : .left)
                        } else {
                            move(t.height > 0 ? .down : .up)
                        }
                    }
            )

            Button("New Game") { resetGame() }
                .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            if grid.allSatisfy({ $0.allSatisfy { $0 == 0 } }) {
                resetGame()
            }
        }
    }

    private func scoreBox(_ title: String, _ value: Int) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.bold().monospacedDigit())
        }
        .frame(minWidth: 80)
        .padding(.vertical, 8)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
    }

    private func tileView(_ value: Int, side: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(tileColor(value))
            if value > 0 {
                Text("\(value)")
                    .font(.system(size: value < 1000 ? side * 0.38 : side * 0.3,
                                  weight: .bold, design: .rounded))
                    .foregroundStyle(value <= 4 ? Color(red: 0.47, green: 0.43, blue: 0.4) : .white)
                    .minimumScaleFactor(0.5)
            }
        }
        .frame(width: side, height: side)
        .animation(.easeOut(duration: 0.12), value: value)
    }

    private func tileColor(_ value: Int) -> Color {
        switch value {
        case 0: Color(red: 0.8, green: 0.76, blue: 0.71)
        case 2: Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4: Color(red: 0.93, green: 0.88, blue: 0.78)
        case 8: Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16: Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32: Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64: Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128: Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256: Color(red: 0.93, green: 0.8, blue: 0.38)
        case 512: Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: Color(red: 0.93, green: 0.77, blue: 0.25)
        default: Color(red: 0.93, green: 0.76, blue: 0.18)
        }
    }

    // MARK: - Game logic

    private enum MoveDirection {
        case up, down, left, right
    }

    private static func emptyGrid() -> [[Int]] {
        Array(repeating: Array(repeating: 0, count: size), count: size)
    }

    private func resetGame() {
        grid = Self.emptyGrid()
        score = 0
        isGameOver = false
        spawnTile()
        spawnTile()
    }

    private func spawnTile() {
        var empty: [(Int, Int)] = []
        for row in 0..<Self.size {
            for col in 0..<Self.size where grid[row][col] == 0 {
                empty.append((row, col))
            }
        }
        guard let (row, col) = empty.randomElement() else { return }
        grid[row][col] = Int.random(in: 0..<10) == 0 ? 4 : 2
    }

    /// Slides one row's values toward index 0, merging equal neighbors once.
    private func slideRow(_ row: [Int]) -> (row: [Int], gained: Int) {
        var tiles = row.filter { $0 != 0 }
        var gained = 0
        var i = 0
        while i < tiles.count - 1 {
            if tiles[i] == tiles[i + 1] {
                tiles[i] *= 2
                gained += tiles[i]
                tiles.remove(at: i + 1)
            }
            i += 1
        }
        while tiles.count < Self.size {
            tiles.append(0)
        }
        return (tiles, gained)
    }

    private func move(_ direction: MoveDirection) {
        guard !isGameOver else { return }

        var newGrid = grid
        var gained = 0

        for i in 0..<Self.size {
            // Extract the line of tiles in slide order, slide it, write it back.
            var line: [Int]
            switch direction {
            case .left: line = grid[i]
            case .right: line = grid[i].reversed()
            case .up: line = (0..<Self.size).map { grid[$0][i] }
            case .down: line = (0..<Self.size).map { grid[$0][i] }.reversed()
            }

            let result = slideRow(line)
            gained += result.gained
            let slid = result.row

            switch direction {
            case .left:
                newGrid[i] = slid
            case .right:
                newGrid[i] = slid.reversed()
            case .up:
                for j in 0..<Self.size { newGrid[j][i] = slid[j] }
            case .down:
                let reversed = Array(slid.reversed())
                for j in 0..<Self.size { newGrid[j][i] = reversed[j] }
            }
        }

        guard newGrid != grid else { return }

        grid = newGrid
        score += gained
        bestScore = max(bestScore, score)
        spawnTile()

        if !hasAnyMove() {
            isGameOver = true
        }
    }

    private func hasAnyMove() -> Bool {
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                if grid[row][col] == 0 { return true }
                if col + 1 < Self.size && grid[row][col] == grid[row][col + 1] { return true }
                if row + 1 < Self.size && grid[row][col] == grid[row + 1][col] { return true }
            }
        }
        return false
    }
}

#Preview {
    MergeTilesView()
}
