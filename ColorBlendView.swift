import SwiftUI

// Mix two paint colors. Pick the resulting blend from four options.
struct ColorBlendView: View {
    private struct BlendQ {
        let a: String
        let b: String
        let result: String
        let aColor: Color
        let bColor: Color
    }

    private let blends: [BlendQ] = [
        BlendQ(a:"Red",b:"Blue",result:"Purple",aColor:.red,bColor:.blue),
        BlendQ(a:"Red",b:"Yellow",result:"Orange",aColor:.red,bColor:.yellow),
        BlendQ(a:"Blue",b:"Yellow",result:"Green",aColor:.blue,bColor:.yellow),
        BlendQ(a:"Red",b:"White",result:"Pink",aColor:.red,bColor:.white),
        BlendQ(a:"Black",b:"White",result:"Gray",aColor:.black,bColor:.white),
        BlendQ(a:"Blue",b:"White",result:"Light Blue",aColor:.blue,bColor:.white),
        BlendQ(a:"Red",b:"Black",result:"Dark Red",aColor:.red,bColor:.black),
        BlendQ(a:"Yellow",b:"White",result:"Cream",aColor:.yellow,bColor:Color(red:0.98,green:0.98,blue:0.90)),
        BlendQ(a:"Green",b:"Yellow",result:"Lime",aColor:.green,bColor:.yellow),
        BlendQ(a:"Blue",b:"Green",result:"Teal",aColor:.blue,bColor:.green),
        BlendQ(a:"Red",b:"Orange",result:"Vermillion",aColor:.red,bColor:.orange),
        BlendQ(a:"Purple",b:"Red",result:"Magenta",aColor:.purple,bColor:.red),
    ]

    private let wrongOptions = ["Brown","Cyan","Maroon","Mint","Gold","Navy","Coral","Violet","Tan"]

    @State private var current: BlendQ? = nil
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var queue: [BlendQ] = []

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

    private func gameplayView(_ q: BlendQ) -> some View {
        VStack(spacing: 28) {
            Group {
                if let fb = feedback {
                    Text(fb ? "✓" : "✗ \(q.result)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            HStack(spacing: 20) {
                colorSwatch(q.aColor, label: q.a)
                Text("+").font(.system(size: 36, weight: .black))
                colorSwatch(q.bColor, label: q.b)
                Text("=").font(.system(size: 36, weight: .black))
                Text("?").font(.system(size: 36, weight: .black)).foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { name in
                    Button { guess(name, correct: q.result) } label: {
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

    private func colorSwatch(_ color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primary.opacity(0.15), lineWidth: 1))
            Text(label).font(.caption.bold())
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ name: String, correct: String) {
        let ok = name == correct
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        if queue.isEmpty { queue = blends.shuffled() }
        let q = queue.removeFirst()
        current = q
        var pool: Set<String> = [q.result]
        let extras = wrongOptions.shuffled()
        for w in extras { if pool.count < 4 { pool.insert(w) } }
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

#Preview { ColorBlendView() }
