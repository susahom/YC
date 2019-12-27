' Windows Installer utility to list feature composition in an MSI database
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the use of adding temporary columns to a read-only database
'
Option Explicit
Public isGUI, installer, database, message, featureParam, nextSequence  'global variables accessed across functions

Const msiOpenDatabaseModeReadOnly = 0
Const msiDbNullInteger            = &h80000000
Const msiViewModifyUpdate         = 2

' Check if run from GUI script host, in order to modify display
If UCase(Mid(Wscript.FullName, Len(Wscript.Path) + 2, 1)) = "W" Then isGUI = True

' Show help if no arguments or if argument contains ?
Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If argCount = 0 Then
	Wscript.Echo "Windows Installer utility to list feature composition in an installer database." &_
		vbLf & " The 1st argument is the path to an install database, relative or complete path" &_
		vbLf & " The 2nd argument is the name of the feature (the primary key of Feature table)" &_
		vbLf & " If the 2nd argument is not present, all feature names will be listed as a tree" &_
		vbLf & " If the 2nd argument is ""*"" then the composition of all features will be listed" &_
		vbLf & " Large databases or features are better displayed by using CScript than WScript" &_
		vbLf & " Note: The name of the feature, if provided,  is case-sensitive" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Connect to Windows Installer object
On Error Resume Next
Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Open database
Dim databasePath:databasePath = Wscript.Arguments(0)
Set database = installer.OpenDatabase(databasePath, msiOpenDatabaseModeReadOnly) : CheckError
REM Set database = installer.OpenDatabase(databasePath, 1) : CheckError

If argCount = 1 Then  'If no feature specified, then simply list features
	ListFeatures False
	ShowOutput "Features for " & databasePath, message
ElseIf Left(Wscript.Arguments(1), 1) = "*" Then 'List all features
	ListFeatures True
Else
	QueryFeature Wscript.Arguments(1) 
End If
Wscript.Quit 0

' List all table rows referencing a given feature
Function QueryFeature(feature)
	' Get feature info and format output header
	Dim view, record, header, parent
	Set view = database.OpenView("SELECT `Feature_Parent` FROM `Feature` WHERE `Feature` = ?") : CheckError
	Set featureParam = installer.CreateRecord(1)
	featureParam.StringData(1) = feature
	view.Execute featureParam : CheckError
	Set record = view.Fetch : CheckError
	Set view = Nothing
	If record Is Nothing Then Fail "Feature not in database: " & feature
	parent = record.StringData(1)
	header = "Feature: "& feature & "  Parent: " & parent

	' List of tables with foreign keys to Feature table - with subsets of columns to display
	DoQuery "FeatureComponents","Component_"                         '
	DoQuery "Condition",        "Level,Condition"                    '
	DoQuery "Billboard",        "Billboard,Action"                   'Ordering

	QueryFeature = ShowOutput(header, message)
	message = Empty
End Function

' Query used for sorting and corresponding record field indices
const irecParent   = 1  'put first in order to use as query parameter
const irecChild    = 2  'primary key of Feature table
const irecSequence = 3  'temporary column added for sorting
const sqlSort = "SELECT `Feature_Parent`,`Feature`,`Sequence` FROM `Feature`"

' Recursive function to resolve parent feature chain, return tree level (low order 8 bits of sequence number)
Function LinkParent(childView)
	Dim view, record, level
	On Error Resume Next
	Set record = childView.Fetch
	If record Is Nothing Then Exit Function  'return Empty if no record found
	If Not record.IsNull(irecSequence) Then LinkParent = (record.IntegerData(irecSequence) And 255) + 1 : Exit Function 'Already resolved
	If record.IsNull(irecParent) Or record.StringData(irecParent) = record.StringData(irecChild) Then 'Root node
		level = 0
	Else  'child node, need to get level from parent
		Set view = database.OpenView(sqlSort & " WHERE `Feature` = ?") : CheckError
		view.Execute record : CheckError '1st param is parent feature
		level = LinkParent(view)
		If IsEmpty(level) Then Fail "Feature parent does not exist: " & record.StringData(irecParent)
	End If
	record.IntegerData(irecSequence) = nextSequence + level
	nextSequence = nextSequence + 256
	childView.Modify msiViewModifyUpdate, record : CheckError
	LinkParent = level + 1
End Function

' List all features in database, sorted hierarchically
Sub ListFeatures(queryAll)
	Dim viewSchema, view, record, feature, level
	On Error Resume Next
	Set viewSchema = database.OpenView("ALTER TABLE Feature ADD Sequence LONG TEMPORARY") : CheckError
	viewSchema.Execute : CheckError  'Add ordering column, keep view open to hold temp columns
	Set view = database.OpenView(sqlSort) : CheckError
	view.Execute : CheckError
	nextSequence = 0
	While LinkParent(view) : Wend  'Loop to link rows hierachically
	Set view = database.OpenView("SELECT `Feature`,`Title`, `Sequence` FROM `Feature` ORDER BY Sequence") : CheckError
	view.Execute : CheckError
	Do
		Set record = view.Fetch : CheckError
		If record Is Nothing Then Exit Do
		feature = record.StringData(1)
		level = record.IntegerData(3) And 255
		If queryAll Then
			If QueryFeature(feature) = vbCancel Then Exit Sub
		Else
			If Not IsEmpty(message) Then message = message & vbLf
			message = message & Space(level * 2) & feature & "  (" & record.StringData(2) & ")"
		End If
	Loop
End Sub

' Perform a join to query table rows linked to a given feature, delimiting and qualifying names to prevent conflicts
Sub DoQuery(table, columns)
	Dim view, record, columnCount, column, output, header, delim, columnList, tableList, tableDelim, query, joinTable, primaryKey, foreignKey, columnDelim
	On Error Resume Next
	tableList  = Replace(table,   ",", "`,`")
	tableDelim = InStr(1, table, ",", vbTextCompare)
	If tableDelim Then  ' need a 3-table join
		joinTable = Right(table, Len(table)-tableDelim)
		table = Left(table, tableDelim-1)
		foreignKey = columns
		Set record = database.PrimaryKeys(joinTable)
		primaryKey = record.StringData(1)
		columnDelim = InStr(1, columns, ",", vbTextCompare)
		If columnDelim Then foreignKey = Left(columns, columnDelim - 1)
		query = " AND `" & foreignKey & "` = `" & primaryKey & "`"
	End If
	columnList = table & "`." & Replace(columns, ",", "`,`" & table & "`.`")
	query = "SELECT `" & columnList & "` FROM `" & tableList & "` WHERE `Feature_` = ?" & query
	If database.TablePersistent(table) <> 1 Then Exit Sub
	Set view = database.OpenView(query) : CheckError
	view.Execute featureParam : CheckError
	Do
		Set record = view.Fetch : CheckError
		If record Is Nothing Then Exit Do
		If IsEmpty(output) Then
			If Not IsEmpty(message) Then message = message & vbLf
			message = message & "----" & table & " Table----  (" & columns & ")" & vbLf
		End If
		output = Empty
		columnCount = record.FieldCount
		delim = "  "
		For column = 1 To columnCount
			If column = columnCount Then delim = vbLf
			output = output & record.StringData(column) & delim
		Next
		message = message & output
	Loop
End Sub

Sub CheckError
	Dim message, errRec
	If Err = 0 Then Exit Sub
	message = Err.Source & " " & Hex(Err) & ": " & Err.Description
	If Not installer Is Nothing Then
		Set errRec = installer.LastErrorRecord
		If Not errRec Is Nothing Then message = message & vbLf & errRec.FormatText
	End If
	Fail message
End Sub

Function ShowOutput(header, message)
	ShowOutput = vbOK
	If IsEmpty(message) Then Exit Function
	If isGUI Then
		ShowOutput = MsgBox(message, vbOKCancel, header)
	Else
		Wscript.Echo "> " & header
		Wscript.Echo message
	End If
End Function

Sub Fail(message)
	Wscript.Echo message
	Wscript.Quit 2
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIirwYJKoZIhvcNAQcCoIIioDCCIpwCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' o40u8w/79QYYEVTk+LHUW40T5s95rhdh/xj2PF/Wgf2g
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
'' SIG '' Bmrm1MbfI5qWdcUxghaGMIIWggIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgZi2jXnHmXUs+wBApyuT8W3+JK0Ql3la+1qnCnmPA
'' SIG '' E0QwPAYKKwYBBAGCNwoDHDEuDCxkOHZoSlBBZkNnVk43
'' SIG '' Lys0SkEvTWRGZzN4UVZDdndxRE9GYzhJMnlubzE4PTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAGBAQ3CMkuKuBiW2PLiYp5Zzq7VPtmvh
'' SIG '' PrCgOno3ww1olpajLGg6DPiX+BdwWg7DB5ts9C4/OTrf
'' SIG '' GYZiJeGR0Y9RqTPNjAp+7PQKLZL8csW0pMdk76E02xmf
'' SIG '' iRMWtxd8m/M8HfozfoAwOY/jhvx37iyxOrS+oniU7S2L
'' SIG '' jcDCg678agWPoQZu+xq/+DorO7nHKSOHqsxTgNnbmK0B
'' SIG '' OurhRjxvfdQPRiFUDyWata1QN4lpI0hfOlTFVP9afExj
'' SIG '' k0S3h+2TOTWKXMKLBPFDt4FeU9rRkqtRoBScJQrlWRCF
'' SIG '' HpwyM/hoDrRS5V0pStEzBejGVLGNkGSq5rIQPn9kvEK4
'' SIG '' sXKhghO5MIITtQYKKwYBBAGCNwMDATGCE6UwghOhBgkq
'' SIG '' hkiG9w0BBwKgghOSMIITjgIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBWAYLKoZIhvcNAQkQAQSgggFHBIIBQzCCAT8C
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' C8IlPUwc+9gzcjh3r7Fi9vpDsppGkXFyWspt4wnESqcC
'' SIG '' BlvOENczJRgTMjAxODEwMjMxNzQ5MjguODg3WjAHAgEB
'' SIG '' gAIB9KCB1KSB0TCBzjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEp
'' SIG '' MCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVl
'' SIG '' cnRvIFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
'' SIG '' OkIxQjctRjY3Ri1GRUMyMSUwIwYDVQQDExxNaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIPITCCBPUwggPd
'' SIG '' oAMCAQICEzMAAADSuONabcRbGncAAAAAANIwDQYJKoZI
'' SIG '' hvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQG
'' SIG '' A1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
'' SIG '' MTAwHhcNMTgwODIzMjAyNjM0WhcNMTkxMTIzMjAyNjM0
'' SIG '' WjCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMg
'' SIG '' TWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28x
'' SIG '' JjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkIxQjctRjY3
'' SIG '' Ri1GRUMyMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1T
'' SIG '' dGFtcCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOC
'' SIG '' AQ8AMIIBCgKCAQEAvqqUKB2JtJqhuuoEqM44x2sGz7/Z
'' SIG '' DCDO6485+Z0JMFC42zulbKxDf08QaoSkdFjSIZQZg2Cm
'' SIG '' fM+eUbYxSYyIZrGc6S9bv8X106QzZiwJVkZqTM7h+KWF
'' SIG '' Q+gEkpxJxO6A4bmjjcLdW2X7NuK7HaWyNMWTTDeMUh/0
'' SIG '' VQPXn6yyRZnRw5+Ed7YFB9ZpOkmPSzdpLhJOxabdLZVW
'' SIG '' FtfqVma2Oqh3ujxbHw+kJWkYDKApNAw2k2BUqpXbtTcN
'' SIG '' hiGGaGJ0Eu+KrOB8DfS1QM7P1tcyuDb0xrSm8Vp+UgBW
'' SIG '' dag0BlVxiqsZd3vKVrgjqzszCrByKw3TREqVdWcyvpKV
'' SIG '' ujiXRQIDAQABo4IBGzCCARcwHQYDVR0OBBYEFOysOHF1
'' SIG '' +pfJI/lScmVJ4D2id+DOMB8GA1UdIwQYMBaAFNVjOlyK
'' SIG '' MZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJoEeG
'' SIG '' RWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3Js
'' SIG '' L3Byb2R1Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAx
'' SIG '' LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKG
'' SIG '' Pmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2Vy
'' SIG '' dHMvTWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwG
'' SIG '' A1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
'' SIG '' DQYJKoZIhvcNAQELBQADggEBAEbPQylxHA69NndBer0V
'' SIG '' Z7CAAnIqJpIWmCi5+Wz5ZfgDI9CYP8ucH5lwlHktCege
'' SIG '' 91Z5CLMf2VbxKduJK2ycfWZU8hzjk2Hs+8ocuN2uR7cr
'' SIG '' Lge3lWJwoBm7Xy90vfFTjZ5Q6QwbgXqcvmckHINNOnnW
'' SIG '' /E5P9b9ZLXY9lmZzA2zqdkqtNP9OYbRBc2RnQovmSkX8
'' SIG '' JHv9O07w9VD1yII6X/7a2ekenCPxTdey8tooByT1HOmh
'' SIG '' YdDh0XfN5EpZcDupbql7G8VfqeYn8oUmx+1EBXBn9nmY
'' SIG '' L4s4hwmWWfhlMQAoRb4c9/KOX4FLnIiXd2qGdUW6S3lA
'' SIG '' uxaUo1RApPl82fswggZxMIIEWaADAgECAgphCYEqAAAA
'' SIG '' AAACMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBD
'' SIG '' ZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3
'' SIG '' MDEyMTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0B
'' SIG '' AQEFAAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwTl/X6
'' SIG '' f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AV
'' SIG '' UycEMR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4
'' SIG '' CLNC3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhgRvJYR4Yy
'' SIG '' hB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxG
'' SIG '' wScdJGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHR
'' SIG '' D5wGPmd/9WbAA5ZEfu/QS/1u5ZrKsajyeioKMfDaTgaR
'' SIG '' togINeh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJ
'' SIG '' RF1eFpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGC
'' SIG '' NxUBBAMCAQAwHQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvF
'' SIG '' M2hahW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBB
'' SIG '' MAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8G
'' SIG '' A1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYG
'' SIG '' A1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0Nl
'' SIG '' ckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQRO
'' SIG '' MEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIw
'' SIG '' MTAtMDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8G
'' SIG '' CSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDov
'' SIG '' L3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9k
'' SIG '' ZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUA
'' SIG '' ZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBt
'' SIG '' AGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aI
'' SIG '' UQ3ixuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkw
'' SIG '' s8LFZslq3/Xn8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOM
'' SIG '' zPRgEop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/G
'' SIG '' f/I3fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6
'' SIG '' AG9LMEQkIjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbl
'' SIG '' jjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFj
'' SIG '' nXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaG
'' SIG '' pL2eGq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2
'' SIG '' onGqBooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7cQnf
'' SIG '' XXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fe
'' SIG '' cn5ha293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kq
'' SIG '' VDmyW9rIDVWZeodzOwjmmC3qjeAzLhIp9cAvVCch98is
'' SIG '' TtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99j
'' SIG '' e/WZii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9
'' SIG '' zOZN+w2/XU/pnR4ZOC+8z1gFLu8NoFA12u8JJxzVs341
'' SIG '' Hgi62jbb01+P3nSISRKhggOvMIIClwIBATCB/qGB1KSB
'' SIG '' 0TCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMg
'' SIG '' TWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28x
'' SIG '' JjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkIxQjctRjY3
'' SIG '' Ri1GRUMyMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1T
'' SIG '' dGFtcCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAHD4
'' SIG '' KH/VUjOZRWk4Nw6/5TmY7vPCoIHeMIHbpIHYMIHVMQsw
'' SIG '' CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
'' SIG '' MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
'' SIG '' b2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3Nv
'' SIG '' ZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEnMCUGA1UE
'' SIG '' CxMebkNpcGhlciBOVFMgRVNOOjU3RjYtQzFFMC01NTRD
'' SIG '' MSswKQYDVQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2Ug
'' SIG '' TWFzdGVyIENsb2NrMA0GCSqGSIb3DQEBBQUAAgUA33nR
'' SIG '' QzAiGA8yMDE4MTAyNDAwNTYzNVoYDzIwMTgxMDI1MDA1
'' SIG '' NjM1WjB2MDwGCisGAQQBhFkKBAExLjAsMAoCBQDfedFD
'' SIG '' AgEAMAkCAQACAQECAf8wBwIBAAICFuMwCgIFAN97IsMC
'' SIG '' AQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoD
'' SIG '' AaAKMAgCAQACAxbjYKEKMAgCAQACAwehIDANBgkqhkiG
'' SIG '' 9w0BAQUFAAOCAQEACsp6IfVp5mygoKddz99fr92BLXFX
'' SIG '' 9PGa4ZWrPIQO1522pE8iizPc3s29bbWLpFDdJG84hHaq
'' SIG '' jMy1Cyo9RY2lU+4v5juoFRUnNH00l5pnIoq5gjFpg7s5
'' SIG '' 6/ZdUt1cVqXBvNllpWfiwZadW4Et324xufuI3T9m18Pt
'' SIG '' UHmEgTLU7gyQXy1ryb+o5XQ7YDN8TLiA2wEA94lT92Rj
'' SIG '' 9eH63UndIPv8Z7vu8TVXGjy+s4HwlAA1JtIU6xTWog6q
'' SIG '' kWF43YbqjGYrTsGMGU2M/1Z4XG4Blnfba0fwExSQC7BE
'' SIG '' r4jppGrN5OzfQ2yf5pldUODW1nwKvnQ9oTJUSo16W0UB
'' SIG '' 54s0HDGCAvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVT
'' SIG '' MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
'' SIG '' ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
'' SIG '' YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
'' SIG '' YW1wIFBDQSAyMDEwAhMzAAAA0rjjWm3EWxp3AAAAAADS
'' SIG '' MA0GCWCGSAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMx
'' SIG '' DQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIEqv
'' SIG '' liJMN5bCqH0qxhlO1AZSoLRDMMeMfw247k7+34HuMIHi
'' SIG '' BgsqhkiG9w0BCRACDDGB0jCBzzCBzDCBsQQUcPgof9VS
'' SIG '' M5lFaTg3Dr/lOZju88IwgZgwgYCkfjB8MQswCQYDVQQG
'' SIG '' EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
'' SIG '' BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
'' SIG '' cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGlt
'' SIG '' ZS1TdGFtcCBQQ0EgMjAxMAITMwAAANK441ptxFsadwAA
'' SIG '' AAAA0jAWBBTMljg3qWylp5BtlMkqGGEPJswoxzANBgkq
'' SIG '' hkiG9w0BAQsFAASCAQAbzV7Nnis8ZQFnl+yWBtaz9XCK
'' SIG '' hKcMEQ/1W8DIigMIMOwz6QGjNrsHaIFvQRle9BOJy4Xs
'' SIG '' 8mjOTdWUuRCqJ4bbhL0jODU08KesngYaQB85aU9Z7IGl
'' SIG '' oUX58zLZPsYqHBurlW2vZ+zWxxiQKbX6ZhoSrwRJVAUx
'' SIG '' EPT/HUtssSOkbYcC/9y/u7N4U8tuZMLfJSODstbkTgxd
'' SIG '' V/uSL878puWf6Bo9TKcF//6niU1L8OwozL7/uebZlTKp
'' SIG '' 2i+9hby4H/gvk0LWV1diiIGvKI8Jl4H1yHhwDD4hSOTI
'' SIG '' uN4d4DeSK1mabvnQz1Rxxf9aQ0r+GlsdyGILXKqNyIkZ
'' SIG '' EmDJ5zKF
'' SIG '' End signature block
