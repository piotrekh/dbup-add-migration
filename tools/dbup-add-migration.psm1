function Add-DbUpMigration
{
    param
    (
        [string] $Name,
        [string] $Folder = "",
        [BuildActionType] $BuildAction = [BuildActionType]::None
    )

    $migrationsFolderName = "Migrations"
    $scriptsFolderName = "Scripts"

    $project = Get-Project
    $projectDir = Split-Path $project.FullName
    $scriptsDir = $projectDir    

    #apply folder and build action values from settings file
    #(only if folder is not specified and build action is 'None')
    Apply-Settings -folder ([ref]$Folder) -buildAction ([ref]$BuildAction) -projectDir $projectDir

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
    $item = $project.ProjectItems.AddFromFile($filePath)
    
    #set the build action
    if($BuildAction -ne [BuildActionType]::None)
    {
        $item.Properties.Item("BuildAction").Value = $BuildAction -as [int]

        #if build action is set to content, then also
        #set 'copy to output directory' to 'copy always'
        if($BuildAction -eq [BuildActionType]::Content)
        {
            $item.Properties.Item("CopyToOutputDirectory").Value = [uint32]1
        }
    }

    Write-Host "Created a new migration file - ${fileName}"

    #open the migration file
    $dte.ItemOperations.OpenFile($filePath) | Out-Null
}

function Add-Migration
{
    param
    (
        [string] $Name,
        [string] $Folder = "",
        [BuildActionType] $BuildAction = [BuildActionType]::None
    )

    Add-DbUpMigration -Name $Name -Folder $Folder -BuildAction $BuildAction
}

function Apply-Settings([ref]$folder, [ref]$buildAction, $projectDir)
{    
    $settingsFilePath = Join-Path $projectDir "dbup-add-migration.json"

    #check if settings file exists
    if (Test-Path $settingsFilePath -PathType Leaf)
    {
        $settings = Get-Content -Raw -Path $settingsFilePath | ConvertFrom-Json

        #overwrite $folder value only if it's not already set
        if($folder.Value -eq "")
        {
            $folder.Value = $settings.folder
        }
        
        #overwrite $buildAction value only if it's set to 'None'
        if($buildAction.Value -eq [BuildActionType]::None)
        {
            $buildAction.Value = [BuildActionType] $settings.buildAction
        }
    }
}

function Add-MigrationSettings
{
    $project = Get-Project
    $projectDir = Split-Path $project.FullName
    $settingsFileName = "dbup-add-migration.json"
    $settingsFilePath = Join-Path $projectDir $settingsFileName

    #create settings file only if it doesn't exist yet
    if (Test-Path $settingsFilePath -PathType Leaf)
    {
        Write-Host "A settings file for Add-Migration command already exists"
    }
    else
    {
        #create the file
        New-Item -Path $projectDir -Name $settingsFileName -ItemType File | Out-Null
        
        #prepare default settings
        $defaultSettings = @"
{
	"folder": "Migrations",
	"buildAction": "EmbeddedResource"
}
"@

        #insert default data into the file
        $defaultSettings | Out-File -FilePath $settingsFilePath

        #add the settings file to the project
        $item = $project.ProjectItems.AddFromFile($settingsFilePath)

        #open the settings file
        $dte.ItemOperations.OpenFile($settingsFilePath) | Out-Null
    }
}

enum BuildActionType
{
    None = 0
    Compile = 1
    Content = 2
    EmbeddedResource = 3
}

Export-ModuleMember -Function Add-DbUpMigration, Add-Migration, Add-MigrationSettings