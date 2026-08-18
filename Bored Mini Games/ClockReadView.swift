import SwiftUI

struct ClockReadView: View {
    @State private var hour = 3
    @State private var minute = 0
    @State private var choices: [String] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = 60.0
    @State private var gameOver = false
    @State private var feedback: Bool? = nil
    @State private var timerTask: Task<Void, Never>? = nil

    private var answer: String { timeLabel(hour, minute) }

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
                    Text(fb ? "✓" : "✗ \(answer)").foregroundStyle(fb ? .green : .red)
                } else { Text(" ") }
            }
            .font(.title2.bold()).frame(height: 36)

            Text("What time is shown?").font(.subheadline).foregroundStyle(.secondary)

            clockFace
                .frame(width: 180, height: 180)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(choices, id: \.self) { c in
                    Button { guess(c) } label: {
                        Text(c).font(.title3.bold())
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var clockFace: some View {
        ZStack {
            Circle().fill(.white).shadow(color: .black.opacity(0.12), radius: 10)
            Circle().stroke(Color(.systemGray3), lineWidth: 2)

            ForEach(1...12, id: \.self) { n in
                let angle = Angle(degrees: Double(n) * 30 - 90)
                Text("\(n)").font(.system(size: 11, weight: .semibold))
                    .position(
                        x: 90 + 72 * cos(angle.radians),
                        y: 90 + 72 * sin(angle.radians)
                    )
            }

            // Hour hand
            let hAngle = Angle(degrees: Double(hour % 12) * 30 + Double(minute) * 0.5 - 90)
            Rectangle()
                .fill(Color.primary)
                .frame(width: 4, height: 50)
                .offset(y: -25)
                .rotationEffect(hAngle, anchor: .bottom)
                .position(x: 90, y: 90)

            // Minute hand
            let mAngle = Angle(degrees: Double(minute) * 6 - 90)
            Rectangle()
                .fill(Color.primary)
                .frame(width: 3, height: 68)
                .offset(y: -34)
                .rotationEffect(mAngle, anchor: .bottom)
                .position(x: 90, y: 90)

            Circle().fill(Color.primary).frame(width: 8, height: 8).position(x: 90, y: 90)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Game Over").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func guess(_ c: String) {
        let ok = c == answer
        withAnimation { feedback = ok }
        if ok { score += 1 } else { lives -= 1 }
        if lives <= 0 { gameOver = true; timerTask?.cancel(); return }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            await MainActor.run { withAnimation { feedback = nil }; nextClock() }
        }
    }

    private func timeLabel(_ h: Int, _ m: Int) -> String {
        String(format: "%d:%02d", h == 0 ? 12 : h, m)
    }

    private func nextClock() {
        let validMinutes = [0, 15, 30, 45]
        hour = Int.random(in: 1...12)
        minute = validMinutes.randomElement()!
        var pool: Set<String> = [answer]
        while pool.count < 4 {
            let rh = Int.random(in: 1...12)
            let rm = validMinutes.randomElement()!
            pool.insert(timeLabel(rh, rm))
        }
        choices = pool.shuffled()
    }

    private func reset() {
        score = 0; lives = 3; timeLeft = 60; gameOver = false; feedback = nil
        nextClock()
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

#Preview { ClockReadView() }
