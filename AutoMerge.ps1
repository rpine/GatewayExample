Import-Module "./Branch-Menu.psm1";
Get-Command -Module "Function-Use-Branch-Menu";

function hardReset($msg, $branch)
{
	Write-Host $msg -ForegroundColor Red
	git reset --hard
}

function doesLocalBranchExist($branch)
{
	$localBranch = (git branch --list $branch)
	if ($localBranch)
	{
		return $true
	}
	else 
	{
		return $false
	}
		
}

function doesRemoteBranchExist($branch)
{
	$remoteBranch = (git ls-remote --heads origin $branch)
	if ($remoteBranch)
	{
		return $true
	}
	else 
	{
		return $false
	}
}


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
	Write-Host 'Working on branch: ', $branch -ForegroundColor DarkGreen
    #Test to check if branch exists remotely 
    $exists = doesRemoteBranchExist($branch)
    if($exists)
	{
		Write-Host 'The branch exists remotely: ', $branch
 	}
	$localExists = doesLocalBranchExist($branch)
    if($localExists)
	{
		Write-Host 'The branch exists locally: ', $branch
 	}

	git checkout $branch
	git branch --list graph*
	git merge $selectedBranch
	$gruntResult = grunt build
	Write-Host 'Grunt task result: ', $gruntResult, ' Exit Code: ', $LastExitCode -ForegroundColor Blue
	if ($LastExitCode -ne 0)
	{
		hardReset('Grunt Task Failed. ', $branch)
		$FailedMerges += $branch
		continue	
	}
	
	$workingfiles = git status --porcelain
	if ($workingfiles)
	{
		hardReset('working folder not empty', $branch)
		$FailedMerges += $branch
	}
	else
	{
		Write-Host 'working folder empty, merge succeeded' -ForegroundColor DarkGreen
		git commit -a -m "Automated commit message."
		git push --set-upstream origin $branch
	}
		
}
foreach ($b in $FailedMerges)
{
	Write-Host 'Merge failed for:', $b -ForegroundColor Red
}
Write-Host '--------------Finished------------------' 

