#!/usr/bin/env pwsh
# Gemini CLI Authentication Setup Script

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Gemini CLI Authentication Setup                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Choose your authentication method:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. API Key (Recommended - Easiest)" -ForegroundColor Green
Write-Host "  2. Google Cloud / Vertex AI" -ForegroundColor Green
Write-Host "  3. Just verify configuration" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "STEP 1: Get Your API Key" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Go to: https://ai.google.dev/" -ForegroundColor White
        Write-Host "2. Click 'Get API Key'" -ForegroundColor White
        Write-Host "3. Copy the API key" -ForegroundColor White
        Write-Host ""
        
        $apiKey = Read-Host "Paste your API Key here"
        
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Host "❌ No API key provided. Exiting." -ForegroundColor Red
            exit 1
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "STEP 2: Setting Environment Variable" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        # Set for current session
        $env:GEMINI_API_KEY = $apiKey
        Write-Host "✓ Set GEMINI_API_KEY for current PowerShell session" -ForegroundColor Green
        
        # Ask to set permanently
        $setPermanent = Read-Host "Set permanently for all future sessions? (y/n)"
        if ($setPermanent -eq "y" -or $setPermanent -eq "Y") {
            [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", $apiKey, "User")
            Write-Host "✓ Permanently saved to User environment variables" -ForegroundColor Green
            Write-Host "  (Note: Restart PowerShell to apply permanently)" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "STEP 3: Testing" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Running: gemini -p 'Run: echo Testing Gemini' --yolo" -ForegroundColor Magenta
        Write-Host ""
        
        & gemini -p "Run: echo Testing Gemini" --yolo
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✓✓✓ SUCCESS! Gemini is now working! ✓✓✓" -ForegroundColor Green
            Write-Host ""
            Write-Host "You can now use Gemini with shell commands:" -ForegroundColor Green
            Write-Host "  gemini -p 'Run: npm --version' --yolo" -ForegroundColor Magenta
            Write-Host "  gemini -p 'Run: git status' --yolo" -ForegroundColor Magenta
            Write-Host "  gemini -p 'Run: npm run build' --yolo" -ForegroundColor Magenta
        } else {
            Write-Host ""
            Write-Host "❌ Test failed. Check the error above." -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "Google Cloud Setup Instructions" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        Write-Host "STEP 1: Install Google Cloud CLI" -ForegroundColor Yellow
        Write-Host "  Option A (Chocolatey): choco install google-cloud-sdk" -ForegroundColor White
        Write-Host "  Option B (Direct): https://cloud.google.com/sdk/docs/install" -ForegroundColor White
        Write-Host ""
        
        Write-Host "STEP 2: Authenticate" -ForegroundColor Yellow
        Write-Host "  Run: gcloud auth login" -ForegroundColor Magenta
        Write-Host "  Run: gcloud auth application-default login" -ForegroundColor Magenta
        Write-Host ""
        
        Write-Host "STEP 3: Enable Vertex AI API" -ForegroundColor Yellow
        Write-Host "  1. Go to: https://console.cloud.google.com/" -ForegroundColor White
        Write-Host "  2. Search for 'Vertex AI API'" -ForegroundColor White
        Write-Host "  3. Click 'Enable'" -ForegroundColor White
        Write-Host ""
        
        Write-Host "STEP 4: Set Environment Variables" -ForegroundColor Yellow
        Write-Host "  Run:" -ForegroundColor White
        Write-Host "    `$env:GOOGLE_GENAI_USE_VERTEXAI = 'true'" -ForegroundColor Magenta
        Write-Host "    `$env:GOOGLE_CLOUD_PROJECT = 'your-project-id'" -ForegroundColor Magenta
        Write-Host ""
        
        Write-Host "STEP 5: Test" -ForegroundColor Yellow
        Write-Host "  Run: gemini -p 'Run: echo test' --yolo" -ForegroundColor Magenta
    }
    
    "3" {
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "Verifying Configuration" -ForegroundColor Yellow
        Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host ""
        
        # Check Gemini CLI
        Write-Host "Gemini CLI Version:" -ForegroundColor Yellow
        & gemini --version
        Write-Host ""
        
        # Check settings files
        Write-Host "Configuration Files:" -ForegroundColor Yellow
        
        $userSettings = "C:\Users\ankud\.gemini\settings.json"
        if (Test-Path $userSettings) {
            Write-Host "✓ User-level config found: $userSettings" -ForegroundColor Green
            Write-Host "  Content:" -ForegroundColor Cyan
            Get-Content $userSettings | Write-Host
        } else {
            Write-Host "❌ User-level config not found" -ForegroundColor Red
        }
        
        Write-Host ""
        
        $projectSettings = "C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json"
        if (Test-Path $projectSettings) {
            Write-Host "✓ Project-level config found: $projectSettings" -ForegroundColor Green
            Write-Host "  Content:" -ForegroundColor Cyan
            Get-Content $projectSettings | Write-Host
        } else {
            Write-Host "❌ Project-level config not found" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "Environment Variables:" -ForegroundColor Yellow
        
        if ([string]::IsNullOrWhiteSpace($env:GEMINI_API_KEY)) {
            Write-Host "⚠ GEMINI_API_KEY: Not set" -ForegroundColor Yellow
        } else {
            Write-Host "✓ GEMINI_API_KEY: Set (length: $($env:GEMINI_API_KEY.Length))" -ForegroundColor Green
        }
        
        if ([string]::IsNullOrWhiteSpace($env:GOOGLE_GENAI_USE_VERTEXAI)) {
            Write-Host "⚠ GOOGLE_GENAI_USE_VERTEXAI: Not set" -ForegroundColor Yellow
        } else {
            Write-Host "✓ GOOGLE_GENAI_USE_VERTEXAI: $($env:GOOGLE_GENAI_USE_VERTEXAI)" -ForegroundColor Green
        }
        
        if ([string]::IsNullOrWhiteSpace($env:GOOGLE_CLOUD_PROJECT)) {
            Write-Host "⚠ GOOGLE_CLOUD_PROJECT: Not set" -ForegroundColor Yellow
        } else {
            Write-Host "✓ GOOGLE_CLOUD_PROJECT: $($env:GOOGLE_CLOUD_PROJECT)" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Set GEMINI_API_KEY or Google Cloud credentials" -ForegroundColor White
        Write-Host "2. Run: gemini -p 'Run: echo test' --yolo" -ForegroundColor Magenta
    }
    
    default {
        Write-Host "❌ Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Documentation: .\.gemini\GEMINI-SETUP.md" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
