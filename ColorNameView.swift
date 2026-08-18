import SwiftUI

// A color swatch is shown. Name the color from 4 choices. Tests color vocabulary.
struct ColorNameView: View {
    private struct ColorItem {
        let name: String
        let color: Color
    }

    private let colorItems: [ColorItem] = [
        ColorItem(name: "Crimson", color: Color(red: 0.86, green: 0.08, blue: 0.24)),
        ColorItem(name: "Coral", color: Color(red: 1.00, green: 0.50, blue: 0.31)),
        ColorItem(name: "Amber", color: Color(red: 1.00, green: 0.75, blue: 0.00)),
        ColorItem(name: "Lime", color: Color(red: 0.60, green: 0.98, blue: 0.20)),
        ColorItem(name: "Teal", color: Color(red: 0.00, green: 0.50, blue: 0.50)),
        ColorItem(name: "Indigo", color: Color(red: 0.29, green: 0.00, blue: 0.51)),
        ColorItem(name: "Violet", color: Color(red: 0.54, green: 0.17, blue: 0.89)),
        ColorItem(name: "Magenta", color: Color(red: 1.00, green: 0.00, blue: 1.00)),
        ColorItem(name: "Maroon", color: Color(red: 0.50, green: 0.00, blue: 0.00)),
        ColorItem(name: "Olive", color: Color(red: 0.50, green: 0.50, blue: 0.00)),
        ColorItem(name: "Navy", color: Color(red: 0.00, green: 0.00, blue: 0.50)),
        ColorItem(name: "Salmon", color: Color(red: 0.98, green: 0.50, blue: 0.45)),
        ColorItem(name: "Khaki", color: Color(red: 0.76, green: 0.69, blue: 0.57)),
        ColorItem(name: "Lavender", color: Color(red: 0.71, green: 0.49, blue: 0.86)),
        ColorItem(name: "Turquoise", color: Color(red: 0.25, green: 0.88, blue: 0.82)),
        ColorItem(name: "Scarlet", color: Color(red: 1.00, green: 0.14, blue: 0.00)),
        ColorItem(name: "Beige", color: Color(red: 0.96, green: 0.96, blue: 0.86)),
        ColorItem(name: "Chartreuse", color: Color(red: 0.50, green: 1.00, blue: 0.00)),
        ColorItem(name: "Cerulean", color: Color(red: 0.00, green: 0.48, blue: 0.65)),
        ColorItem(name: "Fuchsia", color: Color(red: 1.00, green: 0.00, blue: 0.56)),
    ]

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
                    Text(fb ? "✓" : "✗ \(colorItems[currentIdx].name)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("Name this color")
                .font(.headline).foregroundStyle(.secondary)

            RoundedRectangle(cornerRadius: 20)
                .fill(colorItems[currentIdx].color)
                .frame(width: 160, height: 100)
                .shadow(color: colorItems[currentIdx].color.opacity(0.4), radius: 10, x: 0, y: 5)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { name in
                    Button { guess(name) } label: {
                        Text(name)
                            .font(.headline)
                            .minimumScaleFactor(0.7)
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
        let correct = name == colorItems[currentIdx].name
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = Array(colorItems.indices).shuffled() }
        currentIdx = queue.removeFirst()
        let correct = colorItems[currentIdx].name
        var pool: Set<String> = [correct]
        while pool.count < 4 { pool.insert(colorItems.randomElement()!.name) }
        choices = Array(pool).shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil; queue = []
        next()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { ColorNameView() }
