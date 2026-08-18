import SwiftUI

// Each word must start with the last letter of the previous word. Alternates with CPU.
struct WordChainView: View {
    private let wordPool: Set<String> = [
        "APPLE","EAGLE","EEL","LAMP","PIG","GORILLA","ANT","TIGER","RAT","TOMATO",
        "OAK","KITE","ELM","MANGO","OWL","LION","NET","TOAD","DOG","GRAPE",
        "EGG","GIANT","TULIP","PALM","MOON","NEST","TOP","PEN","NUT","TIN",
        "NAP","PLUM","MAP","PIANO","ONION","OVEN","NIT","TEA","ARC","CAT",
        "TAPIR","RAY","YAK","KNOT","TAR","ROAD","DOT","TILE","ERR","RUG",
        "GUM","MUD","DAM","MOP","POD","DEN","NIP","POP","PAT","TIP",
        "PIN","NAG","GEL","LET","TEN","NEW","WAX","XIS","SIP","PAD",
        "DAB","BET","TOT","TAP","PIG","GOT","TUB","BUN","NAB","BAG",
        "GAP","PEA","ACE","EMU","UDO","OAT","TAO","ODE","ELF","FIG",
        "GIN","NIM","MOB","BOA","AGO","ONE","OAF","FAN","NOD","DIP",
    ]

    private let cpuDelay = 1.0

    @State private var chain: [String] = []
    @State private var inputText = ""
    @State private var playerScore = 0
    @State private var cpuScore = 0
    @State private var turn: Turn = .player
    @State private var message = ""
    @State private var gameOver = false
    @State private var round = 0

    private enum Turn { case player, cpu }

    private var lastLetter: Character? { chain.last?.last }
    private var usedWords: Set<String> { Set(chain) }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                Spacer()
                scoreBlock("You", playerScore, .blue)
                Spacer()
                Text("vs").foregroundStyle(.secondary).font(.title2)
                Spacer()
                scoreBlock("CPU", cpuScore, .red)
                Spacer()
            }
            .padding(.top, 8)

            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(turn == .player ? .blue : .orange)
                .padding(.horizontal, 24)

            chainScroll

            if !gameOver {
                if let last = lastLetter {
                    Text("Next word must start with \"\(String(last))\"")
                        .font(.caption).foregroundStyle(.secondary)
                }

                if turn == .player {
                    playerInput
                }
            } else {
                Button("New Game") { startGame() }.buttonStyle(.borderedProminent).font(.headline)
            }

            Spacer()
        }
        .onAppear { startGame() }
    }

    private func scoreBlock(_ label: String, _ n: Int, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label).font(.headline).foregroundStyle(color)
            Text("\(n)").font(.system(size: 40, weight: .black, design: .rounded))
        }
    }

    private var chainScroll: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(chain.enumerated()), id: \.offset) { i, w in
                        Text(w)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(
                                i % 2 == 0 ? Color.blue.opacity(0.15) : Color.red.opacity(0.15),
                                in: Capsule()
                            )
                            .id(i)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 44)
            .onChange(of: chain.count) { _, n in
                withAnimation { proxy.scrollTo(n - 1) }
            }
        }
    }

    private var playerInput: some View {
        HStack(spacing: 12) {
            TextField("Type a word…", text: $inputText)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .font(.title3)
                .padding(12)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                .onSubmit { submitWord() }

            Button("Submit") { submitWord() }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .disabled(inputText.isEmpty)
        }
        .padding(.horizontal, 24)
    }

    private func submitWord() {
        let word = inputText.uppercased().trimmingCharacters(in: .whitespaces)
        inputText = ""
        guard validate(word: word) else { return }
        chain.append(word)
        playerScore += 1
        message = "CPU thinking…"; turn = .cpu
        Task {
            try? await Task.sleep(for: .seconds(cpuDelay))
            await MainActor.run { cpuTurn() }
        }
    }

    private func validate(word: String) -> Bool {
        guard !word.isEmpty else { return false }
        guard wordPool.contains(word) else { message = "\(word) — not in word list"; return false }
        guard !usedWords.contains(word) else { message = "\(word) — already used"; return false }
        if let needed = lastLetter {
            guard word.first == needed else { message = "Must start with \"\(needed)\""; return false }
        }
        return true
    }

    private func cpuTurn() {
        guard let needed = chain.last?.last else { return }
        let candidates = wordPool.filter { $0.first == needed && !usedWords.contains($0) }
        if let pick = candidates.randomElement() {
            chain.append(pick); cpuScore += 1
            message = "CPU played \"\(pick)\". Your turn!"
            turn = .player
        } else {
            message = "CPU can't move — you win! 🎉"
            playerScore += 3; gameOver = true
        }
    }

    private func startGame() {
        chain = []; playerScore = 0; cpuScore = 0; round += 1
        inputText = ""; gameOver = false; turn = .player
        message = "Start with any word!"
    }
}

#Preview { WordChainView() }
