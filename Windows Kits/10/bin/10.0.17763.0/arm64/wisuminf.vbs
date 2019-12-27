' Windows Installer utility to manage the summary information stream
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the database summary information methods

Option Explicit

Const msiOpenDatabaseModeReadOnly     = 0
Const msiOpenDatabaseModeTransact     = 1
Const msiOpenDatabaseModeCreate       = 3

Dim propList(19, 1)
propList( 1,0) = "Codepage"    : propList( 1,1) = "ANSI codepage of text strings in summary information only"
propList( 2,0) = "Title"       : propList( 2,1) = "Package type, e.g. Installation Database"
propList( 3,0) = "Subject"     : propList( 3,1) = "Product full name or description"
propList( 4,0) = "Author"      : propList( 4,1) = "Creator, typically vendor name"
propList( 5,0) = "Keywords"    : propList( 5,1) = "List of keywords for use by file browsers"
propList( 6,0) = "Comments"    : propList( 6,1) = "Description of purpose or use of package"
propList( 7,0) = "Template"    : propList( 7,1) = "Target system: Platform(s);Language(s)"
propList( 8,0) = "LastAuthor"  : propList( 8,1) = "Used for transforms only: New target: Platform(s);Language(s)"
propList( 9,0) = "Revision"    : propList( 9,1) = "Package code GUID, for transforms contains old and new info"
propList(11,0) = "Printed"     : propList(11,1) = "Date and time of installation image, same as Created if CD"
propList(12,0) = "Created"     : propList(12,1) = "Date and time of package creation"
propList(13,0) = "Saved"       : propList(13,1) = "Date and time of last package modification"
propList(14,0) = "Pages"       : propList(14,1) = "Minimum Windows Installer version required: Major * 100 + Minor"
propList(15,0) = "Words"       : propList(15,1) = "Source and Elevation flags: 1=short names, 2=compressed, 4=network image, 8=LUA package"
propList(16,0) = "Characters"  : propList(16,1) = "Used for transforms only: validation and error flags"
propList(18,0) = "Application" : propList(18,1) = "Application associated with file, ""Windows Installer"" for MSI"
propList(19,0) = "Security"    : propList(19,1) = "0=Read/write 2=Readonly recommended 4=Readonly enforced"

Dim iArg, iProp, property, value, message
Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If (argCount = 0) Then
	message = "Windows Installer utility to manage summary information stream" &_
		vbNewLine & " 1st argument is the path to the storage file (installer package)" &_
		vbNewLine & " If no other arguments are supplied, summary properties will be listed" &_
		vbNewLine & " Subsequent arguments are property=value pairs to be updated" &_
		vbNewLine & " Either the numeric or the names below may be used for the property" &_
		vbNewLine & " Date and time fields use current locale format, or ""Now"" or ""Date""" &_
		vbNewLine & " Some properties have specific meaning for installer packages"
	For iProp = 1 To UBound(propList)
		property = propList(iProp, 0)
		If Not IsEmpty(property) Then
			message = message & vbNewLine & Right(" " & iProp, 2) & "  " & property & " - " & propLIst(iProp, 1)
		End If
	Next
	message = message & vbNewLine & vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."

	Wscript.Echo message
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : If CheckError("MSI.DLL not registered") Then Wscript.Quit 2

' Evaluate command-line arguments and open summary information
Dim cUpdate:cUpdate = 0 : If argCount > 1 Then cUpdate = 20
Dim sumInfo  : Set sumInfo = installer.SummaryInformation(Wscript.Arguments(0), cUpdate) : If CheckError(Empty) Then Wscript.Quit 2

' If only package name supplied, then list all properties in summary information stream
If argCount = 1 Then
	For iProp = 1 to UBound(propList)
		value = sumInfo.Property(iProp) : CheckError(Empty)
		If Not IsEmpty(value) Then message = message & vbNewLine & Right(" " & iProp, 2) & "  " &  propList(iProp, 0) & " = " & value
	Next
	Wscript.Echo message
	Wscript.Quit 0
End If

' Process property settings, combining arguments if equal sign has spaces before or after it
For iArg = 1 To argCount - 1
	property = property & Wscript.Arguments(iArg)
	Dim iEquals:iEquals = InStr(1, property, "=", vbTextCompare) 'Must contain an equals sign followed by a value
	If iEquals > 0 And iEquals <> Len(property) Then
		value = Right(property, Len(property) - iEquals)
		property = Left(property, iEquals - 1)
		If IsNumeric(property) Then
			iProp = CLng(property)
		Else  ' Lookup property name if numeric property ID not supplied
			For iProp = 1 To UBound(propList)
				If propList(iProp, 0) = property Then Exit For
			Next
		End If
		If iProp > UBound(propList) Then
			Wscript.Echo "Unknown summary property name: " & property
			sumInfo.Persist ' Note! must write even if error, else entire stream will be deleted
			Wscript.Quit 2
		End If
		If iProp = 11 Or iProp = 12 Or iProp = 13 Then
			If UCase(value) = "NOW"  Then value = Now
			If UCase(value) = "DATE" Then value = Date
			value = CDate(value)
		End If
		If iProp = 1 Or iProp = 14 Or iProp = 15 Or iProp = 16 Or iProp = 19 Then value = CLng(value)
		sumInfo.Property(iProp) = value : CheckError("Bad format for property value " & iProp)
		property = Empty
	End If
Next
If Not IsEmpty(property) Then
	Wscript.Echo "Arguments must be in the form: property=value  " & property
	sumInfo.Persist ' Note! must write even if error, else entire stream will be deleted
	Wscript.Quit 2
End If

' Write new property set. Note! must write even if error, else entire stream will be deleted
sumInfo.Persist : If CheckError("Error persisting summary property stream") Then Wscript.Quit 2
Wscript.Quit 0


Function CheckError(message)
	If Err = 0 Then Exit Function
	If IsEmpty(message) Then message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Dim errRec : Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbNewLine & errRec.FormatText
	End If
	Wscript.Echo message
	CheckError = True
	Err.Clear
End Function

'' SIG '' Begin signature block
'' SIG '' MIIirAYJKoZIhvcNAQcCoIIinTCCIpkCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' bn8llKyfjYiHNwaF/UnnU74Wl84HND+puok0mU7lHYug
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
'' SIG '' Bmrm1MbfI5qWdcUxghaDMIIWfwIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQglzkLrttgD3vlcRipTn+ZUDOD3R+L+HfvDDHGuJMw
'' SIG '' z2wwPAYKKwYBBAGCNwoDHDEuDCwxaGk3SVNPOXJLN0lz
'' SIG '' YWVldlpEMkY5ZUIyTU8zcXZJa3lhSHZCbWJ2M2JzPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAEgeQfjXoFCv6wZJ2ua5P48yhKbdBo07
'' SIG '' YEc+j5UY3/hpXoXLgy9bcOmmqDxFh+EonC7/EAR6cwbx
'' SIG '' CUyf874p8uJgqdWz/DiZHg1In1W6l1BmTTHvtHqYfHTx
'' SIG '' 3x2XYywIjQ279bWSO9IvwAhvwjaXtSgcS8dKt3h9BJps
'' SIG '' RVtBwgP+ZWaBANzYOf1C9Y9oWTNBWGtQPMSmUm/M0mFs
'' SIG '' r78C8aykYDFBeiSAhrDVU6mcbfBaPaJjwnVyCDtErorI
'' SIG '' Virx17vuVEmf52UZQDRsuuZw7KRNKBRc+uAS8U3zNLpx
'' SIG '' BLPILe4AQfkgk3AUApFwHFhNPj7MuVx67VPGkfQ57uW4
'' SIG '' xAWhghO2MIITsgYKKwYBBAGCNwMDATGCE6IwghOeBgkq
'' SIG '' hkiG9w0BBwKgghOPMIITiwIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVwYLKoZIhvcNAQkQAQSgggFGBIIBQjCCAT4C
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' a2+RBjWL1wRMNCFJsQFXsaH8MXUUL+Ts2lF4RGvM6zoC
'' SIG '' BlvOGLnR8xgSMjAxODEwMjMxNzQ5MjkuOThaMAcCAQGA
'' SIG '' AgH0oIHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkw
'' SIG '' JwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVy
'' SIG '' dG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046
'' SIG '' QjhFQy0zMEE0LTcxNDQxJTAjBgNVBAMTHE1pY3Jvc29m
'' SIG '' dCBUaW1lLVN0YW1wIFNlcnZpY2Wggg8fMIIGcTCCBFmg
'' SIG '' AwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCB
'' SIG '' iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWlj
'' SIG '' cm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
'' SIG '' IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0
'' SIG '' NjU1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
'' SIG '' ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkd
'' SIG '' Dbx3EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxf
'' SIG '' xcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEw
'' SIG '' RA/xYIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeB
'' SIG '' zb8kYDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSmXdFh
'' SIG '' E24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13
'' SIG '' Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWa
'' SIG '' yrGo8noqCjHw2k4GkbaICDXoeByw6ZnNPOcvRLqn9Nxk
'' SIG '' vaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYw
'' SIG '' ggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTV
'' SIG '' YzpcijGQ80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIE
'' SIG '' DB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0T
'' SIG '' AQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo
'' SIG '' 0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRw
'' SIG '' Oi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
'' SIG '' dWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmww
'' SIG '' WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw
'' SIG '' Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
'' SIG '' Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0g
'' SIG '' AQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYB
'' SIG '' BQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9Q
'' SIG '' S0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUH
'' SIG '' AgIwNB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkA
'' SIG '' XwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcN
'' SIG '' AQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM
'' SIG '' 9TG+zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzt
'' SIG '' a1RXCCtRgkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1
'' SIG '' mCRWS3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/Uv
'' SIG '' eYFl2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E
'' SIG '' 4XCfMkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/
'' SIG '' 3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLh
'' SIG '' nPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs
'' SIG '' 9/S/fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF
'' SIG '' 0M2n0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQek
'' SIG '' kzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0
'' SIG '' cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3g
'' SIG '' My4SKfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN4Ib5
'' SIG '' KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh
'' SIG '' 0sVV42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7v
'' SIG '' DaBQNdrvCScc1bN+NR4Iuto229Nfj950iEkSMIIE9TCC
'' SIG '' A92gAwIBAgITMwAAAMw6vTtyOBEFugAAAAAAzDANBgkq
'' SIG '' hkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
'' SIG '' JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
'' SIG '' MjAxMDAeFw0xODA4MjMyMDI2MjVaFw0xOTExMjMyMDI2
'' SIG '' MjVaMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQL
'' SIG '' EyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmlj
'' SIG '' bzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046QjhFQy0z
'' SIG '' MEE0LTcxNDQxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFNlcnZpY2UwggEiMA0GCSqGSIb3DQEBAQUA
'' SIG '' A4IBDwAwggEKAoIBAQDH0FWliiYVaxXd8HeYu7X5zFNL
'' SIG '' BnExJxJk6j0vI/p5USi1aLW63x1b07oLgwpViHNfpZ7M
'' SIG '' OoJ8/poCU+WOlcyBqcGkWEzHt3CfV//1zmQWu8bl7vQO
'' SIG '' Oh4jtk+a6CQZCfZSLduvL6Er15oxkAPddzdZ1obHOlBO
'' SIG '' FbjrD+eoh7rYh0rSdgIDGKw66SRASNilFZP1whG6YiGm
'' SIG '' chJ+fbIe4jASJNTiadyEo0F7fgGI8YEqFmqs0rzf6I9U
'' SIG '' Vrvr9IBXi0QZXaxYoRTvT72dx6kierO3LZjmZGJ35jYz
'' SIG '' sIXlZnR490J7nm23mNITgxbVV2Jb0FOw8NkgUOlxHJ5e
'' SIG '' sWBy5SKLAgMBAAGjggEbMIIBFzAdBgNVHQ4EFgQUralN
'' SIG '' pkrCZRBP1+t7HiGaMTNI66kwHwYDVR0jBBgwFoAU1WM6
'' SIG '' XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0fBE8wTTBLoEmg
'' SIG '' R4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9j
'' SIG '' cmwvcHJvZHVjdHMvTWljVGltU3RhUENBXzIwMTAtMDct
'' SIG '' MDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
'' SIG '' AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9j
'' SIG '' ZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcnQw
'' SIG '' DAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcD
'' SIG '' CDANBgkqhkiG9w0BAQsFAAOCAQEAPV1daoLp4mVRNVLD
'' SIG '' yRy/4BFgVhCnmHLmQ7p4IQjBs6twKdtJPKrEYyhMJi6c
'' SIG '' I0CuBKx4YGS7o2AgkZMaQHB3KlK83wUJeoTGy6icCTUZ
'' SIG '' hbv+x+DCQHJJfuJSJjlLCUQI4oXh5eu36uVfovCzAYPC
'' SIG '' 2DTysuJAqE1L0v6oFITq1Z0AqrRDSUwzMY5jnnszvZL6
'' SIG '' j7byMe+g0nSrYPj16BP1IF3N8S+kQXjYse+jHVPJSzqo
'' SIG '' OEtRrPQeSssWb/E7X39ck1PxNpDMDn/EJ81p6uTX2g2d
'' SIG '' fE1M5cmnC+Oxh1tyud01nVsrfsX4WBq5NClXB4qc9afd
'' SIG '' gHtQXuV+6Uoiay7Y36GCA60wggKVAgEBMIH+oYHUpIHR
'' SIG '' MIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBN
'' SIG '' aWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
'' SIG '' MCQGA1UECxMdVGhhbGVzIFRTUyBFU046QjhFQy0zMEE0
'' SIG '' LTcxNDQxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
'' SIG '' YW1wIFNlcnZpY2WiJQoBATAJBgUrDgMCGgUAAxUAc9qH
'' SIG '' Mf0u+zxorOfoRpRzRIe/lk2ggd4wgdukgdgwgdUxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xKTAnBgNVBAsTIE1pY3Jvc29m
'' SIG '' dCBPcGVyYXRpb25zIFB1ZXJ0byBSaWNvMScwJQYDVQQL
'' SIG '' Ex5uQ2lwaGVyIE5UUyBFU046NTdGNi1DMUUwLTU1NEMx
'' SIG '' KzApBgNVBAMTIk1pY3Jvc29mdCBUaW1lIFNvdXJjZSBN
'' SIG '' YXN0ZXIgQ2xvY2swDQYJKoZIhvcNAQEFBQACBQDfeZFE
'' SIG '' MCIYDzIwMTgxMDIzMTIyMzMyWhgPMjAxODEwMjQxMjIz
'' SIG '' MzJaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAN95kUQC
'' SIG '' AQAwBwIBAAICGuswBwIBAAICGjQwCgIFAN964sQCAQAw
'' SIG '' NgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAK
'' SIG '' MAgCAQACAxbjYKEKMAgCAQACAwehIDANBgkqhkiG9w0B
'' SIG '' AQUFAAOCAQEAZBxn2cCii0dFmg+W2ctLXe1fWHVjZKEE
'' SIG '' i6/FyMBaTJ2VK5QcH2YMyx3C78Ox6w65QdGzo9ukOE8d
'' SIG '' DatQcN+WQxBvN9R5CPFVqEhJ1w0E3BsfDZVVM0tLGFZd
'' SIG '' sDNfcQFRC2+Ef/Sno29B2ZFBFoCj/PpC7NbDEpEmKXbQ
'' SIG '' 5Rh5ZKH0XY/3RDl+eEdx22BV0bdolr9suGJpl8sExaiR
'' SIG '' jV4f0tmtfpl5K9Oig9rkJwC+bFMJcYIEd9mYeqxmdT/w
'' SIG '' GY+YeAkdfJtLCIeoTP9Ca7WFVMR3JwotEZNv0pNBEpUR
'' SIG '' 7l72MpCc85YoM1/rOnNbpzZxiPTs8qZhzDuYCF1D4ZxI
'' SIG '' xTGCAvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMw
'' SIG '' EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
'' SIG '' b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
'' SIG '' IFBDQSAyMDEwAhMzAAAAzDq9O3I4EQW6AAAAAADMMA0G
'' SIG '' CWCGSAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMxDQYL
'' SIG '' KoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIDK3nx64
'' SIG '' OBCC9syoCo6FQSJhhk54N7ln8knyJXmbBE2/MIHiBgsq
'' SIG '' hkiG9w0BCRACDDGB0jCBzzCBzDCBsQQUc9qHMf0u+zxo
'' SIG '' rOfoRpRzRIe/lk0wgZgwgYCkfjB8MQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
'' SIG '' dGFtcCBQQ0EgMjAxMAITMwAAAMw6vTtyOBEFugAAAAAA
'' SIG '' zDAWBBTvXCYA1Gx+BTHLX2gmBBxr/CkdvDANBgkqhkiG
'' SIG '' 9w0BAQsFAASCAQBlHJKEnJ7XtcW+LwpF6HRtJ6+6L5ut
'' SIG '' Fu9XGticv4Ky6oWhgLtvrfTEqXuSshLbhIFxYcSJLhN+
'' SIG '' jSD5A3QSVbKeGtKKPCmNatR3bFJzD76TAP2mQiauu6sX
'' SIG '' UtGSQff39zt9S4p9n3HGlZNSXOiGrVHdaJI5hoxyoYOV
'' SIG '' hKumwOXpn+5gwHb4xgwkCX+U6KP4mz8l3TXb6MgZ/wmO
'' SIG '' BlMIhwkTJNyMlE3C8RYKtf+mWIZkpSo/yC1PgPHLTArb
'' SIG '' zoTWjxN8eBmAJcrskOvJovaraBCNqpW3JZe2NZEeRsPD
'' SIG '' VA0kWNdfQqoZR6gcxmGEm6wjLx69xDWc+QqQzHSTdPxu
'' SIG '' J6nX
'' SIG '' End signature block
