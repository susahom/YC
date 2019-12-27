' Windows Installer utility to add a transform or nested database as a substorage
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the database _Storages table
'
Option Explicit

Const msiOpenDatabaseModeReadOnly     = 0
Const msiOpenDatabaseModeTransact     = 1
Const msiOpenDatabaseModeCreate       = 3

Const msiViewModifyInsert         = 1
Const msiViewModifyUpdate         = 2
Const msiViewModifyAssign         = 3
Const msiViewModifyReplace        = 4
Const msiViewModifyDelete         = 6

Const ForAppending = 8
Const ForReading = 1
Const ForWriting = 2
Const TristateTrue = -1

' Check arg count, and display help if argument not present or contains ?
Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If (argCount = 0) Then
	Wscript.Echo "Windows Installer database substorage managment utility" &_
		vbNewLine & " 1st argument is the path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is the path to a transform or database to import" &_
		vbNewLine & " If the 2nd argument is missing, substorages will be listed" &_
		vbNewLine & " 3rd argument is optional, the name used for the substorage" &_
		vbNewLine & " If the 3rd arugment is missing, the file name is used" &_
		vbNewLine & " To remove a substorage, use /D or -D as the 2nd argument" &_
		vbNewLine & " followed by the name of the substorage to remove" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Evaluate command-line arguments and set open and update modes
Dim databasePath:databasePath = Wscript.Arguments(0)
Dim openMode    : If argCount = 1 Then openMode = msiOpenDatabaseModeReadOnly Else openMode = msiOpenDatabaseModeTransact
Dim updateMode  : If argCount > 1 Then updateMode = msiViewModifyAssign  'Either insert or replace existing row
Dim importPath  : If argCount > 1 Then importPath = Wscript.Arguments(1)
Dim storageName : If argCount > 2 Then storageName = Wscript.Arguments(2)
If storageName = Empty And importPath <> Empty Then storageName = Right(importPath, Len(importPath) - InStrRev(importPath, "\",-1,vbTextCompare))
If UCase(importPath) = "/D" Or UCase(importPath) = "-D" Then updateMode = msiViewModifyDelete : importPath = Empty 'substorage will be deleted if no input data

' Open database and create a view on the _Storages table
Dim sqlQuery : Select Case updateMode
	Case msiOpenDatabaseModeReadOnly: sqlQuery = "SELECT `Name` FROM _Storages"
	Case msiViewModifyAssign:         sqlQuery = "SELECT `Name`,`Data` FROM _Storages"
	Case msiViewModifyDelete:         sqlQuery = "SELECT `Name` FROM _Storages WHERE `Name` = ?"
End Select
Dim database : Set database = installer.OpenDatabase(databasePath, openMode) : CheckError
Dim view     : Set view = database.OpenView(sqlQuery)
Dim record

If openMode = msiOpenDatabaseModeReadOnly Then 'If listing storages, simply fetch all records
	Dim message, name
	view.Execute : CheckError
	Do
		Set record = view.Fetch
		If record Is Nothing Then Exit Do
		name = record.StringData(1)
		If message = Empty Then message = name Else message = message & vbNewLine & name
	Loop
	Wscript.Echo message
Else 'If adding a storage, insert a row, else if removing a storage, delete the row
	Set record = installer.CreateRecord(2)
	record.StringData(1) = storageName
	view.Execute record : CheckError
	If importPath <> Empty Then  'Insert storage - copy data into stream
		record.SetStream 2, importPath : CheckError
	Else  'Delete storage, fetch first to provide better error message if missing
		Set record = view.Fetch
		If record Is Nothing Then Wscript.Echo "Storage not present:", storageName : Wscript.Quit 2
	End If
	view.Modify updateMode, record : CheckError
	database.Commit : CheckError
	Set view = Nothing
	Set database = Nothing
	CheckError
End If

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
'' SIG '' MIIirgYJKoZIhvcNAQcCoIIinzCCIpsCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' sTAYbRu9/MmUNmYRZx8kYofzzKM5ELfE6P0ECXnWOFWg
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
'' SIG '' Bmrm1MbfI5qWdcUxghaFMIIWgQIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgPx5Ydb0eocKGuSqV7yII1JQhIeeOjapMIdMo3bll
'' SIG '' OXwwPAYKKwYBBAGCNwoDHDEuDCxIQU9MQXduclNIb0xm
'' SIG '' b3IxVHlNcGZxbEI0VXF0d0pJQWQ1c2E0VXU2R1EwPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAKrowIWuTNMjyjYMdgZJVEZNYZiJWzEE
'' SIG '' FpwgWJk8QZUq4bnxsM8F+R1tJRv6CxPjkV/pTcq3zL7t
'' SIG '' UdHJPm9gZHHHg6IPlkZfTCWGeWcyYPrfmMA0lCgGcBb6
'' SIG '' ouHVjQittH9+pf2wh5cs/vtIfUCLvWjGNOFqDXi7NMee
'' SIG '' /cJ7lx6Hw9aw6wR7oEnfKD7BC0luz9ZVpdQrM3eWyf/z
'' SIG '' Bp5x61SUMlQ/5oQtRE37Mfp2qR50wBMrzfEW1f4RtAsy
'' SIG '' 5xX45DX96HMDVNrLfzemjLfpKcd/HSPsq6kHyiqs53rn
'' SIG '' 2oMblBaLv5HKHbdz0IB6NNRDP1i6NxkOnrkpYzAq5r7P
'' SIG '' bwWhghO4MIITtAYKKwYBBAGCNwMDATGCE6QwghOgBgkq
'' SIG '' hkiG9w0BBwKgghORMIITjQIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVwYLKoZIhvcNAQkQAQSgggFGBIIBQjCCAT4C
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' 7aUHrcGiFt5k+HJFA04yW0g5Ue/QEKDeeIGq171JRycC
'' SIG '' BlvOENczHhgSMjAxODEwMjMxNzQ5MjguNDNaMAcCAQGA
'' SIG '' AgH0oIHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkw
'' SIG '' JwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVy
'' SIG '' dG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046
'' SIG '' QjFCNy1GNjdGLUZFQzIxJTAjBgNVBAMTHE1pY3Jvc29m
'' SIG '' dCBUaW1lLVN0YW1wIFNlcnZpY2Wggg8hMIIE9TCCA92g
'' SIG '' AwIBAgITMwAAANK441ptxFsadwAAAAAA0jANBgkqhkiG
'' SIG '' 9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MDAeFw0xODA4MjMyMDI2MzRaFw0xOTExMjMyMDI2MzRa
'' SIG '' MIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBN
'' SIG '' aWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
'' SIG '' MCQGA1UECxMdVGhhbGVzIFRTUyBFU046QjFCNy1GNjdG
'' SIG '' LUZFQzIxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
'' SIG '' YW1wIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUAA4IB
'' SIG '' DwAwggEKAoIBAQC+qpQoHYm0mqG66gSozjjHawbPv9kM
'' SIG '' IM7rjzn5nQkwULjbO6VsrEN/TxBqhKR0WNIhlBmDYKZ8
'' SIG '' z55RtjFJjIhmsZzpL1u/xfXTpDNmLAlWRmpMzuH4pYVD
'' SIG '' 6ASSnEnE7oDhuaONwt1bZfs24rsdpbI0xZNMN4xSH/RV
'' SIG '' A9efrLJFmdHDn4R3tgUH1mk6SY9LN2kuEk7Fpt0tlVYW
'' SIG '' 1+pWZrY6qHe6PFsfD6QlaRgMoCk0DDaTYFSqldu1Nw2G
'' SIG '' IYZoYnQS74qs4HwN9LVAzs/W1zK4NvTGtKbxWn5SAFZ1
'' SIG '' qDQGVXGKqxl3e8pWuCOrOzMKsHIrDdNESpV1ZzK+kpW6
'' SIG '' OJdFAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQU7Kw4cXX6
'' SIG '' l8kj+VJyZUngPaJ34M4wHwYDVR0jBBgwFoAU1WM6XIox
'' SIG '' kPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmgR4ZF
'' SIG '' aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
'' SIG '' cHJvZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEu
'' SIG '' Y3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+
'' SIG '' aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
'' SIG '' cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQwDAYD
'' SIG '' VR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDCDAN
'' SIG '' BgkqhkiG9w0BAQsFAAOCAQEARs9DKXEcDr02d0F6vRVn
'' SIG '' sIACciomkhaYKLn5bPll+AMj0Jg/y5wfmXCUeS0J6B73
'' SIG '' VnkIsx/ZVvEp24krbJx9ZlTyHOOTYez7yhy43a5Htysu
'' SIG '' B7eVYnCgGbtfL3S98VONnlDpDBuBepy+ZyQcg006edb8
'' SIG '' Tk/1v1ktdj2WZnMDbOp2Sq00/05htEFzZGdCi+ZKRfwk
'' SIG '' e/07TvD1UPXIgjpf/trZ6R6cI/FN17Ly2igHJPUc6aFh
'' SIG '' 0OHRd83kSllwO6luqXsbxV+p5ifyhSbH7UQFcGf2eZgv
'' SIG '' iziHCZZZ+GUxAChFvhz38o5fgUuciJd3aoZ1RbpLeUC7
'' SIG '' FpSjVECk+XzZ+zCCBnEwggRZoAMCAQICCmEJgSoAAAAA
'' SIG '' AAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVT
'' SIG '' MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
'' SIG '' ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
'' SIG '' YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENl
'' SIG '' cnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcw
'' SIG '' MTIxMzY1NVoXDTI1MDcwMTIxNDY1NVowfDELMAkGA1UE
'' SIG '' BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
'' SIG '' BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
'' SIG '' b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
'' SIG '' bWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEB
'' SIG '' AQUAA4IBDwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/
'' SIG '' aZRrdFQQ1aUKAIKF++18aEssX8XD5WHCdrc+Zitb8BVT
'' SIG '' JwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRDDNdNuDgI
'' SIG '' s0Ldk6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKE
'' SIG '' HnRhZ5FfgVSxz5NMksHEpl3RYRNuKMYa+YaAu99h/EbB
'' SIG '' Jx0kZxJyGiGKr0tkiVBisV39dx898Fd1rL2KQk1AUdEP
'' SIG '' nAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2
'' SIG '' iAg16HgcsOmZzTznL0S6p/TcZL2kAcEgCZN4zfy8wMlE
'' SIG '' XV4WnAEFTyJNAgMBAAGjggHmMIIB4jAQBgkrBgEEAYI3
'' SIG '' FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8Uz
'' SIG '' aFqFbVUwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEw
'' SIG '' CwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
'' SIG '' VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYD
'' SIG '' VR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3Nv
'' SIG '' ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9vQ2Vy
'' SIG '' QXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4w
'' SIG '' TDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3Nv
'' SIG '' ZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRfMjAx
'' SIG '' MC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCBkjCBjwYJ
'' SIG '' KwYBBAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8v
'' SIG '' d3d3Lm1pY3Jvc29mdC5jb20vUEtJL2RvY3MvQ1BTL2Rl
'' SIG '' ZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBn
'' SIG '' AGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0A
'' SIG '' ZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQAH5ohR
'' SIG '' DeLG4Jg/gXEDPZ2joSFvs+umzPUxvs8F4qn++ldtGTCz
'' SIG '' wsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM
'' SIG '' 9GASinbMQEBBm9xcF/9c+V4XNZgkVkt070IQyK+/f8Z/
'' SIG '' 8jd9Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvkx872ynoA
'' SIG '' b0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWO
'' SIG '' M7tiX5rbV0Dp8c6ZZpCM/2pif93FSguRJuI57BlKcWOd
'' SIG '' eyFtw5yjojz6f32WapB4pm3S4Zz5Hfw42JT0xqUKloak
'' SIG '' vZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45V3ai
'' SIG '' caoGig+JFrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9d
'' SIG '' dJgiCGHasFAeb73x4QDf5zEHpJM692VHeOj4qEir995y
'' SIG '' fmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEegPsbiSpU
'' SIG '' ObJb2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO
'' SIG '' 2ii4sanblrKnQqLJzxlBTeCG+SqaoxFmMNO7dDJL32N7
'' SIG '' 9ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M
'' SIG '' 5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUe
'' SIG '' CLraNtvTX4/edIhJEqGCA68wggKXAgEBMIH+oYHUpIHR
'' SIG '' MIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBN
'' SIG '' aWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
'' SIG '' MCQGA1UECxMdVGhhbGVzIFRTUyBFU046QjFCNy1GNjdG
'' SIG '' LUZFQzIxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
'' SIG '' YW1wIFNlcnZpY2WiJQoBATAJBgUrDgMCGgUAAxUAcPgo
'' SIG '' f9VSM5lFaTg3Dr/lOZju88Kggd4wgdukgdgwgdUxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29m
'' SIG '' dCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMScwJQYDVQQL
'' SIG '' Ex5uQ2lwaGVyIE5UUyBFU046NTdGNi1DMUUwLTU1NEMx
'' SIG '' KzApBgNVBAMTIk1pY3Jvc29mdCBUaW1lIFNvdXJjZSBN
'' SIG '' YXN0ZXIgQ2xvY2swDQYJKoZIhvcNAQEFBQACBQDfedFD
'' SIG '' MCIYDzIwMTgxMDI0MDA1NjM1WhgPMjAxODEwMjUwMDU2
'' SIG '' MzVaMHYwPAYKKwYBBAGEWQoEATEuMCwwCgIFAN950UMC
'' SIG '' AQAwCQIBAAIBAQIB/zAHAgEAAgIW4zAKAgUA33siwwIB
'' SIG '' ADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEEAYRZCgMB
'' SIG '' oAowCAIBAAIDFuNgoQowCAIBAAIDB6EgMA0GCSqGSIb3
'' SIG '' DQEBBQUAA4IBAQAKynoh9WnmbKCgp13P31+v3YEtcVf0
'' SIG '' 8Zrhlas8hA7XnbakTyKLM9zezb1ttYukUN0kbziEdqqM
'' SIG '' zLULKj1FjaVT7i/mO6gVFSc0fTSXmmciirmCMWmDuznr
'' SIG '' 9l1S3VxWpcG82WWlZ+LBlp1bgS3fbjG5+4jdP2bXw+1Q
'' SIG '' eYSBMtTuDJBfLWvJv6jldDtgM3xMuIDbAQD3iVP3ZGP1
'' SIG '' 4frdSd0g+/xnu+7xNVcaPL6zgfCUADUm0hTrFNaiDqqR
'' SIG '' YXjdhuqMZitOwYwZTYz/VnhcbgGWd9trR/ATFJALsESv
'' SIG '' iOmkas3k7N9DbJ/mmV1Q4NbWfAq+dD2hMlRKjXpbRQHn
'' SIG '' izQcMYIC9TCCAvECAQEwgZMwfDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
'' SIG '' bXAgUENBIDIwMTACEzMAAADSuONabcRbGncAAAAAANIw
'' SIG '' DQYJYIZIAWUDBAIBBQCgggEyMBoGCSqGSIb3DQEJAzEN
'' SIG '' BgsqhkiG9w0BCRABBDAvBgkqhkiG9w0BCQQxIgQg8w3c
'' SIG '' HR1YFkTv4QXPftl0YT1dbl67XdttD4q1tBQq/U0wgeIG
'' SIG '' CyqGSIb3DQEJEAIMMYHSMIHPMIHMMIGxBBRw+Ch/1VIz
'' SIG '' mUVpODcOv+U5mO7zwjCBmDCBgKR+MHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwAhMzAAAA0rjjWm3EWxp3AAAA
'' SIG '' AADSMBYEFMyWODepbKWnkG2UySoYYQ8mzCjHMA0GCSqG
'' SIG '' SIb3DQEBCwUABIIBAFu/ySZE5gjB9HEDGZ50lnu1CNeW
'' SIG '' Pg3QkESNXUd8LmzTdhY7wt9gab6deueqPE/cwD/92+2g
'' SIG '' h36WMQ/DN+LeCkbnh6pMtOJDVi+kAriqkRlkofGVJfzz
'' SIG '' byRJtW5qNVxrYfApnVEGho96DMTJCNyqMZK2XAxuhs+d
'' SIG '' lg1xY+WDKSsuE4WQXm0Tz59816WkOFMeredxar42PhpN
'' SIG '' oKA04dtzCBd75LL6/SA8SDRZMKKVEnboXVAi4qvJa+T0
'' SIG '' XEjH3R6QBcRc7xaO5GOUabXOzf6TFpyHBeahJ5znB2Ez
'' SIG '' fXwiw6QTjZPUxwasOARNTFFybUiKZJvWmZIMFLwAOXJU
'' SIG '' sLRg9DE=
'' SIG '' End signature block
