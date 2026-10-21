using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Game.Tests.PlayMode
{
    // A sample of the fixed frame time (docs/test-tiers.md, section 3). Time.captureDeltaTime makes each frame advance
    // the game time by a fixed step, whatever the speed of the machine. So a test gives the same result in batch mode
    // (hundreds of frames each second) and in a game at 60 fps. Wait in game time (WaitForSeconds), never in real time.
    public class FixedFrameTimeTests
    {
        [SetUp]
        public void SetUp() => Time.captureDeltaTime = 1f / 60f;

        [TearDown]
        public void TearDown() => Time.captureDeltaTime = 0f;

        [UnityTest]
        public IEnumerator OneSecondOfGameTime_IsAboutSixtyFrames()
        {
            int start = Time.frameCount;
            yield return new WaitForSeconds(1f);
            Assert.That(Time.frameCount - start, Is.InRange(59, 62));
        }

        // The frame-rate matrix: the same case at more than one frame rate. Physics in FixedUpdate gives the same result.
        [UnityTest]
        public IEnumerator AFallingBody_FallsTheSame_AtEachFrameRate([Values(30, 60, 144)] int fps)
        {
            Time.captureDeltaTime = 1f / fps;
            var ball = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            ball.transform.position = new Vector3(0f, 100f, 0f);
            ball.AddComponent<Rigidbody>();
            float start = Time.fixedTime;
            yield return new WaitForSeconds(1f);
            float t = Time.fixedTime - start;
            float fallen = 100f - ball.transform.position.y;
            Object.Destroy(ball);
            float expected = 0.5f * -Physics.gravity.y * t * t;
            Assert.That(fallen, Is.EqualTo(expected).Within(10).Percent, $"{fps} fps: fell {fallen:F2} m in {t:F2} s");
        }
    }
}
