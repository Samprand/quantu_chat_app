# PowerShell script to download Inter font files
# Run this script from the flutter_chat_app directory

Write-Host "Downloading Inter font files..." -ForegroundColor Green

# Create fonts directory if it doesn't exist
if (!(Test-Path "assets/fonts")) {
    New-Item -ItemType Directory -Path "assets/fonts" -Force
}

# Download Inter font files from Google Fonts
$fontUrls = @{
    "Inter-Regular.ttf" = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Regular.woff2"
    "Inter-Medium.ttf" = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Medium.woff2"
    "Inter-SemiBold.ttf" = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-SemiBold.woff2"
    "Inter-Bold.ttf" = "https://github.com/rsms/inter/raw/master/docs/font-files/Inter-Bold.woff2"
}

foreach ($font in $fontUrls.GetEnumerator()) {
    $fontName = $font.Key
    $fontUrl = $font.Value
    $fontPath = "assets/fonts/$fontName"
    
    Write-Host "Downloading $fontName..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile $fontPath
        Write-Host "Downloaded $fontName" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to download $fontName" -ForegroundColor Red
        Write-Host "You can manually download Inter fonts from: https://fonts.google.com/specimen/Inter" -ForegroundColor Yellow
    }
}

Write-Host "Font download completed!" -ForegroundColor Green
Write-Host "Note: If some fonts failed to download, you can manually download them from Google Fonts" -ForegroundColor Yellow 