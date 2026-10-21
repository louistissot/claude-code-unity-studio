using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Game.Testing
{
    // The in-game report key (docs/play-report-loop.md). One key press writes a report folder that a human sends with
    // a play report: a screenshot, the build version, the scene, the camera position and direction, the game time, and
    // the last log lines. The human writes the folder name next to the point of the report, so that the session finds
    // the place and the moment.
    //
    // The key: F8 with the old Input Manager. With the Input System only, call ReportKey.Capture from your own input
    // code (for example an action on the F8 key). Show the player a short confirmation (TODO in your UI).
    public sealed class ReportKey : MonoBehaviour
    {
        const int LogLines = 200;
        static readonly Queue<string> recent = new Queue<string>(LogLines);

        public static string LastFolder { get; private set; }

        // Enter Play Mode options can keep static values between runs: reset them.
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        static void ResetStatics()
        {
            Application.logMessageReceived -= OnLog;
            recent.Clear();
            LastFolder = null;
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Install()
        {
            if (Application.isBatchMode)
                return;
            Application.logMessageReceived += OnLog;
            var go = new GameObject("ReportKey");
            DontDestroyOnLoad(go);
            go.AddComponent<ReportKey>();
        }

        static void OnLog(string message, string stackTrace, LogType type)
        {
            if (recent.Count == LogLines)
                recent.Dequeue();
            recent.Enqueue($"{DateTime.Now:HH:mm:ss} {type} {message}");
        }

        void Update()
        {
#if ENABLE_LEGACY_INPUT_MANAGER
            if (Input.GetKeyDown(KeyCode.F8))
                Capture("");
#endif
        }

        // Write a report folder and return its path. The screenshot file comes at the end of the frame.
        public static string Capture(string note)
        {
            string folder = Path.Combine(Application.persistentDataPath, "Reports", DateTime.Now.ToString("yyyyMMdd-HHmmss"));
            Directory.CreateDirectory(folder);
            ScreenCapture.CaptureScreenshot(Path.Combine(folder, "screen.png"));

            var text = new StringBuilder();
            text.AppendLine($"Report: {Path.GetFileName(folder)}");
            text.AppendLine($"Version: {Application.version} (Unity {Application.unityVersion})");
            text.AppendLine($"System: {SystemInfo.operatingSystem}; {SystemInfo.graphicsDeviceName}; {SystemInfo.systemMemorySize} MB");
            text.AppendLine($"Scene: {SceneManager.GetActiveScene().name}");
            text.AppendLine($"Game time: {Time.time:F1} s; frame {Time.frameCount}");
            Camera cam = Camera.main;
            if (cam != null)
                text.AppendLine($"Camera: position {cam.transform.position:F2}; direction {cam.transform.forward:F2}");
            text.AppendLine($"Note: {note}");
            // TODO: add the state of your game: the seed, the game clock, the health, the mission, the network role.
            text.AppendLine();
            text.AppendLine("Last log lines:");
            foreach (string line in recent)
                text.AppendLine(line);
            File.WriteAllText(Path.Combine(folder, "report.txt"), text.ToString());

            LastFolder = folder;
            Debug.Log($"[Report] {folder}");
            return folder;
        }
    }
}
