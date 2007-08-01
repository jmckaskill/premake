package.name     = "Premake"
package.language = "c"
package.kind     = "exe"
package.target   = "premake"

-- Build Flags

	package.buildflags = 
	{ 
		"no-64bit-checks",
		"static-runtime",
		"extra-warnings"
	}

	package.config["Release"].buildflags = 
	{ 
		"no-symbols", 
		"optimize-size",
		"no-frame-pointers"
	}


-- Avoid VS2005 warnings

	package.defines = { "_CRT_SECURE_NO_DEPRECATE" }

-- Libraries

	if (OS == "linux") then
		package.links = { "m" }
	end


-- Files

	package.files =
	{
		matchrecursive("*.h", "*.c")
	}
