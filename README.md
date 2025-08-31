# 📝 Legendary Notepad

> **A modular, high‑performance Notepad replacement** — built for speed, beauty, and total control.  
> Designed by [Kyle Rasmussen](https://github.com/Kydras8) to be the **gold standard** for developer onboarding, plugin ecosystems, and branded automation.

---

## ✨ Features

- ⚡ **Instant Launch** — Opens in milliseconds, even with large files.
- 🔌 **Plugin‑Ready Architecture** — Modular hooks, helpers, and live preview UIs.
- 🎨 **Custom UI** — Branded visuals, 3D effects, rounded edges, and themeable layouts.
- 📜 **Context Menu Hooks** — Integrates directly into Windows right‑click menus.
- 🔒 **Vault Mode** — Secure, encrypted editing sessions.
- 🧩 **Hex/Diff Views** — Inspect binary and text changes side‑by‑side.
- 📝 **Markdown Preview** — Live rendering for docs and notes.
- 🛡 **Self‑Healing Git Hooks** — Auto‑repairs pre‑commit and post‑commit hooks.
- 📊 **Live Status Dashboard** — Auto‑generated `STATUS.md` with build badges and repo health.

---

## 🚀 Quick Start

```powershell
# Clone the repo
git clone https://github.com/Kydras8/legendary-notepad.git
cd legendary-notepad

# Install dependencies
npm install

# Bootstrap environment (hooks, helpers, branding)
pwsh ./scripts/bootstrapper.ps1

# Launch Legendary Notepad
npm start
🔄 Developer Workflow
Legendary Notepad is built for speed and automation. Use the pushlegend command (from your PowerShell profile) to:

Auto‑repair Git hooks (pre + post commit)

Run self‑tests

Update STATUS.md with live badges

Commit & push in one shot

powershell
pushlegend "feat: add new plugin system"
scripts/         # Bootstrapper, self-test, workflow guard, dashboard generator
plugins/         # Modular plugin system
.github/         # CI/CD workflows
STATUS.md        # Auto-generated repo health dashboard
README.md        # This file
📊 Live Status Dashboard
The STATUS.md file is updated automatically after every commit. It includes:

Branch badge

Commit count badge

Pending changes badge

Build status badge (clickable — links to latest GitHub Actions run)

Example:
Credits
Built with ❤️ by Kyle Rasmussen Master of modular scripting, automation, and aesthetic perfection.
📜 License
MIT License — See LICENSE for details.


