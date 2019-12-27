// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//
// Copyright (c) Microsoft Corporation. All rights reserved.


/****************************************************************************
						Microsoft RPC
           
                       Dynept Example

    FILE:       dyneptc.c

    USAGE:      dyneptc  -n network_address
                         -p protocol_sequence
                         -a server principal name
                         -o options
                         -s string_displayed_on_server

    PURPOSE:    Client side of RPC distributed application

    FUNCTIONS:  main() - binds to server and calls remote procedure

    COMMENTS:   This version of the distributed application that
                prints "What a dynamic, world" (or other string) on
                the server features a client that manages its connection
                to the server. It uses the binding handle dynept_IfHandle,
                defined in the file dynept.h.

****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "dynept.h"    // header file generated by MIDL compiler
#include "spn.h"

void Usage(char * pszProgramName)
{
    fprintf_s(stderr, "Usage:  %s\n", pszProgramName);
    fprintf_s(stderr, " -p protocol_sequence\n");
    fprintf_s(stderr, " -n network_address\n");
    fprintf_s(stderr, " -a server principal name\n");	
    fprintf_s(stderr, " -o options\n");
    fprintf_s(stderr, " -s string\n");
    exit(1);
}

void __cdecl main(int argc, char **argv)
{
    RPC_STATUS status;
    unsigned char * pszUuid             = NULL;
    unsigned char * pszProtocolSequence = "ncacn_ip_tcp";
    unsigned char * pszSpn              = NULL;	
    unsigned char * pszNetworkAddress   = NULL;
    unsigned char * pszOptions          = NULL;
    unsigned char * pszStringBinding    = NULL;
    unsigned char * pszString           = "What a dynamic world";
    unsigned long ulCode;
	RPC_SECURITY_QOS SecQos;
    int i;

    /* allow the user to override settings with command line switches */
    for (i = 1; i < argc; i++) {
        if ((*argv[i] == '-') || (*argv[i] == '/')) {
            switch (tolower(*(argv[i]+1))) {
            case 'p':  // protocol sequence
                pszProtocolSequence = argv[++i];
                break;
            case 'n':  // network address
                pszNetworkAddress = argv[++i];
                break;
            case 'a':  
                pszSpn = argv[++i];
                break;
            case 'o':
                pszOptions = argv[++i];
                break;
            case 's':
                pszString = argv[++i];
                break;
            case 'h':
            case '?':
            default:
                Usage(argv[0]);
            }
        }
        else
            Usage(argv[0]);
    }

    /* Use a convenience function to concatenate the elements of */
    /* the string binding into the proper sequence.              */
    status = RpcStringBindingCompose(pszUuid,
                                     pszProtocolSequence,
                                     pszNetworkAddress,
                                     NULL,
                                     pszOptions,
                                     &pszStringBinding);
    printf_s("RpcStringBindingCompose returned 0x%x\n", status);
    printf_s("pszStringBinding = %s\n", pszStringBinding);
    if (status) {
        exit(status);
    }

    /* Set the binding handle that will be used to bind to the server. */
    status = RpcBindingFromStringBinding(pszStringBinding,
                                         &dynept_IfHandle);
    printf_s("RpcBindingFromStringBinding returned 0x%x\n", status);
    if (status) {
        exit(status);
    }
	
    /* User did not specify spn, construct one. */
    if (pszSpn == NULL) {
        MakeSpn(&pszSpn);
    }

    /* Set the quality of service on the binding handle */
    SecQos.Version = RPC_C_SECURITY_QOS_VERSION_1;
    SecQos.Capabilities = RPC_C_QOS_CAPABILITIES_MUTUAL_AUTH;
    SecQos.IdentityTracking = RPC_C_QOS_IDENTITY_DYNAMIC;
    SecQos.ImpersonationType = RPC_C_IMP_LEVEL_IDENTIFY;

    /* Set the security provider on binding handle */
    status = RpcBindingSetAuthInfoEx(dynept_IfHandle,
                                     pszSpn,
                                     RPC_C_AUTHN_LEVEL_PKT_PRIVACY,
                                     RPC_C_AUTHN_GSS_NEGOTIATE,
                                     NULL,
                                     RPC_C_AUTHZ_NONE,
                                     &SecQos);
	
    printf_s("RpcBindingSetAuthInfoEx returned 0x%x\n", status);
    if (status) {
        exit(status);
    }	

    printf_s("Calling the remote procedure 'HelloProc'\n");
    printf_s("Print the string '%s' on the server\n", pszString);

    RpcTryExcept {
        HelloProc(dynept_IfHandle,pszString);  // make call with user message
        printf_s("Calling the remote procedure 'Shutdown'\n");
        Shutdown(dynept_IfHandle);  // shut down the server side
    }
    RpcExcept(( ( (RpcExceptionCode() != STATUS_ACCESS_VIOLATION) &&
                   (RpcExceptionCode() != STATUS_DATATYPE_MISALIGNMENT) &&
                   (RpcExceptionCode() != STATUS_PRIVILEGED_INSTRUCTION) &&
                   (RpcExceptionCode() != STATUS_BREAKPOINT) &&
                   (RpcExceptionCode() != STATUS_STACK_OVERFLOW) &&
                   (RpcExceptionCode() != STATUS_IN_PAGE_ERROR) &&
                   (RpcExceptionCode() != STATUS_GUARD_PAGE_VIOLATION)
                    )
                    ? EXCEPTION_EXECUTE_HANDLER : EXCEPTION_CONTINUE_SEARCH )) {
        ulCode = RpcExceptionCode();
        printf_s("Runtime reported exception 0x%lx = %ld\n", ulCode, ulCode);

	}
    RpcEndExcept

    /*  The calls to the remote procedures are complete. */
    /*  Free the string and the binding handle           */
    status = RpcStringFree(&pszStringBinding);  // remote calls done; unbind
    printf_s("RpcStringFree returned 0x%x\n", status);
    if (status) {
        exit(status);
    }

    status = RpcBindingFree(&dynept_IfHandle);  // remote calls done; unbind
    printf_s("RpcBindingFree returned 0x%x\n", status);
    if (status) {
        exit(status);
    }

    exit(0);

}  // end main()


/*********************************************************************/
/*                 MIDL allocate and free                            */
/*********************************************************************/

void  __RPC_FAR * __RPC_USER midl_user_allocate(size_t len)
{
    return(malloc(len));
}

void __RPC_USER midl_user_free(void __RPC_FAR * ptr)
{
    free(ptr);
}

/* end file dyneptc.c */
