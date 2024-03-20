# Path to the folder containing the CSV files
$folderPath = "C:\temp\ASPI\csv\test"

# Path to the output merged CSV file
$outputCSV = "C:\temp\ASPI\csv\merged_file.csv"

# Get all CSV files in the folder
$csvFiles = Get-ChildItem -Path $folderPath -Filter *.csv | ForEach-Object { $_.FullName }

# Initialize an empty array to store the content of all CSV files
$mergedContent = @()

# Read the content of each CSV file and add it to the mergedContent array
foreach ($csvFile in $csvFiles) {
    $content = Get-Content $csvFile
    $mergedContent += $content
}

# Write the merged content to the output CSV file
$mergedContent | Set-Content $outputCSV

Write-Host "Merged CSV file saved to: $outputCSV"
