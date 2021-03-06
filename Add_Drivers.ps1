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
$XamlMainWindow=LoadXml("Add_Drivers.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$Global:Current_Folder =(get-location).path 

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Drivers_Browse = $Form.findname("Drivers_Browse")
$Drivers_Browse_textbox = $Form.findname("Drivers_Browse_textbox")
$Duplicate_Drivers = $Form.findname("Duplicate_Drivers")

$Add_this_drivers = $Form.findname("Add_this_drivers")

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
$Drivers_Browse.Add_Click({	
	$folder = $object.BrowseForFolder(0, $message, 0, 0) 
	If ($folder -ne $null) 
		{ 		
			$global:Drivers_Folder = $folder.self.Path 
			$Drivers_Browse_textbox.Text =  $Drivers_Folder					
		}
})


$Add_this_drivers.Add_Click({	
	Global:Drivers_Name = $Appli_command.Text.ToString()
	If ($Drivers_Browse_textbox.Text -eq "")
		{
			$Drivers_Browse_textbox.BorderBrush = "Red"				

		}
	Else
		{			
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"					
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DriversManager")
				{
					Remove-PSDrive -Name "DriversManager"		
					New-PSDrive -Name "DriversManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DriversManager" -PSProvider MDTProvider -Root $deploymentshare		
				}			

			If ($Duplicate_Drivers.IsSelected -eq $true)
				{				
					import-mdtoperatingsystem -path "DriversManager:\Out-of-Box Drivers" -SourcePath "$Drivers_Folder" -DestinationFolder "$OS_Folder_Name" -ImportDuplicate –Verbose			
				}
			Else
				{
					import-mdtoperatingsystem -path "DriversManager:\Out-of-Box Drivers\$Drivers_Name" -SourcePath "$Drivers_Folder" -DestinationFolder "$OS_Folder_Name" –Verbose			
				}			
			[System.Windows.Forms.MessageBox]::Show("MUI has been correctly added. You can close the window.") 		
		}
})

$Form.ShowDialog() | Out-Null