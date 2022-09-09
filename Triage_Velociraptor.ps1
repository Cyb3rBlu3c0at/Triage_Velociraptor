<#
.DESCRIPTION
This PowerShell script was created for the purpose of using the Velociraptor Offline Collector across a Client's environment. This script will create a folder,
download PowerShell module, install AWS, download the Velociraptor Offline Collector, and execute the program. The Offline Collector will have the AWS credentials
embedded into the binary to assist with transferring the results. 

Version:            1
Author:             Mike Dunn
Creation Date:      September 2022

.NOTES
Plans for next version will include file/parameter checks so as not to constantly install something that is not needed if the script is run multiple times.
#>

$AccessKey = "ACCESS KEY GOES HERE"
$SecretKey = "SECRET KEY GOES HERE"
$Bucket = "NAME OF BUCKET"
$Object = "NAME OF FOLDER/FILE IN AWS"
$LocalPath = "C:\Windows\Temp\Triage"

function Create_Folder{
    New-Item -Path C:\Windows\Temp -Name Triage -ItemType Directory
}

function Install_AWS{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
    Find-Module -Name AWSPowerShell | Save-Module -Path "C:\Program Files\WindowsPowerShell\Modules"
    Import-Module AWSPowerShell
}

function Download_File{
    Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs Triage
    Initialize-AWSDefaultConfiguration -ProfileName Triage -Region us-east-1
    cd $LocalPath
    Read-S3Object -BucketName $Bucket -Key $Object -File Triage.exe
}

function Triage{
    Unblock-File -Path "$LocalPath\Triage.exe"
    .\Triage.exe
}

function Cleanup{
    Remove-AWSCredentialProfile -ProfileName Triage -Force
    cd C:\Windows\Temp
    Remove-Item -Path $LocalPath -Force -Recurse
}

Create_Folder
Install_AWS
Download_File
Triage
Cleanup
