<#
.DESCRIPTION
Test SSL and TLS connections for a given domain

.PARAMETER HostName
The host to connect to

.PARAMETER Port
Port to connect to, defaults to 443 

.EXAMPLE
Test-ServerSSLSupport "www.google.co.uk"
Host          : www.google.co.uk
Port          : 443
SSLv2         : False
SSLv3         : True
TLSv1_0       : True
TLSv1_1       : True
TLSv1_2       : True
HashAlgorithm : Sha1
KeyExhange    : 44550


.EXAMPLE
"www.google.co.uk","www.bbc.co.uk" | Test-ServerSSLSupport
Host          : www.google.co.uk
Port          : 443
SSLv2         : False
SSLv3         : True
TLSv1_0       : True
TLSv1_1       : True
TLSv1_2       : True
HashAlgorithm : Sha1
KeyExhange    : 44550

Host          : www.bbc.co.uk
Port          : 443
SSLv2         : False
SSLv3         : False
TLSv1_0       : True
TLSv1_1       : True
TLSv1_2       : True
HashAlgorithm : Sha1
KeyExhange    : RsaKeyX

.LINK
https://www.sysadmins.lv/blog-en/test-web-server-ssltls-protocol-support-with-powershell.aspx
#>
function Test-ServerSSLSupport {
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HostName,
        [UInt16]$Port = 443
    )
    process {
        $RetValue = New-Object psobject -Property @{
            Host = $HostName
            Port = $Port
            SSLv2 = $false
            SSLv3 = $false
            TLSv1_0 = $false
            TLSv1_1 = $false
            TLSv1_2 = $false
            KeyExhange = $null
            HashAlgorithm = $null
        }
        "ssl2", "ssl3", "tls", "tls11", "tls12" | %{
            $TcpClient = New-Object Net.Sockets.TcpClient
            $TcpClient.Connect($RetValue.Host, $RetValue.Port)
            $SslStream = New-Object Net.Security.SslStream $TcpClient.GetStream()
            $SslStream.ReadTimeout = 15000
            $SslStream.WriteTimeout = 15000
            try {
                $SslStream.AuthenticateAsClient($RetValue.Host,$null,$_,$false)
                $RetValue.KeyExhange = $SslStream.KeyExchangeAlgorithm
                $RetValue.HashAlgorithm = $SslStream.HashAlgorithm
                $status = $true
            } catch {
                $status = $false
            }
            switch ($_) {
                "ssl2" {$RetValue.SSLv2 = $status}
                "ssl3" {$RetValue.SSLv3 = $status}
                "tls" {$RetValue.TLSv1_0 = $status}
                "tls11" {$RetValue.TLSv1_1 = $status}
                "tls12" {$RetValue.TLSv1_2 = $status}
            }
            # dispose objects to prevent memory leaks
            $TcpClient.Dispose()
            $SslStream.Dispose()
        }
        $RetValue | select Host, Port, SSLv2, SSLv3, TLSv1_0, TLSv1_1, TLSv1_2, HashAlgorithm, KeyExhange
    }
}