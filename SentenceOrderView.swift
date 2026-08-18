import SwiftUI

// Put the scrambled sentence back in the correct order.
struct SentenceOrderView: View {
    private let sentences: [[String]] = [
        ["The", "cat", "sat", "on", "the", "mat"],
        ["She", "sells", "seashells", "by", "the", "shore"],
        ["Quick", "brown", "fox", "jumps", "high"],
        ["The", "sun", "rises", "in", "the", "east"],
        ["All", "that", "glitters", "is", "not", "gold"],
        ["Every", "cloud", "has", "a", "silver", "lining"],
        ["Actions", "speak", "louder", "than", "words"],
        ["Time", "flies", "like", "an", "arrow"],
        ["A", "rolling", "stone", "gathers", "no", "moss"],
        ["Look", "before", "you", "leap"],
        ["Birds", "of", "a", "feather", "flock", "together"],
        ["The", "early", "bird", "catches", "the", "worm"],
        ["Practice", "makes", "perfect"],
        ["Laughter", "is", "the", "best", "medicine"],
        ["Two", "heads", "are", "better", "than", "one"],
        ["Where", "there", "is", "smoke", "there", "is", "fire"],
        ["Slow", "and", "steady", "wins", "the", "race"],
        ["Better", "late", "than", "never"],
    ]

    @State private var target: [String] = []
    @State private var tiles: [String] = []
    @State private var chosen: [String] = []
    @State private var score = 0
    @State private var round = 0
    @State private var feedback: Bool? = nil
    @State private var queue: [[String]] = []

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                Text("Round \(round)").font(.headline)
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            feedbackBanner

            Spacer()

            VStack(spacing: 16) {
                Text("Arrange into a sentence:")
                    .font(.headline).foregroundStyle(.secondary)

                chosenArea

                Divider().padding(.horizontal, 24)

                tilePool
            }
            .padding(.horizontal, 16)

            Spacer()

            Button("Submit") { submit() }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .disabled(chosen.count != target.count)
                .padding(.bottom, 16)
        }
        .onAppear { newRound() }
    }

    private var feedbackBanner: some View {
        Group {
            if let fb = feedback {
                Text(fb ? "Correct! ✓" : "Wrong — try next one")
                    .font(.headline)
                    .foregroundStyle(fb ? .green : .red)
            } else {
                Text(" ")
            }
        }
        .frame(height: 28)
    }

    private var chosenArea: some View {
        FlowLayout(tiles: chosen) { word in
            Button { unchoose(word) } label: {
                Text(word)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.blue.opacity(0.2), in: Capsule())
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: 60)
        .padding(.horizontal, 8)
    }

    private var tilePool: some View {
        FlowLayout(tiles: tiles) { word in
            Button { choose(word) } label: {
                Text(word)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color(.systemGray5), in: Capsule())
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .frame(minHeight: 60)
        .padding(.horizontal, 8)
    }

    private func choose(_ word: String) {
        if let idx = tiles.firstIndex(of: word) {
            tiles.remove(at: idx)
            chosen.append(word)
        }
    }

    private func unchoose(_ word: String) {
        if let idx = chosen.firstIndex(of: word) {
            chosen.remove(at: idx)
            tiles.append(word)
        }
    }

    private func submit() {
        let correct = chosen == target
        withAnimation { feedback = correct }
        if correct { score += 1 }
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run { feedback = nil; newRound() }
        }
    }

    private func newRound() {
        if queue.isEmpty { queue = sentences.shuffled() }
        target = queue.removeFirst()
        tiles = target.shuffled()
        while tiles == target { tiles = target.shuffled() }
        chosen = []
        round += 1
    }
}

// Simple flow layout for word tiles
private struct FlowLayout: View {
    let tiles: [String]
    let content: (String) -> AnyView

    init(tiles: [String], @ViewBuilder content: @escaping (String) -> some View) {
        self.tiles = tiles
        self.content = { AnyView(content($0)) }
    }

    var body: some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(tiles, id: \.self) { word in
                    content(word)
                        .alignmentGuide(.leading) { d in
                            if width + d.width > geo.size.width - 16 {
                                width = 0; height -= d.height + 8
                            }
                            let result = width
                            if word == tiles.last { width = 0 } else { width += d.width + 8 }
                            return -result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if word == tiles.last { height = 0 }
                            return result
                        }
                }
            }
        }
    }
}

#Preview { SentenceOrderView() }
