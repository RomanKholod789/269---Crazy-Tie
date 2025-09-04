import SwiftUI

enum Screens {
    case launch
    case welcome
    case mainMenu
    case reactionGame
    case tapBattle
    case reflexGame
    case chickenGame
}

final class Coordinator: ObservableObject {
    @Published var actualScreen: Screens
    
    init() {
        actualScreen = .launch
    }
    
    
    func navigate(to screen: Screens) {
        if actualScreen != screen {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                actualScreen = screen
            }
        }
    }
}
