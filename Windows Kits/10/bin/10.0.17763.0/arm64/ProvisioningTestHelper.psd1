#
# Module manifest for module 'ProvisioningTestModule'
#
# Copyright (c) Microsoft Corporation. All rights reserved
#

@{

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = '05218365-87aa-4f63-80d3-2f5af78231a0'

# Author of this module
Author = 'Microsoft'

# Company or vendor of this module
CompanyName = 'Microsoft Corporation'

# Copyright statement for this module
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('ProvisioningTestHelper.dll')

# Functions to export from this module
FunctionsToExport = @('Install-TestEVCert', 'ConvertTo-SignedXml', 'Test-SignedXml', 'Install-RootCertFromFile')

}



# SIG # Begin signature block
# MIIirwYJKoZIhvcNAQcCoIIioDCCIpwCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCHlJMZ/9YbTgsq
# MYLztYO7es0Y3OaHx98vm51wyVDy+6CCC4EwggUJMIID8aADAgECAhMzAAACJG2S
# 5VjKdf54AAAAAAIkMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMTgwNTMxMTczNzAyWhcNMTkwNTI5MTczNzAyWjB/MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQDEyBNaWNy
# b3NvZnQgV2luZG93cyBLaXRzIFB1Ymxpc2hlcjCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALUAO1XlZu1u14a2BT1w1Rf5vQ4YH9YkJAx2KWLJIH+IAKcj
# pAFqdYJe3YYqr8fV1TjB5GR0UkNA13z2/iGmnHEUV5mmaFV9BqlEAl/uCKr2R7cc
# 6OPwnu+Ou5pJ1QRFZ2uk+ZMjgPZEPxpIitV38reCwgxQRbyZCNR/jiorsfsH1kmz
# j3hRrRzwWzuAxuwZb7r7AOkxgB156LYTiTYY7CFMRnAScVrAps2DqY3JiI/kzloU
# v5gQKwp1oXfXfp96vqWdpKNlWa2+VfLxj4BF6+kC1o0DkZYFl4ME/2F38Xuw96XF
# GCEmXGiF5pwjHrQDgg/FHbIABV+ZpSgdPD0pLtkCAwEAAaOCAX0wggF5MB8GA1Ud
# JQQYMBYGCisGAQQBgjcKAxQGCCsGAQUFBwMDMB0GA1UdDgQWBBT03vBzGFpXavw+
# EO3eYmj9DrbSmjBUBgNVHREETTBLpEkwRzEtMCsGA1UECxMkTWljcm9zb2Z0IEly
# ZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMRYwFAYDVQQFEw0yMjk5MDMrNDM2MDg5
# MB8GA1UdIwQYMBaAFOb8X3u7IgBY5HJOtfQhdCMy5u+sMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y0NvZFNpZ1BDQV8yMDEwLTA3LTA2LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljQ29k
# U2lnUENBXzIwMTAtMDctMDYuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEL
# BQADggEBAORp1AJcig5+KRMkkh5exzIFd+O7ccdVf5fgpmzZVrLAU2cMIgkbjX2p
# 6V8wbDM5LY2/VqNq6Twl/PdKDf8EYAIxbZ+J32AFzNH/sgBcke0qDGQ0HT+3RgfX
# R6n/qWQrScz/w70dahX9zuLgt0h9OJ4XswMBSukyTBVfQARaTfy3Pj3tBU+QPBHt
# SDDYA5LmqdGLB68K8CTrua0pg8p3Ux1W7Tp7d0X+KCU1m68FYh4oVrPR27SwGFeu
# ak7+uLH8LV7VOmD52m/y3XfW7+sjNoVBix1s1pJns19tRei1HbCdaWAGvw7y5Pex
# 2m96SuVNnYkDS6Y9lfChl6GHiJxn3Q0wggZwMIIEWKADAgECAgphDFJMAAAAAAAD
# MA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAxMDAeFw0xMDA3MDYyMDQwMTdaFw0yNTA3MDYyMDUwMTdaMH4xCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jv
# c29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQDpDmRQeWe1xOP9CQBMnpSs91Zo6kTYz8VYT6mldnxtRbrTOZK0
# pB75+WWC5BfSj/1EnAjoZZPOLFWEv30I4y4rqEErGLeiS25JTGsVB97R0sKJHnGU
# zbV/S7SvCNjMiNZrF5Q6k84mP+zm/jSYV9UdXUn2siou1YW7WT/4kLQrg3TKK7M7
# RuPwRknBF2ZUyRy9HcRVYldy+Ge5JSA03l2mpZVeqyiAzdWynuUDtWPTshTIwciK
# JgpZfwfs/w7tgBI1TBKmvlJb9aba4IsLSHfWhUfVELnG6Krui2otBVxgxrQqW5wj
# HF9F4xoUHm83yxkzgGqJTaNqZmN4k9Uwz5UfAgMBAAGjggHjMIIB3zAQBgkrBgEE
# AYI3FQEEAwIBADAdBgNVHQ4EFgQU5vxfe7siAFjkck619CF0IzLm76wwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNS
# b29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgZ0GA1UdIASBlTCBkjCBjwYJKwYBBAGC
# Ny4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJ
# L2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEA
# bABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3
# DQEBCwUAA4ICAQAadO9XTyl7xBaFeLhQ0yL8CZ2sgpf4NP8qLJeVEuXkv8+/k8jj
# NKnbgbjcHgC+0jVvr+V/eZV35QLU8evYzU4eG2GiwlojGvCMqGJRRWcI4z88HpP4
# MIUXyDlAptcOsyEp5aWhaYwik8x0mOehR0PyU6zADzBpf/7SJSBtb2HT3wfV2XIA
# LGmGdj1R26Y5SMk3YW0H3VMZy6fWYcK/4oOrD+Brm5XWfShRsIlKUaSabMi3H0oa
# Dmmp19zBftFJcKq2rbtyR2MX+qbWoqaG7KgQRJtjtrJpiQbHRoZ6GD/oxR0h1Xv5
# AiMtxUHLvx1MyBbvsZx//CJLSYpuFeOmf3Zb0VN5kYWd1dLbPXM18zyuVLJSR2rA
# qhOV0o4R2plnXjKM+zeF0dx1hZyHxlpXhcK/3Q2PjJst67TuzyfTtV5p+qQWBAGn
# JGdzz01Ptt4FVpd69+lSTfR3BU+FxtgL8Y7tQgnRDXbjI1Z4IiY2vsqxjG6qHeSF
# 2kczYo+kyZEzX3EeQK+YZcki6EIhJYocLWDZN4lBiSoWD9dhPJRoYFLv1keZoIBA
# 7hWBdz6c4FMYGlAdOJWbHmYzEyc5F3iHNs5Ow1+y9T1HU7bg5dsLYT0q15Iszjda
# PkBCMaQfEAjCVpy/JF1RAp1qedIX09rBlI4HeyVxRKsGaubUxt8jmpZ1xTGCFoQw
# ghaAAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTACEzMAAAIk
# bZLlWMp1/ngAAAAAAiQwDQYJYIZIAWUDBAIBBQCgggEEMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
# SIb3DQEJBDEiBCASnBV8DWDrRuyVAVYATNScSmQAZ9DUFli4s0xDRKxomDA8Bgor
# BgEEAYI3CgMcMS4MLGU4K0pZa2FSQjl5QkxNR2ZOclZYa2pjV05CSWhFZVIxcFZS
# NzAySHZycDA9MFoGCisGAQQBgjcCAQwxTDBKoCSAIgBNAGkAYwByAG8AcwBvAGYA
# dAAgAFcAaQBuAGQAbwB3AHOhIoAgaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3dp
# bmRvd3MwDQYJKoZIhvcNAQEBBQAEggEAg1NWqhNiT5gCb7cBNg326Kp53fK98BPL
# wdfW5zsFpWZziyz44u1bounehUs3N+Vu9QyKlJdA1r111tFoyR2tABJoi4XagxYJ
# RI63F5Jqrjhs1tNTW3732xAAGiUpc6aO5Cny2lopCVr6dWAGUo5ZLU0ULqmzP7Mz
# c1DMWg0QACzIspw7ZkWk9KtZbq2745IiX4iDiQhrMFXQzZnNFb4UIAec7Rv0wd78
# fBlMDy8QUGVeF7p6YSMMw6/2n+Lpo/Q7+nvrpo0fX4Po+ywXY5S0QJ9kpzkJnsiO
# EJcBxXfMOFtg/1S516MOOIdKUQ4mHklt8z4pdM8igckvviGbj5HbxaGCE7cwghOz
# BgorBgEEAYI3AwMBMYITozCCE58GCSqGSIb3DQEHAqCCE5AwghOMAgEDMQ8wDQYJ
# YIZIAWUDBAIBBQAwggFYBgsqhkiG9w0BCRABBKCCAUcEggFDMIIBPwIBAQYKKwYB
# BAGEWQoDATAxMA0GCWCGSAFlAwQCAQUABCCe+frVpVT88uq2GEukB/1QZN0fKmx0
# DLdvuzE+LQ0HuAIGW84YpuOvGBMyMDE4MTAyMzE3NTIxMy40ODlaMAcCAQGAAgH0
# oIHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkw
# JwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UE
# CxMdVGhhbGVzIFRTUyBFU046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wggg8fMIIE9TCCA92gAwIBAgITMwAAANAc
# amBhwufhrQAAAAAA0DANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
# cCBQQ0EgMjAxMDAeFw0xODA4MjMyMDI2MjhaFw0xOTExMjMyMDI2MjhaMIHOMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNy
# b3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRT
# UyBFU046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCbPoY2
# 11rO+8Z9zCo8IAYVmps5IDy61+pDNMYTp0m8huVorXo5SKMmKAYnE0C1sg6srmX5
# Q0s4a64HYRinDv2ly2HM2cU36hva3Ey1ZXtNkas6jSudX1Idqe3NuICGkOTGtydh
# BeSLWQ57tWx4c0/eFPyRb56B93OVe35gMirnNNUxG13+Z0PV52SRjGTZ+zUPZy7c
# rK1UP8RNbKfHWd2PYZK6WSRv37Vd7ocqC79HbP1xJb8pZLxTVCqWlfPokE1oZfKx
# mHTtBDlPyT1rGkqCgV97H/KWaAeXsy/WReXaWuaPVxJVCnpcEsRrgtfFmnSiNoEz
# u+fg7FIIBPXOkkYrAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQUA4Mol6hrJfLEUzIf
# ma06vHcYxXEwHwYDVR0jBBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
# BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJv
# ZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4w
# TDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
# cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNV
# HSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEApbwklmQJ31r0v5RT
# fzYZkW48IPXgYF18spdGCVoMGD7qK1GR5IXN0eTzTWNJTRpOkR4726dJ9trulEfw
# TDe9owtngVnUTTZco4j1Ba1hLnc0rcT1wZfbQc9bXWmhEI3KLobATjK7Stfz49VV
# 9QvRgr3ldnqGGbY5miHg5CKOIGOr9XDFtT3ve9jTqJZl8qxJVoKfHcUidYdGwfAK
# j8zcMIrt0+aE9V7G00wTNV9duDIA5vazZAUkJh6vs+H2Hmsl0SreztcnLOuSGL5H
# wSJrenGPlBT4mEeZqRhdJWunQdNWfEGmN1ovQZs7KayRu9l5Oia8rM7wkXDVF9cE
# +cCBLDCCBnEwggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcNAQELBQAwgYgx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1p
# Y3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcw
# MTIxMzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs
# /BOX9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUd
# zgkTjnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAy
# WGBG8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h/EbBJx0kZxJy
# GiGKr0tkiVBisV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL/W7lmsqx
# qPJ6Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlEXV4W
# nAEFTyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU
# 1WM6XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEw
# CwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/o
# olxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNy
# b3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYt
# MjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5j
# cnQwgaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIB
# FjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQu
# aHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkAYwB5AF8A
# UwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohRDeLG
# 4Jg/gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l4/m8
# 7WtUVwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/
# 8jd9Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kp
# vLb9BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlK
# cWOdeyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsi
# OCC1JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw
# 4TtxCd9ddJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995yfmFrb3epgcun
# Caw5u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaYLeqN4DMuEin1
# wC9UJyH3yKxO2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL32N79ZmKLxvH
# Ia9Zta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zPWAUu7w2g
# UDXa7wknHNWzfjUeCLraNtvTX4/edIhJEqGCA60wggKVAgEBMIH+oYHUpIHRMIHO
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBN
# aWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVz
# IFRTUyBFU046QzBGNC0zMDg2LURFRjgxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WiJQoBATAJBgUrDgMCGgUAAxUAKSkfi3FxMlc3Nr+9neHT
# ozE+jpWggd4wgdukgdgwgdUxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNv
# MScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBFU046NTdGNi1DMUUwLTU1NEMxKzApBgNV
# BAMTIk1pY3Jvc29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJKoZIhvcN
# AQEFBQACBQDfeYX5MCIYDzIwMTgxMDIzMTkzNTIxWhgPMjAxODEwMjQxOTM1MjFa
# MHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAN95hfkCAQAwBwIBAAICGxAwBwIBAAIC
# GkEwCgIFAN9613kCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAK
# MAgCAQACAxbjYKEKMAgCAQACAwehIDANBgkqhkiG9w0BAQUFAAOCAQEAI8pK6gNC
# VkjxPqEM3bxBpBwC2ZVEsRnvMXi2Ep5SniGK8H3CIv17PwNcq1H/W2V4tre/Macp
# b6/TaoLOwJ9Q7oRsl5dsmhKqk/8yr7BWNVNAxKFgH6FvywWRRVQpZ5zVDcAtJCGX
# zfIQEXsV4Jq0N7heoDHM3IHA6aS/F5PfCnX6FjmrkNYk1EEZxLt+/8acMTsqwBwA
# NLCBtPcMwuByxMLac3wGonwpqKkLDwQ9ItM5YOKSss9JLp7c2/n4LsQaiZaBkG3M
# xNedSEli7cZQp6VGuPDvDTcGSNfLzLQofmq2cOTdkskBpgonrfwzio2ASp71FIJM
# npoiHewalvhi6DGCAvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAAA0BxqYGHC5+GtAAAAAADQMA0GCWCGSAFlAwQCAQUAoIIBMjAa
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEINEuKdrJ
# kxIk9JUyqjK1ftZkpdOhU189dniED3yQgdpIMIHiBgsqhkiG9w0BCRACDDGB0jCB
# zzCBzDCBsQQUKSkfi3FxMlc3Nr+9neHTozE+jpUwgZgwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAANAcamBhwufhrQAAAAAA0DAWBBQ40aGo
# azhWbtgqK+62hidVXTw+xzANBgkqhkiG9w0BAQsFAASCAQBI3fh+H65NS8MfabRj
# sRY6/CANg/v0nHWzpjVMAIqilAuw6BC+BmRi3qpYOXEoxFr6pJ0ZkyPe6lvAI4mO
# vGugjPrGZyeif1mUiPCu1j4ti0KOk2ipHLGc4vDa1D0jq8VlNmcQ57eI658b44MH
# MYfuBICyzfdo4hsklWpFvR9ebOkA6wSfTTu7YM7RffO57xAoyI1iUIcOLGS92hLv
# sBwkxVZWbUlAZ44SdZuBlV6kYqlVxHLY5qSdTAa+g1X3yEJwbWqKlcpCzNj05sM2
# e8h2DXzIDyNm+6HwT3CsObjkdkXRGgc02MgFBZ8bnfiJfJkCy8QPyK+vIAtLaaBn
# fEh2
# SIG # End signature block
