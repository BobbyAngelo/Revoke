// Legally-worded email + AG complaint templates.
// Ported verbatim from the original iOS app (EmailTemplate.swift).

window.REQUEST_TYPES = [
  { id: "delete",  label: "Delete My Data",  icon: "🗑️" },
  { id: "opt_out", label: "Opt Out of Sale", icon: "✋" },
  { id: "access",  label: "What Do You Have?", icon: "🔍" },
];

window.emailSubject = function (type, userName, law) {
  switch (type) {
    case "delete":  return `${law.lawName} Data Deletion Request - ${userName}`;
    case "opt_out": return `${law.lawName} Opt-Out Request - ${userName}`;
    case "access":  return `${law.lawName} Data Access Request - ${userName}`;
    default:        return `${law.lawName} Request - ${userName}`;
  }
};

function deletionBody(brokerName, userName, userEmail, law) {
  return `To Whom It May Concern at ${brokerName},

I am a ${law.state} resident writing to exercise my rights under the ${law.lawName}, ${law.statute}.

I hereby request that you:

1. DELETE all personal information you have collected, stored, or maintained about me, including but not limited to: my name, email addresses, phone numbers, physical addresses, device identifiers, browsing history, purchase history, location data, biometric data, inferences drawn about me, and any profiles or scores associated with my identity.

2. DIRECT any and all service providers, contractors, processors, or third parties with whom you have shared, sold, or disclosed my personal information to also delete my personal information from their records.

3. OPT ME OUT of the sale, sharing, or disclosure of my personal information for cross-context behavioral advertising, profiling, or any other commercial purpose, effective immediately.

4. CONFIRM in writing that the above actions have been completed.

To assist in locating my records, here is my identifying information:
- Full Name: ${userName}
- Email Address: ${userEmail}

Please acknowledge receipt of this request within 10 business days, and complete the deletion within ${law.responseDays} calendar days as required by law. Failure to comply may result in a complaint to the ${law.state} Attorney General's office.

Do not require me to create an account, verify through a third-party service, or navigate a multi-step portal in order to exercise these rights. Such barriers may constitute a "dark pattern" under the ${law.lawName}.

This request is made under penalty of perjury. I declare that I am the consumer whose personal information is the subject of this request, and the information provided above is accurate.

Sincerely,
${userName}
${law.state} Resident`;
}

function optOutBody(brokerName, userName, userEmail, law) {
  return `To Whom It May Concern at ${brokerName},

I am a ${law.state} resident writing to exercise my right to opt out of the sale and sharing of my personal information under the ${law.lawName}, ${law.statute}.

I direct you to:

1. STOP selling my personal information to third parties.
2. STOP sharing my personal information for cross-context behavioral advertising.
3. NOTIFY all third parties to whom you have sold or shared my personal information in the past 90 days of this opt-out request.

Identifying information:
- Full Name: ${userName}
- Email Address: ${userEmail}

Please process this request within 15 business days as required by law.

Sincerely,
${userName}
${law.state} Resident`;
}

function accessBody(brokerName, userName, userEmail, law) {
  return `To Whom It May Concern at ${brokerName},

I am a ${law.state} resident exercising my Right to Know under the ${law.lawName}, ${law.statute}.

I request that you disclose:

1. The categories of personal information you have collected about me.
2. The specific pieces of personal information you have collected about me.
3. The categories of sources from which my personal information was collected.
4. The business or commercial purpose for collecting or selling my personal information.
5. The categories of third parties with whom you share my personal information.

Identifying information:
- Full Name: ${userName}
- Email Address: ${userEmail}

Please provide this information in a readily usable format within ${law.responseDays} calendar days as required by law.

Sincerely,
${userName}
${law.state} Resident`;
}

window.emailBody = function (type, brokerName, userName, userEmail, law) {
  switch (type) {
    case "delete":  return deletionBody(brokerName, userName, userEmail, law);
    case "opt_out": return optOutBody(brokerName, userName, userEmail, law);
    case "access":  return accessBody(brokerName, userName, userEmail, law);
    default:        return deletionBody(brokerName, userName, userEmail, law);
  }
};

window.mailtoURL = function (to, subject, body) {
  return `mailto:${encodeURIComponent(to || "")}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
};

// --- Attorney General complaint ---

window.agComplaintSubject = function (brokerName, law) {
  return `${law.lawName} Complaint: ${brokerName} - Failure to Respond to Consumer Data Request`;
};

window.agComplaintBody = function (receipt, userName, userEmail, law) {
  const daysSinceSent = Math.max(0, Math.floor((Date.now() - new Date(receipt.dateSent)) / 86400000));
  const dateSentFormatted = new Date(receipt.dateSent).toLocaleDateString(undefined, { year: "numeric", month: "long", day: "numeric" });
  const effective = window.effectiveStatus(receipt);
  const status = effective === "denied"
    ? "denied my request claiming exemption"
    : `failed to respond within the statutory ${law.responseDays}-day deadline`;
  const reqTypePretty = receipt.requestType.replace(/_/g, " ");
  const reqTypeTitle = reqTypePretty.replace(/\b\w/g, (c) => c.toUpperCase());

  return `${law.state} Office of the Attorney General
Attn: Privacy Enforcement

Dear Attorney General,

I am filing this complaint regarding ${receipt.brokerName}'s failure to comply with the ${law.lawName}, ${law.statute}.

On ${dateSentFormatted}, I submitted a ${reqTypePretty} request to ${receipt.brokerName} at the email address ${receipt.toEmail}.

As of today, ${daysSinceSent} days have elapsed, and the company has ${status}.

Request Details:
- Company: ${receipt.brokerName}
- Request Type: ${reqTypeTitle}
- Date Sent: ${dateSentFormatted}
- Email Sent To: ${receipt.toEmail}
- Law Cited: ${law.lawName}, ${law.statute}
- Statutory Deadline: ${law.responseDays} calendar days
- Days Elapsed: ${daysSinceSent}
- Status: ${window.statusLabel(effective)}

I respectfully request that your office investigate this matter and take appropriate enforcement action.

Sincerely,
${userName}
${userEmail}
${law.state} Resident`;
};
