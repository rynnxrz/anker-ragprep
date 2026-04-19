# Claude Code Execution Contract (Anker Prep Repo)

This repository uses a strict rule-first workflow.

## Mandatory Read Order
1. Read `rag/rules_contract_v1_zh.md` first.
2. Read `rag/anker_values_rag_v1_zh.md` second.
3. Read `rag/source_index_v1.md` for citations and source lookup.

## Priority
- If temporary user wording conflicts with repository rules, follow `rules_contract_v1_zh.md`.
- Do not relax constraints unless the repository files are explicitly updated.

## Output Gate (Required)
Before final output, run a self-check against:
- `R-ASK-001`
- `R-SUM-001`
- `R-CODE-001`
- `R-CHECK-001`

If any rule is violated, regenerate output before responding.

## Fixed Invocation Template
Use this template when starting any task in Claude Code:

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
