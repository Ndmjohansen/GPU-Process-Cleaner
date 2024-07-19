# GPU Process Cleaner

This PowerShell script, `clear_gpu.ps1`, is designed to manage processes running on NVIDIA GPUs. It's particularly useful for cleaning up GPU resources when a system is unplugged, helping to conserve battery life on portable devices with dedicated NVIDIA graphics.

## Features

- Automatically detects NVIDIA GPUs in the system
- Lists all processes currently using each GPU
- Allows user to selectively force close processes running on the GPU
- Includes a blacklist to prevent closing essential processes
- Integrated with Windows Task Scheduler to run automatically when the system is unplugged

## Prerequisites

- Windows operating system
- PowerShell
- NVIDIA GPU and drivers
- `nvidia-smi` command-line utility (usually included with NVIDIA drivers)

## How It Works

1. The script waits for 10 seconds to allow Windows to offload the GPU.
2. It then retrieves a list of NVIDIA GPUs in the system.
3. For each GPU, it lists the processes currently using it.
4. The user is prompted with a Yes/No dialog for each process, asking if they want to force close it.
5. If confirmed, the script will forcefully terminate the selected processes.
6. Blacklisted processes (e.g., `dwm.exe`) are skipped to prevent system instability.

## Task Scheduler Integration

This script is designed to work with Windows Task Scheduler. A scheduled task XML file is bundled with this repository to automatically run `clear_gpu.ps1` when the system is unplugged from power. This helps conserve battery life by cleaning up GPU resources when running on battery power.

**Important**: The XML file assumes that the `clear_gpu.ps1` script is located at: `C:\Scripts\GPU Process Cleaner\clear_gpu.ps1`
Make sure to place the script in this location or update the XML file with the correct path before importing.

To set up the task:

1. Open Task Scheduler
2. Select "Import Task..." from the Action menu
3. Browse to and select the bundled XML file
4. Review and adjust any settings as needed for your system, especially the script path if different
5. Save the imported task

The task is preconfigured to:
- Trigger when the system is unplugged from AC power
- Run with appropriate permissions to interact with the desktop
- Execute the `clear_gpu.ps1` script

## Usage

While the script is primarily intended to run automatically via Task Scheduler, you can also run it manually:

1. Right-click on `clear_gpu.ps1`
2. Select "Run with PowerShell"

## Caution

Use this script carefully. Forcefully closing processes can lead to data loss if unsaved work is present.