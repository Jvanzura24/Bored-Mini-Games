//
//  PaddleBallView.swift
//  Bored Mini Games
//
//  A single-player arcade rally game: drag the bottom paddle to return the
//  ball past the computer's paddle at the top. First to 7 points wins.
//

import SwiftUI

struct PaddleBallView: View {
    private enum PlayState {
        case waitingToServe
        case playing
        case gameOver
    }

    @State private var ballPosition: CGPoint = .zero
    @State private var ballVelocity: CGVector = .zero
    @State private var playerX: CGFloat = 0
    @State private var computerX: CGFloat = 0
    @State private var playerScore = 0
    @State private var computerScore = 0
    @State private var playState: PlayState = .waitingToServe
    @State private var fieldSize: CGSize = .zero
    @State private var serveDown = true
    @AppStorage("difficulty.paddleBall") private var difficulty: Difficulty = .medium

    private let paddleWidth: CGFloat = 90
    private let paddleHeight: CGFloat = 14
    private let ballSize: CGFloat = 16
    private let winningScore = 7

    private var computerSpeed: CGFloat {
        switch difficulty {
        case .easy: 2.6
        case .medium: 3.4
        case .hard: 4.5
        }
    }

    private var maxBallSpeed: CGFloat {
        switch difficulty {
        case .easy: 8
        case .medium: 9
        case .hard: 11
        }
    }

    private var playerPaddleY: CGFloat { fieldSize.height - 50 }
    private var computerPaddleY: CGFloat { 50 }

    var body: some View {
        VStack(spacing: 10) {
            DifficultyPicker(difficulty: $difficulty)
                .padding(.top, 8)
            playField
        }
    }

    private var playField: some View {
        GeometryReader { geo in
            ZStack {
                Color.black

                // Center line and scores
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(height: 2)
                HStack(spacing: 40) {
                    Text("\(computerScore)")
                    Text("\(playerScore)")
                }
                .font(.system(size: 44, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.35))

                // Computer paddle
                Capsule()
                    .fill(.red)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: computerX, y: computerPaddleY)

                // Player paddle
                Capsule()
                    .fill(.cyan)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(x: playerX, y: playerPaddleY)

                // Ball
                Circle()
                    .fill(.white)
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)

                if playState == .waitingToServe {
                    Text("Tap to serve\nDrag to move your paddle")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.top, 120)
                }

                if playState == .gameOver {
                    VStack(spacing: 16) {
                        Text(playerScore > computerScore ? "You Win! 🏆" : "Computer Wins")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Button("Play Again") { restartMatch() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        playerX = min(max(value.location.x, paddleWidth / 2),
                                      geo.size.width - paddleWidth / 2)
                    }
            )
            .onTapGesture {
                if playState == .waitingToServe { serve() }
            }
            .onChange(of: geo.size, initial: true) {
                fieldSize = geo.size
                resetPositions()
            }
            .task {
                // ~60 fps game loop; ends automatically when the view goes away.
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(16))
                    step()
                }
            }
        }
        .clipped()
    }

    private func resetPositions() {
        playerX = fieldSize.width / 2
        computerX = fieldSize.width / 2
        ballPosition = CGPoint(x: fieldSize.width / 2, y: fieldSize.height / 2)
        ballVelocity = .zero
    }

    private func restartMatch() {
        playerScore = 0
        computerScore = 0
        resetPositions()
        serveDown = true
        playState = .waitingToServe
    }

    private func serve() {
        ballPosition = CGPoint(x: fieldSize.width / 2, y: fieldSize.height / 2)
        ballVelocity = CGVector(dx: CGFloat.random(in: -3...3),
                                dy: serveDown ? 5 : -5)
        playState = .playing
    }

    private func step() {
        guard playState == .playing, fieldSize != .zero else { return }

        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy

        // Side walls
        if ballPosition.x < ballSize / 2 {
            ballPosition.x = ballSize / 2
            ballVelocity.dx = abs(ballVelocity.dx)
        } else if ballPosition.x > fieldSize.width - ballSize / 2 {
            ballPosition.x = fieldSize.width - ballSize / 2
            ballVelocity.dx = -abs(ballVelocity.dx)
        }

        // Computer tracks the ball with limited speed so it can be beaten
        let delta = ballPosition.x - computerX
        computerX += min(max(delta, -computerSpeed), computerSpeed)
        computerX = min(max(computerX, paddleWidth / 2), fieldSize.width - paddleWidth / 2)

        bounceOffPaddle(atY: playerPaddleY, paddleX: playerX, movingDown: true)
        bounceOffPaddle(atY: computerPaddleY, paddleX: computerX, movingDown: false)

        // Scoring
        if ballPosition.y > fieldSize.height + ballSize {
            computerScore += 1
            serveDown = true
            pointScored()
        } else if ballPosition.y < -ballSize {
            playerScore += 1
            serveDown = false
            pointScored()
        }
    }

    private func bounceOffPaddle(atY paddleY: CGFloat, paddleX: CGFloat, movingDown: Bool) {
        let approaching = movingDown ? ballVelocity.dy > 0 : ballVelocity.dy < 0
        let reach = paddleHeight / 2 + ballSize / 2
        guard approaching,
              abs(ballPosition.y - paddleY) <= reach,
              abs(ballPosition.x - paddleX) <= paddleWidth / 2 + ballSize / 2
        else { return }

        let newSpeed = min(abs(ballVelocity.dy) * 1.04, maxBallSpeed)
        ballVelocity.dy = movingDown ? -newSpeed : newSpeed
        // Hitting off-center adds angle
        let offset = (ballPosition.x - paddleX) / (paddleWidth / 2)
        ballVelocity.dx = min(max(ballVelocity.dx + offset * 2.5, -maxBallSpeed), maxBallSpeed)
    }

    private func pointScored() {
        ballVelocity = .zero
        ballPosition = CGPoint(x: fieldSize.width / 2, y: fieldSize.height / 2)
        if playerScore >= winningScore || computerScore >= winningScore {
            playState = .gameOver
            return
        }
        playState = .waitingToServe
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            if playState == .waitingToServe { serve() }
        }
    }
}

#Preview {
    PaddleBallView()
}
