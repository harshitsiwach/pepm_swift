import SwiftUI
import LocalAuthentication

@main
struct PepmaxApp: App {
    @StateObject private var store = AppStore()
    @State private var isUnlocked = false
    @State private var hasCheckedLock = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !store.profile.hasCompletedOnboarding {
                    OnboardingView()
                } else if store.profile.isAppLockEnabled && !isUnlocked {
                    LockScreenView(isUnlocked: $isUnlocked)
                } else {
                    MainTabView()
                }
            }
            .environmentObject(store)
            .environment(\.isDarkMode, store.profile.isDarkMode)
            .environment(\.theme, store.profile.isDarkMode ? .dark : .light)
            .preferredColorScheme(store.profile.isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.3), value: store.profile.hasCompletedOnboarding)
            .animation(.easeInOut(duration: 0.3), value: isUnlocked)
            .onAppear {
                if store.profile.isAppLockEnabled && !hasCheckedLock {
                    hasCheckedLock = true
                    // Auto-trigger Face ID on launch
                }
            }
        }
    }
}

// MARK: - Lock Screen

struct LockScreenView: View {
    @EnvironmentObject var store: AppStore
    @Binding var isUnlocked: Bool
    @State private var authError = ""
    @State private var showError = false
    
    private var theme: LiquidGlassTheme {
        store.profile.isDarkMode ? .dark : .light
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Logo
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [theme.primary.opacity(0.2), theme.primary.opacity(0.0)],
                                center: .center, startRadius: 0, endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .fill(theme.primary.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Circle().stroke(theme.primary.opacity(0.2), lineWidth: 1)
                        }
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(theme.primary)
                }
                
                VStack(spacing: 8) {
                    Text("Pepmax is Locked")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(theme.text)
                    Text("Authenticate to access your data")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(theme.textMuted)
                }
                
                if showError {
                    Text(authError)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(theme.error)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background { Capsule().fill(theme.error.opacity(0.1)) }
                }
                
                Spacer()
                
                GlowButton(title: "Unlock with Face ID", icon: "faceid") {
                    authenticate()
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            authenticate()
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Pepmax to access your peptide data") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        withAnimation(.spring(response: 0.4)) {
                            isUnlocked = true
                        }
                        Haptics.notification(.success)
                    } else {
                        authError = "Authentication failed. Try again."
                        showError = true
                        Haptics.notification(.error)
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // Fallback to passcode
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock Pepmax") { success, _ in
                DispatchQueue.main.async {
                    if success {
                        withAnimation(.spring(response: 0.4)) {
                            isUnlocked = true
                        }
                    }
                }
            }
        } else {
            // No biometrics available, unlock anyway
            isUnlocked = true
        }
    }
}
