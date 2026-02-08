#!/usr/bin/env python3
import re
import sys

MSG_FILE = sys.argv[1] if len(sys.argv) > 1 else None
if not MSG_FILE:
    print("No commit message file provided")
    sys.exit(1)

with open(MSG_FILE, encoding="utf-8") as f:
    lines = [line.rstrip("\n") for line in f.readlines() if line.strip()]

if not lines:
    print("Empty commit message")
    sys.exit(1)

subject = lines[0]

pattern = re.compile(
    r"^(feat|fix|docs|chore|refactor|style|test|perf)(\(.+\))?(!)?: .+"
)

if not pattern.match(subject):
    print(
        f"Invalid commit message subject:\n\n  {subject}\n\nCommit message must follow Conventional Commits, e.g. 'feat(api): add login'"
    )
    sys.exit(1)

sys.exit(0)
