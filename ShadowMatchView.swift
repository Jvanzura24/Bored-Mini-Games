import SwiftUI

// Match the silhouette to the correct shape name. 4 choices, 60s, 3 lives.
struct ShadowMatchView: View {
    private struct ShapeItem: Identifiable {
        let id = UUID()
        let name: String
        let builder: () -> AnyView
    }

    private var shapeItems: [ShapeItem] {[
        ShapeItem(name: "Circle") { AnyView(Circle().fill(Color.primary)) },
        ShapeItem(name: "Square") { AnyView(Rectangle().fill(Color.primary)) },
        ShapeItem(name: "Triangle") { AnyView(
            Path { p in
                p.move(to: CGPoint(x: 50, y: 0))
                p.addLine(to: CGPoint(x: 100, y: 100))
                p.addLine(to: CGPoint(x: 0, y: 100))
                p.closeSubpath()
            }.fill(Color.primary).frame(width: 100, height: 100)
        )},
        ShapeItem(name: "Pentagon") { AnyView(
            Path { p in
                let sides = 5
                let center = CGPoint(x: 50, y: 50)
                let r: CGFloat = 50
                for i in 0..<sides {
                    let angle = (Double(i) * 2 * .pi / Double(sides)) - .pi / 2
                    let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
                    i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                }
                p.closeSubpath()
            }.fill(Color.primary).frame(width: 100, height: 100)
        )},
        ShapeItem(name: "Hexagon") { AnyView(
            Path { p in
                let sides = 6
                let center = CGPoint(x: 50, y: 50)
                let r: CGFloat = 50
                for i in 0..<sides {
                    let angle = (Double(i) * 2 * .pi / Double(sides)) - .pi / 2
                    let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
                    i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                }
                p.closeSubpath()
            }.fill(Color.primary).frame(width: 100, height: 100)
        )},
        ShapeItem(name: "Star") { AnyView(
            Path { p in
                let points = 5
                let cx: CGFloat = 50; let cy: CGFloat = 50
                let outerR: CGFloat = 50; let innerR: CGFloat = 20
                for i in 0..<(points * 2) {
                    let angle = Double(i) * .pi / Double(points) - .pi / 2
                    let r = i.isMultiple(of: 2) ? outerR : innerR
                    let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
                    i == 0 ? p.move(to: pt) : p.addLine(to: pt)
                }
                p.closeSubpath()
            }.fill(Color.primary).frame(width: 100, height: 100)
        )},
        ShapeItem(name: "Diamond") { AnyView(
            Path { p in
                p.move(to: CGPoint(x: 50, y: 0))
                p.addLine(to: CGPoint(x: 100, y: 50))
                p.addLine(to: CGPoint(x: 50, y: 100))
                p.addLine(to: CGPoint(x: 0, y: 50))
                p.closeSubpath()
            }.fill(Color.primary).frame(width: 100, height: 100)
        )},
        ShapeItem(name: "Oval") { AnyView(Ellipse().fill(Color.primary).frame(width: 100, height: 60)) },
    ]}

    @State private var currentIdx = 0
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [Int] = []

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
                    Text(fb ? "✓" : "✗ \(shapeItems[currentIdx].name)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("What shape is this?")
                .font(.headline).foregroundStyle(.secondary)

            shapeItems[currentIdx].builder()
                .frame(width: 100, height: 100)
                .opacity(0.85)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { name in
                    Button { guess(name) } label: {
                        Text(name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ name: String) {
        let correct = name == shapeItems[currentIdx].name
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = Array(shapeItems.indices).shuffled() }
        currentIdx = queue.removeFirst()
        let correct = shapeItems[currentIdx].name
        var pool: Set<String> = [correct]
        let all = shapeItems.map { $0.name }
        while pool.count < 4 {
            pool.insert(all.randomElement()!)
        }
        choices = Array(pool).shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = []; next()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { ShadowMatchView() }
