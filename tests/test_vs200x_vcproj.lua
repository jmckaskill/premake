--
-- tests/test_vs200x_vcproj.lua
-- Automated test suite for Visual Studio 2002-2008 C/C++ project generation.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	T.vs200x_vcproj = { }


--
-- Configure a solution for testing
--

	local sln, prj
	function T.vs200x_vcproj.setup()
		_ACTION = "vs2005"

		sln = solution "MySolution"
		configurations { "Debug", "Release" }
		platforms {}
		
		project "DotNetProject"   -- to test handling of .NET platform in solution
		language "C#"
		kind "ConsoleApp"
		
		prj = project "MyProject"
		language "C++"
		kind "ConsoleApp"
		uuid "AE61726D-187C-E440-BD07-2556188A6565"		
	end

	local function prepare()
		io.capture()
		premake.buildconfigs()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)

		local cfg = premake.getconfig(sln.projects[2])
		cfg.name = prj.name
		cfg.blocks = prj.blocks
		prj = cfg
	end
	

--
-- Make sure I've got the basic layout correct
--

	function T.vs200x_vcproj.BasicLayout()
		prepare()
		premake.vs200x_vcproj(prj)
		test.capture [[
<?xml version="1.0" encoding="Windows-1252"?>
<VisualStudioProject
	ProjectType="Visual C++"
	Version="8.00"
	Name="MyProject"
	ProjectGUID="{AE61726D-187C-E440-BD07-2556188A6565}"
	RootNamespace="MyProject"
	Keyword="Win32Proj"
	>
	<Platforms>
		<Platform
			Name="Win32"
		/>
	</Platforms>
	<ToolFiles>
	</ToolFiles>
	<Configurations>
		<Configuration
			Name="Debug|Win32"
			OutputDirectory="."
			IntermediateDirectory="obj\Debug\MyProject"
			ConfigurationType="1"
			CharacterSet="2"
			>
			<Tool
				Name="VCPreBuildEventTool"
			/>
			<Tool
				Name="VCCustomBuildTool"
			/>
			<Tool
				Name="VCXMLDataGeneratorTool"
			/>
			<Tool
				Name="VCWebServiceProxyGeneratorTool"
			/>
			<Tool
				Name="VCMIDLTool"
			/>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				Detect64BitPortabilityProblems="true"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
			/>
			<Tool
				Name="VCManagedResourceCompilerTool"
			/>
			<Tool
				Name="VCResourceCompilerTool"
			/>
			<Tool
				Name="VCPreLinkEventTool"
			/>
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				AdditionalLibraryDirectories=""
				GenerateDebugInformation="false"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
			<Tool
				Name="VCALinkTool"
			/>
			<Tool
				Name="VCManifestTool"
			/>
			<Tool
				Name="VCXDCMakeTool"
			/>
			<Tool
				Name="VCBscMakeTool"
			/>
			<Tool
				Name="VCFxCopTool"
			/>
			<Tool
				Name="VCAppVerifierTool"
			/>
			<Tool
				Name="VCWebDeploymentTool"
			/>
			<Tool
				Name="VCPostBuildEventTool"
			/>
		</Configuration>
		<Configuration
			Name="Release|Win32"
			OutputDirectory="."
			IntermediateDirectory="obj\Release\MyProject"
			ConfigurationType="1"
			CharacterSet="2"
			>
			<Tool
				Name="VCPreBuildEventTool"
			/>
			<Tool
				Name="VCCustomBuildTool"
			/>
			<Tool
				Name="VCXMLDataGeneratorTool"
			/>
			<Tool
				Name="VCWebServiceProxyGeneratorTool"
			/>
			<Tool
				Name="VCMIDLTool"
			/>
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				Detect64BitPortabilityProblems="true"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
			/>
			<Tool
				Name="VCManagedResourceCompilerTool"
			/>
			<Tool
				Name="VCResourceCompilerTool"
			/>
			<Tool
				Name="VCPreLinkEventTool"
			/>
			<Tool
				Name="VCLinkerTool"
				OutputFile="$(OutDir)\MyProject.exe"
				LinkIncremental="2"
				AdditionalLibraryDirectories=""
				GenerateDebugInformation="false"
				SubSystem="1"
				EntryPointSymbol="mainCRTStartup"
				TargetMachine="1"
			/>
			<Tool
				Name="VCALinkTool"
			/>
			<Tool
				Name="VCManifestTool"
			/>
			<Tool
				Name="VCXDCMakeTool"
			/>
			<Tool
				Name="VCBscMakeTool"
			/>
			<Tool
				Name="VCFxCopTool"
			/>
			<Tool
				Name="VCAppVerifierTool"
			/>
			<Tool
				Name="VCWebDeploymentTool"
			/>
			<Tool
				Name="VCPostBuildEventTool"
			/>
		</Configuration>
	</Configurations>
	<References>
	</References>
	<Files>
	</Files>
	<Globals>
	</Globals>
</VisualStudioProject>
		]]
	end


--
-- Test multiple platforms
--

	function T.vs200x_vcproj.Platforms_OnMultiplePlatforms()
		platforms { "x32", "x64" }
		prepare()

		premake.vs200x_vcproj(prj)
		local result = io.endcapture()		
		test.istrue(result:find '<Configuration\r\n\t\t\tName="Debug|Win32"\r\n')
		test.istrue(result:find '<Configuration\r\n\t\t\tName="Release|Win32"\r\n')
		test.istrue(result:find '<Configuration\r\n\t\t\tName="Debug|x64"\r\n')
		test.istrue(result:find '<Configuration\r\n\t\t\tName="Release|x64"\r\n')
	end



--
-- Test x64 handling
--

	function T.vs200x_vcproj.PlatformsList_OnX64()
		platforms { "Native", "x64" }
		prepare()
		premake.vs200x_vcproj_platforms(prj)
		test.capture [[
	<Platforms>
		<Platform
			Name="Win32"
		/>
		<Platform
			Name="x64"
		/>
	</Platforms>
		]]		
	end



--
-- Test Xbox360 handling
--

	function T.vs200x_vcproj.PlatformsList_OnXbox360()
		platforms { "Native", "Xbox360" }
		prepare()
		premake.vs200x_vcproj_platforms(prj)
		test.capture [[
	<Platforms>
		<Platform
			Name="Win32"
		/>
		<Platform
			Name="Xbox 360"
		/>
	</Platforms>
		]]		
	end
	
	function T.vs200x_vcproj.CompilerBlock_OnXbox360()
		platforms { "Xbox360" }
		prepare()
		premake.vs200x_vcproj_VCCLCompilerTool(premake.getconfig(prj, "Debug", "Xbox360"))
		test.capture [[
			<Tool
				Name="VCCLX360CompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				Detect64BitPortabilityProblems="true"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
			/>
		]]
	end


--
-- Test PS3 handling
--

	function T.vs200x_vcproj.PlatformsList_OnPS3()
		platforms { "Native", "PS3" }
		prepare()
		premake.vs200x_vcproj_platforms(prj)
		test.capture [[
	<Platforms>
		<Platform
			Name="Win32"
		/>
	</Platforms>
		]]		
	end
	
	function T.vs200x_vcproj.CompilerBlock_OnPS3()
		platforms { "PS3" }
		flags { "Symbols" }
		includedirs { "include/pkg1", "include/pkg2" }
		defines { "DEFINE1", "DEFINE2" }
		prepare()
		premake.vs200x_vcproj_VCCLCompilerTool_GCC(premake.getconfig(prj, "Debug", "PS3"))
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				AdditionalOptions="-g"
				AdditionalIncludeDirectories="include\pkg1;include\pkg2"
				PreprocessorDefinitions="DEFINE1;DEFINE2"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
				CompileAs="0"
			/>
		]]
	end
	
	function T.vs200x_vcproj.LinkerBlock_OnPS3ConsoleApp()
		platforms { "PS3" }
		prepare()
		premake.vs200x_vcproj_VCLinkerTool_GCC(premake.getconfig(prj, "Debug", "PS3"))
		test.capture [[
			<Tool
				Name="VCLinkerTool"
				AdditionalOptions="-s"
				OutputFile="$(OutDir)\MyProject.elf"
				LinkIncremental="0"
				AdditionalLibraryDirectories=""
				GenerateManifest="false"
				ProgramDatabaseFile=""
				RandomizedBaseAddress="1"
				DataExecutionPrevention="0"
			/>
		]]
	end

	function T.vs200x_vcproj.LinkerBlock_OnPS3StaticLib()
		platforms { "PS3" }
		kind "StaticLib"
		prepare()
		premake.vs200x_vcproj_VCLinkerTool_GCC(premake.getconfig(prj, "Debug", "PS3"))
		test.capture [[
			<Tool
				Name="VCLibrarianTool"
				AdditionalOptions="-s"
				OutputFile="$(OutDir)\libMyProject.a"
			/>
		]]
	end

	function T.vs200x_vcproj.LinkerBlock_OnPS3SharedLink()
		platforms { "PS3" }
		links { "MyLibrary" }
		project "MyLibrary"
		language "C++"
		kind "SharedLib"
		prepare()
		premake.vs200x_vcproj_VCLinkerTool_GCC(premake.getconfig(prj, "Debug", "PS3"))

		test.capture [[
			<Tool
				Name="VCLinkerTool"
				AdditionalOptions="-s"
				AdditionalDependencies="libMyLibrary.a"
				OutputFile="$(OutDir)\MyProject.elf"
				LinkIncremental="0"
				AdditionalLibraryDirectories=""
				GenerateManifest="false"
				ProgramDatabaseFile=""
				RandomizedBaseAddress="1"
				DataExecutionPrevention="0"
			/>
		]]
	end

		
--
-- Test manifest file handling.
--

	function T.vs200x_vcproj.VCManifestTool_OnNoManifests()
		files { "hello.c", "goodbye.c" }
		prepare()
		premake.vs200x_vcproj_VCManifestTool(premake.getconfig(prj, "Debug"))
		test.capture [[
			<Tool
				Name="VCManifestTool"
			/>
		]]
	end


	function T.vs200x_vcproj.VCManifestTool_OnNoManifests()
		files { "hello.c", "project1.manifest", "goodbye.c", "project2.manifest" }
		prepare()
		premake.vs200x_vcproj_VCManifestTool(premake.getconfig(prj, "Debug"))
		test.capture [[
			<Tool
				Name="VCManifestTool"
				AdditionalManifestFiles="project1.manifest;project2.manifest"
			/>
		]]
	end


--
-- Test precompiled header handling
--

	function T.vs200x_vcproj.PCH_OnWindows()
		files { "afxwin.cpp" }
		pchsource "afxwin.cpp"
		prepare()
		_VS.files(prj, "afxwin.cpp", "Item", 1)
		test.capture [[
			<File
				RelativePath="afxwin.cpp"
				>
				<FileConfiguration
					Name="Debug|Win32"
					>
					<Tool
						Name="VCCLCompilerTool"
						UsePrecompiledHeader="1"
					/>
				</FileConfiguration>
				<FileConfiguration
					Name="Release|Win32"
					>
					<Tool
						Name="VCCLCompilerTool"
						UsePrecompiledHeader="1"
					/>
				</FileConfiguration>
			</File>
		]]
	end

	function T.vs200x_vcproj.PCH_OnXbox360()
		files { "afxwin.cpp" }
		pchsource "afxwin.cpp"
		platforms { "Xbox360" }
		prepare()
		sln.vstudio_configs = premake.vstudio_buildconfigs(sln)
		_VS.files(prj, "afxwin.cpp", "Item", 1)
		test.capture [[
			<File
				RelativePath="afxwin.cpp"
				>
				<FileConfiguration
					Name="Debug|Xbox 360"
					>
					<Tool
						Name="VCCLX360CompilerTool"
						UsePrecompiledHeader="1"
					/>
				</FileConfiguration>
				<FileConfiguration
					Name="Release|Xbox 360"
					>
					<Tool
						Name="VCCLX360CompilerTool"
						UsePrecompiledHeader="1"
					/>
				</FileConfiguration>
			</File>
		]]
	end

--
-- Floating point flag tests
--

	function T.vs200x_vcproj.CompilerBlock_OnFpFast()
		flags { "FloatFast" }
		prepare()
		premake.vs200x_vcproj_VCCLCompilerTool(premake.getconfig(prj, "Debug"))
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				FloatingPointModel="2"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				Detect64BitPortabilityProblems="true"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
			/>
		]]
	end

	function T.vs200x_vcproj.CompilerBlock_OnFpStrict()
		flags { "FloatStrict" }
		prepare()
		premake.vs200x_vcproj_VCCLCompilerTool(premake.getconfig(prj, "Debug"))
		test.capture [[
			<Tool
				Name="VCCLCompilerTool"
				Optimization="0"
				BasicRuntimeChecks="3"
				RuntimeLibrary="3"
				EnableFunctionLevelLinking="true"
				FloatingPointModel="1"
				UsePrecompiledHeader="0"
				WarningLevel="3"
				Detect64BitPortabilityProblems="true"
				ProgramDataBaseFileName="$(OutDir)\$(ProjectName).pdb"
				DebugInformationFormat="0"
			/>
		]]
	end
