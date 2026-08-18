import SwiftUI

struct CardWarView: View {
    private let rankNames = ["2","3","4","5","6","7","8","9","10","J","Q","K","A"]
    private let suitSymbols = ["♠","♥","♦","♣"]
    private let redSuits: Set<Int> = [1, 2]

    @State private var playerDeck: [Int] = []
    @State private var cpuDeck: [Int] = []
    @State private var playerCard: Int? = nil
    @State private var cpuCard: Int? = nil
    @State private var roundResult = ""
    @State private var gameOver = false
    @State private var phase: Phase = .idle

    private enum Phase { case idle, revealed }

    private func rankOf(_ c: Int) -> Int { c % 13 }
    private func suitOf(_ c: Int) -> Int { c / 13 }
    private func isRed(_ c: Int) -> Bool { redSuits.contains(suitOf(c)) }
    private func label(_ c: Int) -> String { "\(rankNames[rankOf(c)])\(suitSymbols[suitOf(c)])" }

    var body: some View {
        VStack(spacing: 0) {
            deckCounts
            Spacer()
            if gameOver {
                gameOverView
            } else {
                battleArea
                Spacer()
                flipButton
            }
        }
        .onAppear { resetGame() }
    }

    private var deckCounts: some View {
        HStack {
            VStack(spacing: 4) {
                Text("You").font(.headline).foregroundStyle(.secondary)
                Text("\(playerDeck.count)").font(.system(size: 48, weight: .black, design: .rounded))
                Text("cards").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("vs").font(.title2).foregroundStyle(.secondary)
            Spacer()
            VStack(spacing: 4) {
                Text("CPU").font(.headline).foregroundStyle(.secondary)
                Text("\(cpuDeck.count)").font(.system(size: 48, weight: .black, design: .rounded))
                Text("cards").font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 40).padding(.top, 16)
    }

    private var battleArea: some View {
        VStack(spacing: 20) {
            if phase == .revealed, let pc = playerCard, let cc = cpuCard {
                HStack(spacing: 40) {
                    cardFace(pc, label: "You")
                    cardFace(cc, label: "CPU")
                }
                Text(roundResult)
                    .font(.title2.bold())
                    .foregroundStyle(roundResult == "You win!" ? .green :
                                     roundResult == "CPU wins!" ? .red : .orange)
                    .transition(.scale.combined(with: .opacity))
            } else {
                HStack(spacing: 40) {
                    cardBack(label: "You")
                    cardBack(label: "CPU")
                }
            }
        }
    }

    private func cardFace(_ card: Int, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                    .frame(width: 120, height: 170)
                Text(self.label(card))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(isRed(card) ? .red : .primary)
            }
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
        }
    }

    private func cardBack(label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.blue.opacity(0.85))
                    .frame(width: 120, height: 170)
                Image(systemName: "suit.diamond.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white.opacity(0.3))
            }
            Text(label).font(.caption.bold()).foregroundStyle(.secondary)
        }
    }

    private var flipButton: some View {
        Button {
            flipCards()
        } label: {
            Text(phase == .idle ? "Flip!" : "Next Round")
                .font(.title3.bold())
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24).padding(.bottom, 24)
        .disabled(playerDeck.isEmpty || cpuDeck.isEmpty)
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text(playerDeck.count > cpuDeck.count ? "You Win! 🎉" : "CPU Wins!")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("You: \(playerDeck.count)  CPU: \(cpuDeck.count)").font(.title3).foregroundStyle(.secondary)
            Button("Play Again") { resetGame() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func flipCards() {
        if phase == .revealed {
            if playerDeck.isEmpty || cpuDeck.isEmpty { gameOver = true; return }
            withAnimation { phase = .idle; playerCard = nil; cpuCard = nil; roundResult = "" }
            return
        }
        guard !playerDeck.isEmpty && !cpuDeck.isEmpty else { gameOver = true; return }
        let pc = playerDeck.removeFirst()
        let cc = cpuDeck.removeFirst()
        playerCard = pc; cpuCard = cc

        if rankOf(pc) > rankOf(cc) {
            roundResult = "You win!"; playerDeck.append(contentsOf: [pc, cc].shuffled())
        } else if rankOf(cc) > rankOf(pc) {
            roundResult = "CPU wins!"; cpuDeck.append(contentsOf: [pc, cc].shuffled())
        } else {
            roundResult = "War! — Draw"; playerDeck.append(pc); cpuDeck.append(cc)
        }

        withAnimation { phase = .revealed }
        if playerDeck.isEmpty || cpuDeck.isEmpty { gameOver = true }
    }

    private func resetGame() {
        let shuffled = (0..<52).shuffled()
        playerDeck = Array(shuffled.prefix(26))
        cpuDeck = Array(shuffled.suffix(26))
        playerCard = nil; cpuCard = nil
        roundResult = ""; gameOver = false; phase = .idle
    }
}

#Preview { CardWarView() }
