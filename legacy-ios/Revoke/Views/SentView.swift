import SwiftUI

struct SentView: View {
    @EnvironmentObject var receiptStore: ReceiptStore
    @EnvironmentObject var settings: UserSettings
    @State private var showDeleteConfirm = false
    @State private var receiptToDelete: Receipt? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if receiptStore.receipts.isEmpty {
                    emptyState
                } else {
                    receiptList
                }
            }
            .background(Color.black)
            .navigationTitle("Sent Requests")
        }
    }
    
    // MARK: - Empty State
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            
            Text("No requests sent yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
            
            Text("Start by browsing companies\nand sending deletion requests.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
    
    // MARK: - Receipt List
    
    var receiptList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats Bar
                statsBar
                    .padding(.horizontal)
                
                // Overdue / Complaint-Ready Section
                if receiptStore.complaintReadyCount > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("OVERDUE -- FILE COMPLAINT", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.red)
                        
                        Text("\(receiptStore.complaintReadyCount) companies have missed their legal deadline or denied your request. Tap a card below to file a complaint with your state's Attorney General.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                // Actionable Section
                if receiptStore.actionableCount > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("ACTION NEEDED", systemImage: "hand.point.right")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.orange)
                        
                        Text("\(receiptStore.actionableCount) requests need your attention. Tap to update status or follow up.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding()
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                
                // Receipt Cards
                ForEach(receiptStore.receipts) { receipt in
                    ReceiptCard(receipt: receipt)
                        .environmentObject(receiptStore)
                        .environmentObject(settings)
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                receiptToDelete = receipt
                                showDeleteConfirm = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.vertical)
        }
        .alert("Delete Receipt?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let receipt = receiptToDelete {
                    withAnimation { receiptStore.removeReceipt(receipt) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the receipt and cancel any deadline reminders for \(receiptToDelete?.brokerName ?? "this company").")
        }
    }
    
    // MARK: - Stats Bar
    
    var statsBar: some View {
        HStack(spacing: 0) {
            statItem(count: receiptStore.receipts.count, label: "Total", color: .white)
            statItem(count: receiptStore.pendingCount, label: "Pending", color: Color.accentColor)
            statItem(count: receiptStore.confirmedCount, label: "Confirmed", color: .green)
            statItem(count: receiptStore.overdueCount, label: "Overdue", color: .red)
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
    
    func statItem(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .black))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundColor(color.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Receipt Card

struct ReceiptCard: View {
    let receipt: Receipt
    @EnvironmentObject var receiptStore: ReceiptStore
    @EnvironmentObject var settings: UserSettings
    @State private var showResponsePicker = false
    @State private var showComplaintPreview = false
    
    var statusColor: Color {
        switch receipt.effectiveStatus {
        case .pending: return receipt.daysRemaining <= 7 ? .orange : Color.accentColor
        case .confirmed, .noAccount: return .green
        case .redirected, .needsInfo: return .orange
        case .denied, .noReply: return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.brokerName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(receipt.requestType.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                // Status Badge
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: receipt.effectiveStatus.icon)
                            .font(.system(size: 10))
                        Text(receipt.statusLabel)
                            .font(.system(size: 13, weight: .black))
                    }
                    .foregroundColor(statusColor)
                    
                    if receipt.responseStatus == .pending && !receipt.isOverdue {
                        Text("remaining")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(1)
                            .foregroundColor(statusColor.opacity(0.6))
                    }
                }
            }
            
            Divider().background(Color.white.opacity(0.06))
            
            // Receipt Details
            HStack(spacing: 16) {
                receiptDetail(label: "Sent", value: receipt.dateSent.formatted(date: .abbreviated, time: .omitted))
                receiptDetail(label: "To", value: receipt.toEmail)
                receiptDetail(label: "Law", value: receipt.lawCited)
            }
            
            // Deadline bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    let law = PrivacyLaw.forState(receipt.stateName == "California" ? "CA" : receipt.stateName) ?? PrivacyLaw.allLaws[0]
                    let totalDays = CGFloat(law.responseDays)
                    let elapsed = totalDays - CGFloat(receipt.daysRemaining)
                    let progress = min(elapsed / totalDays, 1.0)
                    
                    Rectangle()
                        .fill(statusColor)
                        .frame(width: geo.size.width * progress, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
            
            // Response notes
            if let notes = receipt.responseNotes, !notes.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "note.text")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                    Text(notes)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(2)
                }
            }
            
            // Action Buttons
            HStack(spacing: 8) {
                // Update Status Button
                Button(action: { showResponsePicker = true }) {
                    Label("Update Status", systemImage: "square.and.pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // File Complaint (only for overdue/denied)
                if receipt.canFileComplaint {
                    Button(action: { showComplaintPreview = true }) {
                        Label("File Complaint", systemImage: "exclamationmark.bubble")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(receipt.canFileComplaint ? Color.red.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1)
        )
        .sheet(isPresented: $showResponsePicker) {
            ResponsePickerSheet(receipt: receipt)
                .environmentObject(receiptStore)
        }
        .sheet(isPresented: $showComplaintPreview) {
            AGComplaintSheet(receipt: receipt)
                .environmentObject(settings)
        }
    }
    
    func receiptDetail(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundColor(.white.opacity(0.3))
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
        }
    }
}

// MARK: - Response Picker Sheet

struct ResponsePickerSheet: View {
    let receipt: Receipt
    @EnvironmentObject var receiptStore: ReceiptStore
    @Environment(\.dismiss) var dismiss
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("What happened with \(receipt.brokerName)?")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Select the response you received from this company.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(ResponseStatus.allCases.filter { $0 != .pending }) { status in
                            Button(action: {
                                receiptStore.updateResponse(
                                    receiptId: receipt.id,
                                    status: status,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                dismiss()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: status.icon)
                                        .font(.system(size: 18))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(status.label)
                                            .font(.system(size: 15, weight: .semibold))
                                        Text(statusDescription(status))
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.2))
                                }
                                .foregroundColor(.white)
                                .padding(14)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Notes field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NOTES (OPTIONAL)")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.3))
                            
                            TextField("Any details about their response...", text: $notes, axis: .vertical)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                                .lineLimit(3...6)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    func statusDescription(_ status: ResponseStatus) -> String {
        switch status {
        case .confirmed: return "Company confirmed they are deleting your data"
        case .noAccount: return "Company says they have no data on you"
        case .redirected: return "Company told you to use their web portal"
        case .needsInfo: return "Company wants more personal information from you"
        case .denied: return "Company refused or claimed an exemption"
        case .noReply: return "Deadline passed with no response"
        case .pending: return ""
        }
    }
}

// MARK: - AG Complaint Sheet

struct AGComplaintSheet: View {
    let receipt: Receipt
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) var dismiss
    
    var law: PrivacyLaw { settings.currentLaw }
    
    var complaintSubject: String {
        EmailTemplate.agComplaintSubject(brokerName: receipt.brokerName, law: law)
    }
    
    var complaintBody: String {
        EmailTemplate.agComplaintBody(receipt: receipt, userName: settings.userName, userEmail: settings.userEmail, law: law)
    }
    
    var agEmail: String {
        EmailTemplate.agEmail(for: settings.userState)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text("Attorney General Complaint")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                Text(receipt.brokerName)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        Text("This company has \(receipt.effectiveStatus == .denied ? "denied your request" : "missed its \(law.responseDays)-day statutory deadline"). You have the right to file a complaint with your state's Attorney General.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(16)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(14)
                    
                    // Complaint Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COMPLAINT PREVIEW")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.3))
                        
                        HStack {
                            Text("To:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                            Text(agEmail)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        HStack(alignment: .top) {
                            Text("Subject:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                            Text(complaintSubject)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        Text(complaintBody)
                            .font(.system(size: 11, design: .monospaced))
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
                    
                    // Send Button
                    Button(action: {
                        if let url = EmailTemplate.mailtoURL(to: agEmail, subject: complaintSubject, body: complaintBody) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Open Complaint in Mail", systemImage: "envelope.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.red)
                            .cornerRadius(14)
                    }
                    
                    Text("This will open your Mail app with the complaint pre-filled, addressed to the \(law.state) Attorney General.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.3))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("File Complaint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color.accentColor)
                }
            }
        }
    }
}
