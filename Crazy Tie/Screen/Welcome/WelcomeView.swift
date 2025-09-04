import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var currentPage = 0
    @State private var opacity: Double = 0
    
    private let onboardingPages = [
        OnboardingPage(
            title: "WELCOME TO CRAZY TIE",
            description: "The ultimate 2-player competition game on one device!",
            icon: "🎮",
            color: Color.themeYellow
        ),
        OnboardingPage(
            title: "QUICK REACTIONS",
            description: "Test your reflexes and speed against your opponent",
            icon: "⚡",
            color: Color.themeOrange
        ),
        OnboardingPage(
            title: "4 EXCITING GAMES", 
            description: "From tap battles to nerve games - choose your challenge",
            icon: "🎯",
            color: Color.themeRed
        ),
        OnboardingPage(
            title: "READY TO PLAY?",
            description: "Face your opponent and prove who's the fastest!",
            icon: "🏆",
            color: Color.themeOrange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("bbb")
                .resizable()
                .ignoresSafeArea()
            
            // Dark overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("SKIP") {
                        coordinator.navigate(to: .mainMenu)
                    }
                    .font(.customFont(.customMedium, size: 16))
                    .foregroundColor(.themeWhite.opacity(0.8))
                    .padding()
                }
                
                Spacer()
                
                // Onboarding content
                TabView(selection: $currentPage) {
                    ForEach(onboardingPages.indices, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 400)
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 12) {
                    ForEach(onboardingPages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.themeYellow : Color.themeWhite.opacity(0.4))
                            .frame(width: 10, height: 10)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Action button
                VStack(spacing: 16) {
                    if currentPage == onboardingPages.count - 1 {
                        GameButton(
                            title: "START PLAYING",
                            color: .themeOrange
                        ) {
                            coordinator.navigate(to: .mainMenu)
                        }
                        .padding(.horizontal, 30)
                    } else {
                        Button("NEXT") {
                            withAnimation(.spring()) {
                                currentPage += 1
                            }
                        }
                        .font(.customFont(.customSemiBold, size: 18))
                        .foregroundColor(.themeYellow)
                        .frame(width: 120, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.themeYellow, lineWidth: 2)
                        )
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                opacity = 1
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            Text(page.icon)
                .font(.system(size: 80))
                .scaleEffect(scale)
            
            // Title
            Text(page.title)
                .font(.customFont(.customBold, size: 28))
                .foregroundColor(page.color)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.customFont(.customMedium, size: 16))
                .foregroundColor(.themeWhite)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(Coordinator())
}
