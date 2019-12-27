' Windows Installer utility to applay a transform to an installer database
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates use of Database.ApplyTransform and MsiDatabaseApplyTransform
'
Option Explicit

' Error conditions that may be suppressed when applying transforms
Const msiTransformErrorAddExistingRow         = 1 'Adding a row that already exists. 
Const msiTransformErrorDeleteNonExistingRow   = 2 'Deleting a row that doesn't exist. 
Const msiTransformErrorAddExistingTable       = 4 'Adding a table that already exists. 
Const msiTransformErrorDeleteNonExistingTable = 8 'Deleting a table that doesn't exist. 
Const msiTransformErrorUpdateNonExistingRow  = 16 'Updating a row that doesn't exist. 
Const msiTransformErrorChangeCodePage       = 256 'Transform and database code pages do not match 

Const msiOpenDatabaseModeReadOnly     = 0
Const msiOpenDatabaseModeTransact     = 1
Const msiOpenDatabaseModeCreate       = 3

If (Wscript.Arguments.Count < 2) Then
	Wscript.Echo "Windows Installer database tranform application utility" &_
		vbNewLine & " 1st argument is the path to an installer database" &_
		vbNewLine & " 2nd argument is the path to the transform file to apply" &_
		vbNewLine & " 3rd argument is optional set of error conditions to suppress:" &_
		vbNewLine & "     1 = adding a row that already exists" &_
		vbNewLine & "     2 = deleting a row that doesn't exist" &_
		vbNewLine & "     4 = adding a table that already exists" &_
		vbNewLine & "     8 = deleting a table that doesn't exist" &_
		vbNewLine & "    16 = updating a row that doesn't exist" &_
		vbNewLine & "   256 = mismatch of database and transform codepages" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Open database and apply transform
Dim database : Set database = installer.OpenDatabase(Wscript.Arguments(0), msiOpenDatabaseModeTransact) : CheckError
Dim errorConditions:errorConditions = 0
If Wscript.Arguments.Count >= 3 Then errorConditions = CLng(Wscript.Arguments(2))
Database.ApplyTransform Wscript.Arguments(1), errorConditions : CheckError
Database.Commit : CheckError

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
'' SIG '' ocXRzPIBsTOs40BugTYvo1tESbFrFB3U6AbYVQhStNmg
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
'' SIG '' IC0J+qPZFDgwEyiEvrJozTxVjbdsdwcOYM5GWgUyuLG4
'' SIG '' MDwGCisGAQQBgjcKAxwxLgwsckJQaDNQeE1BSmhDT3N6
'' SIG '' UnBXWGx0dW9zaTl0dVIrKzlFVXVFMUEzUy9CQT0wWgYK
'' SIG '' KwYBBAGCNwIBDDFMMEqgJIAiAE0AaQBjAHIAbwBzAG8A
'' SIG '' ZgB0ACAAVwBpAG4AZABvAHcAc6EigCBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vd2luZG93czANBgkqhkiG9w0B
'' SIG '' AQEFAASCAQCNtqG63m8hYR8FUUyJFuucQ38SyLR24qNe
'' SIG '' mwdMYglz5vAsz6NBMrvQD+NR/ukn0lp/SIxLyRwc6xy+
'' SIG '' /kCfxjbgV69N26L9jRd6ZJ/Zr1w+65UHNAc8ikE4COJO
'' SIG '' HWuhKdZMu3LsvgLhmhqI79qY2EaBJLCBo6IagxoMXmJH
'' SIG '' hqlyoSnE5YkaxUvQo/VScSqkvMxVVJkXXyRMIgutax5Z
'' SIG '' usGYQpfddOwpkEsODwvFQ5J9FpFmJfTts1qF2OHj48W/
'' SIG '' 7Kh2IcTjhHyShQfPO8caLXbZAmhMD3tGNfqMp99Ouim2
'' SIG '' S+JlVXLEFi/AlAQie1Ky4TkFyWuEbj+Lv49f8H5xAcI0
'' SIG '' oYITRjCCE0IGCisGAQQBgjcDAwExghMyMIITLgYJKoZI
'' SIG '' hvcNAQcCoIITHzCCExsCAQMxDzANBglghkgBZQMEAgEF
'' SIG '' ADCCATwGCyqGSIb3DQEJEAEEoIIBKwSCAScwggEjAgEB
'' SIG '' BgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIKcu
'' SIG '' fEWkJVl1Vzr2sdUHb9ptaaaB5GAI1N8YoWTO7VdRAgZa
'' SIG '' soGXN+EYEzIwMTgwNDIxMDIzNjI0LjE2NlowBwIBAYAC
'' SIG '' AfSggbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDDAK
'' SIG '' BgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
'' SIG '' RVNOOjBERTgtMkRDNS0zQ0E5MSUwIwYDVQQDExxNaWNy
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
'' SIG '' BNkwggPBoAMCAQICEzMAAACm/VLgixYnPwAAAAAAAKYw
'' SIG '' DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' UENBIDIwMTAwHhcNMTYwOTA3MTc1NjUxWhcNMTgwOTA3
'' SIG '' MTc1NjUxWjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBF
'' SIG '' U046MERFOC0yREM1LTNDQTkxJTAjBgNVBAMTHE1pY3Jv
'' SIG '' c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
'' SIG '' SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBuM2eCSe0cIuF
'' SIG '' /x1aSNHA5udhcPU9qlRbwN3VssAQ665EmlyhiamvYcVT
'' SIG '' 9AJs/b9sy9HzkpoSoBFthTc+cd3RoO+aId3YWyaDkA8m
'' SIG '' f40eHuPjJBstMtG077fAzQpH2OBPNce7BDhFJmtvqOKF
'' SIG '' JrON9PezvFnwIhiY/1c0GBtO0bTv2O4qiG39/h8VXSmB
'' SIG '' a3Y5MMX/fSOiRHQYswg0ybnI182M71FN4PMP7zq0LdKz
'' SIG '' Jfm/ZJMXVC/vyFFjlSWxLKNIcchnqnGH2NevyucbnaA5
'' SIG '' MsWmb2ob1Rh1lKmqeVms39uO0spJnHdBqtgwOWbkkXjU
'' SIG '' 7Sfpl8N+WUT6LblqcQPdAgMBAAGjggEbMIIBFzAdBgNV
'' SIG '' HQ4EFgQUDuHFQ8kmG9zLh7vcTGbXBrzRwCYwHwYDVR0j
'' SIG '' BBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
'' SIG '' BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
'' SIG '' XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
'' SIG '' BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
'' SIG '' Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
'' SIG '' BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEAhCAn
'' SIG '' oQbouNb8kjrKSNady9CWjrME2siuhF+rOqL02rViVi8K
'' SIG '' wbKPPrcfLGBadSLOR5HfQXrZnpA0K6NYAw3DhsaW1bqF
'' SIG '' 0eNjtBlRvWePNmXs1hkmlweM+laX/sxcGW13Bljp0Quv
'' SIG '' GqsLFPdPCVDDGWuYzCHjJYbWQTfrZS3ZbGyPR/8XT72l
'' SIG '' UDajq8LcdXDhYVrvQRsqA9EGeV7KpkMYq1dEk4HA60Ko
'' SIG '' EwXUGDicWyY23JXrM6W0cJr8vZ1vpAek3x5Cpw87uUGx
'' SIG '' tku/hBJF2W7PWHy242sLrgAG1qSWu2cRLztQ6ZJs9ZpZ
'' SIG '' yIfkr2S+VSwzcDYfi/Tq5pwBPaQ7L6GCA3QwggJcAgEB
'' SIG '' MIHioYG4pIG1MIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQww
'' SIG '' CgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
'' SIG '' IEVTTjowREU4LTJEQzUtM0NBOTElMCMGA1UEAxMcTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
'' SIG '' BSsOAwIaBQADFQB/oDBsfKPq6vKBBNM1oufc4tSFPaCB
'' SIG '' wTCBvqSBuzCBuDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDehN1CMCIYDzIwMTgwNDIwMjE0
'' SIG '' MjI2WhgPMjAxODA0MjEyMTQyMjZaMHQwOgYKKwYBBAGE
'' SIG '' WQoEATEsMCowCgIFAN6E3UICAQAwBwIBAAICEnEwBwIB
'' SIG '' AAICGSQwCgIFAN6GLsICAQAwNgYKKwYBBAGEWQoEAjEo
'' SIG '' MCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgC
'' SIG '' AQACAwehIDANBgkqhkiG9w0BAQUFAAOCAQEAaWv5BXGr
'' SIG '' xHI/9pY8gtO4G4zMkdm//qdsuXzdd52tRZ+ogC0vQVbL
'' SIG '' c4RALb4cgtHVBNyqvGkoYSmua9rQ4r8+cCskZGXy+CR5
'' SIG '' QRhk6oRM1/QDmYdgnlJb/L4EJr6qUmtXkfnHuM5qCxrt
'' SIG '' srit+UFxwExE41izMJCsI0NHIHREU7nD6nAcQITvjnAS
'' SIG '' MWOFaSvHilol786/V4a5nVQZvShcbrNcbFQyGSjnfANk
'' SIG '' xcqEr+iibqv8tt1Gjfk3IS1u5hr9+AtqEw9Ox8q0NU7u
'' SIG '' LvBB+qmiPXCzOdilW9Gg/6wADcG+yBNOku0UfhOi0o8b
'' SIG '' fnUvp1Jqn+rC2bP4WOH+DSXfxzGCAvUwggLxAgEBMIGT
'' SIG '' MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAA
'' SIG '' pv1S4IsWJz8AAAAAAACmMA0GCWCGSAFlAwQCAQUAoIIB
'' SIG '' MjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
'' SIG '' KoZIhvcNAQkEMSIEIK1LtLMCDDiyGlxMD+3Bx3rlNTH3
'' SIG '' NrSGEwR7PVbfyVQFMIHiBgsqhkiG9w0BCRACDDGB0jCB
'' SIG '' zzCBzDCBsQQUf6AwbHyj6urygQTTNaLn3OLUhT0wgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAKb9UuCLFic/AAAAAAAApjAWBBTuzjnSLPZvfPx8
'' SIG '' S5TULmKF6TQ1wjANBgkqhkiG9w0BAQsFAASCAQCfHO15
'' SIG '' lijnrI/v886CyFWN2qwfCcgTRs5Po1daHnEIrrxA+A3R
'' SIG '' YH+rQ+Jed5k7MT/IoqV1DbnFD/xOIirlSYLouJ7feZWq
'' SIG '' 7ldY42nLjl1cylwWukeTKWp+Dvd1Q5FDU0fPRTH0OTeP
'' SIG '' B8vunxongPQRi8eVJ52Sc/4gT1bB4i3f0P4vJtBzXCPH
'' SIG '' QUVwb9cw/cF9jCT0Wv1m4CJsWN2zYi8iamqnszsiW8pF
'' SIG '' 3Z0Qn+P0yXpNc/ILxuBls5fjvsr+zPgywI15GOvVTZ0y
'' SIG '' S91yRBAlVD9iHfPYddh+H/Z4lRC4C3TNJmjst/++A0UI
'' SIG '' n+meMOrpTFAJPj/G7mobNyhFee6E
'' SIG '' End signature block
