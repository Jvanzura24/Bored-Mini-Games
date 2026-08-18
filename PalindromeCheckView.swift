import SwiftUI

struct PalindromeCheckView: View {
    private let items: [(String, Bool)] = [
        ("racecar", true), ("level", true), ("noon", true), ("civic", true),
        ("radar", true), ("madam", true), ("refer", true), ("kayak", true),
        ("rotor", true), ("stats", true), ("121", true), ("1221", true),
        ("12321", true), ("404", true), ("2002", true), ("11", true),
        ("hello", false), ("world", false), ("swift", false), ("apple", false),
        ("table", false), ("chair", false), ("cloud", false), ("mouse", false),
        ("123", false), ("456", false), ("789", false), ("2024", false),
        ("mountain", false), ("garden", false), ("orange", false), ("purple", false),
    ]

    @State private var queue: [(String, Bool)] = []
    @State private var current: (String, Bool) = ("", false)
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

            Text(current.0)
                .font(.system(size: 48, weight: .black, design: .monospaced))
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 24)

            Text("Is this a palindrome?")
                .font(.headline).foregroundStyle(.secondary)

            HStack(spacing: 24) {
                Button("Yes") { answer(true) }
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(Color.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.green)
                    .buttonStyle(.plain)

                Button("No") { answer(false) }
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(Color.red.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.red)
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

    private func answer(_ isPalindrome: Bool) {
        let correct = isPalindrome == current.1
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = items.shuffled() }
        current = queue.removeFirst()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = items.shuffled(); next()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { PalindromeCheckView() }
