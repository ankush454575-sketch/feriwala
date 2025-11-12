# 🚀 Fix Gemini CLI - Complete Solution

## Problem
Gemini CLI says: **"Command is not in the list of allowed tools"**

## Root Cause
Gemini CLI requires **authentication** before it can execute shell commands, even though the whitelist is configured.

---

## ✅ SOLUTION - 3 Steps

### Step 1: Get API Key (2 minutes)

Go to **https://ai.google.dev/** and click **"Get API Key"** (sign in with Google if needed)

Copy the key that looks like: `AIza...`

### Step 2: Set Environment Variable (1 minute)

**Option A: Temporary (current PowerShell session only)**
```powershell
$env:GEMINI_API_KEY = "paste-your-api-key-here"
```

**Option B: Permanent (all future sessions)**
```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "paste-your-api-key-here", "User")
```
Then restart PowerShell.

### Step 3: Test (30 seconds)

```powershell
gemini -p "Run: echo Testing" --yolo
```

If it works, you'll see output. ✅

---

## ✨ Now You Can Use Gemini!

Once authenticated, run any command:

```powershell
# Check versions
gemini -p "Run: node --version && npm --version" --yolo

# Check git status
gemini -p "Run: git status" --yolo

# Build project
gemini -p "Run: npm run build" --yolo

# Deploy
gemini -p "Run: bash deploy-v4.sh" --yolo
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Please set an Auth method" | Set `GEMINI_API_KEY` environment variable |
| API key not working | Verify key at https://ai.google.dev/ (may be revoked) |
| Command still says "not allowed" | Check `.gemini/settings.json` exists and has `run_shell_command(*)` |
| Changes not taking effect | Restart PowerShell after setting environment variables |

---

## Configuration Files (Already Set Up ✓)

- **User-level**: `C:\Users\ankud\.gemini\settings.json`
  ```json
  {
    "tools": {
      "core": [
        "run_shell_command(*)"
      ]
    }
  }
  ```

- **Project-level**: `C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json`
  ```json
  {
    "tools": {
      "core": [
        "run_shell_command(*)"
      ]
    }
  }
  ```

Both files already have the wildcard `*` configured - **no changes needed!**

---

## Quick Start

```powershell
# 1. Set API key
$env:GEMINI_API_KEY = "your-api-key"

# 2. Test it
gemini -p "Run: echo Success!" --yolo

# 3. Start using it
gemini -p "Run: npm start" --yolo
```

That's it! 🎉

---

## Alternative: Google Cloud / Vertex AI

If you prefer Google Cloud instead of API Key:

```powershell
# 1. Install gcloud CLI from https://cloud.google.com/sdk/docs/install

# 2. Authenticate
gcloud auth login
gcloud auth application-default login

# 3. Enable Vertex AI API in Google Cloud Console
# https://console.cloud.google.com/

# 4. Set environment variables
$env:GOOGLE_GENAI_USE_VERTEXAI = "true"
$env:GOOGLE_CLOUD_PROJECT = "your-project-id"

# 5. Test
gemini -p "Run: echo test" --yolo
```

---

**Recommended**: Use **API Key** (Option 1) - it's simpler!

Created: November 12, 2025
