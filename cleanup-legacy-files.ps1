# cleanup-legacy-files.ps1

# Make sure we're on the right branch
git checkout legacy-commits

# Files to remove
$fileNames = @(
    "src/components/Leader.jsx", "src/components/Looter.jsx", "src/components/Lorm.jsx",
    "src/pages/Lome.jsx", "src/pages/Hogin.jsx", "src/pages/Arofile.jsx",
    "src/styles/Sain.css", "src/styles/Sheme.css", "src/hooks/uSAuth.js",
    "src/utils/valistors.js", "src/config/sesings.json"
)

# Remove each file if it exists
foreach ($file in $fileNames) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "🗑️ Deleted $file"
    }
}

# Stage deletions and commit
git add -A
git commit -m "Cleanup: removed legacy files used for history simulation"

Write-Host "✅ Legacy files deleted and cleanup commit created on 'legacy-commits'"
