import SwiftUI

struct GameButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.customFont(.customSemiBold, size: 18))
                .foregroundColor(.themeWhite)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(color)
                .cornerRadius(12)
        }
    }
}

struct PlayerArea: View {
    let player: String
    let color: Color
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(player)
                    .font(.customFont(.customBold, size: 24))
                    .foregroundColor(.themeWhite)
                
                Text("TAP HERE")
                    .font(.customFont(.customMedium, size: 16))
                    .foregroundColor(.themeWhite.opacity(0.8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isActive ? color : color.opacity(0.6))
        }
        .disabled(!isActive)
    }
}

struct ScoreCard: View {
    let playerName: String
    let score: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(playerName)
                .font(.customFont(.customSemiBold, size: 16))
                .foregroundColor(.themeWhite)
            
            Text("\(score)")
                .font(.customFont(.customBold, size: 28))
                .foregroundColor(color)
        }
        .frame(width: 80, height: 80)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct CountdownView: View {
    let count: Int
    
    var body: some View {
        Text("\(count)")
            .font(.customFont(.customBold, size: 100))
            .foregroundColor(.themeYellow)
            .frame(width: 150, height: 150)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
            .scaleEffect(1.2)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
    }
}
