import SwiftUI

// Tap numbers that add up to the target. Classic mental math puzzle.
struct SumTargetView: View {
    private let gridSize = 5

    @State private var numbers: [Int] = []
    @State private var target = 0
    @State private var selected: Set<Int> = []
    @State private var score = 0
    @State private var timeLeft = 60.0
    @State private var feedback: Bool? = nil
    @State private var gameOver = false
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var round = 0

    var selectedSum: Int { selected.map { numbers[$0] }.reduce(0, +) }

    var body: some View {
        VStack(spacing: 20) {
            hud
            if gameOver { gameOverView } else { gameplayView }
            Spacer()
        }
        .onAppear { reset() }
        .onDisappear { timerTask?.cancel() }
    }

    private var hud: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
            Spacer()
            Label(String(format: "%.0f", timeLeft), systemImage: "timer")
        }
        .font(.headline).padding(.horizontal, 24).padding(.top, 8)
    }

    private var gameplayView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("Target").font(.caption).foregroundStyle(.secondary)
                Text("\(target)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundStyle(.blue)
            }

            Group {
                if let fb = feedback {
                    Text(fb ? "✓ +1" : "✗ Reset")
                        .foregroundStyle(fb ? .green : .red)
                        .font(.title3.bold())
                } else {
                    Text("Sum: \(selectedSum)")
                        .foregroundStyle(selectedSum == target ? .green : .primary)
                        .font(.title3.bold())
                }
            }
            .frame(height: 32)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: gridSize), spacing: 10) {
                ForEach(0..<numbers.count, id: \.self) { i in
                    Button {
                        toggle(i)
                    } label: {
                        Text("\(numbers[i])")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                selected.contains(i) ? Color.blue : Color(.systemGray5),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .foregroundStyle(selected.contains(i) ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)

            HStack(spacing: 16) {
                Button("Clear") { selected = [] }
                    .buttonStyle(.bordered).font(.headline)
                Button("Submit") { submit() }
                    .buttonStyle(.borderedProminent).font(.headline)
                    .disabled(selected.isEmpty)
            }
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!").font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text("Score: \(score)").font(.title2).foregroundStyle(.secondary)
            Button("Play Again") { reset() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxHeight: .infinity)
    }

    private func toggle(_ i: Int) {
        if selected.contains(i) { selected.remove(i) } else { selected.insert(i) }
    }

    private func submit() {
        let correct = selectedSum == target
        withAnimation { feedback = correct }
        if correct { score += 1 }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run { feedback = nil; next() }
        }
    }

    private func next() {
        selected = []
        round += 1
        generatePuzzle()
    }

    private func generatePuzzle() {
        // Pick 2-3 numbers that sum to target, fill rest randomly
        let count = gridSize * gridSize
        let nums = (0..<count).map { _ in Int.random(in: 1...9) }
        // Ensure at least one valid solution
        let a = Int.random(in: 0..<count)
        var b = Int.random(in: 0..<count)
        while b == a { b = Int.random(in: 0..<count) }
        target = nums[a] + nums[b]
        numbers = nums
    }

    private func reset() {
        score = 0; timeLeft = 60; gameOver = false; feedback = nil; round = 0
        generatePuzzle(); selected = []
        timerTask?.cancel()
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { timeLeft -= 1; if timeLeft <= 0 { gameOver = true } }
            }
        }
    }
}

#Preview { SumTargetView() }
