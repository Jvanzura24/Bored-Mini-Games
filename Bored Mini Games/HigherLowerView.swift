import SwiftUI

struct HigherLowerView: View {
    private let rankNames = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
    private let suitSymbols = ["♠","♥","♦","♣"]
    private let redSuits: Set<Int> = [1, 2]

    @State private var deck: [Int] = []
    @State private var currentCard = 0
    @State private var score = 0
    @State private var streak = 0
    @State private var gameOver = false
    @State private var feedback: String? = nil
    @State private var lastCard = -1

    private func rankOf(_ card: Int) -> Int { card % 13 }
    private func suitOf(_ card: Int) -> Int { card / 13 }
    private func isRed(_ card: Int) -> Bool { redSuits.contains(suitOf(card)) }
    private func label(_ card: Int) -> String {
        "\(rankNames[rankOf(card)])\(suitSymbols[suitOf(card)])"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                if streak >= 3 { Label("×\(streak)", systemImage: "flame.fill").foregroundStyle(.orange) }
                Spacer()
                Text("\(deck.count) left").foregroundStyle(.secondary)
            }
            .font(.headline)
            .padding(.horizontal, 24).padding(.top, 8)

            Spacer()

            if gameOver {
                gameOverView
            } else {
                gameplayView
            }

            Spacer()
        }
        .onAppear { resetGame() }
    }

    private var gameplayView: some View {
        VStack(spacing: 28) {
            if let fb = feedback {
                Text(fb)
                    .font(.title2.bold())
                    .foregroundStyle(fb.hasPrefix("✓") ? .green : .red)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text(" ").font(.title2)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.10), radius: 12, y: 6)
                    .frame(width: 160, height: 220)

                Text(label(currentCard))
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(isRed(currentCard) ? .red : .primary)
            }

            HStack(spacing: 24) {
                guessButton(label: "Lower", icon: "arrow.down", color: .red) { guess(higher: false) }
                guessButton(label: "Higher", icon: "arrow.up", color: .green) { guess(higher: true) }
            }
        }
    }

    private func guessButton(label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.title3.bold())
                .frame(minWidth: 130, minHeight: 56)
                .background(color, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text(deck.isEmpty ? "Deck cleared! 🎉" : "Wrong guess!")
                .font(.title2.bold())
            Text("Score: \(score)").font(.title3).foregroundStyle(.secondary)
            Button("Play Again") { resetGame() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(higher: Bool) {
        guard !deck.isEmpty else { gameOver = true; return }
        let next = deck.removeFirst()
        let correct = higher ? rankOf(next) >= rankOf(currentCard) : rankOf(next) <= rankOf(currentCard)

        if correct {
            streak += 1
            score += max(1, streak / 3)
            withAnimation { feedback = "✓  \(label(next))" }
            currentCard = next
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                await MainActor.run { withAnimation { feedback = nil } }
                if deck.isEmpty { await MainActor.run { gameOver = true } }
            }
        } else {
            streak = 0
            withAnimation { feedback = "✗  \(label(next))" }
            Task {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { gameOver = true }
            }
        }
    }

    private func resetGame() {
        deck = (0..<52).shuffled()
        currentCard = deck.removeFirst()
        score = 0; streak = 0; gameOver = false; feedback = nil
    }
}

#Preview { HigherLowerView() }
