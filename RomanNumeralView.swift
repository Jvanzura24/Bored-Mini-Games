import SwiftUI

struct RomanNumeralView: View {
    private let pairs: [(String, Int)] = [
        ("I",1),("II",2),("III",3),("IV",4),("V",5),("VI",6),("VII",7),("VIII",8),
        ("IX",9),("X",10),("XI",11),("XII",12),("XIV",14),("XV",15),("XVI",16),
        ("XIX",19),("XX",20),("XXI",21),("XXV",25),("XL",40),("XLV",45),("L",50),
        ("LX",60),("LXX",70),("XC",90),("XCIX",99),("C",100),("CX",110),("CL",150),
        ("CC",200),("CD",400),("D",500),("DL",550),("CM",900),("M",1000),("MCMXCIX",1999),
    ]

    @State private var current: (String, Int) = ("I", 1)
    @State private var choices: [Int] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [(String, Int)] = []

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
        VStack(spacing: 32) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ = \(current.1)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            VStack(spacing: 8) {
                Text("Roman → Decimal").font(.headline).foregroundStyle(.secondary)
                Text(current.0)
                    .font(.system(size: 56, weight: .black, design: .serif))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { n in
                    Button { guess(n) } label: {
                        Text("\(n)")
                            .font(.title2.bold())
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

    private func guess(_ n: Int) {
        let correct = n == current.1
        withAnimation { feedback = correct }
        if correct { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = pairs.shuffled() }
        current = queue.removeFirst()
        var pool: Set<Int> = [current.1]
        while pool.count < 4 {
            let off = Int.random(in: 1...max(3, current.1 / 4)) * (Bool.random() ? 1 : -1)
            let c = current.1 + off
            if c > 0 { pool.insert(c) }
        }
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

#Preview { RomanNumeralView() }
