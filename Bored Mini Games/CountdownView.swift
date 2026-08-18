import SwiftUI

// Estimate when a countdown reaches zero — release your tap at the right moment.
struct CountdownView: View {
    private enum Phase { case idle, counting, result }

    @State private var target = 5.0
    @State private var phase: Phase = .idle
    @State private var startTime = Date.now
    @State private var elapsed = 0.0
    @State private var best: Double? = nil
    @State private var score = 0
    @State private var displayTime = 0.0
    @State private var ticker: Task<Void, Never>? = nil

    private var diff: Double { abs(elapsed - target) }

    var body: some View {
        VStack(spacing: 32) {
            if let b = best {
                Text("Best: ±\(String(format: "%.3f", b))s")
                    .font(.headline).foregroundStyle(.secondary)
            }

            scoreRow

            Spacer()

            VStack(spacing: 16) {
                Text("Stop at exactly").font(.title2).foregroundStyle(.secondary)
                Text(String(format: "%.1f s", target))
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(.blue)

                if phase == .counting {
                    Text(String(format: "%.2f", displayTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundStyle(.primary)
                        .transition(.opacity)
                }

                if phase == .result {
                    resultBlock
                }
            }

            Spacer()

            if phase != .counting {
                Button("New Target") { newTarget() }.foregroundStyle(.secondary)
            }

            tapButton
        }
        .onDisappear { ticker?.cancel() }
    }

    private var scoreRow: some View {
        HStack {
            Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
        }
        .font(.headline)
        .padding(.horizontal, 24).padding(.top, 8)
    }

    private var resultBlock: some View {
        VStack(spacing: 8) {
            Text(String(format: "You stopped at %.3f s", elapsed))
                .font(.headline)
            Text(String(format: "%+.3f s", elapsed - target))
                .font(.title.bold())
                .foregroundStyle(diff < 0.1 ? .green : diff < 0.3 ? .orange : .red)
            Text(rating).font(.headline).foregroundStyle(.secondary)
        }
        .transition(.opacity)
    }

    private var tapButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(phase == .counting ? Color.green : Color.blue)

            Text(phase == .idle ? "Tap to Start" :
                 phase == .counting ? "TAP to Stop!" : "Tap Again")
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.horizontal, 24).padding(.bottom, 24)
        .onTapGesture { handleTap() }
    }

    private var rating: String {
        if diff < 0.05 { return "Flawless!" }
        if diff < 0.15 { return "Excellent!" }
        if diff < 0.3  { return "Nice!" }
        return "Keep trying"
    }

    private func handleTap() {
        switch phase {
        case .idle:
            startTime = .now; displayTime = 0
            withAnimation { phase = .counting }
            ticker = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(16))
                    await MainActor.run { displayTime = Date.now.timeIntervalSince(startTime) }
                }
            }
        case .counting:
            elapsed = Date.now.timeIntervalSince(startTime)
            ticker?.cancel()
            if best == nil || diff < best! { best = diff }
            if diff < 0.3 { score += max(1, Int(3 - diff * 10)) }
            withAnimation { phase = .result }
        case .result:
            newTarget()
        }
    }

    private func newTarget() {
        target = Double(Int.random(in: 30...100)) / 10.0
        elapsed = 0; displayTime = 0
        withAnimation { phase = .idle }
    }
}

#Preview { CountdownView() }
