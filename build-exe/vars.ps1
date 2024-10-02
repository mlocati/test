# Script that sets some variables used in the GitHub Action steps

param (
    [Parameter(Mandatory = $true)]
    [ValidateSet(32, 64)]
    [int] $Bits,
    [Parameter(Mandatory = $true)]
    [ValidateSet('shared', 'static')]
    [string] $Link,
    [Parameter(Mandatory = $false)]
    [ValidateSet('', 'no', 'test', 'production')]
    [string] $Sign
)

# Leave empty to disable code signing
if ($env:GITHUB_REPOSITORY -ne 'mlocati/gettext-iconv-windows') {
    Write-Host -Object "Using -Sign none because the current repository ($($env:GITHUB_REPOSITORY)) is not the upstream one`n"
    $Sign = 'no'
} elseif ($env:GITHUB_EVENT_NAME -eq 'pull_request') {
    Write-Host -Object "Using -Sign test because the current event is $($env:GITHUB_EVENT_NAME)`n"
    $Sign = 'no'
} elseif (-not($Sign)) {
    Write-Host -Object "Using -Sign test`n"
    $Sign = 'test'
}
$signpathSigningPolicy = ''
$signaturesCanBeInvalid = 0
switch ($Sign) {
    'no' {
        Write-Host "Signing is disabled`n"
    }
    'test' {
        $signpathSigningPolicy = 'test-signing'
        $signaturesCanBeInvalid = 1
        Write-Host "SignPath signing policy: $signpathSigningPolicy (self-signed certificate)`n"
    }
    'production' {
        $signpathSigningPolicy = 'release-signing'
        $signaturesCanBeInvalid = 1
        Write-Host "SignPath signing policy: $signpathSigningPolicy (production certificate)`n"
    }
    default {
        throw "Invalid value of the -Sign argument ($Sign)"
    }
}

"signpath-signing-policy=$signpathSigningPolicy" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
"signatures-canbeinvalid=$signaturesCanBeInvalid" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8

Write-Output '## Outputs'
Get-Content -LiteralPath $env:GITHUB_OUTPUT
