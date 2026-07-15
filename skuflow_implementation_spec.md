# SKU Flow — Implementation Spec
## For use in a new Claude chat alongside the SKU Flow App.jsx file

---

## CONTEXT

SKU Flow is a SaaS reseller operating system built on React/Vite/Supabase. The uploaded file is the current SKU Flow App.jsx. Three major updates need implementing in this order:

1. **Visual Design Overhaul** — new colour system, sidebar, typography, SVG nav icons
2. **Settings Refactor** — sidebar-nav-within-settings, 11 sections including Billing and Contact Us
3. **Onboarding Wizard** — step-by-step account setup shown on first login

Implement and confirm each phase before starting the next.

---

## CRITICAL RULES (apply to all phases)

- Surgical patches only — never rewrite the entire file
- Never define helper components as inline arrow functions inside parent components — always top-level named functions (causes white screen on re-render)
- Never use `toISOString()` for date logic — use `localDateStr()` / `getToday()` / `getWeekStart()`
- Version up the file on every output — if input is `App__1_.jsx`, output is `App__2_.jsx`
- Confirm the active file name before starting any work
- All new components must be top-level named functions, never inline

---

## PHASE 1 — VISUAL DESIGN

### Design tokens

Replace the existing `:root {}` CSS variable block with:

```css
:root {
  --sidebar-w:     220px;
  --sidebar-bg:    #16181D;
  --main-bg:       #F7F8FA;
  --card-bg:       #FFFFFF;
  --sf2:           #F0F2F5;
  --bd:            #E4E7EC;
  --border-dark:   #2A2D35;
  --tx:            #111318;
  --txm:           #6B7280;
  --txd:           #9CA3AF;
  --txs:           #D1D5DB;
  --ac:            #6366F1;
  --acl:           #EEF2FF;
  --acd:           #4F46E5;
  --sidebar-tx:    #9CA3AF;
  --sidebar-txh:   #F9FAFB;
  --sidebar-hover: #1E2028;
  --gn:            #16A34A;
  --gnl:           #F0FDF4;
  --rd:            #DC2626;
  --rdl:           #FEF2F2;
  --am:            #D97706;
  --aml:           #FFFBEB;
  --r:             8px;
  --r2:            6px;
  --shadow:        0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.04);
  --shadow-md:     0 4px 12px rgba(0,0,0,.08);
}
```

### SVG Nav icons

Add these as module-level constants before the NavItem component. All are 15×15, stroke 1.75, currentColor:

```jsx
const IcoDashboard  = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>;
const IcoStock      = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>;
const IcoListings   = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><line x1="3" y1="6" x2="3.01" y2="6"/><line x1="3" y1="12" x2="3.01" y2="12"/><line x1="3" y1="18" x2="3.01" y2="18"/></svg>;
const IcoMovement   = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>;
const IcoData       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>;
const IcoPin        = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>;
const IcoDrafter    = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>;
const IcoSold       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>;
const IcoShipping   = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>;
const IcoLive       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>;
const IcoCalc       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="4" y="2" width="16" height="20" rx="2"/><line x1="8" y1="6" x2="16" y2="6"/><line x1="8" y1="10" x2="16" y2="10"/><line x1="8" y1="14" x2="12" y2="14"/></svg>;
const IcoAnalytics  = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg>;
const IcoGrowth     = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>;
const IcoHistory    = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M3 3h5l2 3H3z"/><path d="M3 8h18v13H3z"/></svg>;
const IcoBell       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>;
const IcoSettings   = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>;
const IcoUser       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/></svg>;
const IcoMail       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>;
const IcoBilling    = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>;
const IcoVersion    = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>;
const IcoPrefs      = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83M16.95 16.95l2.83 2.83M1 12h4M19 12h4M4.22 19.78l2.83-2.83M16.95 7.05l2.83-2.83"/></svg>;
const IcoPlat       = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>;
const IcoGoals      = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/></svg>;
const IcoDataMgmt   = () => <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"/></svg>;
```

### NavItem component (top-level)

```jsx
function NavItem({ label, icon, active, onClick }) {
  return (
    <div className={`nav-item${active ? " active" : ""}`} onClick={onClick}>
      <span className="nav-icon">{icon}</span>
      <span>{label}</span>
    </div>
  );
}
```

### Sidebar nav — use emojis, NOT SVG icons

The main app sidebar uses **emojis** for nav icons, not SVG. The SVG icons defined above are for the **Settings sidebar only**. Replace the `Ico*` references in the sidebar JSX with emoji strings:

```jsx
// Sidebar nav items use emojis:
<NavItem label="Dashboard"       icon="⊞"  active={view==="dashboard"}   onClick={()=>setView("dashboard")}/>
<NavItem label="Stock"           icon="◫"  active={view==="stock"}       onClick={()=>setView("stock")}/>
<NavItem label="Listings"        icon="☰"  active={view==="listings"}    onClick={()=>setView("listings")}/>
<NavItem label="Movement"        icon="⚡" active={view==="movement"}    onClick={()=>setView("movement")}/>
<NavItem label="Listing Data"    icon="📋" active={view==="listingdata"} onClick={()=>setView("listingdata")}/>
<NavItem label="Mark as Listed"  icon="📌" active={view==="marklisted"}  onClick={()=>setView("marklisted")}/>
<NavItem label="Listing Drafter" icon="✍️" active={view==="drafter"}     onClick={()=>setView("drafter")}/>
<NavItem label="Mark as Sold"    icon="✓"  active={view==="marksold"}    onClick={()=>setView("marksold")}/>
<NavItem label="Shipping"        icon="📦" active={view==="shipping"}    onClick={()=>setView("shipping")}/>
<NavItem label="Live Data"       icon="💰" active={view==="livedata"}    onClick={()=>setView("livedata")}/>
<NavItem label="Price Calc"      icon="🧮" active={view==="pricecalc"}   onClick={()=>setView("pricecalc")}/>
<NavItem label="Analytics"       icon="↗"  active={view==="analytics"}   onClick={()=>setView("analytics")}/>
<NavItem label="Growth"          icon="📈" active={view==="growth"}      onClick={()=>setView("growth")}/>
<NavItem label="History"         icon="🗂"  active={view==="history"}     onClick={()=>setView("history")}/>
```

The SVG icon constants (`IcoDashboard`, `IcoStock`, etc.) are **only used in the Settings sidebar nav**, not in the main app sidebar.

### Sidebar JSX structure

Replace the existing sidebar render. Find where the sidebar/nav is currently rendered and replace it:

```jsx
<div className="sidebar">
  <div className="sidebar-logo">
    <div className="logo-mark">SF</div>
    <div>
      <div className="logo-name">SKU Flow</div>
      <div className="logo-sub">Reseller OS</div>
    </div>
  </div>
  <div className="sidebar-nav">
    <div className="nav-group-label">Overview</div>
    <NavItem label="Dashboard"      icon={<IcoDashboard/>}  active={view==="dashboard"}   onClick={()=>setView("dashboard")}/>
    <NavItem label="Stock"          icon={<IcoStock/>}      active={view==="stock"}       onClick={()=>setView("stock")}/>
    <NavItem label="Listings"       icon={<IcoListings/>}   active={view==="listings"}    onClick={()=>setView("listings")}/>
    <div className="nav-group-label">Insights</div>
    <NavItem label="Movement"       icon={<IcoMovement/>}   active={view==="movement"}    onClick={()=>setView("movement")}/>
    <NavItem label="Listing Data"   icon={<IcoData/>}       active={view==="listingdata"} onClick={()=>setView("listingdata")}/>
    <div className="nav-group-label">Tools</div>
    <NavItem label="Mark as Listed" icon={<IcoPin/>}        active={view==="marklisted"}  onClick={()=>setView("marklisted")}/>
    <NavItem label="Listing Drafter"icon={<IcoDrafter/>}    active={view==="drafter"}     onClick={()=>setView("drafter")}/>
    <NavItem label="Mark as Sold"   icon={<IcoSold/>}       active={view==="marksold"}    onClick={()=>setView("marksold")}/>
    <NavItem label="Shipping"       icon={<IcoShipping/>}   active={view==="shipping"}    onClick={()=>setView("shipping")}/>
    <NavItem label="Live Data"      icon={<IcoLive/>}       active={view==="livedata"}    onClick={()=>setView("livedata")}/>
    <NavItem label="Price Calc"     icon={<IcoCalc/>}       active={view==="pricecalc"}   onClick={()=>setView("pricecalc")}/>
    <div className="nav-group-label">Reports</div>
    <NavItem label="Analytics"      icon={<IcoAnalytics/>}  active={view==="analytics"}   onClick={()=>setView("analytics")}/>
    <NavItem label="Growth"         icon={<IcoGrowth/>}     active={view==="growth"}      onClick={()=>setView("growth")}/>
    <NavItem label="History"        icon={<IcoHistory/>}    active={view==="history"}     onClick={()=>setView("history")}/>
  </div>
  <div className="sidebar-footer">
    <div className="workspace-badge" onClick={()=>setView("settings")}>
      <div className="ws-avatar">AD</div>
      <div className="ws-info">
        <div className="ws-name">Archive District</div>
        <div className="tier-pill">Pro</div>
      </div>
    </div>
  </div>
</div>
```

Note: workspace name and tier should come from liveData or appSettings if available. Hardcode "Archive District" / "Pro" as fallback for now.

### Sidebar CSS (add to stylesheet)

```css
.sidebar {
  width: var(--sidebar-w); background: var(--sidebar-bg);
  display: flex; flex-direction: column; flex-shrink: 0;
  border-right: 1px solid var(--border-dark);
  height: 100vh; position: fixed; left: 0; top: 0; z-index: 100;
}
.sidebar-logo {
  padding: 20px 18px 16px; border-bottom: 1px solid var(--border-dark);
  display: flex; align-items: center; gap: 10px; flex-shrink: 0;
}
.logo-mark {
  width: 30px; height: 30px; background: var(--ac); border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; font-weight: 800; color: #fff; flex-shrink: 0;
}
.logo-name { font-size: 13px; font-weight: 700; color: #F9FAFB; letter-spacing: -.2px; line-height: 1.2; }
.logo-sub  { font-size: 10px; color: #4B5563; font-weight: 500; }
.sidebar-nav { flex: 1; padding: 10px 0; overflow-y: auto; }
.nav-group-label {
  font-size: 10px; font-weight: 700; letter-spacing: .08em;
  text-transform: uppercase; color: #374151; padding: 14px 18px 5px;
}
.nav-item {
  display: flex; align-items: center; gap: 9px; padding: 7px 18px;
  color: var(--sidebar-tx); font-size: 12.5px; font-weight: 500;
  border-left: 3px solid transparent; cursor: pointer; transition: all .12s;
}
.nav-item:hover { background: var(--sidebar-hover); color: var(--sidebar-txh); }
.nav-item.active { color: #fff; background: rgba(99,102,241,.12); border-left-color: var(--ac); }
.nav-icon { width: 18px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.nav-icon svg { opacity: .75; }
.nav-item.active .nav-icon svg { opacity: 1; }
.sidebar-footer { border-top: 1px solid var(--border-dark); padding: 12px 14px; flex-shrink: 0; }
.workspace-badge {
  display: flex; align-items: center; gap: 8px; padding: 8px 10px;
  background: rgba(255,255,255,.04); border-radius: var(--r2);
  border: 1px solid var(--border-dark); cursor: pointer;
}
.ws-avatar {
  width: 26px; height: 26px; border-radius: 6px;
  background: linear-gradient(135deg, #6366F1, #8B5CF6);
  display: flex; align-items: center; justify-content: center;
  font-size: 10px; font-weight: 800; color: #fff; flex-shrink: 0;
}
.ws-name { font-size: 11.5px; font-weight: 600; color: #E5E7EB; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.tier-pill {
  display: inline-flex; font-size: 9.5px; font-weight: 700; letter-spacing: .05em;
  text-transform: uppercase; padding: 1px 7px; border-radius: 20px;
  background: rgba(99,102,241,.2); color: #A5B4FC; margin-top: 1px;
}
```

### Top bar

Replace the existing top bar render:

```jsx
<div className="topbar">
  <div className="topbar-title">{PAGE_TITLES[view] || "SKU Flow"}</div>
  <div className="topbar-right">
    <button className="notif-btn"><IcoBell /></button>
    <button className="btn btn-o btn-sm" onClick={()=>setView("settings")}>
      <IcoSettings /> Settings
    </button>
  </div>
</div>
```

Add PAGE_TITLES constant near top of file:

```jsx
const PAGE_TITLES = {
  dashboard:"Dashboard", stock:"Stock", listings:"Listings",
  movement:"Movement Tracker", listingdata:"Listing Data",
  marklisted:"Mark as Listed", drafter:"Listing Drafter",
  marksold:"Mark as Sold", shipping:"Shipping", livedata:"Live Data",
  pricecalc:"Price Calculator", analytics:"Analytics",
  growth:"Growth", history:"History", settings:"Settings",
};
```

Topbar CSS:

```css
.topbar {
  background: var(--card-bg); border-bottom: 1px solid var(--bd);
  padding: 0 22px; height: 52px;
  display: flex; align-items: center; justify-content: space-between; flex-shrink: 0;
}
.topbar-title { font-size: 14px; font-weight: 700; color: var(--tx); letter-spacing: -.2px; }
.topbar-right { display: flex; align-items: center; gap: 10px; }
.notif-btn {
  width: 32px; height: 32px; border-radius: var(--r2);
  background: var(--sf2); border: 1px solid var(--bd);
  display: flex; align-items: center; justify-content: center; cursor: pointer;
}
```

### Main layout CSS

```css
.app-layout { display: flex; min-height: 100vh; }
.main-content {
  margin-left: var(--sidebar-w); flex: 1; background: var(--main-bg);
  display: flex; flex-direction: column; min-height: 100vh;
}
.content-scroll { flex: 1; overflow-y: auto; padding: 20px 22px; }
```

---

## PHASE 2 — SETTINGS REFACTOR

### SCard helper (top-level)

```jsx
function SCard({ icon, title, sub, children }) {
  return (
    <div className="s-card">
      <div className="s-card-header">
        <div className="s-card-icon">{icon}</div>
        <div><div className="s-card-title">{title}</div>{sub&&<div className="s-card-sub">{sub}</div>}</div>
      </div>
      <div className="s-card-body">{children}</div>
    </div>
  );
}
```

### SettingsSidebar (top-level)

```jsx
function SettingsSidebar({ active, onChange }) {
  const groups = [
    { label: "Account", items: [
      { id:"account",        label:"Account",        icon:<IcoUser/> },
      { id:"notifications",  label:"Notifications",  icon:<IcoBell/> },
    ]},
    { label: "App", items: [
      { id:"preferences",    label:"Preferences",    icon:<IcoPrefs/> },
      { id:"platforms",      label:"Platforms",      icon:<IcoPlat/> },
      { id:"goals",          label:"Goals",          icon:<IcoGoals/> },
      { id:"stock",          label:"Stock",          icon:<IcoStock/> },
      { id:"listings",       label:"Listings",       icon:<IcoListings/> },
    ]},
    { label: "System", items: [
      { id:"data",           label:"Data",           icon:<IcoDataMgmt/> },
      { id:"billing",        label:"Billing & Plan", icon:<IcoBilling/> },
      { id:"contact",        label:"Contact Us",     icon:<IcoMail/> },
      { id:"versions",       label:"Version History",icon:<IcoVersion/> },
    ]},
  ];
  return (
    <div className="settings-nav">
      {groups.map(g=>(
        <div key={g.label}>
          <div className="settings-nav-label">{g.label}</div>
          {g.items.map(item=>(
            <div key={item.id}
              className={`settings-nav-item${active===item.id?" active":""}`}
              onClick={()=>onChange(item.id)}
            >
              <span className="settings-nav-icon">{item.icon}</span>
              {item.label}
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}
```

### SettingsPage wrapper (top-level)

```jsx
function SettingsPage({ liveData, setLiveData, listings, stockData, /* pass any other props the old Settings used */ }) {
  const [sTab, setSTab] = useState("account");
  const as = getAS(liveData);
  const setAS = (k, v) => setLiveData(prev => ({
    ...prev, appSettings: { ...(prev?.appSettings||{}), [k]: v }
  }));

  return (
    <div className="settings-layout">
      <SettingsSidebar active={sTab} onChange={setSTab} />
      <div className="settings-content">
        <div className="settings-page-title">{SETTINGS_TITLES[sTab]}</div>
        {sTab==="account"       && <SettingsAccount liveData={liveData} setLiveData={setLiveData} />}
        {sTab==="notifications" && <SettingsNotifications as={as} setAS={setAS} />}
        {sTab==="preferences"   && <SettingsPreferences as={as} setAS={setAS} />}
        {sTab==="platforms"     && <SettingsPlatforms as={as} setAS={setAS} liveData={liveData} setLiveData={setLiveData} />}
        {sTab==="goals"         && <SettingsGoals as={as} setAS={setAS} />}
        {sTab==="stock"         && <SettingsStock as={as} setAS={setAS} />}
        {sTab==="listings"      && <SettingsListings as={as} setAS={setAS} liveData={liveData} setLiveData={setLiveData} />}
        {sTab==="data"          && <SettingsData listings={listings} stockData={stockData} liveData={liveData} setLiveData={setLiveData} />}
        {sTab==="billing"       && <SettingsBilling listingCount={listings.length} />}
        {sTab==="contact"       && <SettingsContact />}
        {sTab==="versions"      && <VersionHistoryTab liveData={liveData} setLiveData={setLiveData} />}
      </div>
    </div>
  );
}

const SETTINGS_TITLES = {
  account:"Account", notifications:"Notifications", preferences:"Preferences",
  platforms:"Platforms & Listing Defaults", goals:"Goals", stock:"Stock",
  listings:"Listings", data:"Data Management", billing:"Billing & Plan",
  contact:"Contact Us", versions:"Version History",
};
```

### Settings layout CSS

```css
.settings-layout { display: flex; flex: 1; overflow: hidden; height: 100%; }
.settings-nav {
  width: 196px; background: var(--card-bg); border-right: 1px solid var(--bd);
  padding: 14px 0; overflow-y: auto; flex-shrink: 0;
}
.settings-nav-label {
  font-size: 10px; font-weight: 700; letter-spacing: .07em;
  text-transform: uppercase; color: var(--txd); padding: 12px 16px 5px;
}
.settings-nav-item {
  display: flex; align-items: center; gap: 9px; padding: 8px 16px;
  font-size: 12.5px; font-weight: 500; color: var(--txm);
  cursor: pointer; border-left: 3px solid transparent; transition: all .1s;
}
.settings-nav-item:hover { background: var(--main-bg); color: var(--tx); }
.settings-nav-item.active { background: var(--acl); color: var(--ac); border-left-color: var(--ac); font-weight: 600; }
.settings-nav-icon { width: 18px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; opacity: .75; }
.settings-nav-item.active .settings-nav-icon { opacity: 1; }
.settings-content { flex: 1; overflow-y: auto; padding: 24px 28px; }
.settings-page-title { font-size: 17px; font-weight: 800; color: var(--tx); letter-spacing: -.3px; margin-bottom: 20px; }
.s-card { background: var(--card-bg); border: 1px solid var(--bd); border-radius: var(--r); box-shadow: var(--shadow); margin-bottom: 14px; overflow: hidden; }
.s-card-header { padding: 13px 18px 13px 20px; border-bottom: 1px solid var(--bd); display: flex; align-items: center; gap: 10px; box-shadow: inset 3px 0 0 var(--ac); background: linear-gradient(90deg, rgba(99,102,241,.04) 0%, transparent 60%); }
/* IMPORTANT: Use box-shadow inset NOT border-left for the accent — border-left is clipped by overflow:hidden on .s-card */
.s-card-icon { width: 30px; height: 30px; border-radius: 7px; background: var(--acl); color: var(--ac); display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.s-card-title { font-size: 13px; font-weight: 700; color: var(--tx); }
.s-card-sub   { font-size: 11px; color: var(--txm); margin-top: 1px; }
.s-card-body  { padding: 16px 18px; }
.s-form-row { display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #F3F4F6; }
.s-form-row:last-child { border-bottom: none; padding-bottom: 0; }
.s-form-row:first-child { padding-top: 0; }
.s-row-label { font-size: 12.5px; font-weight: 600; color: var(--tx); }
.s-row-sub   { font-size: 11px; color: var(--txm); margin-top: 1px; }
```

### Individual settings sections — what each must contain

**SettingsAccount** — Profile card (name, business name save button), Email card (current email, change email button), Password card (current/new password fields, update button)

**SettingsNotifications** — Toggle rows for: Item Sold, Item Listed, Return Raised, Item Shipped, Notes Updated, Sunday Backup. Read/write from `as.notifSold`, `as.notifListed`, `as.notifReturn`, `as.notifShipped`, `as.notifNotes`, `as.notifSundayBackup`

**SettingsPreferences** — Toggles: Night Mode (`as.darkMode`), Compact Tables (`as.compactMode`). Inputs: Currency Symbol (`as.currency`), Date Format (`as.dateFormat`), Cash Buffer % (`as.cashBuffer`)

### Theme system — three modes

Add `as.theme` to `DEFAULT_APP_SETTINGS` (default: `"default"`). Three options:

| Value | Name | Description |
|---|---|---|
| `"default"` | Default | Current SKU Flow design — dark `#16181D` sidebar, `#F7F8FA` main, indigo accent |
| `"night"` | Night Mode | Full dark interface across main content and cards |
| `"classic"` | Classic | Original Archive District aesthetic — lighter sidebar, muted palette, original colours |

Replace the old `as.darkMode` boolean with `as.theme` string throughout. Remove `as.darkMode` from `DEFAULT_APP_SETTINGS`.

### Theme CSS variables

Add all three theme blocks to the top of the stylesheet, after the `:root {}` block:

```css
/* DEFAULT theme — already defined in :root, no override needed */

/* NIGHT MODE */
[data-theme="night"] {
  --main-bg:      #0E1015;
  --card-bg:      #16181D;
  --sf2:          #1E2028;
  --bd:           #2A2D35;
  --tx:           #F9FAFB;
  --txm:          #9CA3AF;
  --txd:          #6B7280;
  --txs:          #374151;
}

/* CLASSIC — original Archive District aesthetic */
[data-theme="classic"] {
  --sidebar-bg:   #1E2A3A;
  --sidebar-tx:   #94A3B8;
  --sidebar-txh:  #F1F5F9;
  --sidebar-hover:#243447;
  --main-bg:      #F1F5F9;
  --card-bg:      #FFFFFF;
  --sf2:          #E2E8F0;
  --bd:           #CBD5E1;
  --tx:           #0F172A;
  --txm:          #64748B;
  --txd:          #94A3B8;
  --ac:           #3B82F6;
  --acl:          #EFF6FF;
  --acd:          #2563EB;
}
```

### Theme application

```jsx
// In App root, apply theme on mount and whenever as.theme changes:
useEffect(() => {
  const theme = getAS(liveData).theme || "default";
  if (theme === "default") {
    document.documentElement.removeAttribute("data-theme");
  } else {
    document.documentElement.setAttribute("data-theme", theme);
  }
}, [liveData?.appSettings?.theme]);
```

### Theme picker UI in SettingsPreferences

Replace the old dark mode toggle with a three-option theme picker:

```jsx
<SCard icon={<IcoPrefs/>} title="Interface Theme" sub="Choose how SKU Flow looks">
  <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:10,paddingTop:4}}>
    {[
      { value:"default", label:"Default",  desc:"Dark sidebar, light content, indigo accent" },
      { value:"night",   label:"Night",    desc:"Full dark interface" },
      { value:"classic", label:"Classic",  desc:"Original Archive District look" },
    ].map(opt => (
      <div
        key={opt.value}
        onClick={() => setAS("theme", opt.value)}
        style={{
          border: `1.5px solid ${as.theme===opt.value ? "var(--ac)" : "var(--bd)"}`,
          background: as.theme===opt.value ? "var(--acl)" : "var(--card-bg)",
          borderRadius: "var(--r2)", padding: "10px 12px", cursor: "pointer",
          transition: "all .12s",
        }}
      >
        <div style={{fontSize:12,fontWeight:700,color:as.theme===opt.value?"var(--ac)":"var(--tx)",marginBottom:3}}>
          {opt.label}
          {as.theme===opt.value && " ✓"}
        </div>
        <div style={{fontSize:10.5,color:"var(--txm)",lineHeight:1.4}}>{opt.desc}</div>
      </div>
    ))}
  </div>
</SCard>
```

### Migration note

If any existing user data has `appSettings.darkMode: true`, treat it as `theme: "night"` on load:
```js
const getAS = (liveData) => {
  const raw = { ...DEFAULT_APP_SETTINGS, ...(liveData?.appSettings||{}) };
  // Migrate legacy darkMode boolean
  if (raw.darkMode === true && !raw.theme) raw.theme = "night";
  return raw;
};
```

**SettingsPlatforms** — Three pill-toggle sections: hiddenListedPlats, hiddenSoldPlats, crossListPlats. Below: Custom Types / Colours / Sizes as removable coloured pill tags (read from `as.customTypes`, `as.customColours`, `as.customSizes`). Below: Default Condition select, Drafter default condition select (Pro only)

**SettingsGoals** — Weekly profit target (`liveData.goals?.weeklyProfit`), weekly revenue, monthly profit, monthly revenue. Save writes to `liveData.goals`

**SettingsStock** — Sell-through warning threshold (`as.sellThrough`), Slow mover threshold days (`as.slowDays`), Velocity tags toggle (`as.velocityTags`)

**SettingsListings** — Slow mover threshold (duplicate from stock for discoverability), Cross-List tracker settings

**SettingsData** — XLSX export button, Reset listings button (danger, requires confirm), Reset stock button (danger, requires confirm). Migrate existing export/reset logic here

**SettingsBilling** — Four sections:

**1. Current plan card** — gradient indigo card showing: tier name, price/month, renewal date, listing usage bar (count / limit with % fill). Example: "Plus · £12.99/month · renews 14 Aug 2025 · 271 of 500 listings used"

**2. Upgrade your plan** — Three-column card grid (Core / Plus / Pro). Each card shows:
- Tier name + price (£7.99 / £12.99 / £19.99 per month)
- Listing limit (300 / 500 / 1,000)
- Feature list with ✓ (included) and ✕ (not included) for every major feature:
  - ✓/✕ Dashboard & Goals
  - ✓/✕ Stock management
  - ✓/✕ Listings management
  - ✓/✕ Mark as Listed / Sold
  - ✓/✕ Shipping tracker
  - ✓/✕ Live Data (basic)
  - ✓/✕ Pending payouts & Profit Pocketed (Pro only)
  - ✓/✕ Price Calculator
  - ✓/✕ Version History
  - ✓/✕ Velocity tags (Plus+)
  - ✓/✕ Movement Tracker (Plus+)
  - ✓/✕ Growth charts (Plus+)
  - ✓/✕ Analytics & Restock Intelligence (Pro only)
  - ✓/✕ Listing Drafter AI (Pro only)
  - ✓/✕ Cross-List Tracker (Pro only)
  - ✓/✕ Multi-platform accounts (Pro only)
- CTA button: "Current Plan" (greyed, current tier), "Upgrade" (accent, higher tier), "Downgrade" (ghost, lower tier)
- Upgrade/Downgrade buttons show "Coming Soon" modal for now
- Current plan card gets a recommended badge and accent border

**3. Payment history** — Table rows: date, plan name, amount, "Paid" badge, PDF download button. Placeholder data initially.

**4. Cancel subscription** — Red danger zone card: "Your access continues until [renewal date]." Cancel button requires confirmation modal before proceeding.

**SettingsContact** — Three type cards (Question/Suggestion/Issue). Subject input. Message textarea. Send button. Saves to Supabase `contact_submissions` table. Show success state after send.

**VersionHistoryTab** — Move the existing VersionHistory component content here unchanged

---

## PHASE 3 — ONBOARDING WIZARD

### When to show

In the App root render, before the main app layout:

```jsx
// Add to App root state:
const [onboardingDone, setOnboardingDone] = useState(true); // default true to avoid flash
// Set to false when profile loads and profile.onboarding_complete === false

if (!onboardingDone) {
  return <OnboardingWizard tier={tier} onComplete={handleOnboardingComplete} />;
}
```

```jsx
const handleOnboardingComplete = async (formData) => {
  // 1. Save settings from formData to liveData.appSettings
  setLiveData(prev => ({
    ...prev,
    appSettings: {
      ...(prev?.appSettings||{}),
      currency: formData.currency,
      dateFormat: formData.dateFormat,
      skuPrefix: formData.skuPrefix,
      bundlePrefix: formData.bundlePrefix,
      defaultCondition: formData.condition,
    },
    goals: {
      ...(prev?.goals||{}),
      weeklyProfit: formData.weeklyProfit,
      weeklyRevenue: formData.weeklyRevenue,
      monthlyProfit: formData.monthlyProfit,
      monthlyRevenue: formData.monthlyRevenue,
    }
  }));
  // 2. Save drafter config if Pro
  // 3. Mark onboarding complete in Supabase profiles table
  await supabase.from("profiles").update({ onboarding_complete: true }).eq("id", userId);
  setOnboardingDone(true);
};
```

### OnboardingWizard (top-level)

```jsx
function OnboardingWizard({ tier, onComplete }) {
  const isProOrInternal = ["pro","internal"].includes(tier);
  const totalSteps = isProOrInternal ? 6 : 4;
  const [step, setStep] = useState(1);
  const [form, setForm] = useState({
    name:"", businessName:"",
    currency:"£", dateFormat:"DD/MM/YYYY",
    platforms:["Depop","Vinted","eBay"],
    skuPrefix:"A", skuFormat:"A001",
    bundlePrefix:"BDL", bundleFormat:"BDL-001",
    condition:"Excellent",
    weeklyProfit:"", weeklyRevenue:"",
    monthlyProfit:"", monthlyRevenue:"",
    drafterTone:"casual", drafterDialect:"uk",
    drafterLength:"medium",
    alwaysInclude:"", neverInclude:"", brandVoice:"",
  });
  const set = (k,v) => setForm(p=>({...p,[k]:v}));
  const progress = Math.round((step/(totalSteps+1))*100);
  const canSkip = step > 2;
  const isComplete = step === totalSteps + 1;

  return (
    <div className="onb-screen">
      <div className="onb-progress"><div className="onb-progress-fill" style={{width:`${progress}%`}}/></div>
      <div className="onb-topnav">
        <div style={{display:"flex",alignItems:"center",gap:9}}>
          <div className="logo-mark">SF</div>
          <span style={{fontSize:13,fontWeight:700,color:"var(--tx)"}}>SKU Flow</span>
        </div>
        {!isComplete && <div className="onb-pill">Step {step} of {totalSteps}</div>}
        {isComplete && <div style={{fontSize:12,fontWeight:600,color:"var(--gn)"}}>✓ Setup complete</div>}
        {canSkip && !isComplete
          ? <span className="onb-skip" onClick={()=>setStep(s=>s+1)}>Skip for now</span>
          : <div style={{width:72}}/>
        }
      </div>
      <div className="onb-body">
        {step===1 && <OnbStep1 form={form} set={set}/>}
        {step===2 && <OnbStep2 form={form} set={set}/>}
        {step===3 && <OnbStep3 form={form} set={set}/>}
        {step===4 && <OnbStep4 form={form} set={set}/>}
        {step===5 && isProOrInternal && <OnbStep5/>}
        {step===6 && isProOrInternal && <OnbStep6 form={form} set={set}/>}
        {isComplete && <OnbComplete form={form} onComplete={onComplete}/>}
      </div>
      {!isComplete && (
        <div className="onb-footer">
          {step>1 ? <button className="btn btn-o" onClick={()=>setStep(s=>s-1)}>← Back</button> : <div/>}
          <button className="btn btn-p" onClick={()=>setStep(s=>s+1)}>
            {step===totalSteps?"Finish setup →":"Continue →"}
          </button>
        </div>
      )}
    </div>
  );
}
```

### Step components — all top-level named functions

**OnbStep1** — name input + businessName input, then divider, then currency pick (£/€/$), then date format pick (DD/MM/YYYY vs MM/DD/YYYY). Use opt-card grid.

**OnbStep2** — Platform multi-select grid (3 per row on mobile, 4 per row wider). Platforms: Depop (#FF2050), Vinted (#09B1BA), eBay (#E53238), Grailed (#1A1A1A), Whatnot (#7C3AED), Facebook (#1877F2), Vestiaire (#2B5CE6), Tilt (#FF6B35), + custom (dashed border, + icon).

**OnbStep3** — Item SKU pick (A001/001/VTG-001/AD-001) with live prefix input + preview. Divider. Bundle SKU pick (BDL-001/BATCH-01/B001/AD-BDL-01) with live prefix input + preview.

**OnbStep4** — Condition pick grid (New with tags/New without tags/Excellent/Good/Fair/Varies). Divider. Weekly profit + revenue currency inputs. Divider. Monthly profit + revenue currency inputs.

**OnbStep5** — Pro feature banner. Heading "Let's configure your Listing Drafter." Sub text. Checklist of 5 items (tone, dialect, length, always/never phrases, brand voice). Example output preview box in indigo light.

**OnbStep6** — Tone pick (Casual/Hype/Formal as stacked cards with icon + name + desc). Divider. Dialect pick (UK/US). Divider. Length pick (Short/Medium/Detailed). Divider. Always include textarea. Never include textarea. Brand voice textarea.

**OnbComplete** — Check icon (indigo gradient). "You're all set." heading. Sub text. Settings info note. Summary card showing: currency, platforms list, item SKU, bundle SKU, condition, weekly profit goal, drafter config (if Pro). "Enter SKU Flow →" full-width primary button calling onComplete(form).

### Onboarding CSS

```css
.onb-screen {
  position: fixed; inset: 0;
  background: var(--main-bg);
  display: flex; flex-direction: column; z-index: 9999;
}
.onb-progress {
  width: 100%; height: 4px; background: var(--bd); flex-shrink: 0;
}
.onb-progress-fill {
  height: 100%;
  background: linear-gradient(90deg, var(--ac), #8B5CF6);
  transition: width .3s ease;
}
.onb-topnav {
  height: 54px; background: var(--card-bg); border-bottom: 1px solid var(--bd);
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 36px; flex-shrink: 0;
}
.onb-pill {
  font-size: 11.5px; font-weight: 600; color: var(--txd);
  background: var(--main-bg); border: 1px solid var(--bd);
  padding: 4px 12px; border-radius: 20px;
}
.onb-skip {
  font-size: 12px; font-weight: 600; color: var(--txd);
  text-decoration: underline; text-underline-offset: 3px; cursor: pointer;
}
.onb-body {
  flex: 1; display: flex; align-items: center; justify-content: center;
  padding: 32px 36px; overflow-y: auto;
}
.onb-footer {
  height: 62px; background: var(--card-bg); border-top: 1px solid var(--bd);
  display: flex; align-items: center; justify-content: space-between;
  padding: 0 36px; flex-shrink: 0;
}
.onb-inner { width: 100%; max-width: 560px; }
.onb-inner-wide { width: 100%; max-width: 760px; }
.onb-tag {
  display: inline-flex; align-items: center; gap: 5px;
  font-size: 10.5px; font-weight: 700; letter-spacing: .07em;
  text-transform: uppercase; color: var(--ac); margin-bottom: 8px;
}
.onb-title { font-size: 24px; font-weight: 800; color: var(--tx); letter-spacing: -.5px; line-height: 1.2; margin-bottom: 6px; }
.onb-sub   { font-size: 13px; color: var(--txm); line-height: 1.65; margin-bottom: 24px; }
.onb-sec-label {
  font-size: 10.5px; font-weight: 700; letter-spacing: .07em;
  text-transform: uppercase; color: var(--txd);
  display: block; margin: 16px 0 8px;
}
.onb-sec-label:first-child { margin-top: 0; }
.onb-divider { height: 1px; background: var(--bd); margin: 18px 0; }
.onb-opt-grid { display: grid; gap: 8px; }
.onb-g2 { grid-template-columns: 1fr 1fr; }
.onb-g3 { grid-template-columns: 1fr 1fr 1fr; }
.onb-g4 { grid-template-columns: 1fr 1fr 1fr 1fr; }
.onb-opt {
  border: 1.5px solid var(--bd); border-radius: var(--r2);
  padding: 12px 14px; background: var(--card-bg);
  cursor: pointer; box-shadow: var(--shadow); transition: all .1s;
}
.onb-opt:hover { border-color: #C7D2FE; }
.onb-opt.sel   { border-color: var(--ac); background: var(--acl); }
.onb-opt-eg {
  font-family: monospace; font-size: 15px; font-weight: 700;
  color: var(--tx); margin-bottom: 3px;
}
.onb-opt.sel .onb-opt-eg { color: var(--ac); }
.onb-opt-desc { font-size: 11px; color: var(--txm); }
.onb-plat-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 8px; }
.onb-plat {
  border: 1.5px solid var(--bd); border-radius: var(--r2);
  padding: 12px 8px; background: var(--card-bg);
  text-align: center; cursor: pointer; box-shadow: var(--shadow); transition: all .1s;
}
.onb-plat.sel { border-color: var(--ac); background: var(--acl); }
.onb-plat-icon {
  width: 34px; height: 34px; border-radius: 9px; margin: 0 auto 6px;
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; font-weight: 800; color: #fff;
}
.onb-plat-name { font-size: 11px; font-weight: 700; color: var(--tx); }
.onb-plat.sel .onb-plat-name { color: var(--ac); }
.onb-sku-preview {
  display: flex; align-items: center; gap: 10px;
  background: var(--card-bg); border: 1px solid var(--bd);
  border-radius: var(--r2); padding: 9px 14px; margin-top: 8px; box-shadow: var(--shadow);
}
.onb-sku-result {
  margin-left: auto; font-family: monospace; font-size: 13px; font-weight: 700;
  color: var(--ac); background: var(--acl); padding: 4px 10px; border-radius: 5px;
}
.onb-goal-row {
  display: flex; align-items: center;
  background: var(--card-bg); border: 1.5px solid var(--bd);
  border-radius: var(--r2); overflow: hidden; box-shadow: var(--shadow); margin-bottom: 8px;
}
.onb-goal-pfx {
  padding: 0 12px; height: 42px; display: flex; align-items: center;
  background: #F9FAFB; border-right: 1px solid var(--bd);
  font-size: 14px; font-weight: 700; color: var(--txm);
}
.onb-goal-input {
  flex: 1; height: 42px; border: none; background: transparent;
  padding: 0 12px; font-size: 15px; font-weight: 700;
  color: var(--tx); font-family: inherit; outline: none;
}
.onb-tone-card {
  border: 1.5px solid var(--bd); border-radius: var(--r2);
  padding: 12px 14px; background: var(--card-bg);
  display: flex; align-items: center; gap: 12px;
  cursor: pointer; box-shadow: var(--shadow); transition: all .1s; margin-bottom: 8px;
}
.onb-tone-card.sel { border-color: var(--ac); background: var(--acl); }
.onb-tone-icon {
  width: 34px; height: 34px; border-radius: 8px; flex-shrink: 0;
  background: var(--main-bg); display: flex; align-items: center; justify-content: center;
}
.onb-tone-card.sel .onb-tone-icon { background: rgba(99,102,241,.12); }
.onb-tone-name { font-size: 13px; font-weight: 700; color: var(--tx); margin-bottom: 2px; }
.onb-tone-card.sel .onb-tone-name { color: var(--ac); }
.onb-tone-desc { font-size: 11px; color: var(--txm); }
```

---

## IMPLEMENTATION ORDER

1. CSS variables
2. SVG icon constants
3. PAGE_TITLES constant
4. NavItem component (top-level)
5. Sidebar JSX + CSS
6. Topbar JSX + CSS
7. Main layout CSS (app-layout, main-content, content-scroll)
8. Check renders → Phase 2
9. SCard component (top-level)
10. SettingsSidebar component (top-level)
11. All 11 settings section components (top-level, one at a time)
12. SettingsPage wrapper (top-level)
13. Replace existing settings render with SettingsPage
14. Check renders → Phase 3
15. All OnbStep components (top-level)
16. OnboardingWizard component (top-level)
17. Wire onboarding in App root
18. Final check

---

## EMPTY STATES

Every tab must have a designed empty state shown when there is no data. Empty states must include an icon, a short heading, a one-line explanation, and a call-to-action button where applicable.

### Required empty states

**Stock** — no bundles added yet
- Icon: box/package SVG
- Heading: "No stock yet"
- Sub: "Add your first wholesale bundle to start tracking."
- CTA: "+ Add Bundle" (primary button)

**Listings** — no listings added yet
- Icon: list SVG
- Heading: "No listings yet"
- Sub: "Add your first item to get started."
- CTA: "+ Add Listing" (primary button)

**Listings — filtered tab (Active / Sold / To List / Returns)** — filter returns nothing
- Icon: filter SVG
- Heading: "Nothing here"
- Sub: "No items match this filter right now."
- No CTA

**Movement Tracker** — no listing/selling activity yet
- Icon: activity/pulse SVG
- Heading: "No activity yet"
- Sub: "Movement data will appear here as you list and sell items."
- No CTA

**Shipping** — no items awaiting shipment
- Icon: truck SVG
- Heading: "All shipped"
- Sub: "No items are waiting to be dispatched."
- No CTA (positive state — use green accent)

**Mark as Listed — session history** — no items listed this session
- Inline micro-state only: "No items listed this session yet."

**Mark as Sold — session history** — no items sold this session
- Inline micro-state only: "No items sold this session yet."

**Analytics** — no listings data yet
- Icon: bar chart SVG
- Heading: "Not enough data yet"
- Sub: "Analytics will populate once you have listings and sales."
- No CTA

**Growth** — no sales history yet
- Icon: trending up SVG
- Heading: "Growth data will appear here"
- Sub: "Start listing and selling to see your progress over time."
- No CTA

**History** — no months of data yet
- Icon: calendar SVG
- Heading: "No history yet"
- Sub: "Your monthly and weekly summaries will appear here."
- No CTA

**Shipping queue — all shipped** — positive empty state
- Use green gnl background, green heading: "All caught up — nothing to ship."

### Empty state CSS

```css
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 24px;
  text-align: center;
  gap: 8px;
}

.empty-state-icon {
  width: 44px; height: 44px;
  border-radius: 12px;
  background: var(--acl);
  display: flex; align-items: center; justify-content: center;
  color: var(--ac);
  margin-bottom: 4px;
}

.empty-state-icon.positive { background: var(--gnl); color: var(--gn); }

.empty-state-title {
  font-size: 14px; font-weight: 700; color: var(--tx); letter-spacing: -.2px;
}

.empty-state-sub {
  font-size: 12px; color: var(--txm); line-height: 1.6; max-width: 260px;
}
```

### Empty state JSX pattern (top-level named function)

```jsx
function EmptyState({ icon, title, sub, action, positive }) {
  return (
    <div className="empty-state">
      <div className={`empty-state-icon${positive ? " positive" : ""}`}>{icon}</div>
      <div className="empty-state-title">{title}</div>
      {sub && <div className="empty-state-sub">{sub}</div>}
      {action && (
        <button className="btn btn-p" style={{marginTop:8}} onClick={action.onClick}>
          {action.label}
        </button>
      )}
    </div>
  );
}
```

---

## ONBOARDING SETTINGS — ALL UPDATABLE FROM SETTINGS

Every question asked during onboarding must have a corresponding editable field in Settings. Mapping:

| Onboarding step | Settings location |
|---|---|
| Name + business name | Settings → Account → Profile |
| Currency + date format | Settings → Preferences |
| Platform selection | Settings → Platforms → "Your platforms" multi-select |
| Item SKU format + prefix | Settings → Listings → "SKU Format" |
| Bundle SKU format + prefix | Settings → Listings → "Bundle SKU Format" |
| Default condition | Settings → Platforms → Listing Defaults |
| Weekly + monthly goals | Settings → Goals |
| Drafter tone + dialect | Settings → Platforms → Listing Drafter Config (Pro) |
| Drafter length | Settings → Platforms → Listing Drafter Config (Pro) |
| Always/never phrases | Settings → Platforms → Listing Drafter Config (Pro) |
| Brand voice notes | Settings → Platforms → Listing Drafter Config (Pro) |

### SKU Format settings (add to SettingsListings section)

```jsx
// In SettingsListings component:
<SCard icon={<IcoListings/>} title="Item SKU Format" sub="How new item SKUs are auto-generated">
  <div className="s-form-row">
    <div><div className="s-row-label">Format</div></div>
    <select className="fsel" value={as.skuFormat||"A001"} onChange={e=>setAS("skuFormat",e.target.value)}>
      <option value="A001">A001 — Letter + number</option>
      <option value="001">001 — Numbers only</option>
      <option value="CUSTOM-001">Custom prefix + number</option>
      <option value="AD-001">Initials + number</option>
    </select>
  </div>
  <div className="s-form-row">
    <div><div className="s-row-label">Custom prefix</div><div className="s-row-sub">Used when format is "Custom prefix"</div></div>
    <input className="finp" style={{width:80,textAlign:"center"}} value={as.skuPrefix||"A"} onChange={e=>setAS("skuPrefix",e.target.value.toUpperCase())} maxLength={6} />
  </div>
</SCard>

<SCard icon={<IcoStock/>} title="Bundle SKU Format" sub="How new bundle SKUs are auto-generated">
  <div className="s-form-row">
    <div><div className="s-row-label">Format</div></div>
    <select className="fsel" value={as.bundleFormat||"BDL-001"} onChange={e=>setAS("bundleFormat",e.target.value)}>
      <option value="BDL-001">BDL-001 — BDL prefix</option>
      <option value="BATCH-01">BATCH-01 — BATCH prefix</option>
      <option value="B001">B001 — Short B prefix</option>
      <option value="CUSTOM-001">Custom prefix</option>
    </select>
  </div>
  <div className="s-form-row">
    <div><div className="s-row-label">Custom prefix</div></div>
    <input className="finp" style={{width:80,textAlign:"center"}} value={as.bundlePrefix||"BDL"} onChange={e=>setAS("bundlePrefix",e.target.value.toUpperCase())} maxLength={8} />
  </div>
</SCard>
```

Add `skuFormat`, `skuPrefix`, `bundleFormat`, `bundlePrefix` to `DEFAULT_APP_SETTINGS`:
```js
skuFormat:    "A001",
skuPrefix:    "A",
bundleFormat: "BDL-001",
bundlePrefix: "BDL",
```

### Platform selection (add to SettingsPlatforms)

Add a "Your Platforms" section at the top of SettingsPlatforms, above the hidden platforms sections. Multi-select pill grid — same UI as the onboarding step. Tapping a platform toggles it in `as.activePlatforms`. Platforms not in `as.activePlatforms` are hidden from all flows.

### Drafter language config (add to SettingsPlatforms, Pro only)

Add a "Listing Drafter Config" section at the bottom of SettingsPlatforms gated by `tier === "pro" || tier === "internal"`. Show the 6 drafter fields: tone (3-card pick), dialect (2-card pick), length (3-card pick), always include (textarea), never include (textarea), brand voice (textarea). Write to `as.drafterTone`, `as.drafterDialect`, `as.drafterLength`, `as.alwaysInclude`, `as.neverInclude`, `as.brandVoice`.

If drafter config is incomplete (`as.drafterTone` is null/undefined), show a banner in the Listing Drafter tab: "Your Drafter isn't fully configured — [Complete setup →]" linking to Settings → Platforms.

---

## LISTING LIMIT WARNING

When a workspace's listing count reaches **80% or more** of their tier limit, show a warning banner. At **100%** (limit reached), block adding new listings.

### Banner — 80%+ threshold

Show in two places:
1. **Top of Listings tab** — above the filter tabs, below the top bar
2. **Dashboard** — below the KPI cards

```jsx
function ListingLimitBanner({ listingCount, limit, tier, onUpgrade }) {
  const pct = Math.round((listingCount / limit) * 100);
  if (pct < 80) return null;
  const atLimit = listingCount >= limit;

  return (
    <div className={`limit-banner${atLimit ? " limit-banner-full" : ""}`}>
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
        <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
      </svg>
      <span>
        {atLimit
          ? `You've reached your ${tier} plan limit of ${limit} listings. `
          : `${listingCount} of ${limit} listings used (${pct}%). `
        }
        <strong style={{cursor:"pointer",textDecoration:"underline"}} onClick={onUpgrade}>
          {atLimit ? "Upgrade to add more →" : "Upgrade your plan →"}
        </strong>
      </span>
    </div>
  );
}
```

```css
.limit-banner {
  display: flex; align-items: flex-start; gap: 8px;
  background: var(--aml); border: 1px solid rgba(217,119,6,.25);
  border-radius: var(--r2); padding: 9px 12px;
  font-size: 12px; color: var(--am); line-height: 1.5;
  margin-bottom: 10px;
}

.limit-banner.limit-banner-full {
  background: var(--rdl); border-color: rgba(220,38,38,.25); color: var(--rd);
}
```

At limit: disable the "+ Add Listing" button and show tooltip "Upgrade your plan to add more listings."

### Where to call it

In the App root, derive:
```jsx
const listingLimit = tier === "core" ? 300 : tier === "plus" ? 500 : tier === "pro" ? 1000 : 999999;
const showLimitWarning = listings.length >= listingLimit * 0.8;
```

Pass `listingCount={listings.length}`, `limit={listingLimit}`, `tier={tier}`, `onUpgrade={()=>setView("settings") + setSTab("billing")}` to the banner component.

---

## DATA EXPORT — JSON + XLSX, renamed from "Backup"

### Rename throughout

Replace all instances of "backup", "Backup", "Sunday Backup" notification label stays as-is (it's a separate feature). In the UI and Settings, rename:
- "Back up" → "Export data"
- "Manual save" in Version History → "Export snapshot"

### Export format — both JSON and XLSX always together

Whenever the user triggers an export (from Settings → Data or Version History), always produce **both files**:

1. **JSON export** — full raw data dump
```js
const exportJSON = () => {
  const payload = {
    exportedAt: getToday(),
    workspace: workspaceName,
    tier,
    listings,
    stockData,
    appSettings: liveData?.appSettings || {},
    goals: liveData?.goals || {},
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `skuflow-export-${getToday()}.json`;
  a.click();
  URL.revokeObjectURL(url);
};
```

2. **XLSX export** — same structure as current, two sheets (Listings + Stock). Keep existing XLSX builder logic unchanged.

Both trigger simultaneously. Button label: "Export Data (JSON + XLSX)".

### In Settings → Data

Replace the existing export/backup section with:

```jsx
<SCard icon={<IcoDataMgmt/>} title="Export Data" sub="Download a full copy of your data as JSON and XLSX">
  <div className="s-form-row">
    <div>
      <div className="s-row-label">Export all data</div>
      <div className="s-row-sub">Downloads JSON + XLSX — listings, stock, settings</div>
    </div>
    <button className="btn btn-o btn-sm" onClick={handleExport}>↓ Export</button>
  </div>
  <div className="s-form-row" style={{borderBottom:"none",paddingBottom:0}}>
    <div>
      <div className="s-row-label">Last exported</div>
      <div className="s-row-sub">{as.lastExported || "Never"}</div>
    </div>
  </div>
</SCard>
```

After export, write `setAS("lastExported", getToday())` so the last exported date is shown.

### In Version History

Rename "Manual save" button to "Export snapshot". Each snapshot entry shows a "↓ Export" button alongside "Restore" — exports that snapshot's data as JSON + XLSX.

---

## STRIPE INTEGRATION

### Approach — Stripe Payment Links (Phase 1, no full checkout embed needed)

For launch, use **Stripe Payment Links** rather than a full embedded Stripe checkout. This means:
- You create a Payment Link per tier in the Stripe dashboard (one for Plus, one for Pro)
- Upgrade buttons link out to the Stripe-hosted payment page
- After payment, Stripe webhook fires → you update the workspace tier in Supabase
- No Stripe SDK needed in the frontend for Phase 1

### What to build now

**1. Stripe webhook handler** — a Supabase Edge Function that listens for `checkout.session.completed` events and updates `workspaces.tier` and `workspaces.listing_limit` accordingly.

```js
// supabase/functions/stripe-webhook/index.ts
// On checkout.session.completed:
// - Read metadata.workspace_id and metadata.tier from the session
// - Update workspaces set tier = metadata.tier, listing_limit = LIMITS[metadata.tier]
// - Update workspaces set stripe_customer_id = session.customer
```

Add to `workspaces` table:
```sql
alter table workspaces add column stripe_customer_id text;
alter table workspaces add column stripe_subscription_id text;
alter table workspaces add column subscription_status text default 'active';
alter table workspaces add column renewal_date date;
```

**2. Upgrade buttons in SettingsBilling**

```jsx
const STRIPE_LINKS = {
  plus: "https://buy.stripe.com/PLACEHOLDER_PLUS",
  pro:  "https://buy.stripe.com/PLACEHOLDER_PRO",
};

// In tier comparison card:
<button
  className={`tier-btn ${targetTier === tier ? "current" : "upgrade"}`}
  onClick={() => {
    if (targetTier === tier) return;
    if (STRIPE_LINKS[targetTier]) {
      window.open(`${STRIPE_LINKS[targetTier]}?client_reference_id=${workspaceId}`, "_blank");
    }
  }}
>
  {targetTier === tier ? "Current Plan" : `Upgrade to ${TIER_NAMES[targetTier]}`}
</button>
```

Pass `workspaceId` as `client_reference_id` so the webhook can identify which workspace to upgrade.

**3. Billing card — show real renewal date**

Once Stripe webhook fires and `renewal_date` is set in Supabase, display it on the current plan card. Pull from workspace row.

**4. Cancel subscription**

Cancel button opens confirmation modal → on confirm, calls a Supabase Edge Function that cancels the Stripe subscription via Stripe API. Access continues until `renewal_date`.

### Stripe Payment Link setup (you do this in Stripe dashboard)

For each tier link, set metadata:
- `tier`: "plus" or "pro"
- After payment, Stripe sends webhook → Edge Function updates workspace

### Placeholder until Stripe links are created

Use `STRIPE_LINKS.plus = null` and `STRIPE_LINKS.pro = null`. Upgrade buttons show "Coming Soon" modal when link is null. Swap in real URLs when Payment Links are created in Stripe.

### Supabase SQL — run before implementing Stripe

Run this in the Supabase SQL editor for project `bufysvflmcffsqlntrwp` before any Stripe code is written:

```sql
-- Add Stripe and subscription columns to workspaces table
alter table workspaces add column if not exists stripe_customer_id text;
alter table workspaces add column if not exists stripe_subscription_id text;
alter table workspaces add column if not exists subscription_status text default 'active'
  check (subscription_status in ('active', 'cancelled', 'past_due', 'trialing'));
alter table workspaces add column if not exists renewal_date date;
alter table workspaces add column if not exists stripe_price_id text;
```

Verify with:
```sql
select id, name, tier, stripe_customer_id, subscription_status, renewal_date
from workspaces;
```

### Note for implementation

Add `STRIPE_WEBHOOK_SECRET` and `STRIPE_SECRET_KEY` to Supabase Edge Function secrets, not to the frontend. Never expose Stripe secret key in the React app.
