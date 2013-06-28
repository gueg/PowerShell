#Users into CSV file
#adding in a csv file
#ajout des recherches dans un fichier csv
$FilePath = "c:\people3.csv" 
$OuDomain = "OU=Damien,DC=test,DC=local,DC=damien,DC=fr"
Get-QADUser -sl 0 -searchRoot $OuDomain | select-Object Firstname, Mail, Description, Address, SamAccountName, Displayname, Location, logonscrip, Company, title, department, telephonenumber | Export-Csv $FilePath



