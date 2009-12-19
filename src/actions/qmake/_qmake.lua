--
-- _qmake.lua
-- Define the qmake actions
--

	newaction {
		trigger         = "qmake",
		shortname       = "QMake",
		description     = "Generate qmake project files",
		
		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib" },
		
		valid_languages = { "C", "C++" },
		
		valid_tools     = {
			cc   = { "gcc", "msc" },
		},
		
		onsolution = function(sln)
			premake.generate(sln, "%%.creator", premake.qtcreator_creator)
			premake.generate(sln, "%%.files", premake.qtcreator_files)
			premake.generate(sln, "%%.includes", premake.qtcreator_includes)
			premake.generate(sln, "%%.config", premake.qtcreator_config)
		end,
		
    --[[
		onproject = function(prj)
			premake.generate(prj, "%%.pro.files", premake.qmake_project)
		end,
    --]]
		
		oncleansolution = function(sln)
			premake.clean.file(sln, "%%.files")
		end,
		--[[
		oncleanproject = function(prj)
			premake.clean.file(prj, "%%.pro.files")
		end
    --]]
	}
