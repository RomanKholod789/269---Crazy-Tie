import SwiftUI
import Combine

struct TapEffect: Identifiable {
    let id = UUID()
    let player: Player
    let position: CGPoint
    var scale: CGFloat = 0.1
    var opacity: Double = 1.0
}

enum TapBattleState {
    case waiting
    case countdown
    case playing
    case finished
}

final class TapBattleViewModel: ObservableObject {
    @Published var gameState: TapBattleState = .waiting
    @Published var countdown = 3
    @Published var player1Taps = 0
    @Published var player2Taps = 0
    @Published var timeRemaining = 10
    @Published var showGameOver = false
    @Published var winner: Player?
    @Published var tapEffects: [TapEffect] = []
    
    private var countdownTimer: Timer?
    private var gameTimer: Timer?
    private let gameDuration = 10
    
    var gameOverMessage: String {
        if let winner = winner {
            return "\(winner.displayName) wins!\nFinal Score: \(player1Taps) - \(player2Taps)"
        } else {
            return "It's a tie!\nFinal Score: \(player1Taps) - \(player2Taps)"
        }
    }
    
    func startGame() {
        resetGame()
    }
    
    func resetGame() {
        gameState = .waiting
        player1Taps = 0
        player2Taps = 0
        timeRemaining = gameDuration
        winner = nil
        showGameOver = false
        tapEffects.removeAll()
        
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
                self.startBattle()
            }
        }
    }
    
    private func startBattle() {
        gameState = .playing
        timeRemaining = gameDuration
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.endGame()
            }
        }
    }
    
    func playerTapped(_ player: Player) {
        guard gameState == .playing else { return }
        
        // Increment tap count
        switch player {
        case .player1:
            player1Taps += 1
        case .player2:
            player2Taps += 1
        }
        
        // Add tap effect
        let tapPosition = CGPoint(
            x: CGFloat.random(in: 50...300),
            y: CGFloat.random(in: 50...200)
        )
        
        let effect = TapEffect(player: player, position: tapPosition)
        tapEffects.append(effect)
        
        // Animate effect
        withAnimation(.easeOut(duration: 0.5)) {
            if let index = tapEffects.firstIndex(where: { $0.id == effect.id }) {
                tapEffects[index].scale = 2.0
                tapEffects[index].opacity = 0.0
            }
        }
        
        // Remove effect after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tapEffects.removeAll { $0.id == effect.id }
        }
    }
    
    private func endGame() {
        gameState = .finished
        
        // Determine winner
        if player1Taps > player2Taps {
            winner = .player1
        } else if player2Taps > player1Taps {
            winner = .player2
        } else {
            winner = nil // Tie
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showGameOver = true
        }
    }
}
