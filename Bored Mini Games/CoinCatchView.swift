import SwiftUI

struct CoinCatchView: View {
    private struct Coin: Identifiable {
        let id = UUID()
        var x: CGFloat  // 0–1 fraction
        var y: CGFloat  // 0–1 fraction
        let speed: Double
    }

    @State private var coins: [Coin] = []
    @State private var basketX: CGFloat = 0.5
    @State private var score = 0
    @State private var lives = 5
    @State private var gameOver = false
    @State private var gameTask: Task<Void, Never>? = nil
    @State private var spawnTask: Task<Void, Never>? = nil

    private let basketFraction: CGFloat = 0.115  // basket half-width as fraction of screen width
    private let catchY: Double = 0.84

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red:0.1,green:0.1,blue:0.25), Color(red:0.05,green:0.05,blue:0.15)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if gameOver {
                    gameOverView
                } else {
                    gameContent(geo: geo)
                }
            }
            .onAppear { startGame(size: geo.size) }
            .onDisappear { stopTasks() }
        }
    }

    private func gameContent(geo: GeometryProxy) -> some View {
        ZStack {
            ForEach(coins) { coin in
                Text("🪙")
                    .font(.system(size: 30))
                    .position(x: coin.x * geo.size.width, y: coin.y * geo.size.height)
            }

            // Basket
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.7, green: 0.45, blue: 0.15))
                    .frame(width: basketFraction * 2 * geo.size.width, height: 18)
            }
            .position(x: basketX * geo.size.width, y: CGFloat(catchY) * geo.size.height + 9)

            VStack {
                HStack {
                    Label("\(score)", systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.title2.bold())
                        .padding(10)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            Image(systemName: i < lives ? "heart.fill" : "heart")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                    .padding(10)
                }
                Spacer()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { v in
                    basketX = max(0.08, min(0.92, v.location.x / geo.size.width))
                }
        )
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text("Caught: \(score) coins").font(.title2).foregroundStyle(.gray)
            Button("Play Again") {
                Task { @MainActor in startGame(size: CGSize(width: 390, height: 700)) }
            }
            .buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func startGame(size: CGSize) {
        coins = []; score = 0; lives = 5; gameOver = false; basketX = 0.5
        stopTasks()

        gameTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(16))
                guard !Task.isCancelled else { return }
                await MainActor.run { update(size: size) }
            }
        }

        spawnTask = Task {
            var spawnInterval = 1400
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(spawnInterval))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if !gameOver {
                        coins.append(Coin(
                            x: CGFloat.random(in: 0.06...0.94),
                            y: 0.0,
                            speed: Double.random(in: 0.003...0.006)
                        ))
                    }
                }
                spawnInterval = max(700, spawnInterval - 15)
            }
        }
    }

    private func update(size: CGSize) {
        guard !gameOver else { return }
        for i in coins.indices.reversed() {
            coins[i].y += coins[i].speed

            let inX = abs(coins[i].x - basketX) < basketFraction
            let inY = coins[i].y > catchY - 0.03 && coins[i].y < catchY + 0.04
            if inX && inY {
                coins.remove(at: i); score += 1; continue
            }
            if coins[i].y > 1.05 {
                coins.remove(at: i)
                lives -= 1
                if lives <= 0 { withAnimation { gameOver = true }; stopTasks() }
            }
        }
    }

    private func stopTasks() { gameTask?.cancel(); spawnTask?.cancel() }
}

#Preview { CoinCatchView() }
