#========================================================================
#
# Tool Name	: Windows 10 Profile Generator
# Author 	: Damien VAN ROBAEYS
# Date 		: 14/06/2016
#
#========================================================================


param
	(
		[String]$deploymentshare,
		[String]$module
	)

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('MahApps.Metro.Controls.Dialogs')     | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("Update_DeploymentShare.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$Global:Current_Folder =(get-location).path 
$Global:Archi = $env:PROCESSOR_ARCHITECTURE
$Global:ProgFilesx64 = "$env:SystemDrive\Program Files (x86)"
$Global:Isx64 = test-path $ProgFilesx64
 
 
########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Update_Optimize = $Form.findname("Update_Optimize")
$Update_Optimize_compress = $Form.findname("Update_Optimize_compress")
$Update_Regenerate = $Form.findname("Update_Regenerate")
$Run_Update = $Form.findname("Run_Update")


Function MDT_ADK_Registry_Creation
	{
		# In this part we'll use MDT as a portable application
		# 1 / First we need to create a registry Key "HKLM:\SOFTWARE\Microsoft\Deployment 4"
		$MDT_Deployment4_Label = "Deployment 4" 				
		$HKLM_Location = "HKLM:\SOFTWARE\Microsoft"
		$Global:MDT_Deployment4 = "HKLM:\SOFTWARE\Microsoft\$MDT_Deployment4_Label"
		New-Item -Path $HKLM_Location -Name $MDT_Deployment4_Label			
		# 2 / Then we need to create a string Install_Dir with value "$Current_Folder\module\" in the "Deployment 4 Key"		
		New-ItemProperty -Path "$MDT_Deployment4" -Name "Install_Dir" -PropertyType String -Value "$MDTModule\"

		# 3 / We need to create a registry Key "HKLM:\SOFTWARE\Microsoft\Windows Kits\Installed Roots"					
		$WinKits_Key_Label = "Windows Kits" 
		$InstalledRoots_Key_Label = "Installed Roots" 
		
		If ($Isx64)
			{
				$HKLM_Location2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft"			
				$InstalledRoots_Key_Creation = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows Kits\$InstalledRoots_Key_Label"
				$Global:WindowsKits_Location = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows Kits"			
			}
		Else
			{
				$HKLM_Location2 = "HKLM:\SOFTWARE\Microsoft"			
				$InstalledRoots_Key_Creation = "HKLM:\SOFTWARE\Microsoft\Windows Kits\$InstalledRoots_Key_Label"
				$Global:WindowsKits_Location = "HKLM:\SOFTWARE\Microsoft\Windows Kits"		
			}			
			
			New-Item -Path $HKLM_Location2 -Name $WinKits_Key_Label
			New-Item -Path $WindowsKits_Location -Name $InstalledRoots_Key_Label	
							
		# 2 / Then we need to create a string "KitsRoot10" with value "$Current_Folder\Windows Kits\" in the "Installed Roots"					
		New-ItemProperty -Path "$InstalledRoots_Key_Creation" -Name "KitsRoot10" -PropertyType String -Value "$ADKmodule\"	
	}

	
Function MDT_ADK_Registry_Delete
	{
		Remove-Item -Path $MDT_Deployment4 -recurse
		Remove-Item -Path $WindowsKits_Location -recurse	
	}
	
	
	

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
$Run_Update.Add_Click({	

	If ($Update_Optimize.IsSelected -eq $true)
		{
			MDT_ADK_Registry_Creation
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"			
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DSManager")
				{
					Remove-PSDrive -Name "DSManager"		
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare		
				}							
			update-MDTDeploymentShare -path "DSManager:" -Verbose			
			MDT_ADK_Registry_Delete
			[System.Windows.Forms.MessageBox]::Show("Your Deployment Share has been updated") 					
		}
	ElseIf ($Update_Optimize_compress.IsSelected -eq $true)
		{
			MDT_ADK_Registry_Creation
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"			
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DSManager")
				{
					Remove-PSDrive -Name "DSManager"		
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare		
				}						
			update-MDTDeploymentShare -path "DSManager:" -Compress -Verbose
			MDT_ADK_Registry_Delete
			[System.Windows.Forms.MessageBox]::Show("Your Deployment Share has been updated") 		
			
		}
	ElseIf ($Update_Regenerate.IsSelected -eq $true)
		{
			MDT_ADK_Registry_Creation
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"			
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DSManager")
				{
					Remove-PSDrive -Name "DSManager"		
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DSManager" -PSProvider MDTProvider -Root $deploymentshare		
				}						
			update-MDTDeploymentShare -path "DSManager:" -Force -Verbose
			MDT_ADK_Registry_Delete			
			[System.Windows.Forms.MessageBox]::Show("Your Deployment Share has been updated") 					
		}		

})


$Form.ShowDialog() | Out-Null