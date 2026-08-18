import SwiftUI

// Connect adjacent dots to form boxes. Complete a box to score it.
struct DotsBoxesView: View {
    private let dots = 4  // 4×4 dots → 3×3 boxes
    private let boxes: Int = 3

    // Horizontal edges: [row][col] for dots, rows 0..<dots, cols 0..<dots-1
    @State private var hEdges: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 4)
    // Vertical edges: [row][col], rows 0..<dots-1, cols 0..<dots
    @State private var vEdges: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 3)
    @State private var boxOwner: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)
    @State private var playerScore = 0
    @State private var cpuScore = 0
    @State private var currentPlayer = 1  // 1=player, 2=cpu
    @State private var gameOver = false

    private let spacing: CGFloat = 72
    private let dotSize: CGFloat = 12
    private let edgeThick: CGFloat = 8

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                VStack { Text("You").font(.headline); Text("\(playerScore)").font(.system(size:44,weight:.black)).foregroundStyle(.blue) }
                Text("vs").foregroundStyle(.secondary)
                VStack { Text("CPU").font(.headline); Text("\(cpuScore)").font(.system(size:44,weight:.black)).foregroundStyle(.red) }
            }

            Text(gameOver ? (playerScore > cpuScore ? "You win! 🎉" : cpuScore > playerScore ? "CPU wins!" : "Draw!") :
                 currentPlayer == 1 ? "Your turn" : "CPU thinking…")
                .font(.headline)
                .foregroundStyle(gameOver ? Color.primary : currentPlayer == 1 ? .green : .orange)

            boardView
                .frame(width: spacing * CGFloat(dots - 1) + dotSize * 2,
                       height: spacing * CGFloat(dots - 1) + dotSize * 2)

            if gameOver {
                Button("New Game") { resetGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
        }
        .onAppear { resetGame() }
    }

    private var boardView: some View {
        ZStack {
            boxFills
            hEdgeButtons
            vEdgeButtons
            dots2D
        }
    }

    private var boxFills: some View {
        ForEach(0..<boxes, id: \.self) { row in
            ForEach(0..<boxes, id: \.self) { col in
                let owner = boxOwner[row][col]
                if owner != 0 {
                    Rectangle()
                        .fill(owner == 1 ? Color.blue.opacity(0.25) : Color.red.opacity(0.25))
                        .frame(width: spacing - 4, height: spacing - 4)
                        .position(x: CGFloat(col) * spacing + spacing / 2 + dotSize,
                                  y: CGFloat(row) * spacing + spacing / 2 + dotSize)
                }
            }
        }
    }

    private var hEdgeButtons: some View {
        ForEach(0..<dots, id: \.self) { row in
            ForEach(0..<(dots-1), id: \.self) { col in
                let owner = hEdges[row][col]
                Button { if owner == 0 && currentPlayer == 1 { claimHEdge(row: row, col: col) } } label: {
                    Capsule()
                        .fill(owner == 0 ? Color(.systemGray4) : owner == 1 ? Color.blue : Color.red)
                        .frame(width: spacing - dotSize, height: edgeThick)
                }
                .buttonStyle(.plain)
                .position(x: CGFloat(col) * spacing + spacing / 2 + dotSize,
                          y: CGFloat(row) * spacing + dotSize)
                .disabled(owner != 0 || currentPlayer != 1)
            }
        }
    }

    private var vEdgeButtons: some View {
        ForEach(0..<(dots-1), id: \.self) { row in
            ForEach(0..<dots, id: \.self) { col in
                let owner = vEdges[row][col]
                Button { if owner == 0 && currentPlayer == 1 { claimVEdge(row: row, col: col) } } label: {
                    Capsule()
                        .fill(owner == 0 ? Color(.systemGray4) : owner == 1 ? Color.blue : Color.red)
                        .frame(width: edgeThick, height: spacing - dotSize)
                }
                .buttonStyle(.plain)
                .position(x: CGFloat(col) * spacing + dotSize,
                          y: CGFloat(row) * spacing + spacing / 2 + dotSize)
                .disabled(owner != 0 || currentPlayer != 1)
            }
        }
    }

    private var dots2D: some View {
        ForEach(0..<dots, id: \.self) { row in
            ForEach(0..<dots, id: \.self) { col in
                Circle()
                    .fill(Color.primary)
                    .frame(width: dotSize, height: dotSize)
                    .position(x: CGFloat(col) * spacing + dotSize, y: CGFloat(row) * spacing + dotSize)
            }
        }
    }

    private func claimHEdge(row: Int, col: Int) {
        hEdges[row][col] = currentPlayer
        let scored = checkBoxes(player: currentPlayer)
        if !scored { togglePlayer() }
        checkGameOver()
        if currentPlayer == 2 && !gameOver { scheduleCPU() }
    }

    private func claimVEdge(row: Int, col: Int) {
        vEdges[row][col] = currentPlayer
        let scored = checkBoxes(player: currentPlayer)
        if !scored { togglePlayer() }
        checkGameOver()
        if currentPlayer == 2 && !gameOver { scheduleCPU() }
    }

    @discardableResult
    private func checkBoxes(player: Int) -> Bool {
        var scored = false
        for r in 0..<boxes {
            for c in 0..<boxes {
                if boxOwner[r][c] == 0 {
                    let top = hEdges[r][c] != 0
                    let bottom = hEdges[r+1][c] != 0
                    let left = vEdges[r][c] != 0
                    let right = vEdges[r][c+1] != 0
                    if top && bottom && left && right {
                        boxOwner[r][c] = player
                        if player == 1 { playerScore += 1 } else { cpuScore += 1 }
                        scored = true
                    }
                }
            }
        }
        return scored
    }

    private func togglePlayer() { currentPlayer = currentPlayer == 1 ? 2 : 1 }

    private func checkGameOver() {
        if boxOwner.flatMap({ $0 }).filter({ $0 != 0 }).count == boxes * boxes {
            gameOver = true
        }
    }

    private func scheduleCPU() {
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run { cpuPlay() }
        }
    }

    private func cpuPlay() {
        guard !gameOver && currentPlayer == 2 else { return }
        // Greedy: prefer moves that complete a box; else random
        if let move = findCompletingMove() {
            move(); let scored = checkBoxes(player: 2)
            checkGameOver()
            if scored && !gameOver { scheduleCPU() } else if !gameOver { togglePlayer() }
        } else {
            randomMove()
        }
    }

    private func findCompletingMove() -> (() -> Void)? {
        for r in 0..<dots { for c in 0..<(dots-1) { if hEdges[r][c] == 0 {
            hEdges[r][c] = 2
            for br in 0..<boxes { for bc in 0..<boxes {
                if boxOwner[br][bc] == 0 {
                    let t = hEdges[br][bc] != 0; let b = hEdges[br+1][bc] != 0
                    let l = vEdges[br][bc] != 0; let ri = vEdges[br][bc+1] != 0
                    if t && b && l && ri { hEdges[r][c] = 0; return { self.claimHEdge(row: r, col: c) } }
                }
            } }
            hEdges[r][c] = 0
        } } }
        for r in 0..<(dots-1) { for c in 0..<dots { if vEdges[r][c] == 0 {
            vEdges[r][c] = 2
            for br in 0..<boxes { for bc in 0..<boxes {
                if boxOwner[br][bc] == 0 {
                    let t = hEdges[br][bc] != 0; let b = hEdges[br+1][bc] != 0
                    let l = vEdges[br][bc] != 0; let ri = vEdges[br][bc+1] != 0
                    if t && b && l && ri { vEdges[r][c] = 0; return { self.claimVEdge(row: r, col: c) } }
                }
            } }
            vEdges[r][c] = 0
        } } }
        return nil
    }

    private func randomMove() {
        var freeH: [(Int,Int)] = [], freeV: [(Int,Int)] = []
        for r in 0..<dots { for c in 0..<(dots-1) { if hEdges[r][c] == 0 { freeH.append((r,c)) } } }
        for r in 0..<(dots-1) { for c in 0..<dots { if vEdges[r][c] == 0 { freeV.append((r,c)) } } }
        let allFree = freeH.count + freeV.count
        guard allFree > 0 else { return }
        let pick = Int.random(in: 0..<allFree)
        if pick < freeH.count {
            let (r,c) = freeH[pick]; claimHEdge(row: r, col: c)
        } else {
            let (r,c) = freeV[pick - freeH.count]; claimVEdge(row: r, col: c)
        }
    }

    private func resetGame() {
        hEdges = Array(repeating: Array(repeating: 0, count: 3), count: 4)
        vEdges = Array(repeating: Array(repeating: 0, count: 4), count: 3)
        boxOwner = Array(repeating: Array(repeating: 0, count: 3), count: 3)
        playerScore = 0; cpuScore = 0; currentPlayer = 1; gameOver = false
    }
}

#Preview { DotsBoxesView() }
