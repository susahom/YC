' Windows Installer utility to list component composition of an MSI database
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the various tables having foreign keys to the Component table
'
Option Explicit
Public isGUI, installer, database, message, compParam  'global variables access across functions

Const msiOpenDatabaseModeReadOnly     = 0

' Check if run from GUI script host, in order to modify display
If UCase(Mid(Wscript.FullName, Len(Wscript.Path) + 2, 1)) = "W" Then isGUI = True

' Show help if no arguments or if argument contains ?
Dim argCount:argCount = Wscript.Arguments.Count
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If argCount = 0 Then
	Wscript.Echo "Windows Installer utility to list component composition in an install database." &_
		vbLf & " The 1st argument is the path to an install database, relative or complete path" &_
		vbLf & " The 2nd argument is the name of the component (primary key of Component table)" &_
		vbLf & " If the 2nd argument is not present, the names of all components will be listed" &_
		vbLf & " If the 2nd argument is a ""*"", the composition of all components will be listed" &_
		vbLf & " Large databases or components are better displayed using CScript than WScript." &_
		vbLf & " Note: The name of the component, if provided,  is case-sensitive" &_
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

If argCount = 1 Then  'If no component specified, then simply list components
	ListComponents False
	ShowOutput "Components for " & databasePath, message
ElseIf Left(Wscript.Arguments(1), 1) = "*" Then 'List all components
	ListComponents True
Else
	QueryComponent Wscript.Arguments(1) 
End If
Wscript.Quit 0

' List all table rows referencing a given component
Function QueryComponent(component)
	' Get component info and format output header
	Dim view, record, header, componentId
	Set view = database.OpenView("SELECT `ComponentId` FROM `Component` WHERE `Component` = ?") : CheckError
	Set compParam = installer.CreateRecord(1)
	compParam.StringData(1) = component
	view.Execute compParam : CheckError
	Set record = view.Fetch : CheckError
	Set view = Nothing
	If record Is Nothing Then Fail "Component not in database: " & component
	componentId = record.StringData(1)
	header = "Component: "& component & "  ComponentId = " & componentId

	' List of tables with foreign keys to Component table - with subsets of columns to display
	DoQuery "FeatureComponents","Feature_"                           '
	DoQuery "PublishComponent", "ComponentId,Qualifier"              'AppData,Feature
	DoQuery "File",             "File,Sequence,FileName,Version"     'FileSize,Language,Attributes
	DoQuery "SelfReg,File",     "File_"                              'Cost
	DoQuery "BindImage,File",   "File_"                              'Path
	DoQuery "Font,File",        "File_,FontTitle"                    '
	DoQuery "Patch,File",       "File_"                              'Sequence,PatchSize,Attributes,Header
	DoQuery "DuplicateFile",    "FileKey,File_,DestName"             'DestFolder
	DoQuery "MoveFile",         "FileKey,SourceName,DestName"        'SourceFolder,DestFolder,Options
	DoQuery "RemoveFile",       "FileKey,FileName,DirProperty"       'InstallMode
	DoQuery "IniFile",          "IniFile,FileName,Section,Key"       'Value,Action
	DoQuery "RemoveIniFile",    "RemoveIniFile,FileName,Section,Key" 'Value,Action
	DoQuery "Registry",         "Registry,Root,Key,Name"             'Value
	DoQuery "RemoveRegistry",   "RemoveRegistry,Root,Key,Name"       '
	DoQuery "Shortcut",         "Shortcut,Directory_,Name,Target"    'Arguments,Description,Hotkey,Icon_,IconIndex,ShowCmd,WkDir
	DoQuery "Class",            "CLSID,Description"                  'Context,ProgId_Default,AppId_,FileType,Mask,Icon_,IconIndex,DefInprocHandler,Argument,Feature_
	DoQuery "ProgId,Class",     "Class_,ProgId,Description"          'ProgId_Parent,Icon_IconIndex,Insertable
	DoQuery "Extension",        "Extension,ProgId_"                  'MIME_,Feature_
	DoQuery "Verb,Extension",   "Extension_,Verb"                    'Sequence,Command.Argument
	DoQuery "MIME,Extension",   "Extension_,ContentType"             'CLSID
	DoQuery "TypeLib",          "LibID,Language,Version,Description" 'Directory_,Feature_,Cost
	DoQuery "CreateFolder",     "Directory_"                         ' 
	DoQuery "Environment",      "Environment,Name"                   'Value
	DoQuery "ODBCDriver",       "Driver,Description"                 'File_,File_Setup
	DoQuery "ODBCAttribute,ODBCDriver", "Driver_,Attribute,Value" '
	DoQuery "ODBCTranslator",   "Translator,Description"             'File_,File_Setup
	DoQuery "ODBCDataSource",   "DataSource,Description,DriverDescription" 'Registration
	DoQuery "ODBCSourceAttribute,ODBCDataSource", "DataSource_,Attribute,Value" '
	DoQuery "ServiceControl",   "ServiceControl,Name,Event"          'Arguments,Wait
	DoQuery "ServiceInstall",   "ServiceInstall,Name,DisplayName"    'ServiceType,StartType,ErrorControl,LoadOrderGroup,Dependencies,StartName,Password
	DoQuery "ReserveCost",      "ReserveKey,ReserveFolder"           'ReserveLocal,ReserveSource

	QueryComponent = ShowOutput(header, message)
	message = Empty
End Function

' List all components in database
Sub ListComponents(queryAll)
	Dim view, record, component
	Set view = database.OpenView("SELECT `Component`,`ComponentId` FROM `Component`") : CheckError
	view.Execute : CheckError
	Do
		Set record = view.Fetch : CheckError
		If record Is Nothing Then Exit Do
		component = record.StringData(1)
		If queryAll Then
			If QueryComponent(component) = vbCancel Then Exit Sub
		Else
			If Not IsEmpty(message) Then message = message & vbLf
			message = message & component
		End If
	Loop
End Sub

' Perform a join to query table rows linked to a given component, delimiting and qualifying names to prevent conflicts
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
	query = "SELECT `" & columnList & "` FROM `" & tableList & "` WHERE `Component_` = ?" & query
	If database.TablePersistent(table) <> 1 Then Exit Sub
	Set view = database.OpenView(query) : CheckError
	view.Execute compParam : CheckError
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
'' SIG '' MIIiqQYJKoZIhvcNAQcCoIIimjCCIpYCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' WoLLQA6rHA8fttRtGpZpVGF985uNg+TIhlmzKb0W2sOg
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
'' SIG '' Bmrm1MbfI5qWdcUxghaAMIIWfAIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgU+H2zhtPO/bs1TiBZyzIPq79ccTVGaHmw1wCd9Wp
'' SIG '' jFgwPAYKKwYBBAGCNwoDHDEuDCxjRG5BMkVsM0ZYSFls
'' SIG '' Y0JLVW5FMzFFOEtmZVpRNEZNSldoNGtvR2g1YVlzPTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAEE1VpLA0gA2dQFkH5eLdxCmx0zPUovm
'' SIG '' 1VsMW2/KAQ2IwZqgpGui72MkLxqjp/dRbMSG466Re6NU
'' SIG '' rwUjXFcbIarfe8krEJmLjwaQPx+1ChfeEuWBC6EvAI4G
'' SIG '' fw12fOfdAlXO1Qw7U1rjl8eFEDvLGEai6Ad2GXxk+/Sv
'' SIG '' N9uvzA66sDYnq4Rtvck+8v3hLJFS31BY/OlfHjKTClXv
'' SIG '' aFjNaONLnDgYUrna8Bjb2IfJ2roLMRQ1RUYSubdwzodz
'' SIG '' vTZNUA32HxqKjR1z7z1NyUAZBXKIZ9AMy6YsnaxNcU6e
'' SIG '' QtMcB9TNSzdzX5d7juti0jkR0S5ZB/1h+iepH+14ym6p
'' SIG '' pBqhghOzMIITrwYKKwYBBAGCNwMDATGCE58wghObBgkq
'' SIG '' hkiG9w0BBwKgghOMMIITiAIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVQYLKoZIhvcNAQkQAQSgggFEBIIBQDCCATwC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' 9JyKG1qKNOZGvTe9saSnG+D8oDZtLdM82vFp0ULnMlwC
'' SIG '' BlvOEPwpsRgTMjAxODEwMjMxNzQ5MzEuODQ0WjAEgAIB
'' SIG '' 9KCB1KSB0TCBzjELMAkGA1UEBhMCVVMxEzARBgNVBAgT
'' SIG '' Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
'' SIG '' BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcG
'' SIG '' A1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRv
'' SIG '' IFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0
'' SIG '' OEMtQzRCOS0yMDY2MSUwIwYDVQQDExxNaWNyb3NvZnQg
'' SIG '' VGltZS1TdGFtcCBTZXJ2aWNloIIPHjCCBPUwggPdoAMC
'' SIG '' AQICEzMAAADVpyPleJVqCf8AAAAAANUwDQYJKoZIhvcN
'' SIG '' AQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
'' SIG '' c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
'' SIG '' BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
'' SIG '' AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
'' SIG '' HhcNMTgwODIzMjAyNjQ1WhcNMTkxMTIzMjAyNjQ1WjCB
'' SIG '' zjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMgTWlj
'' SIG '' cm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28xJjAk
'' SIG '' BgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0OEMtQzRCOS0y
'' SIG '' MDY2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
'' SIG '' MIIBCgKCAQEAwhQJK64X8TSCMvzuifB27nQzUHBTFDC2
'' SIG '' tlYRBgKYsyEaE1H/d5DEEP2WpjgVjGFFnVvF+wiOztIq
'' SIG '' 9wXSbVh+GArmP0F1m/O5552QRjwxVS7jXMHXx2f42Zp6
'' SIG '' XPm8XP0EurmEk8AR1mDdlH7h0/vX21Vck/+JWSyUtNMo
'' SIG '' f9ipPxVyJ6Zc5RoKwr9F7vF0F7yoFKGw7BuAPvFVjCCZ
'' SIG '' 6/P5tJndSxYKVxwEH2QyE0eGeIgqS4yjgE0nm177Knwo
'' SIG '' FXLOie0qa06FLVco1IjLARYDNEYpm2U/foNUY7L1IZqP
'' SIG '' B5XRGMeSpkxQPW0SIhoOgGmJldpwc+d7UVAbBKMrg0yU
'' SIG '' SwIDAQABo4IBGzCCARcwHQYDVR0OBBYEFCloozGUdkPZ
'' SIG '' X10Nm5/TsoT2YjeEMB8GA1UdIwQYMBaAFNVjOlyKMZDz
'' SIG '' Q3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJoEeGRWh0
'' SIG '' dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3By
'' SIG '' b2R1Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNy
'' SIG '' bDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0
'' SIG '' dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMv
'' SIG '' TWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1Ud
'' SIG '' EwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJ
'' SIG '' KoZIhvcNAQELBQADggEBAHnZy8LpxNHAqy0O0ia/2meg
'' SIG '' C/32wLbBAvLiuYHNYvaQj+yV4E1ejvhyp0Bahh8tEJCj
'' SIG '' 4O5babn/SYx7gOm88MtgJBJImQC27+FQvzTCKTlmpo28
'' SIG '' h+nuHX8In8oy4iB3xZuE1nEvIblLhbsCzrrtA2J/B4Ku
'' SIG '' MWpkxX1e0E7bCPP1C2LVGN04iaFftXiR0JgpK11CDbEm
'' SIG '' FRT1m0+oamu2Fo+q2j0WF6qzfsLDa87e0CNioxdNkK/J
'' SIG '' vP7htQfEha+q8khcum48/PXMK8Ki0t8HPMGJX2aIgQFe
'' SIG '' ye/aogiR0OchKqWshnWdd1Ed1eXhmEF/fABlH8TAgu8p
'' SIG '' qSwoVjOuTgswggZxMIIEWaADAgECAgphCYEqAAAAAAAC
'' SIG '' MA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0
'' SIG '' aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEy
'' SIG '' MTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEF
'' SIG '' AAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwTl/X6f2mU
'' SIG '' a3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycE
'' SIG '' MR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4CLNC
'' SIG '' 3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhgRvJYR4YyhB50
'' SIG '' YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScd
'' SIG '' JGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wG
'' SIG '' Pmd/9WbAA5ZEfu/QS/1u5ZrKsajyeioKMfDaTgaRtogI
'' SIG '' Neh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1e
'' SIG '' FpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUB
'' SIG '' BAMCAQAwHQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2ha
'' SIG '' hW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
'' SIG '' A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1Ud
'' SIG '' IwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1Ud
'' SIG '' HwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0
'' SIG '' LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1
'' SIG '' dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEww
'' SIG '' SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0
'' SIG '' LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAt
'' SIG '' MDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsG
'' SIG '' AQQBgjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3
'' SIG '' dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZh
'' SIG '' dWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBh
'' SIG '' AGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBtAGUA
'' SIG '' bgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3i
'' SIG '' xuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LF
'' SIG '' Zslq3/Xn8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRg
'' SIG '' Eop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3
'' SIG '' fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9L
'' SIG '' MEQkIjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbljjO7
'' SIG '' Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFjnXsh
'' SIG '' bcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2e
'' SIG '' Gq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2onGq
'' SIG '' BooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7cQnfXXSY
'' SIG '' Ighh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5h
'' SIG '' a293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kqVDmy
'' SIG '' W9rIDVWZeodzOwjmmC3qjeAzLhIp9cAvVCch98isTtoo
'' SIG '' uLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZ
'' SIG '' ii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN
'' SIG '' +w2/XU/pnR4ZOC+8z1gFLu8NoFA12u8JJxzVs341Hgi6
'' SIG '' 2jbb01+P3nSISRKhggOsMIIClAIBATCB/qGB1KSB0TCB
'' SIG '' zjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UECxMgTWlj
'' SIG '' cm9zb2Z0IE9wZXJhdGlvbnMgUHVlcnRvIFJpY28xJjAk
'' SIG '' BgNVBAsTHVRoYWxlcyBUU1MgRVNOOjE0OEMtQzRCOS0y
'' SIG '' MDY2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAK3DJLzR
'' SIG '' 2XXwXdDdRR85MZ5u1p6xoIHeMIHbpIHYMIHVMQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQg
'' SIG '' T3BlcmF0aW9ucyBQdWVydG8gUmljbzEnMCUGA1UECxMe
'' SIG '' bkNpcGhlciBOVFMgRVNOOjU3RjYtQzFFMC01NTRDMSsw
'' SIG '' KQYDVQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2UgTWFz
'' SIG '' dGVyIENsb2NrMA0GCSqGSIb3DQEBBQUAAgUA33nRhTAi
'' SIG '' GA8yMDE4MTAyNDAwNTc0MVoYDzIwMTgxMDI1MDA1NzQx
'' SIG '' WjBzMDkGCisGAQQBhFkKBAExKzApMAoCBQDfedGFAgEA
'' SIG '' MAYCAQACATcwBwIBAAICGHwwCgIFAN97IwUCAQAwNgYK
'' SIG '' KwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAaAKMAgC
'' SIG '' AQACAwehIKEKMAgCAQACAwehIDANBgkqhkiG9w0BAQUF
'' SIG '' AAOCAQEAk7cNiyeB8LD5fzyaEeQAAL6wTSdeAlnDexrd
'' SIG '' tKWjL7EMzmOD4t0sGneSrxzAjQIiA7iivh3KtJHPKlVA
'' SIG '' BpBXRHvAxcTMDCDS4YVwTiGYEtzhDYgN+MTYMEMkHciJ
'' SIG '' 90MD79A1fSovxsIgXScrifsPxDI2N2fw4coi04dRYSsW
'' SIG '' T5bcav6xc9m32pigX3HsYE1nQEhWttEF0mbk1GyhebHS
'' SIG '' wRtk0QkBiYuJvIt46NvyzcOgow5MnlR5T+dc2wXHUp3C
'' SIG '' ADg9Xm/+D/TQ1c4OYdMwjecU90F7yh7O9Z5eSs/GZifm
'' SIG '' bDmFpeZLMqxEGGLaRkp9QxixI/Fnr0hCjrFPr9pMCDGC
'' SIG '' AvUwggLxAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
'' SIG '' MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
'' SIG '' QSAyMDEwAhMzAAAA1acj5XiVagn/AAAAAADVMA0GCWCG
'' SIG '' SAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMxDQYLKoZI
'' SIG '' hvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIAvXTsQbM8XD
'' SIG '' jEk/1iWjNu0jiOnLJKsUvO9otgV9nH5HMIHiBgsqhkiG
'' SIG '' 9w0BCRACDDGB0jCBzzCBzDCBsQQUrcMkvNHZdfBd0N1F
'' SIG '' Hzkxnm7WnrEwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBQQ0EgMjAxMAITMwAAANWnI+V4lWoJ/wAAAAAA1TAW
'' SIG '' BBSEmCwvGAHC31fsN1XevcakRXo6ajANBgkqhkiG9w0B
'' SIG '' AQsFAASCAQBrjwCArE7QlyJ/v+Ys9beYloKufUXa0BOI
'' SIG '' iFqo313hVzGZrujd62Qfvt45JBIJ4P3E/Fuzq1URwCyV
'' SIG '' LJWRpjjdU+GcR1/oO7pat5CW1ISfPxg3Bani5BHurdyX
'' SIG '' pV6HizfGMAr4LjNyzcaHgBMgK5etZ2Jg7nFvl6ygT5cA
'' SIG '' SkA9CTMolsqOt9mCbuDs61TK6CS3X/PZ+k0JCWfFZQFE
'' SIG '' r65nHZ7hfzDcUcNaxHL7GAELDhm5qAXDdAFdvkoG0gkl
'' SIG '' jnfvUUYBxzmGJNbPt7dQpDsXFtDITTxZPgyBicN/oQIY
'' SIG '' kkuQ7pGy0OUBY6pUNWv2tL8oPJ6KvYhZY4kzLoqcW0wE
'' SIG '' End signature block
