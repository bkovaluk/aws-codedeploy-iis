# Retrieve APPLICATION_NAME environment variable
$applicationName = [System.Environment]::GetEnvironmentVariable("APPLICATION_NAME", [System.EnvironmentVariableTarget]::Process)

Write-Host "Creating IIS Sites..."
$application, $environment = $applicationName -split "_"
Write-Host "Application: $($application.toUpper())"
Write-Host "Environment: $($environment.toUpper())"

# Read settings from JSON file
$confDir = Join-Path -Path $PSScriptRoot -ChildPath "..\conf"
$siteConfigurations = Get-Content "${confDir}\${application}\${environment}.json" -Raw | ConvertFrom-Json

$sm = Get-IISServerManager

foreach ($siteConfiguration in $siteConfigurations) {
    # Assign variables from JSON content
    $appName = $siteConfiguration.appName
    $protocol = $siteConfiguration.protocol
    $port = $siteConfiguration.port
    $physicalPath = $siteConfiguration.physicalPath
    $hostHeaders = $siteConfiguration.bindings

    # Check if the site exists and create it if it doesn't
    $site = $sm.Sites[$appName]
    if ($null -eq $site) {
        $site = $sm.Sites.Add($appName, $protocol, "*:${port}:", $physicalPath)
        $site.Bindings.Clear()
        Write-Host "Site created: $appName"
    } else {
        Write-Host "Site already exists: $appName"
    }

    # Check if site bindings exist and create them if they do not
    foreach ($hostHeader in $hostHeaders) {
        $bindingInformation = "*:${port}:${hostHeader}"
        try {
            $site.Bindings.Add($bindingInformation, $protocol) | Out-Null
            Write-Host "Binding created: $bindingInformation"
        } catch [System.Exception] {
            # Handle the exception silently (do nothing) or log the error if needed
            Write-Host "Binding already exists or failed to create: $bindingInformation"
        }
    }

    # Check if the application pool exists and create it if it doesn't
    $appPool = $sm.ApplicationPools[$appName]
    if ($null -eq $appPool) {
        $appPool = $sm.ApplicationPools.Add($appName)
        Write-Host "Application pool created: $appName"
    } else {
        Write-Host "Application pool already exists: $appName"
    }

    # Set the application pool to the root application of the site
    $site.Applications["/"].ApplicationPoolName = $appName

    # Identity type settings
    $identityType = $siteConfiguration.identityType

    if ($identityType -eq "SpecificUser") {
        $appPool.ProcessModel.IdentityType = [Microsoft.Web.Administration.ProcessModelIdentityType]::SpecificUser
        $appPool.ProcessModel.UserName = $siteConfiguration.userName

        # Retrieve the secret value
        if ($siteConfiguration.password) {
            $appPool.ProcessModel.Password = $siteConfiguration.password
        } else {
            $secretId = $siteConfiguration.secretId
            $secretOutput = (aws secretsmanager get-secret-value --secret-id $secretId --query 'SecretString' --output text)
            $secretValue = (ConvertFrom-Json $secretOutput).password
            $appPool.ProcessModel.Password = $secretValue
        }

        Write-Host "Application pool identity set to SpecificUser for $appName"
    } elseif ($identityType -eq "ApplicationPoolIdentity") {
        $appPool.ProcessModel.IdentityType = [Microsoft.Web.Administration.ProcessModelIdentityType]::ApplicationPoolIdentity
        Write-Host "Application pool identity set to ApplicationPoolIdentity for $appName"
    }
}

# Commit the changes to the server manager
$sm.CommitChanges()
Write-Host "All changes committed to IIS Server Manager"
