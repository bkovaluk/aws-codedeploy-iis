# Get a list of all application pools in IIS
$appPools = Get-IISAppPool

# Iterate through each application pool
foreach ($appPool in $appPools) {
    $appPoolName = $appPool.Name
    $appPoolState = $appPool.State

    # Exclude default application pools by checking the name
    if ($appPoolName -notlike "DefaultAppPool*" -and $appPoolName -notlike "Classic .NET AppPool") {
        # Check if the application pool is in the "Started" state
        if ($appPoolState -eq "Started") {
            Write-Host "Application pool '$appPoolName' is running."
        } else {
            Write-Host "Application pool '$appPoolName' is not running. State: $appPoolState"
            exit 1
        }
    }
}
