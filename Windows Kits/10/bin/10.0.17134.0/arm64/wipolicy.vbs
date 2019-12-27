' Windows Installer utility to manage installer policy settings
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the installer policy keys
' Policy can be configured by an administrator using the NT Group Policy Editor
'
Option Explicit

Dim policies(21, 4)
policies(1, 0)="LM" : policies(1, 1)="HKLM" : policies(1, 2)="Logging"              : policies(1, 3)="REG_SZ"    : policies(1, 4) = "Logging modes if not supplied by install, set of iwearucmpv"
policies(2, 0)="DO" : policies(2, 1)="HKLM" : policies(2, 2)="Debug"                : policies(2, 3)="REG_DWORD" : policies(2, 4) = "OutputDebugString: 1=debug output, 2=verbose debug output, 7=include command line"
policies(3, 0)="DI" : policies(3, 1)="HKLM" : policies(3, 2)="DisableMsi"           : policies(3, 3)="REG_DWORD" : policies(3, 4) = "1=Disable non-managed installs, 2=disable all installs"
policies(4, 0)="WT" : policies(4, 1)="HKLM" : policies(4, 2)="Timeout"              : policies(4, 3)="REG_DWORD" : policies(4, 4) = "Wait timeout in seconds in case of no activity"
policies(5, 0)="DB" : policies(5, 1)="HKLM" : policies(5, 2)="DisableBrowse"        : policies(5, 3)="REG_DWORD" : policies(5, 4) = "Disable user browsing of source locations if 1"
policies(6, 0)="AB" : policies(6, 1)="HKLM" : policies(6, 2)="AllowLockdownBrowse"  : policies(6, 3)="REG_DWORD" : policies(6, 4) = "Allow non-admin users to browse to new sources for managed applications if 1 - use is not recommended"
policies(7, 0)="AM" : policies(7, 1)="HKLM" : policies(7, 2)="AllowLockdownMedia"   : policies(7, 3)="REG_DWORD" : policies(7, 4) = "Allow non-admin users to browse to new media sources for managed applications if 1 - use is not recommended"
policies(8, 0)="AP" : policies(8, 1)="HKLM" : policies(8, 2)="AllowLockdownPatch"   : policies(8, 3)="REG_DWORD" : policies(8, 4) = "Allow non-admin users to apply small and minor update patches to managed applications if 1 - use is not recommended"
policies(9, 0)="DU" : policies(9, 1)="HKLM" : policies(9, 2)="DisableUserInstalls"  : policies(9, 3)="REG_DWORD" : policies(9, 4) = "Disable per-user installs if 1 - available on Windows Installer version 2.0 and later"
policies(10, 0)="DP" : policies(10, 1)="HKLM" : policies(10, 2)="DisablePatch"         : policies(10, 3)="REG_DWORD" : policies(10, 4) = "Disable patch application to all products if 1"
policies(11, 0)="UC" : policies(11, 1)="HKLM" : policies(11, 2)="EnableUserControl"    : policies(11, 3)="REG_DWORD" : policies(11, 4) = "All public properties sent to install service if 1"
policies(12, 0)="ER" : policies(12, 1)="HKLM" : policies(12, 2)="EnableAdminTSRemote"  : policies(12, 3)="REG_DWORD" : policies(12, 4) = "Allow admins to perform installs from terminal server client sessions if 1"
policies(13, 0)="LS" : policies(13, 1)="HKLM" : policies(13, 2)="LimitSystemRestoreCheckpointing" : policies(13, 3)="REG_DWORD" : policies(13, 4) = "Turn off creation of system restore check points on Windows XP if 1 - available on Windows Installer version 2.0 and later"
policies(14, 0)="SS" : policies(14, 1)="HKLM" : policies(14, 2)="SafeForScripting"     : policies(14, 3)="REG_DWORD" : policies(14, 4) = "Do not prompt when scripts within a webpage access Installer automation interface if 1 - use is not recommended"
policies(15, 0)="TP" : policies(15,1)="HKLM" : policies(15, 2)="TransformsSecure"     : policies(15, 3)="REG_DWORD" : policies(15, 4) = "Pin tranforms in secure location if 1 (only admin and system have write privileges to cache location)"
policies(16, 0)="EM" : policies(16, 1)="HKLM" : policies(16, 2)="AlwaysInstallElevated": policies(16, 3)="REG_DWORD" : policies(16, 4) = "System privileges if 1 and HKCU value also set - dangerous policy as non-admin users can install with elevated privileges if enabled"
policies(17, 0)="EU" : policies(17, 1)="HKCU" : policies(17, 2)="AlwaysInstallElevated": policies(17, 3)="REG_DWORD" : policies(17, 4) = "System privileges if 1 and HKLM value also set - dangerous policy as non-admin users can install with elevated privileges if enabled"
policies(18,0)="DR" : policies(18,1)="HKCU" : policies(18,2)="DisableRollback"      : policies(18,3)="REG_DWORD" : policies(18,4) = "Disable rollback if 1 - use is not recommended"
policies(19,0)="TS" : policies(19,1)="HKCU" : policies(19,2)="TransformsAtSource"   : policies(19,3)="REG_DWORD" : policies(19,4) = "Locate transforms at root of source image if 1"
policies(20,0)="SO" : policies(20,1)="HKCU" : policies(20,2)="SearchOrder"          : policies(20,3)="REG_SZ"    : policies(20,4) = "Search order of source types, set of n,m,u (default=nmu)"
policies(21,0)="DM" : policies(21,1)="HKCU" : policies(21,2)="DisableMedia"          : policies(21,3)="REG_DWORD"    : policies(21,4) = "Browsing to media sources is disabled"

Dim argCount:argCount = Wscript.Arguments.Count
Dim message, iPolicy, policyKey, policyValue, WshShell, policyCode
On Error Resume Next

' If no arguments supplied, then list all current policy settings
If argCount = 0 Then
	Set WshShell = WScript.CreateObject("WScript.Shell") : CheckError
	For iPolicy = 0 To UBound(policies)
		policyValue = ReadPolicyValue(iPolicy)
		If Not IsEmpty(policyValue) Then 'policy key present, else skip display
			If Not IsEmpty(message) Then message = message & vbLf
			message = message & policies(iPolicy,0) & ": " & policies(iPolicy,2) & "(" & policies(iPolicy,1) & ") = " & policyValue
		End If
	Next
	If IsEmpty(message) Then message = "No installer policies set"
	Wscript.Echo message
	Wscript.Quit 0
End If

' Check for ?, and show help message if found
policyCode = UCase(Wscript.Arguments(0))
If InStr(1, policyCode, "?", vbTextCompare) <> 0 Then
	message = "Windows Installer utility to manage installer policy settings" &_
		vbLf & " If no arguments are supplied, current policy settings in list will be reported" &_
		vbLf & " The 1st argument specifies the policy to set, using a code from the list below" &_
		vbLf & " The 2nd argument specifies the new policy setting, use """" to remove the policy" &_
		vbLf & " If the 2nd argument is not supplied, the current policy value will be reported"
	For iPolicy = 0 To UBound(policies)
		message = message & vbLf & policies(iPolicy,0) & ": " & policies(iPolicy,2) & "(" & policies(iPolicy,1) & ")  " & policies(iPolicy,4) & vbLf
	Next
	message = message & vblf & vblf & "Copyright (C) Microsoft Corporation.  All rights reserved."

	Wscript.Echo message
	Wscript.Quit 1
End If

' Policy code supplied, look up in array
For iPolicy = 0 To UBound(policies)
	If policies(iPolicy, 0) = policyCode Then Exit For
Next
If iPolicy > UBound(policies) Then Wscript.Echo "Unknown policy code: " & policyCode : Wscript.Quit 2
Set WshShell = WScript.CreateObject("WScript.Shell") : CheckError

' If no value supplied, then simply report current value
policyValue = ReadPolicyValue(iPolicy)
If IsEmpty(policyValue) Then policyValue = "Not present"
message = policies(iPolicy,0) & ": " & policies(iPolicy,2) & "(" & policies(iPolicy,1) & ") = " & policyValue
If argCount > 1 Then ' Value supplied, set policy
	policyValue = WritePolicyValue(iPolicy, Wscript.Arguments(1))
	If IsEmpty(policyValue) Then policyValue = "Not present"
	message = message & " --> " & policyValue
End If
Wscript.Echo message

Function ReadPolicyValue(iPolicy)
	On Error Resume Next
	Dim policyKey:policyKey = policies(iPolicy,1) & "\Software\Policies\Microsoft\Windows\Installer\" & policies(iPolicy,2)
	ReadPolicyValue = WshShell.RegRead(policyKey)
End Function

Function WritePolicyValue(iPolicy, policyValue)
	On Error Resume Next
	Dim policyKey:policyKey = policies(iPolicy,1) & "\Software\Policies\Microsoft\Windows\Installer\" & policies(iPolicy,2)
	If Len(policyValue) Then
		WshShell.RegWrite policyKey, policyValue, policies(iPolicy,3) : CheckError
		WritePolicyValue = policyValue
	ElseIf Not IsEmpty(ReadPolicyValue(iPolicy)) Then
		WshShell.RegDelete policyKey : CheckError
	End If
End Function

Sub CheckError
	Dim message, errRec
	If Err = 0 Then Exit Sub
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbLf & errRec.FormatText
	End If
	Wscript.Echo message
	Wscript.Quit 2
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIiOgYJKoZIhvcNAQcCoIIiKzCCIicCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' /P2vh2Oob6dK4LJgJX9q0NCUL4Tr2otbVtqd2lYQZG6g
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
'' SIG '' IBu+HHdVsB4YvaPdNhQbqqKDiMS+SoonMp2YYFv3MDmr
'' SIG '' MDwGCisGAQQBgjcKAxwxLgwsUFYvMXA1bEJMSDBFMmZJ
'' SIG '' cDVTdUtwZGwxZ0NtSzBGR005R1g5OVFMSVhzdz0wWgYK
'' SIG '' KwYBBAGCNwIBDDFMMEqgJIAiAE0AaQBjAHIAbwBzAG8A
'' SIG '' ZgB0ACAAVwBpAG4AZABvAHcAc6EigCBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vd2luZG93czANBgkqhkiG9w0B
'' SIG '' AQEFAASCAQAlyz4EyXjTbmVe+dRHyrpw+vEVaTO3PAhA
'' SIG '' 3kK7yA7haH0UA83UDJs9ue44izkybmzxHWK7jlzspXLe
'' SIG '' mI3uCkIeft4Z0IRbIzA21A5wXIiZm+qgXjreyGo+0RO+
'' SIG '' WWL1giJJQyDbdzGSjncOj65HVGvhqaV9mFGvIyz3lkCY
'' SIG '' R71JhbAiSjPZJ2EZ9fsgmhypbgBBxklYKhbw+WFTCU9p
'' SIG '' 6hamwoc5fSeW3gzlsDMKQ7Lq8wMilqT1dxSgavGvCzkl
'' SIG '' KjzCYz2hEYl16eIEAnVPtAoLVMbjgAHlekINO76SIjgH
'' SIG '' EtAcTb4HAAntb63Y1Ts4ZOSkmyWmeZQeRqGzG9C2p+Q8
'' SIG '' oYITRjCCE0IGCisGAQQBgjcDAwExghMyMIITLgYJKoZI
'' SIG '' hvcNAQcCoIITHzCCExsCAQMxDzANBglghkgBZQMEAgEF
'' SIG '' ADCCATwGCyqGSIb3DQEJEAEEoIIBKwSCAScwggEjAgEB
'' SIG '' BgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIMfB
'' SIG '' DfvhyDC3UBxXHyQFdWFqDxmAK3fnrPSVt/+4rOGkAgZa
'' SIG '' spzkmskYEzIwMTgwNDIxMDIzMjUzLjA2NlowBwIBAYAC
'' SIG '' AfSggbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDDAK
'' SIG '' BgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
'' SIG '' RVNOOjU3QzgtMkQxNS0xQzhCMSUwIwYDVQQDExxNaWNy
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
'' SIG '' BNkwggPBoAMCAQICEzMAAACqt6mI/+pXwwoAAAAAAKow
'' SIG '' DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' UENBIDIwMTAwHhcNMTYwOTA3MTc1NjUzWhcNMTgwOTA3
'' SIG '' MTc1NjUzWjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBF
'' SIG '' U046NTdDOC0yRDE1LTFDOEIxJTAjBgNVBAMTHE1pY3Jv
'' SIG '' c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
'' SIG '' SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCe2H97V3j6Bfqj
'' SIG '' mreQr5q51bZ0dpHLuM67Ks4rKe9ftGt1mHUogK2Yj7mq
'' SIG '' 8J3StptHZJjGpVmqkXj5Hot59yR0Ruok/mkErr7rf1NT
'' SIG '' E1nVD/z7zd32B0GbGzc32Vx2md2ux8Pb061owlCcdA5E
'' SIG '' dy4unW/BHe8sxzt0rtuXLY+BxUcFQMBKN0iTvAOaS/CN
'' SIG '' BMtDcPvoWLGdrFDnubWE8cebB+z3mmnbr0h/rFkxhmIW
'' SIG '' cJVe8cvMOkfz6j8CjBC7vSOMqQNzTw64DFzxL6p/+mSb
'' SIG '' jC6YFMBGzyZPPAYjxk8it5IPGgIZ/JwpzYTega/w/a2Y
'' SIG '' rKWIg4aVVIa0m3FAxi83AgMBAAGjggEbMIIBFzAdBgNV
'' SIG '' HQ4EFgQUCLhyHRUk9ZMC4Z/SHEzTq8xZybAwHwYDVR0j
'' SIG '' BBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
'' SIG '' BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
'' SIG '' XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
'' SIG '' BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
'' SIG '' Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
'' SIG '' BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEAYI8O
'' SIG '' 7gfOGuF9n3nGeA6dzkykAZ1qZ0eXERuKcsrkwXznLeOP
'' SIG '' kWe86HR6P8rpRiQAP6HO8H5P0vQaffR2OB0UNh2l2Ylv
'' SIG '' ysVTFO8TLCACldEKecXS7m08P5FG6blS3t9c4pykTVFq
'' SIG '' HcLpk01GchYm+YT/k3fd6AM9VPzCBKBfj4e9VXSa6WSs
'' SIG '' sOQaylw7IB8LVVgIsMPLp7xZLE1Cke1bszAukqeTjk6A
'' SIG '' DK6peTHsUpF8lRCvf8HOI9sPmcxqw8T0LB91ZIIsoNgO
'' SIG '' B/eaDmWoXJWBnH5Y7nnzkSGt280sv7WIcv4GG51fdg92
'' SIG '' MoiuUjxtOS7MBk4kSS0vqWYA1vxoJqGCA3QwggJcAgEB
'' SIG '' MIHioYG4pIG1MIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQww
'' SIG '' CgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
'' SIG '' IEVTTjo1N0M4LTJEMTUtMUM4QjElMCMGA1UEAxMcTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
'' SIG '' BSsOAwIaBQADFQCcnMVrmMynwa1HIOzTRPzObdDqA6CB
'' SIG '' wTCBvqSBuzCBuDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDehN3DMCIYDzIwMTgwNDIwMjE0
'' SIG '' NDM1WhgPMjAxODA0MjEyMTQ0MzVaMHQwOgYKKwYBBAGE
'' SIG '' WQoEATEsMCowCgIFAN6E3cMCAQAwBwIBAAICBcowBwIB
'' SIG '' AAICGUgwCgIFAN6GL0MCAQAwNgYKKwYBBAGEWQoEAjEo
'' SIG '' MCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgC
'' SIG '' AQACAx6EgDANBgkqhkiG9w0BAQUFAAOCAQEAmZ8OVs3Q
'' SIG '' snG18t5iuXs4XqyVAtlVSUi0y3KJ66otj7vPaO6WwI1F
'' SIG '' 2o92YD3qAV6SGfLF+iJ61dFSjEXHn+ZjY6HOBx+Bp/Lx
'' SIG '' hXvQI0JjIvBYFRGTCo/A4pFFQfKR3MPgZheurVcML//L
'' SIG '' vQ2IU2cUCrLEvUwOsDxvJHNUlD27/bc+64IuhaTfOAXN
'' SIG '' M3zA1RXY6Kg24i4HZ/l79na+vQd1AETe+NqnPpe7tk8G
'' SIG '' nfYkmsC4b94k1vDOmZ9PnhWXEgorYWpYpTD+QWEukcVe
'' SIG '' Fsq3Elz3Fea679oBs8GQuNbsyIL9uUdLK1mw+iyd9ApY
'' SIG '' 8F7CojvaLNE54SbY7bRTFcaGejGCAvUwggLxAgEBMIGT
'' SIG '' MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAA
'' SIG '' qrepiP/qV8MKAAAAAACqMA0GCWCGSAFlAwQCAQUAoIIB
'' SIG '' MjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
'' SIG '' KoZIhvcNAQkEMSIEIOc7AXS1vdMN1IH6iTrDEzYYy8Po
'' SIG '' WGqfvv2SZIx1MX3IMIHiBgsqhkiG9w0BCRACDDGB0jCB
'' SIG '' zzCBzDCBsQQUnJzFa5jMp8GtRyDs00T8zm3Q6gMwgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAKq3qYj/6lfDCgAAAAAAqjAWBBQhtKAIhLcRgCTs
'' SIG '' HEx3Obri4tyyWTANBgkqhkiG9w0BAQsFAASCAQBrj41+
'' SIG '' iImzj4WnUOu9r+njL5OhsbGXDo0O9RcGGbV6LmKTuFpW
'' SIG '' PMd/dF8ly/+BXf2ocsx4dn1JDq7D/F4RGXcujk167oVm
'' SIG '' NGm4YICCXqbvGFQ9nmW1HmeOkVAbhm3wEpnQmug3KTDr
'' SIG '' w/lttGHqx7sbIK7TYny/fEhdeUxbdroZQPmv0jh5qNol
'' SIG '' xDZGKEXQDzSdAKUF7WaLzqs9JazWcIh7jVwW6SUXO/ST
'' SIG '' sAedMCjuKSeMVGbcSp9kHT0N2f+F4dJICAKjDrjlVS3Y
'' SIG '' ENZkjDM9TZuQBRxyVsKusFrT5qDgtGSHsxLoJA4g+qvJ
'' SIG '' e/BgbkpKCqepn9Q29CHaAZyx61X3
'' SIG '' End signature block
