<#
.PSCRIPTNAME: deleteidlebranches.ps1
 
.DESCRIPTION: 
Git Calls to delete IDLE branches on DevOps Projects.
This script delete branches, it is a bad practice, so be careful how you use it.
 
.AUTHOR: 
Banji IKUYINMINU
 
.NOTES:
    Name            : deleteidlebranches.ps1
    Version         : 1.1
    Version History :
        1.0   28/11/2023 Latest Version.
#>
 


$subscriptionName = "XXXXX"
$organizationName = "XXXXX"
$projectName = "XXXXX"
$repoName = "XXXX"
$repositoryId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" #ReplaceIDperRepository
$repositoryPath = C:\Azcopy\repository #Set-Location

$repositoryURL = "https://$organizationName@dev.azure.com/$organizationName/$projectName/_git/$repoName" #ReplaceURLperTargettedRepository

# Authenticate to Azure DevOps
Connect-AzAccount -Subscription $subscriptionName
Start-Sleep -Seconds 5

#Check if Path has been initiated
if (!(Clone-Path -Path $repositoryPath)) {
    git clone $repositoryURL $repositoryPath
    Start-Sleep 10
} else {
    Set-Location -Path $repostoryPath
}

git init
git pull origin master


#Initialize an empty arrary to store the deleted branches
$deletedBranches = @()

# Define the array of branch names and their corresponding repository IDs - REPLACE THE FEATURE BRANCHES HERE.
$branchesToDelete = @(
    "features/rafa_c:$repositoryId",
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

    $deletedBranches += $branchName

    Write-Host "Branch '$branchName' in Repository '$repositoryId' deleted successfully."
}

#Write Out The Branches that were deleted.
Write-Host "Deleted branches: $($deletedBranches -join ',')"