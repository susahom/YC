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
# MIIh3QYJKoZIhvcNAQcCoIIhzjCCIcoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
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
# PkBCMaQfEAjCVpy/JF1RAp1qedIX09rBlI4HeyVxRKsGaubUxt8jmpZ1xTGCFbIw
# ghWuAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# KDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTACEzMAAAIk
# bZLlWMp1/ngAAAAAAiQwDQYJYIZIAWUDBAIBBQCgggEEMBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
# SIb3DQEJBDEiBCASnBV8DWDrRuyVAVYATNScSmQAZ9DUFli4s0xDRKxomDA8Bgor
# BgEEAYI3CgMcMS4MLGIxUGRoTWxWUENMeGNzUGRVUjB3WThRWXpQcUdNMGFObGx0
# N3NpUnB3ZkU9MFoGCisGAQQBgjcCAQwxTDBKoCSAIgBNAGkAYwByAG8AcwBvAGYA
# dAAgAFcAaQBuAGQAbwB3AHOhIoAgaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3dp
# bmRvd3MwDQYJKoZIhvcNAQEBBQAEggEAmrQGsAvOM0d2nvu+4rfUsrkO395jpIMB
# 8Enb9R2ca8nmZG1QUwm14P1FM/d85gU/ZZ3+L/KxaAx7KBPjcxrlESrqEFNs5q+4
# 3ZFdNU9ZRGhuuy16fkGE6eX+0zERrIcbC+3Y20FDcmHdVXT+w7T+dikrIWECKlf7
# oY8lNGMIK0Pq7w5bs6XOZWU64ClvmpKwNeA1Qn9ICyKvOFBM5nCuY/qeYTMlGhQk
# 90cGZKV9KTvpRHGK4Re1AFQrCTEjj16dugCFtoKEQkF4Ohgv5r42Qjq6RWCUI09N
# +JFAH+Sb1Wz+wV1ITh0HidGoSar+nINm2to9jPrC2+y1qEE4Yh8c06GCEuUwghLh
# BgorBgEEAYI3AwMBMYIS0TCCEs0GCSqGSIb3DQEHAqCCEr4wghK6AgEDMQ8wDQYJ
# YIZIAWUDBAIBBQAwggFRBgsqhkiG9w0BCRABBKCCAUAEggE8MIIBOAIBAQYKKwYB
# BAGEWQoDATAxMA0GCWCGSAFlAwQCAQUABCBPXCz8MaUqA6Wgi7/QxMf8Vmj4xi8j
# lucmkkhCpnSMsAIGW7SxdCFbGBMyMDE4MTAyMzEzMDcyOS43ODZaMASAAgH0oIHQ
# pIHNMIHKMQswCQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWlj
# cm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFs
# ZXMgVFNTIEVTTjpBQjQxLTRCMjctRjAyNjElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgc2VydmljZaCCDjwwggTxMIID2aADAgECAhMzAAAA3IYTqAXYFYtH
# AAAAAADcMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMB4XDTE4MDgyMzIwMjY1NFoXDTE5MTEyMzIwMjY1NFowgcoxCzAJBgNVBAYT
# AlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBP
# cGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkFCNDEt
# NEIyNy1GMDI2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNl
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsPoXEjCNi8qS6Ww/tsTy
# q7CbdVKtpLF3QAbbQREFjmJ056Ggpzww68gwVJPKfxeXilueif7SmoYEUk/Ngm93
# 3VFzoPfypWRMGAps+z1lPlfGZrgpsENMstKZzCz+oHjP9GV1vhebyF1yqmZ1EmwU
# 08vyXFcVcb7AQQsxX66/3HZEOezWQNBBxUR97v5AC4+GbE3MzYR5O3uIXIxatf/Q
# E4pG9d1RZLMtLA/469WC5A+icvvI1dDJ41TKdcFp0c5adZThiT3XNlzO6bDoao2W
# hAXuGLxDAKOkQ1zLDBKqm9NvkrjJ4ePHr6p20budDC6A0Ch1MFUwjsy3dp8P0qvs
# lwIDAQABo4IBGzCCARcwHQYDVR0OBBYEFDrVvNEDVZ0OHNlKXJJ+dLgqaZieMB8G
# A1UdIwQYMBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJoEeG
# RWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Rp
# bVN0YVBDQV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUH
# MAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljVGltU3Rh
# UENBXzIwMTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYB
# BQUHAwgwDQYJKoZIhvcNAQELBQADggEBABwtIuWSLIAHwv0ne3ECr5kwzT6+64FX
# iqqlzFn0H75BQJruK+hgQzFy+8CWQfMJnzCnNi1YuEmIg2YpeHtGFj3CHa+p/sXz
# tD7AhKa+zT2z7bbo4vTrHnTCXya85tRhLzkW3q35z3v5x10S1UnfyKnVxUc0GWe2
# tpa2ttV29HyQQRL3Gn0+r1+F5YdrSqfNWgzUByszs2ZZUj7zLh7mMo/uknS3hdqz
# 3lyEKV8lIHrrY5w4+qX5yoteErJpyS7MSo29Bh0tzX5ArWKvK2oLPHeWvTsq8RYj
# Z4VjjMB1foXnysntWnrCt9EcYu3GzHDUBN9+K/62glOhRjx3F1p4LvgwggZxMIIE
# WaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9v
# dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEyMTM2NTVaFw0y
# NTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwTl/X6f2mUa3RU
# ENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycEMR9BGxqVHc4JE458YTBZsTBE
# D/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhgRvJYR4YyhB50
# YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScdJGcSchohiq9LZIlQYrFd
# /XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZEfu/QS/1u5ZrKsajyeioKMfDaTgaR
# togINeh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1eFpwBBU8iTQIDAQAB
# o4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNVjOlyKMZDzQ3t8
# RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIB
# hjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fO
# mhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9w
# a2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggr
# BgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
# bS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MIGgBgNVHSAB
# Af8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZhdWx0Lmh0bTBABggrBgEF
# BQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBt
# AGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3ixuCYP4FxAz2do6Eh
# b7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn8Hi9x6ieJeP5vO1rVFcIK1GCRBL7
# uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3fVo/HPKZeUqR
# UgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQkIjzP7QOllo9ZKby2/QThcJ8ySif9
# Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFjnXshbcOco6I8
# +n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2eGq4EQoO4tYCbIjggtSXlZOz39L9+
# Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7cQnfXXSYIghh
# 2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5ha293qYHLpwmsObvsxsvYgrRy
# zR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjmmC3qjeAzLhIp9cAvVCch98isTtoo
# uLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZii8bxyGvWbWu3EQ8l1Bx
# 16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4ZOC+8z1gFLu8NoFA12u8JJxzVs341
# Hgi62jbb01+P3nSISRKhggLOMIICNwIBATCB+KGB0KSBzTCByjELMAkGA1UEBhMC
# VVMxCzAJBgNVBAgTAldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9w
# ZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046QUI0MS00
# QjI3LUYwMjYxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIHNlcnZpY2Wi
# IwoBATAHBgUrDgMCGgMVAHgq8wD2Onemka/iTyB8ERMyTtcdoIGDMIGApH4wfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDfeY12
# MCIYDzIwMTgxMDIzMjAwNzE4WhgPMjAxODEwMjQyMDA3MThaMHcwPQYKKwYBBAGE
# WQoEATEvMC0wCgIFAN95jXYCAQAwCgIBAAICJMUCAf8wBwIBAAICE9AwCgIFAN96
# 3vYCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAweh
# IKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQCKWMNUhZrgaB7ldP4EU8rX
# VGtHJEmQAE5QITT52vZqPlSKGDBZhbkQJF+rRZyihp1nidExiZMqLIA4s4WyeoRL
# TQKwByOvgWnhKywB2BxyYqjZieZoKvE3v6kfL/1w8om+0NF9z1l6CO/uoWkubPOc
# /BKi7ECd9Kj+nw6180ow+DGCAw0wggMJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQSAyMDEwAhMzAAAA3IYTqAXYFYtHAAAAAADcMA0GCWCGSAFlAwQCAQUA
# oIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIE
# IJB5wclIhpJt/k1Z8WDbka7iiuIeWfgoSnMHVp4JJIKvMIH6BgsqhkiG9w0BCRAC
# LzGB6jCB5zCB5DCBvQQgG8/ujUiuMWjU8VCLYM12DSowo3Js7CpNKIQ7Etnarl0w
# gZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
# JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAANyGE6gF
# 2BWLRwAAAAAA3DAiBCA/Zr5p5d6dt/iHCulOvudVriOgp2iOeGXFKv+PF4VwrjAN
# BgkqhkiG9w0BAQsFAASCAQBiMbGvhhT4TJDNaRRTKnUC1ldWZNphRB0UHIs6V/F+
# b8HyW0ls1MNqGYTjA1SLPKzr1O5XnGv+R7cphZiqYc1+dCfWD/hI+T9O/0JJeoRu
# nBZUbDIko72hoQVf7pXP0T7uk3ibAkPIdZTPWjJW6K+PuWCP7l0JiC4E9uv8luC0
# w/inMDAPChXURlY5pm7glbUeODegPngnxt1FUvQCwkvEnqGRxAvNql/mG9pcas2t
# FGb8OQRqrp5oaGBn1V2TJlr70p96y1EkX6bIMfaft9Q58k5IRJTA8R0u6Ef4uJrb
# UDKZFKt5i1csYRxvNsW+eNqu7KLeaSrF7yZxwzVF61iv
# SIG # End signature block
