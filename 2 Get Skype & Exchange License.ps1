#Create authentification object for the user
$credential = Get-Credential -UserName 'your login' -Message "Enter SPO credentials"

#Import Lync module
Import-Module LyncOnlineConnector

#Log in to Office 365 and register using the information provided to previously.
$session = New-CsOnlineSession -Credential $credential

#Import O365 user session in the current session
Import-PSSession $session -AllowClobber

#Initializing a persistent connection to Exchange
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRed

#Import Exchange user session in the current session
Import-PSSession $Session -AllowClobber

#Connect to Azure Active Directory with credentials 
Connect-MsolService -Credential $credential

#Get users with a license
$x = Get-MsolUser  | Where-Object {$_.isLicensed -eq "TRUE"} 


foreach ($i in $x)
    {
      #Getting information on the user's mailbox and store it in the object $i
      $y = Get-Mailbox -Identity $i.UserPrincipalName
      Write-Host $i.UserPrincipalName
      If($y)
      {
        #Adding the information IsMailboxEnabled in the object $i
        $i | Add-Member -MemberType NoteProperty -Name IsMailboxEnabled -Value $y.IsMailboxEnabled
      }

      #Retrieving information about the Lync account of the user stored in the object $i
      $y = Get-CsOnlineUser -Identity $i.UserPrincipalName

      #Adding the information  EnabledForSkype in the object $i
      $i | Add-Member -MemberType NoteProperty -Name EnabledForSkype -Value $y.Enabled
    }

#Display informations obtained above
$x | Select-Object DisplayName, PrimaryEmailAddress, IsLicensed, IsMailboxEnabled, EnabledForSkype | Sort-Object DisplayName| Export-Csv "your path\file.csv" -Delimiter ";"