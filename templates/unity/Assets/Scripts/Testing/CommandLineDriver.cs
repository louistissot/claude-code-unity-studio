using System;
using System.IO;
using UnityEngine;

namespace Game.Testing
{
    // The command-line driver of the bot runs and the network tests (tools/bot-run.sh, tools/net-test.sh).
    // It reads the arguments of the player, quits at the end of the run, and writes the lines that the tools check.
    // This is a skeleton: your game starts the host, the client, and the bot (see the TODO lines), and calls the
    // Report methods.
    public sealed class CommandLineDriver : MonoBehaviour
    {
        public static CommandLineDriver Instance { get; private set; }

        // The network test: "host", "join", or "" (no network test).
        public string NetRole { get; private set; } = "";
        public string NetAddress { get; private set; } = "127.0.0.1";
        public int NetPlayers { get; private set; } = 2;
        public string NetMode { get; private set; } = "";

        // The bot run.
        public bool Bot { get; private set; }
        public int BotSeed { get; private set; } = 1;
        public string BotScenario { get; private set; } = "default";

        float quitAt = -1f;
        StreamWriter netLog;
        string botReport;
        bool finished;

        // Enter Play Mode options can keep static values between runs: reset them.
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
        static void ResetStatics() => Instance = null;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Create()
        {
            string[] args = Environment.GetCommandLineArgs();
            if (Array.IndexOf(args, "-net") < 0 && Array.IndexOf(args, "-bot") < 0)
                return;
            var go = new GameObject("CommandLineDriver");
            DontDestroyOnLoad(go);
            go.AddComponent<CommandLineDriver>().Parse(args);
        }

        static string Arg(string[] args, string name, string fallback)
        {
            int i = Array.IndexOf(args, name);
            return i >= 0 && i + 1 < args.Length ? args[i + 1] : fallback;
        }

        void Parse(string[] args)
        {
            Instance = this;
            NetRole = Arg(args, "-net", "");
            if (NetRole == "join")
                NetAddress = Arg(args, "join", NetAddress);
            NetPlayers = int.TryParse(Arg(args, "-net-players", ""), out int n) ? n : NetPlayers;
            NetMode = Arg(args, "-net-mode", "");
            string log = Arg(args, "-net-log", "");
            if (log.Length > 0)
                netLog = new StreamWriter(log, false) { AutoFlush = true };
            if (float.TryParse(Arg(args, "-net-seconds", ""), out float seconds))
                quitAt = Time.realtimeSinceStartup + seconds;

            Bot = Array.IndexOf(args, "-bot") >= 0;
            BotSeed = int.TryParse(Arg(args, "-bot-seed", ""), out int seed) ? seed : BotSeed;
            BotScenario = Arg(args, "-bot-scenario", BotScenario);
            botReport = Arg(args, "-bot-report", "");
        }

        void Start()
        {
            if (NetRole == "host")
            {
                // TODO: start the host of your network library and wait for NetPlayers players. Then call
                // ReportHostStarted() when the host listens.
            }
            else if (NetRole == "join")
            {
                // TODO: connect to NetAddress. Call ReportConnected() when the connection is up.
            }
            if (Bot)
            {
                // TODO: start your bot with BotSeed and BotScenario. At the end of the run the bot calls
                // FinishBot(true, "") or FinishBot(false, "<the reason>").
            }
        }

        void Update()
        {
            if (!finished && quitAt > 0f && Time.realtimeSinceStartup >= quitAt)
            {
                finished = true;
                NetLine("end of the run");
                netLog?.Dispose();
                Application.Quit(0);
            }
        }

        // A test line for the log of the network test. Use the Report methods for the lines that the checks read.
        public void NetLine(string text)
        {
            string line = $"[NetTest] {text}";
            netLog?.WriteLine(line);
            Debug.Log(line);
        }

        public void ReportHostStarted() => NetLine("host started");
        public void ReportConnected() => NetLine("connected");
        // Call it every few seconds with the count of players that this machine sees (the local player included).
        public void ReportPlayers(int count) => NetLine($"players {count}");
        // Call it one time when the game knows its seed. All machines of one game must show the same seed.
        public void ReportSeed(int seed) => NetLine($"seed {seed}");

        // The end of a bot run: write the report and quit with exit code 0.
        public void FinishBot(bool pass, string reason)
        {
            if (finished)
                return;
            finished = true;
            if (botReport.Length > 0)
            {
                // TODO: add the numbers of your game: the time to the goal, the damage, the stuck places, the rescues.
                string text = $"Seed: {BotSeed}\nScenario: {BotScenario}\nGame time: {Time.time:F1} s\n"
                              + (pass ? "Result: PASS\n" : $"Result: FAIL {reason}\n");
                File.WriteAllText(botReport, text);
            }
            Application.Quit(0);
        }

        void OnDestroy()
        {
            netLog?.Dispose();
            if (Instance == this)
                Instance = null;
        }
    }
}
