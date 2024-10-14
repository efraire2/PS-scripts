# File Path: Get-AllMailboxPermissionsReport.ps1


# Function to get mailbox permissions for all user and shared mailboxes
function Get-AllMailboxPermissionsReport {
    # Fetch all user and shared mailboxes excluding distribution lists and groups
    $mailboxes = Get-Mailbox -RecipientTypeDetails UserMailbox, SharedMailbox -ResultSize Unlimited

    # Prepare a collection to store results
    $report = @()

    # Loop through each mailbox to get permissions
    foreach ($mailbox in $mailboxes) {
        $mailboxName = $mailbox.PrimarySmtpAddress

        # Prepare an object to store the report for the mailbox
        $reportEntry = [PSCustomObject]@{
            Mailbox                 = $mailboxName
            FullAccessPermissions   = ""
            SendAsPermissions       = ""
            SendOnBehalfPermissions = ""
        }

        # Fetch Full Access permissions (Read and Manage)
        $fullAccessPermissions = Get-MailboxPermission -Identity $mailboxName | Where-Object { $_.IsInherited -eq $false -and $_.User -ne 'NT AUTHORITY\SELF' }
        if ($fullAccessPermissions) {
            # Convert list of users to a comma-separated string
            $reportEntry.FullAccessPermissions = ($fullAccessPermissions | ForEach-Object { $_.User } | Select-Object -Unique | Sort-Object | ForEach-Object { $_.ToString() }) -join ", "
        }

        # Fetch Send As permissions
        $sendAsPermissions = Get-RecipientPermission -Identity $mailboxName | Where-Object { $_.AccessRights -contains 'SendAs' }
        if ($sendAsPermissions) {
            # Convert list of users to a comma-separated string
            $reportEntry.SendAsPermissions = ($sendAsPermissions | ForEach-Object { $_.Trustee } | Select-Object -Unique | Sort-Object | ForEach-Object { $_.ToString() }) -join ", "
        }

        # Fetch Send on Behalf Of permissions
        $sendOnBehalfPermissions = Get-Mailbox -Identity $mailboxName | Select-Object -ExpandProperty GrantSendOnBehalfTo
        if ($sendOnBehalfPermissions) {
            # Convert list of users to a comma-separated string
            $reportEntry.SendOnBehalfPermissions = ($sendOnBehalfPermissions | Select-Object -Unique | Sort-Object | ForEach-Object { $_.PrimarySmtpAddress }) -join ", "
        }

        # Add the entry to the report collection
        $report += $reportEntry
    }

    # Return the full report
    return $report
}

# Main script
# Connect to Exchange Online
Connect-ExchangeOnline

# Get permissions report for all user and shared mailboxes (excluding distribution lists/groups)
$mailboxPermissionsReport = Get-AllMailboxPermissionsReport

# Export the report to a CSV file
$csvFilePath = "C:\Temp\csv\AllMailboxPermissionsReport.csv"  # You can specify a different path if needed
$mailboxPermissionsReport | Export-Csv -Path $csvFilePath -NoTypeInformation

# Notify user about export completion
Write-Host "Mailbox permissions report exported to $csvFilePath"

