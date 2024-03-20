#AD Export for specific info

# Specify the output CSV file path
$csvFilePath = "C:\Temp\csv\ADUsersExportdel.csv"

# Specify the subdomain DC server name
$subdomainDC = "sub.domain.com"

# Define a function to extract the Organizational Unit (OU) from DistinguishedName
function Get-OUPath {
    param(
        [string]$DistinguishedName
    )
    # Split the DistinguishedName into components
    $dnComponents = $DistinguishedName -split ','

    # Exclude the first component (CN) and join the rest to get the OU path
    $ouPath = ($dnComponents | Where-Object { $_ -notmatch '^CN=' }) -join ','

    return $ouPath
}

# Define a function to remove OU and DC paths from the Manager attribute
function Remove-OUandDCPaths {
    param(
        [string]$ManagerAttribute
    )

    # Split the Manager attribute by comma to separate the paths
    $Paths = $ManagerAttribute -split ','

    # Remove OU and DC paths
    $CleanedPaths = $Paths | Where-Object { $_ -notmatch 'OU=' -and $_ -notmatch 'DC=' }

    # Join the cleaned paths back into a single string
    $CleanedManager = $CleanedPaths -join ','

    return $CleanedManager
}

# Get all users from Active Directory on the specified subdomain DC and select the specified properties
$users = Get-ADUser -Server $subdomainDC -Filter * -Properties DisplayName, Enabled, DistinguishedName, SamAccountName, SID, UserPrincipalName, EmployeeID, Surname, GivenName, Company, co, Created, Title, Manager, Location, Department, PreferredLanguage  |
    Select-Object @{
        Name = 'Enabled'
        Expression = { $_.Enabled }
    }, @{
        Name = 'Username'
        Expression = { $_.SamAccountName }
    }, @{
        Name = 'UserPrincipleName'
        Expression = { $_.UserPrincipalName }
    }, @{
        Name = 'Display name'
        Expression = { $_.DisplayName }
    }, @{
        Name = 'Employee ID'
        Expression = { $_.employeeID }
    }, @{
        Name = 'First Name'
        Expression = { $_.GivenName }
    }, @{
        Name = 'Last Name'
        Expression = { $_.Surname }
    },  @{
        Name = 'Job title'
        Expression = { $_.Title }
    }, @{
        Name = 'Manager'
        Expression = { Remove-OUandDCPaths -ManagerAttribute $_.Manager }
    }, @{
        Name = 'Company'
        Expression = { $_.Company }
    }, @{
        Name = 'Country'
        Expression = { $_.co }
    }, @{
        Name = 'OU path'
        Expression = { Get-OUPath -DistinguishedName $_.DistinguishedName }
    },  @{
        Name = 'SID'
        Expression = { $_.SID }
    }

# Export the results to a CSV file
$users | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file exported to: $csvFilePath"
