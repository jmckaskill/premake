--
-- _manifest.lua
-- Manage the list of built-in Premake scripts.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

-- The master list of built-in scripts. Order is important! If you want to
-- build a new script into Premake, add it to this list.

	return
	{
		"base/os.lua",
		"base/path.lua",
		"base/string.lua",
		"base/table.lua",
		"base/io.lua",
		"base/globals.lua",
		"base/action.lua",
		"base/option.lua",
		"base/tree.lua",
		"base/project.lua",
		"base/configs.lua",
		"base/api.lua",
		"base/cmdline.lua",
		"tools/dotnet.lua",
		"tools/gcc.lua",
		"tools/msc.lua",
		"tools/ow.lua",
		"base/validate.lua",
		"base/help.lua",
		"base/premake.lua",
		"actions/codeblocks/codeblocks_workspace.lua",
		"actions/codeblocks/codeblocks_cbp.lua",
		"actions/codeblocks/_codeblocks.lua",
		"actions/codelite/codelite_workspace.lua",
		"actions/codelite/codelite_project.lua",
		"actions/codelite/_codelite.lua",
    "actions/qmake/_qmake.lua",
    "actions/qmake/qmake_pro.lua",
    "actions/qmake/qmake_subdirs.lua",
		"actions/make/make_solution.lua",
		"actions/make/make_cpp.lua",
		"actions/make/make_csharp.lua",
		"actions/make/_make.lua",
		"actions/vstudio/vs2002_solution.lua",
		"actions/vstudio/vs2002_csproj.lua",
		"actions/vstudio/vs2002_csproj_user.lua",
		"actions/vstudio/vs200x_vcproj.lua",
		"actions/vstudio/vs2003_solution.lua",
		"actions/vstudio/vs2005_solution.lua",
		"actions/vstudio/vs2005_csproj.lua",
		"actions/vstudio/vs2005_csproj_user.lua",
		"actions/vstudio/_vstudio.lua",
		"actions/xcode/_xcode.lua",
		"actions/xcode/xcode_pbxproj.lua",
		"actions/clean/_clean.lua",
	}
