import SwiftUI

// A scale has weights on the left. Pick the right weight for the right side to balance.
struct BalanceScaleView: View {
    @State private var leftWeights: [Int] = []
    @State private var leftTotal = 0
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var tilt: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            hud
            Spacer()
            if gameOver { gameOverView } else { gameplayView }
            Spacer()
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

    private var gameplayView: some View {
        VStack(spacing: 24) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓ Balanced!" : "✗ That's \(leftTotal == 0 ? "" : "\(leftTotal) kg")").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            scaleView

            VStack(spacing: 8) {
                Text("Left pan: \(leftTotal) kg")
                    .font(.headline).foregroundStyle(.secondary)
                Text("What balances the right side?")
                    .font(.subheadline).foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { w in
                    Button { guess(w) } label: {
                        Text("\(w) kg").font(.title2.bold())
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var scaleView: some View {
        ZStack {
            // Fulcrum
            Triangle()
                .fill(Color(.systemGray3))
                .frame(width: 30, height: 24)
                .offset(y: 50)

            // Beam
            Rectangle()
                .fill(Color(.systemGray2))
                .frame(width: 200, height: 6)
                .rotationEffect(.degrees(tilt))
                .animation(.spring(duration: 0.4), value: tilt)

            // Left pan
            VStack(spacing: 4) {
                Rectangle().fill(Color(.systemGray2)).frame(width: 60, height: 4)
                ForEach(leftWeights, id: \.self) { w in
                    Text("\(w)kg").font(.caption.bold())
                        .frame(width: 44, height: 22)
                        .background(Color.blue.opacity(0.25), in: RoundedRectangle(cornerRadius: 6))
                }
            }
            .offset(x: -90, y: CGFloat(tilt) * 1.8 + 18)
            .animation(.spring(duration: 0.4), value: tilt)

            // Right pan (balanced = shows ?)
            VStack(spacing: 4) {
                Rectangle().fill(Color(.systemGray2)).frame(width: 60, height: 4)
                Text("?").font(.title2.bold()).foregroundStyle(.orange)
                    .frame(width: 44, height: 30)
                    .background(Color.orange.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
            }
            .offset(x: 90, y: -CGFloat(tilt) * 1.8 + 18)
            .animation(.spring(duration: 0.4), value: tilt)
        }
        .frame(height: 110)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ w: Int) {
        let ok = w == leftTotal
        withAnimation { feedback = ok; tilt = ok ? 0 : (Double(w) > Double(leftTotal) ? -8 : 8) }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run { withAnimation { feedback = nil; tilt = -4 }; nextQuestion() }
        }
    }

    private func nextQuestion() {
        let weights = (1...3).map { _ in Int.random(in: 1...9) }
        leftWeights = weights; leftTotal = weights.reduce(0, +)
        var pool: Set<Int> = [leftTotal]
        while pool.count < 4 { pool.insert(Int.random(in: max(1, leftTotal-8)...leftTotal+8)) }
        choices = pool.shuffled()
        withAnimation(.spring(duration: 0.4)) { tilt = -4 }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil; tilt = -4
        nextQuestion()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

#Preview { BalanceScaleView() }
