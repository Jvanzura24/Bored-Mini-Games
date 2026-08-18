//
//  SnakeView.swift
//  Bored Mini Games
//
//  Classic snake: swipe to steer, eat food to grow, avoid walls and
//  your own tail.
//

import SwiftUI

struct SnakeView: View {
    private struct GridPoint: Equatable, Hashable {
        var x: Int
        var y: Int
    }

    private enum Direction {
        case up, down, left, right

        var opposite: Direction {
            switch self {
            case .up: .down
            case .down: .up
            case .left: .right
            case .right: .left
            }
        }

        var delta: (x: Int, y: Int) {
            switch self {
            case .up: (0, -1)
            case .down: (0, 1)
            case .left: (-1, 0)
            case .right: (1, 0)
            }
        }
    }

    private let columns = 15
    private let rows = 20

    @State private var snake: [GridPoint] = []
    @State private var direction: Direction = .up
    @State private var pendingDirection: Direction = .up
    @State private var food = GridPoint(x: 3, y: 3)
    @State private var score = 0
    @State private var highScore = 0
    @State private var isRunning = false
    @State private var isGameOver = false
    @AppStorage("difficulty.snake") private var difficulty: Difficulty = .medium

    var body: some View {
        VStack(spacing: 12) {
            DifficultyPicker(difficulty: $difficulty)

            HStack {
                Text("Score: \(score)")
                Spacer()
                Text("Best: \(highScore)")
            }
            .font(.headline.monospacedDigit())
            .padding(.horizontal)

            GeometryReader { geo in
                let cell = min(geo.size.width / CGFloat(columns), geo.size.height / CGFloat(rows))
                let boardWidth = cell * CGFloat(columns)
                let boardHeight = cell * CGFloat(rows)

                ZStack {
                    Canvas { context, _ in
                        // Board background
                        context.fill(Path(CGRect(x: 0, y: 0, width: boardWidth, height: boardHeight)),
                                     with: .color(Color(red: 0.08, green: 0.12, blue: 0.08)))
                        // Food
                        context.fill(Path(ellipseIn: rect(for: food, cell: cell).insetBy(dx: 2, dy: 2)),
                                     with: .color(.red))
                        // Snake
                        for (index, segment) in snake.enumerated() {
                            let color: Color = index == 0 ? .green : .green.opacity(0.75)
                            context.fill(Path(roundedRect: rect(for: segment, cell: cell).insetBy(dx: 1, dy: 1),
                                              cornerRadius: 3),
                                         with: .color(color))
                        }
                    }
                    .frame(width: boardWidth, height: boardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    if !isRunning {
                        VStack(spacing: 12) {
                            Text(isGameOver ? "Game Over" : "Snake")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            Text(isGameOver ? "Score: \(score)" : "Swipe to steer")
                                .foregroundStyle(.white.opacity(0.8))
                            Button(isGameOver ? "Play Again" : "Start") { startGame() }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding(24)
                        .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 15)
                    .onEnded { value in
                        steer(translation: value.translation)
                    }
            )
            .task {
                // Game tick loop; ends automatically when the view goes away.
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(difficulty.snakeTickMilliseconds))
                    tick()
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func rect(for point: GridPoint, cell: CGFloat) -> CGRect {
        CGRect(x: CGFloat(point.x) * cell, y: CGFloat(point.y) * cell, width: cell, height: cell)
    }

    private func startGame() {
        let startX = columns / 2
        let startY = rows / 2
        snake = [GridPoint(x: startX, y: startY),
                 GridPoint(x: startX, y: startY + 1),
                 GridPoint(x: startX, y: startY + 2)]
        direction = .up
        pendingDirection = .up
        score = 0
        isGameOver = false
        spawnFood()
        isRunning = true
    }

    private func steer(translation: CGSize) {
        let newDirection: Direction
        if abs(translation.width) > abs(translation.height) {
            newDirection = translation.width > 0 ? .right : .left
        } else {
            newDirection = translation.height > 0 ? .down : .up
        }
        // Can't reverse directly into yourself
        if newDirection != direction.opposite {
            pendingDirection = newDirection
        }
    }

    private func tick() {
        guard isRunning, let head = snake.first else { return }

        direction = pendingDirection
        let next = GridPoint(x: head.x + direction.delta.x, y: head.y + direction.delta.y)

        // Wall or self collision (tail tip is safe because it moves away,
        // unless we just ate and are growing)
        let bodyToCheck = next == food ? snake : Array(snake.dropLast())
        if next.x < 0 || next.x >= columns || next.y < 0 || next.y >= rows
            || bodyToCheck.contains(next) {
            isRunning = false
            isGameOver = true
            highScore = max(highScore, score)
            return
        }

        snake.insert(next, at: 0)
        if next == food {
            score += 1
            spawnFood()
        } else {
            snake.removeLast()
        }
    }

    private func spawnFood() {
        var open: [GridPoint] = []
        for x in 0..<columns {
            for y in 0..<rows {
                let point = GridPoint(x: x, y: y)
                if !snake.contains(point) {
                    open.append(point)
                }
            }
        }
        if let spot = open.randomElement() {
            food = spot
        }
    }
}

private extension Difficulty {
    /// Milliseconds between snake moves — lower means a faster snake.
    var snakeTickMilliseconds: Int {
        switch self {
        case .easy: 200
        case .medium: 160
        case .hard: 110
        }
    }
}

#Preview {
    SnakeView()
}
