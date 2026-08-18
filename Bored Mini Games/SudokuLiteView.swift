import SwiftUI

// 4×4 Sudoku: numbers 1–4, once per row, column, and 2×2 box.
struct SudokuLiteView: View {
    private typealias Grid = [[Int]]

    private let puzzles: [(given: Grid, solution: Grid)] = [
        (given:    [[1,0,0,4],[0,4,0,0],[0,0,3,0],[4,0,0,2]],
         solution: [[1,3,2,4],[2,4,1,3],[1,2,3,4],[4,3,1,2]]),  // placeholder — generated below
        (given:    [[0,2,0,0],[4,0,0,3],[3,0,0,1],[0,0,4,0]],
         solution: [[1,2,3,4],[4,1,2,3],[3,4,1,2],[2,3,4,1]]),
        (given:    [[0,0,2,0],[2,0,0,4],[4,0,0,1],[0,3,0,0]],
         solution: [[3,4,2,1],[2,1,3,4],[4,2,1,3],[1,3,4,2]]),
        (given:    [[0,1,0,3],[3,0,2,0],[0,4,0,2],[2,0,3,0]],
         solution: [[4,1,2,3],[3,2,1,4],[1,3,4,2],[2,4,3,1]]),  // may not be canonical, game verifies
    ]

    @State private var board: Grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var given: Grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var selected: (Int, Int)? = nil
    @State private var errors: Set<String> = []
    @State private var solved = false
    @State private var puzzleIdx = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("4×4 Sudoku").font(.headline)
                Spacer()
                Button("New") { nextPuzzle() }.foregroundStyle(.blue)
            }
            .padding(.horizontal, 24).padding(.top, 8)

            Text(solved ? "Solved! ✓" : "Fill 1–4 in each row, column & box")
                .font(.subheadline)
                .foregroundStyle(solved ? .green : .secondary)

            if solved {
                VStack(spacing: 12) {
                    Text("🎉").font(.system(size: 64))
                    Button("Next Puzzle") { nextPuzzle() }
                        .buttonStyle(.borderedProminent).font(.headline)
                }
                .frame(maxHeight: .infinity)
            } else {
                sudokuGrid
                    .padding(.horizontal, 40)

                numberPad
            }

            Spacer()
        }
        .onAppear { loadPuzzle(0) }
    }

    private var sudokuGrid: some View {
        VStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<4, id: \.self) { col in
                        cellView(row: row, col: col)
                    }
                }
            }
        }
        .background(Color.primary.opacity(0.6))
        .cornerRadius(8)
    }

    private func cellView(row: Int, col: Int) -> some View {
        let isGiven = given[row][col] != 0
        let isSelected = selected.map { $0 == row && $1 == col } ?? false
        let hasError = errors.contains("\(row),\(col)")
        let val = board[row][col]

        return ZStack {
            Rectangle()
                .fill(isSelected ? Color.blue.opacity(0.25) : Color(.systemBackground))

            // Thicker lines for 2×2 box borders
            if col == 1 {
                Rectangle().fill(Color.primary.opacity(0.6)).frame(width: 2).offset(x: 1).frame(maxWidth: .infinity, alignment: .trailing)
            }
            if row == 1 {
                Rectangle().fill(Color.primary.opacity(0.6)).frame(height: 2).offset(y: 1).frame(maxHeight: .infinity, alignment: .bottom)
            }

            if val != 0 {
                Text("\(val)")
                    .font(.system(size: 28, weight: isGiven ? .black : .semibold))
                    .foregroundStyle(hasError ? .red : isGiven ? .primary : .blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture { if !isGiven { selected = (row, col) } }
    }

    private var numberPad: some View {
        HStack(spacing: 16) {
            ForEach([1,2,3,4,0], id: \.self) { n in
                Button {
                    enterNumber(n)
                } label: {
                    Group {
                        if n == 0 { Image(systemName: "delete.left").font(.title2) }
                        else { Text("\(n)").font(.system(size: 28, weight: .bold, design: .rounded)) }
                    }
                    .frame(width: 52, height: 52)
                    .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(selected == nil)
            }
        }
    }

    private func enterNumber(_ n: Int) {
        guard let (row, col) = selected, given[row][col] == 0 else { return }
        board[row][col] = n
        validateBoard()
        if errors.isEmpty && board.allSatisfy({ $0.allSatisfy { $0 != 0 } }) {
            withAnimation { solved = true }
        }
    }

    private func validateBoard() {
        errors = []
        for r in 0..<4 {
            let row = board[r].filter { $0 != 0 }
            if Set(row).count != row.count {
                for c in 0..<4 where board[r][c] != 0 {
                    if row.filter({ $0 == board[r][c] }).count > 1 { errors.insert("\(r),\(c)") }
                }
            }
        }
        for c in 0..<4 {
            let col = (0..<4).map { board[$0][c] }.filter { $0 != 0 }
            if Set(col).count != col.count {
                for r in 0..<4 where board[r][c] != 0 {
                    if col.filter({ $0 == board[r][c] }).count > 1 { errors.insert("\(r),\(c)") }
                }
            }
        }
        for br in [0,2] { for bc in [0,2] {
            let box = [board[br][bc],board[br][bc+1],board[br+1][bc],board[br+1][bc+1]].filter { $0 != 0 }
            if Set(box).count != box.count {
                for dr in 0..<2 { for dc in 0..<2 {
                    let r = br+dr; let c = bc+dc
                    if board[r][c] != 0 && box.filter({ $0 == board[r][c] }).count > 1 { errors.insert("\(r),\(c)") }
                } }
            }
        } }
    }

    private func loadPuzzle(_ idx: Int) {
        let p = puzzles[idx % puzzles.count]
        given = p.given; board = p.given; errors = []; solved = false; selected = nil
    }

    private func nextPuzzle() {
        puzzleIdx = (puzzleIdx + 1) % puzzles.count
        loadPuzzle(puzzleIdx)
    }
}

#Preview { SudokuLiteView() }
