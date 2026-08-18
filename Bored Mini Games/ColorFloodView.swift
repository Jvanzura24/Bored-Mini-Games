//
//  ColorFloodView.swift
//  Bored Mini Games
//

import SwiftUI

private let kGridSize = 8
private let kMaxMoves = 22
private let kFloodColors: [Color] = [
    Color(red: 0.92, green: 0.26, blue: 0.26),
    Color(red: 0.22, green: 0.57, blue: 0.93),
    Color(red: 0.18, green: 0.76, blue: 0.40),
    Color(red: 0.97, green: 0.77, blue: 0.14),
    Color(red: 0.66, green: 0.24, blue: 0.92),
    Color(red: 0.95, green: 0.52, blue: 0.16),
]

struct ColorFloodView: View {
    @State private var grid: [[Int]] = []
    @State private var moves = 0
    @State private var won = false
    @State private var lost = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("\(moves) / \(kMaxMoves) moves", systemImage: "arrow.trianglehead.2.clockwise")
                    .font(.headline)
                Spacer()
                Button("New Game") { newGame() }.buttonStyle(.bordered)
            }
            .padding(.horizontal)

            GeometryReader { geo in
                let side = min(geo.size.width, geo.size.height)
                let cell = side / CGFloat(kGridSize)
                ZStack(alignment: .topLeading) {
                    ForEach(0..<kGridSize, id: \.self) { row in
                        ForEach(0..<kGridSize, id: \.self) { col in
                            if !grid.isEmpty {
                                kFloodColors[grid[row][col]]
                                    .frame(width: cell + 0.5, height: cell + 0.5)
                                    .offset(x: CGFloat(col) * cell, y: CGFloat(row) * cell)
                            }
                        }
                    }
                }
                .frame(width: side, height: side)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .frame(maxWidth: .infinity)
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(.horizontal)

            if won || lost {
                Text(won ? "Board flooded! 🎉" : "Out of moves!")
                    .font(.title3.bold())
                    .foregroundStyle(won ? .green : .red)
                    .transition(.opacity)
            }

            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { i in
                    Button {
                        floodFill(to: i)
                    } label: {
                        kFloodColors[i]
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                            .overlay {
                                if !grid.isEmpty && grid[0][0] == i {
                                    Circle().stroke(Color.white, lineWidth: 3)
                                }
                            }
                    }
                    .disabled(won || lost || grid.isEmpty || grid[0][0] == i)
                }
            }
            .padding(.bottom, 8)
        }
        .onAppear { newGame() }
    }

    private func newGame() {
        grid = (0..<kGridSize).map { _ in
            (0..<kGridSize).map { _ in Int.random(in: 0..<6) }
        }
        moves = 0
        won = false
        lost = false
    }

    private func floodFill(to newColor: Int) {
        guard !won && !lost && !grid.isEmpty else { return }
        let current = grid[0][0]
        guard current != newColor else { return }

        var visited = Array(repeating: Array(repeating: false, count: kGridSize), count: kGridSize)
        var queue = [(0, 0)]
        visited[0][0] = true
        var idx = 0
        while idx < queue.count {
            let (r, c) = queue[idx]; idx += 1
            for (dr, dc) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let nr = r + dr, nc = c + dc
                guard nr >= 0, nr < kGridSize, nc >= 0, nc < kGridSize,
                      !visited[nr][nc], grid[nr][nc] == current else { continue }
                visited[nr][nc] = true
                queue.append((nr, nc))
            }
        }

        for (r, c) in queue { grid[r][c] = newColor }
        moves += 1

        if grid.allSatisfy({ $0.allSatisfy { $0 == newColor } }) {
            withAnimation { won = true }
        } else if moves >= kMaxMoves {
            withAnimation { lost = true }
        }
    }
}

#Preview { ColorFloodView() }
