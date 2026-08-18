import SwiftUI

struct CategorySortView: View {
    private struct Item { let word: String; let cat: String }

    private let categories = ["Animal", "Food", "Place", "Object"]
    private let items: [Item] = [
        Item(word:"Eagle",cat:"Animal"),    Item(word:"Pizza",cat:"Food"),
        Item(word:"Paris",cat:"Place"),     Item(word:"Hammer",cat:"Object"),
        Item(word:"Salmon",cat:"Animal"),   Item(word:"Sushi",cat:"Food"),
        Item(word:"Tokyo",cat:"Place"),     Item(word:"Compass",cat:"Object"),
        Item(word:"Cobra",cat:"Animal"),    Item(word:"Mango",cat:"Food"),
        Item(word:"Cairo",cat:"Place"),     Item(word:"Lantern",cat:"Object"),
        Item(word:"Penguin",cat:"Animal"),  Item(word:"Noodles",cat:"Food"),
        Item(word:"London",cat:"Place"),    Item(word:"Scissors",cat:"Object"),
        Item(word:"Dolphin",cat:"Animal"),  Item(word:"Cheese",cat:"Food"),
        Item(word:"Sydney",cat:"Place"),    Item(word:"Backpack",cat:"Object"),
        Item(word:"Panda",cat:"Animal"),    Item(word:"Tacos",cat:"Food"),
        Item(word:"Berlin",cat:"Place"),    Item(word:"Umbrella",cat:"Object"),
        Item(word:"Jaguar",cat:"Animal"),   Item(word:"Waffles",cat:"Food"),
        Item(word:"Madrid",cat:"Place"),    Item(word:"Flashlight",cat:"Object"),
        Item(word:"Flamingo",cat:"Animal"), Item(word:"Dumpling",cat:"Food"),
        Item(word:"Athens",cat:"Place"),    Item(word:"Telescope",cat:"Object"),
    ]

    @State private var queue: [Item] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Item? { queue.first }

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
                    Text(fb ? "✓" : "✗ \(current?.cat ?? "")").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            if let item = current {
                VStack(spacing: 6) {
                    Text("Which category?").font(.subheadline).foregroundStyle(.secondary)
                    Text(item.word).font(.system(size: 56, weight: .black, design: .rounded)).foregroundStyle(.blue)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        Button { pick(cat) } label: {
                            Text(cat).font(.title3.bold())
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(catColor(cat).opacity(0.18), in: RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(catColor(cat), lineWidth: 2))
                                .foregroundStyle(catColor(cat))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func catColor(_ cat: String) -> Color {
        switch cat {
        case "Animal": return .green
        case "Food": return .orange
        case "Place": return .blue
        default: return .purple
        }
    }

    private func pick(_ cat: String) {
        guard let item = current else { return }
        let ok = cat == item.cat
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = items.shuffled() }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = items.shuffled()
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

#Preview { CategorySortView() }
