<#
.Synopsis
    Grabs all permissions for a specified mailbox item

.Description
    Pulling detailed permissions from Exchange can be onerous. This function will quickly gather permissions and extended permissions for a specific user/mailbox.

.Parameter Mailbox
    Specify the mailbox to check permissions

.Example
    Example: Get-MailboxAccessRights -mailbox "johndoe"
#>
function Get-MailboxAccessRights {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$mailbox
    )

    $MailboxAccessRights = Get-mailbox -identity "*$mailbox*" | Get-MailboxPermission | Where-Object { $_.user -like "*mapeley*" -and $_.AccessRights -like "*FullAccess*"} | select User,AccessRights
    $extendedPermissions = Get-Mailbox -identity "*$mailbox*" | Get-ADPermission | Where-Object { $_.ExtendedRights -like "*send*" } | Where-Object {$_.user -like "*$mailbox*" } | select user,AccessRights

    Write-Output "Full Access Rights:"
    $MailboxAccessRights

    Write-Output "Extended Permissions"
    $extendedPermissions
}