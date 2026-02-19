#ifndef _SYS_TIME_H
#define _SYS_TIME_H

#ifdef __cplusplus
extern "C" {
#endif

int gettimeofday(struct timeval* tv, void* tz);

#ifdef __cplusplus
}
#endif

#endif

