import SwiftUI

// Type the shown word as fast as possible. Score based on correct words per minute.
struct QuickTypingView: View {
    private let wordList = [
        "apple","brave","cloud","dance","eagle","flame","grace","habit","ivory","jewel",
        "knack","lemon","maple","nerve","ocean","piano","quest","river","shine","tiger",
        "ultra","vivid","waltz","xenon","yacht","zebra","bloom","crisp","drift","ember",
        "frost","graft","honey","index","joust","karma","lunar","magic","noble","orbit",
        "prism","quilt","relay","scope","trade","unity","vapor","wheat","xylem","yield",
    ]

    @State private var currentWord = ""
    @State private var input = ""
    @State private var score = 0
    @State private var timeLeft = 30.0
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var feedback: Bool? = nil
    @State private var queue: [String] = []

    var body: some View {
        VStack(spacing: 20) {
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
            Text(String(format: "%.1f", timeLeft))
                .font(.system(.headline, design: .monospaced))
                .foregroundStyle(timeLeft < 10 ? .red : .primary)
            Spacer()
            Text("Type it!").font(.headline).foregroundStyle(.secondary)
        }
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private var gameplayView: some View {
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title.bold()).frame(height: 44)

            Text(currentWord)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            TextField("Type here…", text: $input)
                .font(.title2)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(14)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 40)
                .onChange(of: input) { _, newVal in
                    if newVal.lowercased() == currentWord {
                        submitWord(correct: true)
                    } else if newVal.count > currentWord.count {
                        submitWord(correct: false)
                    }
                }

            Button("Skip") { submitWord(correct: false) }
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("\(score) words").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func submitWord(correct: Bool) {
        withAnimation { feedback = correct }
        if correct { score += 1 }
        input = ""
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await MainActor.run { feedback = nil; nextWord() }
        }
    }

    private func nextWord() {
        if queue.isEmpty { queue = wordList.shuffled() }
        currentWord = queue.removeFirst()
    }

    private func reset() {
        score = 0; timeLeft = 30; gameOver = false; feedback = nil; input = ""
        queue = wordList.shuffled(); nextWord()
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run {
                    timeLeft = max(0, timeLeft - 0.1)
                    if timeLeft <= 0 { gameOver = true; timerTask?.cancel() }
                }
            }
        }
    }
}

#Preview { QuickTypingView() }
