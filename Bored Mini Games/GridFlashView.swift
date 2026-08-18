import SwiftUI

struct GridFlashView: View {
    private enum Phase { case idle, showing, guessing, result }

    private let cols = 4
    private var total: Int { cols * cols }

    @State private var phase: Phase = .idle
    @State private var round = 1
    @State private var score = 0
    @State private var litCells: Set<Int> = []
    @State private var selected: Set<Int> = []
    @State private var lastCorrect = false

    private var targetCount: Int { min(round + 2, total) }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Round \(round)").font(.headline)
                Spacer()
                Text("Score: \(score)").font(.headline)
            }
            .padding(.horizontal, 24)

            Text(hintText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .animation(.default, value: phase == .guessing)

            grid
                .padding(.horizontal, 24)

            bottomControls
        }
        .onAppear { startRound() }
    }

    private var hintText: String {
        switch phase {
        case .idle:     return "Get ready…"
        case .showing:  return "Memorize \(targetCount) lit cells!"
        case .guessing: return "Tap \(targetCount - selected.count) more cell(s)"
        case .result:   return lastCorrect ? "Correct! ✓" : "Wrong ✗"
        }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: cols),
            spacing: 8
        ) {
            ForEach(0..<total, id: \.self) { i in
                RoundedRectangle(cornerRadius: 10)
                    .fill(cellColor(i))
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        if phase == .guessing { tap(i) }
                    }
            }
        }
    }

    private func cellColor(_ i: Int) -> Color {
        switch phase {
        case .showing:
            return litCells.contains(i) ? .yellow : Color(.systemGray5)
        case .guessing:
            return selected.contains(i) ? .blue : Color(.systemGray5)
        case .result:
            if litCells.contains(i) && selected.contains(i) { return .green }
            if litCells.contains(i) { return .red }
            if selected.contains(i) { return .orange }
            return Color(.systemGray5)
        default:
            return Color(.systemGray5)
        }
    }

    private var bottomControls: some View {
        Group {
            if phase == .guessing {
                Button("Submit") { checkAnswer() }
                    .buttonStyle(.borderedProminent)
                    .disabled(selected.count != targetCount)
            } else if phase == .result {
                Button(lastCorrect ? "Next Round →" : "Try Again") {
                    if lastCorrect { round += 1 }
                    startRound()
                }
                .buttonStyle(.borderedProminent)
            } else if phase == .idle {
                Button("Start") { startRound() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .font(.headline)
        .padding(.bottom, 16)
    }

    private func tap(_ i: Int) {
        if selected.contains(i) {
            selected.remove(i)
        } else if selected.count < targetCount {
            selected.insert(i)
        }
    }

    private func checkAnswer() {
        lastCorrect = selected == litCells
        if lastCorrect { score += 1 }
        withAnimation { phase = .result }
    }

    private func startRound() {
        selected = []
        litCells = Set((0..<total).shuffled().prefix(targetCount))
        withAnimation { phase = .showing }
        Task {
            let showDuration = max(0.7, 2.0 - Double(round) * 0.08)
            try? await Task.sleep(for: .seconds(showDuration))
            await MainActor.run { withAnimation { phase = .guessing } }
        }
    }
}

#Preview { GridFlashView() }
