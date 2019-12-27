' Windows Installer script viewer for use with Windows Scripting Host CScript.exe only
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the special database processing mode for viewing script files
'
Option Explicit

Const msiOpenDatabaseModeListScript = 5

' Check arg count, and display help if argument not present or contains ?
Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If argCount = 0 Then
	Wscript.Echo "Windows Installer Script Viewer for Windows Scripting Host (CScript.exe)" &_
		vbNewLine & " Argument is path to installer execution script" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Cannot run with GUI script host, as listing is performed to standard out
If UCase(Mid(Wscript.FullName, Len(Wscript.Path) + 2, 1)) = "W" Then
	Wscript.Echo "Cannot use WScript.exe - must use CScript.exe with this program"
	Wscript.Quit 2
End If

Dim installer, view, database, record, fieldCount, template, index, field
On Error Resume Next
Set installer = CreateObject("WindowsInstaller.Installer") : CheckError
Set database = installer.Opendatabase(Wscript.Arguments(0), msiOpenDatabaseModeListScript) : CheckError
Set view = database.Openview("")
view.Execute : CheckError
Do
   Set record = view.Fetch
   If record Is Nothing Then Exit Do
   fieldCount = record.FieldCount
   template = record.StringData(0)
   index = InstrRev(template, "[") + 1
   If (index > 1) Then
      field = Int(Mid(template, index, InstrRev(template, "]") - index))
      If field < fieldCount Then
         template = Left(template, Len(template) - 1)
         While field < fieldCount
            field = field + 1
            template = template & ",[" & field & "]"
         Wend
         record.StringData(0) = template & ")"
      End If
   End If
   Wscript.Echo record.FormatText
Loop
Wscript.Quit 0

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
'' SIG '' MIIh2AYJKoZIhvcNAQcCoIIhyTCCIcUCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' yGbucx5C9ty0NdJlcwpY0JNDXmCZOM9FQgmr4/kXaQOg
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
'' SIG '' IgQgIzWjuDNixL6mnYLp3SYsLFP9nfR9rcGn48MkdNYr
'' SIG '' r9wwPAYKKwYBBAGCNwoDHDEuDCxIQ21qZ3I3VWJBOFM4
'' SIG '' UnRPWmNWZ0k2Ky9LSmFXTWZGaS9OK0xmNmN3eVdjPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAFxrgmmjlhvPfLS344MFaAlMv7QiWsf0
'' SIG '' afJTfG3Wf0EauVUjnFglPP4MyrtJ3N4vXo0mAUjnhRYc
'' SIG '' gWV+3pGM/6Z4ELSTTGev8CH1m3s0MIoCfgK1DAmzdyOU
'' SIG '' bPgBXeXQhS383FArcLcM0dRJN5fjk0ILjPISppPVyH6p
'' SIG '' A/R/h7vnktinMDNTzYMHkcplcRqDSUDfmCl4tbYaG1kT
'' SIG '' JeDGCaqYHUgWzCCrs+tQO5278ismF/ArdiPYqboihVgI
'' SIG '' lpwqap+hwPd13yRkJ7MIlHsX4scHedDT0rwM5xDTl9P3
'' SIG '' wVSzevN/XCxGNWXjhs5H4njNdlDYra4eXB9JNIUk13hg
'' SIG '' EOWhghLiMIIS3gYKKwYBBAGCNwMDATGCEs4wghLKBgkq
'' SIG '' hkiG9w0BBwKgghK7MIIStwIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBUQYLKoZIhvcNAQkQAQSgggFABIIBPDCCATgC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' k9OC3bjFxRboz2jTGVtj96NW+on4isthAdx2lc7jHFYC
'' SIG '' Blx1QM7TqRgTMjAxOTAzMTkwMjU5MDYuODQ4WjAEgAIB
'' SIG '' 9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
'' SIG '' AldBMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
'' SIG '' Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRl
'' SIG '' ZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RkM0MS00
'' SIG '' QkQ0LUQyMjAxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIHNlcnZpY2Wggg45MIIE8TCCA9mgAwIBAgIT
'' SIG '' MwAAAOGcqCPPPSEhhwAAAAAA4TANBgkqhkiG9w0BAQsF
'' SIG '' ADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0x
'' SIG '' ODA4MjMyMDI3MDJaFw0xOTExMjMyMDI3MDJaMIHKMQsw
'' SIG '' CQYDVQQGEwJVUzELMAkGA1UECBMCV0ExEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxh
'' SIG '' bmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
'' SIG '' aGFsZXMgVFNTIEVTTjpGQzQxLTRCRDQtRDIyMDElMCMG
'' SIG '' A1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgc2Vydmlj
'' SIG '' ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
'' SIG '' AJvhrH0LWs8Pa72NDWnSakVkNQXGdlob5H+nmMJfx/ha
'' SIG '' KB7dEtZ69dew01Z5cXBCyqGO2Xr4m2Uii/4MGbBcGDrz
'' SIG '' wdBKMGQJ4oCj/N4f+0zM+RK7BsSYSd9Kvv1jCM9aqjvT
'' SIG '' dJ3a6noaYm+5QufvXMMTZfmhbKa72MnGrs8vtRdOKMBT
'' SIG '' tYcSSscwHnZMMxmuYl04JLuHjTlIBgxoMnjkZc0doBBD
'' SIG '' NbJipcG11uCZyiEmHegokEn8rx+7LRIM03NaA4XIJBCu
'' SIG '' 9S0o9EKucxH/KV7dnar1WkpG5MsqOyTFokIac4HH7bII
'' SIG '' QQgfcPsrJqxo6m9Unov6RpQvLJJt0Jhv9x0CAwEAAaOC
'' SIG '' ARswggEXMB0GA1UdDgQWBBT/AlutaLbKjm+FAs/F5FwN
'' SIG '' Xsi4PDAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNo
'' SIG '' WoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
'' SIG '' aWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB
'' SIG '' BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0
'' SIG '' YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAA
'' SIG '' MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEB
'' SIG '' CwUAA4IBAQAbcQlO2+9iK1sqSyxFYSRuJxqHjMDRTKi+
'' SIG '' ZnVjNNGMUfYwlyaJn6ntWPz7rKXrFfUnbtVLxFOKhJBy
'' SIG '' uAt41s5GdVJssNwhdVLqJ0ebeIBpvSAeNIdWTiHPuAki
'' SIG '' iKYWM+mpSFqeOgzd7hk/OuI26alUjBEkOJCx2AEe1P31
'' SIG '' MwB2n4c1NkJJPaZ9h7fYVwmec1YasqXN4x/+8y8cwi/g
'' SIG '' 5DBNyvNToL6yUqZS0e3svqrW2gKOQNAN+QpDM0Tf/Xxr
'' SIG '' 4zKTBRRK0DhVAG5qWgNh35vgJnpUAj22AZ8++fLTUiVt
'' SIG '' LQebEJsyzeliDnHxfF1vPbmYYgT5SvK0HXIbIeBv6f7H
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
'' SIG '' cyBUU1MgRVNOOkZDNDEtNEJENC1EMjIwMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBzZXJ2aWNloiMK
'' SIG '' AQEwBwYFKw4DAhoDFQBB33iP2WWCQDtkZKLUXodkQcCc
'' SIG '' TaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAk
'' SIG '' BgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
'' SIG '' MDEwMA0GCSqGSIb3DQEBBQUAAgUA4DrFnjAiGA8yMDE5
'' SIG '' MDMxOTA5MzQyMloYDzIwMTkwMzIwMDkzNDIyWjB0MDoG
'' SIG '' CisGAQQBhFkKBAExLDAqMAoCBQDgOsWeAgEAMAcCAQAC
'' SIG '' AhVRMAcCAQACAhGbMAoCBQDgPBceAgEAMDYGCisGAQQB
'' SIG '' hFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMH
'' SIG '' oSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEA
'' SIG '' b0uQyU41QRM6woyiJ/59Z3s/UC/LKKCIt2P9ItOMbm1N
'' SIG '' eGaPtzZHI57E9LGEY1RSwegiemgFhesi8HWL6nkmwwfa
'' SIG '' JAO/ls3ZWY60/oI2oR9SQW51YCClHqJcQSyczGFzVT3J
'' SIG '' aG9cLNMUZI7kR+GV4Y9/EV48UBSJNjkWqYOQnhwxggMN
'' SIG '' MIIDCQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
'' SIG '' JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
'' SIG '' MjAxMAITMwAAAOGcqCPPPSEhhwAAAAAA4TANBglghkgB
'' SIG '' ZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3
'' SIG '' DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDBt4OBT7fbnNPF
'' SIG '' W85+Z6M3R2Fk5g+lI9y9W5PuoZcCbzCB+gYLKoZIhvcN
'' SIG '' AQkQAi8xgeowgecwgeQwgb0EILxo72txumUJwo/jS6KP
'' SIG '' Un9+XDxQXc4BaS+pMzwzr2zeMIGYMIGApH4wfDELMAkG
'' SIG '' A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAO
'' SIG '' BgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
'' SIG '' dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
'' SIG '' IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAADhnKgjzz0h
'' SIG '' IYcAAAAAAOEwIgQgsB0iutv9kyLrR43Ix4xxbmKkG+Om
'' SIG '' Omakhwxw5sqBMXkwDQYJKoZIhvcNAQELBQAEggEAJImv
'' SIG '' 0vw89UGiIi4DCyQDPMcSeCaBjzunh9Api2FJpmCVCO9v
'' SIG '' VwL+zlm+UJ6G9imNlz251mocIpurJFYt+WsWf5bfBy8H
'' SIG '' O7u+JpcUPLN9vocdvLdnwodVIdKPGrmvrlxsHsgvSZF4
'' SIG '' ndpSZCqUQNIRraAAT1E3SOc2kMGxfLlYFg0Gv4YxHkmE
'' SIG '' YKcL+mXwZ/PASOSgayE4F9C1NLEXc1FfmiLH2v5LC8Uu
'' SIG '' ywfXLQ948vfvkuEMdtiT78FBiliNHqar+RNyKsoxv0RL
'' SIG '' ylDWh0U8a+z39u1AK1k7so6xFt4W4peUpC6I1cbM27Bj
'' SIG '' Ufm9+NANslHGF6oPFQ9pR6AVZ9oPnQ==
'' SIG '' End signature block
