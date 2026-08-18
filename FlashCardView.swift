import SwiftUI

// Geography & science flash cards. Tap to flip, swipe to mark known/unknown.
struct FlashCardView: View {
    private struct Card {
        let front: String
        let back: String
    }

    private let cards: [Card] = [
        Card(front: "Capital of France", back: "Paris"),
        Card(front: "Chemical symbol for Gold", back: "Au"),
        Card(front: "Largest planet in our solar system", back: "Jupiter"),
        Card(front: "Number of bones in the adult human body", back: "206"),
        Card(front: "Speed of light (approx)", back: "300,000 km/s"),
        Card(front: "Chemical symbol for Water", back: "H₂O"),
        Card(front: "Deepest ocean trench", back: "Mariana Trench"),
        Card(front: "Closest star to Earth", back: "Proxima Centauri"),
        Card(front: "Hardest natural substance", back: "Diamond"),
        Card(front: "Number of sides on a hexagon", back: "6"),
        Card(front: "Capital of Japan", back: "Tokyo"),
        Card(front: "What does DNA stand for?", back: "Deoxyribonucleic Acid"),
        Card(front: "Boiling point of water (°C)", back: "100°C"),
        Card(front: "Chemical symbol for Iron", back: "Fe"),
        Card(front: "Largest continent", back: "Asia"),
        Card(front: "How many planets in our solar system?", back: "8"),
        Card(front: "Capital of Australia", back: "Canberra"),
        Card(front: "Smallest prime number", back: "2"),
        Card(front: "What force keeps planets in orbit?", back: "Gravity"),
        Card(front: "Freezing point of water (°F)", back: "32°F"),
    ]

    @State private var queue: [Card] = []
    @State private var current: Card? = nil
    @State private var flipped = false
    @State private var known = 0
    @State private var unknown = 0
    @State private var done = false
    @State private var offset: CGFloat = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label("\(known)", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                Spacer()
                Text("\(queue.count) left").font(.headline)
                Spacer()
                Label("\(unknown)", systemImage: "xmark.circle.fill").foregroundStyle(.red)
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            if done {
                doneView
            } else if let card = current {
                cardView(card: card)
            }

            if !done {
                HStack(spacing: 24) {
                    Button {
                        swipe(knew: false)
                    } label: {
                        Label("Didn't know", systemImage: "xmark").font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)

                    Button {
                        swipe(knew: true)
                    } label: {
                        Label("Got it", systemImage: "checkmark").font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .onAppear { reset() }
    }

    private func cardView(card: Card) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 8)

            VStack(spacing: 16) {
                Text(flipped ? "Answer" : "Question")
                    .font(.caption.bold()).foregroundStyle(.secondary)
                Text(flipped ? card.back : card.front)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Text(flipped ? "" : "Tap to reveal")
                    .font(.caption).foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .padding(.horizontal, 20)
        .offset(x: offset)
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(duration: 0.4)) { flipped.toggle() }
        }
    }

    private var doneView: some View {
        VStack(spacing: 20) {
            Text("All Done! ✓").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.green)
            Text("Knew: \(known) / \(cards.count)").font(.title2).foregroundStyle(.secondary)
            Button("Study Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func swipe(knew: Bool) {
        if knew { known += 1 } else { unknown += 1 }
        withAnimation(.easeInOut(duration: 0.25)) { offset = knew ? 300 : -300 }
        Task {
            try? await Task.sleep(for: .milliseconds(280))
            await MainActor.run {
                offset = 0; flipped = false
                if queue.isEmpty { done = true } else { current = queue.removeFirst() }
            }
        }
    }

    private func reset() {
        queue = cards.shuffled(); current = queue.removeFirst()
        known = 0; unknown = 0; done = false; flipped = false; offset = 0
    }
}

#Preview { FlashCardView() }
