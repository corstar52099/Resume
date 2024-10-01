# Get the directory of the script (assumed to be the current working directory)
$repoDir = Get-Location

# Get the most recent .docx and .pdf files based on LastWriteTime
$docxFileNew = Get-ChildItem -Path $repoDir -Filter *.docx | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$pdfFileNew = Get-ChildItem -Path $repoDir -Filter *.pdf | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Check if files exist
if (-Not $docxFileNew) {
    Write-Host "No .docx file found!" -ForegroundColor Red
    exit 1
}
if (-Not $pdfFileNew) {
    Write-Host "No .pdf file found!" -ForegroundColor Red
    exit 1
}

# Find the older .docx and .pdf files by skipping the latest (only delete if there's more than 1 file of each type)
$docxFileOld = Get-ChildItem -Path $repoDir -Filter *.docx | Sort-Object LastWriteTime -Descending | Select-Object -Skip 1
$pdfFileOld = Get-ChildItem -Path $repoDir -Filter *.pdf | Sort-Object LastWriteTime -Descending | Select-Object -Skip 1

# Stage the new files for Git
git add $docxFileNew.FullName
git add $pdfFileNew.FullName

# Delete old files from Git (if any exist)
if ($docxFileOld) {
    foreach ($file in $docxFileOld) {
        git rm $file.FullName
    }
}
if ($pdfFileOld) {
    foreach ($file in $pdfFileOld) {
        git rm $file.FullName
    }
}

# Add the current script to the repository
$scriptPath = $MyInvocation.MyCommand.Definition
git add $scriptPath

# Commit all changes
$commitMessage = "Update to latest .docx and .pdf, remove old files, and include script"
git commit -m $commitMessage

# Push the changes to the remote repository
git push

Write-Host "Successfully updated files, removed old versions, and committed the script."
