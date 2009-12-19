--
-- premake.lua
-- High-level processing functions.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--


--
-- Open a file for output, and call a function to actually do the writing.
-- Used by the actions to generate solution and project files.
--
-- @param obj
--    A solution or project object; will be based to the callback function.
-- @param filename
--    The output filename; see the docs for premake.project.getfilename()
--    for the expected format.
-- @param callback
--    The function responsible for writing the file, should take a solution
--    or project as a parameters.
--

	function premake.generate(obj, filename, callback)
		filename = premake.project.getfilename(obj, filename)
    tmpfilename = filename .. ".tmp"
		printf("Generating %s...", filename)

		local f, err = io.open(tmpfilename, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		callback(obj)
		f:close()
    if os.isfile(filename) then
      local function slurp(name)
        local f = io.open(name, "rb")
        local ret = f:read("*a")
        f:close()
        return ret
      end
      local old = slurp(filename)
      local new = slurp(tmpfilename)
      if old ~= new then
        os.remove(filename)
        os.rename(tmpfilename, filename)
      else
        os.remove(tmpfilename)
      end
    else
      os.rename(tmpfilename, filename)
    end
	end

  --[[
	function premake.generate(obj, filename, callback)
		filename = premake.project.getfilename(obj, filename)
		printf("Generating %s...", filename)

		local f, err = io.open(filename, "wb")
		if (not f) then
			error(err, 0)
		end

		io.output(f)
		callback(obj)
		f:close()
	end
  --]]
