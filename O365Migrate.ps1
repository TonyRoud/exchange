$output = Powershell {
    import-module MSonline

    C:\Windows\Sysnative\WindowsPowershell\v1.0\Powershell.exe -NonInteractive -Command {

        # SCOrch specific UPNs relating to input variables
        $UPN = "\`d.T.~Ed/{F2149A68-14F2-4AF0-9B9A-90CA4442CE6F}.{17283BDD-B62B-491F-A60D-051E87CE3184}\`d.T.~Ed/"
        $TenantUname = "\`d.T.~Vb/{1F992A78-7CD0-444B-B5BB-4DAD631E5D02}\`d.T.~Vb/"
        $TenantPass = "\`d.T.~Vb/{1BB8CE1A-ACAA-49F7-9221-2D13CF7D6416}\`d.T.~Vb/"

        # Grab user creds and connect to MSOnline
        $securePass = $TenantPass | ConvertTo-SecureString -AsPlainText -Force
        $Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $TenantUname, $securePass
        Connect-MsolService -Credential $credential

        # Check If user exists on O365
        $timeout = new-timespan -hour 3
        $sw = [diagnostics.stopwatch]::StartNew()

        while ($sw.elapsed -lt $timeout){

            $FindUser = get-msoluser -UserPrincipalName $UPN | Select-Object userprincipalname -ErrorAction SilentlyContinue

            if ($Finduser -match $UPN){

                $UserExists = "True"

                start-sleep -seconds 300

                # Apply License To user
                Set-MsolUser -UserPrincipalName $UPN -UsageLocation GB
                Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses $licenses

                # Enable User for MFA
                $auth = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
                $auth.RelyingParty = "*"
                $auth.state = "Enforced"
                set-msoluser -UserPrincipalName $UPN -StrongAuthenticationRequirements $auth

                # Disable Yammer
                $Options = New-MsolLicenseOptions –AccountSkuId scottish4:ENTERPRISEPACK –DisabledPlans YAMMER_ENTERPRISE
                Set-MsolUserLicense –UserPrincipalName $UPN –LicenseOptions $Options

                $O365Report = Get-MsolUser -UserPrincipalName $UPN | Select-Object userprincipalname,islicensed,strongauthenticationrequirements

                #### Loop to continue to next stage once mailbox is available to migrate

                $timeout2 = new-timespan -hour 2
                $sw2 = [diagnostics.stopwatch]::StartNew()

                while ($sw2.elapsed -lt $timeout2){
                    $CheckProvStatus = get-msoluser -UserPrincipalName $UPN | Select-Object OverallProvisioningStatus -ErrorAction SilentlyContinue

                    if ($CheckProvStatus -match "Success"){

                        $ProvStatusSuccess = "True"
                        start-sleep -seconds 60

                        Return
                    }
                    $ProvStatusSuccess = "False"
                    start-sleep -seconds 60
                    $CheckProvStatus = get-msoluser -UserPrincipalName $UPN | Select-Object OverallProvisioningStatus -ErrorAction SilentlyContinue
                }
            $ProvStatusSuccess = "Timeout"
            ### Complete loop
            Return
        }
        $UserExists = "False"
        start-sleep -seconds 60
        $FindUser = get-msoluser -UserPrincipalName $UPN | Select-Object userprincipalname -ErrorAction SilentlyContinue
        }
    $UserExists = "Timeout"
    }
}