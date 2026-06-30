import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var brokerStore: BrokerStore
    @EnvironmentObject var receiptStore: ReceiptStore
    @EnvironmentObject var settings: UserSettings
    @State private var selectedPack: String? = nil
    @State private var selectedBroker: Broker? = nil
    @State private var showBatchConfirm = false
    @State private var batchBrokers: [Broker] = []
    @State private var batchSendIndex = 0
    @State private var searchText = ""
    
    var filteredBrokers: [Broker] {
        guard !searchText.isEmpty else { return [] }
        return brokerStore.brokers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    @State private var isBatchSending = false
    
    private let requestType: EmailTemplate.RequestType = .delete
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mission
                    Text("Your data. Your rights. Take them back.")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.3))
                        TextField("Search companies...", text: $searchText)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 12) {
                        statCard(value: "\(brokerStore.brokers.count)", label: "Companies", color: .white)
                        statCard(value: "\(receiptStore.receipts.count)", label: "Sent", color: Color.accentColor)
                        statCard(value: "\(receiptStore.overdueCount)", label: "Overdue", color: .red)
                    }
                    .padding(.horizontal)
                    
                    // Search Results
                    if !searchText.isEmpty {
                        VStack(spacing: 4) {
                            Text("\(filteredBrokers.count) results")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 10) {
                                ForEach(filteredBrokers) { broker in
                                    BrokerRow(
                                        broker: broker,
                                        isSent: receiptStore.receipts.contains { $0.brokerId == broker.id }
                                    ) {
                                        selectedBroker = broker
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    // Packs Grid
                    else if selectedPack == nil {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(brokerStore.packs) { pack in
                                PackCard(
                                    pack: pack,
                                    sentCount: sentCount(forPack: pack.id),
                                    totalCount: pack.brokerCount
                                ) {
                                    withAnimation { selectedPack = pack.id }
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Back button + Send All
                        HStack {
                            Button(action: { withAnimation { selectedPack = nil } }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("All Packs")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.accentColor)
                            }
                            
                            Spacer()
                            
                            // Send All button
                            let unsent = unsentEmailBrokers(forPack: selectedPack!)
                            if !unsent.isEmpty {
                                Button(action: {
                                    batchBrokers = unsent
                                    showBatchConfirm = true
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 11))
                                        Text("Send All (\(unsent.count))")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Progress bar for this pack
                        let packBrokers = brokerStore.brokers(forPack: selectedPack!)
                        let sent = sentCount(forPack: selectedPack!)
                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    let progress = packBrokers.isEmpty ? 0.0 : CGFloat(sent) / CGFloat(packBrokers.count)
                                    Rectangle()
                                        .fill(sent == packBrokers.count ? Color.green : Color.accentColor)
                                        .frame(width: geo.size.width * progress, height: 6)
                                        .cornerRadius(3)
                                        .animation(.easeInOut, value: sent)
                                }
                            }
                            .frame(height: 6)
                            
                            HStack {
                                Text("\(sent)/\(packBrokers.count) sent")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.4))
                                Spacer()
                                if sent == packBrokers.count {
                                    Label("Complete", systemImage: "checkmark.circle.fill")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Broker List
                        LazyVStack(spacing: 10) {
                            ForEach(brokerStore.brokers(forPack: selectedPack!)) { broker in
                                BrokerRow(
                                    broker: broker,
                                    isSent: receiptStore.receipts.contains { $0.brokerId == broker.id }
                                ) {
                                    selectedBroker = broker
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.black)
            .navigationTitle("Revoke")
            .sheet(item: $selectedBroker) { broker in
                EmailPreviewView(broker: broker)
            }
            .alert("Send \(batchBrokers.count) Emails?", isPresented: $showBatchConfirm) {
                Button("Send All") {
                    startBatchSend()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                let portalCount = batchBrokers.filter { $0.isPortalOnly }.count
                if portalCount > 0 {
                    Text("This will open \(batchBrokers.count - portalCount) emails in your Mail app. \(portalCount) portal-only companies will be skipped (use their web portal instead).")
                } else {
                    Text("This will open each email in your Mail app one at a time. Just tap Send on each one. Receipts are created automatically.")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func sentCount(forPack packId: String) -> Int {
        let packBrokerIds = Set(brokerStore.brokers(forPack: packId).map { $0.id })
        return receiptStore.receipts.filter { packBrokerIds.contains($0.brokerId) }.count
    }
    
    func unsentEmailBrokers(forPack packId: String) -> [Broker] {
        let sentIds = Set(receiptStore.receipts.map { $0.brokerId })
        return brokerStore.brokers(forPack: packId).filter { broker in
            !sentIds.contains(broker.id) && !broker.isPortalOnly && broker.privacy_email != nil
        }
    }
    
    func startBatchSend() {
        let emailBrokers = batchBrokers.filter { !$0.isPortalOnly && $0.privacy_email != nil }
        guard !emailBrokers.isEmpty else { return }
        
        let law = settings.currentLaw
        
        // Open the first email immediately
        for (index, broker) in emailBrokers.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                if let email = broker.privacy_email {
                    let subject = EmailTemplate.subject(type: requestType, userName: settings.userName, law: law)
                    let body = EmailTemplate.body(type: requestType, brokerName: broker.name, userName: settings.userName, userEmail: settings.userEmail, law: law)
                    
                    if let url = EmailTemplate.mailtoURL(to: email, subject: subject, body: body) {
                        UIApplication.shared.open(url)
                    }
                    
                    // Auto-create receipt
                    receiptStore.addReceipt(broker: broker, requestType: requestType.rawValue, toEmail: email, law: law)
                }
            }
        }
    }
    
    func statCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Pack Card

struct PackCard: View {
    let pack: Pack
    let sentCount: Int
    let totalCount: Int
    let onTap: () -> Void
    
    var progress: CGFloat {
        totalCount == 0 ? 0 : CGFloat(sentCount) / CGFloat(totalCount)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Progress ring + icon
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            sentCount == totalCount && totalCount > 0 ? Color.green : Color.accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    Text(pack.icon)
                        .font(.system(size: 20))
                }
                
                Text(pack.name.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("\(sentCount)/\(totalCount) sent")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(sentCount == totalCount && totalCount > 0 ? .green : .white.opacity(0.4))
                
                if pack.criticalCount > 0 {
                    Text("\(pack.criticalCount) high priority")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.white.opacity(0.05))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        sentCount == totalCount && totalCount > 0
                            ? Color.green.opacity(0.2)
                            : Color.white.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Broker Row

struct BrokerRow: View {
    let broker: Broker
    let isSent: Bool
    let onTap: () -> Void
    
    var riskColor: Color {
        switch broker.risk_level {
        case "critical": return .red
        case "high_priority": return .orange
        case "elevated", "high": return .yellow
        case "moderate": return Color.accentColor
        case "low": return .green
        default: return .green
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Status indicator
                ZStack {
                    Text(broker.categoryIcon)
                        .font(.system(size: 22))
                    
                    if isSent {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                            .background(Circle().fill(Color.black).frame(width: 16, height: 16))
                            .offset(x: 12, y: 10)
                    }
                }
                .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(broker.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isSent ? .white.opacity(0.5) : .white)
                        
                        Text(broker.priorityLabel.uppercased())
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.8)
                            .foregroundColor(riskColor)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(riskColor.opacity(0.12))
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 6) {
                        // Method badge
                        Text(broker.methodLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(broker.isPortalOnly ? .orange : .white.opacity(0.3))
                        
                        Text("·")
                            .foregroundColor(.white.opacity(0.2))
                        
                        Text(broker.notes)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSent ? "checkmark.seal.fill" : "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(isSent ? .green : .white.opacity(0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(isSent ? 0.02 : 0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSent ? Color.green.opacity(0.15) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}
