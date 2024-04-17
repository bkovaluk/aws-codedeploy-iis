# Function to clean up wwwroot directory
function Clear-WebContent {
    $webRootPath = "C:\inetpub\wwwroot"

    Write-Host "Cleaning up wwwroot directory..."

    # Remove all files and directories in wwwroot
    Get-ChildItem -Path $webRootPath | ForEach-Object {
        if ($_.Name -ne "iisstart.htm") {
            # Exclude the default IIS welcome page (iisstart.htm)
            if ($_.PSIsContainer) {
                Remove-Item -Path $_.FullName -Recurse -Force
            } else {
                Remove-Item -Path $_.FullName -Force
            }
        }
    }
}

# Perform cleanup in wwwroot directory before install
Clear-WebContent