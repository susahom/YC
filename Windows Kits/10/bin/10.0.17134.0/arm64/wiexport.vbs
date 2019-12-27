' Windows Installer database table export for use with Windows Scripting Host
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the Database.Export method and MsiDatabaseExport API
'
Option Explicit

Const msiOpenDatabaseModeReadOnly     = 0

Dim shortNames:shortNames = False
Dim argCount:argCount = Wscript.Arguments.Count
Dim iArg:iArg = 0
If (argCount < 3) Then
	Wscript.Echo "Windows Installer database table export utility" &_
		vbNewLine & " 1st argument is path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is path to folder to contain the exported table(s)" &_
		vbNewLine & " Subseqent arguments are table names to export (case-sensitive)" &_
		vbNewLine & " Specify '*' to export all tables, including _SummaryInformation" &_
		vbNewLine & " Specify /s or -s anywhere before table list to force short names" &_
		vbNewLine &_
		vbNewLine & " Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

Dim database : Set database = installer.OpenDatabase(NextArgument, msiOpenDatabaseModeReadOnly) : CheckError
Dim folder : folder = NextArgument
Dim table, view, record
While iArg < argCount
	table = NextArgument
	If table = "*" Then
		Set view = database.OpenView("SELECT `Name` FROM _Tables")
		view.Execute : CheckError
		Do
			Set record = view.Fetch : CheckError
			If record Is Nothing Then Exit Do
			table = record.StringData(1)
			Export table, folder : CheckError
		Loop
		Set view = Nothing
		table = "_SummaryInformation" 'not an actual table
		Export table, folder : Err.Clear  ' ignore if no summary information
	Else
		Export table, folder : CheckError
	End If
Wend
Wscript.Quit(0)            

Sub Export(table, folder)
	Dim file : If shortNames Then file = Left(table, 8) & ".idt" Else file = table & ".idt"
	database.Export table, folder, file
End Sub

Function NextArgument
	Dim arg, chFlag
	Do
		arg = Wscript.Arguments(iArg)
		iArg = iArg + 1
		chFlag = AscW(arg)
		If (chFlag = AscW("/")) Or (chFlag = AscW("-")) Then
			chFlag = UCase(Right(arg, Len(arg)-1))
			If chFlag = "S" Then 
				shortNames = True
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
'' SIG '' MIIiOgYJKoZIhvcNAQcCoIIiKzCCIicCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' VI4Hnca1EkyTrUPvd2CuA7Hjy/dDS98JnuMo4x3O0eig
'' SIG '' ggt/MIIFBzCCA++gAwIBAgITMwAAAbRrG0O4V3NSAAAA
'' SIG '' AAABtDANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBT
'' SIG '' aWduaW5nIFBDQSAyMDEwMB4XDTE3MDcxODE3NTA0MloX
'' SIG '' DTE4MDcxMDE3NTA0MlowfzELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEpMCcGA1UEAxMgTWljcm9zb2Z0IFdpbmRvd3MgS2l0
'' SIG '' cyBQdWJsaXNoZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
'' SIG '' DwAwggEKAoIBAQC6DVAuLCBjckbAsMuB89ZTZhV7pZfn
'' SIG '' g2KFfInD86O36ePIaVn6zFahQgERgATZBbuzRvvbycNm
'' SIG '' cTBozhfzz6i1J2K/cDrhKqMzLZLyqUfJlNIXuIM6D6GH
'' SIG '' 1Zdw9jP1D1cr35Hi4iCGdCqqxpIxOTYm/13J4LuoCxl4
'' SIG '' /XVFxwPHQONB4AWiJbOfcoJpMuM7jIh+fV92RUOTxbk+
'' SIG '' wi2S7dCA7h1FC+gr9iYInFKHqyxHVq06vb7RLTxpTPco
'' SIG '' A4DqTNNMLPckZYjMYlIbgkG8CUjSoZA7P6zUqweigqSg
'' SIG '' vDFnSLNFpDmnN8v9S0SQdE/11LwlLKt2fPXgawILOiM6
'' SIG '' ruULAgMBAAGjggF7MIIBdzAfBgNVHSUEGDAWBgorBgEE
'' SIG '' AYI3CgMUBggrBgEFBQcDAzAdBgNVHQ4EFgQUZ9lfS+X8
'' SIG '' hAlCNe4+O1IvvYaRvKQwUgYDVR0RBEswSaRHMEUxDTAL
'' SIG '' BgNVBAsTBE1PUFIxNDAyBgNVBAUTKzIyOTkwMytmZDZi
'' SIG '' OWU1ZC1lYjczLTQxODktYWJjMi1mN2NhY2RhMzgxYWMw
'' SIG '' HwYDVR0jBBgwFoAU5vxfe7siAFjkck619CF0IzLm76ww
'' SIG '' VgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNy
'' SIG '' b3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljQ29k
'' SIG '' U2lnUENBXzIwMTAtMDctMDYuY3JsMFoGCCsGAQUFBwEB
'' SIG '' BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNy
'' SIG '' b3NvZnQuY29tL3BraS9jZXJ0cy9NaWNDb2RTaWdQQ0Ff
'' SIG '' MjAxMC0wNy0wNi5jcnQwDAYDVR0TAQH/BAIwADANBgkq
'' SIG '' hkiG9w0BAQsFAAOCAQEAoq/AVzlL/kO91si5kz0lTxpb
'' SIG '' 5Js8Do8TlwIsmQFiHb2NQc9JBqTL+FDAcOiwnGP54l4t
'' SIG '' k6tI4t602M7PkEoPoSoACaeij/JSDPS+bsj2vYxdBeky
'' SIG '' teZh+fF0re3nenr0PqzahQnHxWnF/yh3xKv0lidMolB4
'' SIG '' Sgcyhr/eNK80Lszd9E7gmMcykfOYZXxp98c9RDdyp25J
'' SIG '' u4+UvRyGms9YuLAwadVeqi2NsAoDXWk58gvL41n8mvvd
'' SIG '' cIoFvIuRMlsJgoCqj/NvFBxllDuSdVlsymUjpkJqWaNL
'' SIG '' A0bbOzOCfF/JWqrWwYtqjeTpuDw01cMyIi9OHOSFit7K
'' SIG '' uLK1PligSDCCBnAwggRYoAMCAQICCmEMUkwAAAAAAAMw
'' SIG '' DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMw
'' SIG '' EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
'' SIG '' b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
'' SIG '' ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTEwMDcwNjIw
'' SIG '' NDAxN1oXDTI1MDcwNjIwNTAxN1owfjELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUg
'' SIG '' U2lnbmluZyBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEB
'' SIG '' BQADggEPADCCAQoCggEBAOkOZFB5Z7XE4/0JAEyelKz3
'' SIG '' VmjqRNjPxVhPqaV2fG1FutM5krSkHvn5ZYLkF9KP/USc
'' SIG '' COhlk84sVYS/fQjjLiuoQSsYt6JLbklMaxUH3tHSwoke
'' SIG '' cZTNtX9LtK8I2MyI1msXlDqTziY/7Ob+NJhX1R1dSfay
'' SIG '' Ki7VhbtZP/iQtCuDdMorsztG4/BGScEXZlTJHL0dxFVi
'' SIG '' V3L4Z7klIDTeXaallV6rKIDN1bKe5QO1Y9OyFMjByIom
'' SIG '' Cll/B+z/Du2AEjVMEqa+Ulv1ptrgiwtId9aFR9UQucbo
'' SIG '' qu6Lai0FXGDGtCpbnCMcX0XjGhQebzfLGTOAaolNo2pm
'' SIG '' Y3iT1TDPlR8CAwEAAaOCAeMwggHfMBAGCSsGAQQBgjcV
'' SIG '' AQQDAgEAMB0GA1UdDgQWBBTm/F97uyIAWORyTrX0IXQj
'' SIG '' MubvrDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
'' SIG '' BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNV
'' SIG '' HSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNV
'' SIG '' HR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29m
'' SIG '' dC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJB
'' SIG '' dXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBM
'' SIG '' MEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29m
'' SIG '' dC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEw
'' SIG '' LTA2LTIzLmNydDCBnQYDVR0gBIGVMIGSMIGPBgkrBgEE
'' SIG '' AYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cu
'' SIG '' bWljcm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVs
'' SIG '' dC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBs
'' SIG '' AF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4A
'' SIG '' dAAuIB0wDQYJKoZIhvcNAQELBQADggIBABp071dPKXvE
'' SIG '' FoV4uFDTIvwJnayCl/g0/yosl5US5eS/z7+TyOM0qduB
'' SIG '' uNweAL7SNW+v5X95lXflAtTx69jNTh4bYaLCWiMa8Iyo
'' SIG '' YlFFZwjjPzwek/gwhRfIOUCm1w6zISnlpaFpjCKTzHSY
'' SIG '' 56FHQ/JTrMAPMGl//tIlIG1vYdPfB9XZcgAsaYZ2PVHb
'' SIG '' pjlIyTdhbQfdUxnLp9Zhwr/ig6sP4GubldZ9KFGwiUpR
'' SIG '' pJpsyLcfShoOaanX3MF+0Ulwqratu3JHYxf6ptaipobs
'' SIG '' qBBEm2O2smmJBsdGhnoYP+jFHSHVe/kCIy3FQcu/HUzI
'' SIG '' Fu+xnH/8IktJim4V46Z/dlvRU3mRhZ3V0ts9czXzPK5U
'' SIG '' slJHasCqE5XSjhHamWdeMoz7N4XR3HWFnIfGWleFwr/d
'' SIG '' DY+Mmy3rtO7PJ9O1Xmn6pBYEAackZ3PPTU+23gVWl3r3
'' SIG '' 6VJN9HcFT4XG2Avxju1CCdENduMjVngiJja+yrGMbqod
'' SIG '' 5IXaRzNij6TJkTNfcR5Ar5hlySLoQiElihwtYNk3iUGJ
'' SIG '' KhYP12E8lGhgUu/WR5mggEDuFYF3PpzgUxgaUB04lZse
'' SIG '' ZjMTJzkXeIc2zk7DX7L1PUdTtuDl2wthPSrXkizON1o+
'' SIG '' QEIxpB8QCMJWnL8kXVECnWp50hfT2sGUjgd7JXFEqwZq
'' SIG '' 5tTG3yOalnXFMYIWEzCCFg8CAQEwgZUwfjELMAkGA1UE
'' SIG '' BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
'' SIG '' BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
'' SIG '' b3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9zb2Z0IENv
'' SIG '' ZGUgU2lnbmluZyBQQ0EgMjAxMAITMwAAAbRrG0O4V3NS
'' SIG '' AAAAAAABtDANBglghkgBZQMEAgEFAKCCAQQwGQYJKoZI
'' SIG '' hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
'' SIG '' CzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIE
'' SIG '' IHYc/8FhD9ohJu+0uCqDoLr+XwtePsMQt2kRVtRGNU8i
'' SIG '' MDwGCisGAQQBgjcKAxwxLgwsRzV2L2N6UmhRWnp6K0VC
'' SIG '' SlY4eFkwTUZKbS84M0hiRWJHbit5bWVHM3JRTT0wWgYK
'' SIG '' KwYBBAGCNwIBDDFMMEqgJIAiAE0AaQBjAHIAbwBzAG8A
'' SIG '' ZgB0ACAAVwBpAG4AZABvAHcAc6EigCBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vd2luZG93czANBgkqhkiG9w0B
'' SIG '' AQEFAASCAQCmFi9pWALDKbfYvOiOtHFeCL3cK/sX8TgR
'' SIG '' HSHXzJYiN1lQq7UQbxii2OIriHJAZ52NB6pId0QlfYoI
'' SIG '' x0BNR4BWjralUihTdQ6+r1dOGRptejAfQ7uDy5JP2H/y
'' SIG '' mqcLNEWAMSW5unw/cftk5pokKbYiBzgEOm+IB+i6ISRZ
'' SIG '' C1MwWZf2N6pdWZVVckgFlA8hqCeoEPkom30zrP2n14Rp
'' SIG '' zyvQtPSFWwATSMa13wUHTLUm4hJ+Wrj9jEXIMc/H760U
'' SIG '' ep7Xa6PVvMX+mAHLouKgdM82DIcSE4YqK2Yjt1fEWC2r
'' SIG '' VutpCrFf6pDDwtQr9iGQAdnjyMaoAUSYkAthoWCfZGwK
'' SIG '' oYITRjCCE0IGCisGAQQBgjcDAwExghMyMIITLgYJKoZI
'' SIG '' hvcNAQcCoIITHzCCExsCAQMxDzANBglghkgBZQMEAgEF
'' SIG '' ADCCATwGCyqGSIb3DQEJEAEEoIIBKwSCAScwggEjAgEB
'' SIG '' BgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIMyv
'' SIG '' tG1+FLb+l1sHwKR/v6P9QUFaihSVaoaigF9EolkZAgZa
'' SIG '' sq+gHJMYEzIwMTgwNDIxMDIyNzIwLjA2MVowBwIBAYAC
'' SIG '' AfSggbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDDAK
'' SIG '' BgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
'' SIG '' RVNOOjIxMzctMzdBMC00QUFBMSUwIwYDVQQDExxNaWNy
'' SIG '' b3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIOyjCCBnEw
'' SIG '' ggRZoAMCAQICCmEJgSoAAAAAAAIwDQYJKoZIhvcNAQEL
'' SIG '' BQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
'' SIG '' aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
'' SIG '' ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMT
'' SIG '' KU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
'' SIG '' cml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcw
'' SIG '' MTIxNDY1NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
'' SIG '' A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
'' SIG '' MTAwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
'' SIG '' AQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF++18
'' SIG '' aEssX8XD5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxh
'' SIG '' MFmxMEQP8WCIhFRDDNdNuDgIs0Ldk6zWczBXJoKjRQ3Q
'' SIG '' 6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSxz5NMksHE
'' SIG '' pl3RYRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBi
'' SIG '' sV39dx898Fd1rL2KQk1AUdEPnAY+Z3/1ZsADlkR+79BL
'' SIG '' /W7lmsqxqPJ6Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6
'' SIG '' p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGj
'' SIG '' ggHmMIIB4jAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4E
'' SIG '' FgQU1WM6XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYBBAGC
'' SIG '' NxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8G
'' SIG '' A1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU1fZWy4/o
'' SIG '' olxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
'' SIG '' aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
'' SIG '' cHJvZHVjdHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMu
'' SIG '' Y3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcwAoY+
'' SIG '' aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0
'' SIG '' cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAG
'' SIG '' A1UdIAEB/wSBlTCBkjCBjwYJKwYBBAGCNy4DMIGBMD0G
'' SIG '' CCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
'' SIG '' b20vUEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsG
'' SIG '' AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAFAAbwBsAGkA
'' SIG '' YwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFv
'' SIG '' s+umzPUxvs8F4qn++ldtGTCzwsVmyWrf9efweL3HqJ4l
'' SIG '' 4/m87WtUVwgrUYJEEvu5U4zM9GASinbMQEBBm9xcF/9c
'' SIG '' +V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84
'' SIG '' Dxf1L3mBZdmptWvkx872ynoAb0swRCQiPM/tA6WWj1kp
'' SIG '' vLb9BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp8c6ZZpCM
'' SIG '' /2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4
'' SIG '' pm3S4Zz5Hfw42JT0xqUKloakvZ4argRCg7i1gJsiOCC1
'' SIG '' JeVk7Pf0v35jWSUPei45V3aicaoGig+JFrphpxHLmtgO
'' SIG '' R5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x4QDf
'' SIG '' 5zEHpJM692VHeOj4qEir995yfmFrb3epgcunCaw5u+zG
'' SIG '' y9iCtHLNHfS4hQEegPsbiSpUObJb2sgNVZl6h3M7COaY
'' SIG '' LeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKnQqLJzxlB
'' SIG '' TeCG+SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyX
'' SIG '' UHHXodLFVeNp3lfB0d4wwP3M5k37Db9dT+mdHhk4L7zP
'' SIG '' WAUu7w2gUDXa7wknHNWzfjUeCLraNtvTX4/edIhJEjCC
'' SIG '' BNkwggPBoAMCAQICEzMAAACvNY//0yJFdksAAAAAAK8w
'' SIG '' DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' UENBIDIwMTAwHhcNMTYwOTA3MTc1NjU2WhcNMTgwOTA3
'' SIG '' MTc1NjU2WjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBF
'' SIG '' U046MjEzNy0zN0EwLTRBQUExJTAjBgNVBAMTHE1pY3Jv
'' SIG '' c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
'' SIG '' SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCT6ECGDhrLcfAD
'' SIG '' DaaPpOdhEtBh6pBqlVa6t6BNSylk2FGaO11nk62I7kPU
'' SIG '' 3V3U7xJxn20/9eqXKsg6t1UR1KcztXRETZhN4Xqlx92p
'' SIG '' LMyIHwhvPvHPhOXhbA/nw+45gYspMydZ+E/OpZuNBgOu
'' SIG '' 3tRJU2LjWSf16ApMvMbgH1fd0Zv/TgfQbGCYl4GuYQ6Q
'' SIG '' eeQLKMv5vRBrPMFzERBe4uNS9j9heuRFr3VBrUsMtek0
'' SIG '' GhE3cKA/6KwrtAeTvq6DydnidJFwYbAVekT0hJEN/Nsk
'' SIG '' M2YAzCCL7sFoPXEfn30L5dJoJ4aeabKqsxxKF1T5B2n+
'' SIG '' d2/HP8ac0vFSUKvHlzijAgMBAAGjggEbMIIBFzAdBgNV
'' SIG '' HQ4EFgQUfR5VxjGK2mALBmawFNlq/HsS9uEwHwYDVR0j
'' SIG '' BBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
'' SIG '' BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
'' SIG '' XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
'' SIG '' BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
'' SIG '' Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
'' SIG '' BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEAasgA
'' SIG '' hnj7DEKcENb3KKwPhGqL/N1b6h9aQESpLhNfixpJdmkS
'' SIG '' KuaE5vjmutGPPC4p7Us1IOCBuvrVgxcVm3VTmjx/Y5DL
'' SIG '' oAhkL/Nh80rwivBFToiNPGuQjQDiayNJrHlnIOdlM676
'' SIG '' 5CLBQg11ZQ/Unc0e4zDerFqGGsKFh0ck7nw84nI4ORhu
'' SIG '' PHWN5gHZx3dwo9r6WbmJQFmRtsXyu4UtndUYf+OTG3J/
'' SIG '' sQmtEAOuxSUm582jfqK1uPVK1TQUfI/ygsM2CNIwiDZ1
'' SIG '' 1wgZa2IXkdMDQrJzjNEVqHUprP+ARQtFsd1y9lk1uVIG
'' SIG '' zuaIf/8trKzR/OCjz/wcOR/b0BDT26GCA3QwggJcAgEB
'' SIG '' MIHioYG4pIG1MIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQww
'' SIG '' CgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
'' SIG '' IEVTTjoyMTM3LTM3QTAtNEFBQTElMCMGA1UEAxMcTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
'' SIG '' BSsOAwIaBQADFQDY6qwVLW8upS2m/QIDUOKAG/5OI6CB
'' SIG '' wTCBvqSBuzCBuDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDehN2VMCIYDzIwMTgwNDIwMjE0
'' SIG '' MzQ5WhgPMjAxODA0MjEyMTQzNDlaMHQwOgYKKwYBBAGE
'' SIG '' WQoEATEsMCowCgIFAN6E3ZUCAQAwBwIBAAICCiwwBwIB
'' SIG '' AAICGfcwCgIFAN6GLxUCAQAwNgYKKwYBBAGEWQoEAjEo
'' SIG '' MCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgC
'' SIG '' AQACAx6EgDANBgkqhkiG9w0BAQUFAAOCAQEAMeBtrV99
'' SIG '' iOCNnGxiIzuR8NmACumu+tAwqKxS9h/MR6v2JcXLaob8
'' SIG '' VTRDCmAMfNxWmyBVsIKxSrKcWFB8AbMeUH2NQSaNDMp4
'' SIG '' dK+buc6z6wUJ4yvAZRPeA6ckVrn9GH2eXDKvOiiTr9KL
'' SIG '' EdEZ4K3RaVOsYpzmJHBmtK1hR4mE3GriAK677CsV4r79
'' SIG '' HfJlIZq3Ict7IBEDwDfQyMBLrVUMknXtb36r6GUYxs64
'' SIG '' wQwHIN4D4hDLv8cSdVQr2NjHHdwO6HrYx3ict+N1pjya
'' SIG '' zc78l8/z61Jd6hMosLMuwfoMWlcKCjPRB3k+dBKb8naN
'' SIG '' 1QfkB9MWBcbV5ZZMH8P54lWlcDGCAvUwggLxAgEBMIGT
'' SIG '' MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAA
'' SIG '' rzWP/9MiRXZLAAAAAACvMA0GCWCGSAFlAwQCAQUAoIIB
'' SIG '' MjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
'' SIG '' KoZIhvcNAQkEMSIEIBrEze2Ha9lInOIeDasxHxCj1Dw0
'' SIG '' bUuhNkkrN14twfB1MIHiBgsqhkiG9w0BCRACDDGB0jCB
'' SIG '' zzCBzDCBsQQU2OqsFS1vLqUtpv0CA1DigBv+TiMwgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAK81j//TIkV2SwAAAAAArzAWBBRIMEbbjRyFDOLw
'' SIG '' svFn+vprOSrlljANBgkqhkiG9w0BAQsFAASCAQAqXvGE
'' SIG '' Mg+nii+kDaTjDdAVzC6jHuQhHf4n+m6KegFGCUebuaaT
'' SIG '' j10IjTNNtStkWYFBj+lp6pE9Mbn4r5knETbtVkIAK9tf
'' SIG '' YPDGb2tPucP8jNluHaa4voJ/nZjGXctITUuYXe054SJb
'' SIG '' JCOlNqbUyFwmHGfO3yj6JEBvgxrCVFgPx8rQoTKaSoyb
'' SIG '' FM+fhEfn6Ya6GAETtR71u4106S561EiJdFoK8kO8PgJH
'' SIG '' 9zL796sUAKUJ4E3uI6iyfuT+8k42Lwta+xOn+0eKa+6A
'' SIG '' GKSgFkCf+LSR8G68N8xCbQ+TTJyP3058fimWElM4n0wf
'' SIG '' DIXLwMT/B5/hxHr+TR8FjXyEQ1Pc
'' SIG '' End signature block
