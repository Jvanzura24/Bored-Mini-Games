//
//  TargetTapView.swift
//  Bored Mini Games
//
//  A target appears with a shrinking countdown ring.
//  Tap it before the ring runs out — bigger = more points.
//  Miss 3 targets and the game ends.
//

import SwiftUI

private let kTargetLife: Double = 2.2
private let kGameDuration = 30

struct TargetTapView: View {
    @State private var targetPos: CGPoint = .zero
    @State private var targetBirth = Date.now
    @State private var score = 0
    @State private var lives = 3
    @State private var timeLeft = kGameDuration
    @State private var running = false
    @State private var gameOver = false
    @State private var canvasSize: CGSize = .zero
    @State private var gameTimer: Timer? = nil
    @State private var watchTimer: Timer? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.clear

                if running {
                    TimelineView(.animation) { ctx in
                        let age = ctx.date.timeIntervalSince(targetBirth)
                        let progress = max(0, 1 - age / kTargetLife)
                        let radius: CGFloat = 36 + progress * 18

                        ZStack {
                            Circle()
                                .fill(Color(hue: 0.02, saturation: 0.85, brightness: 0.9).opacity(0.85))
                                .frame(width: radius * 2, height: radius * 2)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .frame(width: (radius - 6) * 2, height: (radius - 6) * 2)
                        }
                        .position(targetPos)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture(coordinateSpace: .local) { loc in
                        tapAt(loc)
                    }
                }

                VStack {
                    HStack {
                        Label("\(score)", systemImage: "star.fill")
                            .font(.title2.bold()).foregroundStyle(.yellow)
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { i in
                                Image(systemName: i < lives ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                        }
                        Spacer()
                        Label("\(timeLeft)s", systemImage: "timer")
                            .font(.title2.bold())
                            .foregroundStyle(timeLeft <= 10 ? .red : .primary)
                    }
                    .padding(14)
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer()

                    if !running {
                        VStack(spacing: 14) {
                            if gameOver {
                                Text("Game Over!").font(.largeTitle.bold())
                                Text("Score: \(score)").foregroundStyle(.secondary)
                            } else {
                                Text("Tap targets before their\nring runs out.\n3 misses ends the game.")
                                    .multilineTextAlignment(.center).foregroundStyle(.secondary)
                            }
                            Button(gameOver ? "Play Again" : "Start") { startGame(size: geo.size) }
                                .buttonStyle(.borderedProminent).font(.headline)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.bottom, 50)
                    }
                }
            }
            .onAppear { canvasSize = geo.size }
        }
        .onDisappear { stopAll() }
    }

    private func startGame(size: CGSize) {
        canvasSize = size
        score = 0; lives = 3; timeLeft = kGameDuration
        gameOver = false; running = true
        stopAll()
        spawnTarget()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeLeft -= 1
            if timeLeft <= 0 { endGame() }
        }

        watchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let age = Date.now.timeIntervalSince(targetBirth)
            if age >= kTargetLife { missed() }
        }
    }

    private func tapAt(_ loc: CGPoint) {
        let age = Date.now.timeIntervalSince(targetBirth)
        let progress = max(0, 1 - age / kTargetLife)
        let radius: CGFloat = 36 + progress * 18
        guard hypot(loc.x - targetPos.x, loc.y - targetPos.y) <= radius else { return }
        score += max(1, Int(progress * 10))
        spawnTarget()
    }

    private func missed() {
        lives -= 1
        if lives <= 0 { endGame(); return }
        spawnTarget()
    }

    private func spawnTarget() {
        let margin: CGFloat = 70
        let topPad: CGFloat = 110
        targetBirth = .now
        targetPos = CGPoint(
            x: .random(in: margin...(canvasSize.width - margin)),
            y: .random(in: topPad...(canvasSize.height - margin - 60))
        )
    }

    private func endGame() {
        stopAll()
        running = false
        gameOver = true
    }

    private func stopAll() {
        gameTimer?.invalidate(); gameTimer = nil
        watchTimer?.invalidate(); watchTimer = nil
    }
}

#Preview { TargetTapView() }
