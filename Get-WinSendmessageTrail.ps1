<#
.Synopsis
    Function for pulling messages from sendmail logs

.Description
    Searches sendmail logfiles with a regex match for a specific subject, then return all associated messages.

.Parameter email
    Seach pattern to match within emails

.Parameter logfile
    Sepcify the maillog you

.Example
    Example: Get-SendMailTrail -logfile 10052016 -pattern 'invoices'
#>
function Get-SendmailTrail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,position=1)][string]$email,
        [Parameter(position=2)][string]$logfile
    )

    $maillog = Get-ChildItem maillog* | Select-String -Pattern $email

    foreach ($line in $maillog)
    {
        $subject = ""
        $subject += [regex]::match($line, '(?<=\()[a-z,A-Z,0-9]{14}(?=\sM)').Value
        $subject
        # Get-ChildItem maillog* | Select-String -Pattern $subject | out-host
    }

    foreach ($entry in $subject)
    {
        if ($entry)
        {
            Write-Output $entry; Get-ChildItem maillog* | Select-String -Pattern $entry
        }
    }
}