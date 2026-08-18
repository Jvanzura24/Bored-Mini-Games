import SwiftUI

// Numbers fall from the top. Drag each to the Even or Odd bin at the bottom.
struct EvenOddSortView: View {
    private struct FallingNumber: Identifiable {
        let id = UUID()
        let value: Int
        var y: CGFloat = 0.05
        var done = false
    }

    @State private var falling: [FallingNumber] = []
    @State private var score = 0
    @State private var mistakes = 0
    @State private var timeLeft = 45.0
    @State private var gameOver = false
    @State private var loopTask: Task<Void, Never>? = nil
    @State private var feedbackSide: String? = nil
    @State private var feedbackGood = true

    private let maxMistakes = 3

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    hud
                    Spacer()
                    binsRow(geo: geo)
                        .padding(.bottom, 24)
                }

                ForEach(falling) { item in
                    if !item.done {
                        numberTile(item: item, geo: geo)
                    }
                }

                if let side = feedbackSide {
                    Text(feedbackGood ? "✓" : "✗")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(feedbackGood ? .green : .red)
                        .position(x: side == "even" ? geo.size.width * 0.25 : geo.size.width * 0.75,
                                  y: geo.size.height * 0.75)
                        .transition(.scale.combined(with: .opacity))
                }

                if gameOver { gameOverOverlay }
            }
        }
        .onAppear { startGame() }
        .onDisappear { loopTask?.cancel() }
    }

    private var hud: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
            Spacer()
            HStack(spacing: 4) {
                ForEach(0..<maxMistakes, id: \.self) { i in
                    Image(systemName: i < maxMistakes - mistakes ? "heart.fill" : "heart").foregroundStyle(.red)
                }
            }
            Spacer()
            Label(String(format: "%.0f", timeLeft), systemImage: "timer")
        }
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private func binsRow(geo: GeometryProxy) -> some View {
        HStack(spacing: 16) {
            binView("EVEN", color: .blue) { dropAll(side: "even", geo: geo) }
            binView("ODD", color: .red) { dropAll(side: "odd", geo: geo) }
        }
        .padding(.horizontal, 24)
    }

    private func binView(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .frame(maxWidth: .infinity, minHeight: 72)
                .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(color)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.4), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private func numberTile(item: FallingNumber, geo: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(item.value.isMultiple(of: 2) ? Color.blue.opacity(0.15) : Color.red.opacity(0.15))
                .frame(width: 60, height: 60)
            Text("\(item.value)")
                .font(.system(size: 26, weight: .black, design: .rounded))
        }
        .position(x: geo.size.width * CGFloat.random(in: 0.15...0.85), y: item.y * geo.size.height)
    }

    private func dropAll(side: String, geo: GeometryProxy) {
        guard !gameOver else { return }
        for i in falling.indices where !falling[i].done {
            let isEven = falling[i].value.isMultiple(of: 2)
            let correct = (side == "even") == isEven
            falling[i].done = true
            if correct { score += 1 } else {
                mistakes += 1
                if mistakes >= maxMistakes { gameOver = true }
            }
        }
        withAnimation { feedbackSide = side; feedbackGood = mistakes < maxMistakes }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedbackSide = nil; if !gameOver { spawnWave() } }
        }
    }

    private func spawnWave() {
        let count = Int.random(in: 1...3)
        let newItems = (0..<count).map { _ in FallingNumber(value: Int.random(in: 1...99)) }
        falling = newItems
    }

    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                Button("Play Again") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func startGame() {
        score = 0; mistakes = 0; timeLeft = 45; gameOver = false; feedbackSide = nil
        falling = []
        loopTask?.cancel()
        spawnWave()
        loopTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { EvenOddSortView() }
