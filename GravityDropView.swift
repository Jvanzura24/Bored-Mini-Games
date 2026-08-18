import SwiftUI

// A ball falls from a random horizontal position. Tap to release a catcher at the right time.
struct GravityDropView: View {
    @State private var ballX: CGFloat = 0.5
    @State private var ballY: CGFloat = 0.0
    @State private var catcherX: CGFloat = 0.5
    @State private var score = 0
    @State private var misses = 0
    @State private var gameOver = false
    @State private var round = 0
    @State private var dropping = false
    @State private var caught = false
    @State private var dropTask: Task<Void, Never>? = nil
    @State private var catcherVisible = false

    private let catcherWidth: CGFloat = 0.25
    private let maxMisses = 3

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<maxMisses, id: \.self) { i in
                                Image(systemName: i < maxMisses - misses ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                        Text("Round \(round)").font(.headline)
                    }
                    .font(.headline).padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                // Ball
                if dropping || caught {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                        .frame(width: 30, height: 30)
                        .position(x: ballX * geo.size.width, y: ballY * geo.size.height)
                }

                // Catcher
                if catcherVisible {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        .frame(width: catcherWidth * geo.size.width, height: 16)
                        .position(x: catcherX * geo.size.width, y: geo.size.height * 0.82)
                }

                // Tap zone label
                if !gameOver && !dropping {
                    VStack {
                        Spacer()
                        Text("Tap to release catcher when ball is above it")
                            .font(.caption).foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 40)
                    }
                }

                // Tap catcher to catch
                if dropping {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { releaseCatcher(geo: geo) }
                }

                if gameOver {
                    gameOverOverlay
                }
            }
        }
        .onAppear { startRound() }
        .onDisappear { dropTask?.cancel() }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                Button("Play Again") { restart() }.buttonStyle(.borderedProminent).font(.headline)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func releaseCatcher(geo: GeometryProxy) {
        guard dropping else { return }
        catcherX = ballX
        catcherVisible = true

        // Check if ball is close to catcher height (within 15% of screen height)
        let catchWindow: CGFloat = 0.15
        let catcherY: CGFloat = 0.82
        if abs(ballY - catcherY) < catchWindow {
            // Caught!
            caught = true
            score += 1
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                await MainActor.run { catcherVisible = false; caught = false; startRound() }
            }
        } else {
            // Missed
            misses += 1
            if misses >= maxMisses {
                gameOver = true; dropTask?.cancel()
            } else {
                Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    await MainActor.run { catcherVisible = false; startRound() }
                }
            }
        }
        dropping = false
        dropTask?.cancel()
    }

    private func startRound() {
        round += 1
        ballX = CGFloat.random(in: 0.15...0.85)
        ballY = 0.05
        dropping = false; caught = false; catcherVisible = false

        dropTask?.cancel()
        dropTask = Task {
            // Short pause before drop
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { dropping = true }

            let steps = 80
            let speed = max(0.006, 0.015 - Double(round) * 0.0003)
            for _ in 0..<steps {
                try? await Task.sleep(for: .seconds(speed))
                guard !Task.isCancelled else { return }
                await MainActor.run { ballY += 1.0 / CGFloat(steps) }
            }
            // Ball fell without catch
            await MainActor.run {
                if dropping {
                    dropping = false; misses += 1
                    if misses >= maxMisses { gameOver = true } else { startRound() }
                }
            }
        }
    }

    private func restart() {
        score = 0; misses = 0; round = 0; gameOver = false
        startRound()
    }
}

#Preview { GravityDropView() }
