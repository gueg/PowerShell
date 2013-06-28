#script adding users from a csv file
Add-PSSnapin Quest.ActiveRoles.ADManagement
clear
$strExcelFile = "C:\Documents and Settings\damien.gueganic\Desktop\mike_scrpt\users-add-from-excel\users3.xls"
$objExcel = New-Object -ComObject Excel.Application 
$objExcel.Visible = $True
$objWorkbook = $objExcel.Workbooks.Open($strExcelFile)
$row = 2
$parent = 'OU=users,OU=Developement,DC=damien,DC=test,DC=local,DC=fr'
do 
    {
        $Firstname = $objExcel.Cells.Item($row,1).Value()
        $Firstname2 = $objExcel.Cells.Item($row,1).Value()
		$password = $objExcel.Cells.Item($row,2).Value()
        $Lastname = $objExcel.Cells.Item($row,3).Value()
		$Displayname = $objExcel.Cells.Item($row,4).Value()
		$Office = $objExcel.Cells.Item($row,5).Value()
		$Street = $objExcel.Cells.Item($row,6).Value()
		$City = $objExcel.Cells.Item($row,7).Value()
		$Zippostalcode = $objExcel.Cells.Item($row,8).Value()
		$IPphone = $objExcel.Cells.Item($row,9).Value()
		$Company = $objExcel.Cells.Item($row,10).Value()
        $name = $objExcel.Cells.Item($row,11).Value()
        New-QADuser -ParentContainer $parent -samaccountname $FirstName -Name $name -FirstName $Firstname -LastName $Lastname -MobilePhone $IPphone -UserPassword $password -City $City -Company $Company -Office $Office -DisplayName $Displayname -PostalCode $Zippostalcode -PhoneNumber $IPphone
        $row++
    } 
until ($name -eq $Null)
$objExcel.Quit()
clear
$Null = & {
    [Runtime.Interopservices.Marshal]::ReleaseComObject($objExcel)
    [Runtime.Interopservices.Marshal]::ReleaseComObject($objWorkbook)
    }
	echo Users add : 
	Get-QADUser -SearchRoot $parent 
[GC]::Collect()


