import SwiftUI

// Tap bumpers to score points. Each bumper has limited charges.
struct PinballBumperView: View {
    private struct Bumper: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var charges: Int
        var value: Int
        var flashing = false
    }

    @State private var bumpers: [Bumper] = []
    @State private var score = 0
    @State private var timeLeft = 30.0
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var multiplier = 1
    @State private var comboCount = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.10, green: 0.05, blue: 0.20)],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                // HUD
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Score").font(.caption).foregroundStyle(.white.opacity(0.6))
                            Text("\(score)").font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(.white)
                        }
                        Spacer()
                        VStack {
                            Text(String(format: "%.0f", timeLeft))
                                .font(.system(size: 32, weight: .black, design: .monospaced))
                                .foregroundStyle(timeLeft < 10 ? .red : .white)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Combo x\(multiplier)").font(.caption).foregroundStyle(.yellow.opacity(0.8))
                            Text("\(comboCount) hits").font(.caption).foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                // Bumpers
                ForEach(bumpers) { bumper in
                    bumperView(bumper: bumper, geo: geo)
                        .position(x: bumper.x * geo.size.width, y: bumper.y * geo.size.height)
                }

                // Game over overlay
                if gameOver {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 20) {
                        Text("Time's Up!").font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
                        Text("Score: \(score)").font(.title2).foregroundStyle(.white.opacity(0.8))
                        Button("Play Again") { startGame(geo: geo) }.buttonStyle(.borderedProminent).font(.headline)
                    }
                    .padding(32)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                }
            }
        }
        .onAppear { }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { startGame(geo: geo) }
            }
        )
        .onDisappear { timerTask?.cancel() }
    }

    private func bumperView(bumper: Bumper, geo: GeometryProxy) -> some View {
        let idx = bumpers.firstIndex(where: { $0.id == bumper.id })
        return Button {
            if let i = idx { hitBumper(i) }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        bumper.flashing ?
                        LinearGradient(colors: [.white, .yellow], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(
                            colors: [bumperColor(bumper.value).opacity(0.9), bumperColor(bumper.value).opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: bumperSize(bumper.value), height: bumperSize(bumper.value))
                    .shadow(color: bumperColor(bumper.value).opacity(0.6), radius: bumper.flashing ? 16 : 6)

                VStack(spacing: 2) {
                    Text("+\(bumper.value)")
                        .font(.system(size: bumperSize(bumper.value) * 0.28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("\(bumper.charges)")
                        .font(.system(size: bumperSize(bumper.value) * 0.20, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(bumper.charges > 0 ? 1.0 : 0.25)
        .disabled(bumper.charges <= 0 || gameOver)
    }

    private func bumperColor(_ value: Int) -> Color {
        switch value {
        case 10: return .blue
        case 25: return .green
        case 50: return .orange
        default: return .purple
        }
    }

    private func bumperSize(_ value: Int) -> CGFloat {
        switch value {
        case 10: return 80
        case 25: return 64
        case 50: return 52
        default: return 44
        }
    }

    private func hitBumper(_ i: Int) {
        guard bumpers[i].charges > 0, !gameOver else { return }
        bumpers[i].charges -= 1
        comboCount += 1
        multiplier = min(8, 1 + comboCount / 3)
        let pts = bumpers[i].value * multiplier
        score += pts
        withAnimation(.spring(duration: 0.15)) { bumpers[i].flashing = true }
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            await MainActor.run { bumpers[i].flashing = false }
        }
    }

    private func startGame(geo: GeometryProxy) {
        score = 0; timeLeft = 30; gameOver = false; comboCount = 0; multiplier = 1
        let values = [10, 10, 10, 25, 25, 50, 100]
        bumpers = values.map { v in
            Bumper(x: CGFloat.random(in: 0.12...0.88), y: CGFloat.random(in: 0.20...0.85), charges: Int.random(in: 3...8), value: v)
        }
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run {
                    timeLeft = max(0, timeLeft - 0.1)
                    if timeLeft <= 0 { gameOver = true }
                }
            }
        }
    }
}

#Preview { PinballBumperView() }
