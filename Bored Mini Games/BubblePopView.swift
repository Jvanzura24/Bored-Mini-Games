//
//  BubblePopView.swift
//  Bored Mini Games
//

import SwiftUI

private struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let radius: CGFloat
    let color: Color
    let speed: CGFloat
}

private let kBubbleDuration = 30
private let kBubbleColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .cyan, .yellow]

struct BubblePopView: View {
    @State private var bubbles: [Bubble] = []
    @State private var score = 0
    @State private var timeLeft = kBubbleDuration
    @State private var running = false
    @State private var gameOver = false
    @State private var canvasSize: CGSize = .zero
    @State private var gameTimer: Timer? = nil
    @State private var spawnTimer: Timer? = nil
    @State private var moveTimer: Timer? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.clear

                ForEach(bubbles) { b in
                    Circle()
                        .fill(b.color.opacity(0.72))
                        .frame(width: b.radius * 2, height: b.radius * 2)
                        .overlay(Circle().stroke(b.color.opacity(0.9), lineWidth: 2))
                        .position(x: b.x, y: b.y)
                        .onTapGesture { pop(id: b.id) }
                }

                VStack {
                    HStack {
                        Label("\(score)", systemImage: "hand.tap.fill")
                            .font(.title2.bold())
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
                                Text("Time's up!").font(.largeTitle.bold())
                                Text("Popped \(score) bubbles").foregroundStyle(.secondary)
                            } else {
                                Text("Pop the rising bubbles\nbefore they escape!")
                                    .multilineTextAlignment(.center).foregroundStyle(.secondary)
                            }
                            Button(gameOver ? "Play Again" : "Start") {
                                startGame(size: geo.size)
                            }
                            .buttonStyle(.borderedProminent).font(.headline)
                        }
                        .padding(22)
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
        bubbles = []
        score = 0
        timeLeft = kBubbleDuration
        gameOver = false
        running = true
        stopAll()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeLeft -= 1
            if timeLeft <= 0 { stopAll(); running = false; gameOver = true; HighScoreStore.save(score, for: .bubblePop) }
        }

        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
            spawnBubble(in: canvasSize)
        }

        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
            for i in bubbles.indices { bubbles[i].y -= bubbles[i].speed }
            bubbles.removeAll { $0.y < -70 }
        }
    }

    private func spawnBubble(in size: CGSize) {
        let r = CGFloat.random(in: 22...44)
        let bubble = Bubble(
            x: .random(in: r...(size.width - r)),
            y: size.height + r + 10,
            radius: r,
            color: kBubbleColors.randomElement()!,
            speed: .random(in: 1.4...3.2)
        )
        bubbles.append(bubble)
    }

    private func pop(id: UUID) {
        bubbles.removeAll { $0.id == id }
        score += 1
    }

    private func stopAll() {
        gameTimer?.invalidate(); gameTimer = nil
        spawnTimer?.invalidate(); spawnTimer = nil
        moveTimer?.invalidate(); moveTimer = nil
    }
}

#Preview { BubblePopView() }
