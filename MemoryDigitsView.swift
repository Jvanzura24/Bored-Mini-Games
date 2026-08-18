import SwiftUI

struct MemoryDigitsView: View {
    private enum Phase { case showing, entering, result }

    @State private var phase: Phase = .showing
    @State private var digits = ""
    @State private var input = ""
    @State private var score = 0
    @State private var round = 0
    @State private var digitCount = 4
    @State private var showTimer = 2.0
    @State private var timeLeft = 2.0
    @State private var resultCorrect = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                Text("Round \(round)").font(.headline)
                Spacer()
                Text("\(digitCount) digits").font(.headline).foregroundStyle(.secondary)
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            Spacer()

            switch phase {
            case .showing: showingView
            case .entering: enteringView
            case .result: resultView
            }

            Spacer()
        }
        .onAppear { startRound() }
    }

    private var showingView: some View {
        VStack(spacing: 20) {
            Text("Memorize this number!")
                .font(.headline).foregroundStyle(.secondary)
            Text(digits)
                .font(.system(size: 56, weight: .black, design: .monospaced))
                .padding(.horizontal, 24)
            ProgressView(value: timeLeft, total: showTimer)
                .tint(.blue)
                .padding(.horizontal, 40)
        }
    }

    private var enteringView: some View {
        VStack(spacing: 24) {
            Text("What was the number?")
                .font(.headline).foregroundStyle(.secondary)
            Text(input.isEmpty ? "?" : input)
                .font(.system(size: 56, weight: .black, design: .monospaced))
                .foregroundStyle(input.isEmpty ? .secondary : .primary)
                .frame(minWidth: 120, minHeight: 80)
                .padding(.horizontal, 24)

            numPad
        }
    }

    private var resultView: some View {
        VStack(spacing: 20) {
            Image(systemName: resultCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(resultCorrect ? .green : .red)
            Text(resultCorrect ? "Correct!" : "Wrong!")
                .font(.system(.title, design: .rounded, weight: .bold))
            if !resultCorrect {
                Text("Answer: \(digits)")
                    .font(.title2).foregroundStyle(.secondary)
            }
            Text("Score: \(score)").font(.headline)
            Button(resultCorrect ? "Keep Going" : "Try Again") { startRound() }
                .buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private var numPad: some View {
        VStack(spacing: 10) {
            ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { n in
                        numKey("\(n)")
                    }
                }
            }
            HStack(spacing: 10) {
                numKey("⌫") .foregroundStyle(.orange)
                numKey("0")
                Button("Submit") { submit() }
                    .font(.title3.bold())
                    .frame(width: 88, height: 56)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                    .buttonStyle(.plain)
                    .disabled(input.isEmpty)
            }
        }
        .padding(.horizontal, 24)
    }

    private func numKey(_ label: String) -> some View {
        Button {
            if label == "⌫" { if !input.isEmpty { input.removeLast() } }
            else if input.count < digitCount { input.append(label) }
        } label: {
            Text(label)
                .font(.title2.bold())
                .frame(width: 88, height: 56)
                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        resultCorrect = input == digits
        if resultCorrect {
            score += digitCount
            digitCount = min(digitCount + 1, 9)
        } else {
            digitCount = max(digitCount - 1, 3)
        }
        withAnimation { phase = .result }
    }

    private func startRound() {
        round += 1
        input = ""
        digits = (0..<digitCount).map { _ in "\(Int.random(in: 0...9))" }.joined()
        showTimer = max(1.0, 3.0 - Double(digitCount - 4) * 0.2)
        timeLeft = showTimer
        phase = .showing

        Task {
            let steps = Int(showTimer / 0.1)
            for _ in 0..<steps {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run { timeLeft -= 0.1 }
            }
            await MainActor.run { if phase == .showing { phase = .entering } }
        }
    }
}

#Preview { MemoryDigitsView() }
