import SwiftUI

struct MazeRunView: View {
    // 7×7 grid. Wall data: set of blocked edges.
    // Each cell (r,c). Walls stored as "r,c,dir" where dir in {U,D,L,R}
    private let mazes: [Set<String>] = [
        // Maze 1 — simple path
        ["0,0,L","0,0,U","0,1,U","0,2,U","0,3,U","0,4,U","0,5,U","0,6,U","0,6,R",
         "1,0,L","1,1,D","1,1,R","1,2,U","1,3,R","1,4,U","1,4,L","1,5,U","1,6,R",
         "2,0,L","2,0,D","2,2,L","2,2,D","2,3,D","2,4,L","2,5,R","2,6,R",
         "3,0,L","3,1,U","3,1,L","3,2,U","3,3,U","3,4,D","3,5,D","3,6,R",
         "4,0,L","4,0,U","4,2,R","4,3,U","4,3,L","4,5,U","4,5,R","4,6,R",
         "5,0,L","5,1,D","5,2,D","5,3,D","5,4,D","5,5,U","5,6,R",
         "6,0,L","6,0,D","6,1,D","6,2,D","6,3,D","6,4,D","6,5,D","6,6,D","6,6,R"],
    ]

    private let size = 7
    @State private var walls: Set<String> = []
    @State private var playerRow = 0
    @State private var playerCol = 0
    @State private var steps = 0
    @State private var solved = false
    @State private var best: Int? = nil

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Steps: \(steps)").font(.headline)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 24)

            if solved {
                solvedView
            } else {
                mazeGrid
                    .padding(.horizontal, 12)
                arrowPad
            }
        }
        .onAppear { newMaze() }
    }

    private var mazeGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<size, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<size, id: \.self) { col in
                        cellView(row: row, col: col)
                    }
                }
            }
        }
    }

    private func cellView(row: Int, col: Int) -> some View {
        let isPlayer = row == playerRow && col == playerCol
        let isGoal = row == size - 1 && col == size - 1
        let wallU = walls.contains("\(row),\(col),U")
        let wallD = walls.contains("\(row),\(col),D")
        let wallL = walls.contains("\(row),\(col),L")
        let wallR = walls.contains("\(row),\(col),R")

        return ZStack {
            Rectangle().fill(isPlayer ? Color.blue.opacity(0.3) : isGoal ? Color.green.opacity(0.3) : Color.clear)
            if isPlayer { Image(systemName: "person.fill").font(.system(size: 14)).foregroundStyle(.blue) }
            if isGoal && !isPlayer { Text("🏁").font(.system(size: 14)) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .border(Color.clear)
        .overlay(alignment: .top)    { if wallU { Rectangle().fill(Color.primary).frame(height: 2) } }
        .overlay(alignment: .bottom) { if wallD { Rectangle().fill(Color.primary).frame(height: 2) } }
        .overlay(alignment: .leading){ if wallL { Rectangle().fill(Color.primary).frame(width: 2) } }
        .overlay(alignment: .trailing){ if wallR { Rectangle().fill(Color.primary).frame(width: 2) } }
        .background(Color(.systemGray6))
    }

    private var arrowPad: some View {
        VStack(spacing: 8) {
            arrowBtn("arrow.up", "U") { move(-1, 0) }
            HStack(spacing: 24) {
                arrowBtn("arrow.left", "L") { move(0, -1) }
                arrowBtn("arrow.down", "D") { move(1, 0) }
                arrowBtn("arrow.right", "R") { move(0, 1) }
            }
        }
        .padding(.bottom, 16)
    }

    private func arrowBtn(_ icon: String, _ dir: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 60, height: 60)
                .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Solved! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("\(steps) steps").font(.title2).foregroundStyle(.secondary)
            Button("New Maze") { newMaze() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func move(_ dr: Int, _ dc: Int) {
        guard !solved else { return }
        let nr = playerRow + dr; let nc = playerCol + dc
        guard nr >= 0 && nr < size && nc >= 0 && nc < size else { return }
        let dir = dr == -1 ? "U" : dr == 1 ? "D" : dc == -1 ? "L" : "R"
        let opp = dr == -1 ? "D" : dr == 1 ? "U" : dc == -1 ? "R" : "L"
        if walls.contains("\(playerRow),\(playerCol),\(dir)") { return }
        if walls.contains("\(nr),\(nc),\(opp)") { return }
        playerRow = nr; playerCol = nc; steps += 1
        if playerRow == size - 1 && playerCol == size - 1 {
            if best == nil || steps < best! { best = steps }
            withAnimation { solved = true }
        }
    }

    private func newMaze() {
        // Generate a simple random maze using recursive backtracking
        var visited = Array(repeating: Array(repeating: false, count: size), count: size)
        var wallSet = Set<String>()

        // Add all border and interior walls
        for r in 0..<size { for c in 0..<size {
            if r == 0 { wallSet.insert("\(r),\(c),U") }
            if r == size-1 { wallSet.insert("\(r),\(c),D") }
            if c == 0 { wallSet.insert("\(r),\(c),L") }
            if c == size-1 { wallSet.insert("\(r),\(c),R") }
        }}

        func carve(r: Int, c: Int) {
            visited[r][c] = true
            let dirs = [(-1,0,"U","D"),(1,0,"D","U"),(0,-1,"L","R"),(0,1,"R","L")].shuffled()
            for (dr, dc, d, od) in dirs {
                let nr = r + dr; let nc = c + dc
                guard nr >= 0 && nr < size && nc >= 0 && nc < size && !visited[nr][nc] else { continue }
                // Remove walls between (r,c) and (nr,nc)
                wallSet.remove("\(r),\(c),\(d)")
                wallSet.remove("\(nr),\(nc),\(od)")
                carve(r: nr, c: nc)
            }
        }

        // Add interior walls (all passages blocked initially)
        for r in 0..<size { for c in 0..<size {
            if r > 0 { wallSet.insert("\(r),\(c),U"); wallSet.insert("\(r-1),\(c),D") }
            if c > 0 { wallSet.insert("\(r),\(c),L"); wallSet.insert("\(r),\(c-1),R") }
        }}

        carve(r: 0, c: 0)

        walls = wallSet; playerRow = 0; playerCol = 0; steps = 0; solved = false
    }
}

#Preview { MazeRunView() }
