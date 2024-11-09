/* SPDX-License-Identifier: BSD-2-Clause */
#ifndef COMMON_H_
#define COMMON_H_

#define __weak __attribute__((weak))
#define __optimize __attribute__((optimize(2)))

#ifdef __cplusplus
extern "C" {
#endif

extern int handle_args(int argc, char **argv);

#ifdef __cplusplus
}
#endif

#endif /* COMMON_H_ */
