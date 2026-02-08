#!/usr/bin/env python3
import re
import sys

MSG_FILE = sys.argv[1] if len(sys.argv) > 1 else None
if not MSG_FILE:
    print("No commit message file provided")
    sys.exit(1)

with open(MSG_FILE, "r", encoding="utf-8") as f:
    lines = [l.rstrip("\n") for l in f.readlines() if l.strip()]

if not lines:
    print("Empty commit message")
    sys.exit(1)

subject = lines[0]

pattern = re.compile(
    r"^(feat|fix|docs|chore|refactor|style|test|perf)(\(.+\))?(!)?: .+"
)

if not pattern.match(subject):
    print(
        "Invalid commit message subject:\n\n  {}\n\nCommit message must follow Conventional Commits, e.g. 'feat(api): add login'".format(
            subject
        )
    )
    sys.exit(1)

sys.exit(0)
