using System.IO;
using UnrealBuildTool;
using System.Collections.Generic;

public class GDAL : ModuleRules
{
    public GDAL(ReadOnlyTargetRules Target) : base(Target)
    {
        Type = ModuleType.External;
        PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;

        // Common include directory for all platforms
        PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "include"));

        if (Target.Platform == UnrealTargetPlatform.Linux)
        {
            // Adding the lib directory to the library paths
            PublicLibraryPaths.Add(Path.Combine(ModuleDirectory, "lib"));

            // Adding the dynamic GDAL library
            string DynamicGDALLib = Path.Combine(ModuleDirectory, "lib", "libgdal.so");
            PublicAdditionalLibraries.Add(DynamicGDALLib);

            // Staging directory for GDAL data files
            string stagingDir = Path.Combine("$(ProjectDir)", "Binaries", "Data", "GDAL");
            var datadirs = Directory.GetDirectories(Path.Combine(ModuleDirectory, "share"), "*");

            if (!Directory.Exists(stagingDir))
            {
                Directory.CreateDirectory(stagingDir);
            }
            foreach (string dir in datadirs)
            {
                string StagedDataDir = Path.Combine(stagingDir, Path.GetFileName(dir));
                if (!Directory.Exists(StagedDataDir))
                {
                    Directory.CreateDirectory(StagedDataDir);
                }
                foreach (string file in Directory.GetFiles(dir, "*"))
                {
                    RuntimeDependencies.Add(Path.Combine(StagedDataDir, Path.GetFileName(file)), file, StagedFileType.NonUFS);
                }
            }

            // Dependencies include path
            PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "dependencies", "include"));

            // Adding modules GDAL may depend on, assuming your project correctly sets these up as dependencies.
            PublicDependencyModuleNames.AddRange(
                new string[]
                {
                    "Core",
                }
            );

            // These are common dependencies GDAL might use. You may need to adjust this list based on your actual dependencies and third-party libraries.
            PrivateDependencyModuleNames.AddRange(
                new string[]
                {
                    "CoreUObject",
                    "Engine",
                    "Projects",
                    "RHI",
                    "RenderCore",
                    // Add other dependencies required by GDAL here
                }
            );
        }
    }
}
