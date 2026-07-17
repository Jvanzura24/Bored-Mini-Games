//
//  SolitaireView.swift
//  Bored Mini Games
//
//  Klondike solitaire with tap-to-move controls: tap a face-up card to
//  select it (and any cards stacked on it), then tap a destination pile.
//  Tap the stock to draw one card at a time; when the stock is empty,
//  tapping it recycles the waste pile.
//

import SwiftUI

// MARK: - Model

enum Suit: CaseIterable {
    case spades, hearts, diamonds, clubs

    var symbol: String {
        switch self {
        case .spades: "♠"
        case .hearts: "♥"
        case .diamonds: "♦"
        case .clubs: "♣"
        }
    }

    var isRed: Bool { self == .hearts || self == .diamonds }
}

struct PlayingCard: Identifiable, Equatable {
    let id = UUID()
    let rank: Int  // 1 = Ace … 13 = King
    let suit: Suit
    var faceUp = false

    var rankText: String {
        switch rank {
        case 1: "A"
        case 11: "J"
        case 12: "Q"
        case 13: "K"
        default: String(rank)
        }
    }
}

enum CardSource: Equatable {
    case waste
    case foundation(Int)
    case tableau(column: Int, index: Int)
}

struct SolitaireGame {
    var stock: [PlayingCard] = []
    var waste: [PlayingCard] = []
    var foundations: [[PlayingCard]] = [[], [], [], []]
    var tableau: [[PlayingCard]] = Array(repeating: [], count: 7)

    init() { deal() }

    mutating func deal() {
        var deck: [PlayingCard] = []
        for suit in Suit.allCases {
            for rank in 1...13 {
                deck.append(PlayingCard(rank: rank, suit: suit))
            }
        }
        deck.shuffle()

        waste = []
        foundations = [[], [], [], []]
        tableau = Array(repeating: [], count: 7)
        for column in 0..<7 {
            for row in 0...column {
                var card = deck.removeLast()
                card.faceUp = (row == column)
                tableau[column].append(card)
            }
        }
        stock = deck
    }

    var isWon: Bool { foundations.allSatisfy { $0.count == 13 } }

    mutating func drawFromStock() {
        if stock.isEmpty {
            stock = waste.reversed().map { card in
                var card = card
                card.faceUp = false
                return card
            }
            waste = []
        } else {
            var card = stock.removeLast()
            card.faceUp = true
            waste.append(card)
        }
    }

    /// The card(s) that would move from a given source: a single top card
    /// for waste/foundation, or a run of cards for a tableau column.
    func movingStack(from source: CardSource) -> [PlayingCard] {
        switch source {
        case .waste:
            return waste.last.map { [$0] } ?? []
        case .foundation(let pile):
            return foundations[pile].last.map { [$0] } ?? []
        case .tableau(let column, let index):
            return Array(tableau[column][index...])
        }
    }

    private mutating func removeStack(at source: CardSource) {
        switch source {
        case .waste:
            waste.removeLast()
        case .foundation(let pile):
            foundations[pile].removeLast()
        case .tableau(let column, let index):
            tableau[column].removeSubrange(index...)
            if let lastIndex = tableau[column].indices.last, !tableau[column][lastIndex].faceUp {
                tableau[column][lastIndex].faceUp = true
            }
        }
    }

    func canPlaceOnFoundation(_ card: PlayingCard, pile: Int) -> Bool {
        if let top = foundations[pile].last {
            return top.suit == card.suit && card.rank == top.rank + 1
        }
        return card.rank == 1
    }

    func canPlaceOnTableau(_ card: PlayingCard, column: Int) -> Bool {
        if let top = tableau[column].last {
            return top.faceUp && top.suit.isRed != card.suit.isRed && card.rank == top.rank - 1
        }
        return card.rank == 13
    }

    @discardableResult
    mutating func moveToFoundation(from source: CardSource, pile: Int) -> Bool {
        let stack = movingStack(from: source)
        guard stack.count == 1, let card = stack.first,
              canPlaceOnFoundation(card, pile: pile) else { return false }
        removeStack(at: source)
        foundations[pile].append(card)
        return true
    }

    @discardableResult
    mutating func moveToTableau(from source: CardSource, column: Int) -> Bool {
        if case .tableau(let fromColumn, _) = source, fromColumn == column { return false }
        let stack = movingStack(from: source)
        guard let first = stack.first, canPlaceOnTableau(first, column: column) else { return false }
        removeStack(at: source)
        tableau[column].append(contentsOf: stack)
        return true
    }
}

// MARK: - View

struct SolitaireView: View {
    @State private var game = SolitaireGame()
    @State private var selection: CardSource?

    private let pileSpacing: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let cardWidth = (geo.size.width - pileSpacing * 8) / 7
            let cardHeight = cardWidth * 1.45

            ZStack {
                Color(red: 0.05, green: 0.42, blue: 0.22)
                    .ignoresSafeArea(edges: .horizontal)

                VStack(spacing: 14) {
                    topRow(cardWidth: cardWidth, cardHeight: cardHeight)
                    ScrollView {
                        HStack(alignment: .top, spacing: pileSpacing) {
                            ForEach(0..<7, id: \.self) { column in
                                tableauColumn(column, cardWidth: cardWidth, cardHeight: cardHeight)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(pileSpacing)

                if game.isWon {
                    winOverlay
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Game") { newGame() }
            }
        }
    }

    private var winOverlay: some View {
        VStack(spacing: 16) {
            Text("You Won! 🎉")
                .font(.largeTitle.bold())
            Button("Play Again") { newGame() }
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func newGame() {
        selection = nil
        game = SolitaireGame()
    }

    // MARK: Top row (stock, waste, foundations)

    private func topRow(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        HStack(spacing: pileSpacing) {
            // Stock
            Group {
                if let top = game.stock.last {
                    CardFace(card: top, width: cardWidth, height: cardHeight, highlighted: false)
                } else {
                    EmptyPile(width: cardWidth, height: cardHeight, symbol: "arrow.trianglehead.2.clockwise")
                }
            }
            .onTapGesture {
                selection = nil
                game.drawFromStock()
            }

            // Waste
            Group {
                if let top = game.waste.last {
                    CardFace(card: top, width: cardWidth, height: cardHeight,
                             highlighted: selection == .waste)
                } else {
                    EmptyPile(width: cardWidth, height: cardHeight, symbol: nil)
                }
            }
            .onTapGesture { tapWaste() }

            Spacer(minLength: cardWidth * 0.3)

            // Foundations
            ForEach(0..<4, id: \.self) { pile in
                Group {
                    if let top = game.foundations[pile].last {
                        CardFace(card: top, width: cardWidth, height: cardHeight,
                                 highlighted: selection == .foundation(pile))
                    } else {
                        EmptyPile(width: cardWidth, height: cardHeight, symbol: "suit.club")
                    }
                }
                .onTapGesture { tapFoundation(pile) }
            }
        }
    }

    // MARK: Tableau

    private func tableauColumn(_ column: Int, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        let cards = game.tableau[column]
        let offsets = stackOffsets(for: cards, cardHeight: cardHeight)
        let totalHeight = (offsets.last ?? 0) + cardHeight

        return ZStack(alignment: .top) {
            if cards.isEmpty {
                EmptyPile(width: cardWidth, height: cardHeight, symbol: "crown")
                    .onTapGesture { tapTableau(column: column, index: nil) }
            }
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardFace(card: card, width: cardWidth, height: cardHeight,
                         highlighted: isSelected(column: column, index: index))
                    .offset(y: offsets[index])
                    .onTapGesture { tapTableau(column: column, index: index) }
            }
        }
        .frame(width: cardWidth, height: max(totalHeight, cardHeight), alignment: .top)
    }

    private func stackOffsets(for cards: [PlayingCard], cardHeight: CGFloat) -> [CGFloat] {
        var offsets: [CGFloat] = []
        var y: CGFloat = 0
        for card in cards {
            offsets.append(y)
            y += card.faceUp ? cardHeight * 0.34 : cardHeight * 0.16
        }
        return offsets
    }

    private func isSelected(column: Int, index: Int) -> Bool {
        if case .tableau(let selColumn, let selIndex) = selection {
            return selColumn == column && index >= selIndex
        }
        return false
    }

    // MARK: Tap handling

    private func tapWaste() {
        if selection == .waste {
            selection = nil
        } else if !game.waste.isEmpty {
            selection = .waste
        }
    }

    private func tapFoundation(_ pile: Int) {
        if let source = selection, game.moveToFoundation(from: source, pile: pile) {
            selection = nil
            return
        }
        if selection == .foundation(pile) {
            selection = nil
        } else if !game.foundations[pile].isEmpty {
            selection = .foundation(pile)
        } else {
            selection = nil
        }
    }

    private func tapTableau(column: Int, index: Int?) {
        // A move attempt: something is selected and the tap targets this column.
        if let source = selection {
            if game.moveToTableau(from: source, column: column) {
                selection = nil
                return
            }
            if selection == .tableau(column: column, index: index ?? -1) {
                selection = nil
                return
            }
        }
        // Otherwise (re)select the tapped face-up card.
        if let index, game.tableau[column][index].faceUp {
            selection = .tableau(column: column, index: index)
        } else {
            selection = nil
        }
    }
}

// MARK: - Card rendering

private struct CardFace: View {
    let card: PlayingCard
    let width: CGFloat
    let height: CGFloat
    let highlighted: Bool

    private var suitColor: Color { card.suit.isRed ? .red : .black }

    var body: some View {
        ZStack {
            if card.faceUp {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                VStack(spacing: 0) {
                    HStack(spacing: 1) {
                        Text(card.rankText)
                            .font(.system(size: width * 0.3, weight: .bold))
                        Text(card.suit.symbol)
                            .font(.system(size: width * 0.26))
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 2)
                    .padding(.leading, 3)
                    Spacer(minLength: 0)
                    Text(card.suit.symbol)
                        .font(.system(size: width * 0.45))
                        .padding(.bottom, height * 0.12)
                }
                .foregroundStyle(suitColor)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(colors: [.blue, Color(red: 0.1, green: 0.2, blue: 0.55)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
        .frame(width: width, height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(highlighted ? Color.yellow : Color.black.opacity(0.35),
                        lineWidth: highlighted ? 3 : 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}

private struct EmptyPile: View {
    let width: CGFloat
    let height: CGFloat
    let symbol: String?

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .strokeBorder(.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 5))
            .frame(width: width, height: height)
            .overlay {
                if let symbol {
                    Image(systemName: symbol)
                        .foregroundStyle(.white.opacity(0.4))
                        .font(.system(size: width * 0.35))
                }
            }
            .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SolitaireView()
    }
}
