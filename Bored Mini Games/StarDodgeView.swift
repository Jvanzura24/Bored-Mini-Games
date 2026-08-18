import SwiftUI

struct StarDodgeView: View {
    private struct Obstacle: Identifiable {
        let id = UUID()
        var x: CGFloat  // 0–1 fraction of width
        var y: CGFloat  // 0–1 fraction of height
        let speed: Double
        let size: CGFloat
    }

    @State private var obstacles: [Obstacle] = []
    @State private var shipX: CGFloat = 0.5
    @State private var score = 0
    @State private var gameOver = false
    @State private var gameTask: Task<Void, Never>? = nil
    @State private var spawnTask: Task<Void, Never>? = nil
    @State private var scoreTask: Task<Void, Never>? = nil
    @State private var frameWidth: CGFloat = 390

    private let shipSize: CGFloat = 36

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                if gameOver {
                    gameOverView
                } else {
                    gameContent(geo: geo)
                }
            }
            .onAppear {
                frameWidth = geo.size.width
                startGame(size: geo.size)
            }
            .onDisappear { stopTasks() }
        }
    }

    private func gameContent(geo: GeometryProxy) -> some View {
        ZStack {
            ForEach(obstacles) { obs in
                Image(systemName: "star.fill")
                    .font(.system(size: obs.size))
                    .foregroundStyle(.yellow)
                    .position(x: obs.x * geo.size.width, y: obs.y * geo.size.height)
            }

            Image(systemName: "arrowtriangle.up.fill")
                .font(.system(size: shipSize))
                .foregroundStyle(.cyan)
                .position(x: shipX * geo.size.width, y: geo.size.height - 80)

            VStack {
                HStack {
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(10)
                    Spacer()
                }
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { val in
                    shipX = max(0.06, min(0.94, val.location.x / geo.size.width))
                }
        )
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("GAME OVER")
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .foregroundStyle(.white)
            Text("Score: \(score)").font(.title2).foregroundStyle(.gray)
            Button("Play Again") { startGame(size: CGSize(width: frameWidth, height: 700)) }
                .buttonStyle(.borderedProminent)
                .font(.headline)
        }
    }

    private func startGame(size: CGSize) {
        obstacles = []; score = 0; gameOver = false; shipX = 0.5
        stopTasks()

        gameTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(16))
                guard !Task.isCancelled else { return }
                await MainActor.run { update(size: size) }
            }
        }

        spawnTask = Task {
            var interval = 1200
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(interval))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if !gameOver {
                        obstacles.append(Obstacle(
                            x: CGFloat.random(in: 0.05...0.95),
                            y: 0.0,
                            speed: Double.random(in: 0.003...0.006) + Double(score) * 0.00005,
                            size: CGFloat.random(in: 18...32)
                        ))
                    }
                }
                interval = max(600, interval - 20)
            }
        }

        scoreTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { if !gameOver { score += 1 } }
            }
        }
    }

    private func update(size: CGSize) {
        guard !gameOver else { return }
        let shipFX = shipX
        let shipFY = CGFloat(0.88)
        let shipR = (shipSize / 2) / size.width

        for i in obstacles.indices.reversed() {
            obstacles[i].y += obstacles[i].speed

            let dx = abs(obstacles[i].x - shipFX)
            let dy = abs(obstacles[i].y - shipFY)
            let hitR = (obstacles[i].size / 2) / size.width
            if dx < shipR + hitR && dy < (shipR + hitR) * (size.width / size.height) {
                withAnimation { gameOver = true }
                stopTasks()
                return
            }

            if obstacles[i].y > 1.1 {
                obstacles.remove(at: i)
            }
        }
    }

    private func stopTasks() {
        gameTask?.cancel(); spawnTask?.cancel(); scoreTask?.cancel()
    }
}

#Preview { StarDodgeView() }
