' Windows Installer transform viewer for use with Windows Scripting Host
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the database APIs for viewing transform files
'
Option Explicit

Const iteAddExistingRow      = 1
Const iteDelNonExistingRow   = 2
Const iteAddExistingTable    = 4
Const iteDelNonExistingTable = 8
Const iteUpdNonExistingRow   = 16
Const iteChangeCodePage      = 32
Const iteViewTransform       = 256

Const icdLong       = 0
Const icdShort      = &h400
Const icdObject     = &h800
Const icdString     = &hC00
Const icdNullable   = &h1000
Const icdPrimaryKey = &h2000
Const icdNoNulls    = &h0000
Const icdPersistent = &h0100
Const icdTemporary  = &h0000

Const idoReadOnly = 0

Dim gErrors, installer, base, database, argCount, arg, argValue
gErrors = iteAddExistingRow + iteDelNonExistingRow + iteAddExistingTable + iteDelNonExistingTable + iteUpdNonExistingRow + iteChangeCodePage
Set database = Nothing

' Check arg count, and display help if no all arguments present
argCount = WScript.Arguments.Count
If (argCount < 2) Then
	WScript.Echo "Windows Installer Transform Viewer for Windows Scripting Host (CScript.exe)" &_
		vbNewLine & " 1st non-numeric argument is path to base database which transforms reference" &_
		vbNewLine & " Subsequent non-numeric arguments are paths to the transforms to be viewed" &_
		vbNewLine & " Numeric argument is optional error suppression flags (default is ignore all)" &_
		vbNewLine & " Arguments are executed left-to-right, as encountered" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Cannot run with GUI script host, as listing is performed to standard out
If UCase(Mid(Wscript.FullName, Len(Wscript.Path) + 2, 1)) = "W" Then
	WScript.Echo "Cannot use WScript.exe - must use CScript.exe with this program"
	Wscript.Quit 2
End If

' Create installer object
On Error Resume Next
Set installer = CreateObject("WindowsInstaller.Installer") : CheckError

' Process arguments, opening database and applying transforms
For arg = 0 To argCount - 1
	argValue = WScript.Arguments(arg)
	If IsNumeric(argValue) Then
		gErrors = argValue
	ElseIf database Is Nothing Then
		Set database = installer.OpenDatabase(argValue, idoReadOnly)
	Else
		database.ApplyTransform argValue, iteViewTransform + gErrors
	End If
	CheckError
Next
ListTransform(database)

Function DecodeColDef(colDef)
	Dim def
	Select Case colDef AND (icdShort OR icdObject)
	Case icdLong
		def = "LONG"
	Case icdShort
		def = "SHORT"
	Case icdObject
		def = "OBJECT"
	Case icdString
		def = "CHAR(" & (colDef AND 255) & ")"
	End Select
	If (colDef AND icdNullable)   =  0 Then def = def & " NOT NULL"
	If (colDef AND icdPrimaryKey) <> 0 Then def = def & " PRIMARY KEY"
	DecodeColDef = def
End Function

Sub ListTransform(database)
	Dim view, record, row, column, change
	On Error Resume Next
	Set view = database.OpenView("SELECT * FROM `_TransformView` ORDER BY `Table`, `Row`") : CheckError
	view.Execute : CheckError
	Do
		Set record = view.Fetch : CheckError
		If record Is Nothing Then Exit Do
		change = Empty
		If record.IsNull(3) Then
			row = "<DDL>"
			If NOT record.IsNull(4) Then change = "[" & record.StringData(5) & "]: " & DecodeColDef(record.StringData(4))
		Else
			row = "[" & Join(Split(record.StringData(3), vbTab, -1), ",") & "]"
			If record.StringData(2) <> "INSERT" AND record.StringData(2) <> "DELETE" Then change = "{" & record.StringData(5) & "}->{" & record.StringData(4) & "}"
		End If
		column = record.StringData(1) & " " & record.StringData(2)
		if Len(column) < 24 Then column = column & Space(24 - Len(column))
		WScript.Echo column, row, change
	Loop
End Sub

Sub CheckError
	Dim message, errRec
	If Err = 0 Then Exit Sub
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbNewLine & errRec.FormatText
	End If
	Wscript.Echo message
	Wscript.Quit 2
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIinwYJKoZIhvcNAQcCoIIikDCCIowCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' bSE4J2+6sdFrt3HJs8WbQ0/DQ6WkcvTESWq4fOF4kUmg
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
'' SIG '' Bmrm1MbfI5qWdcUxghZ2MIIWcgIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQg/M4LDrkBMu8VzYzK+dUbfaQ78LzdU1MwXYrmpbLq
'' SIG '' 3S8wPAYKKwYBBAGCNwoDHDEuDCw5VDF4M2J2UWhPc3F1
'' SIG '' U2w1WlpTUFNyUzlIN2VYK0RUUHVlUVZqSUNUNDBzPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAFOYLJ/i/X7CbcmA2tIE72WfbONtzfiF
'' SIG '' vcoKYcLXzINJnimxc1VEBrMccZGEvQTMu0PRFdSJrd/U
'' SIG '' SuNDY26gttBQQbBmTGn3hreEViD/uFwLIDgLsWbHRmgR
'' SIG '' b0BAyHVz2dTaieqtOKb/WB2LjYRfKKbyJWLgwg3oXnRb
'' SIG '' R88t22o0oO7ZRihKACHZJmr6LC+fWYR5F893s2PqoIsY
'' SIG '' LYvAgrpm472wf0a8T/ZkgpprnJvccvi9ESBdXDlnQmw8
'' SIG '' AgKvxwYN7V8MhjbYs3A8bYy3piesMqj1HTzldam2t5TF
'' SIG '' mNCNlo5zdqBM7c30leADzY2G6HfamT7vYwc8PdSvcip/
'' SIG '' FfyhghOpMIITpQYKKwYBBAGCNwMDATGCE5UwghORBgkq
'' SIG '' hkiG9w0BBwKgghOCMIITfgIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVAYLKoZIhvcNAQkQAQSgggFDBIIBPzCCATsC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' OJ2fzzZarsT3aZatwMuCVnUXAxb+Vj/Q+kcUIKnIgSIC
'' SIG '' BlvN8/gcnRgTMjAxODEwMjMxNzQ5MzAuODI0WjAHAgEB
'' SIG '' gAIB9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEl
'' SIG '' MCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
'' SIG '' aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RDIz
'' SIG '' Ni0zN0RBLTk3NjExJTAjBgNVBAMTHE1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFNlcnZpY2Wggg8VMIIGcTCCBFmgAwIB
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
'' SIG '' AwIBAgITMwAAAMlK1n6YThTUewAAAAAAyTANBgkqhkiG
'' SIG '' 9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MDAeFw0xODA4MjMyMDI2MTNaFw0xOTExMjMyMDI2MTNa
'' SIG '' MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxN
'' SIG '' aWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYD
'' SIG '' VQQLEx1UaGFsZXMgVFNTIEVTTjpEMjM2LTM3REEtOTc2
'' SIG '' MTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' U2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
'' SIG '' AQoCggEBANYjaoQ2UEPBUNTS4UPpL11PaEO/UFNLuogX
'' SIG '' BRIhEBMP0ZudXHR08PQyWlZwZSrdggcB4/gEppzEUCZx
'' SIG '' yAOUpZLSqj75rxCViSABt0leuhOAHeX8MHDv6GobJL59
'' SIG '' GNHnZj2SbyXZEyYK++w1oEKJKVv2F2bmpuLSyX0SiYP3
'' SIG '' 6urUtPwQdm3rrtZ2aGa9alTK/Tl+pEiKDVcV2dKbVT3C
'' SIG '' JlSvlBhzjp214IHBzwJX7YACFIdXlQvuI9pCUaGLre96
'' SIG '' b8k1KFVveMWAx16HkfYt+XvCQpWGX6tkRHwmupbW56f4
'' SIG '' XOaelvCgJ5LnUpGXT8OsnvXU8EC5o9zp1sLjgdjnmBkC
'' SIG '' AwEAAaOCARswggEXMB0GA1UdDgQWBBQrhuMJAPMlE8c1
'' SIG '' b2VwuH4gDpp7JzAfBgNVHSMEGDAWgBTVYzpcijGQ80N7
'' SIG '' fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRw
'' SIG '' Oi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
'' SIG '' dWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmww
'' SIG '' WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw
'' SIG '' Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
'' SIG '' Y1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMB
'' SIG '' Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4IBAQAD1vATn1fy5B2lHrKdpjK5mmCz
'' SIG '' 4itQCTdCJC/bpW8vEm4jdnW818H08sQwt2GMnYIxq3T/
'' SIG '' usrLrDW7uaYrx16l9DyXeEis41mfEsEpVpCjqqaT0shx
'' SIG '' 4hmdD5JRgGCmG3La/HqlKtgoV+d6twPgBV52NgupSK5v
'' SIG '' KH6ni6M5rVphyYbaSR1a/DxAn5SyE2TpSg1XglyBBVPu
'' SIG '' QegAy7dI/1aLPZ4m92hS2j8HbEMzjlIDpaPVgxl4Xlxf
'' SIG '' c5csR4Ckr6ui3B35fDNrlyAy8uShmwkFveu+g8/uc6hG
'' SIG '' 2UZy97jAdcFPqofbWyFDhjjiSSMUGg1/EkUBpM/Y18iv
'' SIG '' uDB2UW9soYIDpzCCAo8CAQEwgfqhgdCkgc0wgcoxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29m
'' SIG '' dCBBbWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOkQyMzYtMzdEQS05NzYxMSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' oiUKAQEwCQYFKw4DAhoFAAMVAGSC4KoXbHiKw909SsGS
'' SIG '' ry/oPEgXoIHaMIHXpIHUMIHRMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
'' SIG '' cGVyYXRpb25zMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDfeWqdMCIYDzIwMTgxMDIzMDkz
'' SIG '' ODM3WhgPMjAxODEwMjQwOTM4MzdaMHYwPAYKKwYBBAGE
'' SIG '' WQoEATEuMCwwCgIFAN95ap0CAQAwCQIBAAIBGQIB/zAH
'' SIG '' AgEAAgIY6TAKAgUA33q8HQIBADA2BgorBgEEAYRZCgQC
'' SIG '' MSgwJjAMBgorBgEEAYRZCgMBoAowCAIBAAIDFuNgoQow
'' SIG '' CAIBAAIDHoSAMA0GCSqGSIb3DQEBBQUAA4IBAQCY9XDh
'' SIG '' 49ZJMvYSzuMFehiXg1zD/AOFeg8bL84lr7f4XzmJs1mt
'' SIG '' bc4MfajknHDXLTeO7ZtLGRFcO+73poTUxd5hlQPz88Bj
'' SIG '' 18PuGucJm0iFD513tlNOOi7MawdC2CH7kZbA58t5m/sZ
'' SIG '' mNen8ZgZ66bs8KiJbwZDODupcuvGC5TzlR4gSuS3kv1U
'' SIG '' Qjuc0CD9Kd36ogAQMcNVkjoLRUW7cF/IEAvizIle8Rh0
'' SIG '' 3xPoHGDe+wygLTyyd5Cn+BSkHpt2UhF097Iu9OYxJs9F
'' SIG '' 001URCGL3YqQV3vE7Nptfap0qKUlDqkwglKbjjNAqCEK
'' SIG '' CLOl5XtkrpvRpfd0kjKvifquLRSZMYIC9TCCAvECAQEw
'' SIG '' gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
'' SIG '' TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMA
'' SIG '' AADJStZ+mE4U1HsAAAAAAMkwDQYJYIZIAWUDBAIBBQCg
'' SIG '' ggEyMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAv
'' SIG '' BgkqhkiG9w0BCQQxIgQgePFwPS70R+O31XlbXpN/DO2k
'' SIG '' yYbF8hGupT1UMrFAylkwgeIGCyqGSIb3DQEJEAIMMYHS
'' SIG '' MIHPMIHMMIGxBBRkguCqF2x4isPdPUrBkq8v6DxIFzCB
'' SIG '' mDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
'' SIG '' YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
'' SIG '' VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
'' SIG '' BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
'' SIG '' AhMzAAAAyUrWfphOFNR7AAAAAADJMBYEFMrPHHamf7BZ
'' SIG '' nE4fKwi1sFGml2w3MA0GCSqGSIb3DQEBCwUABIIBAF2H
'' SIG '' h1CDWpHBtscqoI3iF6CyVfJIExaR2zGwcPnGCofoXnCG
'' SIG '' sh92ugmsPV0iQpyG474smCwIOiTFYxb4rI0iGbRu3w8U
'' SIG '' 6axTavzUSD6/a9dBhz8QfEd036wUBb4OpE5lZAYC+U32
'' SIG '' 9Jce23sQfXmMz7hNfOcGDRdvPUhpv/PJU4qwItFZxxla
'' SIG '' 1FtF41stzK21JiOlgiyDUryP8/kp4ZqV99RvgP3gnTaO
'' SIG '' WQMmLYA+l8D9I9n1V1rjZVzM6nkUoMxnDHuDBZ4AyiuW
'' SIG '' Zcxg9iFQTge7ItEPwgS/0/84SLFaoblBPbz68Dyv08tD
'' SIG '' +TJjcJLJ7nU6HXRM9wOXOMJWeSDy8e4=
'' SIG '' End signature block
