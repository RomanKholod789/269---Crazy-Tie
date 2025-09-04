import SwiftUI

struct LaunchView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            // Overlay gradient
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.themeOrange.opacity(0.2),
                    Color.themeRed.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Brand Logo
                Image("brand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
                    .opacity(opacity)
                
                Text("2 PLAYERS • 1 DEVICE")
                    .font(.customFont(.customMedium, size: 16))
                    .foregroundColor(.themeWhite.opacity(0.8))
                    .opacity(opacity)
                
                // Animated circles
                HStack(spacing: 20) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(circleColor(for: index))
                            .frame(width: 20, height: 20)
                            .scaleEffect(isAnimating && index % 2 == 0 ? 1.3 : 0.7)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            startAnimations()
            
            // Navigate after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                coordinator.navigate(to: .welcome)
            }
        }
    }
    
    private func circleColor(for index: Int) -> Color {
        switch index {
        case 0: return .themeRed
        case 1: return .themeYellow
        case 2: return .themeOrange
        default: return .themeWhite
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.8)) {
            opacity = 1
            scale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
}

#Preview {
    LaunchView()
        .environmentObject(Coordinator())
}
