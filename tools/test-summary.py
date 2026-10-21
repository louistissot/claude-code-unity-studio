#!/usr/bin/env python3
# Print a summary of a Unity test result file (NUnit 3 XML): the counts, then each test that did not pass, with its
# message.
# Usage: tools/test-summary.py [TestResults/PlayMode.xml] [a log tag to show, for example "[Physics]"] [lines]
# With a log tag, the script also shows the last lines of the output of each test that have the tag.
import sys
import xml.etree.ElementTree as ET

path = sys.argv[1] if len(sys.argv) > 1 else "TestResults/PlayMode.xml"
tag = sys.argv[2] if len(sys.argv) > 2 else None
lines = int(sys.argv[3]) if len(sys.argv) > 3 else 3
root = ET.parse(path).getroot()
print(f"total {root.get('total')}, passed {root.get('passed')}, failed {root.get('failed')}, "
      f"skipped {root.get('skipped')}, duration {float(root.get('duration') or 0):.0f} s")
for case in root.iter("test-case"):
    result = case.get("result")
    if result == "Skipped" and not tag:
        continue
    if result != "Passed" or tag:
        print(f"{result} {case.get('fullname') or case.get('name')} {float(case.get('duration') or 0):.1f} s")
    failure = case.find("failure")
    if failure is not None:
        print("   " + (failure.findtext("message") or "").strip().replace("\n", " / ")[:1200])
    output = case.find("output")
    if tag and output is not None:
        shown = [line for line in (output.text or "").split("\n") if tag in line]
        for line in shown[-lines:]:
            print("   " + line[:1500])
sys.exit(1 if root.get("failed") not in (None, "0") else 0)
