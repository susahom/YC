' Windows Installer utility to manage binary streams in an installer package
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the database _Streams table
' Used for entering non-database binary streams such as compressed file cabinets
' Streams that persist database binary values should be managed with table views
' Streams that persist database tables and system data are invisible in _Streams
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
	Wscript.Echo "Windows Installer database stream import utility" &_
		vbNewLine & " 1st argument is the path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is the path to a file containing the stream data" &_
		vbNewLine & " If the 2nd argument is missing, streams will be listed" &_
		vbNewLine & " 3rd argument is optional, the name used for the stream" &_
		vbNewLine & " If the 3rd arugment is missing, the file name is used" &_
		vbNewLine & " To remove a stream, use /D or -D as the 2nd argument" &_
		vbNewLine & " followed by the name of the stream in the 3rd argument" &_
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
Dim streamName  : If argCount > 2 Then streamName = Wscript.Arguments(2)
If streamName = Empty And importPath <> Empty Then streamName = Right(importPath, Len(importPath) - InStrRev(importPath, "\",-1,vbTextCompare))
If UCase(importPath) = "/D" Or UCase(importPath) = "-D" Then updateMode = msiViewModifyDelete : importPath = Empty 'Stream will be deleted if no input data

' Open database and create a view on the _Streams table
Dim sqlQuery : Select Case updateMode
	Case msiOpenDatabaseModeReadOnly: sqlQuery = "SELECT `Name` FROM _Streams"
	Case msiViewModifyAssign:         sqlQuery = "SELECT `Name`,`Data` FROM _Streams"
	Case msiViewModifyDelete:         sqlQuery = "SELECT `Name` FROM _Streams WHERE `Name` = ?"
End Select
Dim database : Set database = installer.OpenDatabase(databasePath, openMode) : CheckError
Dim view     : Set view = database.OpenView(sqlQuery)
Dim record

If openMode = msiOpenDatabaseModeReadOnly Then 'If listing streams, simply fetch all records
	Dim message, name
	view.Execute : CheckError
	Do
		Set record = view.Fetch
		If record Is Nothing Then Exit Do
		name = record.StringData(1)
		If message = Empty Then message = name Else message = message & vbNewLine & name
	Loop
	Wscript.Echo message
Else 'If adding a stream, insert a row, else if removing a stream, delete the row
	Set record = installer.CreateRecord(2)
	record.StringData(1) = streamName
	view.Execute record : CheckError
	If importPath <> Empty Then  'Insert stream - copy data into stream
		record.SetStream 2, importPath : CheckError
	Else  'Delete stream, fetch first to provide better error message if missing
		Set record = view.Fetch
		If record Is Nothing Then Wscript.Echo "Stream not present:", streamName : Wscript.Quit 2
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
'' SIG '' MIIiqQYJKoZIhvcNAQcCoIIimjCCIpYCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' cI6yPc6nU50pwvCvjhpQqcdV9XZAulr8Q0FGvLPiuv6g
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
'' SIG '' Bmrm1MbfI5qWdcUxghaAMIIWfAIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgQokwC+HG3/TZ4gbQnFv4cBB6+FknILF1a4Hcmtoi
'' SIG '' sjAwPAYKKwYBBAGCNwoDHDEuDCxpc0xPVUN5a0NDbGZ3
'' SIG '' dUdPNWkwbXhZblo4WTQ3UE56RWFPTjBPbkM2WjRJPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAKlvi3RytGwC0t4YOKPAkVQ2Z4j2J8hB
'' SIG '' ZyefVmetD2lH1WLBvsbSP145281rdkpAzrNZlJlkHWIe
'' SIG '' md3Ou9NC0pVJVYwgNuqKDWl79ZPwn+qQfjd73UG5wqAw
'' SIG '' Q6a/7vSMBubsO6YG2j+qnKefFZetw7Cw+m9IDLlxdMzm
'' SIG '' ure0XqHx3nTXfhiFdzwqx9M0WawOnpRCHzKxQHZWj2Gp
'' SIG '' b6iatlIAXaCbumvVqn6epdRtEdBrSxNUb724R8Ckn563
'' SIG '' MgI/yEVyJ0vT1DKZ5zAsoThaPNXwudlXDOPMNzlP5giZ
'' SIG '' dZMjh+UYAC4xxvT5zdyEomEBbvVCSVI+6kizJXZkM4r2
'' SIG '' OFWhghOzMIITrwYKKwYBBAGCNwMDATGCE58wghObBgkq
'' SIG '' hkiG9w0BBwKgghOMMIITiAIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVQYLKoZIhvcNAQkQAQSgggFEBIIBQDCCATwC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' AQrDB0DBX52U47zwuPFYGLC4Jp7bABZLM0jXwNvxAyoC
'' SIG '' BlvOEPwpghgTMjAxODEwMjMxNzQ5MjguODIxWjAEgAIB
'' SIG '' 9KCB1KSB0TCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcG
'' SIG '' A1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRv
'' SIG '' IFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0
'' SIG '' OEMtQzRCOS0yMDY2MSUwIwYDVQQDExxNaWNyb3NvZnQg
'' SIG '' VGltZS1TdGFtcCBTZXJ2aWNloIIPHjCCBPUwggPdoAMC
'' SIG '' AQICEzMAAADVpyPleJVqCf8AAAAAANUwDQYJKoZIhvcN
'' SIG '' AQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
'' SIG '' c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
'' SIG '' BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
'' SIG '' AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
'' SIG '' HhcNMTgwODIzMjAyNjQ1WhcNMTkxMTIzMjAyNjQ1WjCB
'' SIG '' zjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMgTWlj
'' SIG '' cm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28xJjAk
'' SIG '' BgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0OEMtQzRCOS0y
'' SIG '' MDY2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
'' SIG '' MIIBCgKCAQEAwhQJK64X8TSCMvzuifB27nQzUHBTFDC2
'' SIG '' tlYRBgKYsyEaE1H/d5DEEP2WpjgVjGFFnVvF+wiOztIq
'' SIG '' 9wXSbVh+GArmP0F1m/O5552QRjwxVS7jXMHXx2f42Zp6
'' SIG '' XPm8XP0EurmEk8AR1mDdlH7h0/vX21Vck/+JWSyUtNMo
'' SIG '' f9ipPxVyJ6Zc5RoKwr9F7vF0F7yoFKGw7BuAPvFVjCCZ
'' SIG '' 6/P5tJndSxYKVxwEH2QyE0eGeIgqS4yjgE0nm177Knwo
'' SIG '' FXLOie0qa06FLVco1IjLARYDNEYpm2U/foNUY7L1IZqP
'' SIG '' B5XRGMeSpkxQPW0SIhoOgGmJldpwc+d7UVAbBKMrg0yU
'' SIG '' SwIDAQABo4IBGzCCARcwHQYDVR0OBBYEFCloozGUdkPZ
'' SIG '' X10Nm5/TsoT2YjeEMB8GA1UdIwQYMBaAFNVjOlyKMZDz
'' SIG '' Q3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJoEeGRWh0
'' SIG '' dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3By
'' SIG '' b2R1Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNy
'' SIG '' bDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0
'' SIG '' dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMv
'' SIG '' TWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1Ud
'' SIG '' EwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJ
'' SIG '' KoZIhvcNAQELBQADggEBAHnZy8LpxNHAqy0O0ia/2meg
'' SIG '' C/32wLbBAvLiuYHNYvaQj+yV4E1ejvhyp0Bahh8tEJCj
'' SIG '' 4O5babn/SYx7gOm88MtgJBJImQC27+FQvzTCKTlmpo28
'' SIG '' h+nuHX8In8oy4iB3xZuE1nEvIblLhbsCzrrtA2J/B4Ku
'' SIG '' MWpkxX1e0E7bCPP1C2LVGN04iaFftXiR0JgpK11CDbEm
'' SIG '' FRT1m0+oamu2Fo+q2j0WF6qzfsLDa87e0CNioxdNkK/J
'' SIG '' vP7htQfEha+q8khcum48/PXMK8Ki0t8HPMGJX2aIgQFe
'' SIG '' ye/aogiR0OchKqWshnWdd1Ed1eXhmEF/fABlH8TAgu8p
'' SIG '' qSwoVjOuTgswggZxMIIEWaADAgECAgphCYEqAAAAAAAC
'' SIG '' MA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0
'' SIG '' aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEy
'' SIG '' MTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEF
'' SIG '' AAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwTl/X6f2mU
'' SIG '' a3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycE
'' SIG '' MR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4CLNC
'' SIG '' 3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhgRvJYR4YyhB50
'' SIG '' YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScd
'' SIG '' JGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wG
'' SIG '' Pmd/9WbAA5ZEfu/QS/1u5ZrKsajyeioKMfDaTgaRtogI
'' SIG '' Neh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1e
'' SIG '' FpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUB
'' SIG '' BAMCAQAwHQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2ha
'' SIG '' hW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
'' SIG '' A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
'' SIG '' IwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1Ud
'' SIG '' HwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
'' SIG '' LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1
'' SIG '' dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEww
'' SIG '' SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0
'' SIG '' LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAt
'' SIG '' MDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsG
'' SIG '' AQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3
'' SIG '' dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZh
'' SIG '' dWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBh
'' SIG '' AGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBtAGUA
'' SIG '' bgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3i
'' SIG '' xuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LF
'' SIG '' Zslq3/Xn8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRg
'' SIG '' Eop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3
'' SIG '' fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9L
'' SIG '' MEQkIjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbljjO7
'' SIG '' Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFjnXsh
'' SIG '' bcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2e
'' SIG '' Gq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2onGq
'' SIG '' BooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7cQnfXXSY
'' SIG '' Ighh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5h
'' SIG '' a293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kqVDmy
'' SIG '' W9rIDVWZeodzOwjmmC3qjeAzLhIp9cAvVCch98isTtoo
'' SIG '' uLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZ
'' SIG '' ii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN
'' SIG '' +w2/XU/pnR4ZOC+8z1gFLu8NoFA12u8JJxzVs341Hgi6
'' SIG '' 2jbb01+P3nSISRKhggOsMIIClAIBATCB/qGB1KSB0TCB
'' SIG '' zjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMgTWlj
'' SIG '' cm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28xJjAk
'' SIG '' BgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0OEMtQzRCOS0y
'' SIG '' MDY2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAK3DJLzR
'' SIG '' 2XXwXdDdRR85MZ5u1p6xoIHeMIHbpIHYMIHVMQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQg
'' SIG '' T3BlcmF0aW9ucyBQdWVydG8gUmljbzEnMCUGA1UECxMe
'' SIG '' bkNpcGhlciBOVFMgRVNOOjU3RjYtQzFFMC01NTRDMSsw
'' SIG '' KQYDVQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2UgTWFz
'' SIG '' dGVyIENsb2NrMA0GCSqGSIb3DQEBBQUAAgUA33nRhTAi
'' SIG '' GA8yMDE4MTAyNDAwNTc0MVoYDzIwMTgxMDI1MDA1NzQx
'' SIG '' WjBzMDkGCisGAQQBhFkKBAExKzApMAoCBQDfedGFAgEA
'' SIG '' MAYCAQACATcwBwIBAAICGHwwCgIFAN97IwUCAQAwNgYK
'' SIG '' KwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAKMAgC
'' SIG '' AQACAwehIKEKMAgCAQACAwehIDANBgkqhkiG9w0BAQUF
'' SIG '' AAOCAQEAk7cNiyeB8LD5fzyaEeQAAL6wTSdeAlnDexrd
'' SIG '' tKWjL7EMzmOD4t0sGneSrxzAjQIiA7iivh3KtJHPKlVA
'' SIG '' BpBXRHvAxcTMDCDS4YVwTiGYEtzhDYgN+MTYMEMkHciJ
'' SIG '' 90MD79A1fSovxsIgXScrifsPxDI2N2fw4coi04dRYSsW
'' SIG '' T5bcav6xc9m32pigX3HsYE1nQEhWttEF0mbk1GyhebHS
'' SIG '' wRtk0QkBiYuJvIt46NvyzcOgow5MnlR5T+dc2wXHUp3C
'' SIG '' ADg9Xm/+D/TQ1c4OYdMwjecU90F7yh7O9Z5eSs/GZifm
'' SIG '' bDmFpeZLMqxEGGLaRkp9QxixI/Fnr0hCjrFPr9pMCDGC
'' SIG '' AvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
'' SIG '' MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
'' SIG '' QSAyMDEwAhMzAAAA1acj5XiVagn/AAAAAADVMA0GCWCG
'' SIG '' SAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMxDQYLKoZI
'' SIG '' hvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIActZw6mc4h2
'' SIG '' QN2U5gEUJfizEuEyF66eKxKts7ePVkgJMIHiBgsqhkiG
'' SIG '' 9w0BCRACDDGB0jCBzzCBzDCBsQQUrcMkvNHZdfBd0N1F
'' SIG '' Hzkxnm7WnrEwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBQQ0EgMjAxMAITMwAAANWnI+V4lWoJ/wAAAAAA1TAW
'' SIG '' BBSEmCwvGAHC31fsN1XevcakRXo6ajANBgkqhkiG9w0B
'' SIG '' AQsFAASCAQCXvBS4DbmcrsxSpIrEAJKHCMQgoYGKYiIr
'' SIG '' jLSXdbcfbuURtZshJc45Lzpm/Zr3LzkQ8650jTCwna1W
'' SIG '' d2UoTt+sWY8QRQuLGOQuvGleIwtf/ijbmGkz7dYoMSAh
'' SIG '' DBGS1nmJs8OSBN4OTgVVBk+LcJJaxGDbEH6sXxX6Ubdq
'' SIG '' x0VLupFS89wgAbl/QKUYP+kh5hundpvw+crOurFuCF58
'' SIG '' c8i2+3I57GoDHLcaRwyaffPhukjly8Mp1eFq8Ny1NM8Y
'' SIG '' DkwftCWe0luGfVdnPqyBSUyJFIjJJOrNBTiG5L5QK2wM
'' SIG '' 1TzhNmGxrLt3qTMDgC3QaFaqS7Oy6kGFJb0lCS+ftdfV
'' SIG '' End signature block
