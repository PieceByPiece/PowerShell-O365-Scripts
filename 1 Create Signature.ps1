#Create authentification object for the user
$credential = Get-Credential -UserName 'your login' -Message "Enter SPO credentials"

#Initializing a persistent connection to Exchange
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRed

#Import of the session in the current session
Import-PSSession $Session -AllowClobber

#Connect to Azure Active Directory with credentials 
Connect-MsolService -Credential $credential

#########################################################################################################################

#Save directory for my signatures
$save_location = "your save path"

#Get all users 
$users = Get-MsolUser 
 
foreach ($user in $users) {
 
  $DisplayName= “$($user.DisplayName)”
  $title = "$($User.Title)"
  $MobilePhone = "$($User.MobilePhone)"
  $UserPrincipalName = "$($User.UserPrincipalName)"

  #Create and save personnal signature in HTML
  $output_file = $save_location + $DisplayName + ".html"
  Write-Host "Création de la signature au format html pour " $DisplayName
   "<span style=`"font-family: calibri,sans-serif;`"><strong>" + $DisplayName + "</strong><br />", $title + " - " + $MobilePhone + "<br />", $UserPrincipalName + "<br />", "</span><br />"| Out-File $output_file
}

# Get user by DisplayName
$Myuser = Get-MsolUser  | Where-Object {$_.DisplayName -eq "user display name"}
$MyuserDisplayName= “$($Myuser.DisplayName)”

#Assign signature to the previously selected user using the HTML file
$output_file_user = $save_location + $MyuserDisplayName + ".html"
$signHTML = (Get-Content $output_file_user)
Set-MailboxMessageConfiguration –Identity $Myuser.UserPrincipalName -AutoAddSignature $True  -SignatureHtml   $signHTML

##################################################################################################################################################################################################################
#Log out of Office 365
get-PSSession | remove-PSSession