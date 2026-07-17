//
//  ContentView.swift
//  Bored Mini Games
//
//  Created by Justin Vanzura on 7/17/26.
//

import SwiftUI

enum Game: String, CaseIterable, Identifiable {
    case ticTacToe = "Tic-Tac-Toe"
    case paddleBall = "Paddle Ball"
    case solitaire = "Solitaire"
    case snake = "Snake"
    case memoryMatch = "Memory Match"
    case mergeTiles = "Merge Tiles"
    case simon = "Simon"
    case whackAMole = "Whack-a-Mole"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .ticTacToe: "Beat the computer"
        case .paddleBall: "Classic arcade rally"
        case .solitaire: "Klondike card game"
        case .snake: "Eat and grow"
        case .memoryMatch: "Find the pairs"
        case .mergeTiles: "Combine to 2048"
        case .simon: "Repeat the pattern"
        case .whackAMole: "Tap the moles"
        }
    }

    var icon: String {
        switch self {
        case .ticTacToe: "number"
        case .paddleBall: "circle.fill"
        case .solitaire: "suit.spade.fill"
        case .snake: "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .memoryMatch: "square.grid.2x2.fill"
        case .mergeTiles: "square.stack.3d.up.fill"
        case .simon: "circle.hexagongrid.fill"
        case .whackAMole: "hare.fill"
        }
    }

    var color: Color {
        switch self {
        case .ticTacToe: Color(red: 0.22, green: 0.45, blue: 0.95)
        case .paddleBall: Color(red: 0.95, green: 0.48, blue: 0.20)
        case .solitaire: Color(red: 0.13, green: 0.62, blue: 0.39)
        case .snake: Color(red: 0.06, green: 0.63, blue: 0.68)
        case .memoryMatch: Color(red: 0.55, green: 0.31, blue: 0.86)
        case .mergeTiles: Color(red: 0.90, green: 0.25, blue: 0.49)
        case .simon: Color(red: 0.36, green: 0.42, blue: 0.75)
        case .whackAMole: Color(red: 0.62, green: 0.44, blue: 0.22)
        }
    }

    @ViewBuilder var destination: some View {
        switch self {
        case .ticTacToe: GameScreen(title: rawValue) { TicTacToeView() }
        case .paddleBall: GameScreen(title: rawValue) { PaddleBallView() }
        case .solitaire: GameScreen(title: rawValue) { SolitaireView() }
        case .snake: GameScreen(title: rawValue) { SnakeView() }
        case .memoryMatch: GameScreen(title: rawValue) { MemoryMatchView() }
        case .mergeTiles: GameScreen(title: rawValue) { MergeTilesView() }
        case .simon: GameScreen(title: rawValue) { SimonView() }
        case .whackAMole: GameScreen(title: rawValue) { WhackAMoleView() }
        }
    }
}

struct ContentView: View {
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HeroHeader()

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Game.allCases) { game in
                            NavigationLink {
                                game.destination
                            } label: {
                                GameTile(game: game)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .background(AppBackground())
            .navigationTitle("Bored Mini Games")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color(red: 0.22, green: 0.45, blue: 0.95))
    }
}

private struct HeroHeader: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.16, green: 0.37, blue: 0.92),
                                Color(red: 0.95, green: 0.35, blue: 0.47)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(red: 0.16, green: 0.37, blue: 0.92).opacity(0.24), radius: 18, x: 0, y: 10)

                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 78, height: 78)

            VStack(alignment: .leading, spacing: 6) {
                Text("Pick a quick game")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                Text("Six simple games for a short break.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        )
    }
}

private struct GameTile: View {
    let game: Game

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: game.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(
                        LinearGradient(
                            colors: [game.color.opacity(0.95), game.color.opacity(0.68)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(.background.opacity(0.75), in: Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(game.rawValue)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(game.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(game.color.opacity(0.16))
                .frame(width: 74, height: 74)
                .offset(x: 26, y: 28)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.30), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.97, blue: 1.00),
                Color(red: 0.98, green: 0.95, blue: 0.91),
                Color(red: 0.96, green: 0.95, blue: 1.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

/// Wraps every game with a shared layout: the game fills the screen and a
/// banner ad sits at the bottom, outside the play area so it never overlaps
/// or interrupts gameplay.
struct GameScreen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            BannerAdView()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
