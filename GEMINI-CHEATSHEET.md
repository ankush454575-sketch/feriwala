# 🎯 Gemini CLI - Quick Reference Card

## The Problem
```
❌ Error: "Command is not in the list of allowed tools"
```

## The Solution
1. Get API key from https://ai.google.dev/
2. `$env:GEMINI_API_KEY = "your-key"`
3. `gemini -p "Run: echo test" --yolo`

---

## Essential Commands

### Setup & Testing
```powershell
# Set API key (temporary)
$env:GEMINI_API_KEY = "your-api-key"

# Set permanently
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "your-key", "User")

# Test it
gemini -p "Run: echo Working!" --yolo
```

### Development
```powershell
gemini -p "Run: npm run dev" --yolo
gemini -p "Run: npm run build" --yolo
gemini -p "Run: npm test" --yolo
```

### Git
```powershell
gemini -p "Run: git status" --yolo
gemini -p "Run: git add . && git commit -m 'message'" --yolo
gemini -p "Run: git push" --yolo
```

### Deployment
```powershell
gemini -p "Run: bash deploy-v4.sh" --yolo
gemini -p "Run: ssh -i key.pem user@host 'pm2 status'" --yolo
```

### Project Commands
```powershell
gemini -p "Run: cd server && npm run build" --yolo
gemini -p "Run: npm install" --yolo
gemini -p "Run: ls -la" --yolo
```

---

## Flags

| Flag | Meaning |
|------|---------|
| `--yolo` | Auto-approve commands (no confirmation) |
| `-p "command"` | Command to execute |
| `--help` | Show help |
| `--version` | Show version |

---

## Configuration

### File Locations
- User: `C:\Users\ankud\.gemini\settings.json`
- Project: `C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json`

### Content (Already Set ✓)
```json
{
  "tools": {
    "core": [
      "run_shell_command(*)"
    ]
  }
}
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| "Please set an Auth method" | Set `GEMINI_API_KEY` env variable |
| "Invalid API key" | Get new key from https://ai.google.dev/ |
| Changes not working | Restart PowerShell |
| "command not found" | `npm install -g @google/gemini-cli` |

---

## Pro Tips

✨ **Make it permanent** (do this once):
```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "your-key", "User")
```
Then restart PowerShell - key is saved forever!

✨ **Create aliases** for common commands:
```powershell
# In PowerShell profile
function gbuild { gemini -p "Run: npm run build" --yolo }
function gtest { gemini -p "Run: npm test" --yolo }
function gdeploy { gemini -p "Run: bash deploy-v4.sh" --yolo }
```

✨ **Use in scripts**:
```powershell
# Any PowerShell script can now use Gemini
gemini -p "Run: npm start" --yolo
```

---

## Documentation Links

| File | Purpose |
|------|---------|
| `README-GEMINI.md` | Full guide (start here!) |
| `GEMINI-QUICK-FIX.md` | Quick solutions |
| `.gemini/GEMINI-SETUP.md` | Detailed setup |
| `setup-gemini.bat` | Setup helper script |

---

**Created**: November 12, 2025  
**Status**: ✅ Ready to use  
**Authentication**: Get API key from https://ai.google.dev/
