' Windows Installer utility to copy a file into a database text field
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates processing of primary key data
'
Option Explicit

Const msiOpenDatabaseModeReadOnly     = 0
Const msiOpenDatabaseModeTransact     = 1

Const msiViewModifyUpdate  = 2
Const msiReadStreamAnsi    = 2

Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If (argCount < 4) Then
	Wscript.Echo "Windows Installer utility to copy a file into a database text field." &_
		vbNewLine & "The 1st argument is the path to the installation database" &_
		vbNewLine & "The 2nd argument is the database table name" &_
		vbNewLine & "The 3rd argument is the set of primary key values, concatenated with colons" &_
		vbNewLine & "The 4th argument is non-key column name to receive the text data" &_
		vbNewLine & "The 5th argument is the path to the text file to copy" &_
		vbNewLine & "If the 5th argument is omitted, the existing data will be listed" &_
		vbNewLine & "All primary keys values must be specified in order, separated by colons" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError


' Process input arguments and open database
Dim databasePath: databasePath = Wscript.Arguments(0)
Dim tableName   : tableName    = Wscript.Arguments(1)
Dim rowKeyValues: rowKeyValues = Split(Wscript.Arguments(2),":",-1,vbTextCompare)
Dim dataColumn  : dataColumn   = Wscript.Arguments(3)
Dim openMode : If argCount >= 5 Then openMode = msiOpenDatabaseModeTransact Else openMode = msiOpenDatabaseModeReadOnly
Dim database : Set database = installer.OpenDatabase(databasePath, openMode) : CheckError
Dim keyRecord : Set keyRecord = database.PrimaryKeys(tableName) : CheckError
Dim keyCount : keyCount = keyRecord.FieldCount
If UBound(rowKeyValues) + 1 <> keyCount Then Fail "Incorrect number of primary key values"

' Generate and execute query
Dim predicate, keyIndex
For keyIndex = 1 To keyCount
	If Not IsEmpty(predicate) Then predicate = predicate & " AND "
	predicate = predicate & "`" & keyRecord.StringData(keyIndex) & "`='" & rowKeyValues(keyIndex-1) & "'"
Next
Dim query : query = "SELECT `" & dataColumn & "` FROM `" & tableName & "` WHERE " & predicate
REM Wscript.Echo query 
Dim view : Set view = database.OpenView(query) : CheckError
view.Execute : CheckError
Dim resultRecord : Set resultRecord = view.Fetch : CheckError
If resultRecord Is Nothing Then Fail "Requested table row not present"

' Update value if supplied. Cannot store stream object in string column, must convert stream to string
If openMode = msiOpenDatabaseModeTransact Then
	resultRecord.SetStream 1, Wscript.Arguments(4) : CheckError
	Dim sizeStream : sizeStream = resultRecord.DataSize(1)
	resultRecord.StringData(1) = resultRecord.ReadStream(1, sizeStream, msiReadStreamAnsi) : CheckError
	view.Modify msiViewModifyUpdate, resultRecord : CheckError
	database.Commit : CheckError
Else
	Wscript.Echo resultRecord.StringData(1)
End If

Sub CheckError
	Dim message, errRec
	If Err = 0 Then Exit Sub
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbNewLine & errRec.FormatText
	End If
	Fail message
End Sub

Sub Fail(message)
	Wscript.Echo message
	Wscript.Quit 2
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIh2wYJKoZIhvcNAQcCoIIhzDCCIcgCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' +n92KCymBpb0NXQZvmHi9Nqe+zPewtCgF8ON8kB0lL+g
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
'' SIG '' Bmrm1MbfI5qWdcUxghWyMIIVrgIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgVoGH4+dmBshTi+at5GlIupRaD+jboiJ/aGuZbreG
'' SIG '' i74wPAYKKwYBBAGCNwoDHDEuDCxxM2ZKVGVNam02L3Fl
'' SIG '' dEdiSXlUT0dJNHJsMHNVMnRWUVBHU2ZsenNTSHFFPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAF2m0MRAlkJYRs8LYXi3yd7PvtPa1qRC
'' SIG '' VfgbRVS4yDlFlE392VO3mRJXcaBo3UGCvcs28RM4+uPm
'' SIG '' haamFCN0K6wQnTEG5qFhPMPVK/uQxI9GF2v+ABvek5mU
'' SIG '' BvuSV7QxBJUTwCHYTgASTJUjURh7tWPn3VdITUg1Cxy9
'' SIG '' Um2kWVkET4iooBUfRZzGNjGugd2nY6egWU/Mfpu9GJAQ
'' SIG '' UTKIqYeDSKAItQKpVAlsH5Xq9XHOcWQdcxgV4g4gngfF
'' SIG '' 5Io9hlvJEw4ufnDqcIyRDYL59deTkFBP5i6Paz1XUYvR
'' SIG '' e4PkW2cpbhXw4xu59iDGc9Qh5WKVL5UO+PiN8XbkFXhZ
'' SIG '' Fn+hghLlMIIS4QYKKwYBBAGCNwMDATGCEtEwghLNBgkq
'' SIG '' hkiG9w0BBwKgghK+MIISugIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBUQYLKoZIhvcNAQkQAQSgggFABIIBPDCCATgC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' hoasSc58fyMwGDKbiCtSnwju6bCqtg0hkeu9XXJUMdAC
'' SIG '' Blx1QN0bzxgTMjAxOTAzMTkwMjU5MDYuNTQ4WjAEgAIB
'' SIG '' 9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
'' SIG '' AldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
'' SIG '' Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRl
'' SIG '' ZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046QTg0MS00
'' SIG '' QkI0LUNBOTMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIHNlcnZpY2Wggg48MIIE8TCCA9mgAwIBAgIT
'' SIG '' MwAAAN3k3jrsrfPx1AAAAAAA3TANBgkqhkiG9w0BAQsF
'' SIG '' ADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0x
'' SIG '' ODA4MjMyMDI2NTlaFw0xOTExMjMyMDI2NTlaMIHKMQsw
'' SIG '' CQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
'' SIG '' bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
'' SIG '' aGFsZXMgVFNTIEVTTjpBODQxLTRCQjQtQ0E5MzElMCMG
'' SIG '' A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgc2Vydmlj
'' SIG '' ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
'' SIG '' AI2HFT+p60pioPFxF0JFH0FdkfmtnSYM79IlChuL5gn8
'' SIG '' JnHTOe7lvOPihN7+byvgMUb/oZzLtHhgWYNNLr92jGns
'' SIG '' 45bC9D2XFDJNfZakEvepG+q8UNXJRlpqlEM70H/trnwT
'' SIG '' v/auR3TTqDBbjol39+7JPkf0iA8Eh8FmXssKfbdc4VUQ
'' SIG '' BsJXsHYc5WCBly5V7mpuJvTd7F6jwuAufpeTOGSRtjwy
'' SIG '' ZVfr0Gf9mlYmyFZjwdZNGB1YvCbUfvyW3si5YKZitmxC
'' SIG '' ITLLTNYhO/5yWYpA+ZQ6+t4hEQSTNn6kBqCVvlWFBhKN
'' SIG '' H1wMT23o1UzWBk7P9mGyKqdTs8QBbCwGfC0CAwEAAaOC
'' SIG '' ARswggEXMB0GA1UdDgQWBBR3Ufb2yehiI6WG6WMsfZbw
'' SIG '' 6OqPOTAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNo
'' SIG '' WoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
'' SIG '' aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB
'' SIG '' BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
'' SIG '' YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAA
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
'' SIG '' CwUAA4IBAQAlzHnuKr77BrCoI0wFCK9a/LlR7hf+c51/
'' SIG '' X62moyICoCCSpTk1s4CHchJtWyGrzCnl15FzEYiFXphm
'' SIG '' ZcmQhQ6C2w6qKFaWlmjJV1nTAvNFglqfhfB0q1FS1szY
'' SIG '' gp6tBzzJ6mU6mO5wmJ4zgEsBICIgW3GYuNZ1hRz/UxQ3
'' SIG '' ZuMPYyz5xajC9mdrcWJJMk/Z0vqfBM6mo6TxalpIsO6S
'' SIG '' 7M/NO9XdOTTghVgSAykXZvxf1y4NXOWAb/dLVXp3f3zH
'' SIG '' VPQV13qKaZKN3AvFo+50v/PG9NJNsHcYUUNX2p0RHAgC
'' SIG '' PahJ3AGk6LtbxNXg4POWSPBiyJifP6GZpHeJjh/rApNC
'' SIG '' MIIGcTCCBFmgAwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG
'' SIG '' 9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
'' SIG '' A1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUg
'' SIG '' QXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcN
'' SIG '' MjUwNzAxMjE0NjU1WjB8MQswCQYDVQQGEwJVUzETMBEG
'' SIG '' A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
'' SIG '' ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
'' SIG '' MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
'' SIG '' Q0EgMjAxMDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
'' SIG '' AQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0VBDVpQoA
'' SIG '' goX77XxoSyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3O
'' SIG '' CROOfGEwWbEwRA/xYIiEVEMM1024OAizQt2TrNZzMFcm
'' SIG '' gqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+BVLHP
'' SIG '' k0ySwcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqv
'' SIG '' S2SJUGKxXf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOW
'' SIG '' RH7v0Ev9buWayrGo8noqCjHw2k4GkbaICDXoeByw6ZnN
'' SIG '' POcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0C
'' SIG '' AwEAAaOCAeYwggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0G
'' SIG '' A1UdDgQWBBTVYzpcijGQ80N7fEYbxTNoWoVtVTAZBgkr
'' SIG '' BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
'' SIG '' AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
'' SIG '' 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEug
'' SIG '' SaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
'' SIG '' L2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0w
'' SIG '' Ni0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
'' SIG '' BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
'' SIG '' L2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNy
'' SIG '' dDCBoAYDVR0gAQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMw
'' SIG '' gYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9z
'' SIG '' b2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0w
'' SIG '' QAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AUABv
'' SIG '' AGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0w
'' SIG '' DQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9
'' SIG '' naOhIW+z66bM9TG+zwXiqf76V20ZMLPCxWbJat/15/B4
'' SIG '' vceoniXj+bzta1RXCCtRgkQS+7lTjMz0YBKKdsxAQEGb
'' SIG '' 3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlK
'' SIG '' kVIArzgPF/UveYFl2am1a+THzvbKegBvSzBEJCI8z+0D
'' SIG '' pZaPWSm8tv0E4XCfMkon/VWvL/625Y4zu2JfmttXQOnx
'' SIG '' zplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/
'' SIG '' fZZqkHimbdLhnPkd/DjYlPTGpQqWhqS9nhquBEKDuLWA
'' SIG '' myI4ILUl5WTs9/S/fmNZJQ96LjlXdqJxqgaKD4kWumGn
'' SIG '' Ecua2A5HmoDF0M2n0O99g/DhO3EJ3110mCIIYdqwUB5v
'' SIG '' vfHhAN/nMQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJ
'' SIG '' rDm77MbL2IK0cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqH
'' SIG '' czsI5pgt6o3gMy4SKfXAL1QnIffIrE7aKLixqduWsqdC
'' SIG '' osnPGUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1
'' SIG '' rtxEPJdQcdeh0sVV42neV8HR3jDA/czmTfsNv11P6Z0e
'' SIG '' GTgvvM9YBS7vDaBQNdrvCScc1bN+NR4Iuto229Nfj950
'' SIG '' iEkSoYICzjCCAjcCAQEwgfihgdCkgc0wgcoxCzAJBgNV
'' SIG '' BAYTAlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBP
'' SIG '' cGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOkE4NDEtNEJCNC1DQTkzMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNloiMK
'' SIG '' AQEwBwYFKw4DAhoDFQDppd7VYqc54PjF5U5pK9rjaY8I
'' SIG '' eKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
'' SIG '' BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
'' SIG '' MDEwMA0GCSqGSIb3DQEBBQUAAgUA4DrFtTAiGA8yMDE5
'' SIG '' MDMxOTA5MzQ0NVoYDzIwMTkwMzIwMDkzNDQ1WjB3MD0G
'' SIG '' CisGAQQBhFkKBAExLzAtMAoCBQDgOsW1AgEAMAoCAQAC
'' SIG '' AhkUAgH/MAcCAQACAhGyMAoCBQDgPBc1AgEAMDYGCisG
'' SIG '' AQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
'' SIG '' AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQAD
'' SIG '' gYEAejvkOeh78H98SVV16kBH71nXas321KdrdMAcJs8w
'' SIG '' 4rottwLMZdKgsX5HYH+dDIOZCMADa+4SL4+oPhMxN53X
'' SIG '' yIOM9ckrhmbItdWgf1pcGTwWh1Wv0XnI8E99YieEpvR8
'' SIG '' ojIjY5KSUv+QYuUkPIh7NwEG7/lYeNHNnTdQcRioXpgx
'' SIG '' ggMNMIIDCQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEG
'' SIG '' A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
'' SIG '' ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
'' SIG '' MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
'' SIG '' Q0EgMjAxMAITMwAAAN3k3jrsrfPx1AAAAAAA3TANBglg
'' SIG '' hkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqG
'' SIG '' SIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAxD6bvNYT8
'' SIG '' 4jIjPzoYH2tA9gPgtCXuS+wncOrjAxgZkDCB+gYLKoZI
'' SIG '' hvcNAQkQAi8xgeowgecwgeQwgb0EIErg4nDzh2o/LyQ4
'' SIG '' 6m0c/VC4PriQU+Lwkgt8r8df6FgYMIGYMIGApH4wfDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
'' SIG '' EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
'' SIG '' c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
'' SIG '' b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADd5N46
'' SIG '' 7K3z8dQAAAAAAN0wIgQgh5u733Hnb5UI/oKE+j3m7KVb
'' SIG '' aVKX5m0MEx2Id8qopbYwDQYJKoZIhvcNAQELBQAEggEA
'' SIG '' IVO7tV0XWtCnzNPe3+c+K5TcUYkw0asla9IEkRNDpRxo
'' SIG '' jX88/CqndUhOOGKCh+7V6lJjlc7gXB/5xKKvY7CZC/0C
'' SIG '' mGVM4dmmeeo17TSWz95ePi9/iBgpnajol/0ZUthxelkb
'' SIG '' 6r3l4FH7E7XGtoef/Rv8puHc1ZdQQPf2S7fMu7vBR2t5
'' SIG '' 7CDtVzXTU3Y4b7mPJzWc79/LoEwF2HXo+uWD1ruIXTbO
'' SIG '' 2gjQt5qvs6Ll2xNZcK67tKU3chBtOE3HPslnPgjXF2CN
'' SIG '' YB1HwAqUOslbdyVWQ1+hCXHsRlk93YSj/++CvWhXn6P3
'' SIG '' I70z+GflBxEiaELja9saVWD2FymqsgvYcA==
'' SIG '' End signature block
