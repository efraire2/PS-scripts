# File Path: Get-SingleMailboxPermissionsReport.ps1


# Function to get mailbox permissions for a single mailbox
function Get-SingleMailboxPermissionsReport {
    param (
        [string]$MailboxName
    )

    # Prepare an object to store the report for the single mailbox
    $report = [PSCustomObject]@{
        Mailbox                 = $MailboxName
        FullAccessPermissions   = ""
        SendAsPermissions       = ""
        SendOnBehalfPermissions = ""
    }

    # Fetch Full Access permissions (Read and Manage)
    $fullAccessPermissions = Get-MailboxPermission -Identity $MailboxName | Where-Object { $_.IsInherited -eq $false -and $_.User -ne 'NT AUTHORITY\SELF' }
    if ($fullAccessPermissions) {
        # Convert list of users to a comma-separated string
        $report.FullAccessPermissions = ($fullAccessPermissions | ForEach-Object { $_.User } | Select-Object -Unique | Sort-Object | ForEach-Object { $_.ToString() }) -join ", "
    }

    # Fetch Send As permissions
    $sendAsPermissions = Get-RecipientPermission -Identity $MailboxName | Where-Object { $_.AccessRights -contains 'SendAs' }
    if ($sendAsPermissions) {
        # Convert list of users to a comma-separated string
        $report.SendAsPermissions = ($sendAsPermissions | ForEach-Object { $_.Trustee } | Select-Object -Unique | Sort-Object | ForEach-Object { $_.ToString() }) -join ", "
    }

    # Fetch Send on Behalf Of permissions
    $sendOnBehalfPermissions = Get-Mailbox -Identity $MailboxName | Select-Object -ExpandProperty GrantSendOnBehalfTo
    if ($sendOnBehalfPermissions) {
        # Convert list of users to a comma-separated string
        $report.SendOnBehalfPermissions = ($sendOnBehalfPermissions | Select-Object -Unique | Sort-Object | ForEach-Object { $_.PrimarySmtpAddress }) -join ", "
    }

    # Return the report for the single mailbox
    return $report
}

# Main script
# Connect to Exchange Online
Connect-ExchangeOnline

# Define the mailbox for which to check permissions (replace with your mailbox name)
$mailboxName = "user@example.com"  # Replace with the actual mailbox name

# Get permissions report for the specified mailbox
$mailboxPermissionsReport = Get-SingleMailboxPermissionsReport -MailboxName $mailboxName

# Export the report to a CSV file
$csvFilePath = "MailboxPermissionsReport.csv"  # You can specify a different path if needed
$mailboxPermissionsReport | Export-Csv -Path $csvFilePath -NoTypeInformation

# Notify user about export completion
Write-Host "Mailbox permissions report exported to $csvFilePath"

# Disconnect the session after you're done
Disconnect-ExchangeOnline -Confirm:$false
