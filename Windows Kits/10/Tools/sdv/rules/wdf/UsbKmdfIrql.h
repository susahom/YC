#ifndef SDV_PRE_RUN
#include "..\..\sdv-pre-results.h"
#if (isusbdriver_SDV_RESULT == SDV_FAILED && (manualqueuedispatching_SDV_RESULT == SDV_PASSED||manualqueuedispatching_SDV_RESULT == SDV_NA))
	   #define SDV_HARNESS SDV_WDF_IRQL_SEMIFLAT_HARNESS
		#define SDV_WDF_IRQL_SEMI_FLAT_HARNESS_MODIFIER_NO_MALLOC_sdv_WDF_IO_QUEUE_CONFIG_INIT
		#define SDV_WDF_IRQL_SEMI_FLAT_HARNESS_MODIFIER_NO_MALLOC_sdv_WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE
		#define NO_fun_WDF_OBJECT_CONTEXT_CLEANUP
#else
  #pragma message("SDV_NA")  
#endif
#else
#pragma message("isusbdriver==SDV_FAILED")
#pragma message("manualqueuedispatching==SDV_PASSED,SDV_NA")
#endif
