import Foundation

enum HighScoreStore {
    static func save(_ score: Int, for game: Game) {
        let key = "highScore.\(game.id)"
        guard score > UserDefaults.standard.integer(forKey: key) else { return }
        UserDefaults.standard.set(score, forKey: key)
    }

    static func load(for game: Game) -> Int? {
        let key = "highScore.\(game.id)"
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.integer(forKey: key)
    }

    static func all() -> [(game: Game, score: Int)] {
        Game.allCases.compactMap { game in
            guard let score = load(for: game) else { return nil }
            return (game, score)
        }
    }
}
