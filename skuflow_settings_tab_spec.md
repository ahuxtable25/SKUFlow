# SKU Flow — Settings UX Spec (Option B: Horizontal Tab Bar)
## Append to or use alongside skuflow_implementation_spec.md

---

## OVERVIEW

Settings uses a **horizontal scrollable tab bar** pattern. 8 tabs, swipeable left/right as well as tappable. Each tab renders its own content below the tab bar. No drill-down screens — all settings are visible within the tab's content area, scrollable vertically.

---

## STRUCTURE

### Tab order (left to right)

1. Account
2. Notifications
3. Preferences
4. Stock
5. Listings
6. Billing
7. Data
8. Contact Us

---

## COMPONENT ARCHITECTURE

### SettingsPage (top-level)

```jsx
function SettingsPage({
  liveData, setLiveData, listings, stockData,
  tier, workspaceId, workspaceName, listingLimit,
}) {
  const [sTab, setSTab] = useState("account");
  const as = getAS(liveData);
  const setAS = (k, v) => setLiveData(prev => ({
    ...prev,
    appSettings: { ...(prev?.appSettings || {}), [k]: v }
  }));

  const TABS = [
    { id: "account",       label: "Account" },
    { id: "notifications", label: "Notifications" },
    { id: "preferences",   label: "Preferences" },
    { id: "stock",         label: "Stock" },
    { id: "listings",      label: "Listings" },
    { id: "billing",       label: "Billing" },
    { id: "data",          label: "Data" },
    { id: "contact",       label: "Contact Us" },
  ];

  return (
    <div className="settings-page">
      {/* Horizontal scroll tab bar */}
      <div className="settings-tabs">
        {TABS.map(t => (
          <div
            key={t.id}
            className={`settings-tab${sTab === t.id ? " active" : ""}`}
            onClick={() => setSTab(t.id)}
          >
            {t.label}
          </div>
        ))}
      </div>

      {/* Tab content */}
      <div className="settings-content">
        {sTab === "account"       && <STabAccount liveData={liveData} setLiveData={setLiveData} />}
        {sTab === "notifications"  && <STabNotifications as={as} setAS={setAS} />}
        {sTab === "preferences"    && <STabPreferences as={as} setAS={setAS} />}
        {sTab === "stock"          && <STabStock as={as} setAS={setAS} />}
        {sTab === "listings"       && <STabListings as={as} setAS={setAS} liveData={liveData} setLiveData={setLiveData} tier={tier} />}
        {sTab === "billing"        && <STabBilling tier={tier} listingCount={listings.length} listingLimit={listingLimit} workspaceId={workspaceId} />}
        {sTab === "data"           && <STabData listings={listings} stockData={stockData} liveData={liveData} setLiveData={setLiveData} />}
        {sTab === "contact"        && <STabContact workspaceId={workspaceId} workspaceName={workspaceName} tier={tier} />}
      </div>
    </div>
  );
}
```

### Tab bar CSS

```css
.settings-page {
  display: flex;
  flex-direction: column;
  flex: 1;
  overflow: hidden;
}

.settings-tabs {
  display: flex;
  background: var(--card-bg);
  border-bottom: 1px solid var(--bd);
  overflow-x: auto;
  flex-shrink: 0;
  -webkit-overflow-scrolling: touch;
  scroll-snap-type: x proximity;
  padding: 0 6px;
}

.settings-tabs::-webkit-scrollbar { display: none; }

.settings-tab {
  padding: 11px 14px;
  font-size: 12px;
  font-weight: 600;
  color: var(--txm);
  white-space: nowrap;
  cursor: pointer;
  border-bottom: 2.5px solid transparent;
  transition: all .12s;
  flex-shrink: 0;
  scroll-snap-align: start;
}

.settings-tab:hover { color: var(--tx); }

.settings-tab.active {
  color: var(--ac);
  border-bottom-color: var(--ac);
  font-weight: 700;
}

.settings-content {
  flex: 1;
  overflow-y: auto;
  padding: 18px 20px;
  -webkit-overflow-scrolling: touch;
}

.settings-content::-webkit-scrollbar { display: none; }
```

### Swipe support

Add touch swipe detection to the settings-content area:

```jsx
// In SettingsPage, add swipe detection:
const TABS_ORDER = ["account","notifications","preferences","stock","listings","billing","data","contact"];

const handleSwipe = (direction) => {
  const currentIdx = TABS_ORDER.indexOf(sTab);
  if (direction === "left"  && currentIdx < TABS_ORDER.length - 1) setSTab(TABS_ORDER[currentIdx + 1]);
  if (direction === "right" && currentIdx > 0)                      setSTab(TABS_ORDER[currentIdx - 1]);
};

// Attach to settings-content div:
// onTouchStart, onTouchEnd to detect swipe direction
// Threshold: >50px horizontal movement = swipe
```

Swipe implementation:

```jsx
const touchStartX = useRef(null);

const onTouchStart = (e) => { touchStartX.current = e.touches[0].clientX; };

const onTouchEnd = (e) => {
  if (touchStartX.current === null) return;
  const diff = touchStartX.current - e.changedTouches[0].clientX;
  if (Math.abs(diff) > 50) handleSwipe(diff > 0 ? "left" : "right");
  touchStartX.current = null;
};
```

### SCard component (shared across all tabs)

```jsx
function SCard({ icon, title, sub, children, proOnly, tier }) {
  const locked = proOnly && !["pro","internal"].includes(tier);
  return (
    <div className={`s-card${locked ? " s-card-locked" : ""}`} style={{marginBottom:12}}>
      <div className="s-card-header">
        {icon && <div className="s-card-icon">{icon}</div>}
        <div style={{flex:1}}>
          <div className="s-card-title">{title}</div>
          {sub && <div className="s-card-sub">{sub}</div>}
        </div>
        {locked && <div className="pro-badge">Pro</div>}
      </div>
      <div className="s-card-body">
        {locked
          ? <div style={{fontSize:12,color:"var(--txm)",padding:"4px 0"}}>
              Available on Pro plan. <span style={{color:"var(--ac)",fontWeight:600,cursor:"pointer"}}>Upgrade →</span>
            </div>
          : children
        }
      </div>
    </div>
  );
}
```

```css
.s-card {
  background: var(--card-bg);
  border: 1px solid var(--bd);
  border-radius: var(--r);
  box-shadow: var(--shadow);
  margin-bottom: 12px;
  overflow: hidden;
}

.s-card-locked { opacity: .65; }

.s-card-header {
  padding: 11px 16px;
  border-bottom: 1px solid var(--bd);
  display: flex; align-items: center; gap: 10px;
  box-shadow: inset 3px 0 0 var(--ac);
  background: linear-gradient(90deg, rgba(99,102,241,.04) 0%, transparent 60%);
}

/* IMPORTANT: Use box-shadow inset NOT border-left for the accent —
   border-left is clipped by overflow:hidden on .s-card */

.s-card-icon {
  width: 28px; height: 28px; border-radius: 7px;
  background: var(--acl); color: var(--ac);
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}

.s-card-title { font-size: 12.5px; font-weight: 700; color: var(--tx); }
.s-card-sub   { font-size: 11px; color: var(--txm); margin-top: 1px; }
.s-card-body  { padding: 12px 16px; }

.s-row {
  display: flex; align-items: center; justify-content: space-between;
  padding: 9px 0; border-bottom: 1px solid #F3F4F6;
}
.s-row:last-child  { border-bottom: none; padding-bottom: 0; }
.s-row:first-child { padding-top: 0; }
.s-row-label { font-size: 12.5px; font-weight: 600; color: var(--tx); }
.s-row-sub   { font-size: 11px; color: var(--txm); margin-top: 1px; }

.pro-badge {
  font-size: 9.5px; font-weight: 700; letter-spacing: .05em;
  text-transform: uppercase; padding: 2px 8px; border-radius: 20px;
  background: rgba(99,102,241,.15); color: var(--ac);
}
```

---

## TAB 1 — ACCOUNT

```jsx
function STabAccount({ liveData, setLiveData }) {
  const [name, setName]         = useState(liveData?.profile?.fullName || "");
  const [business, setBusiness] = useState(liveData?.profile?.businessName || "");
  const [saving, setSaving]     = useState(false);

  const saveProfile = async () => {
    setSaving(true);
    await supabase.from("profiles").update({ full_name: name }).eq("id", userId);
    await supabase.from("workspaces").update({ name: business }).eq("id", workspaceId);
    setSaving(false);
  };

  return (
    <>
      <SCard icon={<IcoUser/>} title="Profile">
        <div className="s-row">
          <div className="s-row-label">Full name</div>
          <input className="finp" style={{width:160}} value={name} onChange={e=>setName(e.target.value)} />
        </div>
        <div className="s-row">
          <div className="s-row-label">Business name</div>
          <input className="finp" style={{width:160}} value={business} onChange={e=>setBusiness(e.target.value)} />
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div></div>
          <button className="btn btn-p btn-sm" onClick={saveProfile} disabled={saving}>
            {saving ? "Saving…" : "Save changes"}
          </button>
        </div>
      </SCard>

      <SCard icon={<IcoMail/>} title="Email address">
        <div className="s-row">
          <div><div className="s-row-label">Current email</div><div className="s-row-sub">{userEmail}</div></div>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div></div>
          <button className="btn btn-o btn-sm">Change email</button>
        </div>
      </SCard>

      <SCard icon={<IcoSettings/>} title="Password">
        <div className="s-row">
          <div className="s-row-label">Current password</div>
          <input className="finp" type="password" style={{width:140}} placeholder="••••••••" />
        </div>
        <div className="s-row">
          <div className="s-row-label">New password</div>
          <input className="finp" type="password" style={{width:140}} placeholder="••••••••" />
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div></div>
          <button className="btn btn-p btn-sm">Update password</button>
        </div>
      </SCard>
    </>
  );
}
```

---

## TAB 2 — NOTIFICATIONS

```jsx
function STabNotifications({ as, setAS }) {
  const rows = [
    { key:"notifSold",         label:"Item sold",            sub:"When you mark an item as sold" },
    { key:"notifListed",       label:"Item listed",          sub:"When you mark an item as listed" },
    { key:"notifReturn",       label:"Return raised",        sub:"When a return is logged" },
    { key:"notifShipped",      label:"Item shipped",         sub:"When an item is marked as shipped" },
    { key:"notifNotes",        label:"Notes updated",        sub:"45 seconds after you stop typing" },
    { key:"notifSundayBackup", label:"Sunday backup",        sub:"Weekly auto-save reminder" },
  ];

  return (
    <SCard icon={<IcoBell/>} title="Push Notifications" sub="Delivered to your device via browser">
      {rows.map((r,i) => (
        <div key={r.key} className="s-row" style={i===rows.length-1?{borderBottom:"none",paddingBottom:0}:{}}>
          <div>
            <div className="s-row-label">{r.label}</div>
            <div className="s-row-sub">{r.sub}</div>
          </div>
          <SToggle on={as[r.key]!==false} onChange={v=>setAS(r.key,v)} />
        </div>
      ))}
    </SCard>
  );
}
```

---

## TAB 3 — PREFERENCES

Contains two sections: Goals first (most frequently updated), then Display settings.

```jsx
function STabPreferences({ as, setAS }) {
  return (
    <>
      {/* ── GOALS ── */}
      <SCard icon={<IcoGoals/>} title="Goals" sub="Shown as progress bars on your dashboard">
        <div style={{marginBottom:14}}>
          <div className="s-section-label">Weekly targets</div>
          <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
            <SGolInput label="Profit" value={as.weeklyProfit||""} onChange={v=>setAS("weeklyProfit",v)} currency={as.currency||"£"} />
            <SGolInput label="Revenue" value={as.weeklyRevenue||""} onChange={v=>setAS("weeklyRevenue",v)} currency={as.currency||"£"} />
          </div>
        </div>
        <div>
          <div className="s-section-label">Monthly targets</div>
          <div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:8}}>
            <SGolInput label="Profit" value={as.monthlyProfit||""} onChange={v=>setAS("monthlyProfit",v)} currency={as.currency||"£"} />
            <SGolInput label="Revenue" value={as.monthlyRevenue||""} onChange={v=>setAS("monthlyRevenue",v)} currency={as.currency||"£"} />
          </div>
        </div>
      </SCard>

      {/* ── THEME ── */}
      <SCard icon={<IcoPrefs/>} title="Interface Theme" sub="Choose how SKU Flow looks">
        <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:8}}>
          {[
            { value:"default", label:"Default",  desc:"Dark sidebar, light content" },
            { value:"night",   label:"Night",    desc:"Full dark interface" },
            { value:"classic", label:"Classic",  desc:"Original Archive District" },
          ].map(opt => (
            <div
              key={opt.value}
              onClick={() => {
                setAS("theme", opt.value);
                const t = opt.value;
                if (t === "default") document.documentElement.removeAttribute("data-theme");
                else document.documentElement.setAttribute("data-theme", t);
              }}
              style={{
                border:`1.5px solid ${(as.theme||"default")===opt.value?"var(--ac)":"var(--bd)"}`,
                background:(as.theme||"default")===opt.value?"var(--acl)":"var(--card-bg)",
                borderRadius:"var(--r2)", padding:"10px 10px", cursor:"pointer",
              }}
            >
              <div style={{fontSize:11.5,fontWeight:700,color:(as.theme||"default")===opt.value?"var(--ac)":"var(--tx)",marginBottom:3}}>
                {opt.label}{(as.theme||"default")===opt.value&&" ✓"}
              </div>
              <div style={{fontSize:10,color:"var(--txm)",lineHeight:1.4}}>{opt.desc}</div>
            </div>
          ))}
        </div>
      </SCard>

      {/* ── DISPLAY ── */}
      <SCard icon={<IcoPrefs/>} title="Display">
        <div className="s-row">
          <div><div className="s-row-label">Compact tables</div><div className="s-row-sub">Smaller row height in all tables</div></div>
          <SToggle on={as.compactMode||false} onChange={v=>setAS("compactMode",v)} />
        </div>
        <div className="s-row">
          <div className="s-row-label">Currency symbol</div>
          <select className="fsel" style={{width:90}} value={as.currency||"£"} onChange={e=>setAS("currency",e.target.value)}>
            <option value="£">£ GBP</option>
            <option value="€">€ EUR</option>
            <option value="$">$ USD</option>
          </select>
        </div>
        <div className="s-row">
          <div className="s-row-label">Date format</div>
          <select className="fsel" style={{width:130}} value={as.dateFormat||"DD/MM/YYYY"} onChange={e=>setAS("dateFormat",e.target.value)}>
            <option value="DD/MM/YYYY">DD/MM/YYYY</option>
            <option value="MM/DD/YYYY">MM/DD/YYYY</option>
          </select>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Cash buffer target</div><div className="s-row-sub">Highlighted in Live Data</div></div>
          <div style={{display:"flex",alignItems:"center",gap:4}}>
            <input className="finp" style={{width:55,textAlign:"center"}} value={as.cashBuffer||"80"} onChange={e=>setAS("cashBuffer",e.target.value)} />
            <span style={{fontSize:12,color:"var(--txm)"}}>%</span>
          </div>
        </div>
      </SCard>
    </>
  );
}

/* Goal input helper — top-level */
function SGolInput({ label, value, onChange, currency }) {
  return (
    <div>
      <div style={{fontSize:11,fontWeight:600,color:"var(--txm)",marginBottom:4}}>{label}</div>
      <div style={{display:"flex",alignItems:"center",background:"var(--card-bg)",border:"1.5px solid var(--bd)",borderRadius:"var(--r2)",overflow:"hidden",boxShadow:"var(--shadow)"}}>
        <div style={{padding:"0 8px",height:36,display:"flex",alignItems:"center",background:"#F9FAFB",borderRight:"1px solid var(--bd)",fontSize:13,fontWeight:700,color:"var(--txm)"}}>{currency}</div>
        <input
          type="text" inputMode="decimal"
          style={{flex:1,height:36,border:"none",background:"transparent",padding:"0 8px",fontSize:13,fontWeight:700,color:"var(--tx)",fontFamily:"inherit",outline:"none",fontVariantNumeric:"tabular-nums"}}
          value={value}
          onChange={e=>{ if(/^\d*\.?\d*$/.test(e.target.value)) onChange(e.target.value); }}
        />
      </div>
    </div>
  );
}

/* Section label helper */
// Add to CSS:
// .s-section-label { font-size:10.5px; font-weight:700; letter-spacing:.06em; text-transform:uppercase; color:var(--txd); margin-bottom:8px; display:block; }
```

---

## TAB 4 — STOCK

```jsx
function STabStock({ as, setAS }) {
  return (
    <>
      <SCard icon={<IcoStock/>} title="Stock Thresholds">
        <div className="s-row">
          <div><div className="s-row-label">Sell-through warning</div><div className="s-row-sub">Highlight bundles below this %</div></div>
          <div style={{display:"flex",alignItems:"center",gap:4}}>
            <input className="finp" style={{width:55,textAlign:"center"}} value={as.sellThrough||"50"} onChange={e=>setAS("sellThrough",e.target.value)} />
            <span style={{fontSize:12,color:"var(--txm)"}}>%</span>
          </div>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Slow mover threshold</div><div className="s-row-sub">Days listed before flagged slow</div></div>
          <div style={{display:"flex",alignItems:"center",gap:4}}>
            <input className="finp" style={{width:55,textAlign:"center"}} value={as.slowDays||"14"} onChange={e=>setAS("slowDays",e.target.value)} />
            <span style={{fontSize:12,color:"var(--txm)"}}>days</span>
          </div>
        </div>
      </SCard>

      <SCard icon={<IcoAnalytics/>} title="Velocity Tags" sub="Fast / Medium / Slow / Dead labels on stock bundles">
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Show velocity tags</div><div className="s-row-sub">Plus and Pro plans only</div></div>
          <SToggle on={as.velocityTags!==false} onChange={v=>setAS("velocityTags",v)} />
        </div>
      </SCard>

      <SCard icon={<IcoGrowth/>} title="Restock" sub="Controls restock flag visibility in stock table">
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Show restock flag column</div><div className="s-row-sub">Pro plan only</div></div>
          <SToggle on={as.showRestockFlag||false} onChange={v=>setAS("showRestockFlag",v)} />
        </div>
      </SCard>
    </>
  );
}
```

---

## TAB 5 — LISTINGS

This is the largest tab. Contains: active platforms, hidden platforms, cross-list, custom dropdowns, SKU formats, default condition, and Drafter config (Pro).

```jsx
function STabListings({ as, setAS, liveData, setLiveData, tier }) {
  const ALL_PLATFORMS = ["Depop","Vinted","eBay","Grailed","Whatnot","Facebook","Vestiaire","Tilt"];
  const activePlats   = as.activePlatforms || ALL_PLATFORMS;
  const isProOrInt    = ["pro","internal"].includes(tier);

  const addCustomOption = (field, value) => {
    setLiveData(prev => {
      const prevAS = prev?.appSettings || {};
      const existing = prevAS[field] || [];
      if (existing.includes(value)) return prev;
      return { ...prev, appSettings: { ...prevAS, [field]: [...existing, value] } };
    });
  };

  return (
    <>
      {/* ── YOUR PLATFORMS ── */}
      <SCard icon={<IcoPlat/>} title="Your Platforms" sub="Platforms you don't sell on are hidden from every flow">
        <div style={{display:"flex",flexWrap:"wrap",gap:7}}>
          {ALL_PLATFORMS.map(p => {
            const active = activePlats.includes(p);
            return (
              <button key={p} onClick={()=>{
                const next = active ? activePlats.filter(x=>x!==p) : [...activePlats,p];
                setAS("activePlatforms", next);
              }} style={{
                padding:"5px 12px",fontSize:11,fontWeight:700,borderRadius:20,cursor:"pointer",
                border:`1.5px solid ${active?"var(--ac)":"var(--bd)"}`,
                background:active?"var(--acl)":"var(--card-bg)",
                color:active?"var(--ac)":"var(--txm)",transition:"all .12s",
              }}>{p}{active&&" ✓"}</button>
            );
          })}
        </div>
      </SCard>

      {/* ── MARK AS LISTED — HIDDEN ── */}
      <SCard icon={<IcoPin/>} title="Mark as Listed — Hidden Platforms" sub="These won't appear in the Mark as Listed flow">
        <div style={{display:"flex",flexWrap:"wrap",gap:7}}>
          {activePlats.map(p => {
            const hidden = (as.hiddenListedPlats||[]).includes(p);
            return (
              <button key={p} onClick={()=>{
                const cur = as.hiddenListedPlats||[];
                setAS("hiddenListedPlats", hidden ? cur.filter(x=>x!==p) : [...cur,p]);
              }} style={{
                padding:"5px 12px",fontSize:11,fontWeight:700,borderRadius:20,cursor:"pointer",
                border:`1.5px solid ${hidden?"var(--ac)":"var(--bd)"}`,
                background:hidden?"var(--acl)":"var(--card-bg)",
                color:hidden?"var(--ac)":"var(--txm)",transition:"all .12s",
              }}>{hidden?"🚫 ":""}{p}</button>
            );
          })}
        </div>
        <div style={{fontSize:10.5,color:"var(--txd)",marginTop:8}}>Highlighted = hidden. Tap to toggle.</div>
      </SCard>

      {/* ── MARK AS SOLD — HIDDEN ── */}
      <SCard icon={<IcoSold/>} title="Mark as Sold — Hidden Platforms" sub="These won't appear in the Mark as Sold flow">
        <div style={{display:"flex",flexWrap:"wrap",gap:7}}>
          {activePlats.map(p => {
            const hidden = (as.hiddenSoldPlats||[]).includes(p);
            return (
              <button key={p} onClick={()=>{
                const cur = as.hiddenSoldPlats||[];
                setAS("hiddenSoldPlats", hidden ? cur.filter(x=>x!==p) : [...cur,p]);
              }} style={{
                padding:"5px 12px",fontSize:11,fontWeight:700,borderRadius:20,cursor:"pointer",
                border:`1.5px solid ${hidden?"var(--ac)":"var(--bd)"}`,
                background:hidden?"var(--acl)":"var(--card-bg)",
                color:hidden?"var(--ac)":"var(--txm)",transition:"all .12s",
              }}>{hidden?"🚫 ":""}{p}</button>
            );
          })}
        </div>
        <div style={{fontSize:10.5,color:"var(--txd)",marginTop:8}}>Highlighted = hidden. Tap to toggle.</div>
      </SCard>

      {/* ── CROSS-LIST TRACKER ── */}
      <SCard icon={<IcoData/>} title="Cross-List Tracker — Visible Platforms" sub="Controls which platforms appear in the Cross-List tab" proOnly tier={tier}>
        <div style={{display:"flex",flexWrap:"wrap",gap:7}}>
          {activePlats.map(p => {
            const crossPlats = as.crossListPlats || activePlats;
            const visible = crossPlats.includes(p);
            return (
              <button key={p} onClick={()=>{
                const cur = as.crossListPlats || activePlats;
                setAS("crossListPlats", visible ? cur.filter(x=>x!==p) : [...cur,p]);
              }} style={{
                padding:"5px 12px",fontSize:11,fontWeight:700,borderRadius:20,cursor:"pointer",
                border:`1.5px solid ${visible?"var(--ac)":"var(--bd)"}`,
                background:visible?"var(--acl)":"var(--card-bg)",
                color:visible?"var(--ac)":"var(--txm)",transition:"all .12s",
              }}>{visible?"✓ ":""}{p}</button>
            );
          })}
        </div>
      </SCard>

      {/* ── CUSTOM DROPDOWNS ── */}
      <SCard icon={<IcoListings/>} title="Custom Dropdown Options" sub="Manage types, colours, and sizes you've added">
        {[
          { field:"customTypes",   label:"Types",   colour:"#4338CA" },
          { field:"customColours", label:"Colours", colour:"#15803D" },
          { field:"customSizes",   label:"Sizes",   colour:"#B45309" },
        ].map(({ field, label, colour }) => {
          const items = as[field] || [];
          return (
            <div key={field} style={{marginBottom:10}}>
              <div style={{fontSize:10.5,fontWeight:700,color:"var(--txd)",textTransform:"uppercase",letterSpacing:".05em",marginBottom:6}}>{label}</div>
              {items.length === 0
                ? <div style={{fontSize:11.5,color:"var(--txd)"}}>None added yet</div>
                : <div style={{display:"flex",flexWrap:"wrap",gap:6}}>
                    {items.map((item,idx) => (
                      <div key={idx} style={{display:"inline-flex",alignItems:"center",gap:5,padding:"3px 10px",borderRadius:20,border:`1px solid ${colour}44`,background:`${colour}12`,fontSize:11,fontWeight:600,color:colour}}>
                        {item}
                        <button onClick={()=>setAS(field,items.filter((_,i)=>i!==idx))} style={{background:"none",border:"none",cursor:"pointer",color:colour,fontSize:13,fontWeight:700,lineHeight:1,padding:0,opacity:.7}}>×</button>
                      </div>
                    ))}
                  </div>
              }
            </div>
          );
        })}
      </SCard>

      {/* ── SKU FORMAT ── */}
      <SCard icon={<IcoListings/>} title="SKU Format" sub="How new item SKUs are auto-generated">
        <div className="s-row">
          <div className="s-row-label">Format</div>
          <select className="fsel" style={{width:150}} value={as.skuFormat||"A001"} onChange={e=>setAS("skuFormat",e.target.value)}>
            <option value="A001">A001 — Letter + number</option>
            <option value="001">001 — Numbers only</option>
            <option value="CUSTOM">Custom prefix</option>
            <option value="INITIALS">Initials + number</option>
          </select>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Prefix</div><div className="s-row-sub">Used for custom format</div></div>
          <input className="finp" style={{width:70,textAlign:"center",fontFamily:"monospace",fontWeight:700}} value={as.skuPrefix||"A"} onChange={e=>setAS("skuPrefix",e.target.value.toUpperCase())} maxLength={6} />
        </div>
      </SCard>

      {/* ── BUNDLE SKU FORMAT ── */}
      <SCard icon={<IcoStock/>} title="Bundle SKU Format" sub="How new bundle SKUs are auto-generated">
        <div className="s-row">
          <div className="s-row-label">Format</div>
          <select className="fsel" style={{width:150}} value={as.bundleFormat||"BDL-001"} onChange={e=>setAS("bundleFormat",e.target.value)}>
            <option value="BDL-001">BDL-001 — BDL prefix</option>
            <option value="BATCH-01">BATCH-01 — BATCH prefix</option>
            <option value="B001">B001 — Short B</option>
            <option value="CUSTOM">Custom prefix</option>
          </select>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Prefix</div><div className="s-row-sub">Used for custom format</div></div>
          <input className="finp" style={{width:70,textAlign:"center",fontFamily:"monospace",fontWeight:700}} value={as.bundlePrefix||"BDL"} onChange={e=>setAS("bundlePrefix",e.target.value.toUpperCase())} maxLength={8} />
        </div>
      </SCard>

      {/* ── DEFAULT CONDITION ── */}
      <SCard icon={<IcoDrafter/>} title="Listing Defaults">
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Default condition</div><div className="s-row-sub">Pre-fills when adding listings</div></div>
          <select className="fsel" style={{width:140}} value={as.defaultCondition||"Excellent"} onChange={e=>setAS("defaultCondition",e.target.value)}>
            {["New with tags","New without tags","Excellent","Good","Fair"].map(c=><option key={c} value={c}>{c}</option>)}
          </select>
        </div>
      </SCard>

      {/* ── LISTING DRAFTER CONFIG (Pro) ── */}
      <SCard icon={<IcoDrafter/>} title="Listing Drafter Config" sub="AI description personalisation" proOnly tier={tier}>
        <div className="s-row">
          <div className="s-row-label">Tone</div>
          <select className="fsel" style={{width:110}} value={as.drafterTone||"casual"} onChange={e=>setAS("drafterTone",e.target.value)}>
            <option value="casual">Casual</option>
            <option value="hype">Hype</option>
            <option value="formal">Formal</option>
          </select>
        </div>
        <div className="s-row">
          <div className="s-row-label">Dialect</div>
          <select className="fsel" style={{width:110}} value={as.drafterDialect||"uk"} onChange={e=>setAS("drafterDialect",e.target.value)}>
            <option value="uk">UK English</option>
            <option value="us">US English</option>
          </select>
        </div>
        <div className="s-row">
          <div className="s-row-label">Length</div>
          <select className="fsel" style={{width:110}} value={as.drafterLength||"medium"} onChange={e=>setAS("drafterLength",e.target.value)}>
            <option value="short">Short (2–3 lines)</option>
            <option value="medium">Medium (4–6 lines)</option>
            <option value="detailed">Detailed (7–10)</option>
          </select>
        </div>
        <div style={{marginTop:8}}>
          <div style={{fontSize:11,fontWeight:600,color:"var(--txm)",marginBottom:4}}>Always include</div>
          <textarea className="fta" style={{minHeight:52,fontSize:12}} value={as.alwaysInclude||""} onChange={e=>setAS("alwaysInclude",e.target.value)} placeholder="e.g. vintage, dead-stock…" />
        </div>
        <div style={{marginTop:8}}>
          <div style={{fontSize:11,fontWeight:600,color:"var(--txm)",marginBottom:4}}>Never include</div>
          <textarea className="fta" style={{minHeight:52,fontSize:12}} value={as.neverInclude||""} onChange={e=>setAS("neverInclude",e.target.value)} placeholder="e.g. used, worn…" />
        </div>
        <div style={{marginTop:8}}>
          <div style={{fontSize:11,fontWeight:600,color:"var(--txm)",marginBottom:4}}>Brand voice notes</div>
          <textarea className="fta" style={{minHeight:64,fontSize:12}} value={as.brandVoice||""} onChange={e=>setAS("brandVoice",e.target.value)} placeholder="Tell the AI what makes your shop distinctive…" />
        </div>
      </SCard>
    </>
  );
}
```

---

## TAB 6 — BILLING

```jsx
function STabBilling({ tier, listingCount, listingLimit, workspaceId }) {
  const TIER_NAMES   = { core:"Core", plus:"Plus", pro:"Pro", internal:"Internal" };
  const TIER_PRICES  = { core:"£7.99", plus:"£12.99", pro:"£19.99", internal:"—" };
  const TIER_LIMITS  = { core:300, plus:500, pro:1000, internal:999999 };
  const pct          = Math.min(100, Math.round((listingCount / listingLimit) * 100));

  const STRIPE_LINKS = {
    plus: null, // swap in real Stripe Payment Link URL
    pro:  null,
  };

  const TIER_FEATURES = [
    { label:"Dashboard & Goals",               core:true,  plus:true,  pro:true  },
    { label:"Stock management",                 core:true,  plus:true,  pro:true  },
    { label:"Listings management",              core:true,  plus:true,  pro:true  },
    { label:"Mark as Listed / Sold",            core:true,  plus:true,  pro:true  },
    { label:"Shipping tracker",                 core:true,  plus:true,  pro:true  },
    { label:"Live Data (basic)",                core:true,  plus:true,  pro:true  },
    { label:"Price Calculator",                 core:true,  plus:true,  pro:true  },
    { label:"Version History",                  core:true,  plus:true,  pro:true  },
    { label:"Velocity tags",                    core:false, plus:true,  pro:true  },
    { label:"Movement Tracker",                 core:false, plus:true,  pro:true  },
    { label:"Growth charts",                    core:false, plus:true,  pro:true  },
    { label:"Analytics & Restock Intelligence", core:false, plus:false, pro:true  },
    { label:"Listing Drafter AI",               core:false, plus:false, pro:true  },
    { label:"Cross-List Tracker",               core:false, plus:false, pro:true  },
    { label:"Pending payouts & Profit log",     core:false, plus:false, pro:true  },
    { label:"Multi-platform accounts",          core:false, plus:false, pro:true  },
  ];

  return (
    <>
      {/* ── CURRENT PLAN ── */}
      <div style={{background:"linear-gradient(135deg,#6366F1,#8B5CF6)",borderRadius:"var(--r)",padding:"16px 18px",color:"#fff",marginBottom:12,position:"relative",overflow:"hidden"}}>
        <div style={{position:"absolute",top:-30,right:-30,width:100,height:100,borderRadius:"50%",background:"rgba(255,255,255,.08)"}}></div>
        <div style={{fontSize:10,fontWeight:700,opacity:.7,marginBottom:3,textTransform:"uppercase",letterSpacing:".07em"}}>Current plan</div>
        <div style={{fontSize:22,fontWeight:800,letterSpacing:"-.4px",marginBottom:2}}>{TIER_NAMES[tier]}</div>
        <div style={{fontSize:12,opacity:.8,marginBottom:14}}>{TIER_PRICES[tier]}/month · renews 14 Aug 2025</div>
        <div style={{fontSize:10.5,opacity:.75,marginBottom:5}}>{listingCount} of {listingLimit === 999999 ? "∞" : listingLimit} listings used</div>
        <div style={{height:5,background:"rgba(255,255,255,.2)",borderRadius:99,overflow:"hidden"}}>
          <div style={{height:"100%",width:`${pct}%`,background:"#fff",borderRadius:99}}></div>
        </div>
      </div>

      {/* ── TIER COMPARISON ── */}
      <SCard icon={<IcoBilling/>} title="Upgrade your plan">
        {["core","plus","pro"].map(t => {
          const isCurrent = t === tier;
          const isHigher  = ["core","plus","pro"].indexOf(t) > ["core","plus","pro"].indexOf(tier);
          const included  = TIER_FEATURES.filter(f => f[t]);
          const excluded  = TIER_FEATURES.filter(f => !f[t]);

          return (
            <div key={t} style={{
              border:`1.5px solid ${isCurrent?"var(--ac)":"var(--bd)"}`,
              borderRadius:"var(--r)",
              padding:"14px",
              marginBottom:10,
              background:isCurrent?"var(--acl)":"var(--card-bg)",
              position:"relative",
            }}>
              {isCurrent && (
                <div style={{position:"absolute",top:-1,left:14,background:"var(--ac)",color:"#fff",fontSize:9,fontWeight:700,letterSpacing:".06em",textTransform:"uppercase",padding:"2px 8px",borderRadius:"0 0 6px 6px"}}>
                  YOUR PLAN
                </div>
              )}
              <div style={{display:"flex",alignItems:"flex-start",justifyContent:"space-between",marginTop:isCurrent?8:0,marginBottom:10}}>
                <div>
                  <div style={{fontSize:14,fontWeight:800,color:isCurrent?"var(--ac)":"var(--tx)",letterSpacing:"-.2px"}}>{TIER_NAMES[t]}</div>
                  <div style={{fontSize:13,fontWeight:800,color:isCurrent?"var(--ac)":"var(--tx)"}}>{TIER_PRICES[t]}<span style={{fontSize:11,fontWeight:500,color:"var(--txm)"}}>/mo</span></div>
                  <div style={{fontSize:11,color:"var(--txm)",marginTop:2}}>Up to {TIER_LIMITS[t].toLocaleString()} listings</div>
                </div>
                <button
                  onClick={()=>{
                    if (isCurrent) return;
                    const link = STRIPE_LINKS[t];
                    if (link) window.open(`${link}?client_reference_id=${workspaceId}`, "_blank");
                    else alert("Upgrade coming soon — contact us to upgrade.");
                  }}
                  style={{
                    height:30,padding:"0 12px",borderRadius:"var(--r2)",border:"none",cursor:"pointer",
                    fontSize:11,fontWeight:700,
                    background:isCurrent?"rgba(99,102,241,.15)":isHigher?"var(--ac)":"var(--bd)",
                    color:isCurrent?"var(--ac)":isHigher?"#fff":"var(--txm)",
                  }}
                >
                  {isCurrent ? "Current" : isHigher ? `Upgrade →` : "Downgrade"}
                </button>
              </div>
              <div style={{display:"flex",flexDirection:"column",gap:5}}>
                {included.slice(0,5).map(f=>(
                  <div key={f.label} style={{display:"flex",alignItems:"center",gap:6,fontSize:11.5,color:"var(--txm)"}}>
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="var(--gn)" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    {f.label}
                  </div>
                ))}
                {excluded.slice(0,3).map(f=>(
                  <div key={f.label} style={{display:"flex",alignItems:"center",gap:6,fontSize:11.5,color:"var(--txd)"}}>
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#D1D5DB" strokeWidth="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    {f.label}
                  </div>
                ))}
              </div>
            </div>
          );
        })}
      </SCard>

      {/* ── PAYMENT HISTORY ── */}
      <SCard icon={<IcoVersion/>} title="Payment History">
        {[
          { date:"14 Jul 2025", plan:"Pro — Monthly",  amount:"£19.99" },
          { date:"14 Jun 2025", plan:"Pro — Monthly",  amount:"£19.99" },
          { date:"14 May 2025", plan:"Plus — Monthly", amount:"£12.99" },
        ].map((inv,i) => (
          <div key={i} className="s-row" style={i===2?{borderBottom:"none",paddingBottom:0}:{}}>
            <div>
              <div className="s-row-label">{inv.plan}</div>
              <div className="s-row-sub">{inv.date}</div>
            </div>
            <div style={{display:"flex",alignItems:"center",gap:8}}>
              <div style={{fontSize:12,fontWeight:700}}>{inv.amount}</div>
              <div style={{fontSize:10,fontWeight:700,background:"var(--gnl)",color:"var(--gn)",padding:"2px 7px",borderRadius:20}}>Paid</div>
              <button className="btn btn-o" style={{height:24,fontSize:10,padding:"0 7px"}}>↓</button>
            </div>
          </div>
        ))}
      </SCard>

      {/* ── CANCEL ── */}
      <div style={{border:"1px solid rgba(220,38,38,.2)",borderRadius:"var(--r)",background:"var(--rdl)",padding:"14px 16px"}}>
        <div style={{fontSize:12.5,fontWeight:700,color:"var(--rd)",marginBottom:3}}>Cancel subscription</div>
        <div style={{fontSize:11.5,color:"#EF4444",marginBottom:10,lineHeight:1.5}}>Your access continues until 14 Aug 2025. All your data is preserved.</div>
        <button className="btn btn-d btn-sm">Cancel subscription</button>
      </div>
    </>
  );
}
```

---

## TAB 7 — DATA

```jsx
function STabData({ listings, stockData, liveData, setLiveData }) {
  const as = getAS(liveData);
  const setAS = (k,v) => setLiveData(prev=>({...prev,appSettings:{...(prev?.appSettings||{}),[k]:v}}));

  const handleExport = () => {
    // 1. Trigger JSON export
    const payload = {
      exportedAt: getToday(),
      listings,
      stockData,
      appSettings: liveData?.appSettings || {},
      goals: liveData?.goals || {},
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type:"application/json" });
    const url  = URL.createObjectURL(blob);
    const a    = document.createElement("a");
    a.href     = url;
    a.download = `skuflow-export-${getToday()}.json`;
    a.click();
    URL.revokeObjectURL(url);

    // 2. Trigger XLSX export (call existing XLSX builder)
    exportXLSX(listings, stockData);

    // 3. Record last exported date
    setAS("lastExported", getToday());
  };

  return (
    <>
      <SCard icon={<IcoDataMgmt/>} title="Export Data" sub="Downloads JSON + XLSX simultaneously">
        <div className="s-row">
          <div>
            <div className="s-row-label">Export all data</div>
            <div className="s-row-sub">Listings, stock, settings · {as.lastExported ? `Last: ${as.lastExported}` : "Never exported"}</div>
          </div>
          <button className="btn btn-o btn-sm" onClick={handleExport}>↓ Export</button>
        </div>
      </SCard>

      {/* ── VERSION HISTORY ── */}
      {/* Migrate existing VersionHistory component content here unchanged */}
      <VersionHistory liveData={liveData} setLiveData={setLiveData} />

      {/* ── DANGER ZONE ── */}
      <SCard icon={<IcoDataMgmt/>} title="Reset Data">
        <div className="s-row">
          <div><div className="s-row-label">Reset all listings</div><div className="s-row-sub">Permanently deletes all listing data</div></div>
          <button className="btn btn-d btn-sm" onClick={()=>{ if(confirm("Delete all listings? This cannot be undone.")) setListings([]); }}>Reset</button>
        </div>
        <div className="s-row" style={{borderBottom:"none",paddingBottom:0}}>
          <div><div className="s-row-label">Reset all stock</div><div className="s-row-sub">Permanently deletes all stock bundles</div></div>
          <button className="btn btn-d btn-sm" onClick={()=>{ if(confirm("Delete all stock? This cannot be undone.")) setStockData([]); }}>Reset</button>
        </div>
      </SCard>
    </>
  );
}
```

---

## TAB 8 — CONTACT US

```jsx
function STabContact({ workspaceId, workspaceName, tier }) {
  const [type,    setType]    = useState("question");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [sending, setSending] = useState(false);
  const [sent,    setSent]    = useState(false);

  const submit = async () => {
    if (!subject.trim() || !message.trim()) return;
    setSending(true);
    await supabase.from("contact_submissions").insert({
      workspace_id: workspaceId,
      type,
      subject:      subject.trim(),
      message:      message.trim(),
      tier,
      status:       "new",
    });
    // Resend email notification fires via Supabase trigger or Edge Function
    setSending(false);
    setSent(true);
  };

  if (sent) {
    return (
      <div style={{textAlign:"center",padding:"48px 24px"}}>
        <div style={{width:52,height:52,borderRadius:14,background:"var(--gnl)",display:"flex",alignItems:"center",justifyContent:"center",margin:"0 auto 16px"}}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="var(--gn)" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <div style={{fontSize:16,fontWeight:800,color:"var(--tx)",marginBottom:6}}>Message sent</div>
        <div style={{fontSize:13,color:"var(--txm)",lineHeight:1.6,marginBottom:20}}>We typically reply within 24 hours.</div>
        <button className="btn btn-o" onClick={()=>{ setSent(false); setSubject(""); setMessage(""); }}>Send another</button>
      </div>
    );
  }

  return (
    <SCard icon={<IcoMail/>} title="Send a message" sub="We typically reply within 24 hours">

      {/* Type selector */}
      <div style={{display:"grid",gridTemplateColumns:"1fr 1fr 1fr",gap:7,marginBottom:14}}>
        {[
          { id:"question",   label:"Question",   icon:"❓" },
          { id:"suggestion", label:"Suggestion", icon:"💡" },
          { id:"issue",      label:"Issue",      icon:"🐛" },
        ].map(t => (
          <div key={t.id} onClick={()=>setType(t.id)} style={{
            padding:"10px 8px",borderRadius:"var(--r2)",textAlign:"center",cursor:"pointer",
            border:`1.5px solid ${type===t.id?"var(--ac)":"var(--bd)"}`,
            background:type===t.id?"var(--acl)":"var(--card-bg)",
          }}>
            <div style={{fontSize:18,marginBottom:3}}>{t.icon}</div>
            <div style={{fontSize:11,fontWeight:700,color:type===t.id?"var(--ac)":"var(--tx)"}}>{t.label}</div>
          </div>
        ))}
      </div>

      <div style={{marginBottom:10}}>
        <div style={{fontSize:11.5,fontWeight:600,color:"var(--tx)",marginBottom:5}}>Subject</div>
        <input className="finp" placeholder="What's this about?" value={subject} onChange={e=>setSubject(e.target.value)} style={{width:"100%"}} />
      </div>

      <div style={{marginBottom:14}}>
        <div style={{fontSize:11.5,fontWeight:600,color:"var(--tx)",marginBottom:5}}>Message</div>
        <textarea className="fta" style={{minHeight:90}} placeholder="Tell us more…" value={message} onChange={e=>setMessage(e.target.value)} />
      </div>

      <div style={{display:"flex",alignItems:"center",justifyContent:"space-between"}}>
        <div style={{fontSize:11,color:"var(--txd)"}}>Sending as <strong style={{color:"var(--txm)"}}>{workspaceName}</strong> · {tier}</div>
        <button className="btn btn-p" onClick={submit} disabled={sending||!subject.trim()||!message.trim()}>
          {sending ? "Sending…" : "Send"}
        </button>
      </div>
    </SCard>
  );
}
```

---

## SHARED HELPERS

### SToggle (top-level)

```jsx
function SToggle({ on, onChange }) {
  return (
    <div
      onClick={() => onChange(!on)}
      style={{
        width:36, height:20, borderRadius:99, position:"relative",
        background: on ? "var(--ac)" : "#D1D5DB",
        cursor:"pointer", transition:"background .15s", flexShrink:0,
      }}
    >
      <div style={{
        position:"absolute", top:3,
        left: on ? 19 : 3,
        width:14, height:14, borderRadius:"50%",
        background:"#fff", boxShadow:"0 1px 3px rgba(0,0,0,.2)",
        transition:"left .15s",
      }} />
    </div>
  );
}
```

### CSS additions

```css
/* Section label inside card body */
.s-section-label {
  font-size: 10.5px; font-weight: 700; letter-spacing: .06em;
  text-transform: uppercase; color: var(--txd);
  display: block; margin-bottom: 8px;
}

.s-section-label + * { margin-top: 0; }

/* Textarea */
.fta {
  width: 100%; background: var(--main-bg);
  border: 1.5px solid var(--bd); border-radius: var(--r2);
  padding: 9px 12px; font-size: 13px; color: var(--tx);
  line-height: 1.6; resize: none; font-family: inherit;
  box-shadow: var(--shadow);
}

/* Danger button */
.btn-d {
  background: var(--rdl); color: var(--rd);
  border: 1px solid rgba(220,38,38,.2);
}

/* Small button */
.btn-sm { height: 28px; padding: 0 12px; font-size: 11.5px; }
```

---

## ENTRY POINT — wiring into App root

Replace the existing `{view==="settings" && <Settings .../>}` render with:

```jsx
{view === "settings" && (
  <SettingsPage
    liveData={liveData}
    setLiveData={setLiveData}
    listings={listings}
    stockData={stockData}
    tier={tier}
    workspaceId={workspaceId}
    workspaceName={workspaceName}
    listingLimit={listingLimit}
  />
)}
```

---

## IMPLEMENTATION ORDER

1. Add `SToggle` top-level component
2. Add `SGolInput` top-level component
3. Add `SCard` top-level component
4. Add CSS (settings-tabs, settings-tab, settings-content, s-card, s-row, s-section-label, fta, btn-d, btn-sm)
5. Add `STabAccount` top-level component
6. Add `STabNotifications` top-level component
7. Add `STabPreferences` top-level component
8. Add `STabStock` top-level component
9. Add `STabListings` top-level component
10. Add `STabBilling` top-level component
11. Add `STabData` top-level component
12. Add `STabContact` top-level component
13. Add `SettingsPage` wrapper top-level component
14. Wire swipe detection in `SettingsPage`
15. Replace old Settings render in App root
16. Remove old Settings component

---

## NOTES FOR CLAUDE IN THE NEW CHAT

- All components must be top-level named functions — never inline arrow functions inside parents
- `SCard` header uses `box-shadow: inset 3px 0 0 var(--ac)` NOT `border-left` — border-left is clipped by overflow:hidden
- `SToggle` must be top-level — it's used inside multiple tab components
- `SGolInput` must be top-level — used inside STabPreferences
- Swipe detection uses `useRef` for `touchStartX` — must be inside `SettingsPage`, not a child
- Version History component inside Data tab stays unchanged — just import/render it there
- `tier` prop flows from App root through `SettingsPage` to individual tabs that need gating
- Back navigation (`back gesture`) goes back to previous app view, not within settings tabs — settings tab state is local only
