# This script retrieve all users of a group, this group is located in a CSV file
#ce script retrouve tous les utilisateurs d un groupe, les groupes sont preceises dans un fichier csv
# The list of DN of groups must be located here => C:\temp\group.csv
# Result Stores into => C:\temp\group-members.csv
$start = (get-date).datetime |   %{ $_.Split(' ')[3]}
"Script is Starting"
$groups = Get-Content C:\temp\group.csv
#Get the number of lines of the text file
$lengthuser = Get-Content C:\temp\group.csv | Measure-Object -line;
#Creating a file to contain the members of groups
#$file = [System.IO.File]::CreateText("C:\Groups\group-members-v1.csv")
$file = "C:\temp\group-members.csv"
echo "" > $file
"Queries and Formatting"
for($i = 0 ;$i -lt $lengthuser.lines ; $i++) 
{
        #Formatting the groups informations
        $_groups = $groups[$i]|  %{ $_.Split(',')[0] }
        $_groups = $_groups -replace ("`"CN=", "asuwant/");
   
        #Retrieving the members of each groups
        $members = dsget group $groups[$i] -members -l
    
        #Formatting the members informations
        $members = $members |  %{ $_.Split(',')[0] }
        $members = $members -replace ("`"CN=", "")
     
        #Unfolding
        "-------"
        $_groups
       "-------"
        $members
        $var = "$_groups;"
      
        #Write all members of this group
        foreach($user in $members){
      
            $user_firstname = $user | %{$_.Split(' ')[1]}
            $user_lastname = $user | %{$_.Split(' ')[0]} 
            $user_3 = $user | %{$_.Split(' ')[2]}
            

            if($user_3 -like "(*"){    
                if($user_firstname -notlike ""){$user1 = $user_firstname+"."+$user_lastname}
                else { $user1 = $user_lastname}
            }
            if($user_3 -like ""){    
                if($user_firstname -notlike ""){$user1 = $user_firstname+"."+$user_lastname}
                else { $user1 = $user_lastname}
            }
            if($user1 -notlike ""){$users = $users + $user1+";"}
        }
        echo "$var$users" >> $file;
        $users = "";       
        #Unfolding
        "Number: "+$i+" finished"
}
$end=(get-date).datetime | %{ $_.Split(' ')[3]}
"Started :"+$start+" Finished : "+$end;
