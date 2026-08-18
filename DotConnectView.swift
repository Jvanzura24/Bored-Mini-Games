import SwiftUI

// Memory path game: watch which dots connect in order, then reproduce it.
struct DotConnectView: View {
    private enum Phase { case watching, recalling, result }

    private struct Dot: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
    }

    private let dots: [Dot] = [
        Dot(id: 0, x: 0.2, y: 0.25), Dot(id: 1, x: 0.5, y: 0.20), Dot(id: 2, x: 0.8, y: 0.25),
        Dot(id: 3, x: 0.15, y: 0.50), Dot(id: 4, x: 0.5, y: 0.50), Dot(id: 5, x: 0.85, y: 0.50),
        Dot(id: 6, x: 0.2, y: 0.75), Dot(id: 7, x: 0.5, y: 0.80), Dot(id: 8, x: 0.8, y: 0.75),
    ]

    @State private var phase: Phase = .watching
    @State private var pattern: [Int] = []
    @State private var playerPath: [Int] = []
    @State private var highlightIdx = -1
    @State private var score = 0
    @State private var round = 0
    @State private var resultCorrect = false
    @State private var showTask: Task<Void, Never>? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    HStack {
                        Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow)
                        Spacer()
                        Text(phaseLabel).font(.headline).foregroundStyle(.secondary)
                        Spacer()
                        Text("Round \(round)").font(.headline)
                    }
                    .font(.headline).padding(.horizontal, 24).padding(.top, 8)
                    Spacer()
                }

                // Lines for pattern (watching) or player path (recalling)
                let activePath = phase == .watching ? Array(pattern.prefix(highlightIdx + 1)) : playerPath
                if activePath.count >= 2 {
                    ForEach(0..<activePath.count - 1, id: \.self) { i in
                        let a = dots[activePath[i]]
                        let b = dots[activePath[i + 1]]
                        Path { p in
                            p.move(to: CGPoint(x: a.x * geo.size.width, y: a.y * geo.size.height))
                            p.addLine(to: CGPoint(x: b.x * geo.size.width, y: b.y * geo.size.height))
                        }
                        .stroke(phase == .watching ? Color.blue : Color.green, lineWidth: 3)
                    }
                }

                // Dots
                ForEach(dots) { dot in
                    let isHighlighted = phase == .watching && dot.id == (highlightIdx >= 0 && highlightIdx < pattern.count ? pattern[highlightIdx] : -1)
                    let inPlayerPath = playerPath.contains(dot.id)
                    Circle()
                        .fill(isHighlighted ? Color.yellow : inPlayerPath ? Color.green : Color(.systemGray3))
                        .frame(width: isHighlighted ? 44 : 36, height: isHighlighted ? 44 : 36)
                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        .position(x: dot.x * geo.size.width, y: dot.y * geo.size.height)
                        .onTapGesture {
                            if phase == .recalling { tapDot(dot.id) }
                        }
                }

                if phase == .result {
                    resultOverlay
                }
            }
        }
        .onAppear { startRound() }
        .onDisappear { showTask?.cancel() }
    }

    private var phaseLabel: String {
        switch phase {
        case .watching: return "Watch the path"
        case .recalling: return "Tap the path!"
        case .result: return resultCorrect ? "Correct! ✓" : "Wrong ✗"
        }
    }

    private var resultOverlay: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(resultCorrect ? "✓" : "✗")
                .font(.system(size: 72, weight: .black))
                .foregroundStyle(resultCorrect ? .green : .red)
            Text(resultCorrect ? "Score: \(score)" : "Expected: \(pattern.map { "\($0+1)" }.joined(separator: "→"))")
                .font(.headline).foregroundStyle(.secondary)
            Button(resultCorrect ? "Next Round" : "Try Again") { startRound() }
                .buttonStyle(.borderedProminent).font(.headline)
            Spacer()
        }
    }

    private func tapDot(_ id: Int) {
        guard phase == .recalling else { return }
        guard !playerPath.contains(id) else { return }
        playerPath.append(id)
        let idx = playerPath.count - 1
        if playerPath[idx] != pattern[idx] {
            resultCorrect = false
            withAnimation { phase = .result }
            return
        }
        if playerPath.count == pattern.count {
            score += 1; resultCorrect = true
            withAnimation { phase = .result }
        }
    }

    private func startRound() {
        round += 1
        let len = min(3 + round, 7)
        var path: [Int] = []
        var pool = Array(dots.map { $0.id }).shuffled()
        for _ in 0..<len { path.append(pool.removeFirst()) }
        pattern = path; playerPath = []; highlightIdx = -1; phase = .watching
        showTask?.cancel()
        showTask = Task {
            for i in 0..<path.count {
                try? await Task.sleep(for: .milliseconds(600))
                await MainActor.run { highlightIdx = i }
                try? await Task.sleep(for: .milliseconds(500))
                await MainActor.run { highlightIdx = -1 }
            }
            try? await Task.sleep(for: .milliseconds(300))
            await MainActor.run { phase = .recalling }
        }
    }
}

#Preview { DotConnectView() }
