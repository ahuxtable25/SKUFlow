import { useState } from "react";
import { supabase } from "./supabaseClient.js";

const COLORS = {
  bg: "#f4f3f0", sf: "#ffffff", tx: "#0f0f0e", txm: "#5c584f", txd: "#a8a49b",
  ac: "#c0273a", acl: "#faebec", ach: "#a31f30", bdd: "#e5e3dc",
};

export default function WaitlistPage() {
  const [name,    setName]    = useState("");
  const [email,   setEmail]   = useState("");
  const [loading, setLoading] = useState(false);
  const [status,  setStatus]  = useState(null); // null | "ok" | "duplicate" | "error"
  const [errMsg,  setErrMsg]  = useState("");

  const submit = async (e) => {
    e.preventDefault();
    if (!email || loading) return;
    setLoading(true);
    setStatus(null);
    const { error } = await supabase.from("waitlist").insert({
      email: email.trim().toLowerCase(),
      name: name.trim() || null,
    });
    setLoading(false);
    if (error) {
      if (error.code === "23505") {
        setStatus("duplicate");
      } else {
        setStatus("error");
        setErrMsg(error.message);
      }
      return;
    }
    setStatus("ok");
  };

  return (
    <div style={{
      minHeight: "100vh", background: COLORS.bg, fontFamily: "Arial, sans-serif",
      display: "flex", alignItems: "center", justifyContent: "center",
      padding: "24px 16px", boxSizing: "border-box",
    }}>
      <div style={{ width: "100%", maxWidth: 480, textAlign: "center" }}>
        <div style={{
          fontSize: 28, fontWeight: 800, letterSpacing: "-.5px", color: COLORS.tx, marginBottom: 8,
        }}>
          SKUFlow
        </div>
        <div style={{ fontSize: 15, color: COLORS.txm, marginBottom: 4, fontWeight: 700 }}>
          The reseller business OS — launching soon.
        </div>
        <div style={{ fontSize: 13, color: COLORS.txd, marginBottom: 28, lineHeight: 1.6 }}>
          Track stock, listings, and profit across every platform in one place.
          Join the waitlist now and get <strong style={{ color: COLORS.ac }}>your first month free</strong> when we launch.
        </div>

        <div style={{
          background: COLORS.sf, border: `1px solid ${COLORS.bdd}`, borderRadius: 14,
          padding: "28px 24px", boxShadow: "0 4px 24px rgba(0,0,0,.06)", textAlign: "left",
        }}>
          {status === "ok" ? (
            <div style={{ textAlign: "center", padding: "12px 0" }}>
              <div style={{ fontSize: 28, marginBottom: 10 }}>🎉</div>
              <div style={{ fontSize: 15, fontWeight: 700, color: COLORS.tx, marginBottom: 6 }}>
                You're on the list!
              </div>
              <div style={{ fontSize: 12.5, color: COLORS.txm, lineHeight: 1.6 }}>
                We'll email you as soon as SKUFlow launches — with your free month attached.
              </div>
            </div>
          ) : status === "duplicate" ? (
            <div style={{ textAlign: "center", padding: "12px 0" }}>
              <div style={{ fontSize: 28, marginBottom: 10 }}>👋</div>
              <div style={{ fontSize: 15, fontWeight: 700, color: COLORS.tx, marginBottom: 6 }}>
                You're already signed up
              </div>
              <div style={{ fontSize: 12.5, color: COLORS.txm, lineHeight: 1.6 }}>
                That email is already on the waitlist — we've got you covered for launch.
              </div>
            </div>
          ) : (
            <form onSubmit={submit}>
              {status === "error" && (
                <div style={{
                  background: COLORS.acl, color: COLORS.ac, fontSize: 12, padding: "8px 12px",
                  borderRadius: 8, marginBottom: 14,
                }}>{errMsg || "Something went wrong — try again."}</div>
              )}
              <div style={{ marginBottom: 12 }}>
                <label style={{
                  display: "block", fontSize: 10.5, fontWeight: 700, textTransform: "uppercase",
                  letterSpacing: ".4px", color: COLORS.txm, marginBottom: 5,
                }}>Name (optional)</label>
                <input
                  type="text" value={name} onChange={e => setName(e.target.value)}
                  placeholder="Jane Smith"
                  style={{
                    width: "100%", boxSizing: "border-box", background: "#f4f3f0",
                    border: `1px solid ${COLORS.bdd}`, borderRadius: 8, padding: "9px 11px",
                    fontFamily: "Arial, sans-serif", fontSize: 13, outline: "none",
                  }}
                />
              </div>
              <div style={{ marginBottom: 16 }}>
                <label style={{
                  display: "block", fontSize: 10.5, fontWeight: 700, textTransform: "uppercase",
                  letterSpacing: ".4px", color: COLORS.txm, marginBottom: 5,
                }}>Email</label>
                <input
                  type="email" required value={email} onChange={e => setEmail(e.target.value)}
                  placeholder="you@company.com"
                  style={{
                    width: "100%", boxSizing: "border-box", background: "#f4f3f0",
                    border: `1px solid ${COLORS.bdd}`, borderRadius: 8, padding: "9px 11px",
                    fontFamily: "Arial, sans-serif", fontSize: 13, outline: "none",
                  }}
                />
              </div>
              <button type="submit" disabled={loading} style={{
                width: "100%", background: COLORS.ac, color: "#fff", border: "none",
                borderRadius: 8, padding: "11px 0", fontSize: 12.5, fontWeight: 700,
                textTransform: "uppercase", letterSpacing: ".4px", cursor: "pointer",
                opacity: loading ? 0.6 : 1,
              }}>
                {loading ? "Joining…" : "Join the Waitlist"}
              </button>
            </form>
          )}
        </div>

        <div style={{ fontSize: 11, color: COLORS.txd, marginTop: 20 }}>
          Already have an account?{" "}
          <a href="/" style={{ color: COLORS.ac, fontWeight: 700, textDecoration: "none" }}>Sign in</a>
        </div>
      </div>
    </div>
  );
}
