import SwiftUI

struct TapSequenceView: View {
    private enum Phase { case idle, showing, inputting, correct, wrong }

    @State private var sequence: [Int] = []
    @State private var input: [Int] = []
    @State private var phase: Phase = .idle
    @State private var score = 0
    @State private var lit: Int? = nil
    @State private var showIdx = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Score: \(score)").font(.headline)
                Spacer()
                Text("Level \(max(1, sequence.count))").font(.headline)
            }
            .padding(.horizontal, 24).padding(.top, 8)

            statusText.padding(.vertical, 4)

            buttonGrid

            Spacer()

            if phase == .idle || phase == .correct || phase == .wrong {
                Button(
                    phase == .idle ? "Start" :
                    phase == .correct ? "Next Level →" : "Try Again"
                ) {
                    if phase == .correct { addAndShow() } else { startGame() }
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .padding(.bottom, 24)
            }
        }
        .onAppear { startGame() }
    }

    private var statusText: some View {
        Group {
            switch phase {
            case .idle:      Text("Watch, then repeat the order").foregroundStyle(.secondary)
            case .showing:   Text("Watch carefully…").foregroundStyle(.secondary)
            case .inputting: Text("Your turn! \(input.count) / \(sequence.count)").foregroundStyle(.blue)
            case .correct:   Text("Correct! ✓").foregroundStyle(.green)
            case .wrong:     Text("Wrong! ✗").foregroundStyle(.red)
            }
        }
        .font(.headline)
    }

    private var buttonGrid: some View {
        VStack(spacing: 12) {
            ForEach([[1, 2, 3], [4, 5, 6]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { n in
                        Button { tap(n) } label: {
                            Text("\(n)")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(
                                    lit == n ? Color.yellow : Color.blue.opacity(0.18),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(phase != .inputting)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func tap(_ n: Int) {
        flash(n)
        input.append(n)
        if n != sequence[input.count - 1] { withAnimation { phase = .wrong }; return }
        if input.count == sequence.count { score += 1; withAnimation { phase = .correct } }
    }

    private func flash(_ n: Int, completion: (() -> Void)? = nil) {
        withAnimation { lit = n }
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            await MainActor.run { lit = nil; completion?() }
        }
    }

    private func addAndShow() {
        sequence.append(Int.random(in: 1...6))
        input = []; showIdx = 0; playNext()
    }

    private func playNext() {
        phase = .showing
        guard showIdx < sequence.count else {
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                await MainActor.run { input = []; phase = .inputting }
            }
            return
        }
        let n = sequence[showIdx]; showIdx += 1
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            await MainActor.run { flash(n) { self.playNext() } }
        }
    }

    private func startGame() {
        score = 0
        sequence = [Int.random(in: 1...6)]
        input = []; showIdx = 0
        playNext()
    }
}

#Preview { TapSequenceView() }
