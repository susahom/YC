/*++

Copyright (c) Microsoft Corporation. All rights reserved.

Module Name:

    UcxGlobals.h

Abstract:

    UCX global definitions.

Environment:

    Kernel-mode only.

--*/

//
// NOTE: This header is generated by stubwork.  Please make any 
//       modifications to the corresponding template files 
//       (.x or .y) and use stubwork to regenerate the header
//

#ifndef _UCXGLOBALS_H_
#define _UCXGLOBALS_H_

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



typedef struct _UCX_DRIVER_GLOBALS {

    //
    // Size in bytes of this structure
    //
    ULONG                  Size;

    //
    // Client's WdfDriverGlobals
    //
    PWDF_DRIVER_GLOBALS    WdfDriverGlobals;

} UCX_DRIVER_GLOBALS, *PUCX_DRIVER_GLOBALS;

//
// The UCX_DRIVER_GLOBALS struct used to be named UCX_GLOBALS in a previous version
// of this header. Typedef that name to prevent breaking compilation of any existing clients
// that may have been using that name.
//

typedef UCX_DRIVER_GLOBALS UCX_GLOBALS;
typedef PUCX_DRIVER_GLOBALS PUCX_GLOBALS;





WDF_EXTERN_C_END

#endif // _UCXGLOBALS_H_


