' Windows Installer utility to generate file cabinets from MSI database
' For use with Windows Scripting Host, CScript.exe or WScript.exe
' Copyright (c) Microsoft Corporation. All rights reserved.
' Demonstrates the access to install engine and actions
'
Option Explicit

' FileSystemObject.CreateTextFile and FileSystemObject.OpenTextFile
Const OpenAsASCII   = 0 
Const OpenAsUnicode = -1

' FileSystemObject.CreateTextFile
Const OverwriteIfExist = -1
Const FailIfExist      = 0

' FileSystemObject.OpenTextFile
Const OpenAsDefault    = -2
Const CreateIfNotExist = -1
Const FailIfNotExist   = 0
Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Const msiOpenDatabaseModeReadOnly = 0
Const msiOpenDatabaseModeTransact = 1

Const msiViewModifyInsert         = 1
Const msiViewModifyUpdate         = 2
Const msiViewModifyAssign         = 3
Const msiViewModifyReplace        = 4
Const msiViewModifyDelete         = 6

Const msiUILevelNone = 2

Const msiRunModeSourceShortNames = 9

Const msidbFileAttributesNoncompressed = &h00002000

Dim argCount:argCount = Wscript.Arguments.Count
Dim iArg:iArg = 0
If argCount > 0 Then If InStr(1, Wscript.Arguments(0), "?", vbTextCompare) > 0 Then argCount = 0
If (argCount < 2) Then
	Wscript.Echo "Windows Installer utility to generate compressed file cabinets from MSI database" &_
		vbNewLine & " The 1st argument is the path to MSI database, at the source file root" &_
		vbNewLine & " The 2nd argument is the base name used for the generated files (DDF, INF, RPT)" &_
		vbNewLine & " The 3rd argument can optionally specify separate source location from the MSI" &_
		vbNewLine & " The following options may be specified at any point on the command line" &_
		vbNewLine & "  /L to use LZX compression instead of MSZIP" &_
		vbNewLine & "  /F to limit cabinet size to 1.44 MB floppy size rather than CD" &_
		vbNewLine & "  /C to run compression, else only generates the .DDF file" &_
		vbNewLine & "  /U to update the MSI database to reference the generated cabinet" &_
		vbNewLine & "  /E to embed the cabinet file in the installer package as a stream" &_
		vbNewLine & "  /S to sequence number file table, ordered by directories" &_
		vbNewLine & "  /R to revert to non-cabinet install, removes cabinet if /E specified" &_
		vbNewLine & " Notes:" &_
		vbNewLine & "  In order to generate a cabinet, MAKECAB.EXE must be on the PATH" &_
		vbNewLine & "  base name used for files and cabinet stream is case-sensitive" &_
		vbNewLine & "  If source type set to compressed, all files will be opened at the root" &_
		vbNewLine & "  (The /R option removes the compressed bit - SummaryInfo property 15 & 2)" &_
		vbNewLine & "  To replace an embedded cabinet, include the options: /R /C /U /E" &_
		vbNewLine & "  Does not handle updating of Media table to handle multiple cabinets" &_
		vbNewLine &_
		vbNewLine & "Copyright (C) Microsoft Corporation.  All rights reserved."
	Wscript.Quit 1
End If

' Get argument values, processing any option flags
Dim compressType : compressType = "MSZIP"
Dim cabSize      : cabSize      = "CDROM"
Dim makeCab      : makeCab      = False
Dim embedCab     : embedCab     = False
Dim updateMsi    : updateMsi    = False
Dim sequenceFile : sequenceFile = False
Dim removeCab    : removeCab    = False
Dim databasePath : databasePath = NextArgument
Dim baseName     : baseName     = NextArgument
Dim sourceFolder : sourceFolder = NextArgument
If Not IsEmpty(NextArgument) Then Fail "More than 3 arguments supplied" ' process any trailing options
If Len(baseName) < 1 Or Len(baseName) > 8 Then Fail "Base file name must be from 1 to 8 characters"
If Not IsEmpty(sourceFolder) And Right(sourceFolder, 1) <> "\" Then sourceFolder = sourceFolder & "\"
Dim cabFile : cabFile = baseName & ".CAB"
Dim cabName : cabName = cabFile : If embedCab Then cabName = "#" & cabName

' Connect to Windows Installer object
On Error Resume Next
Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer") : CheckError

' Open database
Dim database, openMode, view, record, updateMode, sumInfo, sequence, lastSequence
If updateMsi Or sequenceFile Or removeCab Then openMode = msiOpenDatabaseModeTransact Else openMode = msiOpenDatabaseModeReadOnly
Set database = installer.OpenDatabase(databasePath, openMode) : CheckError

' Remove existing cabinet(s) and revert to source tree install if options specified
If removeCab Then
	Set view = database.OpenView("SELECT DiskId, LastSequence, Cabinet FROM Media ORDER BY DiskId") : CheckError
	view.Execute : CheckError
	updateMode = msiViewModifyUpdate
	Set record = view.Fetch : CheckError
	If Not record Is Nothing Then ' Media table not empty
		If Not record.IsNull(3) Then
			If record.StringData(3) <> cabName Then Wscript.Echo "Warning, cabinet name in media table, " & record.StringData(3) & " does not match " & cabName
			record.StringData(3) = Empty
		End If
		record.IntegerData(2) = 9999 ' in case of multiple cabinets, force all files from 1st media
		view.Modify msiViewModifyUpdate, record : CheckError
		Do
			Set record = view.Fetch : CheckError
			If record Is Nothing Then Exit Do
			view.Modify msiViewModifyDelete, record : CheckError 'remove other cabinet records
		Loop
	End If
	Set sumInfo = database.SummaryInformation(3) : CheckError
	sumInfo.Property(11) = Now
	sumInfo.Property(13) = Now
	sumInfo.Property(15) = sumInfo.Property(15) And Not 2
	sumInfo.Persist
	Set view = database.OpenView("SELECT `Name`,`Data` FROM _Streams WHERE `Name`= '" & cabFile & "'") : CheckError
	view.Execute : CheckError
	Set record = view.Fetch
	If record Is Nothing Then
		Wscript.Echo "Warning, cabinet stream not found in package: " & cabFile
	Else
		view.Modify msiViewModifyDelete, record : CheckError
	End If
	Set sumInfo = Nothing ' must release stream
	database.Commit : CheckError
	If Not updateMsi Then Wscript.Quit 0
End If

' Create an install session and execute actions in order to perform directory resolution
installer.UILevel = msiUILevelNone
Dim session : Set session = installer.OpenPackage(database,1) : If Err <> 0 Then Fail "Database: " & databasePath & ". Invalid installer package format"
Dim shortNames : shortNames = session.Mode(msiRunModeSourceShortNames) : CheckError
If Not IsEmpty(sourceFolder) Then session.Property("OriginalDatabase") = sourceFolder : CheckError
Dim stat : stat = session.DoAction("CostInitialize") : CheckError
If stat <> 1 Then Fail "CostInitialize failed, returned " & stat

' Check for non-cabinet files to avoid sequence number collisions
lastSequence = 0
If sequenceFile Then
	Set view = database.OpenView("SELECT Sequence,Attributes FROM File") : CheckError
	view.Execute : CheckError
	Do
		Set record = view.Fetch : CheckError
		If record Is Nothing Then Exit Do
		sequence = record.IntegerData(1)
		If (record.IntegerData(2) And msidbFileAttributesNoncompressed) <> 0 And sequence > lastSequence Then lastSequence = sequence
	Loop	
End If

' Join File table to Component table in order to find directories
Dim orderBy : If sequenceFile Then orderBy = "Directory_" Else orderBy = "Sequence"
Set view = database.OpenView("SELECT File,FileName,Directory_,Sequence,File.Attributes FROM File,Component WHERE Component_=Component ORDER BY " & orderBy) : CheckError
view.Execute : CheckError

' Create DDF file and write header properties
Dim FileSys : Set FileSys = CreateObject("Scripting.FileSystemObject") : CheckError
Dim outStream : Set outStream = FileSys.CreateTextFile(baseName & ".DDF", OverwriteIfExist, OpenAsASCII) : CheckError
outStream.WriteLine "; Generated from " & databasePath & " on " & Now
outStream.WriteLine ".Set CabinetNameTemplate=" & baseName & "*.CAB"
outStream.WriteLine ".Set CabinetName1=" & cabFile
outStream.WriteLine ".Set ReservePerCabinetSize=8"
outStream.WriteLine ".Set MaxDiskSize=" & cabSize
outStream.WriteLine ".Set CompressionType=" & compressType
outStream.WriteLine ".Set InfFileLineFormat=(*disk#*) *file#*: *file* = *Size*"
outStream.WriteLine ".Set InfFileName=" & baseName & ".INF"
outStream.WriteLine ".Set RptFileName=" & baseName & ".RPT"
outStream.WriteLine ".Set InfHeader="
outStream.WriteLine ".Set InfFooter="
outStream.WriteLine ".Set DiskDirectoryTemplate=."
outStream.WriteLine ".Set Compress=ON"
outStream.WriteLine ".Set Cabinet=ON"

' Fetch each file and request the source path, then verify the source path
Dim fileKey, fileName, folder, sourcePath, delim, message, attributes
Do
	Set record = view.Fetch : CheckError
	If record Is Nothing Then Exit Do
	fileKey    = record.StringData(1)
	fileName   = record.StringData(2)
	folder     = record.StringData(3)
	sequence   = record.IntegerData(4)
	attributes = record.IntegerData(5)
	If (attributes And msidbFileAttributesNoncompressed) = 0 Then
		If sequence <= lastSequence Then
			If Not sequenceFile Then Fail "Duplicate sequence numbers in File table, use /S option"
			sequence = lastSequence + 1
			record.IntegerData(4) = sequence
			view.Modify msiViewModifyUpdate, record
		End If
		lastSequence = sequence
		delim = InStr(1, fileName, "|", vbTextCompare)
		If delim <> 0 Then
			If shortNames Then fileName = Left(fileName, delim-1) Else fileName = Right(fileName, Len(fileName) - delim)
		End If
		sourcePath = session.SourcePath(folder) & fileName
		outStream.WriteLine """" & sourcePath & """" & " " & fileKey
		If installer.FileAttributes(sourcePath) = -1 Then message = message & vbNewLine & sourcePath
	End If
Loop
outStream.Close
REM Wscript.Echo "SourceDir = " & session.Property("SourceDir")
If Not IsEmpty(message) Then Fail "The following files were not available:" & message

' Generate compressed file cabinet
If makeCab Then
	Dim WshShell : Set WshShell = Wscript.CreateObject("Wscript.Shell") : CheckError
	Dim cabStat : cabStat = WshShell.Run("MakeCab.exe /f " & baseName & ".DDF", 7, True) : CheckError
	If cabStat <> 0 Then Fail "MAKECAB.EXE failed, possibly could not find source files, or invalid DDF format"
End If

' Update Media table and SummaryInformation if requested
If updateMsi Then
	Set view = database.OpenView("SELECT DiskId, LastSequence, Cabinet FROM Media ORDER BY DiskId") : CheckError
	view.Execute : CheckError
	updateMode = msiViewModifyUpdate
	Set record = view.Fetch : CheckError
	If record Is Nothing Then ' Media table empty
		Set record = Installer.CreateRecord(3)
		record.IntegerData(1) = 1
		updateMode = msiViewModifyInsert
	End If
	record.IntegerData(2) = lastSequence
	record.StringData(3) = cabName
	view.Modify updateMode, record
	Set sumInfo = database.SummaryInformation(3) : CheckError
	sumInfo.Property(11) = Now
	sumInfo.Property(13) = Now
	sumInfo.Property(15) = (shortNames And 1) + 2
	sumInfo.Persist
End If

' Embed cabinet if requested
If embedCab Then
	Set view = database.OpenView("SELECT `Name`,`Data` FROM _Streams") : CheckError
	view.Execute : CheckError
	Set record = Installer.CreateRecord(2)
	record.StringData(1) = cabFile
	record.SetStream 2, cabFile : CheckError
	view.Modify msiViewModifyAssign, record : CheckError 'replace any existing stream of that name
End If

' Commit database in case updates performed
database.Commit : CheckError
Wscript.Quit 0

' Extract argument value from command line, processing any option flags
Function NextArgument
	Dim arg
	Do  ' loop to pull in option flags until an argument value is found
		If iArg >= argCount Then Exit Function
		arg = Wscript.Arguments(iArg)
		iArg = iArg + 1
		If (AscW(arg) <> AscW("/")) And (AscW(arg) <> AscW("-")) Then Exit Do
		Select Case UCase(Right(arg, Len(arg)-1))
			Case "C" : makeCab      = True
			Case "E" : embedCab     = True
			Case "F" : cabSize      = "1.44M"
			Case "L" : compressType = "LZX"
			Case "R" : removeCab    = True
			Case "S" : sequenceFile = True
			Case "U" : updateMsi    = True
			Case Else: Wscript.Echo "Invalid option flag:", arg : Wscript.Quit 1
		End Select
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
	Fail message
End Sub

Sub Fail(message)
	Wscript.Echo message
	Wscript.Quit 2
End Sub

'' SIG '' Begin signature block
'' SIG '' MIIinwYJKoZIhvcNAQcCoIIikDCCIowCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' +3czCZ7bOIQLc7kJN8m8lyJpE9uBKr7KXjIe8c3/+0yg
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
'' SIG '' Bmrm1MbfI5qWdcUxghZ2MIIWcgIBATCBlTB+MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
'' SIG '' Q29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAACJG2S5VjK
'' SIG '' df54AAAAAAIkMA0GCWCGSAFlAwQCAQUAoIIBBDAZBgkq
'' SIG '' hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
'' SIG '' AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
'' SIG '' IgQgxDFZYfd/RKjHOE5Cgv/lYGksv4yH37lgLg2yLK/O
'' SIG '' 9h8wPAYKKwYBBAGCNwoDHDEuDCxCVDY0L1BNNkgvaXRE
'' SIG '' dW1kclZ2VEc3dnZhbEVoZGNHTlYyWWl4ZUhuWlB3PTBa
'' SIG '' BgorBgEEAYI3AgEMMUwwSqAkgCIATQBpAGMAcgBvAHMA
'' SIG '' bwBmAHQAIABXAGkAbgBkAG8AdwBzoSKAIGh0dHA6Ly93
'' SIG '' d3cubWljcm9zb2Z0LmNvbS93aW5kb3dzMA0GCSqGSIb3
'' SIG '' DQEBAQUABIIBAJ9tPQx7u7N5fs/zZX71JuYQPg0NVJCt
'' SIG '' wuD80fsAc0je/tqqH0k6CiEuRhIqn2fi5NH+4de0qYPY
'' SIG '' 9PcktpkTZ/1+xEEuTMZJay605NLZswwztchGytsp343G
'' SIG '' AcUmsSW0rGk1kf3XGa49AQQEItjYDxXH4iDOOkR9o/1W
'' SIG '' 0sAdMOjqbySFxzJydrk9d1IWoTH5OqRLVbKuA+KSNnpU
'' SIG '' URTz+P80KvKRLBFc1P3nItdFcNwkZa4pVqN8R/8gip6a
'' SIG '' Doj1vgskUqUOC61TJdYug/95s0pRTiohOcuRGnK4TJm4
'' SIG '' UswF/oK+uvXEkHpho3IDGIXYLoQzA3j8tWGWOnUs1Kj3
'' SIG '' T8ihghOpMIITpQYKKwYBBAGCNwMDATGCE5UwghORBgkq
'' SIG '' hkiG9w0BBwKgghOCMIITfgIBAzEPMA0GCWCGSAFlAwQC
'' SIG '' AQUAMIIBVAYLKoZIhvcNAQkQAQSgggFDBIIBPzCCATsC
'' SIG '' AQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' 8H9CJEJbcoX8O731iWwcjL5BI4/S3Uv8L0IzWIF6p2EC
'' SIG '' BlvN9yAdMBgTMjAxODEwMjMxNzQ5MzAuOTQ4WjAHAgEB
'' SIG '' gAIB9KCB0KSBzTCByjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEl
'' SIG '' MCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
'' SIG '' aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MERF
'' SIG '' OC0yREM1LTNDQTkxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFNlcnZpY2Wggg8VMIIGcTCCBFmgAwIB
'' SIG '' AgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
'' SIG '' EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
'' SIG '' c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9z
'' SIG '' b2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIw
'' SIG '' MTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1
'' SIG '' WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
'' SIG '' aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIw
'' SIG '' DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3
'' SIG '' EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxfxcPl
'' SIG '' YcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/x
'' SIG '' YIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8k
'' SIG '' YDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSmXdFhE24o
'' SIG '' xhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3w
'' SIG '' V3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo
'' SIG '' 8noqCjHw2k4GkbaICDXoeByw6ZnNPOcvRLqn9NxkvaQB
'' SIG '' wSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHi
'' SIG '' MBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpc
'' SIG '' ijGQ80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4K
'' SIG '' AFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
'' SIG '' BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2U
'' SIG '' kFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8v
'' SIG '' Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
'' SIG '' cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
'' SIG '' KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
'' SIG '' d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jv
'' SIG '' b0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/
'' SIG '' BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUH
'' SIG '' AgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9QS0kv
'' SIG '' ZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIw
'' SIG '' NB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBT
'' SIG '' AHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQEL
'' SIG '' BQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+
'' SIG '' zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RX
'' SIG '' CCtRgkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRW
'' SIG '' S3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl
'' SIG '' 2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCf
'' SIG '' Mkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVK
'' SIG '' C5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLhnPkd
'' SIG '' /DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/
'' SIG '' fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n
'' SIG '' 0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQekkzr3
'' SIG '' ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d
'' SIG '' 9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4S
'' SIG '' KfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN4Ib5Kpqj
'' SIG '' EWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV
'' SIG '' 42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQ
'' SIG '' NdrvCScc1bN+NR4Iuto229Nfj950iEkSMIIE8TCCA9mg
'' SIG '' AwIBAgITMwAAAOTaHzbe93At2AAAAAAA5DANBgkqhkiG
'' SIG '' 9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MDAeFw0xODA4MjMyMDI3MDhaFw0xOTExMjMyMDI3MDha
'' SIG '' MIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
'' SIG '' Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
'' SIG '' TWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxN
'' SIG '' aWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMSYwJAYD
'' SIG '' VQQLEx1UaGFsZXMgVFNTIEVTTjowREU4LTJEQzUtM0NB
'' SIG '' OTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
'' SIG '' U2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
'' SIG '' AQoCggEBAMOtJNRHh1NLZYDdfKN122SynuEm4sfd7rVE
'' SIG '' NnxVa0b/xQOKLkuURUxf0VzZLgU5GIv5FX0E+21iG6KE
'' SIG '' d9s5cDsB3Ze2DLJ5r61cwKKjvkMRF/HJY7bYFnrIlQSv
'' SIG '' C8O7QLketNr5jwPnnIjLqQn9DRF+9iAvCT/U+nrS5vk7
'' SIG '' 9EF9LqNJjYADZSbKa/oAVnV3Dsf4xbhnw1jZXzkSlxss
'' SIG '' Tx+BgkXUHH0FA7q1vU2ah2y5dxPqpdyYHtsf2zebPz13
'' SIG '' ya1/2zT6z5AF+gkK5SILD6iK4cJ55ajAtdgNy9BqX4Px
'' SIG '' 5G19ONbGqvOJxKlwHnzz4JV4fkbbx8Wg0GLEX3+ckpkC
'' SIG '' AwEAAaOCARswggEXMB0GA1UdDgQWBBTxTWc2LI4dOuRU
'' SIG '' Y4tvWm73DrjOeDAfBgNVHSMEGDAWgBTVYzpcijGQ80N7
'' SIG '' fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRw
'' SIG '' Oi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9k
'' SIG '' dWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmww
'' SIG '' WgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw
'' SIG '' Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
'' SIG '' Y1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMB
'' SIG '' Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4IBAQAUWWo1N9v0C3sYxYgeKV6WFyJI
'' SIG '' uC3CwRjQtHMVySdUGM8lxjR+bJAyDURDZlxjE39Aq17q
'' SIG '' 5r6i6WWfTm3ga567OZLIi0iuOBSCWb+MYu7p2aQ1aYbO
'' SIG '' 3bZKUSa+CtM5OzRkaZL/mF5uAXp1HSnpuewj4Xiqk2Uj
'' SIG '' PRGdUH8dQ0VtPTsBW8WwfTMODA9RLQL5m8UH6Uzf6QcW
'' SIG '' 8dbhTLj8llZ53F2DYHYCfn4YzwzgqVZZopnaj533og0W
'' SIG '' 9d26v1WpZ39mziLH02Tap0ZOZzZpr2C/8cf3QsKdu3ji
'' SIG '' +K/CWDa9os98JoD2dqJwP5yymO1Xld07Z2ycyMDsBMuE
'' SIG '' ASy4iBt5oYIDpzCCAo8CAQEwgfqhgdCkgc0wgcoxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29m
'' SIG '' dCBBbWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOjBERTgtMkRDNS0zQ0E5MSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' oiUKAQEwCQYFKw4DAhoFAAMVAL/ADtOl4iFEl4rDQwV9
'' SIG '' yvaK1ko6oIHaMIHXpIHUMIHRMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBP
'' SIG '' cGVyYXRpb25zMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBF
'' SIG '' U046MjY2NS00QzNGLUM1REUxKzApBgNVBAMTIk1pY3Jv
'' SIG '' c29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xvY2swDQYJ
'' SIG '' KoZIhvcNAQEFBQACBQDfeWvBMCIYDzIwMTgxMDIzMDk0
'' SIG '' MzI5WhgPMjAxODEwMjQwOTQzMjlaMHYwPAYKKwYBBAGE
'' SIG '' WQoEATEuMCwwCgIFAN95a8ECAQAwCQIBAAIBCAIB/zAH
'' SIG '' AgEAAgIYmjAKAgUA33q9QQIBADA2BgorBgEEAYRZCgQC
'' SIG '' MSgwJjAMBgorBgEEAYRZCgMBoAowCAIBAAIDFuNgoQow
'' SIG '' CAIBAAIDB6EgMA0GCSqGSIb3DQEBBQUAA4IBAQCcd9pv
'' SIG '' EhECfVm0gwOwxfZeXti+R9SW58GrV9FB1gKrM5w4yIzG
'' SIG '' xiAz6y0TcS40JXhKceN2QHawORGLcPyJIobBxyzx36Tl
'' SIG '' xqg5nPI7vxDJ40DfLFyv3Q2pZYet6hI+QXpxRlkZQak9
'' SIG '' mVVR9yBQcor0/JykSrd7bgEvQLP2ooI2E/e2kDzBHAzV
'' SIG '' ReTRxDrZCh+6nlNL3pvDlFfRShjUxrMpTZmYCE31Kmkh
'' SIG '' Xln134h4aFE7LiAJkbiIjIJgyPQDC2hlg2Xd1uHm0CIy
'' SIG '' osbWiCFMH6nEk4WbggvPOM9NQKMOiCQlgG3NkBse983L
'' SIG '' Ui6cpqsOI7s7zF7xF3jvfyWAsbFRMYIC9TCCAvECAQEw
'' SIG '' gZMwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
'' SIG '' TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMA
'' SIG '' AADk2h823vdwLdgAAAAAAOQwDQYJYIZIAWUDBAIBBQCg
'' SIG '' ggEyMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAv
'' SIG '' BgkqhkiG9w0BCQQxIgQgV04aBcpvvYOMdD0CRZH2VKXT
'' SIG '' hGFOPZKWCH9DfzkKC3MwgeIGCyqGSIb3DQEJEAIMMYHS
'' SIG '' MIHPMIHMMIGxBBS/wA7TpeIhRJeKw0MFfcr2itZKOjCB
'' SIG '' mDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
'' SIG '' YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
'' SIG '' VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
'' SIG '' BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEw
'' SIG '' AhMzAAAA5NofNt73cC3YAAAAAADkMBYEFG0jRQysPyg6
'' SIG '' 1ejv6K+qCLq3ccuWMA0GCSqGSIb3DQEBCwUABIIBACAM
'' SIG '' qJ+TPU8ebBdekV2yavQEfSlugek1ohyDFUThQE+3mrEy
'' SIG '' lUmrpwfu70titzlOQIiTADoWCN2/0iZEn6XBkcE5e0Dh
'' SIG '' knGjHBAcUaMcDtceyawn02/ZmIqO4ioANjtu9ae9fRZ2
'' SIG '' grtAMcS9doTDbktCPAz+Neo95QSTXMiEoWAeHD7mPHOP
'' SIG '' Kyr/CpQIx6jfLNcXQGTbYdzGukwC8x5xDDDpSTKbf82w
'' SIG '' 1w3MWm/ZAH2BGgk2gsHVuAzrwApuWOnMB78YtuKSCL77
'' SIG '' nrolmdc/67GuyNknTDIqg9Q5DygqjrEALG+78R9uTC4z
'' SIG '' Q07fBx+4ZsPiI/WPjE6UMu+CJ2+KuCk=
'' SIG '' End signature block
