import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = 0
    
    private var theme: LiquidGlassTheme {
        store.profile.isDarkMode ? .dark : .light
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            TrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "syringe.fill")
                }
                .tag(1)
            
            CalculatorView()
                .tabItem {
                    Label("Calculator", systemImage: "function")
                }
                .tag(2)
                
            EncyclopediaView()
                .tabItem {
                    Label("Encyclopedia", systemImage: "book.fill")
                }
                .tag(3)
            
            CompareView()
                .tabItem {
                    Label("Compare", systemImage: "square.stack.3d.up")
                }
                .tag(4)
        }
        .tint(theme.primary)
    }
}
