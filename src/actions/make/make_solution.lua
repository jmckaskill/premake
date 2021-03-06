--
-- make_solution.lua
-- Generate a solution-level makefile.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	function premake.make_solution(sln)
		-- create a shortcut to the compiler interface
		local cc = premake[_OPTIONS.cc]

		-- build a list of supported target platforms that also includes a generic build
		local platforms = premake.filterplatforms(sln, cc.platforms, "Native")

		-- write a header showing the build options
		local cfgpairs = { }
		for _, platform in ipairs(platforms) do
			for _, cfgname in ipairs(sln.configurations) do
				table.insert(cfgpairs, premake.getconfigname(cfgname, platform, true))
			end
		end
		_p('# %s solution makefile autogenerated by Premake', premake.action.current().shortname)
		_p('# Usage: make [ config=config_name ]')
		_p('# Where {config_name} is one of: %s.', table.implode(cfgpairs, '"', '"', ', '))
		_p('')
		
		-- set a default configuration
		_p('ifndef config')
		_p('  config=%s', _MAKE.esc(premake.getconfigname(sln.configurations[1], platforms[1], true)))
		_p('endif')
		_p('export config')
		_p('')

		-- list the projects included in the solution
		_p('PROJECTS := %s', table.concat(_MAKE.esc(table.extract(sln.projects, "name")), " "))
		_p('')
		_p('.PHONY: all clean $(PROJECTS)')
		_p('')
		_p('all: $(PROJECTS)')
		_p('')

		-- write the project build rules
		for _, prj in ipairs(sln.projects) do
			_p('%s: %s', _MAKE.esc(prj.name), table.concat(_MAKE.esc(table.extract(premake.getdependencies(prj), "name")), " "))
			_p('\t@echo ==== Building %s ====', prj.name)
			_p('\t@${MAKE} --no-print-directory -C %s -f %s', _MAKE.esc(path.getrelative(sln.location, prj.location)), _MAKE.esc(_MAKE.getmakefilename(prj, true)))
			_p('')
		end

		-- clean rules
		_p('clean:')
		for _ ,prj in ipairs(sln.projects) do
			_p('\t@${MAKE} --no-print-directory -C %s -f %s clean', _MAKE.esc(path.getrelative(sln.location, prj.location)), _MAKE.esc(_MAKE.getmakefilename(prj, true)))
		end
		_p('')
		
	end
