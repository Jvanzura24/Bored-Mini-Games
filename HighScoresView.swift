import SwiftUI

struct HighScoresView: View {
    @State private var entries: [(game: Game, score: Int)] = []
    @State private var sortByScore = true

    private var sortedEntries: [(game: Game, score: Int)] {
        sortByScore
            ? entries.sorted { $0.score > $1.score }
            : entries.sorted { $0.game.rawValue < $1.game.rawValue }
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    "No Scores Yet",
                    systemImage: "trophy",
                    description: Text("Play some games to record your first high score.")
                )
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        statsHeader

                        Picker("Sort", selection: $sortByScore) {
                            Text("By Score").tag(true)
                            Text("A\u{2013}Z").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 18)

                        LazyVStack(spacing: 8) {
                            ForEach(Array(sortedEntries.enumerated()), id: \.element.game.id) { index, entry in
                                ScoreRow(rank: sortByScore ? index + 1 : nil,
                                         game: entry.game,
                                         score: entry.score)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 14)
                }
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { entries = HighScoreStore.all() }
    }

    private var statsHeader: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "gamecontroller.fill",
                value: "\(entries.count)",
                label: "Games Played",
                tint: Color(red: 0.22, green: 0.45, blue: 0.95)
            )
            StatCard(
                icon: "chart.bar.fill",
                value: "\(entries.map(\.score).max() ?? 0)",
                label: "Top Score",
                tint: Color(red: 0.92, green: 0.65, blue: 0.10)
            )
        }
        .padding(.horizontal, 18)
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3.bold())
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.30), lineWidth: 1)
        )
    }
}

private struct ScoreRow: View {
    let rank: Int?
    let game: Game
    let score: Int

    var body: some View {
        HStack(spacing: 12) {
            if let rank {
                Text(rankLabel(rank))
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(rankColor(rank))
                    .frame(width: 30, alignment: .center)
            }

            Image(systemName: game.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    LinearGradient(
                        colors: [game.color.opacity(0.95), game.color.opacity(0.68)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(game.rawValue)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                Text(game.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(score)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(game.color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.30), lineWidth: 1)
        )
    }

    private func rankLabel(_ r: Int) -> String {
        "#\(r)"
    }

    private func rankColor(_ r: Int) -> Color {
        switch r {
        case 1: Color(red: 1.0, green: 0.84, blue: 0.0)
        case 2: Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: Color(red: 0.80, green: 0.50, blue: 0.20)
        default: .secondary
        }
    }
}

#Preview {
    NavigationStack {
        HighScoresView()
    }
}
