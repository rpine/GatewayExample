using namespace System.Management.Automation.Host

function Use-Branch-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title
    )
    
	$allbranches = (git branch --list)
	
	Clear-Host
	Write-Host "================= $Title ===================="
	$I = 0
	foreach($b in $allbranches)
	{
		Write-Host $I, " : " , $b.Trim() 
        $I++    		
	}
	
	$selection = Read-Host "Please make a selection"

    $result = $allbranches[[int]$selection]
	return $result

}