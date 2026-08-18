import SwiftUI

struct ShootingGalleryView: View {
    private struct Target: Identifiable {
        let id = UUID()
        var x: CGFloat
        let y: CGFloat
        var speed: Double
        var direction: CGFloat // +1 or -1
        let size: CGFloat
        let points: Int
    }

    @State private var targets: [Target] = []
    @State private var score = 0
    @State private var misses = 0
    @State private var timeLeft = 30.0
    @State private var gameOver = false
    @State private var gameTask: Task<Void, Never>? = nil
    @State private var spawnTask: Task<Void, Never>? = nil
    @State private var timerTask: Task<Void, Never>? = nil
    @State private var pops: [(CGPoint, String)] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red:0.08,green:0.12,blue:0.18), Color(red:0.05,green:0.08,blue:0.14)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if gameOver {
                    gameOverView
                } else {
                    gameContent(geo: geo)
                }
            }
            .onAppear { startGame(size: geo.size) }
            .onDisappear { stopAll() }
        }
    }

    private func gameContent(geo: GeometryProxy) -> some View {
        ZStack {
            ForEach(targets) { t in
                ZStack {
                    Circle()
                        .fill(
                            t.size > 55 ? Color.red :
                            t.size > 40 ? Color.orange : Color.yellow
                        )
                        .frame(width: t.size, height: t.size)
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 2)
                        .frame(width: t.size * 0.6, height: t.size * 0.6)
                }
                .position(x: t.x * geo.size.width, y: t.y * geo.size.height)
                .onTapGesture {
                    hit(id: t.id, at: CGPoint(x: t.x * geo.size.width, y: t.y * geo.size.height), pts: t.points)
                }
            }

            ForEach(pops, id: \.0.x) { (pos, label) in
                Text(label)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.yellow)
                    .position(pos)
                    .transition(.opacity.combined(with: .scale))
            }

            VStack {
                HStack {
                    Label("\(score)", systemImage: "star.fill").foregroundStyle(.yellow).font(.title3.bold())
                    Spacer()
                    Label(String(format: "%.0f", timeLeft), systemImage: "timer").foregroundStyle(.white).font(.title3.bold())
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < (3 - misses) ? "target" : "xmark.circle")
                                .foregroundStyle(i < (3 - misses) ? .white : .red).font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 8)
                Spacer()
            }
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.system(.largeTitle, design: .rounded, weight: .bold)).foregroundStyle(.white)
            Text("Score: \(score)").font(.title2).foregroundStyle(.gray)
            Button("Play Again") { Task { @MainActor in startGame(size: CGSize(width: 390, height: 700)) } }
                .buttonStyle(.borderedProminent).font(.headline)
        }
    }

    private func hit(id: UUID, at pos: CGPoint, pts: Int) {
        guard let idx = targets.firstIndex(where: { $0.id == id }) else { return }
        targets.remove(at: idx)
        score += pts
        let label = pts == 1 ? "+1" : pts == 2 ? "+2" : "+3"
        withAnimation { pops.append((pos, label)) }
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            await MainActor.run { _ = pops.removeFirst() }
        }
    }

    private func startGame(size: CGSize) {
        targets = []; score = 0; misses = 0; timeLeft = 30; gameOver = false
        stopAll()

        gameTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(16))
                guard !Task.isCancelled else { return }
                await MainActor.run { update() }
            }
        }

        spawnTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1000))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if !gameOver && targets.count < 6 {
                        let big = Bool.random()
                        let sz: CGFloat = big ? CGFloat.random(in: 56...72) : CGFloat.random(in: 28...45)
                        targets.append(Target(
                            x: CGFloat.random(in: 0.08...0.92),
                            y: CGFloat.random(in: 0.18...0.82),
                            speed: Double.random(in: 0.003...0.007),
                            direction: Bool.random() ? 1 : -1,
                            size: sz,
                            points: sz > 55 ? 1 : sz > 40 ? 2 : 3
                        ))
                    }
                }
            }
        }

        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    timeLeft -= 1
                    if timeLeft <= 0 { gameOver = true; stopAll() }
                }
            }
        }
    }

    private func update() {
        for i in targets.indices {
            targets[i].x += targets[i].speed * targets[i].direction
            if targets[i].x < 0.05 { targets[i].direction = 1 }
            if targets[i].x > 0.95 { targets[i].direction = -1 }
        }
    }

    private func stopAll() { gameTask?.cancel(); spawnTask?.cancel(); timerTask?.cancel() }
}

#Preview { ShootingGalleryView() }
