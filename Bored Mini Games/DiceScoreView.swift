import SwiftUI

struct DiceScoreView: View {
    private struct Category: Identifiable {
        let id: Int
        let name: String
        var score: Int? = nil
        let evaluate: ([Int]) -> Int
    }

    @State private var dice = [1, 2, 3, 4, 5, 6]
    @State private var held = Set<Int>()
    @State private var rollsLeft = 3
    @State private var categories: [Category] = Self.makeCategories()
    @State private var totalScore = 0
    @State private var gameOver = false
    @State private var rolling = false

    var filledCount: Int { categories.filter { $0.score != nil }.count }

    var body: some View {
        VStack(spacing: 0) {
            header
            diceRow
            rollButton
            Divider().padding(.vertical, 8)
            categoryList
        }
        .onAppear { rollDice() }
    }

    private var header: some View {
        HStack {
            Text("Total: \(totalScore)").font(.title2.bold())
            Spacer()
            Text("\(filledCount)/\(categories.count) filled").foregroundStyle(.secondary)
            Spacer()
            Text("Rolls: \(rollsLeft)").font(.headline)
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
    }

    private var diceRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { i in
                Button {
                    if rollsLeft < 3 { if held.contains(i) { held.remove(i) } else { held.insert(i) } }
                } label: {
                    Text(diceFace(dice[i]))
                        .font(.system(size: 36))
                        .frame(width: 50, height: 50)
                        .background(
                            held.contains(i) ? Color.yellow.opacity(0.3) : Color(.systemGray5),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(held.contains(i) ? Color.yellow : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(rolling && !held.contains(i) ? 1.15 : 1.0)
                .animation(.spring(duration: 0.1).repeatCount(rolling && !held.contains(i) ? 3 : 0), value: rolling)
            }
        }
        .padding(.horizontal, 16)
    }

    private var rollButton: some View {
        Button {
            rollDice()
        } label: {
            Text(rollsLeft == 3 ? "Roll All" : "Re-Roll (\(rollsLeft) left)")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(rollsLeft > 0 ? Color.blue : Color.gray, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20).padding(.vertical, 8)
        .disabled(rollsLeft <= 0 || gameOver)
    }

    private var categoryList: some View {
        ScrollView {
            VStack(spacing: 4) {
                if gameOver {
                    Text("Final: \(totalScore) pts")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                        .padding(.bottom, 4)
                    Button("New Game") { newGame() }
                        .buttonStyle(.borderedProminent).font(.headline)
                        .padding(.bottom, 8)
                }
                ForEach(categories) { cat in
                    categoryRow(cat)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 20)
        }
    }

    private func categoryRow(_ cat: Category) -> some View {
        HStack {
            Text(cat.name).font(.subheadline)
            Spacer()
            if let s = cat.score {
                Text("\(s) pts").font(.subheadline.bold()).foregroundStyle(.secondary)
            } else {
                let preview = cat.evaluate(dice)
                Button {
                    scoreCategory(cat.id, value: preview)
                } label: {
                    Text(rollsLeft < 3 ? "\(preview) pts" : "—")
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .disabled(rollsLeft == 3)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func rollDice() {
        guard rollsLeft > 0 else { return }
        rolling = true
        for i in 0..<6 { if !held.contains(i) { dice[i] = Int.random(in: 1...6) } }
        rollsLeft -= 1
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            await MainActor.run { rolling = false }
        }
    }

    private func scoreCategory(_ id: Int, value: Int) {
        if let idx = categories.firstIndex(where: { $0.id == id }) {
            categories[idx].score = value
            totalScore += value
        }
        if categories.allSatisfy({ $0.score != nil }) { gameOver = true; return }
        rollsLeft = 3; held = []
        rollDice()
    }

    private func newGame() {
        categories = Self.makeCategories()
        totalScore = 0; gameOver = false; rollsLeft = 3; held = []
        rollDice()
    }

    private func diceFace(_ n: Int) -> String {
        ["⚀","⚁","⚂","⚃","⚄","⚅"][n - 1]
    }

    private static func makeCategories() -> [Category] {
        [
            Category(id: 0,  name: "Ones")              { $0.filter { $0 == 1 }.reduce(0, +) },
            Category(id: 1,  name: "Twos")              { $0.filter { $0 == 2 }.reduce(0, +) },
            Category(id: 2,  name: "Threes")            { $0.filter { $0 == 3 }.reduce(0, +) },
            Category(id: 3,  name: "Fours")             { $0.filter { $0 == 4 }.reduce(0, +) },
            Category(id: 4,  name: "Fives")             { $0.filter { $0 == 5 }.reduce(0, +) },
            Category(id: 5,  name: "Sixes")             { $0.filter { $0 == 6 }.reduce(0, +) },
            Category(id: 6,  name: "Three of a Kind")   { d in
                let counts = Dictionary(grouping: d, by: { $0 }).mapValues(\.count)
                return counts.values.contains { $0 >= 3 } ? d.reduce(0, +) : 0
            },
            Category(id: 7,  name: "Four of a Kind")    { d in
                let counts = Dictionary(grouping: d, by: { $0 }).mapValues(\.count)
                return counts.values.contains { $0 >= 4 } ? d.reduce(0, +) : 0
            },
            Category(id: 8,  name: "Five of a Kind")    { d in
                let counts = Dictionary(grouping: d, by: { $0 }).mapValues(\.count)
                return counts.values.contains { $0 >= 5 } ? d.reduce(0, +) : 0
            },
            Category(id: 9,  name: "Six of a Kind (50)") { d in
                let counts = Dictionary(grouping: d, by: { $0 }).mapValues(\.count)
                return counts.values.contains(6) ? 50 : 0
            },
            Category(id: 10, name: "Full House (30)")   { d in
                let vals = Dictionary(grouping: d, by: { $0 }).mapValues(\.count).values.sorted()
                return vals == [3, 3] ? 30 : 0
            },
            Category(id: 11, name: "Small Straight (30)") { d in
                let s = Set(d)
                return [[1,2,3,4],[2,3,4,5],[3,4,5,6]].contains { $0.allSatisfy { s.contains($0) } } ? 30 : 0
            },
            Category(id: 12, name: "Large Straight (40)") { d in
                let s = Set(d)
                return (s.isSuperset(of: [1,2,3,4,5]) || s.isSuperset(of: [2,3,4,5,6])) ? 40 : 0
            },
            Category(id: 13, name: "Full Straight (50)") { d in
                Set(d) == [1,2,3,4,5,6] ? 50 : 0
            },
            Category(id: 14, name: "Chance")            { $0.reduce(0, +) },
        ]
    }
}

#Preview { DiceScoreView() }
