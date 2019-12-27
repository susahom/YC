' Windows Installer database utility to merge data from another database              
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the Database.Merge method and MsiDatabaseMerge API
'
Option Explicit

Const msiOpenDatabaseModeReadOnly     = 0
Const msiOpenDatabaseModeTransact     = 1
Const msiOpenDatabaseModeCreate       = 3
Const ForAppending = 8
Const ForReading = 1
Const ForWriting = 2
Const TristateTrue = -1

Dim argCount:argCount = Wscript.Arguments.Count
Dim iArg:iArg = 0
If (argCount < 2) Then
	Wscript.Echo "Windows Installer database merge utility" &_
		vbNewLine & " 1st argument is the path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is the path to database containing data to merge" &_
		vbNewLine & " 3rd argument is the optional table to contain the merge errors" &_
		vbNewLine & " If 3rd argument is not present, the table _MergeErrors is used" &_
		vbNewLine & "  and that table will be dropped after displaying its contents." &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Open databases and merge data
Dim database1 : Set database1 = installer.OpenDatabase(WScript.Arguments(0), msiOpenDatabaseModeTransact) : CheckError
Dim database2 : Set database2 = installer.OpenDatabase(WScript.Arguments(1), msiOpenDatabaseModeReadOnly) : CheckError
Dim errorTable : errorTable = "_MergeErrors"
If argCount >= 3 Then errorTable = WScript.Arguments(2)
Dim hasConflicts:hasConflicts = database1.Merge(database2, errorTable) 'Old code returns void value, new returns boolean
If hasConflicts <> True Then hasConflicts = CheckError 'Temp for old Merge function that returns void
If hasConflicts <> 0 Then
	Dim message, line, view, record
	Set view = database1.OpenView("Select * FROM `" & errorTable & "`") : CheckError
	view.Execute
	Do
		Set record = view.Fetch
		If record Is Nothing Then Exit Do
		line = record.StringData(1) & " table has " & record.IntegerData(2) & " conflicts"
		If message = Empty Then message = line Else message = message & vbNewLine & line
	Loop
	Set view = Nothing
	Wscript.Echo message
End If
If argCount < 3 And hasConflicts Then database1.OpenView("DROP TABLE `" & errorTable & "`").Execute : CheckError
database1.Commit : CheckError
Quit 0

Function CheckError
	Dim message, errRec
	CheckError = 0
	If Err = 0 Then Exit Function
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbNewLine & errRec.FormatText : CheckError = errRec.IntegerData(1)
	End If
	If CheckError = 2268 Then Err.Clear : Exit Function
	Wscript.Echo message
	Wscript.Quit 2
End Function

'' SIG '' Begin signature block
'' SIG '' MIIioAYJKoZIhvcNAQcCoIIikTCCIo0CAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' QXX+BeRpnj5/3w9MZiLTEbzssoFPyxBqr0/6QcQWjb+g
'' SIG '' gguBMIIFCTCCA/GgAwIBAgITMwAAAiRtkuVYynX+eAAA
'' SIG '' AAACJDANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBT
'' SIG '' aWduaW5nIFBDQSAyMDEwMB4XDTE4MDUzMTE3MzcwMloX
'' SIG '' DTE5MDUyOTE3MzcwMlowfzELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEpMCcGA1UEAxMgTWljcm9zb2Z0IFdpbmRvd3MgS2l0
'' SIG '' cyBQdWJsaXNoZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
'' SIG '' DwAwggEKAoIBAQC1ADtV5WbtbteGtgU9cNUX+b0OGB/W
'' SIG '' JCQMdiliySB/iACnI6QBanWCXt2GKq/H1dU4weRkdFJD
'' SIG '' QNd89v4hppxxFFeZpmhVfQapRAJf7giq9ke3HOjj8J7v
'' SIG '' jruaSdUERWdrpPmTI4D2RD8aSIrVd/K3gsIMUEW8mQjU
'' SIG '' f44qK7H7B9ZJs494Ua0c8Fs7gMbsGW+6+wDpMYAdeei2
'' SIG '' E4k2GOwhTEZwEnFawKbNg6mNyYiP5M5aFL+YECsKdaF3
'' SIG '' 136fer6lnaSjZVmtvlXy8Y+ARevpAtaNA5GWBZeDBP9h
'' SIG '' d/F7sPelxRghJlxoheacIx60A4IPxR2yAAVfmaUoHTw9
'' SIG '' KS7ZAgMBAAGjggF9MIIBeTAfBgNVHSUEGDAWBgorBgEE
'' SIG '' AYI3CgMUBggrBgEFBQcDAzAdBgNVHQ4EFgQU9N7wcxha
'' SIG '' V2r8PhDt3mJo/Q620powVAYDVR0RBE0wS6RJMEcxLTAr
'' SIG '' BgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
'' SIG '' bnMgTGltaXRlZDEWMBQGA1UEBRMNMjI5OTAzKzQzNjA4
'' SIG '' OTAfBgNVHSMEGDAWgBTm/F97uyIAWORyTrX0IXQjMubv
'' SIG '' rDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1p
'' SIG '' Y3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWND
'' SIG '' b2RTaWdQQ0FfMjAxMC0wNy0wNi5jcmwwWgYIKwYBBQUH
'' SIG '' AQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1p
'' SIG '' Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY0NvZFNpZ1BD
'' SIG '' QV8yMDEwLTA3LTA2LmNydDAMBgNVHRMBAf8EAjAAMA0G
'' SIG '' CSqGSIb3DQEBCwUAA4IBAQDkadQCXIoOfikTJJIeXscy
'' SIG '' BXfju3HHVX+X4KZs2VaywFNnDCIJG419qelfMGwzOS2N
'' SIG '' v1ajauk8Jfz3Sg3/BGACMW2fid9gBczR/7IAXJHtKgxk
'' SIG '' NB0/t0YH10ep/6lkK0nM/8O9HWoV/c7i4LdIfTieF7MD
'' SIG '' AUrpMkwVX0AEWk38tz497QVPkDwR7Ugw2AOS5qnRiwev
'' SIG '' CvAk67mtKYPKd1MdVu06e3dF/iglNZuvBWIeKFaz0du0
'' SIG '' sBhXrmpO/rix/C1e1Tpg+dpv8t131u/rIzaFQYsdbNaS
'' SIG '' Z7NfbUXotR2wnWlgBr8O8uT3sdpvekrlTZ2JA0umPZXw
'' SIG '' oZehh4icZ90NMIIGcDCCBFigAwIBAgIKYQxSTAAAAAAA
'' SIG '' AzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2Vy
'' SIG '' dGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzA2
'' SIG '' MjA0MDE3WhcNMjUwNzA2MjA1MDE3WjB+MQswCQYDVQQG
'' SIG '' EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
'' SIG '' BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
'' SIG '' cnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29k
'' SIG '' ZSBTaWduaW5nIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0B
'' SIG '' AQEFAAOCAQ8AMIIBCgKCAQEA6Q5kUHlntcTj/QkATJ6U
'' SIG '' rPdWaOpE2M/FWE+ppXZ8bUW60zmStKQe+fllguQX0o/9
'' SIG '' RJwI6GWTzixVhL99COMuK6hBKxi3oktuSUxrFQfe0dLC
'' SIG '' iR5xlM21f0u0rwjYzIjWaxeUOpPOJj/s5v40mFfVHV1J
'' SIG '' 9rIqLtWFu1k/+JC0K4N0yiuzO0bj8EZJwRdmVMkcvR3E
'' SIG '' VWJXcvhnuSUgNN5dpqWVXqsogM3Vsp7lA7Vj07IUyMHI
'' SIG '' iiYKWX8H7P8O7YASNUwSpr5SW/Wm2uCLC0h31oVH1RC5
'' SIG '' xuiq7otqLQVcYMa0KlucIxxfReMaFB5vN8sZM4BqiU2j
'' SIG '' amZjeJPVMM+VHwIDAQABo4IB4zCCAd8wEAYJKwYBBAGC
'' SIG '' NxUBBAMCAQAwHQYDVR0OBBYEFOb8X3u7IgBY5HJOtfQh
'' SIG '' dCMy5u+sMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBB
'' SIG '' MAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8G
'' SIG '' A1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYG
'' SIG '' A1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0Nl
'' SIG '' ckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQRO
'' SIG '' MEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIw
'' SIG '' MTAtMDYtMjMuY3J0MIGdBgNVHSAEgZUwgZIwgY8GCSsG
'' SIG '' AQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3
'' SIG '' dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZh
'' SIG '' dWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBh
'' SIG '' AGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBtAGUA
'' SIG '' bgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAGnTvV08p
'' SIG '' e8QWhXi4UNMi/AmdrIKX+DT/KiyXlRLl5L/Pv5PI4zSp
'' SIG '' 24G43B4AvtI1b6/lf3mVd+UC1PHr2M1OHhthosJaIxrw
'' SIG '' jKhiUUVnCOM/PB6T+DCFF8g5QKbXDrMhKeWloWmMIpPM
'' SIG '' dJjnoUdD8lOswA8waX/+0iUgbW9h098H1dlyACxphnY9
'' SIG '' UdumOUjJN2FtB91TGcun1mHCv+KDqw/ga5uV1n0oUbCJ
'' SIG '' SlGkmmzItx9KGg5pqdfcwX7RSXCqtq27ckdjF/qm1qKm
'' SIG '' huyoEESbY7ayaYkGx0aGehg/6MUdIdV7+QIjLcVBy78d
'' SIG '' TMgW77Gcf/wiS0mKbhXjpn92W9FTeZGFndXS2z1zNfM8
'' SIG '' rlSyUkdqwKoTldKOEdqZZ14yjPs3hdHcdYWch8ZaV4XC
'' SIG '' v90Nj4ybLeu07s8n07VeafqkFgQBpyRnc89NT7beBVaX
'' SIG '' evfpUk30dwVPhcbYC/GO7UIJ0Q124yNWeCImNr7KsYxu
'' SIG '' qh3khdpHM2KPpMmRM19xHkCvmGXJIuhCISWKHC1g2TeJ
'' SIG '' QYkqFg/XYTyUaGBS79ZHmaCAQO4VgXc+nOBTGBpQHTiV
'' SIG '' mx5mMxMnORd4hzbOTsNfsvU9R1O24OXbC2E9KteSLM43
'' SIG '' Wj5AQjGkHxAIwlacvyRdUQKdannSF9PawZSOB3slcUSr
'' SIG '' Bmrm1MbfI5qWdcUxghZ3MIIWcwIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgfWTawCFEjkRs0Gg97AK61YDxU0xqytxYlV2TblYK
'' SIG '' w88wPAYKKwYBBAGCNwoDHDEuDCxDb3M1VzlaWUxRTldp
'' SIG '' SEl1b0RPbjVxYlNqbVFaamN2bTVsY3dRUlNxOEJJPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAD73nGM6YKoVZ3zPQKZleMqfQa6cM5Zy
'' SIG '' WDcPqMH2NvjhUQh0CIm2v8P1qmRBF7vBYYUCNRn8G5lc
'' SIG '' h7v5YIn+uSKH8VKaWH4Wi/vC41p6AHgizvI3YWbQ87TF
'' SIG '' UTEpxUQWaGTEsIgnbjPPjA6atjQ124GrErKKClWvmA16
'' SIG '' N6oMFT4PV/XoUeLYNncE0UHvrL9cyJmU+xKPvQt6Aoak
'' SIG '' q3m9lg9UHQXDLoX5misptOc/BEH+v9AwkJnxOabwJ9/z
'' SIG '' ht4SGDx9G6ukKVOvP46j8fJkOWWB1BApDotJp/quvSmQ
'' SIG '' fRABCKUGCVd830ylrAs+j6o1Ft8vXB/NqodNL7/h35O/
'' SIG '' sX+hghOqMIITpgYKKwYBBAGCNwMDATGCE5YwghOSBgkq
'' SIG '' hkiG9w0BBwKgghODMIITfwIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVAYLKoZIhvcNAQkQAQSgggFDBIIBPzCCATsC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' MpGW8plJZeWtiMG/MZ9IXwErRegGGqXrYVyAGa6urtMC
'' SIG '' BlvN/LUWOhgTMjAxODEwMjMxNzQ5MzAuOTE1WjAHAgEB
'' SIG '' gAIB9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEl
'' SIG '' MCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
'' SIG '' aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MTJF
'' SIG '' Ny0zMDY0LTYxMTIxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFNlcnZpY2Wggg8WMIIGcTCCBFmgAwIB
'' SIG '' AgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
'' SIG '' EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
'' SIG '' c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9z
'' SIG '' b2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
'' SIG '' MTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1
'' SIG '' WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIw
'' SIG '' DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3
'' SIG '' EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxfxcPl
'' SIG '' YcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/x
'' SIG '' YIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8k
'' SIG '' YDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSmXdFhE24o
'' SIG '' xhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3w
'' SIG '' V3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo
'' SIG '' 8noqCjHw2k4GkbaICDXoeByw6ZnNPOcvRLqn9NxkvaQB
'' SIG '' wSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHi
'' SIG '' MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpc
'' SIG '' ijGQ80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4K
'' SIG '' AFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
'' SIG '' BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2U
'' SIG '' kFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8v
'' SIG '' Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
'' SIG '' cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
'' SIG '' KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
'' SIG '' d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jv
'' SIG '' b0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/
'' SIG '' BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUH
'' SIG '' AgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9QS0kv
'' SIG '' ZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIw
'' SIG '' NB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBT
'' SIG '' AHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQEL
'' SIG '' BQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+
'' SIG '' zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RX
'' SIG '' CCtRgkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRW
'' SIG '' S3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl
'' SIG '' 2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCf
'' SIG '' Mkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVK
'' SIG '' C5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLhnPkd
'' SIG '' /DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/
'' SIG '' fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n
'' SIG '' 0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQekkzr3
'' SIG '' ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d
'' SIG '' 9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4S
'' SIG '' KfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN4Ib5Kpqj
'' SIG '' EWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV
'' SIG '' 42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQ
'' SIG '' NdrvCScc1bN+NR4Iuto229Nfj950iEkSMIIE8TCCA9mg
'' SIG '' AwIBAgITMwAAAOrhzv+as6aS0QAAAAAA6jANBgkqhkiG
'' SIG '' 9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MDAeFw0xODA4MjMyMDI3MTdaFw0xOTExMjMyMDI3MTda
'' SIG '' MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxN
'' SIG '' aWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYD
'' SIG '' VQQLEx1UaGFsZXMgVFNTIEVTTjoxMkU3LTMwNjQtNjEx
'' SIG '' MjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' U2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
'' SIG '' AQoCggEBAMF/fj4eWLInplrADQtKR3bLoAP6Epa/z76e
'' SIG '' s/PrnKUm5yFTCQZIb5VO12d57nKAZ986zJ56vzhzJUL1
'' SIG '' aYGhI6BPkz/hjF+bSQDrC57za47QEcdMFPwXt6+cqsLy
'' SIG '' wPsSoHZ4xR2ZiEnZGWeBWKqm21YUp2GMHDmvCG4d4R1B
'' SIG '' g7nd5mLbRrrYZmcccVeEeYFFCyLVeRt+tmN5j0Q49Hfx
'' SIG '' CnXABAOl5bseVholFdimLEYjtsHhzB+Pxvk+6bQ8MQEW
'' SIG '' W4DrS8JQpVJ3eHqAzm/BDxKJI1NfS0ToVRDace6sk7ZS
'' SIG '' i7fzOtvctL99weqb0sxZp9hb/53TDyfjLXqzXgcope0C
'' SIG '' AwEAAaOCARswggEXMB0GA1UdDgQWBBTSx7AXrhm+7XCC
'' SIG '' +1TppG23x8WlrjAfBgNVHSMEGDAWgBTVYzpcijGQ80N7
'' SIG '' fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRw
'' SIG '' Oi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
'' SIG '' dWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmww
'' SIG '' WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw
'' SIG '' Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
'' SIG '' Y1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMB
'' SIG '' Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4IBAQCnu80bmqAE6FpFbcaQf1SGO6ME
'' SIG '' exx5WAf/Hy0uWNB42I2PAZE5ay/Mf0ZmZhf8cT8davdY
'' SIG '' GYRvOqM5bh2TihA29VXIF46Nbx/5HUyjvgk/fh+RcuZg
'' SIG '' FAddcExbLXFOByWFy0XI1+spIhP/439m0YREx4g+thyk
'' SIG '' GZiHsE7imSgRkhWeoTSmPe2AKH/IqR50FDv8UE/TgbXW
'' SIG '' gUxCc0h78yyxcZXEXjgCIK6QLCRY9RNyInGEpUrAvvj3
'' SIG '' uN91X1lJEI3B2B/Vt9P2fy5RbGsDJrZ5fucK2XOSpMpS
'' SIG '' Z899DWP95dxF4VfHVxsiDBuK/khIxEtqqLxWsHp54SDQ
'' SIG '' Wyou/uLIoYIDqDCCApACAQEwgfqhgdCkgc0wgcoxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29m
'' SIG '' dCBBbWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOjEyRTctMzA2NC02MTEyMSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' oiUKAQEwCQYFKw4DAhoFAAMVADxmEkVQ2VanUQ6dzvi2
'' SIG '' 6jEMeABWoIHaMIHXpIHUMIHRMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
'' SIG '' cGVyYXRpb25zMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDfeWmPMCIYDzIwMTgxMDIzMDkz
'' SIG '' NDA3WhgPMjAxODEwMjQwOTM0MDdaMHcwPQYKKwYBBAGE
'' SIG '' WQoEATEvMC0wCgIFAN95aY8CAQAwCgIBAAICEuMCAf8w
'' SIG '' BwIBAAICGP0wCgIFAN96uw8CAQAwNgYKKwYBBAGEWQoE
'' SIG '' AjEoMCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEK
'' SIG '' MAgCAQACAwehIDANBgkqhkiG9w0BAQUFAAOCAQEAX/nN
'' SIG '' J2vYSz75HzbjYFOihWb0vCFbIOm+uvjzVYNaduGbnFcG
'' SIG '' P/hqMmpXy9bUZAK8Y3fKkz4ALRcOIDP9ihGtV1P0UVMq
'' SIG '' tMsnSVDsnTl4utOnGeD1Wx+gqv4naNmsLbEcjvZWDaYI
'' SIG '' VbgB19VaZs2RCZza0GOfENlqe0s3KKh+z8DA39yeSdNh
'' SIG '' 9nZVEI7752VT94zUjxBxF8E2JhRCRhAIhRoYrB6SvvFB
'' SIG '' G0BvnwUXkTmTBDIF986a/aVRgntc/J+rS8McRNU/DcfS
'' SIG '' B8a3cfchhX4XEsnThdxRXGA28xOpczwnHIl1CqUTCai0
'' SIG '' ovQMRYp4aQZnJfZFAdgjDBbbkBpWIDGCAvUwggLxAgEB
'' SIG '' MIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
'' SIG '' aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
'' SIG '' ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
'' SIG '' HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMz
'' SIG '' AAAA6uHO/5qzppLRAAAAAADqMA0GCWCGSAFlAwQCAQUA
'' SIG '' oIIBMjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQw
'' SIG '' LwYJKoZIhvcNAQkEMSIEINPaFcyXVsGTAOta7ws5pUX0
'' SIG '' qtBwUELQInycM3sUrd4bMIHiBgsqhkiG9w0BCRACDDGB
'' SIG '' 0jCBzzCBzDCBsQQUPGYSRVDZVqdRDp3O+LbqMQx4AFYw
'' SIG '' gZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MAITMwAAAOrhzv+as6aS0QAAAAAA6jAWBBTuwVQjEBEM
'' SIG '' zqPYP3b3tHbL6+qHzTANBgkqhkiG9w0BAQsFAASCAQCl
'' SIG '' qKgzjNWZG6b+F3+P1cY/lwU+HFaauUi6aeaOlmrqAJYT
'' SIG '' PYc5W+7QYd9uOHvL63p2iLHAGcAEzCoM3pe8ZpG0GVW3
'' SIG '' kNDTD91mqtLf9CoR0wAjcft+wvzPiI1/fqI9PKIgIE9y
'' SIG '' IWlySaff8W3udJQTc62gFbGqZe0AAJOMW+CFQy7W0RGm
'' SIG '' lRyOA2JxG2BDbNufwseYm7O8zbTC4e/GnXxz3NrdBqj+
'' SIG '' 1lGD41QpyjQ1lQEFKqL3Bc24/GnrmDx+P2Cqy32Ojt5t
'' SIG '' TOzbNrUT6/qqfgenaFpDWCGVIKd8orOQsJXh0jHVYxof
'' SIG '' qOfvkrUFbJCI81U+wBqucMJ8973ILrSo
'' SIG '' End signature block
