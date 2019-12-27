/*++

Copyright (c) Microsoft Corporation. All rights reserved.

Module Name:

    Wdfverifier.h

Environment:

    user mode

NOTE: This header is generated by stubwork.

      To modify contents, add or remove <shared> or <umdf>
      tags in the corresponding .x and .y template files.

--*/

#pragma once

#ifndef WDF_EXTERN_C
  #ifdef __cplusplus
    #define WDF_EXTERN_C       extern "C"
    #define WDF_EXTERN_C_START extern "C" {
    #define WDF_EXTERN_C_END   }
  #else
    #define WDF_EXTERN_C
    #define WDF_EXTERN_C_START
    #define WDF_EXTERN_C_END
  #endif
#endif

WDF_EXTERN_C_START

//
// WDF Function: WdfVerifierDbgBreakPoint
//
typedef
WDFAPI
VOID
(*PFN_WDFVERIFIERDBGBREAKPOINT)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals
    );

VOID
FORCEINLINE
WdfVerifierDbgBreakPoint(
    )
{
    ((PFN_WDFVERIFIERDBGBREAKPOINT) WdfFunctions[WdfVerifierDbgBreakPointTableIndex])(WdfDriverGlobals);
}


//
// WDF Function: WdfVerifierKeBugCheck
//
typedef
WDFAPI
VOID
(*PFN_WDFVERIFIERKEBUGCHECK)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    ULONG BugCheckCode,
    _In_
    ULONG_PTR BugCheckParameter1,
    _In_
    ULONG_PTR BugCheckParameter2,
    _In_
    ULONG_PTR BugCheckParameter3,
    _In_
    ULONG_PTR BugCheckParameter4
    );

VOID
FORCEINLINE
WdfVerifierKeBugCheck(
    _In_
    ULONG BugCheckCode,
    _In_
    ULONG_PTR BugCheckParameter1,
    _In_
    ULONG_PTR BugCheckParameter2,
    _In_
    ULONG_PTR BugCheckParameter3,
    _In_
    ULONG_PTR BugCheckParameter4
    )
{
    ((PFN_WDFVERIFIERKEBUGCHECK) WdfFunctions[WdfVerifierKeBugCheckTableIndex])(WdfDriverGlobals, BugCheckCode, BugCheckParameter1, BugCheckParameter2, BugCheckParameter3, BugCheckParameter4);
}


//
// WDF Function: WdfGetTriageInfo
//
typedef
WDFAPI
PVOID
(*PFN_WDFGETTRIAGEINFO)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals
    );

PVOID
FORCEINLINE
WdfGetTriageInfo(
    )
{
    return ((PFN_WDFGETTRIAGEINFO) WdfFunctions[WdfGetTriageInfoTableIndex])(WdfDriverGlobals);
}

WDF_EXTERN_C_END

