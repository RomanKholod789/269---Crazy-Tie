import SwiftUI

struct ReactionGameView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel = ReactionGameViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            // Dark overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Player 2 area (top half)
                GeometryReader { geometry in
                    reactionPlayerAreaView(
                        player: .player2,
                        geometry: geometry,
                        isTopPlayer: true
                    )
                }
                .frame(maxHeight: .infinity)
                
                // Middle section with header and info
                middleSectionView
                
                // Player 1 area (bottom half)
                GeometryReader { geometry in
                    reactionPlayerAreaView(
                        player: .player1,
                        geometry: geometry,
                        isTopPlayer: false
                    )
                }
                .frame(maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .alert("Game Over!", isPresented: $viewModel.showGameOver) {
            Button("Play Again") {
                viewModel.resetGame()
            }
            Button("Back to Menu") {
                coordinator.navigate(to: .mainMenu)
            }
        } message: {
            Text(viewModel.gameOverMessage)
        }
    }
    

    
        private var middleSectionView: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.8))
                .frame(height: 120)
            
            HStack {
                // Back button
                Button {
                    coordinator.navigate(to: .mainMenu)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.themeYellow)
                }
                
                Spacer()
                
                // Game state content
                gameStateContent
                
                Spacer()
                
                // Round counter
                Text("Round \(viewModel.currentRound)/\(viewModel.maxRounds)")
                    .font(.customFont(.customMedium, size: 16))
                    .foregroundColor(.themeWhite)
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var gameStateContent: some View {
        switch viewModel.gameState {
        case .waiting:
            VStack(spacing: 8) {
                Text("QUICK REACTION")
                    .font(.customFont(.customBold, size: 20))
                    .foregroundColor(.themeYellow)
                
                Text("Get ready!")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
            }
            
        case .countdown:
            CountdownView(count: viewModel.countdown)
                .scaleEffect(0.5)
            
        case .waitingForGreen:
            VStack(spacing: 4) {
                Text("WAIT FOR GREEN!")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(.themeYellow)
                
                Text("Don't tap yet!")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.themeOrange)
            }
            
        case .ready:
            VStack(spacing: 4) {
                Text("GO!")
                    .font(.customFont(.customBold, size: 24))
                    .foregroundColor(.green)
                
                Text("TAP NOW!")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite)
            }
            
        case .finished:
            VStack(spacing: 4) {
                Text("WINNER:")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
                
                Text(viewModel.roundWinner?.displayName ?? "TIE")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(viewModel.roundWinner?.color ?? .themeWhite)
                
                if let time = viewModel.winningTime {
                    Text("\(String(format: "%.3f", time))s")
                        .font(.customFont(.customMedium, size: 12))
                        .foregroundColor(.themeWhite.opacity(0.6))
                }
            }
            
        case .earlyTap:
            VStack(spacing: 4) {
                Text("TOO EARLY!")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(.themeRed)
                
                Text("Point to opponent")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.themeWhite.opacity(0.8))
            }
        }
    }
    
    private func reactionPlayerAreaView(player: Player, geometry: GeometryProxy, isTopPlayer: Bool) -> some View {
        Button {
            viewModel.playerTapped(player)
        } label: {
            ZStack {
                // Background color based on game state
                Rectangle()
                    .fill(backgroundColorForPlayer(player))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Player content
                VStack(spacing: 12) {
                    if isTopPlayer {
                        // Score
                        Text("\(player == .player1 ? viewModel.player1Score : viewModel.player2Score)")
                            .font(.customFont(.customBold, size: 32))
                            .foregroundColor(.themeWhite)
                        
                        // Player name
                        Text(player.displayName)
                            .font(.customFont(.customBold, size: 20))
                            .foregroundColor(.themeWhite)
                        
                        // Instruction based on state
                        instructionText(for: player)
                    } else {
                        // Instruction based on state
                        instructionText(for: player)
                        
                        // Player name
                        Text(player.displayName)
                            .font(.customFont(.customBold, size: 20))
                            .foregroundColor(.themeWhite)
                        
                        // Score
                        Text("\(player == .player1 ? viewModel.player1Score : viewModel.player2Score)")
                            .font(.customFont(.customBold, size: 32))
                            .foregroundColor(.themeWhite)
                    }
                }
                .rotationEffect(.degrees(isTopPlayer ? 180 : 0))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isPlayerAreaActive())
    }
    
    private func backgroundColorForPlayer(_ player: Player) -> Color {
        switch viewModel.gameState {
        case .waiting, .countdown:
            return player.color.opacity(0.4)
        case .waitingForGreen:
            return player.color.opacity(0.6)
        case .ready:
            return Color.green.opacity(0.7)
        case .finished:
            if viewModel.roundWinner == player {
                return player.color.opacity(0.8)
            } else {
                return player.color.opacity(0.3)
            }
        case .earlyTap:
            return Color.red.opacity(0.5)
        }
    }
    
    private func instructionText(for player: Player) -> some View {
        Group {
            switch viewModel.gameState {
            case .waiting:
                Text("GET READY")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
            case .countdown:
                Text("WAIT...")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
            case .waitingForGreen:
                Text("DON'T TAP!")
                    .font(.customFont(.customSemiBold, size: 16))
                    .foregroundColor(.themeOrange)
            case .ready:
                Text("TAP NOW!")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(.themeWhite)
            case .finished:
                if viewModel.roundWinner == player {
                    Text("WINNER!")
                        .font(.customFont(.customBold, size: 16))
                        .foregroundColor(.green)
                } else {
                    Text("NEXT TIME")
                        .font(.customFont(.customMedium, size: 14))
                        .foregroundColor(.themeWhite.opacity(0.6))
                }
            case .earlyTap:
                Text("TOO EARLY!")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeRed)
            }
        }
    }
    
    private func isPlayerAreaActive() -> Bool {
        switch viewModel.gameState {
        case .ready:
            return true
        default:
            return false
        }
    }
}

#Preview {
    ReactionGameView()
        .environmentObject(Coordinator())
}
