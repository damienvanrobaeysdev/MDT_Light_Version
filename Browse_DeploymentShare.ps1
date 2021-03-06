#========================================================================
#
# Tool Name	: Windows 10 Profile Generator
# Author 	: Damien VAN ROBAEYS
# Date 		: 14/06/2016
#
#========================================================================

$Global:Current_Folder =(get-location).path 
# $EXE_config = "$Current_Folder\powershell.exe.config"
# $Win_PowerShell = "C:\Windows\System32\WindowsPowerShell\v1.0"
# copy-item $EXE_config $Win_PowerShell -recurse -force		

# If (Test-path "$Win_PowerShell\powershell.exe.config" -eq $False)
	# {
		# remove-item "$Win_PowerShell\powershell.exe.config" -force
		# copy-item $EXE_config $Win_PowerShell -recurse		
	# }
# Else
	# {
		# copy-item $EXE_config $Win_PowerShell -recurse
	# }
	

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
$XamlMainWindow=LoadXml("Browse_DeploymentShare.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$Browse_DeploymentShare = $Form.findname("Browse_DeploymentShare")
$DeploymentShare_Textbox = $Form.findname("DeploymentShare_Textbox")
$DeploymentShare_Textbox.IsEnabled = $false

$Browse_MDT = $Form.findname("Browse_MDT")
$MDT_Textbox = $Form.findname("MDT_Textbox")
$MDT_Textbox.IsEnabled = $false

$Browse_ADK = $Form.findname("Browse_ADK")
$ADK_Textbox = $Form.findname("ADK_Textbox")
$ADK_Textbox.IsEnabled = $false

$Run_Tool = $Form.findname("Run_Tool")

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
$Browse_DeploymentShare.Add_Click({	
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) 
		{ 		
			$global:deploymentshare = $folder.self.Path 
			$global:Control_folder = "$deploymentshare\Control"

			If (test-path $Control_folder)
				{
					$DeploymentShare_Textbox.Text =  $deploymentshare						
				}
			Else
				{
					[System.Windows.Forms.MessageBox]::Show("A Control folder can't be found on your master. Please check your sources.") 											
				}
					
		}
})



$Browse_MDT.Add_Click({	
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) 
		{ 		
			$global:MDT_module = $folder.self.Path 
				
			If (test-path $MDT_module)
				{				
					If ((test-path "$MDT_module\Bin") -or (test-path "$MDT_module\Templates") -or (test-path "$MDT_module\Samples"))         
						{
							$MDT_Textbox.Text =  $MDT_module						
						}
					Else
						{
							[System.Windows.Forms.MessageBox]::Show("Please select a correct MDT module. a folder Bin, Samples or Templates can't be found.") 										
						}												
				}
			Else
				{
					[System.Windows.Forms.MessageBox]::Show("A Deploy folder can't be found on your master. Please check your sources.") 					
				}
		}
})




$Browse_ADK.Add_Click({	
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) 
		{ 		
			$global:ADK_module = $folder.self.Path 
				
			If (test-path $ADK_module)
				{
					If (test-path "$ADK_module\Assessment and Deployment Kit")
						{
							$ADK_Textbox.Text =  $ADK_module						
						}
					Else
						{
							[System.Windows.Forms.MessageBox]::Show("Please select a correct ADK module. a folder Assessment and Deployment Kit, can't be found.") 										
						}
				}
			Else
				{
					[System.Windows.Forms.MessageBox]::Show("A Deploy folder can't be found on your master. Please check your sources.") 					
				}
		}
})





$Run_Tool.Add_Click({	
	If ($DeploymentShare_Textbox -ne $null)
		{
			powershell -sta "$Current_Folder\MDT_Portable_Version.ps1" -deploymentshare "'$global:deploymentshare'" -MDTModule "'$global:MDT_module'" -ADKmodule "'$global:ADK_module'" 	
		}
	Else
		{
			powershell -sta "$Current_Folder\MDT_Portable_Version.ps1" -deploymentshare "'$global:deploymentshare'"	-MDTModule "'$global:MDT_module'" -ADKmodule "'$global:ADK_module'"
		}
})

$Form.ShowDialog() | Out-Null