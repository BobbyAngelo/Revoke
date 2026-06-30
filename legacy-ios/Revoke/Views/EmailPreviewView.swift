import SwiftUI

struct EmailPreviewView: View {
    @EnvironmentObject var settings: UserSettings
    @EnvironmentObject var receiptStore: ReceiptStore
    @Environment(\.dismiss) var dismiss
    
    let broker: Broker
    var initialRequestType: EmailTemplate.RequestType = .delete
    
    @State private var requestType: EmailTemplate.RequestType = .delete
    @State private var showConfirmation = false
    @State private var showAdvanced = false
    
    var law: PrivacyLaw { settings.currentLaw }
    
    var emailSubject: String {
        EmailTemplate.subject(type: requestType, userName: settings.userName, law: law)
    }
    
    var emailBody: String {
        EmailTemplate.body(type: requestType, brokerName: broker.name, userName: settings.userName, userEmail: settings.userEmail, law: law)
    }
    
    var toEmail: String {
        broker.privacy_email ?? "N/A"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Broker Info Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(broker.categoryIcon)
                                .font(.system(size: 28))
                            VStack(alignment: .leading) {
                                Text(broker.name)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Text(broker.risk_level.uppercased())
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(1)
                                    .foregroundColor(broker.risk_level == "critical" ? .red : .orange)
                            }
                        }
                        
                        Text(broker.notes)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                        
                        HStack {
                            Label(law.lawName, systemImage: "building.columns")
                            Spacer()
                            Label("\(law.responseDays) day deadline", systemImage: "clock")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.accentColor)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(14)
                    
                    // Email Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("EMAIL PREVIEW")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.3))
                        
                        // To
                        HStack {
                            Text("To:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                            Text(toEmail)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        // Subject
                        HStack(alignment: .top) {
                            Text("Subject:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                            Text(emailSubject)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Body
                        Text(emailBody)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    
                    // Portal Warning Banner (for companies that refuse email)
                    if broker.isPortalOnly {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("This company requires their web portal")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.orange)
                            }
                            Text("Email-based deletion requests are not accepted. Use the portal button below to submit your request directly.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Advanced: Change Request Type
                    DisclosureGroup(isExpanded: $showAdvanced) {
                        VStack(spacing: 8) {
                            ForEach(EmailTemplate.RequestType.allCases) { type in
                                Button(action: { requestType = type }) {
                                    HStack {
                                        Image(systemName: type.icon)
                                            .frame(width: 20)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(type.label)
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(requestTypeDescription(type))
                                                .font(.system(size: 11))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                        Spacer()
                                        if requestType == type {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color.accentColor)
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(requestType == type ? Color.accentColor.opacity(0.1) : Color.clear)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 12))
                            Text("Change request type")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.4))
                    }
                    .tint(.white.opacity(0.3))
                    
                    // Portal Button (primary for portal-only, secondary for email brokers)
                    if let url = broker.privacy_url {
                        Button(action: {
                            if let webURL = URL(string: url) {
                                UIApplication.shared.open(webURL)
                            }
                        }) {
                            Label(
                                broker.isPortalOnly ? "Open Deletion Portal" : "Open Web Form",
                                systemImage: "globe"
                            )
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(broker.isPortalOnly ? .black : Color.accentColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(broker.isPortalOnly ? Color.accentColor : Color.accentColor.opacity(0.1))
                            .cornerRadius(14)
                            .overlay(
                                broker.isPortalOnly ? nil :
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Email Button (primary for email brokers, secondary/hidden for portal-only)
                    if let email = broker.privacy_email, !broker.isPortalOnly {
                        Button(action: {
                            openMailApp(to: email)
                        }) {
                            Label("Open in Mail App", systemImage: "envelope.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.accentColor)
                                .cornerRadius(14)
                        }
                        
                        // Copy to clipboard button
                        Button(action: { copyEmailToClipboard() }) {
                            Label(
                                copiedToClipboard ? "Copied!" : "Copy Email Text",
                                systemImage: copiedToClipboard ? "checkmark" : "doc.on.doc"
                            )
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(copiedToClipboard ? .green : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                        
                        Text("Tapping 'Open in Mail' will pre-fill the email. Just hit Send.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Review & Send")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.accentColor)
                }
            }
            .alert("Request Sent?", isPresented: $showConfirmation) {
                Button("Yes, I Sent It") {
                    receiptStore.addReceipt(
                        broker: broker,
                        requestType: requestType.rawValue,
                        toEmail: toEmail,
                        law: law
                    )
                    dismiss()
                }
                Button("Not Yet", role: .cancel) {}
            } message: {
                Text("Did you send the email? We'll start the \(law.responseDays)-day countdown and save a receipt.")
            }
            .alert("Mail Not Available", isPresented: $showMailError) {
                Button("Copy Email") { copyEmailToClipboard() }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your Mail app isn't configured. Tap 'Copy Email' to copy the full email to your clipboard, then paste it into your preferred email app.")
            }
        }
    }
    
    @State private var showMailError = false
    @State private var copiedToClipboard = false
    
    private func openMailApp(to email: String) {
        if let url = EmailTemplate.mailtoURL(to: email, subject: emailSubject, body: emailBody) {
            UIApplication.shared.open(url) { success in
                if success {
                    // Show confirmation after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showConfirmation = true
                    }
                } else {
                    showMailError = true
                }
            }
        } else {
            showMailError = true
        }
    }
    
    private func copyEmailToClipboard() {
        let fullEmail = """
        To: \(toEmail)
        Subject: \(emailSubject)
        
        \(emailBody)
        """
        UIPasteboard.general.string = fullEmail
        copiedToClipboard = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedToClipboard = false
        }
    }
    
    private func requestTypeDescription(_ type: EmailTemplate.RequestType) -> String {
        switch type {
        case .delete: return "Delete all data + opt out (strongest)"
        case .optOut: return "Stop selling, but keep my data"
        case .access: return "Show me what data you have"
        }
    }
}

