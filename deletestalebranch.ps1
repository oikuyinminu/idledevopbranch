<#
.PSCRIPTNAME: deleteidlebranches.ps1
 
.DESCRIPTION: 
API Calls to get report on IDLE branches on DevOps Projects
This script delete branches, it is a bad practice, so be careful how you use it.
 
.AUTHOR: 
Banji IKUYINMINU
 
.NOTES:
    Name            : deleteidlebranches.ps1
    Version         : 1.0
    Version History :
        1.0   28/11/2023 Initial version.
#>
 

# Authenticate to Azure DevOps
Connect-AzAccount

Set-Location C:\Azcopy\repository #YouCanDefineYourPath

$organizationName = "XXXXX"
$projectName = "Power Platform Repos"
$repoName = "XXXX"

git clone https://$organizationName@dev.azure.com/$organizationName/$projectName/_git/$repoName #ReplaceURLperTargettedRepository

git init
git pull origin/master

$repositoryId = "9020ebda-f60c-4cc8-a69f-325edc04f175" #ReplaceIDperRepository

# Define the array of branch names and their corresponding repository IDs
$branchesToDelete = @(
    "features/119034_rafa:$repositoryId",
    "features/rafa:$repositoryId",
    "features/rafa_b:$repositoryId"
    # Add more branches and their repository IDs as needed
)

# Iterate through each branch in the array
foreach ($branchInfo in $branchesToDelete) {
    $branch = $branchInfo -split ':'
    $branchName = $branch[0]
    $repositoryId = $branch[1]

    # Delete the remote branch using Git commands
    $gitCommand = "git push origin --delete $branchName"
    Invoke-Expression $gitCommand

    Write-Host "Branch '$branchName' in Repository '$repositoryId' deleted successfully."
}
git push