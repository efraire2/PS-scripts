# Import the Active Directory module
Import-Module ActiveDirectory

# Set the number of days
$DaysInactive = 60

# Get the current date and calculate the date 60 days ago
$CurrentDate = Get-Date
$InactiveDate = $CurrentDate.AddDays(-$DaysInactive)

# Set the path for the CSV file
$CSVPath = "C:\InactiveUsers.csv"

# List of domains to search (replace with your actual domain names)
$Domains = @(
    "domain1.com",
    "subdomain.domain1.com",
    "domain2.com"
)

# Create an array to store results
$InactiveUsers = @()

# Loop through each domain
foreach ($Domain in $Domains) {
    Write-Host "Searching in domain: $Domain"
    
    # Get the domain controller for the current domain
    $DC = (Get-ADDomainController -Domain $Domain -Discover -NextClosestSite).HostName[0]
    
    # Search for inactive user accounts in the current domain
    $DomainInactiveUsers = Get-ADUser -Server $DC -Filter {LastLogonDate -lt $InactiveDate -and Enabled -eq $true} -Properties LastLogonDate, DistinguishedName |
        Select-Object @{Name="Domain";Expression={$Domain}}, SamAccountName, Name, LastLogonDate, DistinguishedName
    
    # Add results to the array
    $InactiveUsers += $DomainInactiveUsers
}

# Export results to CSV
$InactiveUsers | Export-Csv -Path $CSVPath -NoTypeInformation

# Display confirmation message
Write-Host "Inactive users from all specified domains have been exported to $CSVPath"