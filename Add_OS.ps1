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
$XamlMainWindow=LoadXml("Add_OS.xaml")
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

$Full_Sources = $Form.findname("Full_Sources")
$WIM_File = $Form.findname("WIM_File")
$WDS_Images = $Form.findname("WDS_Images")

$OS_Browse = $Form.findname("OS_Browse")
$OS_Browse_textbox = $Form.findname("OS_Browse_textbox")

$OS_Folder_Name = $Form.findname("OS_Folder_Name")

$WDS_Server_Name = $Form.findname("WDS_Server_Name")

$Add_this_OS = $Form.findname("Add_this_OS")

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
$OS_Browse.Add_Click({	
	If ($Full_Sources.IsSelected -eq $true)
		{
			$folder = $object.BrowseForFolder(0, $message, 0, 0) 
			If ($folder -ne $null) 
				{ 		
					$global:OS_Folder = $folder.self.Path 
					$OS_Browse_textbox.Text =  $OS_Folder					
				}
		}
	ElseIf ($WIM_File.IsSelected -eq $true)
		{
			$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
			$OpenFileDialog.filter = "wim Files (*.wim)| *.wim" # Set the file types 
			$OpenFileDialog.initialDirectory = [Environment]::GetFolderPath("Desktop")
			$OpenFileDialog.ShowDialog() | Out-Null
			$Global:OS_WIM_File = $OpenFileDialog.filename
			$OS_Browse_textbox.Text = $OpenFileDialog.filename					
		}
})





$Add_this_OS.Add_Click({	
	If ($Full_Sources.IsSelected -eq $true)
		{
			If ($OS_Browse_textbox.Text -eq "")
				{
					$OS_Browse_textbox.BorderBrush = "Red"				
				}
			Else
				{			
					$OS_Folder_Name_text = $OS_Folder_Name.Text.ToString()					
					import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"					
					$PSDrive_Test = get-psdrive
					If ($PSDrive_Test -eq "OSManager")
						{
							Remove-PSDrive -Name "OSManager"		
							New-PSDrive -Name "OSManager" -PSProvider MDTProvider -Root $deploymentshare								
						}
					Else
						{
							New-PSDrive -Name "OSManager" -PSProvider MDTProvider -Root $deploymentshare		
						}				
					import-mdtoperatingsystem -path "OSManager:\Operating Systems" -SourcePath "$OS_Folder" -DestinationFolder "$OS_Folder_Name_text" –Verbose										
					[System.Windows.Forms.MessageBox]::Show("Your OS has been correctly added. You can close the window.") 		
				}
		}							
	ElseIf ($WIM_File.IsSelected -eq $true)
		{
			If ($OS_Browse_textbox.Text -eq "")
				{
					$OS_Browse_textbox.BorderBrush = "Red"				

				}
			Else
				{			
					$OS_Folder_Name_text = $OS_Folder_Name.Text.ToString()									
					import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"				
					$PSDrive_Test = get-psdrive
					If ($PSDrive_Test -eq "OSManager")
						{
							Remove-PSDrive -Name "OSManager"		
							New-PSDrive -Name "OSManager" -PSProvider MDTProvider -Root $deploymentshare								
						}
					Else
						{
							New-PSDrive -Name "OSManager" -PSProvider MDTProvider -Root $deploymentshare		
						}				
					import-mdtoperatingsystem -path "OSManager:\Operating Systems" -SourceFile "$OS_WIM_File" -DestinationFolder "$OS_Folder_Name_text" –Verbose																
					[System.Windows.Forms.MessageBox]::Show("Your OS has been correctly added. You can close the window.") 		
				}		
		}
	ElseIf ($WDS_Images.IsSelected -eq $true)
		{
				
			Import_Module	
			import-mdtoperatingsystem -path "DS001:\Operating Systems\$OS_Folder_Name" -WDSServer $WDS_Server_Name.Text.ToString() –Verbose
		}


})

$Form.ShowDialog() | Out-Null