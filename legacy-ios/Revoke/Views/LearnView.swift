import SwiftUI

struct LearnView: View {
    @State private var expandedSection: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Hero
                    VStack(spacing: 12) {
                        Text("🛡️")
                            .font(.system(size: 48))
                        
                        Text("Your Data Rights")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Companies collect and sell your personal data every day. The law gives you the power to stop them.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 20)
                    
                    // FAQ Sections
                    learnSection(
                        id: "what",
                        icon: "questionmark.circle.fill",
                        title: "What are data brokers?",
                        body: "Data brokers are companies that collect your personal information -- your name, address, phone number, browsing history, location data, and more -- and sell it to other companies, advertisers, and sometimes even law enforcement.\n\nThey build profiles on you without your knowledge or consent. Some of the biggest brokers have profiles on over 250 million Americans."
                    )
                    
                    learnSection(
                        id: "what_data",
                        icon: "doc.text.fill",
                        title: "What data do they have on me?",
                        body: "Data brokers may have:\n\n• Your full name and address history\n• Phone numbers and email addresses\n• Social media profiles\n• Purchase history\n• Location data (where you go, when)\n• Health and fitness data\n• Financial information\n• Family relationships\n• Political affiliations\n• Religious beliefs\n\nSome companies like Clearview AI have even scraped billions of photos from the internet to build facial recognition databases."
                    )
                    
                    learnSection(
                        id: "rights",
                        icon: "building.columns.fill",
                        title: "What are my legal rights?",
                        body: "Depending on your state, you have the legal right to:\n\n🗑️ DELETE: Require companies to delete all data they have on you.\n\n🚫 OPT OUT: Stop them from selling your data to others.\n\n📋 ACCESS: See exactly what data they've collected.\n\nCompanies must respond within 45 days (in most states). If they don't, you can file a complaint with your state's Attorney General."
                    )
                    
                    learnSection(
                        id: "how",
                        icon: "envelope.fill",
                        title: "How does Revoke work?",
                        body: "Revoke makes exercising your rights as easy as possible:\n\n1️⃣ Browse companies organized by category (AI, surveillance, health data, etc).\n\n2️⃣ Tap any company to preview a legally compliant email citing your state's privacy law.\n\n3️⃣ Tap 'Open in Mail' and hit Send. Or use 'Send All' to blast an entire category at once.\n\n4️⃣ Track responses from the Sent tab. Update the status when companies reply.\n\n5️⃣ If a company misses their deadline, Revoke generates an Attorney General complaint letter for you.\n\nThat's it. The whole process takes minutes, not hours."
                    )
                    
                    learnSection(
                        id: "portal",
                        icon: "globe",
                        title: "Why do some companies require a portal?",
                        body: "Some companies refuse email-based deletion requests and force you to use their own web portal. This is intentional friction -- every extra step reduces the number of people who follow through.\n\nRevoke flags these companies with a '🌐 Portal Required' badge and provides a direct link to their portal. We've verified each URL so you don't have to hunt for it.\n\nThe good news: once you have Authorized Agent status (coming soon), companies are legally required to process requests from your agent regardless of their preferred method."
                    )
                    
                    learnSection(
                        id: "privacy",
                        icon: "lock.shield.fill",
                        title: "Does Revoke collect my data?",
                        body: "No. Absolutely not.\n\nYour name and email are stored only on YOUR device. We never transmit, upload, or collect any of your information. We don't have accounts, servers, or analytics.\n\nThe emails are sent through YOUR email app. We never see them.\n\nWe built this app because we believe in privacy. It would be hypocritical to violate yours."
                    )
                    
                    learnSection(
                        id: "overdue",
                        icon: "exclamationmark.triangle.fill",
                        title: "What if they don't respond?",
                        body: "If a company doesn't respond within the legal deadline (usually 45 days), they are in violation of the law. You can:\n\n1. File a complaint with your state's Attorney General. Revoke generates the complaint letter for you -- just tap 'File Complaint' on any overdue request.\n\n2. In California, the CPPA (California Privacy Protection Agency) handles enforcement at cppa.ca.gov.\n\n3. Some companies will claim they have no account for you. That's often a legitimate response. Use the 'Update Status' button to mark those as resolved.\n\nRevoke tracks your deadlines automatically and shows you which companies need follow-up."
                    )
                    
                    learnSection(
                        id: "pricing",
                        icon: "dollarsign.circle.fill",
                        title: "Why is Revoke only $0.99?",
                        body: "Other data deletion services charge $100-500 per year. They make money from your subscription.\n\nRevoke costs $0.99 because your privacy shouldn't be a luxury. This app runs entirely on your device. There are no servers to pay for, no accounts to manage, no data to store.\n\nWe believe everyone deserves the tools to exercise their legal rights, regardless of income."
                    )
                    
                    // Disclaimer
                    Text("Revoke is not a law firm and does not provide legal advice. This app helps you exercise your existing legal rights. For specific legal questions, consult an attorney.")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.2))
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Learn")
        }
    }
    
    // MARK: - FAQ Section
    
    func learnSection(id: String, icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedSection = expandedSection == id ? nil : id
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color.accentColor)
                        .frame(width: 28)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: expandedSection == id ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(16)
            }
            
            if expandedSection == id {
                Text(body)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .lineSpacing(5)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity)
            }
        }
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
