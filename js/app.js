// Revoke web app — main controller. No backend, no tracking.
(function () {
  "use strict";

  const brokers = (window.BROKERS || []).slice();
  let settings = window.loadSettings();
  let activeTab = "browse";
  let activeCategory = "all";
  let searchTerm = "";

  const root = document.getElementById("root");

  // ---------- helpers ----------
  function el(html) {
    const t = document.createElement("template");
    t.innerHTML = html.trim();
    return t.content.firstChild;
  }
  function esc(s) {
    return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => (
      { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]
    ));
  }
  function toast(msg) {
    let t = document.getElementById("toast");
    if (!t) { t = el('<div id="toast" class="toast"></div>'); document.body.appendChild(t); }
    t.textContent = msg;
    t.classList.add("show");
    clearTimeout(t._timer);
    t._timer = setTimeout(() => t.classList.remove("show"), 2200);
  }
  function profileReady() {
    return settings.userName.trim() && settings.userEmail.trim();
  }

  // ---------- top bar + tabs ----------
  function renderShell() {
    document.body.innerHTML = "";
    const top = el(`
      <div class="topbar">
        <div class="brand">
          <img src="assets/icon.png" alt="Revoke logo" onerror="this.style.display='none'">
          <div><h1>Revoke</h1><div class="tag">Reclaim your data privacy</div></div>
        </div>
      </div>`);
    const app = el('<div class="app" id="root"></div>');
    const tabs = el(`
      <nav class="tabbar">
        <button data-tab="browse"><span class="ic">🏢</span>Browse</button>
        <button data-tab="sent"><span class="ic">📬</span>Sent</button>
        <button data-tab="learn"><span class="ic">📚</span>Learn</button>
        <button data-tab="settings"><span class="ic">⚙️</span>Settings</button>
      </nav>`);
    document.body.appendChild(top);
    document.body.appendChild(app);
    document.body.appendChild(tabs);
    tabs.querySelectorAll("button").forEach((b) =>
      b.addEventListener("click", () => { activeTab = b.dataset.tab; render(); })
    );
  }

  function render() {
    const r = document.getElementById("root");
    r.innerHTML = "";
    document.querySelectorAll(".tabbar button").forEach((b) =>
      b.classList.toggle("active", b.dataset.tab === activeTab)
    );
    if (activeTab === "browse") renderBrowse(r);
    else if (activeTab === "sent") renderSent(r);
    else if (activeTab === "learn") renderLearn(r);
    else if (activeTab === "settings") renderSettings(r);
    window.scrollTo(0, 0);
  }

  // ---------- Browse ----------
  function renderBrowse(r) {
    if (!profileReady()) {
      r.appendChild(el(`
        <div class="section">
          <div class="card">
            <h2 style="margin:0 0 6px">Set up your profile first</h2>
            <p style="color:var(--text-dim);font-size:14px;line-height:1.5;margin:0">
              Revoke needs your name, email, and state to generate legally-worded requests.
              This information is stored only in your browser and never sent anywhere.
            </p>
            <button class="btn" style="margin-top:14px" id="goSettings">Set up profile</button>
          </div>
        </div>`));
      r.querySelector("#goSettings").addEventListener("click", () => { activeTab = "settings"; render(); });
      return;
    }

    const search = el('<input class="search" type="search" placeholder="Search 178+ companies…">');
    search.value = searchTerm;
    search.addEventListener("input", () => { searchTerm = search.value; renderBrowse(r); r.querySelector(".search").focus(); });
    r.appendChild(search);

    const cats = ["all", ...Object.keys(window.CATEGORY_META)];
    const chips = el('<div class="chips"></div>');
    cats.forEach((c) => {
      const label = c === "all" ? "All" : window.categoryMeta(c).label;
      const chip = el(`<div class="chip ${c === activeCategory ? "active" : ""}">${esc(label)}</div>`);
      chip.addEventListener("click", () => { activeCategory = c; renderBrowse(r); });
      chips.appendChild(chip);
    });
    r.appendChild(chips);

    let list = brokers.slice();
    if (activeCategory !== "all") list = list.filter((b) => b.category === activeCategory);
    if (searchTerm.trim()) {
      const q = searchTerm.toLowerCase();
      list = list.filter((b) => b.name.toLowerCase().includes(q) || (b.notes || "").toLowerCase().includes(q));
    }
    list.sort((a, b) => window.riskOrder(a.risk_level) - window.riskOrder(b.risk_level) || a.name.localeCompare(b.name));

    const sec = el(`<div class="section"><div class="section-title">${list.length} ${list.length === 1 ? "company" : "companies"}</div></div>`);
    if (!list.length) {
      sec.appendChild(el('<div class="empty"><div class="big">🔍</div>No companies match your search.</div>'));
    }
    list.forEach((b) => {
      const meta = window.categoryMeta(b.category);
      const row = el(`
        <div class="broker">
          <div class="emoji">${meta.icon}</div>
          <div class="info">
            <div class="name">${esc(b.name)}</div>
            <div class="meta">${esc(meta.label)} · ${window.methodLabel(b.method)}</div>
          </div>
          <span class="pill ${window.riskClass(b.risk_level)}">${esc(window.riskLabel(b.risk_level))}</span>
          <span class="chev">›</span>
        </div>`);
      row.addEventListener("click", () => openComposer(b));
      sec.appendChild(row);
    });
    r.appendChild(sec);
  }

  // ---------- Composer modal ----------
  function openComposer(broker) {
    const law = window.lawForState(settings.userState);
    let type = "delete";

    const portalOnly = window.isPortalOnly(broker.method);
    const backdrop = el('<div class="modal-backdrop"></div>');
    const modal = el('<div class="modal"></div>');
    backdrop.appendChild(modal);
    backdrop.addEventListener("click", (e) => { if (e.target === backdrop) backdrop.remove(); });
    document.body.appendChild(backdrop);

    function paint() {
      const subject = window.emailSubject(type, settings.userName, law);
      const body = window.emailBody(type, broker.name, settings.userName, settings.userEmail, law);
      const to = broker.privacy_email || "";
      modal.innerHTML = "";
      modal.appendChild(el(`<button class="modal-close" aria-label="Close">✕</button>`));
      modal.appendChild(el(`<h2>${esc(broker.name)}</h2>`));
      modal.appendChild(el(`<div class="sub">${esc(window.categoryMeta(broker.category).label)} · Citing ${esc(law.lawName)} (${esc(law.state)})</div>`));

      const seg = el('<div class="seg"></div>');
      window.REQUEST_TYPES.forEach((rt) => {
        const b = el(`<button class="${rt.id === type ? "active" : ""}">${rt.icon} ${esc(rt.label)}</button>`);
        b.addEventListener("click", () => { type = rt.id; paint(); });
        seg.appendChild(b);
      });
      modal.appendChild(seg);

      if (portalOnly) {
        modal.appendChild(el(`<div class="notice">⚠️ ${esc(broker.name)} requires a web portal or form rather than email. ${broker.notes ? esc(broker.notes) : ""}</div>`));
      }
      if (!to && !portalOnly) {
        modal.appendChild(el(`<div class="notice">No public privacy email is listed for this company. Use their portal below.</div>`));
      }

      modal.appendChild(el(`<div style="font-size:12px;color:var(--text-faint);margin-top:14px">${to ? "To: " + esc(to) + " · " : ""}Subject: ${esc(subject)}</div>`));
      modal.appendChild(el(`<div class="email-preview">${esc(body)}</div>`));

      const row = el('<div class="btn-row"></div>');

      if (to && !portalOnly) {
        const sendBtn = el('<button class="btn">✉️ Open in email</button>');
        sendBtn.addEventListener("click", () => {
          window.location.href = window.mailtoURL(to, subject, body);
          window.addReceipt(broker, type, to, law);
          toast("Saved to Sent. Deadline tracking started.");
          setTimeout(() => backdrop.remove(), 400);
        });
        row.appendChild(sendBtn);
      }

      const copyBtn = el('<button class="btn secondary">📋 Copy email</button>');
      copyBtn.addEventListener("click", async () => {
        const full = (to ? `To: ${to}\n` : "") + `Subject: ${subject}\n\n${body}`;
        try { await navigator.clipboard.writeText(full); toast("Email copied to clipboard"); }
        catch (e) { toast("Copy failed — select the text manually"); }
        if (to) window.addReceipt(broker, type, to, law);
      });
      row.appendChild(copyBtn);
      modal.appendChild(row);

      if (broker.privacy_url) {
        const portalBtn = el(`<button class="btn ghost" style="margin-top:8px">🌐 Open company privacy portal</button>`);
        portalBtn.addEventListener("click", () => {
          window.open(broker.privacy_url, "_blank", "noopener");
          window.addReceipt(broker, type, to || broker.privacy_url, law);
          toast("Logged to Sent. Submit the form in the new tab.");
        });
        modal.appendChild(portalBtn);
      }

      modal.appendChild(el(`<div class="foot">Companies must respond within ${law.responseDays} days under ${esc(law.lawName)}. Revoke saves a receipt and tracks the deadline.</div>`));
      modal.querySelector(".modal-close").addEventListener("click", () => backdrop.remove());
    }
    paint();
  }

  // ---------- Sent ----------
  function renderSent(r) {
    const receipts = window.loadReceipts();
    const stats = {
      total: receipts.length,
      pending: receipts.filter((x) => x.responseStatus === "pending" && !window.isOverdue(x)).length,
      confirmed: receipts.filter((x) => x.responseStatus === "confirmed").length,
      overdue: receipts.filter((x) => window.effectiveStatus(x) === "no_reply").length,
    };

    const grid = el(`
      <div class="stats">
        <div class="stat"><div class="num">${stats.total}</div><div class="lbl">Total sent</div></div>
        <div class="stat"><div class="num" style="color:var(--accent)">${stats.pending}</div><div class="lbl">Pending</div></div>
        <div class="stat"><div class="num" style="color:var(--green)">${stats.confirmed}</div><div class="lbl">Confirmed deleted</div></div>
        <div class="stat"><div class="num" style="color:var(--red)">${stats.overdue}</div><div class="lbl">Overdue</div></div>
      </div>`);
    r.appendChild(grid);

    if (!receipts.length) {
      r.appendChild(el('<div class="empty"><div class="big">📭</div>No requests yet.<br>Send your first one from the Browse tab.</div>'));
      return;
    }

    const sec = el('<div class="section"></div>');
    receipts.forEach((rc) => {
      const eff = window.effectiveStatus(rc);
      const meta = window.STATUS_META[eff] || window.STATUS_META.pending;
      const label = window.receiptStatusLabel(rc);
      const sentOn = new Date(rc.dateSent).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
      const card = el(`
        <div class="receipt">
          <div class="top">
            <div>
              <div class="rname">${esc(rc.brokerName)}</div>
              <div class="rmeta">${esc(rc.requestType.replace(/_/g, " "))} · Sent ${sentOn} · ${esc(rc.lawCited)}</div>
            </div>
            <span class="status-pill ${meta.cls}">${esc(label)}</span>
          </div>
        </div>`);

      const sel = el(`
        <select>
          <option value="pending">Update status…</option>
          <option value="confirmed">✅ They confirmed deletion</option>
          <option value="no_account">🚫 They found no account</option>
          <option value="redirected">↪️ They redirected me to a portal</option>
          <option value="needs_info">❓ They need more info</option>
          <option value="denied">⛔ They denied (claimed exemption)</option>
        </select>`);
      sel.value = rc.responseStatus === "pending" ? "pending" : rc.responseStatus;
      sel.addEventListener("change", () => {
        if (sel.value !== "pending") { window.updateReceiptStatus(rc.id, sel.value); renderSent(r); }
      });
      card.appendChild(sel);

      if (window.canFileComplaint(rc)) {
        const law = window.lawForState(rc.stateCode || settings.userState);
        const agBtn = el('<button class="btn danger" style="margin-top:10px">🏛️ File Attorney General complaint</button>');
        agBtn.addEventListener("click", () => {
          const subject = window.agComplaintSubject(rc.brokerName, law);
          const body = window.agComplaintBody(rc, settings.userName, settings.userEmail, law);
          window.location.href = window.mailtoURL(window.agEmailFor(rc.stateCode || settings.userState), subject, body);
        });
        card.appendChild(agBtn);
      }

      const rm = el('<button class="btn ghost" style="margin-top:6px;font-size:13px">Remove</button>');
      rm.addEventListener("click", () => { window.removeReceipt(rc.id); renderSent(r); });
      card.appendChild(rm);

      sec.appendChild(card);
    });
    r.appendChild(sec);
  }

  // ---------- Learn ----------
  function renderLearn(r) {
    const law = window.lawForState(settings.userState);
    r.appendChild(el(`
      <div class="section">
        <div class="section-title">Your rights</div>
        <div class="card">
          <p style="margin:0 0 10px;line-height:1.55;font-size:14px;color:var(--text-dim)">
            Companies profit from your personal data — names, addresses, location, browsing and purchase
            history, and more. Most US state privacy laws give you the legal right to make them delete it,
            stop selling it, or tell you what they hold.
          </p>
          <p style="margin:0;line-height:1.55;font-size:14px;color:var(--text-dim)">
            Revoke writes a request that cites the specific statute that applies to you and opens it in your
            email app. The company is legally required to respond within a set deadline.
          </p>
        </div>
      </div>
      <div class="section">
        <div class="section-title">The three requests</div>
        <div class="card">
          <p style="margin:0 0 8px;font-size:14px"><strong>🗑️ Delete</strong> — erase everything they have on you.</p>
          <p style="margin:0 0 8px;font-size:14px"><strong>✋ Opt out</strong> — stop the sale and sharing of your data.</p>
          <p style="margin:0;font-size:14px"><strong>🔍 Access</strong> — find out exactly what they've collected.</p>
        </div>
      </div>
      <div class="section">
        <div class="section-title">If they ignore you</div>
        <div class="card">
          <p style="margin:0;line-height:1.55;font-size:14px;color:var(--text-dim)">
            When the statutory deadline passes with no response, Revoke can generate a complaint to your
            state Attorney General, pre-filled with the details of your request. Regulators take these seriously.
          </p>
        </div>
      </div>
      <div class="section">
        <div class="section-title">Currently in your state</div>
        <div class="card">
          <p style="margin:0;font-size:14px;line-height:1.55">
            <strong>${esc(law.state)}</strong> — ${esc(law.lawName)}<br>
            <span style="color:var(--text-dim)">${esc(law.statute)}</span><br>
            <span style="color:var(--text-dim)">Response deadline: ${law.responseDays} days</span>
          </p>
        </div>
      </div>
      <div class="foot">Revoke is not a law firm and does not provide legal advice. It helps you exercise rights you already have.</div>`));
  }

  // ---------- Settings ----------
  function renderSettings(r) {
    const sec = el('<div class="section"></div>');
    sec.appendChild(el('<div class="section-title">Your information</div>'));
    const card = el('<div class="card"></div>');

    const nameF = el(`<div class="field"><label>Full name</label><input id="f-name" type="text" placeholder="Jane Doe"></div>`);
    const emailF = el(`<div class="field"><label>Email</label><input id="f-email" type="email" inputmode="email" placeholder="jane@example.com"></div>`);
    nameF.querySelector("input").value = settings.userName;
    emailF.querySelector("input").value = settings.userEmail;

    const stateF = el(`<div class="field"><label>Your state</label><select id="f-state"></select><div class="hint" id="state-hint"></div></div>`);
    const sel = stateF.querySelector("select");
    window.PRIVACY_LAWS.forEach((l) => sel.appendChild(el(`<option value="${l.id}">${esc(l.state)} (${esc(l.lawName)})</option>`)));
    sel.appendChild(el('<option value="OTHER">Other (no state law yet)</option>'));
    sel.value = settings.userState;

    function updateHint() {
      const law = window.lawForState(sel.value);
      stateF.querySelector("#state-hint").textContent =
        sel.value === "OTHER"
          ? "Your state has no specific privacy law yet. Requests will cite the CCPA, which most companies honor nationwide."
          : `Requests will cite: ${law.statute} · Response deadline: ${law.responseDays} days`;
    }
    updateHint();
    sel.addEventListener("change", updateHint);

    card.appendChild(nameF);
    card.appendChild(emailF);
    card.appendChild(stateF);
    card.appendChild(el('<div class="hint" style="margin-top:14px">🔒 This information is stored only in this browser (localStorage). It is never uploaded, and there are no accounts, servers, or tracking.</div>'));

    const save = el('<button class="btn" style="margin-top:16px">Save</button>');
    save.addEventListener("click", () => {
      settings.userName = nameF.querySelector("input").value.trim();
      settings.userEmail = emailF.querySelector("input").value.trim();
      settings.userState = sel.value;
      settings.onboarded = true;
      window.saveSettings(settings);
      toast("Saved");
      activeTab = "browse";
      render();
    });
    card.appendChild(save);
    sec.appendChild(card);
    r.appendChild(sec);

    const danger = el('<div class="section"><div class="section-title">Data</div></div>');
    const resetCard = el('<div class="card"></div>');
    const resetBtn = el('<button class="btn danger">Reset all data</button>');
    resetBtn.addEventListener("click", () => {
      if (confirm("Delete all your saved receipts and settings from this browser?")) {
        localStorage.removeItem("revoke_settings");
        localStorage.removeItem("revoke_receipts");
        settings = window.loadSettings();
        toast("All local data cleared");
        activeTab = "settings";
        render();
      }
    });
    resetCard.appendChild(resetBtn);
    resetCard.appendChild(el('<div class="hint" style="margin-top:10px">Removes every receipt and your profile from this device.</div>'));
    danger.appendChild(resetCard);
    r.appendChild(danger);

    r.appendChild(el(`
      <div class="section">
        <div class="card" style="text-align:center">
          <div style="font-size:13px;color:var(--text-dim)">Revoke · Open source · v1.0</div>
          <div style="font-size:12px;color:var(--text-faint);margin-top:6px">No accounts. No servers. No tracking.</div>
          <div style="margin-top:10px;font-size:13px">
            <a href="privacy.html">Privacy</a> &nbsp;·&nbsp;
            <a href="terms.html">Terms</a>
          </div>
        </div>
      </div>`));
  }

  // ---------- boot ----------
  renderShell();
  render();
})();
