import SwiftUI

struct TowerHanoiView: View {
    private let discCount = 4
    @State private var pegs: [[Int]] = [] // disc sizes (larger = bigger)
    @State private var selected: Int? = nil // selected peg index
    @State private var moves = 0
    @State private var solved = false
    @State private var best: Int? = nil
    @State private var minMoves: Int = 15 // 2^4 - 1

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Moves: \(moves)").font(.headline)
                Spacer()
                Text("Min: \(minMoves)").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 24).padding(.top, 8)

            Text(solved ? "Solved! ✓" : selected != nil ? "Tap dest peg" : "Tap a peg to move")
                .font(.headline)
                .foregroundStyle(solved ? .green : selected != nil ? .blue : .secondary)

            if solved {
                VStack(spacing: 16) {
                    Text("\(moves) moves").font(.title2).foregroundStyle(.secondary)
                    Button("New Game") { reset() }.buttonStyle(.borderedProminent).font(.headline)
                }
            } else {
                pegsView
                    .padding(.horizontal, 16)
                Button("Reset") { reset() }.foregroundStyle(.secondary).font(.subheadline)
            }

            Spacer()
        }
        .onAppear { reset() }
    }

    private var pegsView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(0..<3, id: \.self) { peg in
                pegView(peg: peg)
            }
        }
        .frame(height: 260)
    }

    private func pegView(peg: Int) -> some View {
        let isSelected = selected == peg
        return VStack(spacing: 0) {
            Spacer()
            ZStack(alignment: .bottom) {
                // Peg rod
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(width: 6, height: 220)

                VStack(spacing: 3) {
                    ForEach(pegs[peg].reversed(), id: \.self) { size in
                        discView(size: size)
                    }
                }
                .padding(.bottom, 4)
            }

            // Base
            Rectangle()
                .fill(isSelected ? Color.blue : Color(.systemGray3))
                .frame(height: 8)
                .cornerRadius(4)
        }
        .onTapGesture { tapPeg(peg) }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : .clear, lineWidth: 2)
                .padding(-4)
        )
    }

    private func discView(size: Int) -> some View {
        let colors: [Color] = [.red, .orange, .yellow, .green]
        let w = CGFloat(40 + size * 18)
        return RoundedRectangle(cornerRadius: 5)
            .fill(colors[(size - 1) % colors.count])
            .frame(width: w, height: 24)
    }

    private func tapPeg(_ peg: Int) {
        guard !solved else { return }
        if let src = selected {
            if src == peg {
                selected = nil; return
            }
            // Try to move top disc from src to peg
            if let disc = pegs[src].last {
                if pegs[peg].last == nil || pegs[peg].last! > disc {
                    pegs[src].removeLast()
                    pegs[peg].append(disc)
                    moves += 1
                    selected = nil
                    if pegs[2].count == discCount {
                        if best == nil || moves < best! { best = moves }
                        withAnimation { solved = true }
                    }
                    return
                }
            }
            selected = nil
        } else {
            if !pegs[peg].isEmpty { selected = peg }
        }
    }

    private func reset() {
        pegs = [Array(1...discCount).reversed(), [], []]
        moves = 0; solved = false; selected = nil
        minMoves = Int(pow(2.0, Double(discCount))) - 1
    }
}

#Preview { TowerHanoiView() }
