import SwiftUI

// Balloons drift upward with numbers. Tap them in ascending order.
struct BalloonPopOrderView: View {
    private struct Balloon: Identifiable {
        let id = UUID()
        let value: Int
        var x: CGFloat
        var y: CGFloat
        var popped = false
        var color: Color
    }

    private let balloonColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .cyan]

    @State private var balloons: [Balloon] = []
    @State private var nextExpected = 1
    @State private var count = 5
    @State private var score = 0
    @State private var round = 0
    @State private var mistakes = 0
    @State private var gameOver = false
    @State private var best: Int? = nil

    private let maxMistakes = 3

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Gradient sky background
                LinearGradient(
                    colors: [Color(red:0.53,green:0.81,blue:0.98), Color(red:0.85,green:0.95,blue:1.0)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // HUD
                VStack {
                    HStack {
                        Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<maxMistakes, id: \.self) { i in
                                Image(systemName: i < maxMistakes - mistakes ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                        Text("Tap: \(nextExpected)").font(.headline).foregroundStyle(.primary)
                    }
                    .font(.headline).padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                // Balloons
                ForEach(balloons) { balloon in
                    if !balloon.popped {
                        balloonView(balloon, geo: geo)
                    }
                }

                if gameOver {
                    gameOverOverlay(geo: geo)
                }
            }
        }
        .onAppear { newRound() }
    }

    private func balloonView(_ balloon: Balloon, geo: GeometryProxy) -> some View {
        Button { tap(balloon) } label: {
            ZStack {
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [balloon.color.opacity(0.9), balloon.color.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 72)
                    .shadow(color: balloon.color.opacity(0.4), radius: 4)
                Text("\(balloon.value)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .position(x: balloon.x * geo.size.width, y: balloon.y * geo.size.height)
    }

    private func gameOverOverlay(geo: GeometryProxy) -> some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                if let b = best { Text("Best: \(b)").font(.headline).foregroundStyle(.yellow) }
                Button("Play Again") { resetGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func tap(_ balloon: Balloon) {
        guard !gameOver else { return }
        if balloon.value == nextExpected {
            if let idx = balloons.firstIndex(where: { $0.id == balloon.id }) {
                withAnimation(.spring(duration: 0.2)) { balloons[idx].popped = true }
            }
            score += 1
            nextExpected += 1
            if nextExpected > count { newRound() }
        } else {
            mistakes += 1
            if mistakes >= maxMistakes { gameOver = true }
            if score > (best ?? -1) { best = score }
        }
    }

    private func newRound() {
        round += 1
        count = min(4 + round, 9)
        nextExpected = 1
        let values = Array(1...count).shuffled()
        balloons = values.enumerated().map { i, v in
            Balloon(
                value: v,
                x: CGFloat.random(in: 0.12...0.88),
                y: CGFloat.random(in: 0.18...0.85),
                color: balloonColors[i % balloonColors.count]
            )
        }
    }

    private func resetGame() {
        score = 0; round = 0; mistakes = 0; gameOver = false
        newRound()
    }
}

#Preview { BalloonPopOrderView() }
