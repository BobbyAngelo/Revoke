// US State Privacy Laws + category/pack metadata.
// Ported from the original iOS app (Broker.swift).

window.PRIVACY_LAWS = [
  { id: "CA", state: "California",     lawName: "CCPA/CPRA", statute: "Cal. Civ. Code §§1798.100-1798.199.100", responseDays: 45 },
  { id: "CO", state: "Colorado",       lawName: "CPA",       statute: "C.R.S. §6-1-1301 et seq.",                responseDays: 45 },
  { id: "CT", state: "Connecticut",    lawName: "CTDPA",     statute: "Conn. Gen. Stat. §42-515 et seq.",         responseDays: 45 },
  { id: "VA", state: "Virginia",       lawName: "VCDPA",     statute: "Va. Code Ann. §59.1-575 et seq.",          responseDays: 45 },
  { id: "TX", state: "Texas",          lawName: "TDPSA",     statute: "Tex. Bus. & Com. Code §541.001 et seq.",   responseDays: 45 },
  { id: "OR", state: "Oregon",         lawName: "OCPA",      statute: "ORS §646A.570 et seq.",                    responseDays: 45 },
  { id: "NJ", state: "New Jersey",     lawName: "NJDPA",     statute: "N.J. Stat. Ann. §56:8-166 et seq.",        responseDays: 45 },
  { id: "DE", state: "Delaware",       lawName: "DPDPA",     statute: "6 Del. C. §12D-101 et seq.",               responseDays: 45 },
  { id: "MD", state: "Maryland",       lawName: "MODPA",     statute: "Md. Code Ann., Com. Law §14-4601 et seq.", responseDays: 45 },
  { id: "IN", state: "Indiana",        lawName: "INDPA",     statute: "Ind. Code §24-15-1 et seq.",               responseDays: 45 },
  { id: "KY", state: "Kentucky",       lawName: "KCDPA",     statute: "KRS §367.600 et seq.",                     responseDays: 45 },
  { id: "MT", state: "Montana",        lawName: "MTCDPA",    statute: "MCA §30-14-2801 et seq.",                  responseDays: 45 },
  { id: "NH", state: "New Hampshire",  lawName: "NHDPA",     statute: "N.H. Rev. Stat. Ann. §507-H:1 et seq.",    responseDays: 45 },
  { id: "IA", state: "Iowa",           lawName: "ICDPA",     statute: "Iowa Code §715D.1 et seq.",                responseDays: 90 },
  { id: "TN", state: "Tennessee",      lawName: "TIPA",      statute: "Tenn. Code Ann. §47-18-3201 et seq.",      responseDays: 45 },
  { id: "MN", state: "Minnesota",      lawName: "MCDPA",     statute: "Minn. Stat. §325O.01 et seq.",             responseDays: 45 },
  { id: "NE", state: "Nebraska",       lawName: "NEDPA",     statute: "Neb. Rev. Stat. §87-1101 et seq.",         responseDays: 45 },
];

// Fallback for states without a specific law yet (cites CCPA, honored by most companies nationwide).
window.OTHER_LAW = {
  id: "OTHER", state: "Other", lawName: "CCPA (voluntary)",
  statute: "Cal. Civ. Code §§1798.100-1798.199.100", responseDays: 45,
};

window.lawForState = function (code) {
  return window.PRIVACY_LAWS.find((l) => l.id === code) || (code === "OTHER" ? window.OTHER_LAW : window.OTHER_LAW);
};

// State Attorney General privacy-complaint contacts.
window.AG_EMAILS = {
  CA: "privacy@oag.ca.gov",
  CO: "attorney.general@coag.gov",
  CT: "attorney.general@ct.gov",
  VA: "mailoag@oag.state.va.us",
  TX: "consumer.protection@oag.texas.gov",
};
window.agEmailFor = function (code) {
  return window.AG_EMAILS[code] || "privacy@oag.ca.gov";
};

// Category display metadata.
window.CATEGORY_META = {
  data_broker:      { icon: "🕵️", label: "Data Brokers" },
  social_media:     { icon: "📱", label: "Social Media" },
  ad_network:       { icon: "📢", label: "Ad Networks" },
  retail:           { icon: "🛒", label: "Retail" },
  ai_company:       { icon: "🤖", label: "AI Companies" },
  surveillance:     { icon: "📡", label: "Surveillance" },
  location_broker:  { icon: "📍", label: "Location" },
  health_data:      { icon: "🏥", label: "Health" },
  finance:          { icon: "💳", label: "Finance" },
  search:           { icon: "🔍", label: "Search" },
};
window.categoryMeta = function (cat) {
  return window.CATEGORY_META[cat] || { icon: "📦", label: cat };
};

// Risk metadata.
window.riskLabel = function (risk) {
  switch (risk) {
    case "critical": return "Critical";
    case "high_priority": return "High Priority";
    case "elevated":
    case "high": return "Elevated";
    case "moderate": return "Moderate";
    case "standard":
    case "medium": return "Standard";
    case "low": return "Low Risk";
    default: return "Standard";
  }
};
window.riskClass = function (risk) {
  switch (risk) {
    case "critical":
    case "high_priority": return "risk-critical";
    case "elevated":
    case "high": return "risk-high";
    case "moderate":
    case "standard":
    case "medium": return "risk-medium";
    default: return "risk-low";
  }
};
window.riskOrder = function (risk) {
  const order = { critical: 0, high_priority: 1, high: 2, elevated: 3, moderate: 4, standard: 5, medium: 5, low: 6 };
  return order[risk] !== undefined ? order[risk] : 7;
};

window.methodLabel = function (method) {
  switch (method) {
    case "email": return "📧 Email";
    case "portal": return "🌐 Portal Required";
    case "drp": return "⚡ DRP Portal";
    case "web_form": return "🌐 Web Form";
    default: return "📧 Email";
  }
};
window.isPortalOnly = function (method) {
  return method === "portal" || method === "web_form";
};
