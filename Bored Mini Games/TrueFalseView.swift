import SwiftUI

struct TrueFalseView: View {
    private struct Fact {
        let statement: String
        let isTrue: Bool
    }

    private let facts: [Fact] = [
        Fact(statement: "A triangle has 3 sides.", isTrue: true),
        Fact(statement: "The Sun is a planet.", isTrue: false),
        Fact(statement: "Water boils at 100°C at sea level.", isTrue: true),
        Fact(statement: "Humans have 206 bones.", isTrue: true),
        Fact(statement: "Lightning never strikes the same place twice.", isTrue: false),
        Fact(statement: "Sound travels faster than light.", isTrue: false),
        Fact(statement: "A dozen equals 12.", isTrue: true),
        Fact(statement: "Spiders are insects.", isTrue: false),
        Fact(statement: "The Sahara is the world's largest hot desert.", isTrue: true),
        Fact(statement: "Diamonds are made of carbon.", isTrue: true),
        Fact(statement: "Bats are blind.", isTrue: false),
        Fact(statement: "The heart has 4 chambers.", isTrue: true),
        Fact(statement: "Venus is the hottest planet in our solar system.", isTrue: true),
        Fact(statement: "Penguins live in the Arctic.", isTrue: false),
        Fact(statement: "An octopus has 8 arms.", isTrue: true),
        Fact(statement: "The Great Wall of China is visible from space.", isTrue: false),
        Fact(statement: "Light travels at about 300,000 km/s.", isTrue: true),
        Fact(statement: "Elephants are the largest land animal.", isTrue: true),
        Fact(statement: "A square is a type of rectangle.", isTrue: true),
        Fact(statement: "The Moon produces its own light.", isTrue: false),
        Fact(statement: "Gold is a metal.", isTrue: true),
        Fact(statement: "Plants absorb oxygen at night.", isTrue: false),
        Fact(statement: "Rome is the capital of Italy.", isTrue: true),
        Fact(statement: "A year on Mars is shorter than a year on Earth.", isTrue: false),
        Fact(statement: "Honey never expires.", isTrue: true),
        Fact(statement: "The Pacific is the largest ocean.", isTrue: true),
        Fact(statement: "Whales are fish.", isTrue: false),
        Fact(statement: "Ice is less dense than liquid water.", isTrue: true),
        Fact(statement: "A group of lions is called a pride.", isTrue: true),
        Fact(statement: "Tomatoes are vegetables.", isTrue: false),
    ]

    @State private var queue: [Fact] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Fact? { queue.first }

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
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓ Correct!" : "✗ Wrong!").foregroundStyle(fb ? .green : .red)
                } else {
                    Text(" ")
                }
            }
            .font(.title2.bold()).frame(height: 36)

            if let fact = current {
                Text(fact.statement)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 20) {
                answerButton("TRUE", .green) { answer(true) }
                answerButton("FALSE", .red) { answer(false) }
            }
            .padding(.horizontal, 24)
        }
    }

    private func answerButton(_ title: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title3.bold())
                .frame(maxWidth: .infinity, minHeight: 60)
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

    private func answer(_ choice: Bool) {
        guard let fact = current else { return }
        let correct = choice == fact.isTrue
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = facts.shuffled() }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = facts.shuffled()
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

#Preview { TrueFalseView() }
