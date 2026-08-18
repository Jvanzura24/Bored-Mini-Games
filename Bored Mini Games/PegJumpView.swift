//
//  PegJumpView.swift
//  Bored Mini Games
//
//  Triangle peg solitaire — 15 pegs arranged in 5 rows.
//  Select a peg, then tap the empty hole it should land in.
//

import SwiftUI

// MARK: – Helpers

private func pegIndex(_ row: Int, _ col: Int) -> Int { row * (row + 1) / 2 + col }
private func rowOf(_ idx: Int) -> Int {
    var r = 0; while pegIndex(r + 1, 0) <= idx { r += 1 }; return r
}
private func colOf(_ idx: Int) -> Int { idx - pegIndex(rowOf(idx), 0) }

// All valid (from, over, to) jump triplets
private let kJumps: [(Int, Int, Int)] = {
    var j = [(Int, Int, Int)]()
    for r in 0..<5 {
        for c in 0...r {
            if c + 2 <= r {
                j += [(pegIndex(r,c), pegIndex(r,c+1), pegIndex(r,c+2)),
                      (pegIndex(r,c+2), pegIndex(r,c+1), pegIndex(r,c))]
            }
            if r + 2 < 5 {
                j += [(pegIndex(r,c), pegIndex(r+1,c), pegIndex(r+2,c)),
                      (pegIndex(r+2,c), pegIndex(r+1,c), pegIndex(r,c)),
                      (pegIndex(r,c), pegIndex(r+1,c+1), pegIndex(r+2,c+2)),
                      (pegIndex(r+2,c+2), pegIndex(r+1,c+1), pegIndex(r,c))]
            }
        }
    }
    return j
}()

// MARK: – View

struct PegJumpView: View {
    @State private var pegs = Array(repeating: true, count: 15)
    @State private var selected: Int? = nil
    @State private var done = false
    @State private var statusMsg = ""

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Pegs left: \(pegs.filter { $0 }.count)")
                    .font(.headline)
                Spacer()
                Button("New Game") { newGame() }.buttonStyle(.bordered)
            }
            .padding(.horizontal)

            Text("Select a peg, then tap the empty hole to jump over an adjacent peg.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            GeometryReader { geo in
                let span = min(geo.size.width, geo.size.height)
                let spacing = span / 5.8
                let r = spacing * 0.38
                let topY: CGFloat = 24

                ZStack {
                    ForEach(0..<15, id: \.self) { idx in
                        let row = rowOf(idx)
                        let col = colOf(idx)
                        let cx = geo.size.width / 2
                            + CGFloat(col) * spacing
                            - CGFloat(row) * spacing / 2
                        let cy = topY + CGFloat(row) * spacing * 0.866

                        Circle()
                            .fill(fillColor(idx))
                            .frame(width: r * 2, height: r * 2)
                            .overlay(Circle().stroke(strokeColor(idx), lineWidth: 2))
                            .shadow(color: .black.opacity(0.10), radius: 3, y: 2)
                            .position(x: cx, y: cy)
                            .onTapGesture { tapped(idx) }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal)

            if !statusMsg.isEmpty {
                Text(statusMsg)
                    .font(.title3.bold())
                    .foregroundStyle(pegs.filter { $0 }.count == 1 ? .green : .orange)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .onAppear { newGame() }
    }

    // MARK: – Colors

    private func fillColor(_ idx: Int) -> Color {
        if !pegs[idx] { return Color.gray.opacity(0.18) }
        if idx == selected { return .blue }
        if let sel = selected, isLanding(from: sel, to: idx) { return Color.green.opacity(0.75) }
        return Color(red: 0.74, green: 0.44, blue: 0.15)
    }

    private func strokeColor(_ idx: Int) -> Color {
        if !pegs[idx] { return .gray.opacity(0.25) }
        if idx == selected { return .blue }
        if let sel = selected, isLanding(from: sel, to: idx) { return .green }
        return Color(red: 0.50, green: 0.28, blue: 0.06)
    }

    // MARK: – Logic

    private func isLanding(from: Int, to: Int) -> Bool {
        kJumps.contains { f, o, t in f == from && t == to && pegs[f] && pegs[o] && !pegs[t] }
    }

    private func tapped(_ idx: Int) {
        guard !done else { return }
        if pegs[idx] {
            selected = (selected == idx) ? nil : idx
        } else {
            guard let sel = selected, isLanding(from: sel, to: idx) else { return }
            guard let jump = kJumps.first(where: { $0.0 == sel && $0.2 == idx }) else { return }
            pegs[sel] = false
            pegs[jump.1] = false
            pegs[idx] = true
            selected = nil
            checkDone()
        }
    }

    private func checkDone() {
        let remaining = pegs.filter { $0 }.count
        let hasMoves = kJumps.contains { f, o, t in pegs[f] && pegs[o] && !pegs[t] }
        guard !hasMoves else { return }
        done = true
        withAnimation {
            statusMsg = remaining == 1
                ? "Perfect! One peg left! 🎉"
                : "No more moves — \(remaining) pegs left."
        }
    }

    private func newGame() {
        pegs = Array(repeating: true, count: 15)
        let startHole = [0, 4, 10, 14].randomElement()!
        pegs[startHole] = false
        selected = nil
        done = false
        statusMsg = ""
    }
}

#Preview { PegJumpView() }
