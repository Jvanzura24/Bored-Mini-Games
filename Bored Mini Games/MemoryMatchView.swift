//
//  MemoryMatchView.swift
//  Bored Mini Games
//
//  Flip cards two at a time and find all eight matching pairs in as few
//  moves as possible.
//

import SwiftUI

struct MemoryMatchView: View {
    private struct MemoryCard: Identifiable {
        let id = UUID()
        let symbol: String
        let color: Color
        var isFaceUp = false
        var isMatched = false
    }

    private static let symbolSet: [(String, Color)] = [
        ("heart.fill", .red),
        ("star.fill", .yellow),
        ("moon.fill", .indigo),
        ("sun.max.fill", .orange),
        ("bolt.fill", .cyan),
        ("leaf.fill", .green),
        ("flame.fill", .pink),
        ("drop.fill", .blue)
    ]

    @State private var cards: [MemoryCard] = Self.makeDeck()
    @State private var firstFlippedIndex: Int?
    @State private var moves = 0
    @State private var isBusy = false

    private var allMatched: Bool { cards.allSatisfy(\.isMatched) }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

    var body: some View {
        VStack(spacing: 16) {
            Text("Moves: \(moves)")
                .font(.headline.monospacedDigit())

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards.indices, id: \.self) { index in
                    cardView(cards[index])
                        .onTapGesture { flip(index) }
                }
            }
            .padding(.horizontal)

            if allMatched {
                VStack(spacing: 12) {
                    Text("All pairs found in \(moves) moves! 🎉")
                        .font(.headline)
                    Button("Play Again") { resetGame() }
                        .buttonStyle(.borderedProminent)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical)
    }

    private func cardView(_ card: MemoryCard) -> some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.secondary)
                Image(systemName: card.symbol)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(card.color)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.gradient)
                Image(systemName: "questionmark")
                    .font(.title2.bold())
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .aspectRatio(0.75, contentMode: .fit)
        .opacity(card.isMatched ? 0.5 : 1)
        .rotation3DEffect(.degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                          axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.25), value: card.isFaceUp)
        .animation(.easeInOut(duration: 0.25), value: card.isMatched)
    }

    private func flip(_ index: Int) {
        guard !isBusy, !cards[index].isFaceUp, !cards[index].isMatched else { return }

        cards[index].isFaceUp = true

        guard let firstIndex = firstFlippedIndex else {
            firstFlippedIndex = index
            return
        }

        moves += 1
        firstFlippedIndex = nil

        if cards[firstIndex].symbol == cards[index].symbol {
            cards[firstIndex].isMatched = true
            cards[index].isMatched = true
        } else {
            isBusy = true
            Task {
                try? await Task.sleep(for: .milliseconds(850))
                cards[firstIndex].isFaceUp = false
                cards[index].isFaceUp = false
                isBusy = false
            }
        }
    }

    private func resetGame() {
        cards = Self.makeDeck()
        firstFlippedIndex = nil
        moves = 0
        isBusy = false
    }

    private static func makeDeck() -> [MemoryCard] {
        (symbolSet + symbolSet)
            .map { MemoryCard(symbol: $0.0, color: $0.1) }
            .shuffled()
    }
}

#Preview {
    MemoryMatchView()
}
