function Invoke-WPFFixesNetwork {
    netsh winsock reset
    netsh int ip reset
    Write-Host "Ağ Yapılandırması Sıfırlandı. Lütfen bilgisayarınızı yeniden başlatın."
}
