import SwiftUI

// A dot moves across the screen. Tap it before it disappears. Score points for accuracy.
struct ReflexCatchView: View {
    @State private var dotX: CGFloat = 0.5
    @State private var dotY: CGFloat = 0.5
    @State private var isVisible = false
    @State private var score = 0
    @State private var missed = 0
    @State private var gameOver = false
    @State private var showFlash: Bool = false
    @State private var flashColor: Color = .green
    @State private var spawnTask: Task<Void, Never>? = nil
    @State private var dotSize: CGFloat = 60
    @State private var round = 0

    private let maxMisses = 3

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear

                if isVisible {
                    Circle()
                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                        .frame(width: dotSize, height: dotSize)
                        .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 4)
                        .position(x: dotX * geo.size.width, y: dotY * geo.size.height)
                        .onTapGesture { tap(in: geo) }
                        .transition(.scale.combined(with: .opacity))
                }

                if showFlash {
                    flashColor.opacity(0.15)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                VStack {
                    HStack {
                        Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(0..<maxMisses, id: \.self) { i in
                                Image(systemName: i < maxMisses - missed ? "circle.fill" : "circle")
                                    .foregroundStyle(.red)
                            }
                        }
                        Spacer()
                        Text("Tap it!").font(.headline).foregroundStyle(.secondary)
                    }
                    .font(.headline).padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                if gameOver {
                    gameOverOverlay
                }
            }
        }
        .onAppear { startGame() }
        .onDisappear { spawnTask?.cancel() }
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                Button("Play Again") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func tap(in geo: GeometryProxy) {
        guard isVisible && !gameOver else { return }
        withAnimation(.spring()) { isVisible = false }
        score += 1
        round += 1
        dotSize = max(30, 60 - CGFloat(round) * 1.5)
        flash(.green)
    }

    private func flash(_ color: Color) {
        flashColor = color
        withAnimation { showFlash = true }
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            await MainActor.run { withAnimation { showFlash = false } }
        }
    }

    private func startGame() {
        score = 0; missed = 0; gameOver = false; isVisible = false; round = 0; dotSize = 60
        spawnTask?.cancel()
        spawnTask = Task {
            while !Task.isCancelled {
                let delay = max(0.6, 2.0 - Double(round) * 0.05)
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }

                // If dot still visible when next appears, count as miss
                if isVisible {
                    await MainActor.run {
                        withAnimation { isVisible = false }
                        missed += 1
                        flash(.red)
                        if missed >= maxMisses { gameOver = true; spawnTask?.cancel() }
                    }
                    if gameOver { return }
                    try? await Task.sleep(for: .milliseconds(300))
                }

                await MainActor.run {
                    dotX = CGFloat.random(in: 0.1...0.9)
                    dotY = CGFloat.random(in: 0.15...0.85)
                    withAnimation(.spring()) { isVisible = true }
                }

                let visibleTime = max(0.6, 2.0 - Double(round) * 0.04)
                try? await Task.sleep(for: .seconds(visibleTime))
                guard !Task.isCancelled else { return }

                if isVisible {
                    await MainActor.run {
                        withAnimation { isVisible = false }
                        missed += 1
                        flash(.red)
                        if missed >= maxMisses { gameOver = true }
                    }
                    if gameOver { return }
                }
            }
        }
    }
}

#Preview { ReflexCatchView() }
