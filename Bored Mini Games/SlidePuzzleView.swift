//
//  SlidePuzzleView.swift
//  Bored Mini Games
//
//  The classic sliding number puzzle: tap tiles next to the empty space to
//  slide them, and put the numbers back in order. Difficulty sets the board
//  size, and every shuffle is guaranteed to be solvable.
//

import SwiftUI

struct SlidePuzzleView: View {
    /// The board as a flat array in reading order; 0 is the empty space.
    @State private var tiles: [Int] = []
    @State private var moves = 0
    @AppStorage("difficulty.slidePuzzle") private var difficulty: Difficulty = .medium

    private var size: Int { difficulty.puzzleSize }
    private var isSolved: Bool { !tiles.isEmpty && tiles == Self.solvedOrder(size: size) }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: size)
    }

    var body: some View {
        VStack(spacing: 16) {
            DifficultyPicker(difficulty: $difficulty)

            Text("Moves: \(moves)")
                .font(.headline.monospacedDigit())

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tiles, id: \.self) { value in
                    tileView(value)
                        .onTapGesture { tapTile(value) }
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.15), value: tiles)

            if isSolved {
                VStack(spacing: 12) {
                    Text("Solved in \(moves) moves! 🎉")
                        .font(.headline)
                    Button("Play Again") { resetGame() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                Button("Shuffle") { resetGame() }
                    .buttonStyle(.bordered)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .onChange(of: difficulty, initial: true) {
            resetGame()
        }
    }

    private func tileView(_ value: Int) -> some View {
        ZStack {
            if value != 0 {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.31, green: 0.36, blue: 0.45).gradient)
                Text("\(value)")
                    .font(.title2.bold().monospacedDigit())
                    .foregroundStyle(.white)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .contentShape(Rectangle())
    }

    private func tapTile(_ value: Int) {
        guard value != 0, !isSolved,
              let index = tiles.firstIndex(of: value),
              let blank = tiles.firstIndex(of: 0),
              isAdjacent(index, blank)
        else { return }
        tiles.swapAt(index, blank)
        moves += 1
    }

    private func resetGame() {
        var order = Self.solvedOrder(size: size)
        // Shuffle by walking the empty space with random legal moves, so the
        // puzzle is always solvable (a plain shuffle is unsolvable half the time).
        repeat {
            var blank = order.count - 1
            for _ in 0..<(size * size * 25) {
                let next = neighbors(of: blank).randomElement()!
                order.swapAt(blank, next)
                blank = next
            }
        } while order == Self.solvedOrder(size: size)
        tiles = order
        moves = 0
    }

    private func neighbors(of index: Int) -> [Int] {
        let row = index / size
        let column = index % size
        var result: [Int] = []
        if row > 0 { result.append(index - size) }
        if row < size - 1 { result.append(index + size) }
        if column > 0 { result.append(index - 1) }
        if column < size - 1 { result.append(index + 1) }
        return result
    }

    private func isAdjacent(_ a: Int, _ b: Int) -> Bool {
        let (aRow, aColumn) = (a / size, a % size)
        let (bRow, bColumn) = (b / size, b % size)
        return abs(aRow - bRow) + abs(aColumn - bColumn) == 1
    }

    private static func solvedOrder(size: Int) -> [Int] {
        Array(1..<(size * size)) + [0]
    }
}

private extension Difficulty {
    /// Board side length: 3x3, 4x4, or 5x5.
    var puzzleSize: Int {
        switch self {
        case .easy: 3
        case .medium: 4
        case .hard: 5
        }
    }
}

#Preview {
    SlidePuzzleView()
}
