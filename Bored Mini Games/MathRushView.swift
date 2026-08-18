//
//  MathRushView.swift
//  Bored Mini Games
//

import SwiftUI

private struct MathQ {
    let prompt: String
    let answer: Int
    let choices: [Int]
}

struct MathRushView: View {
    @State private var question = MathRushView.makeQ()
    @State private var score = 0
    @State private var timeLeft = 60
    @State private var countdown: Timer? = nil
    @State private var running = false
    @State private var gameOver = false
    @State private var flash: Bool? = nil   // true=correct false=wrong

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label("\(score)", systemImage: "star.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.yellow)
                Spacer()
                Label("\(timeLeft)s", systemImage: "timer")
                    .font(.title3.bold())
                    .foregroundStyle(timeLeft <= 10 ? .red : .primary)
            }
            .padding(.horizontal)

            Spacer()

            if running {
                VStack(spacing: 28) {
                    Text(question.prompt)
                        .font(.system(size: 54, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .animation(nil, value: question.prompt)

                    if let correct = flash {
                        Text(correct ? "✓ +1" : "✗")
                            .font(.headline)
                            .foregroundStyle(correct ? .green : .red)
                            .transition(.opacity)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(question.choices, id: \.self) { c in
                            Button { pick(c) } label: {
                                Text("\(c)")
                                    .font(.system(.title2, design: .rounded, weight: .semibold))
                                    .frame(maxWidth: .infinity, minHeight: 62)
                                    .background(Color.secondary.opacity(0.12),
                                                in: RoundedRectangle(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            } else if gameOver {
                VStack(spacing: 14) {
                    Text("Time's up!").font(.largeTitle.bold())
                    Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
                    Button("Play Again") { start() }.buttonStyle(.borderedProminent).font(.headline)
                }
            } else {
                VStack(spacing: 14) {
                    Text("Answer fast!\n60 seconds on the clock.")
                        .font(.title3).multilineTextAlignment(.center).foregroundStyle(.secondary)
                    Button("Start") { start() }.buttonStyle(.borderedProminent).font(.headline)
                }
            }

            Spacer()
        }
        .onDisappear { countdown?.invalidate() }
    }

    private func start() {
        score = 0; timeLeft = 60; gameOver = false; running = true
        question = Self.makeQ(); flash = nil
        countdown?.invalidate()
        countdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 { timeLeft -= 1 }
            else { countdown?.invalidate(); running = false; gameOver = true; HighScoreStore.save(score, for: .mathRush) }
        }
    }

    private func pick(_ c: Int) {
        let ok = c == question.answer
        if ok { score += 1 }
        withAnimation(.easeInOut(duration: 0.2)) { flash = ok }
        question = Self.makeQ()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation { flash = nil }
        }
    }

    private static func makeQ() -> MathQ {
        let kind = Int.random(in: 0...2)
        let ans: Int; let prompt: String
        switch kind {
        case 0:
            let a = Int.random(in: 3...25), b = Int.random(in: 3...25)
            ans = a + b; prompt = "\(a) + \(b) = ?"
        case 1:
            let a = Int.random(in: 10...40), b = Int.random(in: 3...15)
            ans = a - b; prompt = "\(a) − \(b) = ?"
        default:
            let a = Int.random(in: 2...9), b = Int.random(in: 2...9)
            ans = a * b; prompt = "\(a) × \(b) = ?"
        }
        var set = Set([ans])
        while set.count < 4 {
            let delta = [-3, -2, -1, 1, 2, 3, 4, -4, 5, -5, 6, -6, 10, -10].randomElement()!
            let cand = ans + delta
            if cand > 0 { set.insert(cand) }
        }
        return MathQ(prompt: prompt, answer: ans, choices: set.shuffled())
    }
}

#Preview { MathRushView() }
