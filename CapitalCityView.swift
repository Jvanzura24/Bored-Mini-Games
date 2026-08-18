import SwiftUI

struct CapitalCityView: View {
    private let pairs: [(String, String)] = [
        ("France","Paris"),("Japan","Tokyo"),("Brazil","Brasília"),("Australia","Canberra"),
        ("Canada","Ottawa"),("Mexico","Mexico City"),("Germany","Berlin"),("Italy","Rome"),
        ("Spain","Madrid"),("Russia","Moscow"),("China","Beijing"),("India","New Delhi"),
        ("Egypt","Cairo"),("South Africa","Pretoria"),("Argentina","Buenos Aires"),
        ("South Korea","Seoul"),("Turkey","Ankara"),("Sweden","Stockholm"),
        ("Norway","Oslo"),("Portugal","Lisbon"),("Netherlands","Amsterdam"),
        ("Poland","Warsaw"),("Greece","Athens"),("Switzerland","Bern"),
        ("Austria","Vienna"),("Belgium","Brussels"),("Finland","Helsinki"),
        ("New Zealand","Wellington"),("Thailand","Bangkok"),("Vietnam","Hanoi"),
    ]

    @State private var current: (String, String) = ("", "")
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [(String, String)] = []

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
                    Text(fb ? "✓" : "✗ \(current.1)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            VStack(spacing: 8) {
                Text("Capital of").font(.headline).foregroundStyle(.secondary)
                Text(current.0)
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 16)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { city in
                    Button { guess(city) } label: {
                        Text(city)
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

    private func guess(_ city: String) {
        let correct = city == current.1
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
        var pool: Set<String> = [current.1]
        while pool.count < 4 { pool.insert(pairs.randomElement()!.1) }
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

#Preview { CapitalCityView() }
