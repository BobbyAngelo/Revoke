// Client-side persistence. Everything lives in localStorage — nothing leaves the browser.

const SETTINGS_KEY = "revoke_settings";
const RECEIPTS_KEY = "revoke_receipts";

// --- Settings ---

window.loadSettings = function () {
  let s = {};
  try { s = JSON.parse(localStorage.getItem(SETTINGS_KEY)) || {}; } catch (e) { s = {}; }
  return {
    userName: s.userName || "",
    userEmail: s.userEmail || "",
    userState: s.userState || "CA",
    onboarded: !!s.onboarded,
  };
};
window.saveSettings = function (s) {
  localStorage.setItem(SETTINGS_KEY, JSON.stringify(s));
};

// --- Receipts ---

window.loadReceipts = function () {
  try { return JSON.parse(localStorage.getItem(RECEIPTS_KEY)) || []; } catch (e) { return []; }
};
window.saveReceipts = function (list) {
  localStorage.setItem(RECEIPTS_KEY, JSON.stringify(list));
};

window.addReceipt = function (broker, requestType, toEmail, law) {
  const list = window.loadReceipts();
  const now = new Date();
  const deadline = new Date(now.getTime() + law.responseDays * 86400000);
  const receipt = {
    id: (crypto.randomUUID ? crypto.randomUUID() : String(Date.now() + Math.random())),
    brokerId: broker.id,
    brokerName: broker.name,
    requestType: requestType,
    dateSent: now.toISOString(),
    toEmail: toEmail,
    lawCited: law.lawName,
    stateName: law.state,
    stateCode: law.id,
    deadlineDate: deadline.toISOString(),
    responseStatus: "pending",
    responseDate: null,
    responseNotes: null,
  };
  list.unshift(receipt);
  window.saveReceipts(list);
  return receipt;
};

window.updateReceiptStatus = function (id, status, notes) {
  const list = window.loadReceipts();
  const r = list.find((x) => x.id === id);
  if (r) {
    r.responseStatus = status;
    r.responseDate = new Date().toISOString();
    r.responseNotes = notes || null;
    window.saveReceipts(list);
  }
};

window.removeReceipt = function (id) {
  window.saveReceipts(window.loadReceipts().filter((x) => x.id !== id));
};

// --- Status logic (ported from Receipt.swift) ---

window.STATUS_META = {
  pending:   { label: "Pending",         cls: "st-pending" },
  confirmed: { label: "Confirmed",       cls: "st-confirmed" },
  no_account:{ label: "No Account",      cls: "st-gray" },
  redirected:{ label: "Portal Required", cls: "st-action" },
  needs_info:{ label: "Needs Info",      cls: "st-action" },
  denied:    { label: "Denied",          cls: "st-bad" },
  no_reply:  { label: "No Reply",        cls: "st-bad" },
};

window.statusLabel = function (status) {
  return (window.STATUS_META[status] || { label: status }).label;
};

window.isOverdue = function (r) {
  return new Date() > new Date(r.deadlineDate) && r.responseStatus === "pending";
};

window.daysRemaining = function (r) {
  return Math.max(0, Math.ceil((new Date(r.deadlineDate) - new Date()) / 86400000));
};

window.effectiveStatus = function (r) {
  if (r.responseStatus === "pending" && new Date() > new Date(r.deadlineDate)) return "no_reply";
  return r.responseStatus;
};

window.receiptStatusLabel = function (r) {
  if (r.responseStatus !== "pending") return window.statusLabel(r.responseStatus);
  if (window.isOverdue(r)) return "OVERDUE";
  const d = window.daysRemaining(r);
  if (d <= 7) return `${d}d left`;
  return `${d} days`;
};

window.needsAction = function (r) {
  return ["redirected", "needs_info", "no_reply"].includes(window.effectiveStatus(r));
};

window.canFileComplaint = function (r) {
  const e = window.effectiveStatus(r);
  return e === "no_reply" || e === "denied";
};
