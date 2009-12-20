--
-- codeblocks_workspace.lua
-- Generate a Code::Blocks workspace.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

  function premake.qtcreator_creator(sln)
  end

	function premake.qtcreator_files(sln)
    --_p(table.show(sln))
    for proj in premake.eachproject(sln) do
      for _,fname in ipairs(proj.files) do
        _p("%s/%s", proj.location, fname)
      end
    end
	end

  function premake.qtcreator_includes(sln)
    local includes = {}
    for proj in premake.eachproject(sln) do
      local cc = premake.gettool(proj)
      for platform_name,_ in pairs(cc.platforms) do
        for cfg in premake.eachconfig(proj, platform_name) do
          for _,v in ipairs(cfg.includedirs) do
            dir = path.getabsolute(proj.location .. '/' .. v)
            includes[dir] = true
          end
        end
      end
    end
    for dir in pairs(includes) do
      _p("%s", dir)
    end
  end

  function premake.qtcreator_config(sln)
  end


