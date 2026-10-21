using System.Linq;
using NUnit.Framework;
using UnityEditor;

namespace Game.Tests.EditMode
{
    // Sample EditMode tests: fast checks of logic and of the project settings. The smoke tier runs them before each
    // commit of code (docs/test-tiers.md).
    public class ProjectSettingsTests
    {
        [Test]
        public void TheBuild_HasAnEnabledScene()
        {
            Assert.IsTrue(EditorBuildSettings.scenes.Any(s => s.enabled), "no enabled scene in the build settings");
        }

        [Test]
        public void TheProductName_IsSet()
        {
            Assert.IsFalse(string.IsNullOrWhiteSpace(PlayerSettings.productName), "the Product Name is empty");
        }
    }
}
