import SwiftUI

struct BrickBreakView: View {
    private struct Brick: Identifiable {
        let id = UUID(); var col: Int; var row: Int; var alive = true
        let color: Color
    }

    @State private var bricks: [Brick] = []
    @State private var ballX: CGFloat = 0.5
    @State private var ballY: CGFloat = 0.75
    @State private var vx: CGFloat = 0.004
    @State private var vy: CGFloat = -0.006
    @State private var paddleX: CGFloat = 0.5
    @State private var score = 0
    @State private var lives = 3
    @State private var gameOver = false
    @State private var won = false
    @State private var gameTask: Task<Void, Never>? = nil

    private let brickCols = 7
    private let brickRows = 5
    private let ballR: CGFloat = 0.018
    private let paddleW: CGFloat = 0.22
    private let paddleH: CGFloat = 0.022
    private let paddleY: CGFloat = 0.88

    private let rowColors: [Color] = [.red, .orange, .yellow, .green, .blue]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                if gameOver || won {
                    endView(geo: geo)
                } else {
                    gameView(geo: geo)
                }
            }
            .onAppear { startGame(size: geo.size) }
            .onDisappear { gameTask?.cancel() }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { v in paddleX = max(paddleW/2, min(1 - paddleW/2, v.location.x / geo.size.width)) })
        }
    }

    private func gameView(geo: GeometryProxy) -> some View {
        ZStack {
            ForEach(bricks) { brick in
                if brick.alive {
                    let bw = 1.0 / CGFloat(brickCols)
                    let bh = 0.13 / CGFloat(brickRows)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(brick.color)
                        .frame(width: bw * geo.size.width - 4, height: bh * geo.size.height - 4)
                        .position(
                            x: (CGFloat(brick.col) + 0.5) * bw * geo.size.width,
                            y: (0.08 + (CGFloat(brick.row) + 0.5) * bh) * geo.size.height
                        )
                }
            }

            Circle()
                .fill(Color.white)
                .frame(width: ballR * 2 * geo.size.width, height: ballR * 2 * geo.size.width)
                .position(x: ballX * geo.size.width, y: ballY * geo.size.height)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.cyan)
                .frame(width: paddleW * geo.size.width, height: paddleH * geo.size.height)
                .position(x: paddleX * geo.size.width, y: paddleY * geo.size.height)

            VStack {
                HStack {
                    Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .foregroundStyle(.red).font(.caption)
                        }
                    }
                }
                .font(.headline).padding(.horizontal, 20).padding(.top, 4)
                Spacer()
            }
        }
    }

    private func endView(geo: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Text(won ? "You Win! 🎉" : "Game Over")
                .font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
            Text("Score: \(score)").font(.title2).foregroundStyle(.gray)
            Button("Play Again") { startGame(size: geo.size) }
                .buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func startGame(size: CGSize) {
        bricks = (0..<brickRows).flatMap { row in
            (0..<brickCols).map { col in
                Brick(col: col, row: row, color: rowColors[row])
            }
        }
        ballX = 0.5; ballY = 0.75; vx = 0.004; vy = -0.007
        paddleX = 0.5; score = 0; lives = 3; gameOver = false; won = false
        gameTask?.cancel()
        gameTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(16))
                guard !Task.isCancelled else { return }
                await MainActor.run { update(size: size) }
            }
        }
    }

    private func update(size: CGSize) {
        guard !gameOver && !won else { return }
        ballX += vx; ballY += vy

        if ballX < ballR { ballX = ballR; vx = abs(vx) }
        if ballX > 1 - ballR { ballX = 1 - ballR; vx = -abs(vx) }
        if ballY < ballR { ballY = ballR; vy = abs(vy) }

        // Paddle collision
        let nearPaddle = abs(ballY - paddleY) < (ballR + paddleH / 2)
        let inPaddleX = abs(ballX - paddleX) < (paddleW / 2 + ballR)
        if nearPaddle && inPaddleX && vy > 0 {
            vy = -abs(vy)
            let offset = (ballX - paddleX) / (paddleW / 2)
            vx = offset * 0.007
        }

        // Ball fell below paddle
        if ballY > 1 + ballR {
            lives -= 1
            if lives <= 0 { withAnimation { gameOver = true }; gameTask?.cancel(); return }
            ballX = paddleX; ballY = paddleY - 0.05; vy = -0.007
        }

        // Brick collisions
        let bw = 1.0 / CGFloat(brickCols)
        let bh = 0.13 / CGFloat(brickRows)
        for i in bricks.indices {
            guard bricks[i].alive else { continue }
            let bx = (CGFloat(bricks[i].col) + 0.5) * bw
            let by = 0.08 + (CGFloat(bricks[i].row) + 0.5) * bh
            let dx = abs(ballX - bx); let dy = abs(ballY - by)
            if dx < bw / 2 + ballR && dy < bh / 2 + ballR {
                bricks[i].alive = false; score += 1
                if dy < bh / 2 { vx = -vx } else { vy = -vy }
            }
        }
        if bricks.allSatisfy({ !$0.alive }) { withAnimation { won = true }; gameTask?.cancel() }
    }
}

#Preview { BrickBreakView() }
