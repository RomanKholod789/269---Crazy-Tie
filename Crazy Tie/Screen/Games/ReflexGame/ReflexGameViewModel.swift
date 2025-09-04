import SwiftUI
import Combine

struct Ball: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let targetPlayer: Player
    var scale: CGFloat = 0.1
    var opacity: Double = 1.0
    var isActive = true
}

enum ReflexGameState {
    case waiting
    case countdown
    case playing
    case finished
}

final class ReflexGameViewModel: ObservableObject {
    @Published var gameState: ReflexGameState = .waiting
    @Published var countdown = 3
    @Published var balls: [Ball] = []
    @Published var player1Score = 0
    @Published var player2Score = 0
    @Published var player1Correct = 0
    @Published var player1Wrong = 0
    @Published var player2Correct = 0
    @Published var player2Wrong = 0
    @Published var timeRemaining = 30
    @Published var showGameOver = false
    @Published var winner: Player?
    @Published var ballsSpawned = 0
    
    let totalBalls = 50
    private var countdownTimer: Timer?
    private var gameTimer: Timer?
    private var ballSpawnTimer: Timer?
    
    var gameOverMessage: String {
        if let winner = winner {
            return "\(winner.displayName) wins!\nScore: \(player1Score) - \(player2Score)"
        } else {
            return "It's a tie!\nScore: \(player1Score) - \(player2Score)"
        }
    }
    
    func startGame() {
        resetGame()
    }
    
    func resetGame() {
        gameState = .waiting
        balls.removeAll()
        player1Score = 0
        player2Score = 0
        player1Correct = 0
        player1Wrong = 0
        player2Correct = 0
        player2Wrong = 0
        timeRemaining = 30
        ballsSpawned = 0
        winner = nil
        showGameOver = false
        
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
                self.startPlaying()
            }
        }
    }
    
    private func startPlaying() {
        gameState = .playing
        timeRemaining = 30
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.endGame()
            }
        }
        
        // Start ball spawning
        ballSpawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            if self.ballsSpawned < self.totalBalls && self.gameState == .playing {
                self.spawnBall()
            } else if self.balls.isEmpty || self.ballsSpawned >= self.totalBalls {
                timer.invalidate()
                if self.balls.isEmpty {
                    self.endGame()
                }
            }
        }
    }
    
    private func spawnBall() {
        let targetPlayer: Player = Bool.random() ? .player1 : .player2
        let ballColor: Color = targetPlayer == .player1 ? .themeRed : .themeOrange
        
        let ball = Ball(
            position: randomPosition(),
            color: ballColor,
            size: CGFloat.random(in: 40...60),
            targetPlayer: targetPlayer
        )
        
        balls.append(ball)
        ballsSpawned += 1
        
        // Animate ball appearance
        withAnimation(.easeOut(duration: 0.3)) {
            if let index = balls.firstIndex(where: { $0.id == ball.id }) {
                balls[index].scale = 1.0
            }
        }
        
        // Remove ball after 3 seconds if not tapped
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.removeBall(ball.id)
        }
    }
    
    private func randomPosition() -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: 60...340),
            y: CGFloat.random(in: 150...600)
        )
    }
    
    func ballTapped(_ ball: Ball) {
        guard ball.isActive else { return }
        
        // Determine which player tapped (simplified - in real app, you'd detect tap location)
        // For now, we'll assume correct taps based on ball color
        let tappingPlayer: Player = ball.targetPlayer
        
        if ball.targetPlayer == tappingPlayer {
            // Correct tap
            switch tappingPlayer {
            case .player1:
                player1Score += 2
                player1Correct += 1
            case .player2:
                player2Score += 2
                player2Correct += 1
            }
        } else {
            // Wrong tap
            switch tappingPlayer {
            case .player1:
                player1Score = max(0, player1Score - 1)
                player1Wrong += 1
            case .player2:
                player2Score = max(0, player2Score - 1)
                player2Wrong += 1
            }
        }
        
        // Animate ball removal
        withAnimation(.easeIn(duration: 0.2)) {
            if let index = balls.firstIndex(where: { $0.id == ball.id }) {
                balls[index].scale = 0.1
                balls[index].opacity = 0.0
                balls[index].isActive = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.removeBall(ball.id)
        }
    }
    
    func screenTapped(at location: CGPoint) {
        // Check if tap hit any ball
        for ball in balls where ball.isActive {
            let distance = sqrt(pow(ball.position.x - location.x, 2) + pow(ball.position.y - location.y, 2))
            if distance <= ball.size / 2 {
                ballTapped(ball)
                break
            }
        }
    }
    
    private func removeBall(_ ballId: UUID) {
        balls.removeAll { $0.id == ballId }
        
        if balls.isEmpty && ballsSpawned >= totalBalls {
            endGame()
        }
    }
    
    private func endGame() {
        gameState = .finished
        gameTimer?.invalidate()
        ballSpawnTimer?.invalidate()
        
        // Determine winner
        if player1Score > player2Score {
            winner = .player1
        } else if player2Score > player1Score {
            winner = .player2
        } else {
            winner = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showGameOver = true
        }
    }
}
