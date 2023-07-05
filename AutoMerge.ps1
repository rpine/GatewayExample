Import-Module "./Branch-Menu.psm1";
Get-Command -Module "Function-Use-Branch-Menu";
git checkout dev.updates
#$frombranch = (
#    git branch --all |
#    Where-Object { $_ -notmatch "->" } |
#    ForEach-Object {$_.substring(2)} |
#    Out-GridView -Title "$project`: Select a branch to build" -OutputMode Single
#)
#Write-Host 'Selected branch: ', $frombranch -ForegroundColor Green

$selectedBranch = Use-Branch-Menu 'Select a source branch to merge'
$selectedBranch = $selectedBranch.replace('*','').Trim()
Write-Host 'Selected branch from menu: ', $selectedBranch -ForegroundColor Green
git checkout $branch
git pull


$branches = (git branch --list graph*)
$FailedMerges = @()
foreach ($b in $branches)
{
	$branch = $b.replace('*','').Trim()
	#$branch = $branch.Trim()
	Write-Host 'Working on branch: ', $branch -ForegroundColor DarkGreen
	git checkout $branch
	git branch --list graph*
	git merge $selectedBranch
	$workingfiles = git status --porcelain
	if ($workingfiles)
	{
		Write-Host 'working folder not empty' -ForegroundColor Red
		$FailedMerges += $branch
	}
	else
	{
		Write-Host 'working folder empty, merge succeeded' -ForegroundColor DarkGreen
		git commit -a -m "Automated commit message."
		git push --set-upstream origin $branch
	}
		
}
Write-Host '----------------------------------------' 
foreach ($b in $FailedMerges)
{
	Write-Host 'Merge failed for:', $b -ForegroundColor Red
}
