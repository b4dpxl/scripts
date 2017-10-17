<#
.DESCRIPTION
Test-Port connects to a given TCP Port on the specified host, and returns the success status

.PARAMETER Target
The computer name or IP address to connect to.

.PARAMETER Port
The TCP port to connect to

.PARAMETER Timeout
The timeout to use, default 2500

.EXAMPLE
Test-Port www.google.co.uk 443
Connection successful!

.EXAMPLE
"www.google.co.uk" | Test-Port -Port 443
Connection successful!

.EXAMPLE
"www.bbc.co.uk","www.google.co.uk" | Test-Port -port 443 -Verbose
VERBOSE: Connecting to www.bbc.co.uk:443
Connection successful!
VERBOSE: Connecting to www.google.co.uk:443
Connection successful!

.EXAMPLE
"www.google.co.uk" | Test-Port -Port 123
Connection failed - timeout

.EXAMPLE
"unknowndomain.fake" | Test-Port -Port 80
Connection failed


#>
function Test-Port {
[CmdletBinding()] # see http://blogs.technet.com/b/heyscriptingguy/archive/2012/07/07/weekend-scripter-cmdletbinding-attribute-simplifies-powershell-functions.aspx
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)][string]$Target,
        [Parameter(Mandatory=$true,Position=1)][int]$Port,
        [Parameter(Mandatory=$false)][int]$Timeout = 2500
    )
    process {
        $tcpobject = new-Object system.Net.Sockets.TcpClient 
        Write-Verbose "Connecting to $($target):$($port)"

        #Connect to remote machine's port               
        $connect = $tcpobject.BeginConnect( $target, $port, $null, $null ) 
    
        #Configure a timeout before quitting - time in milliseconds 
        $wait = $connect.AsyncWaitHandle.WaitOne( $timeout, $false ) 
    
        if ( -not $Wait ) {
            'Connection failed - timeout'
        } else {
            $error.clear()
            try {
                $tcpobject.EndConnect( $connect ) | out-Null 
                If ( $Error[0] ) {
                    Write-warning ( "{0}" -f $error[0].Exception.Message )
                } else {
                    'Connection successful!'
                }
            } catch {
                'Connection failed'
            }
        }
    }

}