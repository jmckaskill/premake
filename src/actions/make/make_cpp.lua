--
-- make_cpp.lua
-- Generate a C/C++ project makefile.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	function premake.make_cpp(prj)
		-- create a shortcut to the compiler interface
		local cc = premake.gettool(prj)
		
		-- build a list of supported target platforms that also includes a generic build
		local platforms = premake.filterplatforms(prj.solution, cc.platforms, "Native")
		
		premake.gmake_cpp_header(prj, cc, platforms)

		for _, platform in ipairs(platforms) do
			for cfg in premake.eachconfig(prj, platform) do
				premake.gmake_cpp_config(cfg, cc)
			end
		end
		
		-- list intermediate files
		_p('OBJECTS := \\')
		for _, file in ipairs(prj.files) do
			if path.iscppfile(file) then
				_p('\t$(OBJDIR)/%s.o \\', _MAKE.esc(path.getbasename(file)))
            elseif (path.getextension(file) == ".hxx") then
                _p('\t$(OBJDIR)/%s_moc.o \\', _MAKE.esc(path.getbasename(file)))
			end
		end
		_p('')
 
		_p('RESOURCES := \\')
		for _, file in ipairs(prj.files) do
			if path.isresourcefile(file) then
				_p('\t$(OBJDIR)/%s.res \\', _MAKE.esc(path.getbasename(file)))
			end
		end
		_p('')
 
		-- identify the shell type
		_p('SHELLTYPE := msdos')
		_p('ifeq (,$(ComSpec)$(COMSPEC))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('ifeq (/bin,$(findstring /bin,$(SHELL)))')
		_p('  SHELLTYPE := posix')
		_p('endif')
		_p('')
		
		-- main build rule(s)
		_p('.PHONY: clean prebuild prelink')
		_p('')

		if os.is("MacOSX") and prj.kind == "WindowedApp" then
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET) $(dir $(TARGETDIR))PkgInfo $(dir $(TARGETDIR))Info.plist')
		else
			_p('all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)')
		end
		_p('')

		-- target build rule
		_p('$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)')
		_p('\t@echo Linking %s', prj.name)
		_p('\t$(SILENT) $(LINKCMD)')
		_p('\t$(POSTBUILDCMDS)')
		_p('')
		
		-- Create destination directories. Can't use $@ for this because it loses the
		-- escaping, causing issues with spaces and parenthesis
		_p('$(TARGETDIR):')
		premake.make_mkdirrule("$(TARGETDIR)")
		
		_p('$(OBJDIR):')
		premake.make_mkdirrule("$(OBJDIR)")

		-- Mac OS X specific targets
		if os.is("MacOSX") and prj.kind == "WindowedApp" then
			_p('$(dir $(TARGETDIR))PkgInfo:')
			_p('$(dir $(TARGETDIR))Info.plist:')
			_p('')
		end

		-- clean target
		_p('clean:')
		_p('\t@echo Cleaning %s', prj.name)
		_p('ifeq (posix,$(SHELLTYPE))')
		_p('\t$(SILENT) rm -f  $(TARGET)')
		_p('\t$(SILENT) rm -rf $(OBJDIR)')
		_p('else')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(TARGET)) del $(subst /,\\\\,$(TARGET))')
		_p('\t$(SILENT) if exist $(subst /,\\\\,$(OBJDIR)) rmdir /s /q $(subst /,\\\\,$(OBJDIR))')
		_p('endif')
		_p('')

		-- custom build step targets
		_p('prebuild:')
		_p('\t$(PREBUILDCMDS)')
		_p('')
		
		_p('prelink:')
		_p('\t$(PRELINKCMDS)')
		_p('')

		-- precompiler header rule
		_p('ifneq (,$(PCH))')
		_p('$(GCH): $(PCH)')
		_p('\t@echo $(notdir $<)')
		if prj.language == "C" then
			_p('\t$(SILENT) $(CC) $(CFLAGS) -o $@ -c $<')
		else
			_p('\t$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<')
		end
		_p('endif')
		_p('')
				
		-- per-file rules
		for _, file in ipairs(prj.files) do
			if path.iscppfile(file) then
				_p('$(OBJDIR)/%s.o: %s', _MAKE.esc(path.getbasename(file)), _MAKE.esc(file))
				_p('\t@echo $(notdir $<)')
				if (path.iscfile(file)) then
					_p('\t$(SILENT) $(CC) $(CFLAGS) -o $@ -c $<')
				else
					_p('\t$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<')
				end
			elseif (path.getextension(file) == ".rc") then
				_p('$(OBJDIR)/%s.res: %s', _MAKE.esc(path.getbasename(file)), _MAKE.esc(file))
				_p('\t@echo $(notdir $<)')
				_p('\t$(SILENT) windres $< -O coff -o $@ $(RESFLAGS)')
            elseif (path.getextension(file) == ".hxx") then
                _p('$(OBJDIR)/%s_moc.cpp: %s', _MAKE.esc(path.getbasename(file)), _MAKE.esc(file))
				_p('\t@echo $(notdir $<)')
                _p('\t$(SILENT) $(MOC) $(MOCFLAGS) -o $@ $<')
				_p('$(OBJDIR)/%s_moc.o: $(OBJDIR)/%s_moc.cpp', _MAKE.esc(path.getbasename(file)), _MAKE.esc(path.getbasename(file)))
				_p('\t@echo $(notdir $<)')
                _p('\t$(SILENT) $(CXX) $(CXXFLAGS) -o $@ -c $<')
			end
		end
		_p('')
		
		-- include the dependencies, built by GCC (with the -MMD flag)
		_p('-include $(OBJECTS:%%.o=%%.d)')
	end



--
-- Write the makefile header
--

	function premake.gmake_cpp_header(prj, cc, platforms)
		_p('# %s project makefile autogenerated by Premake', premake.action.current().shortname)

		-- set up the environment
		_p('ifndef config')
		_p('  config=%s', _MAKE.esc(premake.getconfigname(prj.solution.configurations[1], platforms[1], true)))
		_p('endif')
		_p('')
		
		_p('ifndef verbose')
		_p('  SILENT = @')
		_p('endif')
		_p('')
		
		_p('ifndef CC')
		_p('  CC = %s', cc.cc)
		_p('endif')
		_p('')
		
		_p('ifndef CXX')
		_p('  CXX = %s', cc.cxx)
		_p('endif')
		_p('')
		
		_p('ifndef AR')
		_p('  AR = %s', cc.ar)
		_p('endif')
		_p('')

        _p('ifndef MOC')
        _p('  MOC = %s', cc.moc)
        _p('endif')
        _p('')
	end
	
	
--
-- Write a block of configuration settings.
--

	function premake.gmake_cpp_config(cfg, cc)

		_p('ifeq ($(config),%s)', _MAKE.esc(cfg.shortname))
		
		-- if this platform requires a special compiler or linker, list it now
		local platform = cc.platforms[cfg.platform]
		if platform.cc then
			_p('  CC         = %s', platform.cc)
		end
		if platform.cxx then
			_p('  CXX        = %s', platform.cxx)
		end
		if platform.ar then
			_p('  AR         = %s', platform.ar)
		end
        if platform.moc then
            _p('  MOC        = %s', platform.moc)
        end

		_p('  OBJDIR     = %s', _MAKE.esc(cfg.objectsdir))		
		_p('  TARGETDIR  = %s', _MAKE.esc(cfg.buildtarget.directory))
		_p('  TARGET     = $(TARGETDIR)/%s', _MAKE.esc(cfg.buildtarget.name))
		_p('  DEFINES   += %s', table.concat(cc.getdefines(cfg.defines), " "))
		_p('  INCLUDES  += %s', table.concat(cc.getincludedirs(cfg.includedirs), " "))
		_p('  CPPFLAGS  += %s $(DEFINES) $(INCLUDES)', table.concat(cc.getcppflags(cfg), " "))

		-- set up precompiled headers
		if not cfg.flags.NoPCH and cfg.pchheader then
			_p('  PCH        = %s', _MAKE.esc(path.getrelative(cfg.location, cfg.pchheader)))
			_p('  GCH        = $(OBJDIR)/%s.gch', _MAKE.esc(path.getname(cfg.pchheader))) 
			_p('  CPPFLAGS  += -I$(OBJDIR) -include $(PCH)')
		end
				
		_p('  CFLAGS    += $(CPPFLAGS) $(ARCH) %s', table.concat(table.join(cc.getcflags(cfg), cfg.buildoptions), " "))
		_p('  CXXFLAGS  += $(CFLAGS) %s', table.concat(cc.getcxxflags(cfg), " "))
		_p('  LDFLAGS   += %s', table.concat(table.join(cc.getldflags(cfg), cfg.linkoptions, cc.getlibdirflags(cfg)), " "))
		_p('  LIBS      += %s', table.concat(cc.getlinkflags(cfg), " "))
		_p('  RESFLAGS  += $(DEFINES) $(INCLUDES) %s', table.concat(table.join(cc.getdefines(cfg.resdefines), cc.getincludedirs(cfg.resincludedirs), cfg.resoptions), " "))
		_p('  LDDEPS    += %s', table.concat(_MAKE.esc(premake.getlinks(cfg, "siblings", "fullpath")), " "))
        _p('  MOCFLAGS  += $(DEFINES) $(INCLUDES)')
		
		if cfg.kind == "StaticLib" then
			if cfg.platform:startswith("Universal") then
				_p('  LINKCMD    = libtool -o $(TARGET) $(OBJECTS)')
			else
				_p('  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)')
			end
		else
			-- this was $(TARGET) $(LDFLAGS) $(OBJECTS) ... but was having trouble linking to certain 
			-- static libraries so $(OBJECTS) was moved up
			_p('  LINKCMD    = $(%s) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS)', iif(cfg.language == "C", "CC", "CXX"))
		end
		
		_p('  define PREBUILDCMDS')
		if #cfg.prebuildcommands > 0 then
			_p('\t@echo Running pre-build commands')
			_p('\t%s', table.implode(cfg.prebuildcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define PRELINKCMDS')
		if #cfg.prelinkcommands > 0 then
			_p('\t@echo Running pre-link commands')
			_p('\t%s', table.implode(cfg.prelinkcommands, "", "", "\n\t"))
		end
		_p('  endef')

		_p('  define POSTBUILDCMDS')
		if #cfg.postbuildcommands > 0 then
			_p('\t@echo Running post-build commands')
			_p('\t%s', table.implode(cfg.postbuildcommands, "", "", "\n\t"))
		end
		_p('  endef')
		
		_p('endif')
		_p('')
	end
