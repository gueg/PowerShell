#****************************************************************************************#
#ce script permet de recuperer le nombre de ports sur des equipements switchs CatOS / IOS#
#ce script ecrit 4 fichiers dans un repertoire choisis par l user                        #
#@damien gueganic LinkedIn :  http://fr.linkedin.com/pub/damien-gueganic/58/359/39       #
#@damien gueganic Viadeo : http://fr.viadeo.com/fr/profile/damien.gueganic				       #
#****************************************************************************************#

clear
#fonction explorateur du fichier 
Function Get-FileName($initialDirectory)
{  
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename

}
#Fonction d enregistrement des fichiers / ecrit les fichiers dans ce repertoire
Function Select-FolderDialog
{
    param([string]$Description="Select Folder",[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
     Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $objForm.SelectedPath
        }
        Else
        {
            Write-Error "Operation interrompue par l utilisateur."
        }
    }

#fonction cisco IOS
function cisco-ios {
#parametres commandes
$comis = "term len 0"
$comio2 = "sh int status"
$writer.WriteLine($comis)
$writer.Flush()
Start-Sleep -m 500
$writer.WriteLine($comio2)
$writer.Flush()
}
#fonction cisco catos
function cisco-catos {
#parametres commandes
$comis = "set len 0"
$comio2 = "sh port status "
$writer.WriteLine($comis)
$writer.Flush()
Start-Sleep -m 500
$writer.WriteLine($comio2)
$writer.Flush()
}

#initialisation de la variable de stream 
[string] $output = ""
## fonction de log / sortie des datas de la stream
function GetOutput
{
    ## Create a buffer to receive the response
    $buffer = new-object System.Byte[] 1024
    $encoding = new-object System.Text.AsciiEncoding

    $outputBuffer = ""
    $foundMore = $false

    ## ecrit toutes les donnes disponibles dans la socket cree
    ## sortie du buffer quand c est ok
    do
        {
        
        start-sleep -m 1000

        ## lit toutes les donnees disponibles dans la stream
        $foundmore = $false
        $stream.ReadTimeout = 1000

            do
            {
                 try
                {
                    $read = $stream.Read($buffer, 0, 1024)

                    if($read -gt 0)
                        {
                        $foundmore = $true
                        $outputBuffer += ($encoding.GetString($buffer, 0, $read))
                        }
                    } catch { $foundMore = $false; $read = 0 }
                } while($read -gt 0)
             } while($foundmore)

        $outputBuffer
}

function main 
{
$folder1 = Select-FolderDialog 
$file1 = Get-FileName -initialDirectory "c:\"
if (test-path $file1 -include *.txt)
    { echo "Fichier d import OK"}
    else { echo "Extension FAUSSE"; exit}

    $ipios = Gc $file1
    #paramtres passw securises
    $pass = Read-Host "Entrer mot de passe telnet : " -AsSecureString
    $decpass= [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
    $pass2 = Read-Host "Entrer mot de passe enable :" -AsSecureString
    $decpass2= [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass2))
                        
     foreach ($ips in $ipios)
        {
            if (Test-Connection $ips -Quiet)
                {

                $SCRIPT:output += GetOutput
                $socket = New-Object System.Net.Sockets.TcpClient
                $socket.Connect($ips, 23)
                $stream = $socket.GetStream()
                $writer = New-Object System.IO.StreamWriter $stream
                $writer.WriteLine($decpass)
                $writer.Flush()
                $writer.WriteLine("enable")
                $writer.Flush()
                Start-Sleep -m 500
                $writer.WriteLine($decpass2)
                $writer.Flush()
                Start-Sleep -m 500

             #   #selection des equipements catos / ios :   #
                cisco-catos

                $SCRIPT:output += GetOutput
                $writer.Close()
                $stream.Close()
				        #conversion des @ip en noms DNS 
                $name = [System.Net.Dns]::GetHostByAddress($ips).HostName
                $output > $folder1\log-shintstat.txt
				
                #ports sur le vlan 4 :
                #$a = Get-Content $folder1\log-shintstat.txt | Select-String -Pattern " 4 " -CaseSensitive 
                #nombre ports total :
                #$a = Get-Content $folder1\log-shintstat.txt | Select-String -Pattern "normal" -CaseSensitive  
				
                $a >> $folder1\liste-detail.txt
                $a > $folder1\3.txt
                $b = (Get-Content $folder1\3.txt | Measure-Object -line -word -character);
                echo ($name + " possede " + $b.Lines + " ports ") >> $folder1\liste-detail.txt
                echo ($name + " ; " + $b.Lines ) >> $folder1\liste.xls
                echo "_______________________________________________________________________________" >> $folder1\liste-detail.txt
                $output=""
                rm $folder1\log-shintstat.txt 
                }
                
    
             else {
                    echo "Connexion KO" pour $ips >> $folder1\connexion-ko.txt
                  }
       
            }
            
 }
. main


