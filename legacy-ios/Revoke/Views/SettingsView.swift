import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var receiptStore: ReceiptStore
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Color.accentColor)
                        TextField("Full Name", text: $settings.userName)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color.accentColor)
                        TextField("Email", text: $settings.userEmail)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                } header: {
                    Text("Your Information")
                } footer: {
                    Text("This info is used only to fill your emails. It never leaves your device.")
                }
                
                // State Selection
                Section {
                    Picker("State", selection: $settings.userState) {
                        ForEach(PrivacyLaw.allLaws) { law in
                            Text("\(law.state) (\(law.lawName))")
                                .tag(law.id)
                        }
                        Text("Other (no state law yet)")
                            .tag("OTHER")
                    }
                } header: {
                    Text("Your State")
                } footer: {
                    if settings.userState == "OTHER" {
                        Text("Your state doesn't have a specific privacy law yet. Your emails will cite the CCPA, which most companies apply nationwide.")
                    } else if let law = PrivacyLaw.forState(settings.userState) {
                        Text("Your emails will cite: \(law.statute)\nResponse deadline: \(law.responseDays) days")
                    }
                }
                
                // Stats
                Section {
                    HStack {
                        Label("Total Sent", systemImage: "paperplane")
                        Spacer()
                        Text("\(receiptStore.receipts.count)")
                            .foregroundColor(.white.opacity(0.4))
                    }
                    HStack {
                        Label("Pending", systemImage: "clock")
                        Spacer()
                        Text("\(receiptStore.pendingCount)")
                            .foregroundColor(Color.accentColor)
                    }
                    HStack {
                        Label("Confirmed Deleted", systemImage: "checkmark.circle.fill")
                        Spacer()
                        Text("\(receiptStore.confirmedCount)")
                            .foregroundColor(.green)
                    }
                    HStack {
                        Label("Action Needed", systemImage: "hand.point.right")
                        Spacer()
                        Text("\(receiptStore.actionableCount)")
                            .foregroundColor(.orange)
                    }
                    HStack {
                        Label("Overdue", systemImage: "exclamationmark.triangle.fill")
                        Spacer()
                        Text("\(receiptStore.overdueCount)")
                            .foregroundColor(.red)
                    }
                    if receiptStore.complaintReadyCount > 0 {
                        HStack {
                            Label("Ready for AG Complaint", systemImage: "building.columns")
                            Spacer()
                            Text("\(receiptStore.complaintReadyCount)")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Your Progress")
                } footer: {
                    if receiptStore.receipts.count > 0 {
                        let completionRate = receiptStore.confirmedCount + receiptStore.receipts.filter({ $0.responseStatus == .noAccount }).count
                        Text("\(completionRate) of \(receiptStore.receipts.count) requests resolved (\(receiptStore.receipts.count > 0 ? completionRate * 100 / receiptStore.receipts.count : 0)%)")
                    }
                }
                
                // Share & Rate
                Section {
                    ShareLink(item: URL(string: "https://revokeprivacy.com")!) {
                        HStack {
                            Label("Share Revoke", systemImage: "square.and.arrow.up")
                            Spacer()
                            Text("Help others reclaim their data")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/app/idXXXXXXXXXX?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Label("Rate on App Store", systemImage: "star.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                } header: {
                    Text("Spread the Word")
                } footer: {
                    Text("Every rating helps more people discover their privacy rights.")
                }
                
                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Link(destination: URL(string: "https://revokeprivacy.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                        }
                    }
                    
                    Link(destination: URL(string: "https://revokeprivacy.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 11))
                        }
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("Revoke is not a law firm and does not provide legal advice. This app helps you exercise your existing legal rights.")
                }
                
                // Reset
                Section {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Text("Reset All Data")
                    }
                } footer: {
                    Text("This will delete all your receipts and settings from this device.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Settings")
            .alert("Reset Everything?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    settings.userName = ""
                    settings.userEmail = ""
                    settings.userState = "CA"
                    settings.hasCompletedOnboarding = false
                    receiptStore.receipts = []
                    UserDefaults.standard.removeObject(forKey: "datadelete_receipts")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
