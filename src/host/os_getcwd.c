/**
 * \file   os_getcwd.c
 * \brief  Retrieve the current working directory.
 * \author Copyright (c) 2002-2008 Jason Perkins and the Premake project
 */

#include "premake.h"

int os_getcwd(lua_State* L)
{
	char buffer[0x4000];
	char* ch;

#if PLATFORM_WINDOWS
	GetCurrentDirectory(0x4000, buffer);
#else
	getcwd(buffer, 0x4000);
#endif

	/* convert to platform-neutral directory separators */
	for (ch = buffer; *ch != '\0'; ++ch)
	{
		if (*ch == '\\') *ch = '/';
	}

	lua_pushstring(L, buffer);
	return 1;
}


