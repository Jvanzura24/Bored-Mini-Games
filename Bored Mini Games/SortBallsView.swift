import SwiftUI

// Colored items fall one at a time; tap the matching bin to sort them.
struct SortBallsView: View {
    private let binColors: [Color] = [.red, .blue, .green, .yellow]
    private let binNames = ["Red", "Blue", "Green", "Yellow"]

    @State private var current: Int = 0  // index into binColors
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var ballScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            hud
            Spacer()
            if gameOver {
                gameOverView
            } else {
                ball
                Spacer()
                bins
            }
        }
        .onAppear { reset() }
        .onDisappear { timerTask?.cancel() }
    }

    private var hud: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < lives ? "heart.fill" : "heart").foregroundStyle(.red)
                }
            }
            Spacer()
            Label(String(format: "%.0f", timeLeft), systemImage: "timer")
        }
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private var ball: some View {
        ZStack {
            Circle()
                .fill(binColors[current])
                .frame(width: 100, height: 100)
                .shadow(color: binColors[current].opacity(0.45), radius: 20)
                .scaleEffect(ballScale)
                .animation(.spring(duration: 0.3), value: ballScale)

            if let fb = feedback {
                Text(fb ? "✓" : "✗")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var bins: some View {
        HStack(spacing: 12) {
            ForEach(0..<binColors.count, id: \.self) { i in
                Button {
                    sort(into: i)
                } label: {
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(binColors[i].opacity(0.25))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(binColors[i], lineWidth: 3)
                            )
                            .frame(height: 80)
                        Text(binNames[i])
                            .font(.caption.bold())
                            .foregroundStyle(binColors[i])
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Sorted: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func sort(into bin: Int) {
        let correct = bin == current
        withAnimation {
            feedback = correct
            ballScale = correct ? 1.3 : 0.8
        }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            await MainActor.run {
                withAnimation {
                    feedback = nil
                    ballScale = 1.0
                    current = Int.random(in: 0..<binColors.count)
                }
            }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        ballScale = 1.0; current = Int.random(in: 0..<binColors.count)
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    timeLeft -= 1
                    if timeLeft <= 0 { gameOver = true }
                }
            }
        }
    }
}

#Preview { SortBallsView() }
