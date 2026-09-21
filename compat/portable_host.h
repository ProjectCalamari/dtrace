#ifndef DTRACE_COMPAT_PORTABLE_HOST_H
#define DTRACE_COMPAT_PORTABLE_HOST_H

#if defined(DTRACE_PORTABLE_HOST)
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define __LITTLE_ENDIAN__ 1
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define __BIG_ENDIAN__ 1
#endif

#ifndef __unused
#define __unused __attribute__((unused))
#endif

#ifndef __printflike
#define __printflike(format_index, first_arg) \
	__attribute__((format(printf, format_index, first_arg)))
#endif

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif
#endif

#endif
