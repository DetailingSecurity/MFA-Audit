Get-MsolUser -All |
    Where-Object {
        ($_.BlockCredential -eq $False) -and 
        ($_.islicensed -eq $true)
    } |
    Select-Object UserPrincipalName, 
                 FirstName, 
                 LastName |
    Sort-Object -Property Userprincipalname |
    Export-Csv C:\temp\$(get-date -f yyyy-MM-dd)_CurrentUsers.csv