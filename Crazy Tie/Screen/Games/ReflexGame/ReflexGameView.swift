import SwiftUI

struct ReflexGameView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject private var viewModel = ReflexGameViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Image("bbb")
                    .resizable()
                    .ignoresSafeArea()
                
                // Dark overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Game area
                    gameAreaView(geometry: geometry)
                        .frame(maxHeight: .infinity)
                    
                    // Bottom controls
                    bottomControlsView
                }
                
                // Floating balls
                ForEach(viewModel.balls) { ball in
                    ballView(ball: ball)
                        .position(ball.position)
                }
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
    
    private var headerView: some View {
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
            
            // Title
            Text("REFLEX GAME")
                .font(.customFont(.customBold, size: 20))
                .foregroundColor(.themeYellow)
            
            Spacer()
            
            // Timer
            if viewModel.gameState == .playing {
                Text("\(viewModel.timeRemaining)")
                    .font(.customFont(.customBold, size: 20))
                    .foregroundColor(.themeWhite)
                    .frame(width: 40)
            } else {
                Spacer()
                    .frame(width: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private func gameAreaView(geometry: GeometryProxy) -> some View {
        switch viewModel.gameState {
        case .waiting:
            waitingView
        case .countdown:
            countdownView
        case .playing:
            playingView(geometry: geometry)
        case .finished:
            resultView
        }
    }
    
    private var waitingView: some View {
        VStack(spacing: 30) {
            Text("GET READY!")
                .font(.customFont(.customBold, size: 36))
                .foregroundColor(.themeYellow)
            
            VStack(spacing: 16) {
                Text("Tap only YOUR color!")
                    .font(.customFont(.customSemiBold, size: 20))
                    .foregroundColor(.themeWhite)
                
                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color.themeRed)
                            .frame(width: 40, height: 40)
                        Text("PLAYER 1")
                            .font(.customFont(.customMedium, size: 14))
                            .foregroundColor(.themeRed)
                    }
                    
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color.themeOrange)
                            .frame(width: 40, height: 40)
                        Text("PLAYER 2")
                            .font(.customFont(.customMedium, size: 14))
                            .foregroundColor(.themeOrange)
                    }
                }
            }
            
            Text("Wrong taps lose points!")
                .font(.customFont(.customMedium, size: 16))
                .foregroundColor(.themeWhite.opacity(0.8))
        }
    }
    
    private var countdownView: some View {
        VStack {
            CountdownView(count: viewModel.countdown)
        }
    }
    
    private func playingView(geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        viewModel.screenTapped(at: value.location)
                    }
            )
    }
    
    private var resultView: some View {
        VStack(spacing: 30) {
            Text("RESULTS")
                .font(.customFont(.customBold, size: 32))
                .foregroundColor(.themeYellow)
            
            VStack(spacing: 20) {
                HStack(spacing: 60) {
                    playerResultView(
                        player: "PLAYER 1",
                        score: viewModel.player1Score,
                        correctTaps: viewModel.player1Correct,
                        wrongTaps: viewModel.player1Wrong,
                        color: .themeRed
                    )
                    
                    playerResultView(
                        player: "PLAYER 2",
                        score: viewModel.player2Score,
                        correctTaps: viewModel.player2Correct,
                        wrongTaps: viewModel.player2Wrong,
                        color: .themeOrange
                    )
                }
                
                if let winner = viewModel.winner {
                    Text("\(winner.displayName) WINS!")
                        .font(.customFont(.customBold, size: 24))
                        .foregroundColor(winner.color)
                } else {
                    Text("IT'S A TIE!")
                        .font(.customFont(.customBold, size: 24))
                        .foregroundColor(.themeYellow)
                }
            }
        }
    }
    
    private func playerResultView(player: String, score: Int, correctTaps: Int, wrongTaps: Int, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(player)
                .font(.customFont(.customSemiBold, size: 16))
                .foregroundColor(color)
            
            Text("\(score)")
                .font(.customFont(.customBold, size: 32))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text("✓ \(correctTaps)")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.green)
                
                Text("✗ \(wrongTaps)")
                    .font(.customFont(.customMedium, size: 12))
                    .foregroundColor(.red)
            }
        }
        .frame(width: 120, height: 140)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
    
    private var bottomControlsView: some View {
        HStack {
            // Player 1 score
            ScoreCard(
                playerName: "PLAYER 1",
                score: viewModel.player1Score,
                color: .themeRed
            )
            
            Spacer()
            
            // Game status
            if viewModel.gameState == .playing {
                VStack(spacing: 4) {
                    Text("BALLS LEFT")
                        .font(.customFont(.customMedium, size: 12))
                        .foregroundColor(.themeWhite.opacity(0.8))
                    
                    Text("\(viewModel.totalBalls - viewModel.ballsSpawned)")
                        .font(.customFont(.customBold, size: 16))
                        .foregroundColor(.themeYellow)
                }
            }
            
            Spacer()
            
            // Player 2 score
            ScoreCard(
                playerName: "PLAYER 2",
                score: viewModel.player2Score,
                color: .themeOrange
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private func ballView(ball: Ball) -> some View {
        Button {
            viewModel.ballTapped(ball)
        } label: {
            Circle()
                .fill(ball.color)
                .frame(width: ball.size, height: ball.size)
                .scaleEffect(ball.scale)
                .opacity(ball.opacity)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ReflexGameView()
        .environmentObject(Coordinator())
}
