import SwiftUI

// Drag numbers into sorted order (ascending). Tap-to-swap mechanic.
struct NumberSortView: View {
    @State private var numbers: [Int] = []
    @State private var selected: Int? = nil
    @State private var moves = 0
    @State private var score = 0
    @State private var round = 0
    @State private var solved = false
    @State private var best: Int? = nil

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                Text("Swaps: \(moves)").font(.headline)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            if solved {
                solvedView
            } else {
                Text("Tap two numbers to swap them. Sort ascending →")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                tilesView
                    .padding(.horizontal, 16)
            }

            Spacer()
        }
        .onAppear { newPuzzle() }
    }

    private var tilesView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(Array(numbers.enumerated()), id: \.offset) { i, n in
                Button { tapTile(i) } label: {
                    Text("\(n)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                            selected == i ? Color.blue : (isSorted(i) ? Color.green.opacity(0.3) : Color(.systemGray5)),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                        .foregroundStyle(selected == i ? .white : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selected == i ? Color.blue : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Sorted! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("Done in \(moves) swaps").font(.title2).foregroundStyle(.secondary)
            Button("New Puzzle") { newPuzzle() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func isSorted(_ i: Int) -> Bool {
        let sorted = numbers.sorted()
        return numbers[i] == sorted[i]
    }

    private func tapTile(_ i: Int) {
        guard !solved else { return }
        if let sel = selected {
            if sel == i { selected = nil; return }
            withAnimation {
                numbers.swapAt(sel, i)
                moves += 1
                selected = nil
            }
            if numbers == numbers.sorted() {
                score += max(1, 10 - moves)
                if best == nil || moves < best! { best = moves }
                withAnimation { solved = true }
            }
        } else {
            selected = i
        }
    }

    private func newPuzzle() {
        round += 1
        var nums = (1...16).map { _ in Int.random(in: 1...99) }
        while nums == nums.sorted() { nums.shuffle() }
        numbers = nums
        moves = 0; selected = nil; solved = false
    }
}

#Preview { NumberSortView() }
