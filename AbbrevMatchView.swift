import SwiftUI

struct AbbrevMatchView: View {
    private let pairs: [(String, String)] = [
        ("NASA","National Aeronautics and Space Administration"),
        ("DNA","Deoxyribonucleic Acid"),
        ("CEO","Chief Executive Officer"),
        ("ATM","Automated Teller Machine"),
        ("FAQ","Frequently Asked Questions"),
        ("GPS","Global Positioning System"),
        ("PDF","Portable Document Format"),
        ("RAM","Random Access Memory"),
        ("URL","Uniform Resource Locator"),
        ("VPN","Virtual Private Network"),
        ("WiFi","Wireless Fidelity"),
        ("HTML","HyperText Markup Language"),
        ("USB","Universal Serial Bus"),
        ("CPU","Central Processing Unit"),
        ("SOS","Save Our Souls"),
        ("DIY","Do It Yourself"),
        ("ETA","Estimated Time of Arrival"),
        ("ASAP","As Soon As Possible"),
        ("PIN","Personal Identification Number"),
        ("FYI","For Your Information"),
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
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            VStack(spacing: 8) {
                Text("What does this stand for?").font(.headline).foregroundStyle(.secondary)
                Text(current.0)
                    .font(.system(size: 56, weight: .black, design: .monospaced))
            }

            VStack(spacing: 10) {
                ForEach(choices, id: \.self) { ans in
                    Button { guess(ans) } label: {
                        Text(ans)
                            .font(.subheadline.bold())
                            .minimumScaleFactor(0.6)
                            .multilineTextAlignment(.center)
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
        let ok = ans == current.1
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
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

#Preview { AbbrevMatchView() }
