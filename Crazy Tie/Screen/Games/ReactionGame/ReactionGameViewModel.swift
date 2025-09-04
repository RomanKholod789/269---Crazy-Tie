import SwiftUI
import Combine

enum GameState {
    case waiting
    case countdown
    case waitingForGreen
    case ready
    case finished
    case earlyTap
}

enum Player {
    case player1
    case player2
    
    var displayName: String {
        switch self {
        case .player1: return "PLAYER 1"
        case .player2: return "PLAYER 2"
        }
    }
    
    var color: Color {
        switch self {
        case .player1: return .themeRed
        case .player2: return .themeOrange
        }
    }
}

final class ReactionGameViewModel: ObservableObject {
    @Published var gameState: GameState = .waiting
    @Published var countdown = 3
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var currentRound = 1
    @Published var showGameOver = false
    @Published var roundWinner: Player?
    @Published var winningTime: Double?
    @Published var winReason = ""
    
    let maxRounds = 5
    private var gameStartTime: Date?
    private var countdownTimer: Timer?
    private var readyTimer: Timer?
    
    var gameOverMessage: String {
        let finalWinner = player1Score > player2Score ? Player.player1 : Player.player2
        return "\(finalWinner.displayName) wins the game!\nFinal Score: \(player1Score) - \(player2Score)"
    }
    
    func startGame() {
        resetRound()
    }
    
    func resetGame() {
        player1Score = 0
        player2Score = 0
        currentRound = 1
        showGameOver = false
        resetRound()
    }
    
    func nextRound() {
        currentRound += 1
        resetRound()
    }
    
    private func resetRound() {
        gameState = .waiting
        roundWinner = nil
        winningTime = nil
        winReason = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startCountdown()
        }
    }
    
    private func startCountdown() {
        countdown = 3
        gameState = .countdown
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdown > 1 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                self.startReadyPhase()
            }
        }
    }
    
    private func startReadyPhase() {
        // Show "Wait..." state first
        gameState = .waitingForGreen
        
        // Random delay before showing ready state (2-5 seconds)
        let randomDelay = Double.random(in: 2...5)
        
        readyTimer = Timer.scheduledTimer(withTimeInterval: randomDelay, repeats: false) { _ in
            self.gameState = .ready
            self.gameStartTime = Date()
        }
    }
    
    func playerTapped(_ player: Player) {
        // Only allow tapping in .ready state
        guard gameState == .ready, let startTime = gameStartTime else {
            // Early tap - penalize player (only if not already in earlyTap or finished state)
            if gameState != .earlyTap && gameState != .finished {
                handleEarlyTap(player)
            }
            return
        }
        
        let reactionTime = Date().timeIntervalSince(startTime)
        winningTime = reactionTime
        roundWinner = player
        
        switch player {
        case .player1:
            player1Score += 1
        case .player2:
            player2Score += 1
        }
        
        gameState = .finished
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.currentRound >= self.maxRounds {
                self.showGameOver = true
            } else {
                self.nextRound()
            }
        }
    }
    
    private func handleEarlyTap(_ player: Player) {
        // Show early tap message
        gameState = .earlyTap
        roundWinner = player == .player1 ? .player2 : .player1
        winReason = "\(player.displayName) tapped too early!"
        
        // Award point to other player
        switch roundWinner {
        case .player1:
            player1Score += 1
        case .player2:
            player2Score += 1
        case .none:
            break
        }
        
        countdownTimer?.invalidate()
        readyTimer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.currentRound >= self.maxRounds {
                self.showGameOver = true
            } else {
                self.nextRound()
            }
        }
    }
}
