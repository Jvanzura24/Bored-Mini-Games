//
//  NumberHuntView.swift
//  Bored Mini Games
//
//  Tap 1 → 15 in ascending order as fast as you can.
//

import SwiftUI

private struct NumTarget: Identifiable {
    let id = UUID()
    let number: Int
    let position: CGPoint
}

struct NumberHuntView: View {
    @State private var targets: [NumTarget] = []
    @State private var nextToTap = 1
    @State private var startTime: Date? = nil
    @State private var finishedTime: Double? = nil
    @State private var best: Double? = nil
    @State private var canvasSize: CGSize = .zero

    private let total = 15

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.clear

                if startTime != nil && finishedTime == nil {
                    ForEach(targets) { t in
                        let isNext = t.number == nextToTap
                        ZStack {
                            Circle()
                                .fill(isNext
                                      ? Color.blue.opacity(0.88)
                                      : Color.secondary.opacity(0.22))
                                .frame(width: 54, height: 54)
                            Text("\(t.number)")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(isNext ? .white : .primary)
                        }
                        .position(t.position)
                        .onTapGesture { tapped(t) }
                        .animation(.spring(response: 0.25), value: isNext)
                    }
                }

                VStack {
                    HStack {
                        if let start = startTime, finishedTime == nil {
                            TimelineView(.animation) { ctx in
                                Text(String(format: "%.1f s", ctx.date.timeIntervalSince(start)))
                                    .font(.title2.bold().monospacedDigit())
                            }
                        } else if let ft = finishedTime {
                            Text(String(format: "%.2f s", ft))
                                .font(.title2.bold().monospacedDigit())
                        } else {
                            Text("0.0 s").font(.title2.bold().monospacedDigit())
                        }
                        Spacer()
                        if let b = best {
                            Text(String(format: "Best: %.2f s", b))
                                .font(.headline).foregroundStyle(.secondary)
                        }
                    }
                    .padding()

                    Spacer()

                    if startTime == nil {
                        VStack(spacing: 16) {
                            Text("Tap 1 → \(total) in order,\nas fast as you can!")
                                .font(.title3).multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                            Button("Start") { beginGame(size: geo.size) }
                                .buttonStyle(.borderedProminent).font(.headline)
                        }
                        .padding(22)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.bottom, 50)
                    } else if let ft = finishedTime {
                        VStack(spacing: 12) {
                            Text("Done! 🎉").font(.largeTitle.bold())
                            Text(String(format: "%.2f seconds", ft)).font(.title2).foregroundStyle(.secondary)
                            if best != nil && abs((best ?? 0) - ft) < 0.01 {
                                Text("New best!").font(.headline).foregroundStyle(.blue)
                            }
                            Button("Play Again") { beginGame(size: geo.size) }
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
    }

    private func beginGame(size: CGSize) {
        canvasSize = size
        nextToTap = 1
        finishedTime = nil
        targets = makeTargets(in: size)
        startTime = .now
    }

    private func makeTargets(in size: CGSize) -> [NumTarget] {
        var placed = [CGPoint]()
        let inset: CGFloat = 50
        let topPad: CGFloat = 90
        return (1...total).map { n in
            var pt = CGPoint.zero
            var tries = 0
            repeat {
                pt = CGPoint(
                    x: .random(in: inset...(size.width - inset)),
                    y: .random(in: topPad...(size.height - inset - 50))
                )
                tries += 1
            } while tries < 60 && placed.contains(where: { hypot($0.x - pt.x, $0.y - pt.y) < 68 })
            placed.append(pt)
            return NumTarget(number: n, position: pt)
        }
    }

    private func tapped(_ target: NumTarget) {
        guard target.number == nextToTap else { return }
        targets.removeAll { $0.id == target.id }
        nextToTap += 1
        if nextToTap > total {
            let elapsed = Date.now.timeIntervalSince(startTime!)
            finishedTime = elapsed
            if best == nil || elapsed < best! { best = elapsed }
            startTime = nil
        }
    }
}

#Preview { NumberHuntView() }
