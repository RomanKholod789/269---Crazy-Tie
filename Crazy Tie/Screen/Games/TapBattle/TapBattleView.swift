import SwiftUI

struct TapBattleView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel = TapBattleViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Player 2 area (top half) - rotated 180 degrees
                GeometryReader { geometry in
                    playerAreaView(
                        player: .player2,
                        geometry: geometry,
                        isTopPlayer: true
                    )
                }
                .frame(maxHeight: .infinity)
                
                // Middle section with scores and controls
                middleSectionView
                
                // Player 1 area (bottom half)
                GeometryReader { geometry in
                    playerAreaView(
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
    
    private func playerAreaView(player: Player, geometry: GeometryProxy, isTopPlayer: Bool) -> some View {
        Button {
            viewModel.playerTapped(player)
        } label: {
            ZStack {
                // Background color based on game state
                Rectangle()
                    .fill(backgroundColorForPlayer(player))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Tap effect circles
                ForEach(viewModel.tapEffects.filter { $0.player == player }, id: \.id) { effect in
                    Circle()
                        .fill(player.color.opacity(0.6))
                        .frame(width: 50, height: 50)
                        .position(effect.position)
                        .scaleEffect(effect.scale)
                        .opacity(effect.opacity)
                }
                
                // Player content
                VStack(spacing: 20) {
                    if isTopPlayer {
                        // Score
                        Text("\(viewModel.player2Taps)")
                            .font(.customFont(.customBold, size: 48))
                            .foregroundColor(.themeWhite)
                        
                        // Player name
                        Text("PLAYER 2")
                            .font(.customFont(.customBold, size: 24))
                            .foregroundColor(.themeWhite)
                        
                        // Instruction
                        if viewModel.gameState == .playing {
                            Text("TAP FAST!")
                                .font(.customFont(.customSemiBold, size: 16))
                                .foregroundColor(.themeWhite.opacity(0.8))
                        }
                    } else {
                        // Instruction
                        if viewModel.gameState == .playing {
                            Text("TAP FAST!")
                                .font(.customFont(.customSemiBold, size: 16))
                                .foregroundColor(.themeWhite.opacity(0.8))
                        }
                        
                        // Player name
                        Text("PLAYER 1")
                            .font(.customFont(.customBold, size: 24))
                            .foregroundColor(.themeWhite)
                        
                        // Score
                        Text("\(viewModel.player1Taps)")
                            .font(.customFont(.customBold, size: 48))
                            .foregroundColor(.themeWhite)
                    }
                }
                .rotationEffect(.degrees(isTopPlayer ? 180 : 0))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.gameState != .playing)
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
                
                // Game content based on state
                gameStateView
                
                Spacer()
                
                // Timer or status
                timerView
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    private var gameStateView: some View {
        switch viewModel.gameState {
        case .waiting:
            VStack(spacing: 8) {
                Text("TAP BATTLE")
                    .font(.customFont(.customBold, size: 20))
                    .foregroundColor(.themeYellow)
                
                Text("Get ready to tap!")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
            }
            
        case .countdown:
            CountdownView(count: viewModel.countdown)
                .scaleEffect(0.5)
            
        case .playing:
            VStack(spacing: 4) {
                Text("BATTLE!")
                    .font(.customFont(.customBold, size: 20))
                    .foregroundColor(.themeRed)
                
                HStack(spacing: 20) {
                    Text("\(viewModel.player1Taps)")
                        .font(.customFont(.customBold, size: 24))
                        .foregroundColor(.themeRed)
                    
                    Text("VS")
                        .font(.customFont(.customMedium, size: 14))
                        .foregroundColor(.themeWhite)
                    
                    Text("\(viewModel.player2Taps)")
                        .font(.customFont(.customBold, size: 24))
                        .foregroundColor(.themeOrange)
                }
            }
            
        case .finished:
            VStack(spacing: 4) {
                Text("WINNER:")
                    .font(.customFont(.customMedium, size: 14))
                    .foregroundColor(.themeWhite.opacity(0.8))
                
                Text(viewModel.winner?.displayName ?? "TIE")
                    .font(.customFont(.customBold, size: 18))
                    .foregroundColor(viewModel.winner?.color ?? .themeWhite)
            }
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 4) {
            if viewModel.gameState == .playing {
                Text("TIME")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.themeWhite.opacity(0.6))
                
                Text("\(viewModel.timeRemaining)")
                    .font(.customFont(.customBold, size: 16))
                    .foregroundColor(.themeYellow)
            }
        }
    }
    
    private func backgroundColorForPlayer(_ player: Player) -> Color {
        switch viewModel.gameState {
        case .waiting, .countdown:
            return player.color.opacity(0.3)
        case .playing:
            return player.color.opacity(0.5)
        case .finished:
            if viewModel.winner == player {
                return player.color.opacity(0.7)
            } else {
                return player.color.opacity(0.2)
            }
        }
    }
}

#Preview {
    TapBattleView()
        .environmentObject(Coordinator())
}
