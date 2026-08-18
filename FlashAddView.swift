import SwiftUI

// Several numbers flash on screen one by one. Add them up and enter the total.
struct FlashAddView: View {
    private enum Phase { case flashing, entering, result }

    @State private var phase: Phase = .flashing
    @State private var numbers: [Int] = []
    @State private var currentFlashIdx = 0
    @State private var input = ""
    @State private var score = 0
    @State private var round = 0
    @State private var count = 3
    @State private var resultCorrect = false
    @State private var flashTask: Task<Void, Never>? = nil

    var correctSum: Int { numbers.reduce(0, +) }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                Spacer()
                Text("Round \(round)").font(.headline)
                Spacer()
                Text("\(count) numbers").font(.headline).foregroundStyle(.secondary)
            }
            .font(.headline).padding(.horizontal, 24).padding(.top, 8)

            Spacer()

            switch phase {
            case .flashing: flashView
            case .entering: enterView
            case .result: resultView
            }

            Spacer()
        }
        .onAppear { startRound() }
        .onDisappear { flashTask?.cancel() }
    }

    private var flashView: some View {
        VStack(spacing: 20) {
            Text("Add them up!").font(.headline).foregroundStyle(.secondary)
            if currentFlashIdx < numbers.count {
                Text("\(numbers[currentFlashIdx])")
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .transition(.scale.combined(with: .opacity))
                    .id(currentFlashIdx)
            } else {
                Text("?").font(.system(size: 80, weight: .black, design: .rounded)).foregroundStyle(.secondary)
            }
        }
    }

    private var enterView: some View {
        VStack(spacing: 24) {
            Text("What was the sum?").font(.headline).foregroundStyle(.secondary)

            Text(input.isEmpty ? "?" : input)
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(input.isEmpty ? .secondary : .primary)

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
                Text("Answer: \(correctSum)").font(.title2).foregroundStyle(.secondary)
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
                    ForEach(row, id: \.self) { n in numKey("\(n)") }
                }
            }
            HStack(spacing: 10) {
                numKey("⌫").foregroundStyle(.orange)
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
            else if input.count < 6 { input.append(label) }
        } label: {
            Text(label)
                .font(.title2.bold())
                .frame(width: 88, height: 56)
                .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func submit() {
        resultCorrect = (Int(input) ?? -1) == correctSum
        if resultCorrect {
            score += count
            count = min(count + 1, 7)
        } else {
            count = max(count - 1, 2)
        }
        withAnimation { phase = .result }
    }

    private func startRound() {
        round += 1; input = ""
        numbers = (0..<count).map { _ in Int.random(in: 1...20) }
        currentFlashIdx = 0; phase = .flashing
        flashTask?.cancel()
        flashTask = Task {
            for i in 0..<numbers.count {
                await MainActor.run { currentFlashIdx = i }
                try? await Task.sleep(for: .milliseconds(700))
                await MainActor.run { currentFlashIdx = numbers.count } // blank
                try? await Task.sleep(for: .milliseconds(200))
            }
            await MainActor.run { phase = .entering }
        }
    }
}

#Preview { FlashAddView() }
