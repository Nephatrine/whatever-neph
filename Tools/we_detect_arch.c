/* ARM */
#if defined(__arm__) || defined(__TARGET_ARCH_ARM) || defined(_M_ARM) || defined(__arm64__)
#	if defined(__ARM64_ARCH_8__)
#		error CMAKE_ARCH arm64_v8
#	elif defined(__arm64__)
#		error CMAKE_ARCH arm64
#	elif defined(__ARM_ARCH_7__) \
		|| defined(__ARM_ARCH_7A__) \
		|| defined(__ARM_ARCH_7R__) \
		|| defined(__ARM_ARCH_7M__) \
		|| defined(__ARM_ARCH_7S__) \
		|| defined(_ARM_ARCH_7) \
		|| (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 7) \
		|| (defined(_M_ARM) && _M_ARM-0 >= 7)
#		error CMAKE_ARCH arm_v7
#	elif defined(__ARM_ARCH_6__) \
		|| defined(__ARM_ARCH_6J__) \
		|| defined(__ARM_ARCH_6T2__) \
        || defined(__ARM_ARCH_6Z__) \
        || defined(__ARM_ARCH_6K__) \
        || defined(__ARM_ARCH_6ZK__) \
        || defined(__ARM_ARCH_6M__) \
		|| (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 6) \
		|| (defined(_M_ARM) && _M_ARM-0 >= 6)
#		error CMAKE_ARCH arm_v6
#	elif defined(__ARM_ARCH_5TEJ__) \
		|| defined(__ARM_ARCH_5TE__) \
		|| (defined(__TARGET_ARCH_ARM) && __TARGET_ARCH_ARM-0 >= 5) \
		|| (defined(_M_ARM) && _M_ARM-0 >= 5)
#		error CMAKE_ARCH arm_v5
#	else
#		error CMAKE_ARCH arm
#	endif
/* AMD64 (x86_64) */
#elif defined(__x86_64) || defined(__x86_64__) || defined(__amd64) || defined(_M_X64)
#	error CMAKE_ARCH x86_64
/* x86 (IA-32) */
#elif defined(__i386) || defined(__i386__) || defined(_M_IX86)
#	if defined(__i686__) || defined(__athlon__) || defined(__SSE__)
#   	error CMAKE_ARCH i686
#	elif defined(__i586__) || defined(__k6__)
#		error CMAKE_ARCH i586
#	elif defined(__i486__)
#		error CMAKE_ARCH i486
#	elif defined(__i386) || defined(__i386__)
#   	error CMAKE_ARCH i386
#	else
#		error CMAKE_ARCH x86
#	endif
/* Itanium (IA-64) */
#elif defined(__ia64) || defined(__ia64__) || defined(_M_IA64)
#	error CMAKE_ARCH ia64
/* PPC */
#elif defined(__ppc__) || defined(__ppc) || defined(__powerpc__) \
	|| defined(_ARCH_COM) || defined(_ARCH_PWR) || defined(_ARCH_PPC) \
	|| defined(_M_MPPC) || defined(_M_PPC)
#	if defined(__ppc64__) || defined(__powerpc64__) || defined(__64BIT__)
#		error CMAKE_ARCH ppc64
#	else
#		error CMAKE_ARCH ppc
#	endif
/* SPARC */
#elif defined(__sparc__)
#	error CMAKE_ARCH sparc
#else
#	error CMAKE_ARCH unknown
#endif

