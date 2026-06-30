import Foundation

// MARK: - Broker Model

struct Broker: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let privacy_email: String?
    let privacy_url: String?
    let method: String
    let risk_level: String
    let notes: String
    let pack: String
    
    var riskColor: String {
        switch risk_level {
        case "high_priority": return "riskCritical"
        case "elevated": return "riskHigh"
        case "standard": return "riskMedium"
        // Legacy fallbacks
        case "critical": return "riskCritical"
        case "high": return "riskHigh"
        case "medium": return "riskMedium"
        default: return "riskLow"
        }
    }
    
    var priorityLabel: String {
        switch risk_level {
        case "critical": return "Critical"
        case "high_priority": return "High Priority"
        case "elevated", "high": return "Elevated"
        case "moderate": return "Moderate"
        case "standard", "medium": return "Standard"
        case "low": return "Low Risk"
        default: return "Standard"
        }
    }
    
    var categoryIcon: String {
        switch category {
        case "data_broker": return "🕵️"
        case "social_media": return "📱"
        case "ad_network": return "📢"
        case "retail": return "🛒"
        case "ai_company": return "🤖"
        case "surveillance": return "📡"
        case "location_broker": return "📍"
        case "health_data": return "🏥"
        case "finance": return "💳"
        case "search": return "🔍"
        default: return "📦"
        }
    }
    
    var methodLabel: String {
        switch method {
        case "email": return "📧 Email"
        case "portal": return "🌐 Portal Required"
        case "drp": return "⚡ DRP Portal"
        case "web_form": return "🌐 Web Form"
        default: return "📧 Email"
        }
    }
    
    var isPortalOnly: Bool {
        method == "portal" || method == "web_form"
    }
}

// MARK: - Pack Model

struct Pack: Identifiable {
    let id: String
    let icon: String
    let name: String
    let description: String
    let brokerCount: Int
    let criticalCount: Int
    
    static let packInfo: [String: (icon: String, name: String, desc: String)] = [
        "critical": ("🔴", "High Priority", "Companies with documented regulatory actions or breaches"),
        "ai": ("🤖", "AI Companies", "Companies training AI models on your personal data"),
        "ai_companies": ("🤖", "AI Companies", "Companies that process your data for AI model training"),
        "surveillance": ("📡", "Surveillance", "Companies providing monitoring and tracking systems"),
        "location_brokers": ("📍", "Location Data", "Companies that collect and aggregate geolocation data"),
        "health": ("🏥", "Health & Fitness", "Companies collecting health, fitness, and wellness data"),
        "health_data": ("🏥", "Health & Fitness", "Companies collecting health, fitness, and wellness data"),
        "data_broker": ("🕵️", "Data Aggregators", "Companies that compile and resell personal information"),
        "social": ("📱", "Social Media", "Platforms collecting behavioral and social data"),
        "social_media": ("📱", "Social Media", "Platforms collecting behavioral and social data"),
        "retail": ("🛒", "Retail", "Companies collecting purchase and shopping behavior data"),
        "finance": ("💳", "Finance", "Banks, fintech, and financial data companies"),
        "ad_networks": ("📢", "Ad Networks", "Companies tracking you across the web for targeted advertising"),
        "search": ("🔍", "Search Engines", "Companies collecting your search queries and browsing data"),
    ]
}

// MARK: - US State Privacy Laws

struct PrivacyLaw: Identifiable {
    let id: String
    let state: String
    let lawName: String
    let statute: String
    let deleteRight: Bool
    let optOutRight: Bool
    let responseDays: Int
    
    static let allLaws: [PrivacyLaw] = [
        PrivacyLaw(id: "CA", state: "California", lawName: "CCPA/CPRA", statute: "Cal. Civ. Code §§1798.100-1798.199.100", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "CO", state: "Colorado", lawName: "CPA", statute: "C.R.S. §6-1-1301 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "CT", state: "Connecticut", lawName: "CTDPA", statute: "Conn. Gen. Stat. §42-515 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "VA", state: "Virginia", lawName: "VCDPA", statute: "Va. Code Ann. §59.1-575 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "TX", state: "Texas", lawName: "TDPSA", statute: "Tex. Bus. & Com. Code §541.001 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "OR", state: "Oregon", lawName: "OCPA", statute: "ORS §646A.570 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "NJ", state: "New Jersey", lawName: "NJDPA", statute: "N.J. Stat. Ann. §56:8-166 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "DE", state: "Delaware", lawName: "DPDPA", statute: "6 Del. C. §12D-101 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "MD", state: "Maryland", lawName: "MODPA", statute: "Md. Code Ann., Com. Law §14-4601 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "IN", state: "Indiana", lawName: "INDPA", statute: "Ind. Code §24-15-1 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "KY", state: "Kentucky", lawName: "KCDPA", statute: "KRS §367.600 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "MT", state: "Montana", lawName: "MTCDPA", statute: "MCA §30-14-2801 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "NH", state: "New Hampshire", lawName: "NHDPA", statute: "N.H. Rev. Stat. Ann. §507-H:1 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "IA", state: "Iowa", lawName: "ICDPA", statute: "Iowa Code §715D.1 et seq.", deleteRight: true, optOutRight: true, responseDays: 90),
        PrivacyLaw(id: "TN", state: "Tennessee", lawName: "TIPA", statute: "Tenn. Code Ann. §47-18-3201 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "MN", state: "Minnesota", lawName: "MCDPA", statute: "Minn. Stat. §325O.01 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
        PrivacyLaw(id: "NE", state: "Nebraska", lawName: "NEDPA", statute: "Neb. Rev. Stat. §87-1101 et seq.", deleteRight: true, optOutRight: true, responseDays: 45),
    ]
    
    /// Fallback for states without specific privacy laws. Cites CCPA since most companies honor it nationwide.
    static let other = PrivacyLaw(id: "OTHER", state: "Other", lawName: "CCPA (voluntary)", statute: "Cal. Civ. Code §§1798.100-1798.199.100", deleteRight: true, optOutRight: true, responseDays: 45)
    
    static func forState(_ stateCode: String) -> PrivacyLaw? {
        allLaws.first { $0.id == stateCode } ?? (stateCode == "OTHER" ? other : nil)
    }
}
