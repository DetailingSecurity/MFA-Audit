
# MFA-Audit

Deploying MFA to an organization can be difficult. Auditing MFA across an organization can also be difficult. I built this to make it easier.
You will find two PowerShell scripts and one excel file. By following this process you will generate two CSV files and use the provided Excel worksheet to determine who has not enrolled.

**Please note this assumes user UPNs are the same as the user email addresses**

The two PowerShell scripts will generate the following CSV files:
1. A list of all active user accounts with Microsoft licenses that includes their User Principal Name, First Name, Last Name, and Email Address.
2. A list of all active user accounts that are licensed and enrolled in MFA including their User Principal Name, First Name, Last Name, default MFA method (SMS, Phone App Notification, OTP, or Phone Call), associated MFA devices, and MFA Phone Number.

# Prerequisites

To follow this guide, you will need the following:
- A computer with PowerShell installed.
- The MSOnline module installed in PowerShell.
- An account with the proper privileges in Azure.
- Excel.

# Process
## Part 1: Create list of all active users
1. Open PowerShell as admin.
2.  Connect to the tenant and sign in.
```powershell
Connect-MsolService
```
3. Copy and paste the following code. Make any edits ahead of time if you need to. You can also run the script (MFA-Audit.ps1) as a file.
```powershell
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
```
4. Make note of the CSV you just created as we will come back to it.

## Part 2: Export MFA Details
1. Open PowerShell as admin.
2. Connect to the tenant and sign in.
```powershell
Connect-MsolService
```
3. Copy and paste the following code. Make any edits ahead of time if you need to. You can also run the script as a file.
```powershell
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
```
4. Make note of this CSV as well. We're about to need it.

## Part 3: Compare the two lists
**Please note that you will need to expand 
- Download and open the supplied excel workbook, "MFA Report Template".
- Now open the CurrentUsers.csv we just made.
- Select all data EXCEPT the headers/first row.
- Copy and paste that information to the table on the User List tab in the MFA Report document.
- Switch to the Overview tab. Column A should auto populate. If it doesn't go down all the way, you'll need to grab the bottom corner of the last cell in which the data did populate and drag down until the number of rows on the Overview tab is the same and the number of rows in the User List tab.
- Open the MFAReport.csv file we made.
- Select all data EXCEPT the headers/first row.
- Copy and paste that information to the table on the MFA Details tab in the MFA Report document.
- Switch back to the Overview tab.
- The Enrolled in MFA column should now indicate whether or not that person is enrolled in MFA and the Default Method column should display the default method used for MFA.