import SwiftUI

// Draw over tiles to paint them. Fill the board using the fewest strokes.
struct ColorTrailView: View {
    private let cols = 6
    private let rows = 8
    private let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink]

    @State private var grid: [Int] = [] // -1 = empty, 0-5 = color index
    @State private var currentColor = 0
    @State private var strokes = 0
    @State private var score = 0
    @State private var best: Int? = nil
    @State private var solved = false
    @State private var dragging = false

    var filledCount: Int { grid.filter { $0 >= 0 }.count }
    var totalCount: Int { cols * rows }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Strokes: \(strokes)").font(.headline)
                Spacer()
                Text("\(filledCount)/\(totalCount)").font(.headline).foregroundStyle(.secondary)
                Spacer()
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.secondary) }
            }
            .padding(.horizontal, 24).padding(.top, 8)

            if solved {
                solvedView
            } else {
                Text("Drag to paint. Tap the color palette to switch.")
                    .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)

                boardView
                    .padding(.horizontal, 12)

                colorPicker
            }

            Spacer()
        }
        .onAppear { reset() }
    }

    private var boardView: some View {
        GeometryReader { geo in
            let cellW = geo.size.width / CGFloat(cols)
            let cellH = min(cellW, geo.size.height / CGFloat(rows))

            ZStack(alignment: .topLeading) {
                ForEach(0..<rows, id: \.self) { row in
                    ForEach(0..<cols, id: \.self) { col in
                        let idx = row * cols + col
                        let colorIdx = grid.indices.contains(idx) ? grid[idx] : -1
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorIdx >= 0 ? colors[colorIdx] : Color(.systemGray5))
                            .frame(width: cellW - 4, height: cellH - 4)
                            .position(x: CGFloat(col) * cellW + cellW / 2,
                                      y: CGFloat(row) * cellH + cellH / 2)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let col = Int(value.location.x / cellW)
                        let row = Int(value.location.y / cellH)
                        guard col >= 0, col < cols, row >= 0, row < rows else { return }
                        let idx = row * cols + col
                        guard grid.indices.contains(idx) else { return }
                        if !dragging { dragging = true; strokes += 1 }
                        grid[idx] = currentColor
                        if filledCount == totalCount { withAnimation { solved = true } }
                    }
                    .onEnded { _ in dragging = false }
            )
        }
        .frame(height: CGFloat(rows) * 48)
    }

    private var colorPicker: some View {
        HStack(spacing: 12) {
            ForEach(colors.indices, id: \.self) { i in
                Button {
                    currentColor = i
                } label: {
                    Circle()
                        .fill(colors[i])
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle().stroke(.white, lineWidth: currentColor == i ? 3 : 0)
                        )
                        .shadow(color: colors[i].opacity(0.5), radius: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var solvedView: some View {
        VStack(spacing: 16) {
            Text("Board Filled! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("\(strokes) strokes").font(.title2).foregroundStyle(.secondary)
            Button("New Board") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func reset() {
        grid = Array(repeating: -1, count: cols * rows)
        strokes = 0; currentColor = 0; solved = false; dragging = false
    }
}

#Preview { ColorTrailView() }
