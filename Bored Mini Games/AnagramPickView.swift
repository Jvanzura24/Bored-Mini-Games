import SwiftUI

// Given scrambled letters, which of the four options is a real word using them?
struct AnagramPickView: View {
    private struct Q {
        let letters: String   // e.g. "AELPT"
        let answer: String    // e.g. "PLATE"
        let wrong: [String]   // same length, not valid anagrams
        var choices: [String] { ([answer] + wrong).shuffled() }
    }

    private let questions: [Q] = [
        Q(letters:"AELPT", answer:"PLATE", wrong:["PLEAT","TAPEL","PLETA"]),
        Q(letters:"EACPR", answer:"CAPER", wrong:["CRAPE","CARPE","PECAR"]),
        Q(letters:"EIRGN", answer:"REIGN", wrong:["GIREN","NIGER","RINGE"]),
        Q(letters:"ADNST", answer:"STAND", wrong:["DANTS","TANDS","SDANT"]),
        Q(letters:"ACEFL", answer:"FLACE", wrong:["CLAFE","CLAEF","FALCE"]),
        Q(letters:"EGHLT", answer:"LIGHT", wrong:["THLIG","GILTH","LITGH"]),
        Q(letters:"AEPRS", answer:"SPARE", wrong:["PEARS","RAPES","REAPS"]),
        Q(letters:"ABCEK", answer:"BEACH", wrong:["BECAK","KAECB","CEABK"]),
        Q(letters:"EILNS", answer:"LINES", wrong:["SLEIN","NILES","LIÉNS"]),
        Q(letters:"AMORR", answer:"ARMOR", wrong:["RAMOR","MAROR","RAROM"]),
        Q(letters:"BELOR", answer:"ROBE",  wrong:["ORBLE","BRELO","OBLRE"]),
        Q(letters:"DENOS", answer:"STONE", wrong:["NOTES","TONES","SENOD"]),
        Q(letters:"AEGLR", answer:"LARGE", wrong:["GLARE","LAGER","REGAL"]),
        Q(letters:"CEHST", answer:"CHEST", wrong:["STECH","ETCSH","HECTS"]),
        Q(letters:"AIMNR", answer:"MARIN", wrong:["RINAM","NARIM","MRANI"]),
        Q(letters:"ADLNO", answer:"ALONG", wrong:["LANOD","NODAL","DONAL"]),
        Q(letters:"EGINP", answer:"PINGE", wrong:["GENIP","NGIPE","PIGÉN"]),
        Q(letters:"ACNOT", answer:"OCTAN", wrong:["COTAN","TACON","CANTO"]),
        Q(letters:"DEINO", answer:"OILED", wrong:["DIENO","OIDNE","NODIE"]),
        Q(letters:"AHORT", answer:"Torah", wrong:["HOTÁR","AROHT","THORA"]),
    ]

    @State private var queue: [Q] = []
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var current: Q? { queue.first }

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
                    Text(fb ? "✓ \(current?.answer ?? "")" : "✗ \(current?.answer ?? "")").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            if let q = current {
                VStack(spacing: 8) {
                    Text("Which is a real word?").font(.subheadline).foregroundStyle(.secondary)
                    Text("Letters: \(q.letters)")
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .tracking(6)
                        .foregroundStyle(.blue)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(choices, id: \.self) { w in
                        Button { pick(w, correct: q.answer) } label: {
                            Text(w).font(.title3.bold())
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
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

    private func pick(_ w: String, correct: String) {
        let ok = w == correct
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        queue.removeFirst()
        if queue.isEmpty { queue = questions.shuffled() }
        choices = queue.first!.choices
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil } }
        }
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        queue = questions.shuffled()
        choices = queue.first!.choices
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

#Preview { AnagramPickView() }
