import SwiftUI

@main
struct RevokeApp: App {
    @StateObject private var brokerStore = BrokerStore()
    @StateObject private var receiptStore = ReceiptStore()
    @StateObject private var settings = UserSettings()
    
    init() {
        // Request notification permissions for deadline reminders
        ReceiptStore.requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            if settings.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(brokerStore)
                    .environmentObject(receiptStore)
                    .environmentObject(settings)
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .environmentObject(brokerStore)
                    .environmentObject(receiptStore)
                    .environmentObject(settings)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
