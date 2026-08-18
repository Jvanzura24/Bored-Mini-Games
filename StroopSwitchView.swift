import SwiftUI

// Stroop with a twist: an indicator tells you whether to name the COLOR or READ the WORD.
struct StroopSwitchView: View {
    private struct Item {
        let word: String
        let inkColor: Color
        let inkName: String
    }

    private let items: [Item] = [
        Item(word:"RED",    inkColor:.blue,   inkName:"Blue"),
        Item(word:"BLUE",   inkColor:.red,    inkName:"Red"),
        Item(word:"GREEN",  inkColor:.orange, inkName:"Orange"),
        Item(word:"ORANGE", inkColor:.green,  inkName:"Green"),
        Item(word:"PURPLE", inkColor:.yellow, inkName:"Yellow"),
        Item(word:"YELLOW", inkColor:.purple, inkName:"Purple"),
        Item(word:"RED",    inkColor:.green,  inkName:"Green"),
        Item(word:"BLUE",   inkColor:.orange, inkName:"Orange"),
        Item(word:"GREEN",  inkColor:.red,    inkName:"Red"),
        Item(word:"ORANGE", inkColor:.purple, inkName:"Purple"),
    ]

    @State private var current: Item = Item(word:"",inkColor:.clear,inkName:"")
    @State private var readWord = true  // true = read the word, false = name the ink color
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [Item] = []

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
        VStack(spacing: 24) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ \(readWord ? current.word : current.inkName)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            // Mode indicator
            HStack(spacing: 8) {
                Image(systemName: readWord ? "text.cursor" : "paintbrush.fill")
                    .font(.title3)
                Text(readWord ? "READ the WORD" : "NAME the INK COLOR")
                    .font(.headline.bold())
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background((readWord ? Color.blue : Color.orange).opacity(0.15), in: Capsule())
            .foregroundStyle(readWord ? .blue : .orange)

            Text(current.word)
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(current.inkColor)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { ans in
                    Button { guess(ans) } label: {
                        Text(ans)
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

    private func guess(_ ans: String) {
        let correct = readWord ? ans == current.word : ans == current.inkName
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = items.shuffled() }
        current = queue.removeFirst()
        readWord = Bool.random()
        let correct = readWord ? current.word : current.inkName
        let allWords = Array(Set(items.map { $0.word }))
        let allInks = Array(Set(items.map { $0.inkName }))
        let pool = readWord ? allWords : allInks
        var chosen: Set<String> = [correct]
        while chosen.count < 4 { chosen.insert(pool.randomElement()!) }
        choices = Array(chosen).shuffled()
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

#Preview { StroopSwitchView() }
