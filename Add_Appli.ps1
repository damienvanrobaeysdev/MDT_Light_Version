#========================================================================
#
# Tool Name	: MDT_Application_Manager
# Author 	: Damien VAN ROBAEYS
# Website	: http://www.systanddeploy.com/
# Facebook	: https://www.facebook.com/systanddeploy/
# Mail 		: damien.vanrobaeys@gmail.com
# Twitter   : https://twitter.com/syst_and_deploy
#
#========================================================================

param
	(
		[String]$deploymentshare,
		[String]$module
	)

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data')           | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')        | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null

[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo] "en-US"

Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("Add_Appli.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$User = $env:USERNAME
$Date = get-date -format "dd/MM/yyyy hh:mm:ss"
$Global:Current_Folder =(get-location).path 

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

#************************************************************************** PUBLISHER TEXTBOX ***********************************************************************************************
$Appli_publisher = $Form.findname("Appli_publisher") 
#************************************************************************** NAME TEXTBOX ***********************************************************************************************
$Appli_name = $Form.findname("Appli_name") 
#************************************************************************** VERSION TEXTBOX ***********************************************************************************************
$Appli_version = $Form.findname("Appli_version") 
#************************************************************************** LANGUAGE TEXTBOX ***********************************************************************************************
$Appli_language = $Form.findname("Appli_language") 
#************************************************************************** BROWSE SOURCES BUTTON ***********************************************************************************************
$Appli_source = $Form.findname("Appli_source") 
#************************************************************************** COMMANDLINE TEXTBOX ***********************************************************************************************
$Appli_command = $Form.findname("Appli_command") 
#************************************************************************** COMMENTS TEXTBOX ***********************************************************************************************
$Appli_comments = $Form.findname("Appli_comments") 
#************************************************************************** REBOOT CHECKBOX ***********************************************************************************************
$Appli_Reboot = $Form.findname("Appli_Reboot") 
#************************************************************************** ENABLE CHECKBOX ***********************************************************************************************
$Appli_Enable = $Form.findname("Appli_Enable") 
#************************************************************************** HIDE CHECKBOX ***********************************************************************************************
$Appli_Hide = $Form.findname("Appli_Hide") 
#************************************************************************** FOLDER NAME TEXTBOX ***********************************************************************************************
$Appli_Folder_Choice_Name = $Form.findname("Appli_Folder_Choice_Name") 
#************************************************************************** SOURCES TEXBOX ***********************************************************************************************
$Appli_source_textbox = $Form.findname("Appli_source_textbox") 
#************************************************************************** SUMMARY BUTTON ***********************************************************************************************
$Summary_Button = $Form.findname("Summary_Button") 
#************************************************************************** CLEAR ALL BUTTON ***********************************************************************************************
$Clear_All_Button = $Form.findname("Clear_All_Button") 
#************************************************************************** ADD APPLICATION BUTTON ***********************************************************************************************
$ADD_Appli_XML = $Form.findname("ADD_Appli_XML") 

$Appli_source_textbox.IsEnabled = $false

#########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																			FUNCTIONS
#*******************************************************************************************************************************************************************************************************
#########################################################################################################################################################################################################	

Function Run_Summary
	{
		If (!$name){$name = "-"}
		If (!$comments){$comments = "-"}
		If (!$publisher){$publisher = "-"}
		If (!$version){$version = "-"}
		If (!$language){$language = "-"}
		If (!$foldername){$foldername = "-"}
		If (!$source){$source = "-"}		
		If (!$command){$command = "-"}
		If (!$reboot){$reboot = "False"}
		If (!$enable){$enable = "False"}
		If (!$hide){$hide = "False"}	
	
		powershell "$Current_Folder\Summary.ps1" -name $name -comments $comments -publisher $publisher -version $version -language $language -foldername $foldername -source $source -command $command -reboot $reboot -hide $hide -enable $enable                   
	}



########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																						 BUTTONS ACTIONS 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################
	

########################################################################################################################################################################################################
#                        																BROWSE APPLI BUTTON                                   
########################################################################################################################################################################################################	
	
$Appli_source.Add_Click({	### action on button
    $folder = $object.BrowseForFolder(0, $message, 0, 0) 
    If ($folder -ne $null) { 
        $global:appli_sources_folder = $folder.self.Path 
		$global:appli_source_name = split-path  $folder.self.Path -leaf -resolve		
		$Appli_source_textbox.Text =  $appli_sources_folder	
    } 	
})		
	
	
########################################################################################################################################################################################################
#                        																CLEAR ALL BUTTON                                   
########################################################################################################################################################################################################	

$Clear_All_Button.Add_Click({	### action on button
	$Appli_publisher.Text = ""
	$Appli_name.Text = ""
	$Appli_version.Text = ""
	$Appli_language.Text = ""
	$Appli_source = ""
	$Appli_command.Text = ""
	$Appli_comments.Text = "" 
	$Appli_Reboot.IsChecked = $false
	$Appli_Enable.IsChecked = $true
	$Appli_Hide.IsChecked = $false
	$Appli_Folder_Choice_Name.Text = ""
	$Appli_source_textbox.Text = ""
})		
		
	

########################################################################################################################################################################################################
#                        																SUMMARY BUTTON                                   
########################################################################################################################################################################################################		

$Summary_Button.Add_Click({				
	$Global:name = $Appli_name.Text.ToString()
	$Global:comments = $Appli_comments.Text						
	$Global:publisher = $Appli_publisher.Text						
	$Global:version = $Appli_version.Text						
	$Global:language = $Appli_language.Text							
	$Global:foldername = $Appli_Folder_Choice_Name.Text		
	$Global:source = $appli_sources_folder							
	$Global:command = $Appli_command.Text						
	$Global:reboot = $Appli_Reboot.IsChecked 						
	$Global:hide = $Appli_Hide.IsChecked 						
	$Global:enable = $Appli_Enable.IsChecked
	
	Run_Summary
})		
			
	
########################################################################################################################################################################################################
#                        																ADD APPLICATION BUTTON                                   
########################################################################################################################################################################################################	
	
	
	
$ADD_Appli_XML.Add_Click({		
	$Appli_Reboot_Status = $Appli_Reboot.IsChecked    								# -reboot
	$Appli_Hide_Status = $Appli_Hide.IsChecked         								# -hide
	$Appli_Enable_Status = $Appli_Enable.IsChecked	   								# -enable	
	$XML_Application_name = $Appli_name.Text.ToString()								# -name	
	$XML_Application_comments = $Appli_comments.Text.ToString()						# -comments			
	$XML_Application_Publisher = $Appli_publisher.Text.ToString()					# -publisher		
	$XML_Application_version = $Appli_version.Text.ToString()						# -version
	$XML_Application_language = $Appli_language.Text.ToString()						# -language
	$XML_Folder_Choice_Name = $Appli_Folder_Choice_Name.Text.ToString()				# -destinationfolder
	$XML_Application_command = $Appli_command.Text.ToString()						# -commandline
	$XML_Appli_Source_Folder = ".\Applications\$appli_source_name"  				# -applicationsourcepath
		
		
	If (($XML_Application_Publisher -ne "") -and ($XML_Application_version -ne ""))
		{
			$Application_Complete_Name = "$XML_Application_Publisher $XML_Application_name $XML_Application_version" 
		}
	ElseIf (($XML_Application_Publisher -ne "") -and ($XML_Application_version -eq ""))
		{
			$Application_Complete_Name = "$XML_Application_Publisher $XML_Application_name" 
		}
	ElseIf (($XML_Application_Publisher -eq "") -and ($XML_Application_version -ne ""))
		{
			$Application_Complete_Name = "$XML_Application_name $XML_Application_version" 
		}	
	ElseIf (($XML_Application_Publisher -eq "") -and ($XML_Application_version -eq ""))
		{
			$Application_Complete_Name = "$XML_Application_name" 
		}			
		
		
	If ($XML_Folder_Choice_Name -eq "")
		{
			$Destination_Folder = $Application_Complete_Name
			$XML_Appli_WorkingDirectory = ".\Applications\" + $Application_Complete_Name
		}
	Else
		{
			$Destination_Folder = $XML_Folder_Choice_Name
			$XML_Appli_WorkingDirectory = ".\Applications\$XML_Folder_Choice_Name"		
		}
		
			
	If (($Appli_name.Text -eq "") -or ($Appli_source_textbox.Text -eq ""))
		{
			If (($Appli_name.Text -eq "") -and ($Appli_source_textbox.Text -eq ""))		
				{
					$Appli_name.BorderBrush = "Red"
					$Appli_source_textbox.BorderBrush = "Red"				
				}		
			ElseIf ($Appli_name.Text -eq "")
				{
					$Appli_name.BorderBrush = "Red"
				}
			ElseIf ($Appli_source_textbox.Text -eq "")
				{
					$Appli_source_textbox.BorderBrush = "Red"
				}
		}
	Else
		{			
			import-module "$module\Bin\MicrosoftDeploymentToolkit.psd1"			
			$PSDrive_Test = get-psdrive
			If ($PSDrive_Test -eq "DSAppManager")
				{
					Remove-PSDrive -Name "DSAppManager"		
					New-PSDrive -Name "DSAppManager" -PSProvider MDTProvider -Root $deploymentshare								
				}
			Else
				{
					New-PSDrive -Name "DSAppManager" -PSProvider MDTProvider -Root $deploymentshare		
				}		
			import-MDTApplication -path "DSAppManager:\Applications" -enable $Appli_Enable_Status -reboot $Appli_Reboot_Status -hide $Appli_Hide_Status -Name $Application_Complete_Name -ShortName $XML_Application_name -Comments $XML_Application_comments -Version $XML_Application_version -Publisher $XML_Application_Publisher -Language $XML_Application_language -CommandLine $XML_Application_command -WorkingDirectory $XML_Appli_WorkingDirectory -ApplicationSourcePath $appli_sources_folder -DestinationFolder $Destination_Folder -Verbose
			[System.Windows.Forms.MessageBox]::Show("Application has been correctly added. You can close the window.") 		
		}				
})		
		
	
	
	
$Form.ShowDialog() | Out-Null
