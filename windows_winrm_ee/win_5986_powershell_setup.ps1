## Enable PowerShell Remote protocol
Enable-PSRemoting -Force

$fqdn = [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).HostName
$certParams = @{
   DnsName           =  $fqdn
   CertStoreLocation = "Cert:\LocalMachine\My"
}
$cert = New-SelfSignedCertificate @certParams

## Configure HTTPS transport
$wsmanParams = @{
   ResourceURI = "winrm/config/Listener"
   SelectorSet = @{
       Transport = "HTTPS"
       Address = "*"
   }
   ValueSet    = @{
       CertificateThumbprint = $cert.Thumbprint
       Enabled               = $true
   }
}
New-WSManInstance @wsmanParams

Set-Item -Path WSMan:\localhost\Service\Auth\Kerberos -Value $true

## Configure Firewall Rules
$firewallParams = @{
   DisplayName = "Windows Remote Management (HTTPS-In)"
   Direction   = "Inbound"
   LocalPort   = 5986
   Protocol    = "TCP"
   Action      = "Allow"
}
New-NetFirewallRule @firewallParams

