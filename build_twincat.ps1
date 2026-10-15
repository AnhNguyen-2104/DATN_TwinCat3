# Build TwinCAT 3 Solution and read Error List via DTE Automation Interface
param (
    [switch]$Rebuild = $false
)

try {
    $dte = [System.Runtime.InteropServices.Marshal]::GetActiveObject('TcXaeShell.DTE.15.0')
    if (-not $dte) {
        Write-Error "TcXaeShell is not running."
        exit 1
    }
    
    $solutionName = $dte.Solution.FullName
    Write-Output "Attached to TwinCAT XAE Shell: $solutionName"
    
    $sb = $dte.Solution.SolutionBuild
    if ($Rebuild) {
        Write-Output "Executing Rebuild Solution..."
        $sb.Clean($true)
        $sb.Build($true)
    } else {
        Write-Output "Executing Build Solution..."
        $sb.Build($true)
    }
    
    $lastBuildInfo = $sb.LastBuildInfo
    $errorList = $dte.ToolWindows.ErrorList
    $errorItems = $errorList.ErrorItems
    
    $errors = 0
    $warnings = 0
    
    for ($i = 1; $i -le $errorItems.Count; $i++) {
        $item = $errorItems.Item($i)
        $level = "$($item.ErrorLevel)"
        if ($level -like "*High*" -or $level -eq "3" -or $level -eq "1") {
            $errors++
            Write-Output "[ERROR] $($item.Description) ($($item.FileName):$($item.Line))"
        } elseif ($level -like "*Medium*" -or $level -eq "2") {
            $warnings++
            Write-Output "[WARNING] $($item.Description) ($($item.FileName):$($item.Line))"
        } else {
            Write-Output "[INFO] $($item.Description) ($($item.FileName):$($item.Line))"
        }
    }

    Write-Output "Build Result: ExitCode=$lastBuildInfo | Errors=$errors | Warnings=$warnings"
    if ($errors -gt 0 -or $lastBuildInfo -ne 0) {
        exit 1
    }
    exit 0
} catch {
    Write-Error "Automation Error: $($_.Exception.Message)"
    exit 2
}
