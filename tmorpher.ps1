##############################
# Variables
##############################

$tmorphURL = "https://github.com/starshipx/tMorph/releases/download/v1.0.0/tMorph.zip"
$tmorphDir =  "C:\Dev\tmorph"

$remoteVersion = Invoke-WebRequest "https://starshipx.github.io/tMorph/"
$remoteVersion = $remoteVersion.ParsedHtml.GetElementsByTagName('p') | Where-Object {$_.OuterText -like "*World of Warcraft*"} | Select-Object -expand OuterText

##############################
# Functions
##############################

# Unzipper, not sure what version of Powershell people are using
# Thanks bro @ https://gist.github.com/nachivpn/3e53dd36120877d70aee
function unZip($zipfile, $outdir){
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipfile)
    foreach ($entry in $archive.Entries) {
        $entryTargetFilePath = [System.IO.Path]::Combine($outdir, $entry.FullName)
        $entryDir = [System.IO.Path]::GetDirectoryName($entryTargetFilePath)
        
        #Ensure the directory of the archive entry exists
        if(!(Test-Path $entryDir )){
            New-Item -ItemType Directory -Path $entryDir | Out-Null 
        }
        
        #If the entry is not a directory entry, then extract entry
        if(!$entryTargetFilePath.EndsWith("\")){
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $entryTargetFilePath, $true);
        }
    }
}

# Function to download our zip file 
# Chancing it a little with Invoke-Webrequest and PS versions
function download-tmorph {
    if (!(Test-Path $tmorphDir)) {
        Write-Host "[Info] $tmorphDir not found, will create"
        mkdir $tmorphDir | Out-Null
    }

    # Gonna try delete previous zip if there, might be locked though :S
    if (Test-Path $tmorphDir\tMorph.zip) {
        Write-Host "[Info] Found previously downloaded tMorph zip. Will try to remove"
        Remove-Item $tmorphDir\tMorph.zip -Force -ErrorAction SilentlyContinue
    }

    try {
        Write-Host "[Info] Downloading tmorph from $tmorphURL"
        $startTime = Get-Date
        Invoke-WebRequest $tmorphURL -OutFile $tmorphDir\tMorph.zip
        Write-Host "[Info] Time taken: $((Get-Date).Subtract($startTime).Seconds) second(s)"
    } catch {
        $_
    }
}

# Extract our zip file
function extract-tmorph {
    try { 
    Write-Host "[Info] tMorph $remoteVersion has been extracted"
    unZip -zipfile "$tmorphDir\tMorph.zip" -outdir "$tmorphDir"
    } catch {
        Write-Error "[Error] Something went wrong with extraction - Files in use? May need to delete all files in $tmorphDir"
    }
}

# Check our tmorph versions, grab version info
function check-tmorph {
    Push-Location $tmorphDir
    $versionFile = Get-ChildItem | Where-Object {$_.Name -like "version.txt"} 
    if ($versionFile) {
        $currentVersion = Get-Content $versionFile
        try {
            if ($currentVersion -like $remoteVersion) {
                Write-Host "[Ok] tMorph $remoteVersion is already downloaded. If it's not working, you'll just have to wait :("
            } else {
                Write-Host "[Info] Downloading tMorph $remoteVersion :)"
                download-tmorph
                Set-Content -Path $tmorphDir\version.txt -Value $remoteVersion
                extract-tmorph
            }
        } catch {
            Write-Host "[Warning] Something went wrong with version check, will download latest regardless"
            download-tmorph
            Set-Content -Path $tmorphDir\version.txt -Value $remoteVersion
            extract-tmorph
        }
    } else {
        Write-Host "[Info] No version file found, will download tMorph $remoteVersion for the first time"
        download-tmorph
        Set-Content -Path $tmorphDir\version.txt -Value $remoteVersion
        extract-tmorph
    }   
    Pop-Location
}

##############################
# Script
##############################

check-tmorph
