/**********************************************************************
 * Premake - gnu_cs.c
 * The GNU C# makefile target
 *
 * Copyright (c) 2002-2005 Jason Perkins and the Premake project
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License in the file LICENSE.txt for details.
 **********************************************************************/

#include <stdio.h>
#include <string.h>
#include "premake.h"
#include "gnu.h"
#include "os.h"

static char buffer[8192];

static const char* assignCodeFiles(const char* name);
static const char* assignEmbeddedFiles(const char* name);
static const char* assignContentFiles(const char* name);

static const char* listCodeFiles(const char* name);
static const char* listEmbeddedFiles(const char* name);
static const char* listLinkedFiles(const char* name);
static const char* listContentFiles(const char* name);
static const char* listContentTargets(const char* name);
static const char* listContentRules(const char* name);
static const char* listCopyLocalFiles(const char* name);
static const char* listCopyLocalRules(const char* name);

static const char* listNonSiblingRefs(const char* name);
static const char* listSiblingRefs(const char* name);
static const char* listReferenceDeps(const char* name);
static const char* listResourceBuildSteps(const char* name);


int gnu_cs()
{
	const char* kind;
	const char* csc;
	const char* resgen;
	int i;

	/* Figure out what I'm building */
	prj_select_config(0);
	kind = prj_get_kind();
	if (prj_is_kind("dll") || prj_is_kind("aspnet"))
	{
		kind = "library";
	}
	else if (prj_is_kind("winexe") || prj_is_kind("exe"))
	{
	}
	else
	{
		printf("** Error: unknown package type '%s'\n", kind);
		return 0;
	}

	/* Figure out what I'm building it with */
	if (g_dotnet == NULL)
	{
		if (os_is("windows"))
		{
			csc = "csc";
			resgen = "resgen";
		}
		else
		{
			csc = "mcs";
			resgen = "resgen";
		}
	}
	else if (matches(g_dotnet, "ms"))
	{
		csc = "csc";
		resgen = "resgen";
	}
	else if (matches(g_dotnet, "pnet"))
	{
		csc = "cscc";
		resgen = "resgen";
	}
	else if (matches(g_dotnet, "mono"))
	{
		csc = "mcs";
		resgen = "resgen";
	}
	else if (matches(g_dotnet, "mono2"))
	{
		csc = "gmcs";
		resgen = "resgen";
	}
	else
	{
		printf("** Error: unknown .NET runtime '%s'\n", g_dotnet);
		return 0;
	}

	/* Open package makefile and write the header */
	if (gnu_pkgOwnsPath())
		strcpy(buffer, path_join(prj_get_pkgpath(), "Makefile", ""));
	else
		strcpy(buffer, path_join(prj_get_pkgpath(), prj_get_pkgname(), DOT_MAKE));
	io_openfile(buffer);

	io_print("# C# ");
	if (prj_is_kind("exe"))
		io_print("Console Executable");
	else if (prj_is_kind("winexe"))
		io_print("Windowed Executable");
	else if (prj_is_kind("dll"))
		io_print("Shared Library");
	else if (prj_is_kind("lib"))
		io_print("Static Library");
	else if (prj_is_kind("aspnet"))
		io_print("ASP.NET");

	io_print(" Makefile autogenerated by premake\n");
	io_print("# Don't edit this file! Instead edit `premake.lua` then rerun `make`\n\n");

	/* Set a default configuration */
	prj_select_config(0);
	io_print("ifndef CONFIG\n");
	io_print("  CONFIG=%s\n", prj_get_cfgname());
	io_print("endif\n\n");

	/* Specify the build tools */
	io_print("CSC := %s\n", csc);
	io_print("RESGEN := %s\n", resgen);
	io_print("\n");

	/* Where to put compiled resources */
	io_print("OBJDIR := %s\n\n", prj_get_objdir());

	/* Process the build configurations */
	for (i = 0; i < prj_get_numconfigs(); ++i)
	{
		prj_select_config(i);

		io_print("ifeq ($(CONFIG),%s)\n", prj_get_cfgname());
		io_print("  BINDIR := %s\n", prj_get_bindir());
		io_print("  OUTDIR := %s\n", prj_get_outdir());

		io_print("  FLAGS += /t:%s", kind);
		if (!prj_has_flag("no-symbols"))
		{
			io_print(" /debug");
		}
		if (prj_has_flag("optimize") || prj_has_flag("optimize-size") || prj_has_flag("optimize-speed"))
		{
			/* Mono doesn't support the optimize flag */
			if (!matches(csc, "mcs"))
				io_print(" /optimize");
		}
		if (prj_has_flag("unsafe"))
		{
			io_print(" /unsafe");
		}
		if (prj_has_flag("fatal-warnings"))
		{
			io_print(" /warnaserror");
		}

		print_list(prj_get_defines(), " /d:", "", "", NULL);

		/* VS.NET doesn't allow per-config link paths */
		prj_select_config(0);
		print_list(prj_get_libpaths(), " /lib:\"", "\"", "", NULL);
		print_list(prj_get_links(), " /r:", "", "", listNonSiblingRefs);
		prj_select_config(i);
		print_list(prj_get_links(), " /r:", "", "", listSiblingRefs);
		io_print("\n");

		/* List any sibling packages as dependencies for make */
		prj_select_config(i);
		io_print("  DEPS :=");
		print_list(prj_get_links(), " ", " ", "", listReferenceDeps);
		io_print("\n");

		/* VS.NET doesn't allow per-config target names */
		prj_select_config(0);
		io_print("  TARGET := %s\n", path_getname(prj_get_target()));
		io_print("endif\n\n");
	}

	/* Sort out the files by build action...start by assigning build actions
	 * to well-known file extensions...these don't write anything to the file */
	print_list(prj_get_files(), "", "", "", assignCodeFiles);
	print_list(prj_get_files(), "", "", "", assignEmbeddedFiles);
	print_list(prj_get_files(), "", "", "", assignContentFiles);

	/* Sort out the files by build action */
	io_print("SOURCES := \\\n");
	print_list(prj_get_files(), "\t", " \\\n", "", listCodeFiles);
	io_print("\n");

	io_print("EMBEDDEDFILES := \\\n");
	print_list(prj_get_files(), "\t", " \\\n", "", listEmbeddedFiles);
	io_print("\n");

	io_print("EMBEDDEDCOMMAND := \\\n");
	print_list(prj_get_files(), "\t/resource:", " \\\n", "", listEmbeddedFiles);
	io_print("\n");
	
	io_print("LINKEDFILES := \\\n");
	print_list(prj_get_files(), "\t", " \\\n", "", listLinkedFiles);
	io_print("\n");

	io_print("LINKEDCOMMAND := \\\n");
	print_list(prj_get_files(), "\t/linkresource:", " \\\n", "", listLinkedFiles);
	io_print("\n");

	io_print("CONTENTFILES := \\\n");
	print_list(prj_get_files(), "\t", " \\\n", "", listContentFiles);
	io_print("\n");

	io_print("COPYLOCALFILES := \\\n");
	print_list(prj_get_links(), "\t", " \\\n", "", listCopyLocalFiles);
	io_print("\n");

	io_print("COMPILECOMMAND := $(SOURCES) $(EMBEDDEDCOMMAND) $(LINKEDCOMMAND)\n\n");

	io_print("CMD := $(subst \\,\\\\,$(ComSpec)$(COMSPEC))\n");
	io_print("ifeq (,$(CMD))\n");
	io_print("  CMD_MKOUTDIR := mkdir -p $(OUTDIR)\n");
	io_print("else\n");
	io_print("  CMD_MKOUTDIR := $(CMD) /c if not exist $(subst /,\\\\,$(OUTDIR)) mkdir $(subst /,\\\\,$(OUTDIR))\n");
	io_print("endif\n");
	io_print("\n");

	/* Build targets: add all content files as dependencies so the copy
	 * rules will get fired when they change */
	io_print(".PHONY: clean\n\n");
	io_print("all: \\\n");
	io_print("\t$(OUTDIR)/$(TARGET) \\\n");
	print_list(prj_get_files(), "\t", " \\\n", "", listContentTargets);
	io_print("\n");

	/* The main build target */
	io_print("$(OUTDIR)/$(TARGET): $(SOURCES) $(EMBEDDEDFILES) $(LINKEDFILES) $(COPYLOCALFILES) $(DEPS)\n");
	io_print("\t-@$(CMD_MKOUTDIR)\n");
	io_print("\t@$(CSC) /nologo /out:$@ /lib:$(BINDIR) $(FLAGS) $(COMPILECOMMAND)\n\n");

	/* Write rules to copy content files */
	print_list(prj_get_files(), "", "", "", listContentRules);

	/* Write rules to copy local assemblies */
	print_list(prj_get_links(), "", "", "", listCopyLocalRules);

	/* The clean target */
	io_print("clean:\n");
	io_print("\t@echo Cleaning %s\n", prj_get_pkgname());
	io_print("\t-@rm -f $(OUTDIR)/$(TARGET)\n");
	io_print("\t-@rm -fR $(OBJDIR)\n");
	print_list(prj_get_files(), "\t-@rm -f ", "\n", "", listContentTargets);
	io_print("\n");

	/* Resource build targets */
	print_list(prj_get_files(), "", "", "", listResourceBuildSteps);

	io_closefile();
	return 1;
}


/************************************************************************
 * Visual Studio .NET automatically adds some extra information
 * to resource names. Simulate that here.
 ***********************************************************************/

static const char* makeVsNetCompatName(const char* name)
{
	char* ptr;

	if (matches(path_getextension(name), ".resx"))
	{
		/* The compiled .resources file goes into objdir */
		strcpy(buffer, prj_get_objdir());
		strcat(buffer, "/");

		/* Prepend the default namespace (slashes will get translated below) */
		strcat(buffer, path_getbasename(prj_get_target()));
		strcat(buffer, ".");

		/* ...followed by the path to the file */
		if (!matches(path_getdir(name), ""))
		{
			strcat(buffer, path_getdir(name));
			strcat(buffer, ".");
		}

		/* ...finish up with the file name */
		strcat(buffer, path_getbasename(name));
		strcat(buffer, ".resources");

		/* Convert any slashes in the name to dots */
		for (ptr = buffer + strlen(prj_get_objdir()) + 1; *ptr != '\0'; ++ptr)
		{
			if (*ptr == '/')
				*ptr = '.';
		}

		return buffer;
	}
	else
	{
		return name;
	}
}


/************************************************************************
 * Assign default build actions to files without one
 ***********************************************************************/

static const char* assignCodeFiles(const char* name)
{
	const char* ext = path_getextension(name);
	prj_select_file(name);
	if (prj_is_buildaction(NULL) && matches(ext, ".cs"))
		prj_set_buildaction("Code");
	return NULL;
}

static const char* assignEmbeddedFiles(const char* name)
{
	const char* ext = path_getextension(name);
	prj_select_file(name);
	if (prj_is_buildaction(NULL) && matches(ext, ".resx"))
		prj_set_buildaction("EmbeddedResource");
	return NULL;
}

static const char* assignContentFiles(const char* name)
{
	const char* ext = path_getextension(name);
	prj_select_file(name);
	if (prj_is_buildaction(NULL) && (matches(ext, ".asax") || matches(ext, ".aspx")))
		prj_set_buildaction("Content");
	return NULL;
}


/************************************************************************
 * Checks to see if a given assembly exists on one of the listed link
 * paths. If so, returns the relative path to the assembly.
 ***********************************************************************/

static const char* findLocalAssembly(const char* name)
{
	const char** paths;
	const char*  result = NULL;

	/* Lib paths are relative to package directory. Have to make package
	 * directory current for io_fileexists() to work */
	strcpy(buffer, io_getcwd());
	io_chdir(prj_get_pkgpath());

	paths = prj_get_libpaths();
	while (*paths != NULL)
	{
		const char* path = path_join(*paths, name, "dll");
		if (io_fileexists(path))
		{
			result = path;
			break;
		}
		++paths;
	}

	io_chdir(buffer);
	return result;
}


/************************************************************************
 * Returns lists of files for each build action
 ***********************************************************************/

static const char* listCodeFiles(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("Code"))
	{
		/* Csc needs backslashes, which GNU make doesn't like */
		const char* src = path_translate(name, NULL);
		char* dst = buffer;
		while (*src)
		{
			if (*src == '\\')
			{
				*(dst++) = '\\';
				*(dst++) = '\\';
			}
			else
			{
				*(dst++) = *src;
			}
			src++;
		}
		*dst ='\0';
		return buffer;
	}
	else
	{
		return NULL;
	}
}

static const char* listEmbeddedFiles(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("EmbeddedResource"))
		return makeVsNetCompatName(name);
	else
		return NULL;
}

static const char* listLinkedFiles(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("LinkedResource"))
		return makeVsNetCompatName(name);
	else
		return NULL;
}

static const char* listContentFiles(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("Content"))
		return name;
	else
		return NULL;
}

static const char* listCopyLocalFiles(const char* name)
{
	const char* path = findLocalAssembly(name);
	if (path != NULL)
	{
		sprintf(buffer, "$(BINDIR)/%s.dll", name);
		return buffer;
	}
	return NULL;
}


/************************************************************************
 * Checks to see if a reference is to a sibling package. If so, 
 * returns the binary target name of the package.
 ***********************************************************************/

static const char* listNonSiblingRefs(const char* name)
{
	int i = prj_find_package(name);
	if (i < 0)
	{
		return path_join("", name, "dll");
	}
	return NULL;
}


static const char* listSiblingRefs(const char* name)
{
	int i = prj_find_package(name);
	if (i >= 0)
	{
		if (matches(prj_get_language_for(i), "c#"))
		{
			return prj_get_target_for(i);
		}
	}
	return NULL;
}


/************************************************************************
 * This is called by the code that builds the list of dependencies for 
 * the link step. It looks for sibling projects, and then returns the 
 * full path to that target's output. So if an executable package 
 * depends on a library package, the library filename will be listed 
 * as a dependency
 ***********************************************************************/

static const char* listReferenceDeps(const char* name)
{
	int i = prj_find_package(name);
	if (i >= 0)
	{
		return prj_get_target_for(i);
	}

	return NULL;
}


/************************************************************************
 * Write out content files as make dependencies
 ***********************************************************************/

static const char* listContentTargets(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("LinkedResource") || prj_is_buildaction("Content"))
	{
		sprintf(buffer, "$(BINDIR)/%s", path_getname(name));
		return buffer;
	}
	else
	{
		return NULL;
	}
}


/************************************************************************
 * Write out rules to move files to output directory
 ***********************************************************************/

static const char* listContentRules(const char* name)
{
	prj_select_file(name);
	if (prj_is_buildaction("LinkedResource") || prj_is_buildaction("Content"))
	{
		sprintf(buffer, "$(BINDIR)/%s: %s\n\t-@cp -fR $^ $@\n\n", path_getname(name), name);
		return buffer;
	}
	return NULL;
}

static const char* listCopyLocalRules(const char* name)
{
	const char* path = findLocalAssembly(name);
	if (path != NULL)
	{
		sprintf(buffer, "$(BINDIR)/%s.dll: %s\n\t@echo Copying %s.dll\n\t-@cp $^ $@\n\n", name, path, name);
		return buffer;
	}
	return NULL;
}



/************************************************************************
 * Write out resource compilation rules
 ***********************************************************************/

static const char* listResourceBuildSteps(const char* name)
{
	if (matches(path_getextension(name), ".resx"))
	{
		makeVsNetCompatName(name);
		strcat(buffer, ": ");
		strcat(buffer, name);
		strcat(buffer, "\n\t-@if [ ! -d $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi");
		strcat(buffer, "\n\t$(RESGEN) $^ $@\n\n");
		return buffer;
	}
	else
	{
		return NULL;
	}
}
