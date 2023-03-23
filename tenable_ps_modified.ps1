#PS script for tenable remediation

Adding line to check in git hub

Adding second line

#Defining function to uninstall tenable agent 
function Uninstal 
{
	#Start-Process -FilePath "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe" -ArgumentList "agent unlink --force" -ErrorAction SilentlyContinue
     Write-Output ""
     Write-Output "uninstalling nessus agent"
     Write-Output "-------------------------------------------------"
     $pinfo = New-Object System.Diagnostics.ProcessStartInfo
     $pinfo.FileName = "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe"
     $pinfo.RedirectStandardError = $true
     $pinfo.RedirectStandardOutput = $true
     $pinfo.UseShellExecute = $false
     $pinfo.Arguments = "agent unlink"
     $p = New-Object System.Diagnostics.Process
     $p.StartInfo = $pinfo
     $p.Start() | Out-Null
     $stdout = $p.StandardOutput.ReadToEnd()
     $stderr = $p.StandardError.ReadToEnd()
     $p.WaitForExit()
     Write-Host $stdout
     Write-Host $stderr
     Write-Host ("exit code: {0}" -f $p.ExitCode)

    #Get-Service "Tenable Nessus Agent" | Stop-Service
    $guid = Get-WmiObject -Class Win32_Product -Filter "Name = 'Nessus Agent (x64)'" | Select-Object -ExpandProperty IdentifyingNumber
    $key = get-itemproperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid"
    $instalsrc = $key.psobject.Properties | ?{ $_.Name -eq "InstallSource" } | Select-Object -ExpandProperty Value
    msiexec.exe /x "$instalsrc\NessusAgent-7.4.1-x64.msi" /qn
    Start-Sleep 60
	
	if (! (Test-Path -Path "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe") )
    {
	    Write-Output ">>>>>>> uninstall successful"
        Remove-Item -Path C:\ProgramData\Tenable -Recurse -Force -ErrorAction SilentlyContinue
       
        Remove-Item -path C:\Temp1\NessusAgent-7.4.1-x64.msi -Force -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Tenable" -Name "TAG" -ErrorAction SilentlyContinue
        $status = "success"
	}
	else 
    {
	     Write-Output ">>>>>> uninstall not successful"
        $status = "failed"
     }
    return $status	
}

function instal
{
    Write-Output ""    
	Write-Output "Downloading and installing agent"
    Write-Output "------------------------------------------------"
	Remove-Item -Path C:\Temp1\NessusAgent-7.4.1-x64.msi -Force -ErrorAction SilentlyContinue
	$client = new-object System.Net.WebClient
		
	$path = "C:\Temp1" 
		
	New-Item -ItemType Directory -Force -Path $path -ErrorAction SilentlyContinue	
	$client.DownloadFile("http://internal-core-hp-linux-repo.corp.hpicloud.net/utils/tools/cybertools/tenable/NessusAgent-7.4.1-x64.msi","$path\NessusAgent-7.4.1-x64.msi") 
		
	msiexec /i "$path\NessusAgent-7.4.1-x64.msi" /qn
    Start-Sleep 60
		
	if (Test-Path -Path "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe")
    {
	    Write-Output ">>>>>>> install successful"
       
	}
	else 
    {
	     Write-Output ">>>>>> install not successful"
        
	}
}

function Link 
{
     Write-Output "" 
     Write-output "Linking Nessus agent to tenable io"
     Write-Output "-------------------------------------------------------
"
     Start-Sleep 30
     Get-Service "Tenable Nessus Agent" | Stop-Service
     Remove-ItemProperty -Path "HKLM:\SOFTWARE\Tenable" -Name TAG -ErrorAction SilentlyContinue
     $pinfo = New-Object System.Diagnostics.ProcessStartInfo
     $pinfo.FileName = "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe"
     $pinfo.RedirectStandardError = $true
     $pinfo.RedirectStandardOutput = $true
     $pinfo.UseShellExecute = $false
     $pinfo.Arguments = 'agent link --groups=Public-Cloud --proxy-host=web-proxy.austin.hpicorp.net --proxy-port=8080 --cloud="yes" --key=b1b51ffc22340a1da6aba042658cec8d6dca4b688989155a28962308e2778fd5'
     $p = New-Object System.Diagnostics.Process
     $p.StartInfo = $pinfo
     $p.Start() | Out-Null
     $stdout = $p.StandardOutput.ReadToEnd()
     $stderr = $p.StandardError.ReadToEnd()
     $p.WaitForExit()
     Write-Host $stdout
     Write-Host $stderr
     Write-Host ("exit code: {0}" -f $p.ExitCode)
     Get-Service "Tenable Nessus Agent" | Start-Service
    
}
#This is gather info to check if tenable agent is installed and its status
function status 
{

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = "agent status"
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    Write-Host $stdout
    Write-Host $stderr
    Write-Host ("exit code: {0}" -f $p.ExitCode)

}

#Main()
try{
    Write-Output "Checking nessus agent status 
"
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "C:\Program Files\Tenable\Nessus Agent\Nessuscli.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = "agent status"
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    Write-Host $stdout
    Write-Host $stderr
    Write-Host ("exit code: {0}" -f $p.ExitCode)
}	
catch{ Write-Host "Tenable not installed" }

if (($stderr) -or ($p.ExitCode -ne 0))
{

	if (Select-String -InputObject $stdout -Pattern 'Not linked to a manager')
    {
		Link	
    } 
	elseif (Test-Path -Path 'C:\Program Files\Tenable' -PathType Container)
    {
        $ret_stat = Uninstal

         
         if ($ret_stat[4] -match "success")
         {
		       instal
               Link
    	}
    }
    else {
        
        instal
        Link
    }
}
elseif (Select-String -InputObject $stdout -Pattern 'disconnected') 
{
    Link
}

Write-Output ""

Get-Service "Tenable Nessus Agent" | Select-Object Status
Write-Output ""
