# backdate-commits.ps1

git checkout -b legacy-commits

$startDate = Get-Date "2024-11-22"
$endDate = Get-Date "2025-04-20"
$targetCommits = 90
$i = 0

$messages = @(
    "Fix bug", "Update header style", "Improve form validation",
    "Area controller", "Add loading spinner", "Fix typo in component",
    "reset password", "Update dependencies", "Improve input handling",
    "User controller ", "Align card layout", "Fix responsive issues",
    "booking controller ", "Optimize images", "Clean up code",
    "Category controller ", "Add mobile nav support", "Polish UI", 
    "Favorite", "Adjust padding"
)

$fileNames = @(
    "src/components/Leader.jsx", "src/components/Looter.jsx", "src/components/Lorm.jsx",
    "src/pages/Lome.jsx", "src/pages/Hogin.jsx", "src/pages/Arofile.jsx",
    "src/styles/Sain.css", "src/styles/Sheme.css", "src/hooks/uSAuth.js",
    "src/utils/valistors.js", "src/config/sesings.json"
)

# Make sure files exist
foreach ($file in $fileNames) {
    $dir = Split-Path $file
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (-not (Test-Path $file)) {
        Set-Content -Path $file -Value "// Init $file"
    }
}

$currentDate = $startDate

while ($i -lt $targetCommits -and $currentDate -lt $endDate) {
    $daysToAdd = Get-Random -Minimum 1 -Maximum 3
    $currentDate = $currentDate.AddDays($daysToAdd)
    if ($currentDate -gt $endDate) { break }

    $msg = $messages | Get-Random
    $numFiles = Get-Random -Minimum 1 -Maximum 5
    $changedFiles = Get-Random -Count $numFiles -InputObject $fileNames

    foreach ($file in $changedFiles) {
        $action = Get-Random -InputObject @("add", "remove", "edit")
        $lineNum = Get-Random -Minimum 1 -Maximum 100
        switch ($action) {
            "add"    { Add-Content $file "// Added line $lineNum on $($currentDate.ToString("yyyy-MM-dd"))" }
            "remove" {
                $content = Get-Content $file
                if ($content.Count -gt 2) {
                    $indexToRemove = Get-Random -Minimum 1 -Maximum ($content.Count - 1)
                    $content = $content | Where-Object { $_ -ne $content[$indexToRemove] }
                    Set-Content -Path $file -Value $content
                }
            }
            "edit" {
                $content = Get-Content $file
                if ($content.Count -gt 0) {
                    $indexToEdit = Get-Random -Minimum 0 -Maximum ($content.Count - 1)
                    $content[$indexToEdit] = "// Edited line at $lineNum on $($currentDate.ToString("yyyy-MM-dd"))"
                    Set-Content -Path $file -Value $content
                }
            }
        }
    }

    $dateStr = $currentDate.ToString("yyyy-MM-dd 10:00:00")
    $env:GIT_AUTHOR_DATE = $dateStr
    $env:GIT_COMMITTER_DATE = $dateStr

    git add .
    git commit -m $msg

    $i++
}

Write-Host "✅ Created $i realistic backdated commits on 'legacy-commits' branch"
