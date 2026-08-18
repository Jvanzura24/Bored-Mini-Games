//
//  TowerStackView.swift
//  Bored Mini Games
//
//  Stack sliding blocks as precisely as possible.
//  The part that hangs over the edge is cut off; the platform shrinks each turn.
//

import SwiftUI

private let kBlockH: CGFloat = 38
private let kPalette: [Color] = [.red, .orange, .yellow, .green, .teal, .blue, .purple, .pink]

struct TowerStackView: View {
    // Each block stored as (centerX offset from screen center, width)
    @State private var stack: [(offset: CGFloat, width: CGFloat)] = []
    @State private var platformOffset: CGFloat = 0
    @State private var platformWidth: CGFloat = 0
    @State private var direction: CGFloat = 1
    @State private var speed: CGFloat = 2.2
    @State private var score = 0
    @State private var running = false
    @State private var gameOver = false
    @State private var canvasWidth: CGFloat = 0
    @State private var mover: Timer? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color.clear

                // Rendered stack (drawn bottom-up, clipped to canvas)
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ForEach(stack.indices, id: \.self) { i in
                        let b = stack[i]
                        Rectangle()
                            .fill(kPalette[i % kPalette.count])
                            .frame(width: max(b.width, 0), height: kBlockH)
                            .offset(x: b.offset)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .clipped()

                // Moving platform
                if running {
                    Rectangle()
                        .fill(kPalette[stack.count % kPalette.count].opacity(0.9))
                        .frame(width: max(platformWidth, 0), height: kBlockH)
                        .offset(x: platformOffset)
                        .padding(.bottom, CGFloat(stack.count) * kBlockH)
                }

                // UI overlay
                VStack {
                    Text("Score: \(score)")
                        .font(.title2.bold())
                        .padding(.top, 16)

                    Spacer()

                    if gameOver {
                        VStack(spacing: 14) {
                            Text("Game Over!").font(.largeTitle.bold()).foregroundStyle(.red)
                            Text("Score: \(score)").foregroundStyle(.secondary)
                            Button("Play Again") { setup(geo: geo) }
                                .buttonStyle(.borderedProminent).font(.headline)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.bottom, 50)
                    } else if !running {
                        VStack(spacing: 14) {
                            Text("Tap to drop each block.\nPrecision keeps the stack wide!")
                                .multilineTextAlignment(.center).foregroundStyle(.secondary)
                            Button("Start") { setup(geo: geo) }
                                .buttonStyle(.borderedProminent).font(.headline)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.bottom, 50)
                    } else {
                        Text("Tap to drop!").font(.headline).foregroundStyle(.secondary)
                            .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .contentShape(Rectangle())
            .onTapGesture { if running { drop() } }
            .onAppear { canvasWidth = geo.size.width }
        }
        .onDisappear { mover?.invalidate() }
    }

    private func setup(geo: GeometryProxy) {
        canvasWidth = geo.size.width
        let baseW = min(geo.size.width * 0.55, 180)
        stack = [(offset: 0, width: baseW)]
        platformWidth = baseW
        platformOffset = -baseW
        direction = 1
        speed = 2.2
        score = 0
        gameOver = false
        running = true

        mover?.invalidate()
        mover = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            guard running else { return }
            platformOffset += speed * direction
            let half = platformWidth / 2
            let limit = canvasWidth * 0.62
            if platformOffset + half >= limit { direction = -1 }
            else if platformOffset - half <= -limit { direction = 1 }
        }
    }

    private func drop() {
        guard !stack.isEmpty else { return }
        let top = stack.last!

        let pL = platformOffset - platformWidth / 2
        let pR = platformOffset + platformWidth / 2
        let bL = top.offset - top.width / 2
        let bR = top.offset + top.width / 2

        let oL = max(pL, bL)
        let oR = min(pR, bR)
        let overlap = oR - oL

        guard overlap > 2 else {
            mover?.invalidate()
            running = false
            gameOver = true
            return
        }

        let newOffset = (oL + oR) / 2
        stack.append((offset: newOffset, width: overlap))
        score += 1

        if overlap < 8 {
            mover?.invalidate()
            running = false
            gameOver = true
            return
        }

        platformWidth = overlap
        platformOffset = newOffset - overlap * 2 * direction
        speed = min(speed + 0.18, 9)
    }
}

#Preview { TowerStackView() }
