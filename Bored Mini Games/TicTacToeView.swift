//
//  TicTacToeView.swift
//  Bored Mini Games
//
//  Tic-tac-toe against a computer opponent. Hard mode uses minimax and
//  plays perfectly, Easy mode picks random open squares, and Medium mixes
//  the two.
//

import SwiftUI

struct TicTacToeView: View {
    private enum Player {
        case x, o

        var symbol: String { self == .x ? "xmark" : "circle" }
        var color: Color { self == .x ? .blue : .red }
    }

    @State private var board: [Player?] = Array(repeating: nil, count: 9)
    @State private var isPlayerTurn = true
    @State private var isRoundOver = false
    @State private var statusText = "Your turn — you are X"
    @AppStorage("difficulty.ticTacToe") private var difficulty: Difficulty = .medium
    @State private var playerWins = 0
    @State private var computerWins = 0
    @State private var draws = 0

    private static let winLines: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8],
        [0, 3, 6], [1, 4, 7], [2, 5, 8],
        [0, 4, 8], [2, 4, 6]
    ]

    var body: some View {
        VStack(spacing: 20) {
            DifficultyPicker(difficulty: $difficulty)

            HStack(spacing: 24) {
                scoreLabel("You", playerWins, .blue)
                scoreLabel("Draws", draws, .secondary)
                scoreLabel("CPU", computerWins, .red)
            }

            Text(statusText)
                .font(.headline)

            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(0..<3) { row in
                    GridRow {
                        ForEach(0..<3) { col in
                            cell(at: row * 3 + col)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Button("New Round") { resetRound() }
                .buttonStyle(.borderedProminent)
                .opacity(isRoundOver ? 1 : 0)
        }
        .padding(.vertical)
    }

    private func scoreLabel(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.title3.bold()).foregroundStyle(color)
        }
    }

    private func cell(at index: Int) -> some View {
        Button {
            playerTap(index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.secondary)
                if let player = board[index] {
                    Image(systemName: player.symbol)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(player.color)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }

    private func playerTap(_ index: Int) {
        guard isPlayerTurn, !isRoundOver, board[index] == nil else { return }
        board[index] = .x
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
        let openSquares = board.indices.filter { board[$0] == nil }
        guard !openSquares.isEmpty else { return }

        let choice: Int
        switch difficulty {
        case .easy:
            choice = openSquares.randomElement()!
        case .medium:
            // Plays perfectly half the time, so it can be outsmarted.
            choice = Bool.random() ? bestMove() : openSquares.randomElement()!
        case .hard:
            choice = bestMove()
        }
        board[choice] = .o
        isPlayerTurn = true
        if !checkRoundEnd() {
            statusText = "Your turn — you are X"
        }
    }

    /// Returns true if the round ended (win or draw).
    private func checkRoundEnd() -> Bool {
        if let winner = winner(of: board) {
            isRoundOver = true
            if winner == .x {
                playerWins += 1
                statusText = "You win! 🎉"
            } else {
                computerWins += 1
                statusText = "Computer wins."
            }
            return true
        }
        if !board.contains(nil) {
            isRoundOver = true
            draws += 1
            statusText = "It's a draw."
            return true
        }
        return false
    }

    private func resetRound() {
        board = Array(repeating: nil, count: 9)
        isRoundOver = false
        isPlayerTurn = true
        statusText = "Your turn — you are X"
    }

    // MARK: - Minimax

    private func winner(of board: [Player?]) -> Player? {
        for line in Self.winLines {
            if let p = board[line[0]], board[line[1]] == p, board[line[2]] == p {
                return p
            }
        }
        return nil
    }

    private func bestMove() -> Int {
        var bestScore = Int.min
        var move = board.firstIndex(of: nil) ?? 0
        for index in board.indices where board[index] == nil {
            var trial = board
            trial[index] = .o
            let score = minimax(trial, depth: 0, maximizing: false)
            if score > bestScore {
                bestScore = score
                move = index
            }
        }
        return move
    }

    private func minimax(_ board: [Player?], depth: Int, maximizing: Bool) -> Int {
        if let winner = winner(of: board) {
            return winner == .o ? 10 - depth : depth - 10
        }
        if !board.contains(nil) { return 0 }

        var best = maximizing ? Int.min : Int.max
        for index in board.indices where board[index] == nil {
            var trial = board
            trial[index] = maximizing ? .o : .x
            let score = minimax(trial, depth: depth + 1, maximizing: !maximizing)
            best = maximizing ? max(best, score) : min(best, score)
        }
        return best
    }
}

#Preview {
    TicTacToeView()
}
