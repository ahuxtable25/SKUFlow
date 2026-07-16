/* /api/push.js — OneSignal REST API (zero custom crypto, zero npm deps) */
"use strict";

const ONESIGNAL_APP_ID       = process.env.ONESIGNAL_APP_ID;
const ONESIGNAL_REST_API_KEY = process.env.ONESIGNAL_REST_API_KEY;

module.exports = async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin",  "*");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "POST")   return res.status(405).json({ error: "POST only" });

  const { title, message, workspaceId } = req.body || {};
  if (!title && !message) return res.status(400).json({ error: "title or message required" });
  if (!workspaceId) return res.status(400).json({ error: "workspaceId required" });

  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_API_KEY) {
    return res.status(500).json({
      error: "ONESIGNAL_APP_ID or ONESIGNAL_REST_API_KEY not set in Vercel env vars",
    });
  }

  try {
    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method:  "POST",
      headers: {
        "Authorization": `Basic ${ONESIGNAL_REST_API_KEY}`,
        "Content-Type":  "application/json",
        "Accept":        "application/json",
      },
      body: JSON.stringify({
        app_id:                    ONESIGNAL_APP_ID,
        include_external_user_ids: [String(workspaceId)],
        channel_for_external_user_ids: "push",
        headings:                  { en: title   || "SKUFlow" },
        contents:                  { en: message || "" },
      }),
    });

    const data = await response.json();
    if (!response.ok) return res.status(response.status).json({ error: data });
    return res.status(200).json({ ok: true, recipients: data.recipients || 0, id: data.id });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
};
