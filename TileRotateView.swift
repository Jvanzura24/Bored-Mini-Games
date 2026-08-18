import SwiftUI

// Rotate tiles (arrows) so they all point the same direction.
struct TileRotateView: View {
    private let size = 4

    @State private var rotations: [Double] = []  // multiples of 90
    @State private var moves = 0
    @State private var solved = false
    @State private var best: Int? = nil
    @State private var round = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Taps: \(moves)").font(.headline)
                Spacer()
                Text("Round \(round)").font(.headline)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 24).padding(.top, 8)

            if solved {
                solvedView
            } else {
                Text("Tap to rotate arrows. Align them all the same way.")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                boardView
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
        .onAppear { newPuzzle() }
    }

    private var boardView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: size), spacing: 10) {
            ForEach(0..<(size * size), id: \.self) { i in
                Button {
                    rotateTile(i)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.blue)
                            .rotationEffect(.degrees(rotations.indices.contains(i) ? rotations[i] : 0))
                            .animation(.spring(duration: 0.2), value: rotations.indices.contains(i) ? rotations[i] : 0)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Aligned! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("\(moves) taps").font(.title2).foregroundStyle(.secondary)
            Button("New Puzzle") { newPuzzle() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func rotateTile(_ i: Int) {
        guard !solved else { return }
        rotations[i] = (rotations[i] + 90).truncatingRemainder(dividingBy: 360)
        moves += 1
        checkSolved()
    }

    private func checkSolved() {
        guard !rotations.isEmpty else { return }
        let first = rotations[0]
        if rotations.allSatisfy({ $0 == first }) {
            if best == nil || moves < best! { best = moves }
            withAnimation { solved = true }
        }
    }

    private func newPuzzle() {
        round += 1
        let angles: [Double] = [0, 90, 180, 270]
        rotations = (0..<(size * size)).map { _ in angles.randomElement()! }
        // Ensure not already solved
        let first = rotations[0]
        if rotations.allSatisfy({ $0 == first }) { rotations[1] = (first + 90).truncatingRemainder(dividingBy: 360) }
        moves = 0; solved = false
    }
}

#Preview { TileRotateView() }
