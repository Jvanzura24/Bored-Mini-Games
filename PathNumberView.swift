import SwiftUI

// Connect numbered dots in order on a 4x4 grid, like a number maze.
struct PathNumberView: View {
    private let gridSize = 4

    @State private var numbers: [[Int]] = []
    @State private var nextTarget = 1
    @State private var maxNumber = 0
    @State private var tapped: Set<Int> = []
    @State private var score = 0
    @State private var round = 0
    @State private var solved = false
    @State private var best: Int? = nil
    @State private var moves = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                Text("Next: \(nextTarget)").font(.headline).foregroundStyle(.blue)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            if solved {
                solvedView
            } else {
                Text("Tap numbers 1 → \(maxNumber) in order")
                    .font(.subheadline).foregroundStyle(.secondary)
                boardView
                    .padding(.horizontal, 16)
            }

            Spacer()
        }
        .onAppear { newPuzzle() }
    }

    private var boardView: some View {
        VStack(spacing: 10) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let idx = row * gridSize + col
                        let num = numbers.indices.contains(row) && numbers[row].indices.contains(col) ? numbers[row][col] : 0
                        let wasTapped = tapped.contains(idx)
                        let isNext = num == nextTarget

                        Button {
                            tapCell(row: row, col: col)
                        } label: {
                            Text("\(num)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .background(
                                    wasTapped ? Color.green :
                                    isNext ? Color.blue.opacity(0.25) : Color(.systemGray5),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                                .foregroundStyle(wasTapped ? .white : isNext ? .blue : .primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isNext ? Color.blue : .clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(wasTapped)
                    }
                }
            }
        }
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Done! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("Puzzle \(round)").font(.title2).foregroundStyle(.secondary)
            if let b = best { Text("Best rounds: \(b) pts").font(.headline).foregroundStyle(.blue) }
            Button("Next Puzzle") { newPuzzle() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func tapCell(row: Int, col: Int) {
        guard !solved else { return }
        let num = numbers[row][col]
        guard num == nextTarget else { return }
        let idx = row * gridSize + col
        withAnimation { _ = tapped.insert(idx) }
        nextTarget += 1
        if nextTarget > maxNumber {
            score += 1
            if best == nil || score > best! { best = score }
            withAnimation { solved = true }
        }
    }

    private func newPuzzle() {
        round += 1
        let total = gridSize * gridSize
        let flat = Array(1...total).shuffled()
        numbers = stride(from: 0, to: total, by: gridSize).map { start in
            Array(flat[start..<min(start + gridSize, total)])
        }
        maxNumber = total
        nextTarget = 1
        tapped = []
        solved = false
    }
}

#Preview { PathNumberView() }
