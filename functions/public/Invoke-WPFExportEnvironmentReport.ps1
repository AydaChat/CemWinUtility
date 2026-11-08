function Invoke-WPFExportEnvironmentReport {
    <#
    .SYNOPSIS
        Exports an allowlisted, read-only environment report as JSON, with an optional bundle of
        recent WinUtil logs.
    #>

    try {
        $includeLogs = (Show-WinUtilMessage `
            -Message "Son 7 günlük WinUtil günlükleri de dahil edilsin mi? Ek dosya ham günlükleri içerir ve yerel yollar, komutlar ve hata ayrıntıları barındırabilir. Paylaşmadan önce inceleyin." `
            -Title "Ortam Raporu" -Button "YesNo" -Icon "Question") -eq "Yes"

        Add-Type -AssemblyName System.Windows.Forms
        $dialog = [System.Windows.Forms.SaveFileDialog]::new()
        $dialog.Title = "Ortam Raporunu Dışa Aktar"
        $dialog.Filter = "JSON Dosyaları (*.json)|*.json"
        $dialog.FileName = "WinUtilEnvironmentReport_$(Get-Date -Format 'yyyyMMdd').json"
        $dialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")

        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
            return
        }

        $jsonPath = $dialog.FileName
        $logsPath = Get-WinUtilEnvironmentReportLogsPath -JsonPath $jsonPath

        # SaveFileDialog's own overwrite prompt only covers $jsonPath. A derived companion from a
        # previous export must neither be silently replaced nor left looking like it belongs to new JSON.
        if (Test-Path -LiteralPath $logsPath) {
            if (-not $includeLogs) {
                # Choose another report filename or include and replace the existing logs.
                Show-WinUtilMessage `
                    -Message "Şu konumda zaten bir günlük dosyası var:`n$logsPath`n`nBaşka bir rapor dosya adı seçin veya mevcut günlüklerin üzerine yazın." `
                    -Title "Ortam Raporu" -Button "OK" -Icon "Warning" | Out-Null
                return
            }

            $replaceLogs = (Show-WinUtilMessage `
                -Message "Şu konumda zaten bir günlük dosyası var:`n$logsPath`n`nÜzerine yazılsın mı?" `
                -Title "Ortam Raporu" -Button "YesNo" -Icon "Warning") -eq "Yes"
            if (-not $replaceLogs) {
                return
            }
        }

        # Registry reads across every tweak/toggle and the log bundle's file read add up to a
        # couple of seconds, so the job layer keeps the Settings handler responsive and owns the
        # progress, taskbar state, logging, and error reporting.
        Start-WinUtilJob -Name "EnvironmentReport" -Description "Ortam raporu dışa aktarılıyor" -Parameters @{
            JsonPath = $jsonPath
            LogsPath = $logsPath
            IncludeLogs = $includeLogs
        } -ScriptBlock {
            param($JsonPath, $LogsPath, $IncludeLogs)

            Step-WinUtilJob -Status "Ortam raporu toplanıyor" -Percent 10
            $report = Get-WinUtilEnvironmentReport
            $json = $report | ConvertTo-Json -Depth 6

            if ($IncludeLogs) {
                Step-WinUtilJob -Status "Son WinUtil günlükleri toplanıyor" -Percent 60
                $logs = Get-WinUtilRecentLogs
            }

            Step-WinUtilJob -Status "Ortam raporu yazılıyor" -Percent 80
            Write-WinUtilEnvironmentReportExport -JsonPath $JsonPath -Json $json `
                -LogsPath $LogsPath -Logs $logs -IncludeLogs:$IncludeLogs

            Write-WinUtilLog -Component "EnvironmentReport" -Message "Environment report exported to $JsonPath."
            Step-WinUtilJob -Status "Ortam raporu dışa aktarma tamamlandı" -Percent 100
        }
    } catch {
        Write-WinUtilLog -Component "EnvironmentReport" -Level "ERROR" -Message "Environment report export failed: $($_.Exception.Message)"
        Show-WinUtilMessage -Message "Ortam raporu dışa aktarılamadı. $($_.Exception.Message)" `
            -Title "Ortam Raporu" -Button "OK" -Icon "None" | Out-Null
    }
}
