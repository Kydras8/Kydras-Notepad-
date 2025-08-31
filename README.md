🔄 Developer Workflow
Kydras Notepad+ is built for speed and automation. Use the pushkydras command (from your PowerShell profile) to:

Auto‑repair Git hooks (pre + post commit)

Run self‑tests

Update STATUS.md and README badges

Commit & push in one shot

powershell
pushkydras "feat: add new plugin system"
📂 Repo Structure
Code
scripts/         # Bootstrapper, self-test, workflow guard, dashboard generator
plugins/         # Modular plugin system
.github/         # CI/CD workflows
STATUS.md        # Auto-generated repo health dashboard
README.md        # This file
📊 Live Status Dashboard
The STATUS.md file and README badges are updated automatically after every commit. It includes:

🏆 Credits
Built with ❤️ by Kyle Rasmussen Master of modular scripting, automation, and aesthetic perfection.

📜 License
MIT License — See LICENSE for details.
