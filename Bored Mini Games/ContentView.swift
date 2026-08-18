//
//  ContentView.swift
//  Bored Mini Games
//
//  Created by Justin Vanzura on 7/17/26.
//

import SwiftUI

/// Shared difficulty setting for the games that support one. Each game
/// persists its own selection, so picking Hard in Snake doesn't affect Simon.
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }
}

/// Segmented Easy/Medium/Hard control shown at the top of games that
/// support difficulty levels.
struct DifficultyPicker: View {
    @Binding var difficulty: Difficulty

    var body: some View {
        Picker("Difficulty", selection: $difficulty) {
            ForEach(Difficulty.allCases) { level in
                Text(level.rawValue).tag(level)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 40)
    }
}

enum Game: String, CaseIterable, Identifiable, Hashable {
    case ticTacToe = "Tic-Tac-Toe"
    case paddleBall = "Paddle Ball"
    case solitaire = "Solitaire"
    case snake = "Snake"
    case memoryMatch = "Memory Match"
    case mergeTiles = "Merge Tiles"
    case simon = "Pattern Recall"
    case whackAMole = "Mole Mash"
    case fourInARow = "Four in a Row"
    case slidePuzzle = "Slide Puzzle"
    case colorFlood = "Color Flood"
    case reactionTap = "Reaction Tap"
    case mathRush = "Math Rush"
    case bubblePop = "Bubble Pop"
    case pegJump = "Peg Jump"
    case numberHunt = "Number Hunt"
    case towerStack = "Tower Stack"
    case targetTap = "Target Tap"
    case oddEvenRush = "Odd or Even"
    case speedTap = "Speed Tap"
    case holdTimer = "Hold Timer"
    case colorFlash = "Color Flash"
    case rockPaperScissors = "Rock Paper Scissors"
    case gridFlash = "Grid Flash"
    case higherLower = "Higher or Lower"
    case primeRush = "Prime Rush"
    case coinCatch = "Coin Catch"
    case lightsOut = "Lights Out"
    case sequenceNext = "Sequence Next"
    case cardWar = "Card War"
    case diceScore = "Dice Score"
    case wordScramble = "Word Scramble"
    case starDodge = "Star Dodge"
    case dotsBoxes = "Dots & Boxes"
    case flipGrid = "Flip Grid"
    case trueFalse = "True or False"
    case sortBalls = "Sort Balls"
    case countdown = "Countdown"
    case tapSequence = "Tap Sequence"
    case nim = "Nim"
    case fractionMatch = "Fraction Match"
    case rhymePick = "Rhyme Pick"
    case categorySort = "Category Sort"
    case letterOrder = "Letter Order"
    case quickMultiply = "Quick Multiply"
    case spellingCheck = "Spelling Check"
    case clockRead = "Clock Read"
    case speedRead = "Speed Read"
    case brickBreak = "Brick Break"
    case mazeRun = "Maze Run"
    case towerHanoi = "Tower of Hanoi"
    case shootingGallery = "Shooting Gallery"
    case sudokuLite = "Sudoku Lite"
    case balanceScale = "Balance Scale"
    case emojiMath = "Emoji Math"
    case anagramPick = "Anagram Pick"
    case wordChain = "Word Chain"
    case palindromeCheck = "Palindrome Check"
    case binaryFlip = "Binary Flip"
    case factorFind = "Factor Find"
    case memoryDigits = "Memory Digits"
    case coinStreak = "Coin Streak"
    case temperatureFlip = "Temp Convert"
    case wordLength = "Word Length"
    case tileFlip = "Tile Flip"
    case powersQuiz = "Powers Quiz"
    case sentenceOrder = "Sentence Order"
    case shadowMatch = "Shape Match"
    case reflexCatch = "Reflex Catch"
    case sumTarget = "Sum Target"
    case wordVowel = "Vowel Count"
    case gravityDrop = "Gravity Drop"
    case pathNumber = "Number Path"
    case tapSpeedDuel = "Tap Duel"
    case numberSort = "Number Sort"
    case quickTyping = "Quick Typing"
    case greaterLess = "Greater or Less"
    case missingOp = "Missing Operator"
    case colorName = "Color Name"
    case pinballBumper = "Bumper Tap"
    case evenOddSort = "Even or Odd"
    case dotConnect = "Dot Memory"
    case letterBomb = "Letter Bomb"
    case multiTap = "Multi Tap"
    case spotDiff = "Spot the Diff"
    case colorTrail = "Color Trail"
    case flashCard = "Flash Cards"
    case romanNumeral = "Roman Numerals"
    case capitalCity = "World Capitals"
    case triviaMix = "Trivia Mix"
    case colorBlend = "Color Blend"
    case numberBetween = "Between Two"
    case syllableCount = "Syllable Count"
    case abbrevMatch = "Abbreviations"
    case balloonPopOrder = "Balloon Order"
    case flashAdd = "Flash Add"
    case visualPattern = "Visual Pattern"
    case stroopSwitch = "Stroop Switch"
    case tileRotate = "Tile Rotate"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .ticTacToe: "Beat the computer"
        case .paddleBall: "Classic arcade rally"
        case .solitaire: "Klondike card game"
        case .snake: "Eat and grow"
        case .memoryMatch: "Find the pairs"
        case .mergeTiles: "Merge tiles for points"
        case .simon: "Repeat the pattern"
        case .whackAMole: "Tap the moles"
        case .fourInARow: "Connect four discs"
        case .slidePuzzle: "Order the tiles"
        case .colorFlood: "Flood the board"
        case .reactionTap: "How fast are you?"
        case .mathRush: "Quick arithmetic"
        case .bubblePop: "Pop before they escape"
        case .pegJump: "Leave one peg"
        case .numberHunt: "Tap 1 to 15 in order"
        case .towerStack: "Stack without falling"
        case .targetTap: "Tap before it shrinks"
        case .oddEvenRush: "Odd or even?"
        case .speedTap: "Tap as fast as you can"
        case .holdTimer: "Feel the seconds"
        case .colorFlash: "Stroop color test"
        case .rockPaperScissors: "First to five wins"
        case .gridFlash: "Memorize the grid"
        case .higherLower: "Read the cards"
        case .primeRush: "Spot the primes"
        case .coinCatch: "Catch the falling coins"
        case .lightsOut: "Toggle all lights off"
        case .sequenceNext: "What comes next?"
        case .cardWar: "Highest card wins"
        case .diceScore: "Roll for the best score"
        case .wordScramble: "Unscramble the word"
        case .starDodge: "Dodge the stars"
        case .dotsBoxes: "Connect to score boxes"
        case .flipGrid: "Claim the most discs"
        case .trueFalse: "Fact or fiction?"
        case .sortBalls: "Tap the right bin"
        case .countdown: "Feel the time"
        case .tapSequence: "Watch and repeat"
        case .nim: "Don't take the last"
        case .fractionMatch: "Fraction to decimal"
        case .rhymePick: "Find the rhyme"
        case .categorySort: "Animal, food, place…"
        case .letterOrder: "Tap A to Z"
        case .quickMultiply: "Times tables blitz"
        case .spellingCheck: "Correct or misspelled?"
        case .clockRead: "Read the clock"
        case .speedRead: "Flash memory"
        case .brickBreak: "Break all the bricks"
        case .mazeRun: "Find the exit"
        case .towerHanoi: "Move the discs"
        case .shootingGallery: "Hit moving targets"
        case .sudokuLite: "4×4 number puzzle"
        case .balanceScale: "Find the right weight"
        case .emojiMath: "Solve emoji equations"
        case .anagramPick: "Spot the real word"
        case .wordChain: "Chain words by letter"
        case .palindromeCheck: "Same forwards and back?"
        case .binaryFlip: "Binary to decimal"
        case .factorFind: "Find a divisor"
        case .memoryDigits: "Remember the digits"
        case .coinStreak: "Predict the flip"
        case .temperatureFlip: "C° to F° and back"
        case .wordLength: "Longer word wins"
        case .tileFlip: "Make all tiles match"
        case .powersQuiz: "Squares and cubes"
        case .sentenceOrder: "Fix the word order"
        case .shadowMatch: "Name the shape"
        case .reflexCatch: "Tap the moving dot"
        case .sumTarget: "Pick numbers that sum up"
        case .wordVowel: "Count the vowels"
        case .gravityDrop: "Catch the falling ball"
        case .pathNumber: "Tap 1 to 16 in order"
        case .tapSpeedDuel: "Left vs right, who's faster?"
        case .numberSort: "Swap tiles into order"
        case .quickTyping: "Type the word fast"
        case .greaterLess: "Which number is bigger?"
        case .missingOp: "Find the operator"
        case .colorName: "Name that color"
        case .pinballBumper: "Tap bumpers for points"
        case .evenOddSort: "Sort even or odd"
        case .dotConnect: "Memorize the path"
        case .letterBomb: "Tap only the vowels"
        case .multiTap: "Tap all targets fast"
        case .spotDiff: "Find the odd emoji"
        case .colorTrail: "Paint the whole board"
        case .flashCard: "Study with flash cards"
        case .romanNumeral: "Roman to decimal"
        case .capitalCity: "Match country to capital"
        case .triviaMix: "General knowledge"
        case .colorBlend: "Mix the paint colors"
        case .numberBetween: "Find the middle number"
        case .syllableCount: "Count the syllables"
        case .abbrevMatch: "What does it stand for?"
        case .balloonPopOrder: "Pop 1, 2, 3 in order"
        case .flashAdd: "Add the flashed numbers"
        case .visualPattern: "Complete the grid pattern"
        case .stroopSwitch: "Read or name the color?"
        case .tileRotate: "Align all the arrows"
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
        case .fourInARow: "circle.grid.3x3.fill"
        case .slidePuzzle: "square.grid.3x3.topleft.filled"
        case .colorFlood: "paintbucket.fill"
        case .reactionTap: "bolt.fill"
        case .mathRush: "function"
        case .bubblePop: "bubbles.and.sparkles.fill"
        case .pegJump: "triangle.fill"
        case .numberHunt: "textformat.123"
        case .towerStack: "square.3.layers.3d.top.filled"
        case .targetTap: "scope"
        case .oddEvenRush: "plusminus"
        case .speedTap: "hand.tap.fill"
        case .holdTimer: "stopwatch.fill"
        case .colorFlash: "paintpalette.fill"
        case .rockPaperScissors: "hand.raised.fill"
        case .gridFlash: "grid"
        case .higherLower: "arrow.up.arrow.down"
        case .primeRush: "number.circle.fill"
        case .coinCatch: "dollarsign.circle.fill"
        case .lightsOut: "lightbulb.fill"
        case .sequenceNext: "ellipsis.circle.fill"
        case .cardWar: "rectangle.stack.fill"
        case .diceScore: "die.face.5.fill"
        case .wordScramble: "textformat.abc"
        case .starDodge: "star.fill"
        case .dotsBoxes: "dot.squareshape.split.2x2"
        case .flipGrid: "circle.lefthalf.filled"
        case .trueFalse: "checkmark.circle.fill"
        case .sortBalls: "arrow.down.to.line"
        case .countdown: "timer.circle.fill"
        case .tapSequence: "123.rectangle.fill"
        case .nim: "minus.circle.fill"
        case .fractionMatch: "divide.circle.fill"
        case .rhymePick: "music.note"
        case .categorySort: "tray.2.fill"
        case .letterOrder: "a.circle.fill"
        case .quickMultiply: "multiply.circle.fill"
        case .spellingCheck: "checkmark.seal.fill"
        case .clockRead: "clock.fill"
        case .speedRead: "eye.fill"
        case .brickBreak: "rectangle.grid.3x2.fill"
        case .mazeRun: "map.fill"
        case .towerHanoi: "rectangle.stack.fill"
        case .shootingGallery: "target"
        case .sudokuLite: "grid"
        case .balanceScale: "scalemass.fill"
        case .emojiMath: "face.smiling.fill"
        case .anagramPick: "arrow.2.squarepath"
        case .wordChain: "link.circle.fill"
        case .palindromeCheck: "arrow.left.and.right.circle.fill"
        case .binaryFlip: "01.circle.fill"
        case .factorFind: "divide"
        case .memoryDigits: "number.circle"
        case .coinStreak: "centsign.circle.fill"
        case .temperatureFlip: "thermometer.medium"
        case .wordLength: "ruler.fill"
        case .tileFlip: "square.grid.2x2.fill"
        case .powersQuiz: "x.squareroot"
        case .sentenceOrder: "text.line.last.and.arrowtriangle.forward"
        case .shadowMatch: "triangle.fill"
        case .reflexCatch: "dot.circle.fill"
        case .sumTarget: "sum"
        case .wordVowel: "a.circle"
        case .gravityDrop: "arrow.down.circle.fill"
        case .pathNumber: "123.rectangle.fill"
        case .tapSpeedDuel: "hand.tap.fill"
        case .numberSort: "arrow.up.and.down.square.fill"
        case .quickTyping: "keyboard.fill"
        case .greaterLess: "lessthan.circle.fill"
        case .missingOp: "questionmark.circle.fill"
        case .colorName: "paintpalette.fill"
        case .pinballBumper: "circle.hexagongrid.fill"
        case .evenOddSort: "arrow.left.and.right.circle.fill"
        case .dotConnect: "point.3.connected.trianglepath.dotted"
        case .letterBomb: "textformat.abc.dottedunderline"
        case .multiTap: "target"
        case .spotDiff: "face.smiling"
        case .colorTrail: "paintbrush.pointed.fill"
        case .flashCard: "rectangle.on.rectangle.angled.fill"
        case .romanNumeral: "xmark.circle"
        case .capitalCity: "globe.americas.fill"
        case .triviaMix: "questionmark.bubble.fill"
        case .colorBlend: "drop.halffull"
        case .numberBetween: "lessthan.square.fill"
        case .syllableCount: "waveform"
        case .abbrevMatch: "abc"
        case .balloonPopOrder: "balloon.fill"
        case .flashAdd: "plus.forwardslash.minus"
        case .visualPattern: "square.grid.3x3.fill"
        case .stroopSwitch: "eye.trianglebadge.exclamationmark.fill"
        case .tileRotate: "arrow.up.circle.fill"
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
        case .fourInARow: Color(red: 0.93, green: 0.60, blue: 0.10)
        case .slidePuzzle: Color(red: 0.31, green: 0.36, blue: 0.45)
        case .colorFlood: Color(red: 0.85, green: 0.22, blue: 0.48)
        case .reactionTap: Color(red: 0.15, green: 0.70, blue: 0.34)
        case .mathRush: Color(red: 0.20, green: 0.52, blue: 0.88)
        case .bubblePop: Color(red: 0.42, green: 0.22, blue: 0.88)
        case .pegJump: Color(red: 0.74, green: 0.44, blue: 0.15)
        case .numberHunt: Color(red: 0.08, green: 0.56, blue: 0.60)
        case .towerStack: Color(red: 0.88, green: 0.28, blue: 0.28)
        case .targetTap: Color(red: 0.93, green: 0.38, blue: 0.12)
        case .oddEvenRush: Color(red: 0.18, green: 0.52, blue: 0.92)
        case .speedTap: Color(red: 0.92, green: 0.28, blue: 0.28)
        case .holdTimer: Color(red: 0.30, green: 0.72, blue: 0.48)
        case .colorFlash: Color(red: 0.78, green: 0.22, blue: 0.78)
        case .rockPaperScissors: Color(red: 0.22, green: 0.62, blue: 0.86)
        case .gridFlash: Color(red: 0.55, green: 0.40, blue: 0.82)
        case .higherLower: Color(red: 0.12, green: 0.58, blue: 0.38)
        case .primeRush: Color(red: 0.85, green: 0.45, blue: 0.12)
        case .coinCatch: Color(red: 0.82, green: 0.68, blue: 0.10)
        case .lightsOut: Color(red: 0.28, green: 0.28, blue: 0.38)
        case .sequenceNext: Color(red: 0.22, green: 0.45, blue: 0.75)
        case .cardWar: Color(red: 0.72, green: 0.18, blue: 0.28)
        case .diceScore: Color(red: 0.38, green: 0.58, blue: 0.22)
        case .wordScramble: Color(red: 0.62, green: 0.28, blue: 0.72)
        case .starDodge: Color(red: 0.12, green: 0.12, blue: 0.38)
        case .dotsBoxes: Color(red: 0.52, green: 0.32, blue: 0.18)
        case .flipGrid: Color(red: 0.18, green: 0.42, blue: 0.22)
        case .trueFalse: Color(red: 0.22, green: 0.68, blue: 0.52)
        case .sortBalls: Color(red: 0.88, green: 0.38, blue: 0.22)
        case .countdown: Color(red: 0.45, green: 0.22, blue: 0.72)
        case .tapSequence: Color(red: 0.20, green: 0.55, blue: 0.90)
        case .nim: Color(red: 0.60, green: 0.20, blue: 0.20)
        case .fractionMatch: Color(red: 0.15, green: 0.55, blue: 0.45)
        case .rhymePick: Color(red: 0.72, green: 0.30, blue: 0.60)
        case .categorySort: Color(red: 0.35, green: 0.60, blue: 0.25)
        case .letterOrder: Color(red: 0.20, green: 0.40, blue: 0.80)
        case .quickMultiply: Color(red: 0.88, green: 0.42, blue: 0.10)
        case .spellingCheck: Color(red: 0.22, green: 0.62, blue: 0.42)
        case .clockRead: Color(red: 0.38, green: 0.38, blue: 0.55)
        case .speedRead: Color(red: 0.15, green: 0.52, blue: 0.75)
        case .brickBreak: Color(red: 0.85, green: 0.22, blue: 0.22)
        case .mazeRun: Color(red: 0.30, green: 0.55, blue: 0.30)
        case .towerHanoi: Color(red: 0.55, green: 0.38, blue: 0.20)
        case .shootingGallery: Color(red: 0.10, green: 0.18, blue: 0.35)
        case .sudokuLite: Color(red: 0.28, green: 0.45, blue: 0.68)
        case .balanceScale: Color(red: 0.50, green: 0.35, blue: 0.20)
        case .emojiMath: Color(red: 0.90, green: 0.55, blue: 0.10)
        case .anagramPick: Color(red: 0.58, green: 0.22, blue: 0.65)
        case .wordChain: Color(red: 0.18, green: 0.55, blue: 0.52)
        case .palindromeCheck: Color(red: 0.42, green: 0.22, blue: 0.72)
        case .binaryFlip: Color(red: 0.10, green: 0.30, blue: 0.60)
        case .factorFind: Color(red: 0.65, green: 0.28, blue: 0.18)
        case .memoryDigits: Color(red: 0.20, green: 0.58, blue: 0.48)
        case .coinStreak: Color(red: 0.80, green: 0.65, blue: 0.10)
        case .temperatureFlip: Color(red: 0.88, green: 0.32, blue: 0.22)
        case .wordLength: Color(red: 0.30, green: 0.50, blue: 0.75)
        case .tileFlip: Color(red: 0.55, green: 0.22, blue: 0.65)
        case .powersQuiz: Color(red: 0.18, green: 0.45, blue: 0.35)
        case .sentenceOrder: Color(red: 0.72, green: 0.42, blue: 0.12)
        case .shadowMatch: Color(red: 0.35, green: 0.35, blue: 0.48)
        case .reflexCatch: Color(red: 0.92, green: 0.42, blue: 0.18)
        case .sumTarget: Color(red: 0.22, green: 0.62, blue: 0.32)
        case .wordVowel: Color(red: 0.60, green: 0.25, blue: 0.55)
        case .gravityDrop: Color(red: 0.12, green: 0.38, blue: 0.72)
        case .pathNumber: Color(red: 0.25, green: 0.55, blue: 0.85)
        case .tapSpeedDuel: Color(red: 0.68, green: 0.18, blue: 0.28)
        case .numberSort: Color(red: 0.30, green: 0.62, blue: 0.38)
        case .quickTyping: Color(red: 0.18, green: 0.30, blue: 0.55)
        case .greaterLess: Color(red: 0.75, green: 0.35, blue: 0.10)
        case .missingOp: Color(red: 0.22, green: 0.42, blue: 0.68)
        case .colorName: Color(red: 0.72, green: 0.25, blue: 0.55)
        case .pinballBumper: Color(red: 0.12, green: 0.08, blue: 0.32)
        case .evenOddSort: Color(red: 0.18, green: 0.55, blue: 0.32)
        case .dotConnect: Color(red: 0.35, green: 0.22, blue: 0.72)
        case .letterBomb: Color(red: 0.85, green: 0.28, blue: 0.15)
        case .multiTap: Color(red: 0.88, green: 0.45, blue: 0.10)
        case .spotDiff: Color(red: 0.55, green: 0.28, blue: 0.68)
        case .colorTrail: Color(red: 0.18, green: 0.62, blue: 0.42)
        case .flashCard: Color(red: 0.25, green: 0.45, blue: 0.72)
        case .romanNumeral: Color(red: 0.55, green: 0.40, blue: 0.22)
        case .capitalCity: Color(red: 0.12, green: 0.45, blue: 0.72)
        case .triviaMix: Color(red: 0.72, green: 0.22, blue: 0.38)
        case .colorBlend: Color(red: 0.65, green: 0.28, blue: 0.72)
        case .numberBetween: Color(red: 0.22, green: 0.55, blue: 0.38)
        case .syllableCount: Color(red: 0.45, green: 0.22, blue: 0.68)
        case .abbrevMatch: Color(red: 0.18, green: 0.38, blue: 0.58)
        case .balloonPopOrder: Color(red: 0.88, green: 0.28, blue: 0.42)
        case .flashAdd: Color(red: 0.20, green: 0.55, blue: 0.30)
        case .visualPattern: Color(red: 0.38, green: 0.38, blue: 0.62)
        case .stroopSwitch: Color(red: 0.78, green: 0.32, blue: 0.18)
        case .tileRotate: Color(red: 0.18, green: 0.48, blue: 0.68)
        }
    }

    var instructions: String {
        switch self {
        case .ticTacToe:
            "Tap an empty square to place your mark, then the computer takes its turn. Line up three in a row — across, down, or diagonally — to win the round."
        case .paddleBall:
            "Tap to serve, then drag anywhere on the screen to move your paddle. Return the ball past the computer's paddle at the top to score. First to 7 points wins."
        case .solitaire:
            "Tap a card to select it, then tap where you want it to go. Stack tableau cards in descending order with alternating colors, and build the foundations up from Ace to King by suit. Tap the deck to draw more cards."
        case .snake:
            "Swipe up, down, left, or right to steer the snake. Eat the food to grow and score points, but don't hit the walls or your own tail."
        case .memoryMatch:
            "Tap two cards to flip them over. If they match, they stay face up. Find all the pairs in as few moves as you can."
        case .mergeTiles:
            "Swipe to slide all the tiles at once. When two tiles with the same number collide, they merge into one. Keep merging to reach ever-higher tiles!"
        case .simon:
            "Watch the pads light up, then tap them back in the same order. Each round adds one more step to the sequence — one mistake ends the game."
        case .whackAMole:
            "Tap the moles as they pop out of their holes. Each hit scores a point. Get as many as you can before the 30-second timer runs out."
        case .fourInARow:
            "Tap a column to drop your disc. Connect four in a row — across, down, or diagonally — before the computer does."
        case .slidePuzzle:
            "Tap a tile next to the empty space to slide it there. Put the numbers in order, reading left to right, with the empty space ending up in the bottom-right corner."
        case .colorFlood:
            "Pick a color from the palette to flood-fill your region from the top-left corner. Absorb the entire board in 22 moves or fewer to win."
        case .reactionTap:
            "Wait for the box to turn green, then tap as fast as you can. Tap too early and you'll have to try again. Your best time is saved between rounds."
        case .mathRush:
            "Solve arithmetic questions as fast as you can — addition, subtraction, and multiplication. Pick the correct answer from four choices. You have 60 seconds."
        case .bubblePop:
            "Bubbles float up from the bottom of the screen. Tap them to pop before they escape off the top. How many can you pop in 30 seconds?"
        case .pegJump:
            "Tap a peg to select it, then tap an empty hole two spaces away to jump. The peg you jump over is removed. Try to leave just one peg on the board."
        case .numberHunt:
            "Fifteen numbered circles are scattered across the screen. Tap them in order from 1 to 15 as quickly as you can. Beat your best time!"
        case .towerStack:
            "A block slides back and forth at the top of the stack. Tap to drop it. Only the part that lands on the block below sticks — the rest falls away. Keep stacking!"
        case .targetTap:
            "A circular target appears with a shrinking ring showing time remaining. Tap it before the ring runs out — bigger targets score more points. Miss three and it's game over."
        case .oddEvenRush:
            "A number appears on screen. Tap ODD if it's odd, or EVEN if it's even. You have 60 seconds and 3 lives — wrong answers cost a life."
        case .speedTap:
            "Hit the big button as many times as you can in 10 seconds. Your best score is saved. Try to beat it every round!"
        case .holdTimer:
            "Press and hold the button, then release when you think the target time has passed. The closer you are, the higher your rating."
        case .colorFlash:
            "A color name is shown in a different ink color — this is the Stroop effect! Tap the button that matches the INK color, not the word. You have 60 seconds and 3 lives."
        case .rockPaperScissors:
            "Tap Rock, Paper, or Scissors to play your move against the computer. Rock beats Scissors, Scissors beats Paper, Paper beats Rock. First to 5 wins!"
        case .gridFlash:
            "A grid of cells flashes briefly — some are lit. Then you must tap the cells that were lit from memory. Rounds get harder as more cells light up."
        case .higherLower:
            "A playing card is shown. Tap Higher if you think the next card will be higher, or Lower if it will be lower. Get it wrong and the game ends. Ties always count as correct."
        case .primeRush:
            "A number appears — is it prime? Tap Yes or No as quickly as you can. You have 60 seconds and 3 lives. Remember: 1 is not prime, 2 is the only even prime."
        case .coinCatch:
            "Coins fall from the sky. Drag your basket left and right to catch as many as possible. Miss 5 coins and the game is over."
        case .lightsOut:
            "Tapping a cell toggles it and all its neighbors. The goal is to turn every light off. Plan ahead — each tap has a ripple effect on surrounding cells."
        case .sequenceNext:
            "Four numbers are shown following a pattern. Pick the correct fifth number from four choices. Patterns include adding, subtracting, and multiplying sequences."
        case .cardWar:
            "Tap Flip to reveal the top card for each player. The higher card wins both cards. The player with the most cards when the deck runs out wins the war."
        case .diceScore:
            "Roll 6 dice up to 3 times per turn. Tap dice to hold them between rolls. After rolling, tap a scoring category to fill it. Fill all 15 categories for your final score."
        case .wordScramble:
            "A common word has been scrambled. Use the letter buttons to spell out the correct word, then tap Submit. You have 3 skips — use them wisely!"
        case .starDodge:
            "Drag your ship left and right to dodge the incoming stars. Your score increases every second you survive. Stars get faster over time!"
        case .dotsBoxes:
            "Take turns drawing a line between two adjacent dots. If your line completes a box, you score a point and go again. The player with the most boxes at the end wins."
        case .flipGrid:
            "Place a disc on the board to capture the opponent's discs between yours. Captured discs flip to your color. The player with the most discs when the board is full wins."
        case .trueFalse:
            "A statement appears on screen. Tap TRUE if it's a fact, or FALSE if it's not. You have 60 seconds and 3 lives — answer as many as you can."
        case .sortBalls:
            "A colored ball appears. Tap the bin that matches its color before time runs out. Wrong answers cost a life — sort as many as you can in 60 seconds."
        case .countdown:
            "A target time is shown. Tap the button to start the countdown, then tap again when you think the target time has elapsed. The closer you are, the higher your score."
        case .tapSequence:
            "Numbered buttons light up one by one — watch the sequence carefully. Then repeat the exact same order by tapping the buttons yourself. Each correct round adds one more step."
        case .nim:
            "A pile of sticks is on the table. Take turns removing 1, 2, or 3 sticks. The player who is forced to take the last stick loses. Outsmart the CPU!"
        case .fractionMatch:
            "A fraction is shown. Pick its decimal equivalent from four choices. You have 60 seconds and 3 lives — wrong answers cost a life."
        case .rhymePick:
            "A word is shown. Tap the word from the four choices that rhymes with it. You have 60 seconds and 3 lives."
        case .categorySort:
            "A word appears — quickly tap whether it's an Animal, Food, Place, or Object. 60 seconds, 3 lives. Wrong answers cost a life."
        case .letterOrder:
            "All 26 letters of the alphabet are scattered on screen. Tap them in alphabetical order from A to Z as fast as you can. The next target letter is always highlighted."
        case .quickMultiply:
            "A multiplication question appears. Pick the correct answer from four options as fast as you can. You have 60 seconds and 3 lives."
        case .spellingCheck:
            "A word appears on screen — is it spelled correctly or not? Tap Correct or Wrong as fast as you can. 60 seconds, 3 lives."
        case .clockRead:
            "An analog clock face shows a time. Pick the correct time from four options. You have 60 seconds and 3 lives."
        case .speedRead:
            "A word flashes on screen very briefly. Then four options appear — which word did you see? Harder difficulties flash the word faster."
        case .brickBreak:
            "Drag your paddle left and right to bounce the ball and break the bricks. Clear all the bricks to win. Miss the ball three times and it's game over."
        case .mazeRun:
            "Navigate through a generated maze using the arrow buttons. Find the path from the top-left corner to the bottom-right exit. Try to do it in as few steps as possible."
        case .towerHanoi:
            "Move all 4 discs from the left peg to the right peg. Tap a peg to select it, then tap the destination peg. You can never place a larger disc on top of a smaller one."
        case .shootingGallery:
            "Targets move back and forth across the screen. Tap them to score — smaller targets are worth more points. You have 30 seconds. How high can you score?"
        case .sudokuLite:
            "Fill the 4×4 grid so every row, column, and 2×2 box contains the numbers 1 through 4 exactly once. Tap a cell to select it, then tap a number to fill it in."
        case .balanceScale:
            "A scale has weights on the left pan. Pick the single weight from the four choices that will perfectly balance the right side."
        case .emojiMath:
            "Two equations using emoji icons reveal the value of each symbol. Use that information to solve the third equation. Pick the correct answer from four options."
        case .anagramPick:
            "A set of letters is shown. One of the four choices is a real English word made from those exact letters. The others are made-up — find the real word!"
        case .wordChain:
            "Type a word to start a chain. Each word must begin with the last letter of the previous word. Then the CPU responds. If either player can't find a valid word, they lose!"
        case .palindromeCheck:
            "A word or number appears on screen. Tap YES if it reads the same forwards and backwards (a palindrome), or NO if it doesn't. 60 seconds, 3 lives."
        case .binaryFlip:
            "A binary number is shown — convert it to decimal and pick the correct answer from four options. 60 seconds and 3 lives to test your binary math skills."
        case .factorFind:
            "A number appears. Tap the option that divides it evenly — the others are imposters! 60 seconds, 3 lives."
        case .memoryDigits:
            "A number flashes on screen briefly, then disappears. Type it back from memory. Each correct answer adds a digit and gets harder. Wrong answers shrink it back down."
        case .coinStreak:
            "Predict whether the next coin flip will be Heads or Tails. Correct streaks multiply your points — chain them for big scores! You have 10 flips per game."
        case .temperatureFlip:
            "A temperature is shown in Celsius or Fahrenheit. Pick the correct conversion from four choices. 60 seconds, 3 lives."
        case .wordLength:
            "Two words appear — tap the longer one. It's harder than it looks! Ties count as correct. 60 seconds, 3 lives."
        case .tileFlip:
            "A 4×4 grid of colored tiles is shown. Tap any tile to cycle its color. The goal: make every tile the same color. Try to do it in as few taps as possible!"
        case .powersQuiz:
            "A power expression appears — like 7² or 4³. Pick the correct value from four choices. 60 seconds, 3 lives."
        case .sentenceOrder:
            "The words of a common phrase are shuffled. Tap the words in the correct order to reconstruct the sentence. Score a point for each sentence you fix."
        case .shadowMatch:
            "A geometric shape silhouette is shown. Name it correctly from four choices. Shapes get trickier — from circles and squares to stars and pentagons."
        case .reflexCatch:
            "A glowing dot appears somewhere on screen and disappears after a short time. Tap it before it vanishes! Each round the dot gets smaller and the window gets shorter."
        case .sumTarget:
            "A target number is shown. Select tiles from the grid that add up to exactly that number, then tap Submit. You have 60 seconds — score a point for each correct sum."
        case .wordVowel:
            "A word appears — count its vowels (A, E, I, O, U) and pick the correct count from four options. 60 seconds, 3 lives."
        case .gravityDrop:
            "A ball drops from the top of the screen. Tap to release your catcher at just the right moment to catch it. Miss 3 balls and the game ends!"
        case .pathNumber:
            "Numbers 1 through 16 are scattered in a grid. Tap them in order from 1 to 16 as fast as you can. The next target is highlighted in blue."
        case .tapSpeedDuel:
            "Two players on one screen! Tap your side as many times as possible in 10 seconds. Left side vs right side — most taps wins!"
        case .numberSort:
            "16 numbers are shuffled in a grid. Tap two numbers to swap them. Sort all numbers in ascending order with as few swaps as possible."
        case .quickTyping:
            "A word appears on screen. Type it correctly as fast as you can, then the next word appears. Score as many words as possible in 30 seconds."
        case .greaterLess:
            "Two numbers are shown. Tap the left or right button to indicate which number is greater. 60 seconds, 3 lives — equal numbers are always wrong!"
        case .missingOp:
            "An equation is shown with the operator hidden: 3 ? 4 = 12. Tap +, −, ×, or ÷ to fill in the missing symbol. 60 seconds, 3 lives."
        case .colorName:
            "A color swatch is displayed. Name it correctly from four options — from common colors like Teal and Coral to trickier ones like Cerulean and Chartreuse. 60 seconds, 3 lives."
        case .pinballBumper:
            "Tap the bumpers to score points before time runs out. Each bumper has limited charges, and your score multiplier grows with consecutive hits!"
        case .evenOddSort:
            "Numbers fall from the top of the screen. Tap EVEN or ODD to sort them into the correct bin. Tap before the next wave appears. 3 mistakes ends the game."
        case .dotConnect:
            "Watch as dots light up in sequence, forming a path. Then tap the dots in the exact same order from memory. Each correct round adds one more step to the pattern."
        case .letterBomb:
            "Letters fall from the sky. Tap only the VOWELS (A, E, I, O, U) before they reach the bottom. Tapping a consonant costs a life — let them fall!"
        case .multiTap:
            "Multiple glowing targets appear on screen. Tap every single one before the timer runs out! Each round adds more targets and shortens the time window."
        case .spotDiff:
            "Two emoji grids are shown side by side. One cell on the RIGHT is different. Find it and tap it. 60 seconds, 3 lives — wrong taps cost a life!"
        case .colorTrail:
            "Drag your finger across the blank board to paint tiles. Switch colors using the palette at the bottom. The goal is to fill every single tile. Try to do it in as few strokes as possible."
        case .flashCard:
            "Study 20 facts as flash cards. Tap the card to flip it and reveal the answer. Then swipe Got It or Didn't Know. The deck reshuffles so you can review any you missed."
        case .romanNumeral:
            "A Roman numeral is shown — convert it to its decimal value and pick the correct answer from four choices. 60 seconds, 3 lives."
        case .capitalCity:
            "A country is shown. Pick its capital city from four options. 30 countries covered — from easy ones to tricky ones. 60 seconds, 3 lives."
        case .triviaMix:
            "Mixed general knowledge questions across science, geography, and math. Pick the correct answer from four choices. 60 seconds, 3 lives."
        case .colorBlend:
            "Two paint colors are shown. What color do you get when you mix them? Pick from four options. 60 seconds, 3 lives."
        case .numberBetween:
            "Two numbers are shown. Pick the number from the four choices that falls strictly between them. 60 seconds, 3 lives."
        case .syllableCount:
            "A word appears. Count how many syllables it has and pick the right number. From one-syllable words to five-syllable tongue-twisters! 60 seconds, 3 lives."
        case .abbrevMatch:
            "A common abbreviation is shown — like NASA or URL. Pick what it stands for from four options. 60 seconds, 3 lives."
        case .balloonPopOrder:
            "Numbered balloons float on screen. Tap them in order from 1 upward. Miss the sequence and lose a life. Each round adds more balloons!"
        case .flashAdd:
            "Numbers flash on screen one at a time. Add them all up in your head, then type the total from memory. Get it right and face more numbers next round!"
        case .visualPattern:
            "A 3×3 grid follows a pattern — same shape per row, same color per column. The bottom-right cell is missing. Pick which shape and color completes the pattern."
        case .stroopSwitch:
            "A word is shown in a colored ink. An indicator tells you to either READ the word or NAME the ink color. Switch fast — the rule flips every question! 60 seconds, 3 lives."
        case .tileRotate:
            "A grid of arrow tiles points in random directions. Tap any tile to rotate it 90°. The goal is to make ALL tiles point the same direction in as few taps as possible."
        }
    }

    @ViewBuilder var destination: some View {
        switch self {
        case .ticTacToe: GameScreen(game: self) { TicTacToeView() }
        case .paddleBall: GameScreen(game: self) { PaddleBallView() }
        case .solitaire: GameScreen(game: self) { SolitaireView() }
        case .snake: GameScreen(game: self) { SnakeView() }
        case .memoryMatch: GameScreen(game: self) { MemoryMatchView() }
        case .mergeTiles: GameScreen(game: self) { MergeTilesView() }
        case .simon: GameScreen(game: self) { SimonView() }
        case .whackAMole: GameScreen(game: self) { WhackAMoleView() }
        case .fourInARow: GameScreen(game: self) { FourInARowView() }
        case .slidePuzzle: GameScreen(game: self) { SlidePuzzleView() }
        case .colorFlood: GameScreen(game: self) { ColorFloodView() }
        case .reactionTap: GameScreen(game: self) { ReactionTapView() }
        case .mathRush: GameScreen(game: self) { MathRushView() }
        case .bubblePop: GameScreen(game: self) { BubblePopView() }
        case .pegJump: GameScreen(game: self) { PegJumpView() }
        case .numberHunt: GameScreen(game: self) { NumberHuntView() }
        case .towerStack: GameScreen(game: self) { TowerStackView() }
        case .targetTap: GameScreen(game: self) { TargetTapView() }
        case .oddEvenRush: GameScreen(game: self) { OddEvenRushView() }
        case .speedTap: GameScreen(game: self) { SpeedTapView() }
        case .holdTimer: GameScreen(game: self) { HoldTimerView() }
        case .colorFlash: GameScreen(game: self) { ColorFlashView() }
        case .rockPaperScissors: GameScreen(game: self) { RockPaperScissorsView() }
        case .gridFlash: GameScreen(game: self) { GridFlashView() }
        case .higherLower: GameScreen(game: self) { HigherLowerView() }
        case .primeRush: GameScreen(game: self) { PrimeRushView() }
        case .coinCatch: GameScreen(game: self) { CoinCatchView() }
        case .lightsOut: GameScreen(game: self) { LightsOutView() }
        case .sequenceNext: GameScreen(game: self) { SequenceNextView() }
        case .cardWar: GameScreen(game: self) { CardWarView() }
        case .diceScore: GameScreen(game: self) { DiceScoreView() }
        case .wordScramble: GameScreen(game: self) { WordScrambleView() }
        case .starDodge: GameScreen(game: self) { StarDodgeView() }
        case .dotsBoxes: GameScreen(game: self) { DotsBoxesView() }
        case .flipGrid: GameScreen(game: self) { FlipGridView() }
        case .trueFalse: GameScreen(game: self) { TrueFalseView() }
        case .sortBalls: GameScreen(game: self) { SortBallsView() }
        case .countdown: GameScreen(game: self) { CountdownView() }
        case .tapSequence: GameScreen(game: self) { TapSequenceView() }
        case .nim: GameScreen(game: self) { NimView() }
        case .fractionMatch: GameScreen(game: self) { FractionMatchView() }
        case .rhymePick: GameScreen(game: self) { RhymePickView() }
        case .categorySort: GameScreen(game: self) { CategorySortView() }
        case .letterOrder: GameScreen(game: self) { LetterOrderView() }
        case .quickMultiply: GameScreen(game: self) { QuickMultiplyView() }
        case .spellingCheck: GameScreen(game: self) { SpellingCheckView() }
        case .clockRead: GameScreen(game: self) { ClockReadView() }
        case .speedRead: GameScreen(game: self) { SpeedReadView() }
        case .brickBreak: GameScreen(game: self) { BrickBreakView() }
        case .mazeRun: GameScreen(game: self) { MazeRunView() }
        case .towerHanoi: GameScreen(game: self) { TowerHanoiView() }
        case .shootingGallery: GameScreen(game: self) { ShootingGalleryView() }
        case .sudokuLite: GameScreen(game: self) { SudokuLiteView() }
        case .balanceScale: GameScreen(game: self) { BalanceScaleView() }
        case .emojiMath: GameScreen(game: self) { EmojiMathView() }
        case .anagramPick: GameScreen(game: self) { AnagramPickView() }
        case .wordChain: GameScreen(game: self) { WordChainView() }
        case .palindromeCheck: GameScreen(game: self) { PalindromeCheckView() }
        case .binaryFlip: GameScreen(game: self) { BinaryFlipView() }
        case .factorFind: GameScreen(game: self) { FactorFindView() }
        case .memoryDigits: GameScreen(game: self) { MemoryDigitsView() }
        case .coinStreak: GameScreen(game: self) { CoinStreakView() }
        case .temperatureFlip: GameScreen(game: self) { TemperatureFlipView() }
        case .wordLength: GameScreen(game: self) { WordLengthView() }
        case .tileFlip: GameScreen(game: self) { TileFlipView() }
        case .powersQuiz: GameScreen(game: self) { PowersQuizView() }
        case .sentenceOrder: GameScreen(game: self) { SentenceOrderView() }
        case .shadowMatch: GameScreen(game: self) { ShadowMatchView() }
        case .reflexCatch: GameScreen(game: self) { ReflexCatchView() }
        case .sumTarget: GameScreen(game: self) { SumTargetView() }
        case .wordVowel: GameScreen(game: self) { WordVowelView() }
        case .gravityDrop: GameScreen(game: self) { GravityDropView() }
        case .pathNumber: GameScreen(game: self) { PathNumberView() }
        case .tapSpeedDuel: GameScreen(game: self) { TapSpeedDuelView() }
        case .numberSort: GameScreen(game: self) { NumberSortView() }
        case .quickTyping: GameScreen(game: self) { QuickTypingView() }
        case .greaterLess: GameScreen(game: self) { GreaterLessView() }
        case .missingOp: GameScreen(game: self) { MissingOpView() }
        case .colorName: GameScreen(game: self) { ColorNameView() }
        case .pinballBumper: GameScreen(game: self) { PinballBumperView() }
        case .evenOddSort: GameScreen(game: self) { EvenOddSortView() }
        case .dotConnect: GameScreen(game: self) { DotConnectView() }
        case .letterBomb: GameScreen(game: self) { LetterBombView() }
        case .multiTap: GameScreen(game: self) { MultiTapView() }
        case .spotDiff: GameScreen(game: self) { SpotDiffView() }
        case .colorTrail: GameScreen(game: self) { ColorTrailView() }
        case .flashCard: GameScreen(game: self) { FlashCardView() }
        case .romanNumeral: GameScreen(game: self) { RomanNumeralView() }
        case .capitalCity: GameScreen(game: self) { CapitalCityView() }
        case .triviaMix: GameScreen(game: self) { TriviaMixView() }
        case .colorBlend: GameScreen(game: self) { ColorBlendView() }
        case .numberBetween: GameScreen(game: self) { NumberBetweenView() }
        case .syllableCount: GameScreen(game: self) { SyllableCountView() }
        case .abbrevMatch: GameScreen(game: self) { AbbrevMatchView() }
        case .balloonPopOrder: GameScreen(game: self) { BalloonPopOrderView() }
        case .flashAdd: GameScreen(game: self) { FlashAddView() }
        case .visualPattern: GameScreen(game: self) { VisualPatternView() }
        case .stroopSwitch: GameScreen(game: self) { StroopSwitchView() }
        case .tileRotate: GameScreen(game: self) { TileRotateView() }
        }
    }
}

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var adConsentManager = AdConsentManager()
    @State private var interstitialCoordinator = InterstitialAdCoordinator()
    @State private var hasShownOpenAd = false
    @State private var searchText = ""
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    private var filteredGames: [Game] {
        if searchText.isEmpty { return Game.allCases }
        let query = searchText.lowercased()
        return Game.allCases.filter {
            $0.rawValue.lowercased().contains(query) ||
            $0.subtitle.lowercased().contains(query)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if path.isEmpty {
                BannerAdView(canRequestAds: adConsentManager.canRequestAds)
            }
            NavigationStack(path: $path) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        if searchText.isEmpty {
                            HeroHeader()
                        }

                        if filteredGames.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                                .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(filteredGames) { game in
                                    NavigationLink(value: game) {
                                        GameTile(game: game)
                                    }
                                    .buttonStyle(.plain)
                                }
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
                .searchable(text: $searchText, prompt: "Search games")
                .toolbar {
                    if adConsentManager.privacyOptionsRequired {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                adConsentManager.showPrivacyOptions()
                            } label: {
                                Image(systemName: "hand.raised.fill")
                            }
                            .accessibilityLabel("Privacy options")
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            HighScoresView()
                        } label: {
                            Image(systemName: "trophy.fill")
                        }
                    }
                }
                .navigationDestination(for: Game.self) { game in
                    game.destination
                }
            }
            .tint(Color(red: 0.22, green: 0.45, blue: 0.95))
        }
        .onAppear {
            adConsentManager.prepareAds()
            interstitialCoordinator.loadAd(canRequestAds: adConsentManager.canRequestAds)
        }
        .onChange(of: adConsentManager.canRequestAds) { _, canRequestAds in
            if canRequestAds {
                interstitialCoordinator.loadAd(canRequestAds: true)
            }
        }
        .onChange(of: interstitialCoordinator.isReady) { _, ready in
            if ready && !hasShownOpenAd {
                hasShownOpenAd = true
                interstitialCoordinator.showAd()
            }
        }
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
                Text("Over one hundred quick games for a short break.")
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

/// Wraps every game with a shared layout. Shows the game's instructions
/// automatically the first time a game is opened, and on demand from a
/// toolbar button.
struct GameScreen<Content: View>: View {
    let game: Game
    @ViewBuilder var content: Content

    @State private var showingInstructions = false

    private var hasSeenInstructionsKey: String { "hasSeenInstructions.\(game.id)" }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(game.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingInstructions = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .accessibilityLabel("How to play")
                }
            }
            .sheet(isPresented: $showingInstructions) {
                InstructionsSheet(game: game)
            }
            .onAppear {
                if !UserDefaults.standard.bool(forKey: hasSeenInstructionsKey) {
                    UserDefaults.standard.set(true, forKey: hasSeenInstructionsKey)
                    showingInstructions = true
                }
            }
    }
}

private struct InstructionsSheet: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: game.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [game.color.opacity(0.95), game.color.opacity(0.68)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )

            Text("How to Play \(game.rawValue)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)

            Text(game.instructions)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                dismiss()
            } label: {
                Text("Got It")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(game.color)
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ContentView()
}
