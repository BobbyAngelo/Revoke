import Foundation

// MARK: - Broker Data Store

class BrokerStore: ObservableObject {
    @Published var brokers: [Broker] = []
    @Published var packs: [Pack] = []
    
    init() {
        loadBrokers()
    }
    
    private func loadBrokers() {
        guard let url = Bundle.main.url(forResource: "brokers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Broker].self, from: data) else {
            print("Failed to load brokers.json")
            return
        }
        
        brokers = decoded
        buildPacks()
    }
    
    private func buildPacks() {
        let grouped = Dictionary(grouping: brokers, by: { $0.pack })
        packs = grouped.map { key, brokers in
            let info = Pack.packInfo[key] ?? ("📦", key, "")
            return Pack(
                id: key,
                icon: info.icon,
                name: info.name,
                description: info.desc,
                brokerCount: brokers.count,
                criticalCount: brokers.filter { $0.risk_level == "critical" }.count
            )
        }.sorted { $0.criticalCount > $1.criticalCount }
    }
    
    func brokers(forPack packId: String) -> [Broker] {
        brokers
            .filter { $0.pack == packId }
            .sorted {
                let order = ["critical": 0, "high_priority": 1, "high": 2, "elevated": 3, "moderate": 4, "standard": 5, "medium": 5, "low": 6]
                return (order[$0.risk_level] ?? 7) < (order[$1.risk_level] ?? 7)
            }
    }
    
    func broker(byId id: String) -> Broker? {
        brokers.first { $0.id == id }
    }
}

// MARK: - User Settings

class UserSettings: ObservableObject {
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "dd_userName") }
    }
    @Published var userEmail: String {
        didSet { UserDefaults.standard.set(userEmail, forKey: "dd_userEmail") }
    }
    @Published var userState: String {
        didSet { UserDefaults.standard.set(userState, forKey: "dd_userState") }
    }
    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "dd_language") }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "dd_onboarded") }
    }
    
    var currentLaw: PrivacyLaw {
        PrivacyLaw.forState(userState) ?? PrivacyLaw.other
    }
    
    init() {
        self.userName = UserDefaults.standard.string(forKey: "dd_userName") ?? ""
        self.userEmail = UserDefaults.standard.string(forKey: "dd_userEmail") ?? ""
        self.userState = UserDefaults.standard.string(forKey: "dd_userState") ?? "CA"
        self.language = UserDefaults.standard.string(forKey: "dd_language") ?? "en"
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "dd_onboarded")
    }
}
