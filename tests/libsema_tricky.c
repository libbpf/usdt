// SPDX-License-Identifier: BSD-2-Clause
#include <stdio.h>
#include "common.h"
#include "../usdt.h"

#ifndef SHARED
USDT_DECLARE_SEMA(exec_sema1); /* defined in the executable */
USDT_DECLARE_SEMA(exec_sema2); /* defined in the executable */
#endif

USDT_DEFINE_SEMA(lib_sema1); /* defined in the library */
USDT_DEFINE_SEMA(lib_sema2); /* defined in the library */

void __optimize lib_func(void)
{
#ifndef SHARED
	/* library-side USDTs that use executable-defined explicit semaphore */
	USDT_WITH_EXPLICIT_SEMA(exec_sema1, test, exec_sema_lib_side1);
	USDT_WITH_EXPLICIT_SEMA(exec_sema2, test, exec_sema_lib_side2);
	printf("lib: exec_imp_sema1 is %s.\n", USDT_IS_ACTIVE(test, exec_imp_sema1) ? "ACTIVE" : "INACTIVE");
	printf("lib: exec_imp_sema2 is %s.\n", USDT_IS_ACTIVE(test, exec_imp_sema2) ? "ACTIVE" : "INACTIVE");
	printf("lib: exec_exp_sema1 is %s.\n", USDT_SEMA_IS_ACTIVE(exec_sema1) ? "ACTIVE" : "INACTIVE");
	printf("lib: exec_exp_sema2 is %s.\n", USDT_SEMA_IS_ACTIVE(exec_sema2) ? "ACTIVE" : "INACTIVE");
#endif
	USDT_WITH_SEMA(test, lib_imp_sema1);
	USDT_WITH_SEMA(test, lib_imp_sema2);
	printf("lib: lib_imp_sema1 is %s.\n", USDT_IS_ACTIVE(test, lib_imp_sema1) ? "ACTIVE" : "INACTIVE");
	printf("lib: lib_imp_sema2 is %s.\n", USDT_IS_ACTIVE(test, lib_imp_sema2) ? "ACTIVE" : "INACTIVE");

	USDT_WITH_EXPLICIT_SEMA(lib_sema1, test, lib_exp_sema1);
	USDT_WITH_EXPLICIT_SEMA(lib_sema2, test, lib_exp_sema2);
	printf("lib: lib_exp_sema1 is %s.\n", USDT_SEMA_IS_ACTIVE(lib_sema1) ? "ACTIVE" : "INACTIVE");
	printf("lib: lib_exp_sema2 is %s.\n", USDT_SEMA_IS_ACTIVE(lib_sema2) ? "ACTIVE" : "INACTIVE");
}
