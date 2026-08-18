import SwiftUI

// Scattered letters — tap them in alphabetical order as fast as possible.
struct LetterOrderView: View {
    private struct LetterTile: Identifiable {
        let id = UUID()
        let letter: Character
        var x: CGFloat
        var y: CGFloat
        var found = false
    }

    @State private var tiles: [LetterTile] = []
    @State private var nextExpected: Character = "A"
    @State private var startTime = Date.now
    @State private var elapsed = 0.0
    @State private var best: Double? = nil
    @State private var phase: Phase = .idle
    @State private var ticker: Task<Void, Never>? = nil

    private enum Phase { case idle, playing, done }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if phase == .idle {
                    idleView
                } else if phase == .done {
                    doneView
                } else {
                    playingView(geo: geo)
                }
            }
            .onAppear { setup(size: geo.size) }
            .onDisappear { ticker?.cancel() }
        }
    }

    private var idleView: some View {
        VStack(spacing: 20) {
            Text("Tap A→Z in order").font(.title2.bold())
            Text("As fast as you can!").foregroundStyle(.secondary)
            Button("Start") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var doneView: some View {
        VStack(spacing: 16) {
            Text("Done! ✓").font(.largeTitle.bold()).foregroundStyle(.green)
            Text(String(format: "%.2f s", elapsed)).font(.system(size: 56, weight: .black, design: .rounded))
            if let b = best {
                Text(String(format: "Best: %.2f s", b)).font(.headline).foregroundStyle(.secondary)
            }
            Button("Play Again") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func playingView(geo: GeometryProxy) -> some View {
        ZStack {
            VStack {
                HStack {
                    Text(String(format: "%.1f s", elapsed))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                    Spacer()
                    Text("Next: \(String(nextExpected))")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 20).padding(.top, 8)
                Spacer()
            }

            ForEach(tiles) { tile in
                if !tile.found {
                    Button {
                        tap(tile)
                    } label: {
                        Text(String(tile.letter))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .frame(width: 50, height: 50)
                            .background(
                                tile.letter == nextExpected ? Color.blue : Color(.systemGray4),
                                in: Circle()
                            )
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                    .position(x: tile.x * geo.size.width, y: tile.y * geo.size.height)
                }
            }
        }
    }

    private func tap(_ tile: LetterTile) {
        guard phase == .playing, tile.letter == nextExpected else { return }
        if let idx = tiles.firstIndex(where: { $0.id == tile.id }) {
            withAnimation { tiles[idx].found = true }
        }
        if nextExpected == "Z" {
            elapsed = Date.now.timeIntervalSince(startTime)
            if best == nil || elapsed < best! { best = elapsed }
            ticker?.cancel()
            withAnimation { phase = .done }
        } else {
            nextExpected = Character(UnicodeScalar(nextExpected.asciiValue! + 1))
        }
    }

    private func setup(size: CGSize) {}

    private func startGame() {
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        tiles = letters.map { letter in
            LetterTile(
                letter: letter,
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: 0.15...0.88)
            )
        }
        nextExpected = "A"; elapsed = 0; phase = .playing; startTime = .now
        ticker?.cancel()
        ticker = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                await MainActor.run { elapsed = Date.now.timeIntervalSince(startTime) }
            }
        }
    }
}

#Preview { LetterOrderView() }
