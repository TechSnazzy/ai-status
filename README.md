# AI Status

A tiny macOS menu bar app that shows your Claude and ChatGPT (Codex) usage — daily/session limit, weekly limit, and reset times — at a glance.

Click the menu bar icon to see two tabs, one per service:

- **Current session** — percent used and when it resets
- **This week** — percent used and when it resets

## Why

Neither Claude nor ChatGPT expose personal usage/rate-limit data through a public API — that information only exists in the internal endpoints their web apps call. This app talks to those same endpoints, authenticated with your own browser session cookie, exactly the way the website itself does.

## Setup

### Build & run

Requires macOS 13+ and Xcode command line tools (for the Swift toolchain).

```bash
swift run
```

The app appears as an icon in your menu bar (no Dock icon, no window).

### Connect your accounts

The app needs one session cookie per service. These are **not** API keys — they're the same cookie your browser already uses to stay logged in, so treat them like a password.

**Claude:**
1. Log into [claude.ai](https://claude.ai) in your browser.
2. Open DevTools → **Application** → **Cookies** → `https://claude.ai`.
3. Copy the value of the `sessionKey` cookie.

**ChatGPT:**
1. Log into [chatgpt.com](https://chatgpt.com) in your browser.
2. Open DevTools → **Application** → **Cookies** → `https://chatgpt.com`.
3. Copy the value of the `__Secure-next-auth.session-token` cookie.
   - If your browser split it into numbered chunks (`.0`, `.1`, `.2`, ...), concatenate the values in order with no separator — that's the full token.

Then in the app: click the menu bar icon → gear icon → paste each value → **Save**.

## Where your data goes

Cookie values are stored **only** in the macOS Keychain, under the `com.seanmorrison.aistatus` service, and are never written to disk elsewhere or sent anywhere except directly to `claude.ai` / `chatgpt.com`. Nothing is logged or transmitted to any third party.

## Notes

- These are undocumented, internal endpoints reverse-engineered from each site's own settings UI. They may change without notice.
- Session cookies expire periodically (weeks to months). When that happens the app will show "Not connected" — just repaste a fresh value in Settings.
