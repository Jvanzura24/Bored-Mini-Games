import SwiftUI

struct WordScrambleView: View {
    private let words = [
        "APPLE","BRAIN","CHAIR","DANCE","EAGLE","FLAME","GLOBE","HEART","IMAGE","JUDGE",
        "KNIFE","LEMON","MUSIC","NIGHT","OCEAN","PIANO","QUEEN","RIVER","STONE","TIGER",
        "ULTRA","VOICE","WATER","XENON","YACHT","ZEBRA","BLAST","CLOUD","DREAM","EARTH",
        "FROST","GRANT","HOUSE","INPUT","JEWEL","KNACK","LIGHT","MOUNT","NORTH","OTTER",
        "PLANT","QUICK","ROBIN","SHADE","TREND","UNCLE","VISIT","WRIST","YIELD","ZONAL",
        "AMBER","BENCH","CREAM","DRILL","ELDER","FEAST","GLIDE","HABIT","IVORY","JOUST",
        "KNOCK","LUNAR","MAPLE","NOVEL","OLIVE","PRISM","QUEST","RANCH","SHONE","TOAST",
        "UNTIL","VAPOR","WHEAT","XYLEM","YEAST","ZILCH","BLAZE","CHORD","DUSTY","EMBER",
    ]

    @State private var target = ""
    @State private var scrambled = ""
    @State private var input = ""
    @State private var score = 0
    @State private var streak = 0
    @State private var feedback: Feedback? = nil
    @State private var skipsLeft = 3

    private enum Feedback { case correct, wrong }

    var body: some View {
        VStack(spacing: 28) {
            hud

            Spacer()

            VStack(spacing: 20) {
                if let fb = feedback {
                    Text(fb == .correct ? "✓ Correct!" : "✗ It was: \(target)")
                        .font(.title2.bold())
                        .foregroundStyle(fb == .correct ? .green : .red)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(" ").font(.title2)
                }

                Text("Unscramble this word:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(scrambled)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .tracking(8)

                letterInput
            }

            Spacer()

            HStack {
                Button("Skip (\(skipsLeft))") { skip() }
                    .foregroundStyle(.secondary)
                    .disabled(skipsLeft <= 0)
                Spacer()
                Button("Submit") { submit() }
                    .buttonStyle(.borderedProminent)
                    .disabled(input.count != target.count)
            }
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear { nextWord() }
    }

    private var hud: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
            Spacer()
            if streak >= 3 { Label("×\(streak)", systemImage: "flame.fill").foregroundStyle(.orange) }
        }
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private var letterInput: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<target.count, id: \.self) { i in
                    let ch = i < input.count ? String(Array(input)[i]) : "_"
                    Text(ch)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .frame(width: 44, height: 50)
                        .background(i < input.count ? Color.blue.opacity(0.15) : Color(.systemGray5),
                                    in: RoundedRectangle(cornerRadius: 10))
                }
            }

            HStack(spacing: 0) {
                Button(action: { if !input.isEmpty { input.removeLast() } }) {
                    Image(systemName: "delete.left")
                        .frame(width: 50, height: 44)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 24)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), id: \.self) { ch in
                    Button {
                        if input.count < target.count { input.append(ch) }
                    } label: {
                        Text(String(ch))
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func submit() {
        if input == target {
            streak += 1
            score += max(1, streak)
            withAnimation { feedback = .correct }
        } else {
            streak = 0
            withAnimation { feedback = .wrong }
        }
        Task {
            try? await Task.sleep(for: .seconds(1))
            await MainActor.run { withAnimation { feedback = nil }; nextWord() }
        }
    }

    private func skip() {
        guard skipsLeft > 0 else { return }
        skipsLeft -= 1; streak = 0
        nextWord()
    }

    private func nextWord() {
        target = words.randomElement()!
        scrambled = String(target.shuffled())
        while scrambled == target { scrambled = String(target.shuffled()) }
        input = ""
    }
}

#Preview { WordScrambleView() }
