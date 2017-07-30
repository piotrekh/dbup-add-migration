param($installPath, $toolsPath, $package)
 
#remove previously loaded module
$existingModule = Get-Module 'dbup-add-migration'
if ($existingModule) { Remove-Module $existingModule }
 
Import-Module (Join-Path $toolsPath dbup-add-migration.psm1)