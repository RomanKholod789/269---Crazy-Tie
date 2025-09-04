import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var animatedGames: [Bool] = Array(repeating: false, count: 4)
    
    private let games = [
        GameInfo(
            title: "QUICK REACTION",
            subtitle: "First to tap wins",
            icon: "⚡",
            color: Color.themeYellow,
            screen: .reactionGame
        ),
        GameInfo(
            title: "TAP BATTLE",
            subtitle: "Tap your half faster",
            icon: "👊",
            color: Color.themeRed,
            screen: .tapBattle
        ),
        GameInfo(
            title: "REFLEX GAME",
            subtitle: "Tap your color only",
            icon: "🎯",
            color: Color.themeOrange,
            screen: .reflexGame
        ),
        GameInfo(
            title: "NERVE GAME",
            subtitle: "Steel nerves win",
            icon: "🧠",
            color: Color.themeYellow.opacity(0.8),
            screen: .chickenGame
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            // Gradient overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.clear,
                    Color.black.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Games grid
                gamesGridView
                
                Spacer()
            }
        }
        .onAppear {
            animateGames()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            // Brand Logo
            Image("brand")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 180, maxHeight: 100)
            
            Text("CHOOSE YOUR GAME")
                .font(.customFont(.customBold, size: 24))
                .foregroundColor(.themeYellow)
            
            Text("2 PLAYERS • 1 DEVICE")
                .font(.customFont(.customMedium, size: 14))
                .foregroundColor(.themeWhite.opacity(0.8))
        }
        .padding(.top, 60)
        .padding(.bottom, 30)
    }
    
    private var gamesGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(games.indices, id: \.self) { index in
                GameCardView(
                    game: games[index],
                    isAnimated: animatedGames[index]
                ) {
                    coordinator.navigate(to: games[index].screen)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func animateGames() {
        for index in games.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedGames[index] = true
                }
            }
        }
    }
}

struct GameInfo {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let screen: Screens
}

struct GameCardView: View {
    let game: GameInfo
    let isAnimated: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                Text(game.icon)
                    .font(.system(size: 50))
                
                // Title and subtitle
                VStack(spacing: 4) {
                    Text(game.title)
                        .font(.customFont(.customBold, size: 18))
                        .foregroundColor(.themeWhite)
                        .multilineTextAlignment(.center)
                    
                    Text(game.subtitle)
                        .font(.customFont(.customMedium, size: 14))
                        .foregroundColor(.themeWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(game.color.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(game.color, lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(isAnimated ? 1.0 : 0.8)
            .opacity(isAnimated ? 1.0 : 0.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

#Preview {
    MainMenuView()
        .environmentObject(Coordinator())
}
