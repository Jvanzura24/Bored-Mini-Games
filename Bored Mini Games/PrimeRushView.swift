import SwiftUI

struct PrimeRushView: View {
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var current = 0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
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
                    Text(fb ? "Prime! ✓" : "Not prime ✗").foregroundStyle(fb ? .green : .red)
                } else {
                    Text(" ")
                }
            }
            .font(.title2.bold())
            .frame(height: 36)

            Text("\(current)")
                .font(.system(size: 100, weight: .black, design: .rounded))
                .contentTransition(.numericText())
                .animation(.default, value: current)

            Text("Prime number?")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                answerButton("Yes — Prime", .green) { answer(true) }
                answerButton("No — Not Prime", .red) { answer(false) }
            }
            .padding(.horizontal, 16)
        }
    }

    private func answerButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(color, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func answer(_ isPrimeGuess: Bool) {
        let correct = isPrime(current) == isPrimeGuess
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil; current = Int.random(in: 2...99) } }
        }
    }

    private func isPrime(_ n: Int) -> Bool {
        guard n >= 2 else { return false }
        if n == 2 { return true }
        if n % 2 == 0 { return false }
        var i = 3
        while i * i <= n { if n % i == 0 { return false }; i += 2 }
        return true
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        current = Int.random(in: 2...99)
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

#Preview { PrimeRushView() }
