//
//  FourInARowView.swift
//  Bored Mini Games
//
//  Drop discs into the board and connect four in a row before the computer
//  does. Easy picks random columns, Medium wins or blocks when it can, and
//  Hard searches a few moves ahead.
//

import SwiftUI

struct FourInARowView: View {
    private enum Disc {
        case player, computer
    }

    private static let columnCount = 7
    private static let rowCount = 6

    /// board[column][row], with row 0 at the bottom of the board.
    @State private var board: [[Disc?]] = FourInARowView.emptyBoard()
    @State private var isPlayerTurn = true
    @State private var isRoundOver = false
    @State private var statusText = "Your turn — tap a column"
    @State private var playerWins = 0
    @State private var computerWins = 0
    @State private var draws = 0
    @AppStorage("difficulty.fourInARow") private var difficulty: Difficulty = .medium

    var body: some View {
        VStack(spacing: 16) {
            DifficultyPicker(difficulty: $difficulty)

            HStack(spacing: 24) {
                scoreLabel("You", playerWins, .orange)
                scoreLabel("Draws", draws, .secondary)
                scoreLabel("CPU", computerWins, .red)
            }

            Text(statusText)
                .font(.headline)

            boardView
                .padding(.horizontal, 16)

            Button("New Round") { resetRound() }
                .buttonStyle(.borderedProminent)
                .opacity(isRoundOver ? 1 : 0)

            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }

    private func scoreLabel(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.bold()).foregroundStyle(color)
        }
    }

    private var boardView: some View {
        HStack(spacing: 6) {
            ForEach(0..<Self.columnCount, id: \.self) { column in
                VStack(spacing: 6) {
                    ForEach((0..<Self.rowCount).reversed(), id: \.self) { row in
                        Circle()
                            .fill(cellColor(column: column, row: row))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { playerTap(column) }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.15, green: 0.30, blue: 0.70))
        )
        .animation(.easeOut(duration: 0.2), value: board)
    }

    private func cellColor(column: Int, row: Int) -> Color {
        switch board[column][row] {
        case .player: .yellow
        case .computer: .red
        case nil: .white.opacity(0.85)
        }
    }

    // MARK: - Turns

    private func playerTap(_ column: Int) {
        guard isPlayerTurn, !isRoundOver else { return }
        guard drop(&board, column: column, disc: .player) else { return }
        isPlayerTurn = false
        if checkRoundEnd() { return }
        statusText = "Computer is thinking…"
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            computerMove()
        }
    }

    private func computerMove() {
        guard !isRoundOver else { return }

        let column: Int
        switch difficulty {
        case .easy:
            column = Self.validColumns(of: board).randomElement()!
        case .medium:
            column = immediateWinOrBlock() ?? Self.validColumns(of: board).randomElement()!
        case .hard:
            column = immediateWinOrBlock() ?? searchBestColumn()
        }
        drop(&board, column: column, disc: .computer)
        isPlayerTurn = true
        if !checkRoundEnd() {
            statusText = "Your turn — tap a column"
        }
    }

    /// Returns true if the round ended (win or draw).
    private func checkRoundEnd() -> Bool {
        if let winner = Self.winner(of: board) {
            isRoundOver = true
            if winner == .player {
                playerWins += 1
                statusText = "You win! 🎉"
            } else {
                computerWins += 1
                statusText = "Computer wins."
            }
            return true
        }
        if Self.validColumns(of: board).isEmpty {
            isRoundOver = true
            draws += 1
            statusText = "It's a draw."
            return true
        }
        return false
    }

    private func resetRound() {
        board = Self.emptyBoard()
        isRoundOver = false
        isPlayerTurn = true
        statusText = "Your turn — tap a column"
    }

    // MARK: - Computer strategy

    /// Takes an immediate winning column, or failing that, blocks the
    /// player's immediate winning column.
    private func immediateWinOrBlock() -> Int? {
        for disc in [Disc.computer, Disc.player] {
            for column in Self.validColumns(of: board) {
                var trial = board
                drop(&trial, column: column, disc: disc)
                if Self.winner(of: trial) == disc { return column }
            }
        }
        return nil
    }

    private func searchBestColumn() -> Int {
        var bestScore = Int.min
        var best = Self.validColumns(of: board).first ?? 0
        for column in Self.validColumns(of: board) {
            var trial = board
            drop(&trial, column: column, disc: .computer)
            let score = minimax(trial, depth: 4, maximizing: false, alpha: Int.min, beta: Int.max)
            if score > bestScore {
                bestScore = score
                best = column
            }
        }
        return best
    }

    private func minimax(_ board: [[Disc?]], depth: Int, maximizing: Bool, alpha: Int, beta: Int) -> Int {
        if let winner = Self.winner(of: board) {
            // Prefer wins that come sooner and losses that come later.
            return winner == .computer ? 1000 + depth : -1000 - depth
        }
        let columns = Self.validColumns(of: board)
        if columns.isEmpty { return 0 }
        if depth == 0 { return Self.evaluate(board) }

        var alpha = alpha
        var beta = beta
        var best = maximizing ? Int.min : Int.max
        for column in columns {
            var trial = board
            drop(&trial, column: column, disc: maximizing ? .computer : .player)
            let score = minimax(trial, depth: depth - 1, maximizing: !maximizing, alpha: alpha, beta: beta)
            if maximizing {
                best = max(best, score)
                alpha = max(alpha, best)
            } else {
                best = min(best, score)
                beta = min(beta, best)
            }
            if beta <= alpha { break }
        }
        return best
    }

    /// Rough position score: holding the center column gives more ways to
    /// make four in a row.
    private static func evaluate(_ board: [[Disc?]]) -> Int {
        board[columnCount / 2].reduce(0) { total, disc in
            switch disc {
            case .computer: total + 3
            case .player: total - 3
            case nil: total
            }
        }
    }

    // MARK: - Board helpers

    private static func emptyBoard() -> [[Disc?]] {
        Array(repeating: Array(repeating: nil, count: rowCount), count: columnCount)
    }

    private static func validColumns(of board: [[Disc?]]) -> [Int] {
        (0..<columnCount).filter { board[$0][rowCount - 1] == nil }
    }

    @discardableResult
    private func drop(_ board: inout [[Disc?]], column: Int, disc: Disc) -> Bool {
        guard let row = board[column].firstIndex(where: { $0 == nil }) else { return false }
        board[column][row] = disc
        return true
    }

    private static func winner(of board: [[Disc?]]) -> Disc? {
        for column in 0..<columnCount {
            for row in 0..<rowCount {
                guard let disc = board[column][row] else { continue }
                for (dx, dy) in [(1, 0), (0, 1), (1, 1), (1, -1)] {
                    var count = 1
                    var c = column + dx
                    var r = row + dy
                    while c >= 0, c < columnCount, r >= 0, r < rowCount, board[c][r] == disc {
                        count += 1
                        if count == 4 { return disc }
                        c += dx
                        r += dy
                    }
                }
            }
        }
        return nil
    }
}

#Preview {
    FourInARowView()
}
