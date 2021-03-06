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
$XamlMainWindow=LoadXml("Add_Media.xaml")
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

$Media_Browse = $Form.findname("Media_Browse")
$Media_Browse_textbox = $Form.findname("Media_Browse_textbox")
$Choose_selection_profile = $Form.findname("Choose_selection_profile")

$support_x86 = $Form.findname("support_x86")
$support_x64 = $Form.findname("support_x64")
$generate_iso = $Form.findname("generate_iso")
$Media_ISO_Name = $Form.findname("Media_ISO_Name")

$Create_the_media = $Form.findname("Create_the_media")

#######################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		FUNCTIONS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

Function Populate_Selection_Profile
	{		
		$Selection_Profile_xml = "$deploymentshare\Control\SelectionProfiles.xml"
		$Global:My_Selection_Profile_xml = [xml] (Get-Content $Selection_Profile_xml)	
		foreach ($data in $My_Selection_Profile_xml.selectNodes("selectionProfiles/selectionProfile"))
			{
				$Choose_selection_profile.Items.Add($data.name)	| out-null	
			}					
	}	
	
$Choose_selection_profile.add_SelectionChanged({
    $Global:My_Selected_profile = $Choose_selection_profile.SelectedItem
	foreach ($data in $My_Selection_Profile_xml.selectNodes("selectionProfiles/selectionProfile"))
		{
			If ($My_Selected_profile -eq $data.name)
				{
					$Global:My_Sel_profile = $data.name	
				}
		}		
})		


Populate_Selection_Profile

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	
# Populate_SelectionProfile	
	
	
$Media_Browse.Add_Click({	
	$folder = $object.BrowseForFolder(0, $message, 0, 0) 
	If ($folder -ne $null) 
		{ 		
			$global:Media_folder = $folder.self.Path 
			$Media_Browse_textbox.Text =  $Media_folder					
		}
})


$Create_the_media.Add_Click({	
	If ($Media_Browse_textbox.Text -eq "")
		{
			$Media_Browse_textbox.BorderBrush = "Red"				
		}
	Else
		{		

			# Check if Boot images options are enabled
			$bootx86_status = $support_x86.IsChecked
			$bootx64_status = $support_x64.IsChecked
			
			# If the ISO name textbox is empty, the ISO won't be generated
			$ISO_name = $Media_ISO_Name.Text.ToString()	
			If ($ISO_name -ne "")
				{
					$Generate_ISO = "true"
				}
			Else
				{
					$Generate_ISO = "false"
				}			
			
			# Check how many Media exist in the Media.xml
			$Media_xml = "$deploymentShare\Control\Medias.xml"
			$Sel_media_xml = [xml] (Get-Content $Media_xml)			
			$total_name_count = ($Sel_media_xml.SelectNodes("medias/media/Name")).Count			
			$Media_name = "MyMedia" + ($total_name_count+1)
			
			New-Item -Path "$Media_folder\Content\Deploy" -ItemType directory	
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"					
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "Mediamanager")
				{
					Remove-PSDrive -Name "Mediamanager"		
					New-PSDrive -Name "Mediamanager" -PSProvider MDTProvider -Root $deploymentshare						
				}
			Else
				{
					New-PSDrive -Name "Mediamanager" -PSProvider MDTProvider -Root $deploymentshare		
				}				

			# New-item -path "Mediamanager:\Media" -enable "True" -Name $Media_name -Comments "" -Root "$Media_folder" -SelectionProfile $My_Sel_profile -SupportX86 $bootx86_status -SupportX64 $bootx64_status -GenerateISO $Generate_ISO -ISOName "$ISO_name.iso" –Verbose
			New-item -path "Mediamanager:\Media" -enable "True" -Name $Media_name -Comments "" -Root "$Media_folder" -SelectionProfile $My_Sel_profile -SupportX86 $bootx86_status -SupportX64 $bootx64_status -GenerateISO "true" -ISOName "ISO_name.iso" –Verbose

			New-PSDrive -Name $Media_name -PSProvider "MDTProvider" -Root "$Media_folder\Content\Deploy" -Description "Embedded media deployment share" -Force –Verbose
			Remove-PSDrive -Name $Media_name
			
			[System.Windows.Forms.MessageBox]::Show("Your OS has been correctly added. You can close the window.") 		
		}

})

$Form.ShowDialog() | Out-Null