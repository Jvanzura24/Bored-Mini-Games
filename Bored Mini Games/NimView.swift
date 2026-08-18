import SwiftUI

struct NimView: View {
    @State private var sticks = 13
    @State private var playerWins = 0
    @State private var cpuWins = 0
    @State private var phase: Phase = .playerTurn
    @State private var message = ""
    @State private var gameOver = false

    private enum Phase { case playerTurn, cpuTurn, over }

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 0) {
                Spacer()
                scoreBlock("You", playerWins, .blue)
                Spacer()
                Text("vs").font(.title2).foregroundStyle(.secondary)
                Spacer()
                scoreBlock("CPU", cpuWins, .red)
                Spacer()
            }
            .padding(.top, 8)

            Spacer()

            sticksView

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if phase == .playerTurn && !gameOver {
                HStack(spacing: 16) {
                    ForEach([1, 2, 3], id: \.self) { n in
                        Button("Take \(n)") { take(n) }
                            .buttonStyle(.borderedProminent)
                            .font(.title3.bold())
                            .tint(.blue)
                            .disabled(n > sticks)
                    }
                }
            }

            if phase == .cpuTurn && !gameOver {
                ProgressView().tint(.orange)
            }

            if gameOver {
                Button("New Game") { reset() }
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
            }

            Spacer()
        }
        .onAppear { reset() }
    }

    private func scoreBlock(_ label: String, _ n: Int, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.headline).foregroundStyle(color)
            Text("\(n)").font(.system(size: 44, weight: .black, design: .rounded))
        }
    }

    private var sticksView: some View {
        VStack(spacing: 8) {
            Text("\(sticks) stick\(sticks == 1 ? "" : "s") left")
                .font(.subheadline).foregroundStyle(.secondary)
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(10), spacing: 8), count: min(sticks, 13)),
                spacing: 8
            ) {
                ForEach(0..<sticks, id: \.self) { _ in
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: 10, height: 52)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    private func take(_ n: Int) {
        guard phase == .playerTurn && n <= sticks else { return }
        sticks -= n
        if sticks == 0 {
            cpuWins += 1
            message = "You took the last stick — CPU wins!"
            gameOver = true; return
        }
        message = "CPU is thinking…"; phase = .cpuTurn
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            await MainActor.run { cpuMove() }
        }
    }

    private func cpuMove() {
        // Optimal Nim strategy: leave 4k+1 sticks for the opponent
        let r = sticks % 4
        let n = r == 0 ? 1 : r - 1 == 0 ? 1 : r - 1
        let actual = max(1, min(n, min(3, sticks)))
        sticks -= actual
        if sticks == 0 {
            playerWins += 1
            message = "CPU took the last stick — you win! 🎉"
            gameOver = true; return
        }
        message = "CPU took \(actual). Your turn."
        phase = .playerTurn
    }

    private func reset() {
        sticks = [9, 11, 13, 15, 17].randomElement()!
        phase = .playerTurn; gameOver = false
        message = "Take 1, 2, or 3 sticks. Don't take the last one!"
    }
}

#Preview { NimView() }
