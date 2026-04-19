# Anker Prep RAG Repository

## What this repo enforces
- Rule-first answering behavior for Claude Code.
- Evidence-backed retrieval for Anker values and test preparation.

## Files
- `CLAUDE.md`: hard execution order and output gate.
- `rag/rules_contract_v1_zh.md`: machine-checkable style/format rules.
- `rag/anker_values_rag_v1_zh.md`: chunked RAG knowledge base.
- `rag/source_index_v1.md`: citation registry `[Sxx] -> URL`.

## Start Prompt (copy/paste)
```text
请严格按仓库规则执行本次任务：
1) 先读取 CLAUDE.md
2) 再读取 rag/rules_contract_v1_zh.md
3) 再读取 rag/anker_values_rag_v1_zh.md 和 rag/source_index_v1.md
4) 回答必须满足：
   - 提问题：只写“问题位置 + 问题本身”，不总结、不比喻
   - 总结：不使用比喻，不用比喻式重写
   - 若涉及代码修改：先完成思路，再只输出完整可执行命令，不输出完整代码
5) 最后追加“规则自检”并逐条标注是否违反 R-ASK-001 / R-SUM-001 / R-CODE-001
现在任务是：<把你的具体任务写在这里>
```

## Validation Checklist
- Rules loaded before retrieval: Yes
- Output contains no metaphor in summary: Yes
- Code-change requests produce commands only: Yes
- Final answer includes rule self-check: Yes
