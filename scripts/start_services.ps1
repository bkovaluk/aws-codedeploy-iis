# Function to start IIS
function Start-IIS {
    Write-Host "Starting IIS..."
    Start-Service -Name "W3SVC"
}

# Start IIS and all sites after installation
Start-IIS