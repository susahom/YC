/*++

Copyright (c) Microsoft Corporation.  All rights reserved.

_WdfVersionBuild_

Module Name:

    WdfCommonBuffer.h

Abstract:

    WDF CommonBuffer support

Environment:

    Kernel mode only.

Notes:

Revision History:

--*/

#ifndef _WDFCOMMONBUFFER_1_9_H_
#define _WDFCOMMONBUFFER_1_9_H_



#if (NTDDI_VERSION >= NTDDI_WIN2K)



typedef struct _WDF_COMMON_BUFFER_CONFIG {
    //
    // Size of this structure in bytes
    //
    ULONG   Size;

    //
    // Alignment requirement of the buffer address
    //
    ULONG   AlignmentRequirement;

} WDF_COMMON_BUFFER_CONFIG, *PWDF_COMMON_BUFFER_CONFIG;

VOID
FORCEINLINE
WDF_COMMON_BUFFER_CONFIG_INIT(
    _Out_ PWDF_COMMON_BUFFER_CONFIG Config,
    _In_  ULONG  AlignmentRequirement
    )
{
    RtlZeroMemory(Config, sizeof(WDF_COMMON_BUFFER_CONFIG));

    Config->Size = sizeof(WDF_COMMON_BUFFER_CONFIG);
    Config->AlignmentRequirement = AlignmentRequirement;
}

//
// WDF Function: WdfCommonBufferCreate
//
typedef
_Must_inspect_result_
_IRQL_requires_max_(PASSIVE_LEVEL)
WDFAPI
NTSTATUS
(*PFN_WDFCOMMONBUFFERCREATE)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    WDFDMAENABLER DmaEnabler,
    _In_
    _When_(Length == 0, __drv_reportError(Length cannot be zero))
    size_t Length,
    _In_opt_
    PWDF_OBJECT_ATTRIBUTES Attributes,
    _Out_
    WDFCOMMONBUFFER* CommonBuffer
    );

_Must_inspect_result_
_IRQL_requires_max_(PASSIVE_LEVEL)
NTSTATUS
FORCEINLINE
WdfCommonBufferCreate(
    _In_
    WDFDMAENABLER DmaEnabler,
    _In_
    _When_(Length == 0, __drv_reportError(Length cannot be zero))
    size_t Length,
    _In_opt_
    PWDF_OBJECT_ATTRIBUTES Attributes,
    _Out_
    WDFCOMMONBUFFER* CommonBuffer
    )
{
    return ((PFN_WDFCOMMONBUFFERCREATE) WdfFunctions[WdfCommonBufferCreateTableIndex])(WdfDriverGlobals, DmaEnabler, Length, Attributes, CommonBuffer);
}

//
// WDF Function: WdfCommonBufferCreateWithConfig
//
typedef
_Must_inspect_result_
_IRQL_requires_max_(PASSIVE_LEVEL)
WDFAPI
NTSTATUS
(*PFN_WDFCOMMONBUFFERCREATEWITHCONFIG)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    WDFDMAENABLER DmaEnabler,
    _In_
    _When_(Length == 0, __drv_reportError(Length cannot be zero))
    size_t Length,
    _In_
    PWDF_COMMON_BUFFER_CONFIG Config,
    _In_opt_
    PWDF_OBJECT_ATTRIBUTES Attributes,
    _Out_
    WDFCOMMONBUFFER* CommonBuffer
    );

_Must_inspect_result_
_IRQL_requires_max_(PASSIVE_LEVEL)
NTSTATUS
FORCEINLINE
WdfCommonBufferCreateWithConfig(
    _In_
    WDFDMAENABLER DmaEnabler,
    _In_
    _When_(Length == 0, __drv_reportError(Length cannot be zero))
    size_t Length,
    _In_
    PWDF_COMMON_BUFFER_CONFIG Config,
    _In_opt_
    PWDF_OBJECT_ATTRIBUTES Attributes,
    _Out_
    WDFCOMMONBUFFER* CommonBuffer
    )
{
    return ((PFN_WDFCOMMONBUFFERCREATEWITHCONFIG) WdfFunctions[WdfCommonBufferCreateWithConfigTableIndex])(WdfDriverGlobals, DmaEnabler, Length, Config, Attributes, CommonBuffer);
}

//
// WDF Function: WdfCommonBufferGetAlignedVirtualAddress
//
typedef
_IRQL_requires_max_(DISPATCH_LEVEL)
WDFAPI
PVOID
(*PFN_WDFCOMMONBUFFERGETALIGNEDVIRTUALADDRESS)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    WDFCOMMONBUFFER CommonBuffer
    );

_IRQL_requires_max_(DISPATCH_LEVEL)
PVOID
FORCEINLINE
WdfCommonBufferGetAlignedVirtualAddress(
    _In_
    WDFCOMMONBUFFER CommonBuffer
    )
{
    return ((PFN_WDFCOMMONBUFFERGETALIGNEDVIRTUALADDRESS) WdfFunctions[WdfCommonBufferGetAlignedVirtualAddressTableIndex])(WdfDriverGlobals, CommonBuffer);
}

//
// WDF Function: WdfCommonBufferGetAlignedLogicalAddress
//
typedef
_IRQL_requires_max_(DISPATCH_LEVEL)
WDFAPI
PHYSICAL_ADDRESS
(*PFN_WDFCOMMONBUFFERGETALIGNEDLOGICALADDRESS)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    WDFCOMMONBUFFER CommonBuffer
    );

_IRQL_requires_max_(DISPATCH_LEVEL)
PHYSICAL_ADDRESS
FORCEINLINE
WdfCommonBufferGetAlignedLogicalAddress(
    _In_
    WDFCOMMONBUFFER CommonBuffer
    )
{
    return ((PFN_WDFCOMMONBUFFERGETALIGNEDLOGICALADDRESS) WdfFunctions[WdfCommonBufferGetAlignedLogicalAddressTableIndex])(WdfDriverGlobals, CommonBuffer);
}

//
// WDF Function: WdfCommonBufferGetLength
//
typedef
_IRQL_requires_max_(DISPATCH_LEVEL)
WDFAPI
size_t
(*PFN_WDFCOMMONBUFFERGETLENGTH)(
    _In_
    PWDF_DRIVER_GLOBALS DriverGlobals,
    _In_
    WDFCOMMONBUFFER CommonBuffer
    );

_IRQL_requires_max_(DISPATCH_LEVEL)
size_t
FORCEINLINE
WdfCommonBufferGetLength(
    _In_
    WDFCOMMONBUFFER CommonBuffer
    )
{
    return ((PFN_WDFCOMMONBUFFERGETLENGTH) WdfFunctions[WdfCommonBufferGetLengthTableIndex])(WdfDriverGlobals, CommonBuffer);
}



#endif // (NTDDI_VERSION >= NTDDI_WIN2K)


#endif // _WDFCOMMONBUFFER_1_9_H_
