import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        Group {
            switch coordinator.actualScreen {
            case .launch:
                LaunchView()
                    .environmentObject(coordinator)
            case .welcome:
                WelcomeView()
                    .environmentObject(coordinator)
            case .mainMenu:
                MainMenuView()
                    .environmentObject(coordinator)
            case .reactionGame:
                ReactionGameView()
                    .environmentObject(coordinator)
            case .tapBattle:
                TapBattleView()
                    .environmentObject(coordinator)
            case .reflexGame:
                ReflexGameView()
                    .environmentObject(coordinator)
            case .chickenGame:
                ChickenGameView()
                    .environmentObject(coordinator)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
    }
}

private var backgroundView: some View {
    Image("bbb")
        .resizable()
        .ignoresSafeArea()
}

#Preview {
    CoordinatorView()
}
