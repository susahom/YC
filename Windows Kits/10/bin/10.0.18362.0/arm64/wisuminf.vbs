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
'' SIG '' MIIh2AYJKoZIhvcNAQcCoIIhyTCCIcUCAQExDzANBglg
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
'' SIG '' Bmrm1MbfI5qWdcUxghWvMIIVqwIBATCBlTB+MQswCQYD
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
'' SIG '' xAWhghLiMIIS3gYKKwYBBAGCNwMDATGCEs4wghLKBgkq
'' SIG '' hkiG9w0BBwKgghK7MIIStwIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBUQYLKoZIhvcNAQkQAQSgggFABIIBPDCCATgC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' a2+RBjWL1wRMNCFJsQFXsaH8MXUUL+Ts2lF4RGvM6zoC
'' SIG '' BlxndoqhqRgTMjAxOTAzMTkwMjU5MTguNzA0WjAEgAIB
'' SIG '' 9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
'' SIG '' AldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
'' SIG '' Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRl
'' SIG '' ZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046QTI0MC00
'' SIG '' QjgyLTEzMEUxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIHNlcnZpY2Wggg45MIIE8TCCA9mgAwIBAgIT
'' SIG '' MwAAAOCyGKnU0cK09wAAAAAA4DANBgkqhkiG9w0BAQsF
'' SIG '' ADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0x
'' SIG '' ODA4MjMyMDI3MDFaFw0xOTExMjMyMDI3MDFaMIHKMQsw
'' SIG '' CQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
'' SIG '' bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
'' SIG '' aGFsZXMgVFNTIEVTTjpBMjQwLTRCODItMTMwRTElMCMG
'' SIG '' A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgc2Vydmlj
'' SIG '' ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
'' SIG '' AMKX+GcOx6ZsnHsUxLlG5omyJAkM/S2KrJ4J622I2UZw
'' SIG '' 2hrjbyhW1uUfrJlq0JdnKDKHNucMmh9Mcga12ITNBzl8
'' SIG '' +F119N3iERCB3lyH8GUYhNcUTAnh38aEdlDWFst2IFP+
'' SIG '' PrtDHXlV65fLmf+Mz0+8hsGSxJbBfy+uSFFP+uprXFau
'' SIG '' YX5J9xgrD6kL53e1QeuAAKjRhpUe5LeOWleDfcD6m6Xz
'' SIG '' CJtkFwbEwXUKrCU/QB8xbrQOniqb8kttbF3H+k6KI6sz
'' SIG '' +3KQUO0Sc3TsddGNcOEOF8h4ELPgY+IIQWT3gBoXHKwV
'' SIG '' 4Wf2/LPtPIonFSSxcmG1YaraLhaY9ymHIPMCAwEAAaOC
'' SIG '' ARswggEXMB0GA1UdDgQWBBRrQdMKtjnOrO/+njita5Jt
'' SIG '' doCH6DAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNo
'' SIG '' WoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
'' SIG '' aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB
'' SIG '' BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
'' SIG '' YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAA
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
'' SIG '' CwUAA4IBAQALH96d2ZLkNbrGBvx8h0Soj3rd9QHsihiV
'' SIG '' g1BT9hnCrXnm4rWXCFwflHUJpUyv6XI0h8PyX6WrLyZ2
'' SIG '' i75nByufOjebZQQY7S40V3hzwh7Dlnj1X7oCiNPrPkgY
'' SIG '' mHfLnq4MAJDNFmtH7bq4LHWcuxiMr9a3FAOrUgcdZ4DF
'' SIG '' +sbGwBk7UF1CjbkzHfhmx5WJWP66x+bLSdSZ+9nSEVwx
'' SIG '' 413iLgp2zTeRj8LBZVkHDra0CM4cr9zzXA7uGK6270lf
'' SIG '' gw2NoS4V2F6I3CYfICZumpibPor70g8zvmJcQtvOMNzr
'' SIG '' IsmlU6rXuB9UMJrB6vLOBWcLYIjGruAMbJMz1p/Ay0RJ
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
'' SIG '' iEkSoYICyzCCAjQCAQEwgfihgdCkgc0wgcoxCzAJBgNV
'' SIG '' BAYTAlVTMQswCQYDVQQIEwJXQTEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBP
'' SIG '' cGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOkEyNDAtNEI4Mi0xMzBFMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNloiMK
'' SIG '' AQEwBwYFKw4DAhoDFQDGeaSM5d52mrIdCqQkaft7CFIL
'' SIG '' 0aCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
'' SIG '' BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
'' SIG '' MDEwMA0GCSqGSIb3DQEBBQUAAgUA4DrS7zAiGA8yMDE5
'' SIG '' MDMxOTEwMzExMVoYDzIwMTkwMzIwMTAzMTExWjB0MDoG
'' SIG '' CisGAQQBhFkKBAExLDAqMAoCBQDgOtLvAgEAMAcCAQAC
'' SIG '' AgXyMAcCAQACAhFsMAoCBQDgPCRvAgEAMDYGCisGAQQB
'' SIG '' hFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMH
'' SIG '' oSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEA
'' SIG '' K3iZ+XszHaODsYfcytLS2ZxvqZDImZrqzlG25tDuDTmZ
'' SIG '' zeC+z3KnVvIPO8ULfyIn0xIbvxUdPberfuBraKkyt0na
'' SIG '' FHhZYcId1szhAkb3uFbF1gxb7rF81loqU18PfOZ6bd/H
'' SIG '' 4Il8OIo0ISiTIZImIH9WIOhm+AZSFqS6yTGCIi4xggMN
'' SIG '' MIIDCQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
'' SIG '' JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
'' SIG '' MjAxMAITMwAAAOCyGKnU0cK09wAAAAAA4DANBglghkgB
'' SIG '' ZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3
'' SIG '' DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCC5NuQTDiRSIgJ0
'' SIG '' QdNm3gBn8HD+HSdEohPY6ErR89PnMTCB+gYLKoZIhvcN
'' SIG '' AQkQAi8xgeowgecwgeQwgb0EIKWBL1WkMyiyV3KDUZA9
'' SIG '' VWTnDA04P49yXZqgu9GsQl+QMIGYMIGApH4wfDELMAkG
'' SIG '' A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
'' SIG '' BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
'' SIG '' dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
'' SIG '' IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADgship1NHC
'' SIG '' tPcAAAAAAOAwIgQgLPQ4IEFLViy3Gwz+U3dxvI5Ot8O1
'' SIG '' BBCJGKazGfTvzrQwDQYJKoZIhvcNAQELBQAEggEAMswk
'' SIG '' TwAG/mJIjf2iSeIKf6XpBF9tAUmFYCwMci2QGc7VCf7i
'' SIG '' jYIcrwXyhNLTRwoq4ArEnQsrglcm0ewkL1H+JHocmi5/
'' SIG '' TeUqGBHy4JPVo1rJd/cyTOA2X3PrxGbowXrk/5FkBSe8
'' SIG '' LnqL27kEsTjbs3wWS5T3c8KoW+5N0djHkMmi0J5BWoEo
'' SIG '' IObuuEJh5FlRF8iruute3kUFBXIcyrUpuVASnAMGUA11
'' SIG '' 1xqZN3K47U4Jt5DjMgXtdCATCJlp7RMAMzR4OvyKPaLB
'' SIG '' 1pEVG34ELQayWBvMeRv/bauo048Wx3PrTalsekMyJ9DZ
'' SIG '' 3MZy/jtq8gu2oCoeRD7pL20uA4Lwgw==
'' SIG '' End signature block
