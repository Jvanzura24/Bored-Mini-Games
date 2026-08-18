import SwiftUI

// A word flashes briefly — pick it from four choices.
struct SpeedReadView: View {
    private let wordList = [
        "ANCHOR","BLIZZARD","CAPTAIN","DIAMOND","ECLIPSE","FORTUNE","GLACIER","HORIZON",
        "ISLAND","JOURNEY","KINGDOM","LANTERN","MYSTERY","NETWORK","ORCHARD","PILGRIM",
        "QUANTUM","RAINBOW","SHELTER","THUNDER","ULTIMATE","VILLAGE","WHISPER","XENON",
        "YELLOWED","ZEALOUS","BRACKET","COMPASS","DRIFTER","EVEREST","FISSION","GOBLIN",
        "HARVEST","IMPULSE","JAVELIN","KNAPSACK","LEMENT","MORTISE","NEBULA","OTTOMAN",
        "PENDANT","QUORUM","REACTOR","SINISTER","TANGENT","UPWARD","VOLTAGE","WRANGLE",
    ]

    private enum Phase { case idle, showing, choosing, result }

    @State private var phase: Phase = .idle
    @State private var flashWord = ""
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var difficulty: Difficulty = .medium

    private var flashDuration: Double {
        switch difficulty { case .easy: return 1.0; case .medium: return 0.6; case .hard: return 0.3 }
    }

    var body: some View {
        VStack(spacing: 24) {
            DifficultyPicker(difficulty: $difficulty)
                .onChange(of: difficulty) { _, _ in reset() }
            hud
            Spacer()
            if gameOver { gameOverView } else { contentView }
            Spacer()
        }
        .onAppear { reset() }
        .onDisappear { timerTask?.cancel() }
    }

    private var gameOver: Bool { lives <= 0 || timeLeft <= 0 }

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
        .font(.headline).padding(.horizontal, 24)
    }

    private var contentView: some View {
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ \(flashWord)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            switch phase {
            case .idle, .result:
                Button("Flash Word!") { nextRound() }
                    .buttonStyle(.borderedProminent).font(.headline)
            case .showing:
                Text(flashWord)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .transition(.opacity)
            case .choosing:
                VStack(spacing: 12) {
                    Text("Which word did you see?").font(.subheadline).foregroundStyle(.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(choices, id: \.self) { w in
                            Button { pick(w) } label: {
                                Text(w).font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
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

    private func nextRound() {
        flashWord = wordList.randomElement()!
        var pool: Set<String> = [flashWord]
        while pool.count < 4 { pool.insert(wordList.randomElement()!) }
        choices = pool.shuffled()
        withAnimation { phase = .showing }
        Task {
            try? await Task.sleep(for: .seconds(flashDuration))
            await MainActor.run { withAnimation { phase = .choosing } }
        }
    }

    private func pick(_ w: String) {
        let ok = w == flashWord
        withAnimation { feedback = ok; phase = .result }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil }; nextRound() }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; feedback = nil; phase = .idle
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run { timeLeft -= 1 }
            }
        }
    }
}

#Preview { SpeedReadView() }
