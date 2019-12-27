' Windows Installer database utility to merge data from another database              
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the Database.Merge method and MsiDatabaseMerge API
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
If (argCount < 2) Then
	Wscript.Echo "Windows Installer database merge utility" &_
		vbNewLine & " 1st argument is the path to MSI database (installer package)" &_
		vbNewLine & " 2nd argument is the path to database containing data to merge" &_
		vbNewLine & " 3rd argument is the optional table to contain the merge errors" &_
		vbNewLine & " If 3rd argument is not present, the table _MergeErrors is used" &_
		vbNewLine & "  and that table will be dropped after displaying its contents." &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Open databases and merge data
Dim database1 : Set database1 = installer.OpenDatabase(WScript.Arguments(0), msiOpenDatabaseModeTransact) : CheckError
Dim database2 : Set database2 = installer.OpenDatabase(WScript.Arguments(1), msiOpenDatabaseModeReadOnly) : CheckError
Dim errorTable : errorTable = "_MergeErrors"
If argCount >= 3 Then errorTable = WScript.Arguments(2)
Dim hasConflicts:hasConflicts = database1.Merge(database2, errorTable) 'Old code returns void value, new returns boolean
If hasConflicts <> True Then hasConflicts = CheckError 'Temp for old Merge function that returns void
If hasConflicts <> 0 Then
	Dim message, line, view, record
	Set view = database1.OpenView("Select * FROM `" & errorTable & "`") : CheckError
	view.Execute
	Do
		Set record = view.Fetch
		If record Is Nothing Then Exit Do
		line = record.StringData(1) & " table has " & record.IntegerData(2) & " conflicts"
		If message = Empty Then message = line Else message = message & vbNewLine & line
	Loop
	Set view = Nothing
	Wscript.Echo message
End If
If argCount < 3 And hasConflicts Then database1.OpenView("DROP TABLE `" & errorTable & "`").Execute : CheckError
database1.Commit : CheckError
Quit 0

Function CheckError
	Dim message, errRec
	CheckError = 0
	If Err = 0 Then Exit Function
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbNewLine & errRec.FormatText : CheckError = errRec.IntegerData(1)
	End If
	If CheckError = 2268 Then Err.Clear : Exit Function
	Wscript.Echo message
	Wscript.Quit 2
End Function

'' SIG '' Begin signature block
'' SIG '' MIIiOgYJKoZIhvcNAQcCoIIiKzCCIicCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' QXX+BeRpnj5/3w9MZiLTEbzssoFPyxBqr0/6QcQWjb+g
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
'' SIG '' IH1k2sAhRI5EbNBoPewCutWA8VNMasrcWJVdk25WCsPP
'' SIG '' MDwGCisGAQQBgjcKAxwxLgwsQ29zNVc5WllMUU5XaUhJ
'' SIG '' dW9ET241cWJTam1RWmpjdm01bGN3UVJTcThCST0wWgYK
'' SIG '' KwYBBAGCNwIBDDFMMEqgJIAiAE0AaQBjAHIAbwBzAG8A
'' SIG '' ZgB0ACAAVwBpAG4AZABvAHcAc6EigCBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vd2luZG93czANBgkqhkiG9w0B
'' SIG '' AQEFAASCAQBmUmV4Q/HZeHBkNcb5ng3wjPUMjBUPxH7J
'' SIG '' zthPF7ggQqW+KyawuzqYuqCkpv4xrI9pu16uZO92tzuK
'' SIG '' xC0E1ppfm7+492DFVbgf5M4yEdzsmUa16avMF7HfRD4t
'' SIG '' YKVqFvs5EN5Gw2mdmaPLTwuRO+enN5eCh/2oAGa4ZC0r
'' SIG '' ainIryFOniuRg9hLSzFAl+YMgYnal7VtWpqt6df3Cbew
'' SIG '' PCn0sYzivtX51Ciyp7BxtCClMDYIKOGHvaGy5qMm17/q
'' SIG '' MZhNognhzKbe4mATlrJensf91mULHx9UCT8WC0hzL/FT
'' SIG '' hDI6oIV4NHwoLqSOySvi9aT6U5jSAcKvO8DegYVtiu3R
'' SIG '' oYITRjCCE0IGCisGAQQBgjcDAwExghMyMIITLgYJKoZI
'' SIG '' hvcNAQcCoIITHzCCExsCAQMxDzANBglghkgBZQMEAgEF
'' SIG '' ADCCATwGCyqGSIb3DQEJEAEEoIIBKwSCAScwggEjAgEB
'' SIG '' BgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEINYs
'' SIG '' 8WnLku1p6dnDP1/xAMIvoo2k2+IzqoJ+yQOoqBIIAgZa
'' SIG '' snV8/rMYEzIwMTgwNDIxMDIzMjIyLjY1NVowBwIBAYAC
'' SIG '' AfSggbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDDAK
'' SIG '' BgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
'' SIG '' RVNOOkY2RkYtMkRBNy1CQjc1MSUwIwYDVQQDExxNaWNy
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
'' SIG '' BNkwggPBoAMCAQICEzMAAAClSBdyJ/lwvmMAAAAAAKUw
'' SIG '' DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' UENBIDIwMTAwHhcNMTYwOTA3MTc1NjUwWhcNMTgwOTA3
'' SIG '' MTc1NjUwWjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBF
'' SIG '' U046RjZGRi0yREE3LUJCNzUxJTAjBgNVBAMTHE1pY3Jv
'' SIG '' c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
'' SIG '' SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC02pLUvUxe8NtX
'' SIG '' B99ZYYE6JrbTGLNpw/37zCNv0g3M0xtWFsxQTb7DEvtc
'' SIG '' 1sE0s8I5ybT7Ifoy12FsCgpebk++Cpcv0a0C5OHQ72mB
'' SIG '' nx8yxk2EJv3ie6jSIiw88cwrOTIv/hvsnk9v/YvHVPOF
'' SIG '' nX6CS1ISju4PYz22N0T6Tlu7X92P/uaF1wNSEZ7BlP81
'' SIG '' +4cy9hMgkaeaN6HyT6QyVEvgKBTl5yGG7dbDmpk0ISYw
'' SIG '' dQeYoGXoU7fQmVqUEma721ZWNNREkWGJ0LjUXzpO5YA6
'' SIG '' x/JSmzp119x2qCBTIMcZtxRVdXz7ygIiDqFLgfOw5lnF
'' SIG '' GqULgcoXAj5qxQuOv8G3AgMBAAGjggEbMIIBFzAdBgNV
'' SIG '' HQ4EFgQU4hOrS/LtsWC4ePGFoFH+cuexL6QwHwYDVR0j
'' SIG '' BBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
'' SIG '' BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
'' SIG '' XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
'' SIG '' BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
'' SIG '' Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
'' SIG '' BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEANn1t
'' SIG '' eSvGLi8kIMol9TQVjNzyS0cH9KM+7oZ4CN57h9YGxVjp
'' SIG '' +8vzF04f6TGgxtDCZgOfrs3w7JwrWZOCU7qRERwKnsdi
'' SIG '' Glqj1RbLLabqwPK0/3l++w7wM+pOG65c2vRQLuhLqGcZ
'' SIG '' BqvH38F9YQUiMGHOpZjAwAIofWkxKZkgbqQ25+KU0oRs
'' SIG '' 3A0aScn14zZVbW331VsR1Dm6AN+m0STLSTG8JYCCYKTr
'' SIG '' GeYhgmkvSJKyUMUPDp033x68/rhy65ND/lvGHxteoGhd
'' SIG '' 3g4U5CLUahVW5Oji562Pyic4YmbWbNsmEi8Jg8WucEHi
'' SIG '' OR6ELQux74lwJlIEMuk8DAOebGz4bqGCA3QwggJcAgEB
'' SIG '' MIHioYG4pIG1MIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQww
'' SIG '' CgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
'' SIG '' IEVTTjpGNkZGLTJEQTctQkI3NTElMCMGA1UEAxMcTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
'' SIG '' BSsOAwIaBQADFQCbwjXd+7ImKxoUMWVQLx1TlGmCb6CB
'' SIG '' wTCBvqSBuzCBuDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDehN3fMCIYDzIwMTgwNDIwMjE0
'' SIG '' NTAzWhgPMjAxODA0MjEyMTQ1MDNaMHQwOgYKKwYBBAGE
'' SIG '' WQoEATEsMCowCgIFAN6E3d8CAQAwBwIBAAICBPcwBwIB
'' SIG '' AAICGHQwCgIFAN6GL18CAQAwNgYKKwYBBAGEWQoEAjEo
'' SIG '' MCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgC
'' SIG '' AQACAwehIDANBgkqhkiG9w0BAQUFAAOCAQEADH+vv1Qq
'' SIG '' 6iha/lGOTP7VVQjLeBmaa+bnZJ1M8jJKzkIx+pVtbUYF
'' SIG '' GnF9CUlQd2vbAfRk56FYN6SKiRrxpD4d2HShTrgdjFDR
'' SIG '' 4RxOhw/y3bjZ8Uv/M3TpZE44CnpVYVDAKNrefDsgyLuh
'' SIG '' slAD/AnBgDjilrioJaibG8NcnXBGPWFPfwvTGcYdteLe
'' SIG '' ZRZFikIBcafzFBjRrVJpdNNhBenR7TusgYRwpHE8LyYX
'' SIG '' UmirCjcJgypFf4mMLsv4fCDifWeFnEjSLoll33cb15ht
'' SIG '' cpcOnHQwBw3R0F93H/25DNHiTTTaIZqZ3baGXRAJY9nw
'' SIG '' 5N+2YfVhKkx/MjAbQ0TuZSSw3DGCAvUwggLxAgEBMIGT
'' SIG '' MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAA
'' SIG '' pUgXcif5cL5jAAAAAAClMA0GCWCGSAFlAwQCAQUAoIIB
'' SIG '' MjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
'' SIG '' KoZIhvcNAQkEMSIEIBeHIEz12xjOCSUmxOKc3m9Pbh2I
'' SIG '' yklU9JWUbfczd4yZMIHiBgsqhkiG9w0BCRACDDGB0jCB
'' SIG '' zzCBzDCBsQQUm8I13fuyJisaFDFlUC8dU5Rpgm8wgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAKVIF3In+XC+YwAAAAAApTAWBBQ24UY5mEpsNhKi
'' SIG '' 3u1YNzp73mJvGzANBgkqhkiG9w0BAQsFAASCAQBu5vRy
'' SIG '' YPp2TuQc5plCcVfjpnzzGdVlHeTt9JEH9TOYMsrZ60dQ
'' SIG '' ScEevXry1Ofvb5L2zTDoARW2HFWbrBiTzYPXXEjkJ2Q5
'' SIG '' K0f36GDbq5XOaXKRns+wtHw3xVQ4rEnmkDd36QhEzNoJ
'' SIG '' GDC8s/0E6tNu/Av9RHrwVjha8F0mKKxmzVbn80ltcq7g
'' SIG '' XSu7jvRd8MJhWK2xHe2KOeTILftBoD9rYPZo+7YyjRKZ
'' SIG '' UGYCNffPAUMGflBQ1Lrr0S7C6w3+TwrlftiJC2gesrA5
'' SIG '' 3rHa6jLEPla0bXsSBF9VlXoGUvzM87z9H7l8T2dcq+FA
'' SIG '' n/NprVibi9BbkvBL2AWpk15vsay/
'' SIG '' End signature block
