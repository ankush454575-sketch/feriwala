@echo off
REM Gemini CLI Setup Script (Batch version)

echo.
echo ================================================================
echo Gemini CLI Authentication Setup
echo ================================================================
echo.
echo Choose your authentication method:
echo.
echo  1. API Key (Recommended - Easiest)
echo  2. Google Cloud / Vertex AI
echo  3. Just verify configuration
echo.

set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    echo.
    echo ================================================================
    echo STEP 1: Get Your API Key
    echo ================================================================
    echo.
    echo 1. Go to: https://ai.google.dev/
    echo 2. Click 'Get API Key'
    echo 3. Copy the API key
    echo.
    set /p apiKey="Paste your API Key here: "
    
    if "!apiKey!"=="" (
        echo No API key provided. Exiting.
        exit /b 1
    )
    
    echo.
    echo ================================================================
    echo STEP 2: Setting Environment Variable
    echo ================================================================
    echo.
    
    setx GEMINI_API_KEY "%apiKey%"
    echo API Key saved! (Requires PowerShell restart to take effect)
    
    echo.
    echo ================================================================
    echo STEP 3: Testing
    echo ================================================================
    echo.
    
    set GEMINI_API_KEY=%apiKey%
    call gemini -p "Run: echo Testing Gemini" --yolo
    
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo SUCCESS! Gemini is now working!
        echo.
        echo You can now use Gemini with shell commands:
        echo   gemini -p "Run: npm --version" --yolo
        echo   gemini -p "Run: git status" --yolo
        echo   gemini -p "Run: npm run build" --yolo
    ) else (
        echo.
        echo Test failed. Check the error above.
    )
) else if "%choice%"=="2" (
    echo.
    echo ================================================================
    echo Google Cloud Setup Instructions
    echo ================================================================
    echo.
    echo STEP 1: Install Google Cloud CLI
    echo   Option A (Chocolatey^): choco install google-cloud-sdk
    echo   Option B (Direct^): https://cloud.google.com/sdk/docs/install
    echo.
    echo STEP 2: Authenticate
    echo   Run: gcloud auth login
    echo   Run: gcloud auth application-default login
    echo.
    echo STEP 3: Enable Vertex AI API
    echo   1. Go to: https://console.cloud.google.com/
    echo   2. Search for 'Vertex AI API'
    echo   3. Click 'Enable'
    echo.
    echo STEP 4: Set Environment Variables
    echo   Run in PowerShell:
    echo     $env:GOOGLE_GENAI_USE_VERTEXAI = 'true'
    echo     $env:GOOGLE_CLOUD_PROJECT = 'your-project-id'
    echo.
    echo STEP 5: Test
    echo   Run: gemini -p "Run: echo test" --yolo
) else if "%choice%"=="3" (
    echo.
    echo ================================================================
    echo Verifying Configuration
    echo ================================================================
    echo.
    
    echo Gemini CLI Version:
    call gemini --version
    echo.
    
    echo Configuration Files:
    
    if exist "C:\Users\ankud\.gemini\settings.json" (
        echo User-level config found: C:\Users\ankud\.gemini\settings.json
        type "C:\Users\ankud\.gemini\settings.json"
    ) else (
        echo User-level config not found
    )
    
    echo.
    
    if exist "C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json" (
        echo Project-level config found: C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json
        type "C:\Users\ankud\Desktop\feriwala1.0\.gemini\settings.json"
    ) else (
        echo Project-level config not found
    )
    
    echo.
    echo Environment Variables:
    if defined GEMINI_API_KEY (
        echo GEMINI_API_KEY: Set
    ) else (
        echo GEMINI_API_KEY: Not set
    )
) else (
    echo Invalid choice. Exiting.
    exit /b 1
)

echo.
echo ================================================================
echo Documentation: .\.gemini\GEMINI-SETUP.md
echo ================================================================
