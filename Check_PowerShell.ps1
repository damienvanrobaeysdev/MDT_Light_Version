#========================================================================
#
# Tool Name	: Windows 10 Profile Generator
# Author 	: Damien VAN ROBAEYS
# Date 		: 14/06/2016
#
#========================================================================

$Global:Current_Folder =(get-location).path 
$EXE_config = "$Current_Folder\powershell.exe.config"
$Win_PowerShell = "C:\Windows\System32\WindowsPowerShell\v1.0"
copy-item $EXE_config $Win_PowerShell -recurse -force		

powershell -sta "$Current_Folder\Browse_DeploymentShare.ps1" 			
