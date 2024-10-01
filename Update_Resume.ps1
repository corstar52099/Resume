param (
    [string]$m   # commit message
)

# Define the target filenames for the new files
$newFileBaseName = "Cory Starks Resume"
$newDocxFile = "$newFileBaseName.docx"
$newPdfFile = "$newFileBaseName.pdf"
$scriptFile = $MyInvocation.MyCommand.Name  # Get the name of the script itself

# Identify the most recently modified .docx and .pdf files in the current directory
$latestDocx = Get-ChildItem -Filter "*.docx" | Where-Object { $_.Name -ne $scriptFile } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latestPdf = Get-ChildItem -Filter "*.pdf" | Where-Object { $_.Name -ne $scriptFile } | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Check if both .docx and .pdf files were found
if (-not $latestDocx -or -not $latestPdf) {
    Write-Host "Error: Could not find the latest .docx and/or .pdf files." -ForegroundColor Red
    exit 1
}

# Find and delete older versions of the files (based on modification date)
$olderDocxFiles = Get-ChildItem -Filter "*.docx" | Where-Object { $_.FullName -ne $latestDocx.FullName }
$olderPdfFiles = Get-ChildItem -Filter "*.pdf" | Where-Object { $_.FullName -ne $latestPdf.FullName }

foreach ($file in $olderDocxFiles + $olderPdfFiles) {
    Write-Host "Deleting old file: $($file.FullName)" -ForegroundColor Yellow
    Remove-Item $file.FullName -Force
    git rm $file.FullName  # Remove from Git as well
}

# Rename the new files to "Cory Starks Resume"
Rename-Item $latestDocx.FullName $newDocxFile -Force
Rename-Item $latestPdf.FullName $newPdfFile -Force

# Add the new files and the script itself to Git
git add $newDocxFile
git add $newPdfFile
git add $scriptFile  # Add the script itself to the repository

# Commit the changes
git commit -m $m

# Push the changes to the remote repository
git push

Write-Host "Successfully updated and pushed $newDocxFile, $newPdfFile, and the script to the repository."
