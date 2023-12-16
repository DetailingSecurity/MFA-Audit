Get-MsolUser -All |
    Where-Object {
        ($_.BlockCredential -eq $False) -and 
        ($_.islicensed -eq $true)
    } |
    Select-Object UserPrincipalName, 
                 FirstName, 
                 LastName, 
                 @{n='MFADefaultMethod';e={$_.StrongAuthenticationMethods | Where-Object { $_.IsDefault } | Select-Object -Expand MethodType}},
                 @{n='PhoneAppDetails';e={$_.strongauthenticationphoneappdetails | Select-Object -ExpandProperty DeviceName}},
                 @{n='MFAPhone#';e={$_.StrongAuthenticationUserDetails.PhoneNumber}} |
    Sort-Object -Property Userprincipalname |
    Export-Csv C:\temp\$(get-date -f yyyy-MM-dd)_MFAReport.csv