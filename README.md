# Add-Migration command for DbUp
**Add-Migration** Package Manager Console command intended for use with [DbUp](http://dbup.github.io/) (but not depending on it)

## About
This package adds a new command **"Add-Migration"** to the Package Manager Console. Running the command results in an sql file with date and time (in format _yyyyMMddHHmmss_) in the file name added to the project (e.g. `20170730185349_MyFirstMigration.sql`). 

Create a file using default behaviour (the command will decide where to put it, build action will not be set):

    Add-Migration "MyFirstMigration"

Create a file in specific folder:

    Add-Migration "MyFirstMigration" -Folder "Migrations"    

Set build action when creating a file (use tab for -BuildAction value hints):

    Add-Migration "MyFirstMigration" -BuildAction EmbeddedResource

---

The sql files are generated in either of these locations in your project:
- _Specified folder_ - when `-Folder` parameter is added, the script will be generated in the given directory. If the directory does not exist, it will be created.
- _"Migrations" folder_ - when `-Folder` parameter is omitted, but a folder named "Migrations" already exists in the project.
- _"Scripts" folder_ - when `-Folder` parameter is omitted, but a folder named "Scripts" already exists in the project.
- _First folder with .sql files_ - when `-Folder` parameter is omitted and neither "Migrations" nor "Scripts" folder exists, the command will add the new migration in the first folder in the project that contains .sql files. If no such folder is found, then "Migrations" folder will be created and used by default.

---

When `-BuildAction` parameter is set to _Content_, the command will also set **Copy to output directory** to _Copy always_

---

## How to install
You can install this package from [NuGet](https://www.nuget.org/packages/dbup-add-migration/)
    
    Install-Package dbup-add-migration