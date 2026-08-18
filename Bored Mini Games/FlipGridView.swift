import SwiftUI

// Disc flipping game on a 6×6 board vs a greedy AI.
struct FlipGridView: View {
    private let size = 6
    private typealias Board = [[Int]]  // 0=empty,1=player,2=cpu

    @State private var board: Board = Array(repeating: Array(repeating: 0, count: 6), count: 6)
    @State private var playerScore = 0
    @State private var cpuScore = 0
    @State private var gameOver = false
    @State private var statusMsg = "Your turn"
    @State private var validMoves: Set<[Int]> = []

    private let directions = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 40) {
                VStack { Text("You ●").font(.headline); Text("\(playerScore)").font(.system(size:40,weight:.black)) }
                VStack { Text("CPU ○").font(.headline); Text("\(cpuScore)").font(.system(size:40,weight:.black)) }
            }

            Text(statusMsg).font(.subheadline).foregroundStyle(.secondary)

            gameGrid

            if gameOver {
                Button("New Game") { resetGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
        }
        .onAppear { resetGame() }
    }

    private var gameGrid: some View {
        VStack(spacing: 4) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(0..<size, id: \.self) { col in
                        let isValid = !gameOver && validMoves.contains([row, col])
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isValid ? Color.green.opacity(0.25) : Color.green.opacity(0.55))
                                .aspectRatio(1, contentMode: .fit)
                            if board[row][col] == 1 {
                                Circle().fill(Color.black).padding(6)
                            } else if board[row][col] == 2 {
                                Circle().fill(Color.white).padding(6)
                            } else if isValid {
                                Circle().fill(Color.black.opacity(0.2)).padding(10)
                            }
                        }
                        .onTapGesture {
                            if isValid { playerMove(row: row, col: col) }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func resetGame() {
        board = Array(repeating: Array(repeating: 0, count: size), count: size)
        let mid = size / 2
        board[mid-1][mid-1] = 2; board[mid][mid] = 2
        board[mid-1][mid] = 1; board[mid][mid-1] = 1
        gameOver = false; updateScores()
        validMoves = getValidMoves(for: 1)
        statusMsg = "Your turn"
    }

    private func playerMove(row: Int, col: Int) {
        guard applyMove(row: row, col: col, player: 1) else { return }
        updateScores()
        let cpuMoves = getValidMoves(for: 2)
        if cpuMoves.isEmpty {
            validMoves = getValidMoves(for: 1)
            if validMoves.isEmpty { endGame() }
            else { statusMsg = "CPU passes — your turn" }
            return
        }
        statusMsg = "CPU thinking…"
        validMoves = []
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { cpuTurn(moves: cpuMoves) }
        }
    }

    private func cpuTurn(moves: Set<[Int]>) {
        let best = moves.max { a, b in
            flippedCount(row: a[0], col: a[1], player: 2) < flippedCount(row: b[0], col: b[1], player: 2)
        }!
        _ = applyMove(row: best[0], col: best[1], player: 2)
        updateScores()
        validMoves = getValidMoves(for: 1)
        if validMoves.isEmpty {
            let cpuMoves2 = getValidMoves(for: 2)
            if cpuMoves2.isEmpty { endGame() }
            else { statusMsg = "You pass — CPU goes"; Task { try? await Task.sleep(for: .milliseconds(400)); await MainActor.run { cpuTurn(moves: cpuMoves2) } } }
        } else {
            statusMsg = "Your turn"
        }
    }

    @discardableResult
    private func applyMove(row: Int, col: Int, player: Int) -> Bool {
        let flips = cellsToFlip(row: row, col: col, player: player)
        guard !flips.isEmpty || isValidPlacement(row: row, col: col, player: player) else { return false }
        guard isValidPlacement(row: row, col: col, player: player) else { return false }
        board[row][col] = player
        for (r, c) in flips { board[r][c] = player }
        return true
    }

    private func isValidPlacement(row: Int, col: Int, player: Int) -> Bool {
        board[row][col] == 0 && !cellsToFlip(row: row, col: col, player: player).isEmpty
    }

    private func cellsToFlip(row: Int, col: Int, player: Int) -> [(Int,Int)] {
        guard board[row][col] == 0 else { return [] }
        let opp = player == 1 ? 2 : 1
        var flips: [(Int,Int)] = []
        for (dr, dc) in directions {
            var r = row + dr, c = col + dc
            var line: [(Int,Int)] = []
            while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == opp {
                line.append((r, c)); r += dr; c += dc
            }
            if !line.isEmpty && r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
                flips.append(contentsOf: line)
            }
        }
        return flips
    }

    private func flippedCount(row: Int, col: Int, player: Int) -> Int {
        cellsToFlip(row: row, col: col, player: player).count
    }

    private func getValidMoves(for player: Int) -> Set<[Int]> {
        var moves: Set<[Int]> = []
        for r in 0..<size { for c in 0..<size { if isValidPlacement(row: r, col: c, player: player) { moves.insert([r, c]) } } }
        return moves
    }

    private func updateScores() {
        playerScore = board.flatMap { $0 }.filter { $0 == 1 }.count
        cpuScore = board.flatMap { $0 }.filter { $0 == 2 }.count
    }

    private func endGame() {
        gameOver = true
        if playerScore > cpuScore { statusMsg = "You win! 🎉" }
        else if cpuScore > playerScore { statusMsg = "CPU wins!" }
        else { statusMsg = "Draw!" }
    }
}

#Preview { FlipGridView() }
