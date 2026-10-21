#!/usr/bin/env python3
"""UserPromptSubmit hook: sowhat スキルの点検項目を毎ターン文脈に入れる。

/sowhat を打つまで伝え方の型が文脈に入らないと、打つ前のメッセージが型から外れる。
点検項目は SKILL.md の「## 点検項目」の節をそのまま読む。写しを持たないので、
SKILL.md を直せばこちらも追従する。
"""

import json
import sys
from pathlib import Path

SKILL = Path(__file__).resolve().parents[2] / "shared/skills/sowhat/SKILL.md"
START = "## 点検項目"
END = "## やらないこと"


def checklist(text: str) -> str:
    try:
        body = text.split(START, 1)[1].split(END, 1)[0]
    except IndexError:
        return ""
    return body.strip()


def main() -> int:
    sys.stdin.read()  # フック入力は使わないが、読み捨てないと書き手側が壊れる
    try:
        items = checklist(SKILL.read_text(encoding="utf-8"))
    except OSError:
        return 0
    if not items:
        return 0
    context = (
        "ユーザーへのメッセージを書く前に、この点検項目に照らす。"
        f"型の全文は {SKILL} と "
        "/Users/yoshitogoto/dotfiles/shared/refs/communication.md にある。\n\n"
        f"{START}\n\n{items}"
    )
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "UserPromptSubmit",
                "additionalContext": context,
            },
            "suppressOutput": True,
        },
        sys.stdout,
        ensure_ascii=False,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
