using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

// The build methods of the batch tools (tools/batch.sh, tools/release.sh, docs/release-rules.md).
// Each method reads "-out <path>"; without it, the player goes to Builds/<Release or Dev>/<Win or Mac>/.
// A failed build ends Unity with exit code 1, so that the tools see the failure.
// The name of the Mac executable is the Product Name of the Player settings: keep it equal to GAME_NAME in
// sessions.conf.
public static class BuildTools
{
    public static void BuildWindows() => Build(BuildTarget.StandaloneWindows64, BuildOptions.None);
    public static void BuildMac() => Build(BuildTarget.StandaloneOSX, BuildOptions.None);
    public static void BuildDevMac() => Build(BuildTarget.StandaloneOSX, BuildOptions.Development);

    static string Arg(string name)
    {
        string[] args = System.Environment.GetCommandLineArgs();
        int i = System.Array.IndexOf(args, name);
        return i >= 0 && i + 1 < args.Length ? args[i + 1] : null;
    }

    static void Build(BuildTarget target, BuildOptions options)
    {
        bool windows = target == BuildTarget.StandaloneWindows64;
        bool dev = (options & BuildOptions.Development) != 0;
        string output = Arg("-out")
            ?? $"Builds/{(dev ? "Dev" : "Release")}/{(windows ? "Win" : "Mac")}/{PlayerSettings.productName}{(windows ? ".exe" : ".app")}";
        string[] scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray();
        if (scenes.Length == 0)
        {
            Debug.LogError("[Batch] no enabled scene in the build settings");
            EditorApplication.Exit(1);
            return;
        }
        BuildReport report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = output,
            target = target,
            options = options,
        });
        BuildSummary summary = report.summary;
        Debug.Log($"[Batch] {target} {summary.result}: {output}, {summary.totalSize / 1048576} MB, {summary.totalErrors} errors");
        if (summary.result != BuildResult.Succeeded)
            EditorApplication.Exit(1);
    }
}
