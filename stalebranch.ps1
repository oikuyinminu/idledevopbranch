<#
.PSCRIPTNAME: idlebranches.ps1
 
.DESCRIPTION: 
API Calls to get report on IDLE branches on DevOps Projects
This script does not delete branches, as it is a bad practice, but gives report on idle branches
 
.AUTHOR: 
Banji IKUYINMINU
 
.NOTES:
    Name            : idlebranches.ps1
    Version         : 1.0
    Version History :
        1.0   14/11/2023 Initial version.
#>
 
 
$pat = "XXXXXX"
$organizationName = "XXXXX"
$projectName = "Power Platform Repos"
$apiVersion = "7.1-preview.1"
 

# Define the URL to get the list of repositories
$reposUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/git/repositories?api-version=$apiVersion"
$headers = @{
    Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
}
# Retrieve the list of repositories
$reposResponse = Invoke-RestMethod -Uri $reposUrl -Headers $headers -Method Get
# Create an array to store the results
$results = @()
# Iterate over each repository
foreach ($repository in $reposResponse.value) {
    $repositoryId = $repository.id
    $repositoryName = $repository.name
    # Define the URL to get the branch information for the repository
    $branchUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/git/repositories/$repositoryId/refs?api-version=$apiVersion"
    # Retrieve branch information
    $branchResponse = Invoke-RestMethod -Uri $branchUrl -Headers $headers -Method Get
    $cutOffDate = (Get-Date).AddDays(-181)
    $branchResponse.value | ForEach-Object {
        $branchName = $_.name -replace '^refs/heads/', ''  # Remove the prefix
        # Define the URL to get the commit information for the branch
        $commitUrl = "https://dev.azure.com/$organizationName/$projectName/_apis/git/repositories/$repositoryId/commits?searchCriteria.itemVersion.version=$branchName&api-version=$apiVersion"
        $commitResponse = Invoke-RestMethod -Uri $commitUrl -Headers $headers -Method Get
        # Check if there are commits for the branch before accessing the first one
        if ($commitResponse.value -ne $null -and $commitResponse.value.Count -gt 0) {
            $latestCommit = $commitResponse.value[0]  # Assumes the first commit is the latest
            $commitDate = [DateTime]::Parse($latestCommit.committer.date)
            $committerName = $latestCommit.committer.name  # Get the committer's name
            # Create an object with the result
            $result = [PSCustomObject]@{
                RepositoryId = $repositoryId
                RepositoryName = $repositoryName
                BranchName = $branchName
                LastCommitDate = $commitDate
                CommitterName = $committerName  # Add the committer's name to the result
                IsOlderThan6Months = $commitDate -lt $cutOffDate
            }
            # Add the result to the array
            $results += $result
        } else {
            # Create an object with the result (no commits)
            $result = [PSCustomObject]@{
                RepositoryId = $repositoryId
                RepositoryName = $repositoryName
                BranchName = $branchName
                LastCommitDate = $null
                CommitterName = $null  # Set the committer's name to null when no commits
                IsOlderThan6Months = $false
            }
            # Add the result to the array
            $results += $result
        }
    }
}
# Output the results to a CSV file
$results | Export-Csv -Path "C:Path\to\save\Power_Platform_Repos.csv" -NoTypeInformation