import SwiftUI

struct RockPaperScissorsView: View {
    private enum Move: String, CaseIterable {
        case rock = "Rock", paper = "Paper", scissors = "Scissors"

        var icon: String {
            switch self {
            case .rock: "hand.raised.fill"
            case .paper: "doc.fill"
            case .scissors: "scissors"
            }
        }

        func beats(_ other: Move) -> Bool {
            (self == .rock && other == .scissors) ||
            (self == .paper && other == .rock) ||
            (self == .scissors && other == .paper)
        }
    }

    @State private var playerScore = 0
    @State private var cpuScore = 0
    @State private var playerMove: Move? = nil
    @State private var cpuMove: Move? = nil
    @State private var roundResult = ""
    @State private var gameOver = false
    private let winScore = 5

    var body: some View {
        VStack(spacing: 0) {
            scoreBoard
            Spacer()
            if gameOver {
                gameOverView
            } else {
                roundView
                Spacer()
                moveButtons
            }
            Spacer()
        }
    }

    private var scoreBoard: some View {
        HStack(spacing: 40) {
            VStack(spacing: 4) {
                Text("You").font(.headline).foregroundStyle(.secondary)
                Text("\(playerScore)").font(.system(size: 52, weight: .black, design: .rounded))
            }
            Text("vs").font(.title2).foregroundStyle(.secondary)
            VStack(spacing: 4) {
                Text("CPU").font(.headline).foregroundStyle(.secondary)
                Text("\(cpuScore)").font(.system(size: 52, weight: .black, design: .rounded))
            }
        }
        .padding(.top, 16)
    }

    private var roundView: some View {
        VStack(spacing: 16) {
            if let pm = playerMove, let cm = cpuMove {
                HStack(spacing: 32) {
                    moveChip(pm, label: "You")
                    Image(systemName: "arrow.left.arrow.right").foregroundStyle(.secondary)
                    moveChip(cm, label: "CPU")
                }
                Text(roundResult)
                    .font(.title2.bold())
                    .foregroundStyle(
                        roundResult == "You win!" ? .green :
                        roundResult == "CPU wins!" ? .red : .orange
                    )
            } else {
                Text("Make your move")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 120)
    }

    private func moveChip(_ move: Move, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: move.icon).font(.system(size: 28))
            Text(move.rawValue).font(.caption.bold())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(width: 80)
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var moveButtons: some View {
        VStack(spacing: 12) {
            Text("First to \(winScore) wins").font(.caption).foregroundStyle(.secondary)
            HStack(spacing: 12) {
                ForEach(Move.allCases, id: \.rawValue) { move in
                    Button {
                        play(move)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: move.icon).font(.system(size: 30))
                            Text(move.rawValue).font(.caption.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: 88)
                        .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text(playerScore >= winScore ? "You Win! 🎉" : "CPU Wins!")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Button("Play Again") {
                playerScore = 0; cpuScore = 0
                playerMove = nil; cpuMove = nil
                roundResult = ""; gameOver = false
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
    }

    private func play(_ move: Move) {
        let cpu = Move.allCases.randomElement()!
        playerMove = move; cpuMove = cpu
        if move.beats(cpu) {
            playerScore += 1; roundResult = "You win!"
        } else if cpu.beats(move) {
            cpuScore += 1; roundResult = "CPU wins!"
        } else {
            roundResult = "Draw!"
        }
        if playerScore >= winScore || cpuScore >= winScore { gameOver = true }
    }
}

#Preview { RockPaperScissorsView() }
