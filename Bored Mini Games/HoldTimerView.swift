import SwiftUI

struct HoldTimerView: View {
    private enum Phase { case idle, holding, result }

    @State private var target = 3.0
    @State private var phase: Phase = .idle
    @State private var holdStart = Date.now
    @State private var heldTime = 0.0
    @State private var best: Double? = nil

    private var diff: Double { abs(heldTime - target) }

    var body: some View {
        VStack(spacing: 32) {
            if let b = best {
                Text("Best: ±\(String(format: "%.3f", b))s")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 16) {
                Text("Hold for exactly").font(.title2).foregroundStyle(.secondary)
                Text(String(format: "%.1f s", target))
                    .font(.system(size: 80, weight: .black, design: .rounded))
                    .foregroundStyle(.blue)

                if phase == .result {
                    VStack(spacing: 8) {
                        Text(String(format: "%+.3f s", heldTime - target))
                            .font(.title.bold())
                            .foregroundStyle(diff < 0.1 ? .green : diff < 0.3 ? .orange : .red)
                        Text(rating)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity)
                }
            }

            Spacer()

            if phase != .holding {
                Button("New Target") { newTarget() }
                    .foregroundStyle(.secondary)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(phase == .holding ? Color.green : Color.blue)
                    .frame(maxWidth: .infinity, minHeight: 100)

                Text(phase == .holding ? "Release!" : phase == .result ? "Hold Again" : "Press & Hold")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                if pressing {
                    holdStart = .now
                    withAnimation { phase = .holding }
                } else if phase == .holding {
                    heldTime = Date.now.timeIntervalSince(holdStart)
                    if best == nil || diff < best! { best = diff }
                    withAnimation { phase = .result }
                }
            }, perform: {})
        }
        .onAppear { newTarget() }
    }

    private var rating: String {
        if diff < 0.05 { return "Perfect!" }
        if diff < 0.15 { return "Great!" }
        if diff < 0.3  { return "Close!" }
        return "Keep practicing"
    }

    private func newTarget() {
        target = Double(Int.random(in: 20...80)) / 10.0
        heldTime = 0
        withAnimation { phase = .idle }
    }
}

#Preview { HoldTimerView() }
