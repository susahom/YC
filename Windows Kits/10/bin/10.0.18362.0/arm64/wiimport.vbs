' Windows Installer database table import for use with Windows Scripting Host
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the Database.Import method and MsiDatabaseImport API
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
If (argCount < 3) Then
	Wscript.Echo "Windows Installer database table import utility" &_
		vbNewLine & " 1st argument is the path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is the path to folder containing the imported files" &_
		vbNewLine & " Subseqent arguments are names of archive files to import" &_
		vbNewLine & " Wildcards, such as *.idt, can be used to import multiple files" &_
		vbNewLine & " Specify /c or -c anywhere before file list to create new database" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

Dim openMode:openMode = msiOpenDatabaseModeTransact
Dim databasePath:databasePath = NextArgument
Dim folder:folder = NextArgument

Dim WshShell, fileSys
Set WshShell = Wscript.CreateObject("Wscript.Shell") : CheckError
Set fileSys = CreateObject("Scripting.FileSystemObject") : CheckError

' Open database and process list of files
Dim database, table
Set database = installer.OpenDatabase(databasePath, openMode) : CheckError
While iArg < argCount
	table = NextArgument
	' Check file name for wildcard specification
	If (InStr(1,table,"*",vbTextCompare) <> 0) Or (InStr(1,table,"?",vbTextCompare) <> 0) Then
		' Obtain list of files matching wildcard specification
		Dim file, tempFilePath
		tempFilePath = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\dir.tmp"
		WshShell.Run "cmd.exe /U /c dir /b " & folder & "\" & table & ">" & tempFilePath, 0, True : CheckError
		Set file = fileSys.OpenTextFile(tempFilePath, ForReading, False, TristateTrue) : CheckError
		' Import each file in directory list
		Do While file.AtEndOfStream <> True
			table = file.ReadLine
			database.Import folder, table : CheckError
		Loop
		file.Close
		fileSys.DeleteFile(tempFilePath)
	Else
		database.Import folder, table : CheckError
	End If
Wend
database.Commit 'commit changes if no import errors
Wscript.Quit 0

Function NextArgument
	Dim arg, chFlag
	Do
		arg = Wscript.Arguments(iArg)
		iArg = iArg + 1
		chFlag = AscW(arg)
		If (chFlag = AscW("/")) Or (chFlag = AscW("-")) Then
			chFlag = UCase(Right(arg, Len(arg)-1))
			If chFlag = "C" Then 
				openMode = msiOpenDatabaseModeCreate
			Else
				Wscript.Echo "Invalid option flag:", arg : Wscript.Quit 1
			End If
		Else
			Exit Do
		End If
	Loop
	NextArgument = arg
End Function

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
'' SIG '' MIIh2wYJKoZIhvcNAQcCoIIhzDCCIcgCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' URtattTTdos4rg+Jt96T7zPQ8Pzvx4qAdD0rt5bwgTmg
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
'' SIG '' IgQg7eWUfGzAc/5A7zipkVLl2TNPbIlzesQq/vdNLq54
'' SIG '' wLAwPAYKKwYBBAGCNwoDHDEuDCxzSGN4TXc1bWttUzVL
'' SIG '' bHF6Q200ZkZ6SHRTR0ZFcGNoL1RJREMvb1dVNDlrPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBABzVJOcW8tSlUCpKb0ga+cd1eabqjLt3
'' SIG '' 5KYOhcO/w3m/9hctHZzsDlHA3dvjnLR4mc/16oDCvdje
'' SIG '' LO82E1iA2gly9RkoBxrhibIJNfwChUIkkh0p33882Iep
'' SIG '' BE+KgvSSwWOo1qg1irSb7EqWFvgaaSAv2UJpCvWYPjD7
'' SIG '' zpAIhD+g8EcGztOxJdc+PlqCKz0ypTQZ+Ecl88IhqFdv
'' SIG '' 7+p6CDAzguxav9LMCTkzZ1JJF++spwlMWbsKh+9MgUAn
'' SIG '' aeM2ocQkE9y2WOw7YxGqeR4k9NV/+g+d/xZm3Sc/680b
'' SIG '' S1imcQXR24TK/UYu1sQxMBv4djktfQC9353SkrKVZbHE
'' SIG '' VGmhghLlMIIS4QYKKwYBBAGCNwMDATGCEtEwghLNBgkq
'' SIG '' hkiG9w0BBwKgghK+MIISugIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBUQYLKoZIhvcNAQkQAQSgggFABIIBPDCCATgC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' rS2UZNd6dQjK1O7PCbfRqPBUOEL3AQVOSgg53zYPEzEC
'' SIG '' Blx1InirDBgTMjAxOTAzMTkwMjU5MDUuODI2WjAEgAIB
'' SIG '' 9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
'' SIG '' AldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
'' SIG '' Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRl
'' SIG '' ZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MDg0Mi00
'' SIG '' QkU2LUMyOUExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIHNlcnZpY2Wggg48MIIE8TCCA9mgAwIBAgIT
'' SIG '' MwAAANga5Mw/ehH64QAAAAAA2DANBgkqhkiG9w0BAQsF
'' SIG '' ADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0x
'' SIG '' ODA4MjMyMDI2NTFaFw0xOTExMjMyMDI2NTFaMIHKMQsw
'' SIG '' CQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
'' SIG '' bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
'' SIG '' aGFsZXMgVFNTIEVTTjowODQyLTRCRTYtQzI5QTElMCMG
'' SIG '' A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgc2Vydmlj
'' SIG '' ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
'' SIG '' AJQeMOSHWvWwaLjzMJJNUlItdUPmMVReJICu4pqGgEB5
'' SIG '' cQWDde10v3sl7BPa8SYt4YQ9J1zmeiuXr57pmiFWP/zz
'' SIG '' ApH7DSX8BcRtuDaAzyDtdntSgYEFiPd9Mls0uT0GgAjh
'' SIG '' DT4LIIuwkRQ3G9cEmRfQqF5evcim2kNmhqAGWT9PdRoU
'' SIG '' eZM58bphx7nNEnksdDK8TQ71GckMkw3kOhHn/MxlfsDY
'' SIG '' UXQMdd/gL8BZBA9gdA5XV+Y25/EGVLAPgYVs67VHx0v5
'' SIG '' LM1TN7vselOqD7p4tNRKwc15WvhgrOs3zW+YLHpoi7mK
'' SIG '' 5bBxRbHDHtOBuoavZ12D9Xj1byK71Swy9UMCAwEAAaOC
'' SIG '' ARswggEXMB0GA1UdDgQWBBSftlZLHu4U1d+Kdnqagxrn
'' SIG '' kONm5DAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNo
'' SIG '' WoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
'' SIG '' aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB
'' SIG '' BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
'' SIG '' YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAA
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
'' SIG '' CwUAA4IBAQAOUnB23sg/ILU0t7sBnN7w2jsyd3zgPlIw
'' SIG '' d/GJGkt45hfP5uBn4j9vwGfpsKDZehLtQpt/Rp6i5Sq7
'' SIG '' 9NyQOw4Lr5+SjS5bUuk5E5SkK9z1ZMa/RVeP+gkC5dlE
'' SIG '' lNHep5kc6CJhnSoLIlKE7IgiYkpvjdiDPi3ST8kDSrkT
'' SIG '' 7PZb8PacoNVX7NOcrxKdE5DnlYp6gmr2kFwmN3Wd/se9
'' SIG '' h3UyXIWEXc7B0I8Wsz8W2xws7oYpUGK9el7Tcr0jYqyi
'' SIG '' AmHbuwIpd3TtM3WGpQ5UznixUltmh8+ckTCKD406FhJG
'' SIG '' KOFLhP99FrVVwtDavCE0zJBz1T75D5bf4jYrxoObSU6x
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
'' SIG '' cyBUU1MgRVNOOjA4NDItNEJFNi1DMjlBMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNloiMK
'' SIG '' AQEwBwYFKw4DAhoDFQBlMcHdEV4dkOyNKKJJFQhZYCsi
'' SIG '' gaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
'' SIG '' BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
'' SIG '' MDEwMA0GCSqGSIb3DQEBBQUAAgUA4DqnRjAiGA8yMDE5
'' SIG '' MDMxOTA3MjQ1NFoYDzIwMTkwMzIwMDcyNDU0WjB3MD0G
'' SIG '' CisGAQQBhFkKBAExLzAtMAoCBQDgOqdGAgEAMAoCAQAC
'' SIG '' Ah9dAgH/MAcCAQACAhIkMAoCBQDgO/jGAgEAMDYGCisG
'' SIG '' AQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEA
'' SIG '' AgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQAD
'' SIG '' gYEAC28VjHDZ/5p1YKIH5J6jypDVn5z8brhkBWUcQzuz
'' SIG '' SrMBOCzWAkcPJiIDlDHwaYA15YkULgeZPF7RCQ8DoLci
'' SIG '' LOmj86nbroy8RmknAOGwLNf2tfBT33RbG+Ba5codd3kL
'' SIG '' 4QCA3YF8FZvg6CwlO72lmMuJVL2loxHXSq6arrEicOUx
'' SIG '' ggMNMIIDCQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEG
'' SIG '' A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
'' SIG '' ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
'' SIG '' MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
'' SIG '' Q0EgMjAxMAITMwAAANga5Mw/ehH64QAAAAAA2DANBglg
'' SIG '' hkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqG
'' SIG '' SIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCCuHUVnb9IU
'' SIG '' DFhAecgdeATU2Wk/f3ijux1hyi37cTRj1zCB+gYLKoZI
'' SIG '' hvcNAQkQAi8xgeowgecwgeQwgb0EIHM7ncd4XOjzdin/
'' SIG '' 74SVqj0pQNFvCgT/IGvME59BLtgtMIGYMIGApH4wfDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
'' SIG '' EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
'' SIG '' c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
'' SIG '' b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADYGuTM
'' SIG '' P3oR+uEAAAAAANgwIgQgyHWbD/E1mztAlcdyK8uWIu/A
'' SIG '' 5Eesh/ZQNEr3UGGpd1gwDQYJKoZIhvcNAQELBQAEggEA
'' SIG '' doxO1b4rSlm0fiVs2MIyerrSCQ4wHco9zVR4QyqrvZdW
'' SIG '' +Og9YprwI2rMTDY1NT23kSet0FkEKqLYqsLgWAEbgxiY
'' SIG '' U4fP0/J0aPcCXcH1S+XKoExLZVc05BiuJRBHvvpgIsth
'' SIG '' Wbg8NAOZDlphpNlZAI9dDSxfXFWTpcvj8DnV9VTu2YsL
'' SIG '' KS1JzW3gCp18ov14H9k42UjKSK1tK21gIseDi15xy2RW
'' SIG '' 92N8RhYDfGVQJp4tmvS66PJoyCkTHg3qv6WUZKXx39Jv
'' SIG '' RKHsV/mZDZSQnV6RuV9olwB+2L3Y2H4ioR0QF1f/8xdb
'' SIG '' 19GsG2fccwVY+1TkSwGlxykVPGkghWWykA==
'' SIG '' End signature block
