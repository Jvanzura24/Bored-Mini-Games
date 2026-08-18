import SwiftUI

// Two numbers appear. Tap < or > to indicate which side is greater. 60s, 3 lives.
struct GreaterLessView: View {
    @State private var leftNum = 0
    @State private var rightNum = 0
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 24) {
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
        VStack(spacing: 32) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            HStack(spacing: 0) {
                Text("\(leftNum)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
                Text("?")
                    .font(.system(size: 40, weight: .black))
                    .foregroundStyle(.secondary)
                    .frame(width: 40)
                Text("\(rightNum)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 24) {
                Button {
                    answer(leftGreater: true)
                } label: {
                    VStack(spacing: 4) {
                        Text("◀").font(.system(size: 28))
                        Text("Left is\ngreater").font(.headline).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Button {
                    answer(leftGreater: false)
                } label: {
                    VStack(spacing: 4) {
                        Text("▶").font(.system(size: 28))
                        Text("Right is\ngreater").font(.headline).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 32)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func answer(leftGreater: Bool) {
        let correct: Bool
        if leftNum == rightNum {
            correct = false // ties are always wrong — both are equal, neither is greater
        } else {
            correct = leftGreater == (leftNum > rightNum)
        }
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        leftNum = Int.random(in: 1...999)
        rightNum = Int.random(in: 1...999)
        // Occasionally make them visually tricky (close together)
        if Bool.random() {
            let base = Int.random(in: 1...100)
            leftNum = base + Int.random(in: 0...5)
            rightNum = base + Int.random(in: 0...5)
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        next()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { GreaterLessView() }
