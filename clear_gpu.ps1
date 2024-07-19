Add-Type -AssemblyName PresentationFramework
# Wait for 10 seconds to give windows time to offload the GPU
Start-Sleep -Seconds 10

# Define the list of blacklisted executables
$blacklistedExecutables = @(
    '[Insufficient Permissions]',
    'dwm.exe',
    'explorer.exe',
    'ctfmon.exe',
    'spoolsv.exe',
    'taskhostw.exe',
    'perfmon.exe',
    'wuauserv.exe',
    'dfrgui.exe',
    'svchost.exe',
    'regsvr32.exe',
    'lsass.exe',
    'wininit.exe',
    'services.exe',
    'smss.exe',
    'System',
    'System Idle Process',
    'dllhost.exe',
    'ntoskrnl.exe',
    'winlogon.exe',
    'rundll32.exe',
    'conhost.exe',
    'msmpeng.exe',
    'taskmgr.exe',
    'searchindexer.exe',
    'vssvc.exe'
)

# Function to get the list of NVIDIA GPUs and their IDs
function Get-NvidiaGPUList {
    $gpuList = & nvidia-smi --query-gpu=index,name --format=csv,noheader
    $gpuList | ForEach-Object {
        $gpu = $_ -split ','
        [PSCustomObject]@{
            Index = $gpu[0].Trim()
            Name  = $gpu[1].Trim()
        }
    }
}

# Function to get processes running on a specific NVIDIA GPU
function Get-NvidiaGPUProcesses {
    param (
        [string]$GPUIndex
    )

    $processList = & nvidia-smi --query-compute-apps=pid,process_name --format=csv,noheader,nounits -i $GPUIndex
    $processList | ForEach-Object {
        $process = $_ -split ','
        [PSCustomObject]@{
            ProcessID   = $process[0].Trim()
            ProcessName = [System.IO.Path]::GetFileName($process[1].Trim())
        }
    }
}

# Function to force close a process by ProcessID
function Close-ProcessByProcessID {
    param (
        [int]$ProcessID
    )
    
    Stop-Process -Id $ProcessID -Force
}

# Function to show a Yes/No message box
function Show-YesNoMessageBox {
    param (
        [string]$Message,
        [string]$Title
    )
    
    $result = [System.Windows.MessageBox]::Show($Message, $Title, [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Question)
    return $result -eq [System.Windows.MessageBoxResult]::Yes
}

# Get NVIDIA GPU List
$gpuList = Get-NvidiaGPUList

if ($gpuList.Count -eq 0) {
    Write-Host "No NVIDIA GPUs found." -ForegroundColor Red
    exit
}

# Iterate over each GPU and check for processes
foreach ($gpu in $gpuList) {
    $gpuIndex = $gpu.Index
    $gpuName = $gpu.Name
    Write-Host "Checking processes for NVIDIA GPU '$gpuName' (Index $gpuIndex):" -ForegroundColor Green
    
    # Get processes using the current GPU
    $processesUsingGPU = Get-NvidiaGPUProcesses -GPUIndex $gpuIndex

    # Display the processes using the current GPU
    $processesUsingGPU | Where-Object { $_.ProcessName -notin $blacklistedExecutables } | Format-Table -AutoSize

    # Prompt to force close each process using a message box
    foreach ($process in $processesUsingGPU) {
        if ($process.ProcessName -notin $blacklistedExecutables) {
            $message = "Do you want to force close the process '$($process.ProcessName)' with ProcessID $($process.ProcessID) on GPU '$gpuName'?"
            $title = "Force Close Process"
            $confirm = Show-YesNoMessageBox -Message $message -Title $title
            if ($confirm) {
                Close-ProcessByProcessID -ProcessID $process.ProcessID
                Write-Host "Process '$($process.ProcessName)' with ProcessID $($process.ProcessID) has been closed." -ForegroundColor Red
            } else {
                Write-Host "Process '$($process.ProcessName)' with ProcessID $($process.ProcessID) was not closed." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Process '$($process.ProcessName)' is blacklisted and will not be closed." -ForegroundColor Green
        }
    }
}
