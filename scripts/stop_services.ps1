# Function to stop IIS in case of In-place deployment
# Will not execute if running Blue Green deployment
function Stop-IIS {
    Write-Host "Stopping IIS..."
    Stop-Service -Name "W3SVC" -Force
}

# Stop IIS
Stop-IIS
