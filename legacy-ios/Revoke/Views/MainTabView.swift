import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var receiptStore: ReceiptStore
    
    var body: some View {
        TabView {
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "shield.lefthalf.filled")
                }
            
            SentView()
                .tabItem {
                    Label("Sent", systemImage: "checkmark.seal.fill")
                }
                .badge(receiptStore.overdueCount > 0 ? receiptStore.overdueCount : 0)
            
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.accentColor)
    }
}
