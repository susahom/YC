' Windows Installer utility to list registered products and product info
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of the product enumeration and ProductInfo methods and underlying APIs
'
Option Explicit

Const msiInstallStateNotUsed      = -7
Const msiInstallStateBadConfig    = -6
Const msiInstallStateIncomplete   = -5
Const msiInstallStateSourceAbsent = -4
Const msiInstallStateInvalidArg   = -2
Const msiInstallStateUnknown      = -1
Const msiInstallStateBroken       =  0
Const msiInstallStateAdvertised   =  1
Const msiInstallStateRemoved      =  1
Const msiInstallStateAbsent       =  2
Const msiInstallStateLocal        =  3
Const msiInstallStateSource       =  4
Const msiInstallStateDefault      =  5

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' If no arguments supplied, then list all installed or advertised products
Dim argCount:argCount = Wscript.Arguments.Count
If (argCount = 0) Then
	Dim product, products, info, productList, version
	On Error Resume Next
	Set products = installer.Products : CheckError
	For Each product In products
		version = DecodeVersion(installer.ProductInfo(product, "Version")) : CheckError
		info = product & " = " & installer.ProductInfo(product, "ProductName") & " " & version : CheckError
		If productList <> Empty Then productList = productList & vbNewLine & info Else productList = info
	Next
	If productList = Empty Then productList = "No products installed or advertised"
	Wscript.Echo productList
	Set products = Nothing
	Wscript.Quit 0
End If

' Check for ?, and show help message if found
Dim productName:productName = Wscript.Arguments(0)
If InStr(1, productName, "?", vbTextCompare) > 0 Then
	Wscript.Echo "Windows Installer utility to list registered products and product information" &_
		vbNewLine & " Lists all installed and advertised products if no arguments are specified" &_
		vbNewLine & " Else 1st argument is a product name (case-insensitive) or product ID (GUID)" &_
		vbNewLine & " If 2nd argument is missing or contains 'p', then product properties are listed" &_
		vbNewLine & " If 2nd argument contains 'f', features, parents, & installed states are listed" &_
		vbNewLine & " If 2nd argument contains 'c', installed components for that product are listed" &_
		vbNewLine & " If 2nd argument contains 'd', HKLM ""SharedDlls"" count for key files are listed" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' If Product name supplied, need to search for product code
Dim productCode, property, value, message
If Left(productName, 1) = "{" And Right(productName, 1) = "}" Then
	If installer.ProductState(productName) <> msiInstallStateUnknown Then productCode = UCase(productName)
Else
	For Each productCode In installer.Products : CheckError
		If LCase(installer.ProductInfo(productCode, "ProductName")) = LCase(productName) Then Exit For
	Next
End If
If IsEmpty(productCode) Then Wscript.Echo "Product is not registered: " & productName : Wscript.Quit 2

' Check option argument for type of information to display, default is properties
Dim optionFlag : If argcount > 1 Then optionFlag = LCase(Wscript.Arguments(1)) Else optionFlag = "p"
If InStr(1, optionFlag, "*", vbTextCompare) > 0 Then optionFlag = "pfcd"

If InStr(1, optionFlag, "p", vbTextCompare) > 0 Then
	message = "ProductCode = " & productCode
	For Each property In Array(_
			"Language",_
			"ProductName",_
			"PackageCode",_
			"Transforms",_
			"AssignmentType",_
			"PackageName",_
			"InstalledProductName",_
			"VersionString",_
			"RegCompany",_
			"RegOwner",_
			"ProductID",_
			"ProductIcon",_
			"InstallLocation",_
			"InstallSource",_
			"InstallDate",_
			"Publisher",_
			"LocalPackage",_
			"HelpLink",_
			"HelpTelephone",_
			"URLInfoAbout",_
			"URLUpdateInfo") : CheckError
		value = installer.ProductInfo(productCode, property) ': CheckError
		If Err <> 0 Then Err.Clear : value = Empty
		If (property = "Version") Then value = DecodeVersion(value)
		If value <> Empty Then message = message & vbNewLine & property & " = " & value
	Next
	Wscript.Echo message
End If

If InStr(1, optionFlag, "f", vbTextCompare) > 0 Then
	Dim feature, features, parent, state, featureInfo
	Set features = installer.Features(productCode)
	message = "---Features in product " & productCode & "---"
	For Each feature In features
		parent = installer.FeatureParent(productCode, feature) : CheckError
		If Len(parent) Then parent = " {" & parent & "}"
		state = installer.FeatureState(productCode, feature)
		Select Case(state)
			Case msiInstallStateBadConfig:    state = "Corrupt"
			Case msiInstallStateIncomplete:   state = "InProgress"
			Case msiInstallStateSourceAbsent: state = "SourceAbsent"
			Case msiInstallStateBroken:       state = "Broken"
			Case msiInstallStateAdvertised:   state = "Advertised"
			Case msiInstallStateAbsent:       state = "Uninstalled"
			Case msiInstallStateLocal:        state = "Local"
			Case msiInstallStateSource:       state = "Source"
			Case msiInstallStateDefault:      state = "Default"
			Case Else:                        state = "Unknown"
		End Select
		message = message & vbNewLine & feature & parent & " = " & state
	Next
	Set features = Nothing
	Wscript.Echo message
End If 

If InStr(1, optionFlag, "c", vbTextCompare) > 0 Then
	Dim component, components, client, clients, path
	Set components = installer.Components : CheckError
	message = "---Components in product " & productCode & "---"
	For Each component In components
		Set clients = installer.ComponentClients(component) : CheckError
		For Each client In Clients
			If client = productCode Then
				path = installer.ComponentPath(productCode, component) : CheckError
				message = message & vbNewLine & component & " = " & path
				Exit For
			End If
		Next
		Set clients = Nothing
	Next
	Set components = Nothing
	Wscript.Echo message
End If

If InStr(1, optionFlag, "d", vbTextCompare) > 0 Then
	Set components = installer.Components : CheckError
	message = "---Shared DLL counts for key files of " & productCode & "---"
	For Each component In components
		Set clients = installer.ComponentClients(component) : CheckError
		For Each client In Clients
			If client = productCode Then
				path = installer.ComponentPath(productCode, component) : CheckError
				If Len(path) = 0 Then path = "0"
				If AscW(path) >= 65 Then  ' ignore registry key paths
					value = installer.RegistryValue(2, "SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDlls", path)
					If Err <> 0 Then value = 0 : Err.Clear
					message = message & vbNewLine & value & " = " & path
				End If
				Exit For
			End If
		Next
		Set clients = Nothing
	Next
	Set components = Nothing
	Wscript.Echo message
End If

Function DecodeVersion(version)
	version = CLng(version)
	DecodeVersion = version\65536\256 & "." & (version\65535 MOD 256) & "." & (version Mod 65536)
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
'' SIG '' +TYCWFk7lUqBMQntWKZoHVk2tbD50YMJse1NdDP1q+Gg
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
'' SIG '' IFd/Cq5pLKzWZkXtjyEYQfoznVvRVlVqMlSYutQlf3ww
'' SIG '' MDwGCisGAQQBgjcKAxwxLgwsMFBENkNWaU5ZS1RYR3Y0
'' SIG '' TnYyc0hzQ2d2a3dJOGRQdHN1VGRsejY0emY4bz0wWgYK
'' SIG '' KwYBBAGCNwIBDDFMMEqgJIAiAE0AaQBjAHIAbwBzAG8A
'' SIG '' ZgB0ACAAVwBpAG4AZABvAHcAc6EigCBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vd2luZG93czANBgkqhkiG9w0B
'' SIG '' AQEFAASCAQBL3yPVbgUL1ugdV778a06YpQdzD8HCL6Ni
'' SIG '' J3ozgLbLFkxfm+SwOm8KvTugZ+VchmEqUwr9rctc9aqz
'' SIG '' ZHklO3SYYbVwEyA/WAKvTb+G8zwozfB3pyaYsgZN5BIr
'' SIG '' Y0oxXNkqanNHHtdzVCuPfFcM7hz229nLlJdBv8FD4aD2
'' SIG '' o6sW/TnNUhfUvg0/6LHVrNPYdTeoF79ikF2sLCqTau/A
'' SIG '' tyIw0/9SY1SUS4u+QkE+xIxSKBKsFeHmzJAwzJOIPDk5
'' SIG '' q9WeFlXWLwXIv2mbanatXK1IA2RLRIVekXVXe/jKTDFX
'' SIG '' 9KCJ2HG9r5GMIxHNMhcFC1HLAuRBv5UuHwvkhXGdOf9c
'' SIG '' oYITRjCCE0IGCisGAQQBgjcDAwExghMyMIITLgYJKoZI
'' SIG '' hvcNAQcCoIITHzCCExsCAQMxDzANBglghkgBZQMEAgEF
'' SIG '' ADCCATwGCyqGSIb3DQEJEAEEoIIBKwSCAScwggEjAgEB
'' SIG '' BgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIOtE
'' SIG '' AAejjqQL3tCJPJ1DP7KiJdiIl8bxWD83wa1oVQRzAgZa
'' SIG '' srrtln8YEzIwMTgwNDIxMDIzMDE4LjU1NlowBwIBAYAC
'' SIG '' AfSggbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDDAK
'' SIG '' BgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhlciBEU0Ug
'' SIG '' RVNOOkQyMzYtMzdEQS05NzYxMSUwIwYDVQQDExxNaWNy
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
'' SIG '' BNkwggPBoAMCAQICEzMAAACuDtZOlonbAPUAAAAAAK4w
'' SIG '' DQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' UENBIDIwMTAwHhcNMTYwOTA3MTc1NjU1WhcNMTgwOTA3
'' SIG '' MTc1NjU1WjCBsjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBF
'' SIG '' U046RDIzNi0zN0RBLTk3NjExJTAjBgNVBAMTHE1pY3Jv
'' SIG '' c29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggEiMA0GCSqG
'' SIG '' SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDeki/DpJVy9T4N
'' SIG '' ZmTD+uboIg90jE3Bnse2VLjxj059H/tGML58y3ue28Rn
'' SIG '' WJIv+lSABp+jPp8XIf2p//DKYb0o/QSOJ8kGUoFYesNT
'' SIG '' Ptqyf/qohLW1rcLijiFoMLABH/GDnDbgRZHxVFxHUG+K
'' SIG '' NwffdC0BYC3Vfq3+2uOO8czRlj10gRHU2BK8moSz53Vo
'' SIG '' 2ZwF3TMZyVgvAvlg5sarNgRwAYwbwWW5wEqpeODFX1VA
'' SIG '' /nAeLkjirCmg875M1XiEyPtrXDAFLng5/y5MlAcUMYJ6
'' SIG '' dHuSBDqLLXipjjYakQopB3H1+9s8iyDoBM07JqP9u55V
'' SIG '' P5a2n/IZFNNwJHeCTSvLAgMBAAGjggEbMIIBFzAdBgNV
'' SIG '' HQ4EFgQUfo/lNDREi/J5QLjGoNGcQx4hJbEwHwYDVR0j
'' SIG '' BBgwFoAU1WM6XIoxkPNDe3xGG8UzaFqFbVUwVgYDVR0f
'' SIG '' BE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jcmwvcHJvZHVjdHMvTWljVGltU3RhUENB
'' SIG '' XzIwMTAtMDctMDEuY3JsMFoGCCsGAQUFBwEBBE4wTDBK
'' SIG '' BggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraS9jZXJ0cy9NaWNUaW1TdGFQQ0FfMjAxMC0w
'' SIG '' Ny0wMS5jcnQwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAK
'' SIG '' BggrBgEFBQcDCDANBgkqhkiG9w0BAQsFAAOCAQEAPVlN
'' SIG '' ePD0XDQI0bVBYANTDPmMpk3lIh6gPIilg0hKQpZNMADL
'' SIG '' bmj+kav0GZcxtWnwrBoR+fpBsuaowWgwxExCHBo6mix7
'' SIG '' RLeJvNyNYlCk2JQT/Ga80SRVzOAL5Nxls1PqvDbgFghD
'' SIG '' cRTmpZMvADfqwdu5R6FNyIgecYNoyb7A4AqCLfV1Wx3P
'' SIG '' rPyaXbatskk5mT8NqWLYLshBzt2Ca0bhJJZf6qQwg6r2
'' SIG '' gz1pG15ue6nDq/mjYpTmCDhYz46b8rxrIn0sQxnFTmtn
'' SIG '' tvz2Z1jCGs99n1rr2ZFrGXOJS4Bhn1tyKEFwGJjrfQ4G
'' SIG '' b2pyA9aKRwUyK9BHLKWC5ZLD0hAaIKGCA3QwggJcAgEB
'' SIG '' MIHioYG4pIG1MIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQww
'' SIG '' CgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgRFNF
'' SIG '' IEVTTjpEMjM2LTM3REEtOTc2MTElMCMGA1UEAxMcTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
'' SIG '' BSsOAwIaBQADFQDHwb0we6UYnmReZ3Q2+rvjmbxo+6CB
'' SIG '' wTCBvqSBuzCBuDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoG
'' SIG '' A1UECxMDQU9DMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDehNxwMCIYDzIwMTgwNDIwMjEz
'' SIG '' ODU2WhgPMjAxODA0MjEyMTM4NTZaMHQwOgYKKwYBBAGE
'' SIG '' WQoEATEsMCowCgIFAN6E3HACAQAwBwIBAAICAIIwBwIB
'' SIG '' AAICGikwCgIFAN6GLfACAQAwNgYKKwYBBAGEWQoEAjEo
'' SIG '' MCYwDAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgC
'' SIG '' AQACAx6EgDANBgkqhkiG9w0BAQUFAAOCAQEARE56EvbU
'' SIG '' z/TYIoMMMyXYpa3bu0KSWtO2i2DoJHyzd3vWCY+iiFBV
'' SIG '' xohyjreQNhquW51fBCDGEeqBGm2nwZw6R35C0fTNIdH5
'' SIG '' 9F0tphlGIvFbL0oOObzFlz7eioEj0wBYQcUpzoZBvRGF
'' SIG '' eDC6Wk7nhC+e//FUpeiplfk1Gb+OZIGSc3ZOtBn6sHK8
'' SIG '' sBFU9kfo+0fSQ+v6xzOhtUxoVk76kLfjQay8KgnWpFFy
'' SIG '' krbykkpvKJWepqFqxDVJ3PmbELrWyjZMkawVMOQe3EIF
'' SIG '' ZKiay9KSY25Q5UVuW9RBGJudONL0CbfwLjAoHrV8QCiM
'' SIG '' BYRSBgJzp/jKzppJqXDvEpe7eDGCAvUwggLxAgEBMIGT
'' SIG '' MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
'' SIG '' dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
'' SIG '' aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAA
'' SIG '' rg7WTpaJ2wD1AAAAAACuMA0GCWCGSAFlAwQCAQUAoIIB
'' SIG '' MjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJ
'' SIG '' KoZIhvcNAQkEMSIEIMwzKaN5wT4oslroRTTUrk19N5b/
'' SIG '' MA/q+/Z8Kg77TZOOMIHiBgsqhkiG9w0BCRACDDGB0jCB
'' SIG '' zzCBzDCBsQQUx8G9MHulGJ5kXmd0Nvq745m8aPswgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAK4O1k6WidsA9QAAAAAArjAWBBRMQ9kB2S/staNs
'' SIG '' 5EbPJiF4nZATejANBgkqhkiG9w0BAQsFAASCAQBFoKQU
'' SIG '' F9cFfsxxoMcSnfvS+4hr9OfnAwS8KVJRpGT2m81DbqH8
'' SIG '' pjDmtRjMgPHW3tpIzWjSs72yeoamj1pJn3520kf1Xi4v
'' SIG '' ZJ8Kszq4mYMw7ubeAYjXwHAGiRBsosrIBKzHZWGtsAax
'' SIG '' aerxobOmcZkCRY9J8OcLr9+K8X68JQbhL2MQjM3jc2i1
'' SIG '' ol3Gg9NqdhX7mIzbEly6V6taYpp57WR/aFFydK9OFgGJ
'' SIG '' HKhfqXoe5rlJ2qwEAHWTMYlukWYRnEEpAYtjBDXdLcYM
'' SIG '' f/yGSScJOxi59+iyP74M0ovDmqhXfVerpWKfczbxRLDH
'' SIG '' OWQUqpHWS6ki4hq2WpWpR9z4rqiB
'' SIG '' End signature block
