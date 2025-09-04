import SwiftUI
import Combine

enum ChickenGameState {
    case waiting
    case countdown
    case building
    case danger
    case finished
}

final class ChickenGameViewModel: ObservableObject {
    @Published var gameState: ChickenGameState = .waiting
    @Published var countdown = 3
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var currentRound = 1
    @Published var showGameOver = false
    @Published var roundWinner: Player?
    @Published var tensionLevel: CGFloat = 0
    @Published var tensionPulse = false
    @Published var dangerPulse = false
    @Published var dangerTimeLeft: Double = 3.0
    @Published var player1Tapped = false
    @Published var player2Tapped = false
    @Published var winReason = ""
    
    private var player1TapTime: Date?
    private var player2TapTime: Date?
    
    let maxRounds = 5
    private var countdownTimer: Timer?
    private var tensionTimer: Timer?
    private var dangerTimer: Timer?
    private var dangerCountdownTimer: Timer?
    private let buildingDuration: Double = 4.0
    private let dangerDuration: Double = 3.0
    
    var gameOverMessage: String {
        let finalWinner = player1Score > player2Score ? Player.player1 : Player.player2
        return "\(finalWinner.displayName) wins the nerve battle!\nFinal Score: \(player1Score) - \(player2Score)"
    }
    
    func startGame() {
        resetGame()
    }
    
    func resetGame() {
        player1Score = 0
        player2Score = 0
        currentRound = 1
        showGameOver = false
        resetRound()
    }
    
    func nextRound() {
        if currentRound < maxRounds {
            currentRound += 1
            resetRound()
        }
    }
    
    private func resetRound() {
        gameState = .waiting
        roundWinner = nil
        winReason = ""
        tensionLevel = 0
        dangerTimeLeft = dangerDuration
        player1Tapped = false
        player2Tapped = false
        player1TapTime = nil
        player2TapTime = nil
        tensionPulse = false
        dangerPulse = false
        
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
                self.startBuildingTension()
            }
        }
    }
    
    private func startBuildingTension() {
        gameState = .building
        tensionLevel = 0
        tensionPulse = true
        
        // Build tension over time
        tensionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.tensionLevel < 1.0 {
                self.tensionLevel += 0.1 / self.buildingDuration
            } else {
                timer.invalidate()
                self.startDangerZone()
            }
        }
    }
    
    private func startDangerZone() {
        gameState = .danger
        tensionPulse = false
        dangerPulse = true
        dangerTimeLeft = dangerDuration
        
        // Start danger countdown
        dangerCountdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.dangerTimeLeft > 0 {
                self.dangerTimeLeft -= 0.1
            } else {
                timer.invalidate()
                self.endRoundByTimeout()
            }
        }
    }
    
    func playerTapped(_ player: Player) {
        switch gameState {
        case .building:
            // Early tap - player loses
            handleEarlyTap(player)
        case .danger:
            // Valid tap in danger zone
            handleDangerTap(player)
        default:
            break
        }
    }
    
    private func handleEarlyTap(_ player: Player) {
        // Player who tapped early loses immediately
        let winner: Player = player == .player1 ? .player2 : .player1
        roundWinner = winner
        winReason = "\(player.displayName) tapped too early!"
        
        switch winner {
        case .player1:
            player1Score += 1
        case .player2:
            player2Score += 1
        }
        
        finishRound()
    }
    
    private func handleDangerTap(_ player: Player) {
        let currentTime = Date()
        
        // Mark player as tapped and record time
        switch player {
        case .player1:
            if !player1Tapped {
                player1Tapped = true
                player1TapTime = currentTime
            }
        case .player2:
            if !player2Tapped {
                player2Tapped = true
                player2TapTime = currentTime
            }
        }
        
        // Check if both players have now tapped
        if player1Tapped && player2Tapped {
            // Both tapped - whoever tapped LATER wins!
            guard let time1 = player1TapTime, let time2 = player2TapTime else { return }
            
            if time1 > time2 {
                // Player 1 tapped later - wins
                roundWinner = .player1
                player1Score += 1
                winReason = "Player 1 held their nerve longer!"
            } else {
                // Player 2 tapped later - wins  
                roundWinner = .player2
                player2Score += 1
                winReason = "Player 2 held their nerve longer!"
            }
            
            // End round immediately when both tapped
            dangerCountdownTimer?.invalidate()
            finishRound()
        }
        // If only one tapped, continue until timeout
    }
    
    private func endRoundByTimeout() {
        if !player1Tapped && !player2Tapped {
            // Both players waited too long - no winner
            roundWinner = nil
            winReason = "Both players were too late!"
        } else if player1Tapped && !player2Tapped {
            // Player 1 tapped in time, Player 2 was too late - Player 1 wins
            roundWinner = .player1
            player1Score += 1
            winReason = "Player 1 tapped in time, Player 2 was too late!"
        } else if !player1Tapped && player2Tapped {
            // Player 2 tapped in time, Player 1 was too late - Player 2 wins
            roundWinner = .player2
            player2Score += 1
            winReason = "Player 2 tapped in time, Player 1 was too late!"
        } else {
            // This shouldn't happen as both tapped cases are handled in handleDangerTap
            roundWinner = nil
            winReason = "Unexpected timeout state!"
        }
        
        finishRound()
    }
    
    private func finishRound() {
        gameState = .finished
        dangerPulse = false
        
        // Cancel all timers
        tensionTimer?.invalidate()
        dangerTimer?.invalidate()
        dangerCountdownTimer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if self.currentRound >= self.maxRounds {
                self.showGameOver = true
            } else {
                self.nextRound()
            }
        }
    }
}
