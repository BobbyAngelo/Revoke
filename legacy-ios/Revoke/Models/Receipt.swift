import Foundation
import UserNotifications

// MARK: - Response Status (what happened after sending)

enum ResponseStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "pending"               // No response yet (within deadline)
    case confirmed = "confirmed"           // Company confirmed deletion
    case noAccount = "no_account"          // Company says no data found
    case redirected = "redirected"         // Company redirected to web portal
    case needsInfo = "needs_info"          // Company wants more PII
    case denied = "denied"                 // Company claims exemption
    case noReply = "no_reply"             // Deadline passed, no response
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .noAccount: return "No Account"
        case .redirected: return "Portal Required"
        case .needsInfo: return "Needs Info"
        case .denied: return "Denied"
        case .noReply: return "No Reply"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle.fill"
        case .noAccount: return "person.slash"
        case .redirected: return "arrow.right.circle"
        case .needsInfo: return "questionmark.circle"
        case .denied: return "xmark.shield"
        case .noReply: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "accent"
        case .confirmed: return "green"
        case .noAccount: return "gray"
        case .redirected: return "orange"
        case .needsInfo: return "yellow"
        case .denied: return "red"
        case .noReply: return "red"
        }
    }
}

// MARK: - Receipt Model (proof of sent request)

struct Receipt: Codable, Identifiable {
    let id: String
    let brokerId: String
    let brokerName: String
    let requestType: String
    let dateSent: Date
    let toEmail: String
    let lawCited: String
    let stateName: String
    let deadlineDate: Date
    var responseStatus: ResponseStatus
    var responseDate: Date?
    var responseNotes: String?
    
    var isOverdue: Bool {
        Date() > deadlineDate && responseStatus == .pending
    }
    
    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: deadlineDate).day ?? 0
        return max(0, remaining)
    }
    
    var statusLabel: String {
        if responseStatus != .pending { return responseStatus.label }
        if isOverdue { return "OVERDUE" }
        if daysRemaining <= 7 { return "\(daysRemaining)d left" }
        return "\(daysRemaining) days"
    }
    
    var effectiveStatus: ResponseStatus {
        if responseStatus == .pending && Date() > deadlineDate {
            return .noReply
        }
        return responseStatus
    }
    
    /// Whether this receipt is actionable (user should do something)
    var needsAction: Bool {
        switch effectiveStatus {
        case .redirected, .needsInfo, .noReply: return true
        default: return false
        }
    }
    
    /// Whether an AG complaint can be filed
    var canFileComplaint: Bool {
        effectiveStatus == .noReply || effectiveStatus == .denied
    }
}

// MARK: - Receipt Store

class ReceiptStore: ObservableObject {
    @Published var receipts: [Receipt] = []
    
    private let storageKey = "datadelete_receipts"
    
    init() {
        load()
    }
    
    /// Request notification permissions on first launch
    static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func addReceipt(broker: Broker, requestType: String, toEmail: String, law: PrivacyLaw) {
        let receipt = Receipt(
            id: UUID().uuidString,
            brokerId: broker.id,
            brokerName: broker.name,
            requestType: requestType,
            dateSent: Date(),
            toEmail: toEmail,
            lawCited: law.lawName,
            stateName: law.state,
            deadlineDate: Calendar.current.date(byAdding: .day, value: law.responseDays, to: Date()) ?? Date(),
            responseStatus: .pending
        )
        receipts.insert(receipt, at: 0)
        save()
        scheduleReminders(for: receipt, law: law)
    }
    
    func updateResponse(receiptId: String, status: ResponseStatus, notes: String? = nil) {
        if let index = receipts.firstIndex(where: { $0.id == receiptId }) {
            receipts[index].responseStatus = status
            receipts[index].responseDate = Date()
            receipts[index].responseNotes = notes
            save()
            // Cancel reminders since we got a response
            cancelReminders(for: receipts[index])
        }
    }
    
    func removeReceipt(_ receipt: Receipt) {
        receipts.removeAll { $0.id == receipt.id }
        save()
        cancelReminders(for: receipt)
    }
    
    var overdueCount: Int {
        receipts.filter { $0.effectiveStatus == .noReply }.count
    }
    
    var pendingCount: Int {
        receipts.filter { $0.responseStatus == .pending && !$0.isOverdue }.count
    }
    
    var confirmedCount: Int {
        receipts.filter { $0.responseStatus == .confirmed }.count
    }
    
    var actionableCount: Int {
        receipts.filter { $0.needsAction }.count
    }
    
    var complaintReadyCount: Int {
        receipts.filter { $0.canFileComplaint }.count
    }
    
    // MARK: - Notifications
    
    private func scheduleReminders(for receipt: Receipt, law: PrivacyLaw) {
        let center = UNUserNotificationCenter.current()
        
        // Reminder 1: 7 days before deadline
        if let reminderDate = Calendar.current.date(byAdding: .day, value: -7, to: receipt.deadlineDate),
           reminderDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "Deadline in 7 days"
            content.body = "\(receipt.brokerName) has 7 days left to respond to your \(receipt.requestType.replacingOccurrences(of: "_", with: " ")) request."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: reminderDate.timeIntervalSinceNow, repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "\(receipt.id)_7day", content: content, trigger: trigger
            )
            center.add(request)
        }
        
        // Reminder 2: On deadline day
        let deadlineContent = UNMutableNotificationContent()
        deadlineContent.title = "Deadline reached"
        deadlineContent.body = "\(receipt.brokerName)'s \(law.responseDays)-day deadline is today. Check if they responded."
        deadlineContent.sound = .default
        
        if receipt.deadlineDate > Date() {
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: receipt.deadlineDate.timeIntervalSinceNow, repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "\(receipt.id)_deadline", content: deadlineContent, trigger: trigger
            )
            center.add(request)
        }
        
        // Reminder 3: 1 day after deadline (file complaint nudge)
        if let overdueDate = Calendar.current.date(byAdding: .day, value: 1, to: receipt.deadlineDate),
           overdueDate > Date() {
            let content = UNMutableNotificationContent()
            content.title = "No response from \(receipt.brokerName)"
            content.body = "The statutory deadline has passed. You can file a complaint with your state's Attorney General."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: overdueDate.timeIntervalSinceNow, repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "\(receipt.id)_overdue", content: content, trigger: trigger
            )
            center.add(request)
        }
    }
    
    private func cancelReminders(for receipt: Receipt) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(receipt.id)_7day",
            "\(receipt.id)_deadline",
            "\(receipt.id)_overdue"
        ])
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let data = try? JSONEncoder().encode(receipts) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Receipt].self, from: data) {
            receipts = decoded
        }
    }
}
