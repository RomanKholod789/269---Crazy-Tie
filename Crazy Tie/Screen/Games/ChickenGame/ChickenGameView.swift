import SwiftUI

struct ChickenGameView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel = ChickenGameViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Player 2 area (top half)
                GeometryReader { geometry in
                    chickenPlayerAreaView(
                        player: .player2,
                        geometry: geometry,
                        isTopPlayer: true
                    )
                }
                .frame(maxHeight: .infinity)
                
                // Middle section with header and info
                chickenMiddleSectionView
                
                // Player 1 area (bottom half)  
                GeometryReader { geometry in
                    chickenPlayerAreaView(
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
    

    
    private var chickenMiddleSectionView: some View {
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
                chickenGameStateContent
                
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
    private var chickenGameStateContent: some View {
        switch viewModel.gameState {
        case .waiting:
            VStack(spacing: 8) {
                Text("NERVE GAME")
                    .font(.customFont(.customBold, size: 20))
                    .foregroundColor(.themeYellow)
                
                Text("Last to tap wins!")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
            }
            
        case .countdown:
            CountdownView(count: viewModel.countdown)
                .scaleEffect(0.5)
            
        case .building:
            VStack(spacing: 4) {
                Text("BUILDING TENSION...")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(.themeYellow)
                
                // Tension progress bar
                ProgressView(value: Double(viewModel.tensionLevel), total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 120, height: 8)
                    .scaleEffect(y: 2)
                
                Text("DON'T TAP YET!")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.themeOrange)
            }
            
        case .danger:
            VStack(spacing: 4) {
                Text("⚠️ DANGER ZONE ⚠️")
                    .font(.customFont(.customBold, size: 16))
                    .foregroundColor(.red)
                
                Text("LAST TO TAP WINS!")
                    .font(.customFont(.customSemiBold, size: 14))
                    .foregroundColor(.themeYellow)
                
                if viewModel.dangerTimeLeft > 0 {
                    Text("Time: \(String(format: "%.1f", viewModel.dangerTimeLeft))s")
                        .font(.customFont(.customMedium, size: 12))
                        .foregroundColor(.themeWhite.opacity(0.8))
                }
            }
            
        case .finished:
            VStack(spacing: 4) {
                Text("WINNER:")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
                
                Text(viewModel.roundWinner?.displayName ?? "TIE")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(viewModel.roundWinner?.color ?? .themeWhite)
                
                Text(viewModel.winReason)
                    .font(.customFont(.customMedium, size: 10))
                    .foregroundColor(.themeWhite.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func chickenPlayerAreaView(player: Player, geometry: GeometryProxy, isTopPlayer: Bool) -> some View {
        Button {
            viewModel.playerTapped(player)
        } label: {
            ZStack {
                // Background color based on game state
                Rectangle()
                    .fill(chickenBackgroundColorForPlayer(player))
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
                        chickenInstructionText(for: player)
                    } else {
                        // Instruction based on state
                        chickenInstructionText(for: player)
                        
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
        .disabled(!isChickenPlayerAreaActive())
    }
    
    private func chickenBackgroundColorForPlayer(_ player: Player) -> Color {
        switch viewModel.gameState {
        case .waiting, .countdown:
            return player.color.opacity(0.4)
        case .building:
            return player.color.opacity(0.3)
        case .danger:
            let tapped = player == .player1 ? viewModel.player1Tapped : viewModel.player2Tapped
            return tapped ? player.color.opacity(0.8) : player.color.opacity(0.6)
        case .finished:
            if viewModel.roundWinner == player {
                return player.color.opacity(0.8)
            } else {
                return player.color.opacity(0.3)
            }
        }
    }
    
    private func chickenInstructionText(for player: Player) -> some View {
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
            case .building:
                Text("DON'T TAP YET!")
                    .font(.customFont(.customSemiBold, size: 16))
                    .foregroundColor(.themeOrange)
            case .danger:
                let tapped = player == .player1 ? viewModel.player1Tapped : viewModel.player2Tapped
                if tapped {
                    Text("TAPPED!")
                        .font(.customFont(.customBold, size: 16))
                        .foregroundColor(.green)
                } else {
                    Text("LAST TO TAP WINS!")
                        .font(.customFont(.customBold, size: 14))
                        .foregroundColor(.themeYellow)
                }
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
            }
        }
    }
    
    private func isChickenPlayerAreaActive() -> Bool {
        switch viewModel.gameState {
        case .danger:
            return true
        default:
            return false
        }
    }
}

#Preview {
    ChickenGameView()
        .environmentObject(Coordinator())
}
