import Foundation

// MARK: - Email Templates

struct EmailTemplate {
    
    enum RequestType: String, CaseIterable, Identifiable {
        case delete = "delete"
        case optOut = "opt_out"
        case access = "access"
        
        var id: String { rawValue }
        
        var label: String {
            switch self {
            case .delete: return "Delete My Data"
            case .optOut: return "Opt Out of Sale"
            case .access: return "What Do You Have?"
            }
        }
        
        var icon: String {
            switch self {
            case .delete: return "trash"
            case .optOut: return "hand.raised"
            case .access: return "doc.text.magnifyingglass"
            }
        }
        
        var labelES: String {
            switch self {
            case .delete: return "Eliminar Mis Datos"
            case .optOut: return "Dejar de Vender"
            case .access: return "¿Qué Tienen?"
            }
        }
    }
    
    // MARK: - Subject Lines
    
    static func subject(type: RequestType, userName: String, law: PrivacyLaw) -> String {
        switch type {
        case .delete:
            return "\(law.lawName) Data Deletion Request - \(userName)"
        case .optOut:
            return "\(law.lawName) Opt-Out Request - \(userName)"
        case .access:
            return "\(law.lawName) Data Access Request - \(userName)"
        }
    }
    
    // MARK: - Email Bodies
    
    static func body(type: RequestType, brokerName: String, userName: String, userEmail: String, law: PrivacyLaw) -> String {
        switch type {
        case .delete:
            return deletionBody(brokerName: brokerName, userName: userName, userEmail: userEmail, law: law)
        case .optOut:
            return optOutBody(brokerName: brokerName, userName: userName, userEmail: userEmail, law: law)
        case .access:
            return accessBody(brokerName: brokerName, userName: userName, userEmail: userEmail, law: law)
        }
    }
    
    private static func deletionBody(brokerName: String, userName: String, userEmail: String, law: PrivacyLaw) -> String {
        """
        To Whom It May Concern at \(brokerName),
        
        I am a \(law.state) resident writing to exercise my rights under the \(law.lawName), \(law.statute).
        
        I hereby request that you:
        
        1. DELETE all personal information you have collected, stored, or maintained about me, including but not limited to: my name, email addresses, phone numbers, physical addresses, device identifiers, browsing history, purchase history, location data, biometric data, inferences drawn about me, and any profiles or scores associated with my identity.
        
        2. DIRECT any and all service providers, contractors, processors, or third parties with whom you have shared, sold, or disclosed my personal information to also delete my personal information from their records.
        
        3. OPT ME OUT of the sale, sharing, or disclosure of my personal information for cross-context behavioral advertising, profiling, or any other commercial purpose, effective immediately.
        
        4. CONFIRM in writing that the above actions have been completed.
        
        To assist in locating my records, here is my identifying information:
        - Full Name: \(userName)
        - Email Address: \(userEmail)
        
        Please acknowledge receipt of this request within 10 business days, and complete the deletion within \(law.responseDays) calendar days as required by law. Failure to comply may result in a complaint to the \(law.state) Attorney General's office.
        
        Do not require me to create an account, verify through a third-party service, or navigate a multi-step portal in order to exercise these rights. Such barriers may constitute a "dark pattern" under the \(law.lawName).
        
        This request is made under penalty of perjury. I declare that I am the consumer whose personal information is the subject of this request, and the information provided above is accurate.
        
        Sincerely,
        \(userName)
        \(law.state) Resident
        """
    }
    
    private static func optOutBody(brokerName: String, userName: String, userEmail: String, law: PrivacyLaw) -> String {
        """
        To Whom It May Concern at \(brokerName),
        
        I am a \(law.state) resident writing to exercise my right to opt out of the sale and sharing of my personal information under the \(law.lawName), \(law.statute).
        
        I direct you to:
        
        1. STOP selling my personal information to third parties.
        2. STOP sharing my personal information for cross-context behavioral advertising.
        3. NOTIFY all third parties to whom you have sold or shared my personal information in the past 90 days of this opt-out request.
        
        Identifying information:
        - Full Name: \(userName)
        - Email Address: \(userEmail)
        
        Please process this request within 15 business days as required by law.
        
        Sincerely,
        \(userName)
        \(law.state) Resident
        """
    }
    
    private static func accessBody(brokerName: String, userName: String, userEmail: String, law: PrivacyLaw) -> String {
        """
        To Whom It May Concern at \(brokerName),
        
        I am a \(law.state) resident exercising my Right to Know under the \(law.lawName), \(law.statute).
        
        I request that you disclose:
        
        1. The categories of personal information you have collected about me.
        2. The specific pieces of personal information you have collected about me.
        3. The categories of sources from which my personal information was collected.
        4. The business or commercial purpose for collecting or selling my personal information.
        5. The categories of third parties with whom you share my personal information.
        
        Identifying information:
        - Full Name: \(userName)
        - Email Address: \(userEmail)
        
        Please provide this information in a readily usable format within \(law.responseDays) calendar days as required by law.
        
        Sincerely,
        \(userName)
        \(law.state) Resident
        """
    }
    
    // MARK: - mailto: URL Generation
    
    static func mailtoURL(to: String, subject: String, body: String) -> URL? {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(encodedSubject)&body=\(encodedBody)"
        return URL(string: urlString)
    }
    
    // MARK: - AG Complaint
    
    static func agComplaintSubject(brokerName: String, law: PrivacyLaw) -> String {
        "\(law.lawName) Complaint: \(brokerName) -- Failure to Respond to Consumer Data Request"
    }
    
    static func agComplaintBody(receipt: Receipt, userName: String, userEmail: String, law: PrivacyLaw) -> String {
        let daysSinceSent = Calendar.current.dateComponents([.day], from: receipt.dateSent, to: Date()).day ?? 0
        let dateSentFormatted = receipt.dateSent.formatted(date: .long, time: .omitted)
        let status = receipt.effectiveStatus == .denied ? "denied my request claiming exemption" : "failed to respond within the statutory \(law.responseDays)-day deadline"
        
        return """
        California Office of the Attorney General
        Attn: Privacy Enforcement
        
        Dear Attorney General,
        
        I am filing this complaint regarding \(receipt.brokerName)'s failure to comply with the \(law.lawName), \(law.statute).
        
        On \(dateSentFormatted), I submitted a \(receipt.requestType.replacingOccurrences(of: "_", with: " ")) request to \(receipt.brokerName) at the email address \(receipt.toEmail).
        
        As of today, \(daysSinceSent) days have elapsed, and the company has \(status).
        
        Request Details:
        - Company: \(receipt.brokerName)
        - Request Type: \(receipt.requestType.replacingOccurrences(of: "_", with: " ").capitalized)
        - Date Sent: \(dateSentFormatted)
        - Email Sent To: \(receipt.toEmail)
        - Law Cited: \(law.lawName), \(law.statute)
        - Statutory Deadline: \(law.responseDays) calendar days
        - Days Elapsed: \(daysSinceSent)
        - Status: \(receipt.effectiveStatus.label)
        
        I respectfully request that your office investigate this matter and take appropriate enforcement action.
        
        Sincerely,
        \(userName)
        \(userEmail)
        \(law.state) Resident
        """
    }
    
    /// California AG privacy complaint email address
    static let caAGEmail = "privacy@oag.ca.gov"
    
    /// State AG contact lookup (extend as needed)
    static func agEmail(for stateCode: String) -> String {
        switch stateCode {
        case "CA": return "privacy@oag.ca.gov"
        case "CO": return "attorney.general@coag.gov"
        case "CT": return "attorney.general@ct.gov"
        case "VA": return "mailoag@oag.state.va.us"
        case "TX": return "consumer.protection@oag.texas.gov"
        default: return "privacy@oag.ca.gov" // Default to CA
        }
    }
}

