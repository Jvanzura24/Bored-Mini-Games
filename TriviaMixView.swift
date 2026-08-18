import SwiftUI

struct TriviaMixView: View {
    private struct TriviaQ {
        let question: String
        let answer: String
        let wrong: [String]
    }

    private let questions: [TriviaQ] = [
        TriviaQ(question:"How many strings does a standard guitar have?",answer:"6",wrong:["4","8","12"]),
        TriviaQ(question:"What is the largest ocean on Earth?",answer:"Pacific",wrong:["Atlantic","Indian","Arctic"]),
        TriviaQ(question:"How many sides does a triangle have?",answer:"3",wrong:["4","5","6"]),
        TriviaQ(question:"What gas do plants absorb?",answer:"Carbon dioxide",wrong:["Oxygen","Nitrogen","Hydrogen"]),
        TriviaQ(question:"How many colors in a rainbow?",answer:"7",wrong:["5","6","8"]),
        TriviaQ(question:"What is the currency of Japan?",answer:"Yen",wrong:["Won","Yuan","Rupee"]),
        TriviaQ(question:"Which planet is closest to the Sun?",answer:"Mercury",wrong:["Venus","Earth","Mars"]),
        TriviaQ(question:"How many hours in a day?",answer:"24",wrong:["12","20","48"]),
        TriviaQ(question:"What is the square root of 144?",answer:"12",wrong:["11","13","14"]),
        TriviaQ(question:"Which element has symbol O?",answer:"Oxygen",wrong:["Gold","Iron","Osmium"]),
        TriviaQ(question:"How many degrees in a right angle?",answer:"90",wrong:["45","180","360"]),
        TriviaQ(question:"What is the longest bone in the human body?",answer:"Femur",wrong:["Tibia","Humerus","Spine"]),
        TriviaQ(question:"How many players on a basketball team?",answer:"5",wrong:["6","7","11"]),
        TriviaQ(question:"What is the chemical symbol for water?",answer:"H₂O",wrong:["HO","H₂O₂","O₂H"]),
        TriviaQ(question:"Which ocean is the smallest?",answer:"Arctic",wrong:["Indian","Southern","Atlantic"]),
        TriviaQ(question:"How many teeth do adults have?",answer:"32",wrong:["28","30","36"]),
        TriviaQ(question:"What color are veins?",answer:"Blue",wrong:["Red","Green","Purple"]),
        TriviaQ(question:"How many minutes in an hour?",answer:"60",wrong:["50","90","100"]),
        TriviaQ(question:"Which is the tallest mountain?",answer:"Everest",wrong:["K2","Kilimanjaro","Mont Blanc"]),
        TriviaQ(question:"How many players in a soccer team?",answer:"11",wrong:["9","10","12"]),
    ]

    @State private var current: TriviaQ? = nil
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [TriviaQ] = []

    var body: some View {
        VStack(spacing: 24) {
            hud
            Spacer()
            if gameOver { gameOverView } else if let q = current { gameplayView(q) }
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

    private func gameplayView(_ q: TriviaQ) -> some View {
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ \(q.answer)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text(q.question)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { ans in
                    Button { guess(ans, correct: q.answer) } label: {
                        Text(ans)
                            .font(.headline)
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 56)
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

    private func guess(_ ans: String, correct: String) {
        let ok = ans == correct
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = questions.shuffled() }
        let q = queue.removeFirst()
        current = q
        choices = ([q.answer] + q.wrong.shuffled().prefix(3)).shuffled()
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

#Preview { TriviaMixView() }
