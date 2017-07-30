function Add-Migration
{
    param
    (
        [string] $Name,
        [string] $Folder = ""
    )

    $migrationsFolderName = "Migrations"
    $scriptsFolderName = "Scripts"

    $project = Get-Project
    $projectDir = Split-Path $project.FullName
    $scriptsDir = $projectDir    

    #check if the scripts folder is specified
    if ($Folder -ne "")
    {
        $scriptsDir = Join-Path $scriptsDir $Folder
        
        #create the scripts directory if it doesn't exist yet
        if (-not (Test-Path $scriptsDir -PathType Container))
        {
            New-Item -ItemType Directory -Path $scriptsDir | Out-Null
        }
    }
    #check if "Migrations" folder exists    
    elseif (Test-Path (Join-Path $scriptsDir $migrationsFolderName) -PathType Container)
    {
        $scriptsDir = Join-Path $scriptsDir $migrationsFolderName
    }
    #check if "Scripts" folder exists    
    elseif (Test-Path (Join-Path $scriptsDir $scriptsFolderName) -PathType Container)
    {
        $scriptsDir = Join-Path $scriptsDir $scriptsFolderName
    }
    else
    {
        #search for .sql files in the project
        $sqlFiles = @(Get-ChildItem -Path $projectDir -Filter *.sql -Recurse)

        #if no sql files are found, create a "Migrations" folder,
        #where the new migration file will be stored
        if($sqlFiles.Count -eq 0)
        {
            $scriptsDir = Join-Path $scriptsDir $migrationsFolderName
            New-Item -ItemType Directory -Path $scriptsDir | Out-Null
        }
        #get the first folder with sql files
        else
        {
            $scriptsDir = $sqlFiles[0].DirectoryName
        }
    }

    #generate migration file name and path
    $fileName = Get-Date -Format yyyyMMddHHmmss 
    if($Name -ne "")
    {
        $fileName = $fileName + "_" + $Name
    }    
    $fileName = $fileName + ".sql"
    $filePath = Join-Path $scriptsDir $fileName
 
    #create migration file
    New-Item -Path $scriptsDir -Name $fileName -ItemType File | Out-Null

    #add the migration file to the project
    $project.ProjectItems.AddFromFile($filePath) | Out-Null

    Write-Host "Created a new migration file - ${fileName}"

    #open the migration file
    $dte.ItemOperations.OpenFile($filePath) | Out-Null
}

Export-ModuleMember Add-Migration