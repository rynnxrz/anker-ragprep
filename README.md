# Anker AI 飞行员试炼 — Claude Code Runtime

打开即用的仓库。核心是**第一性原理 ACVD 拆解 + Decision Ledger**。考试不做现场讲解，产物即交付。

## What

- Claude Code 运行时仓库。
- 主交付：`.md` 展示产物（含完整 ACVD + Decision Ledger + 三张表）。
- 辅助（可选）：polished `.html` 渲染。
- 核心评分轴：第一性原理拆解深度。

## How

1. 在此目录打开 Claude Code。
2. 直接输入 case 题目。
3. Claude 按 STEP-1..STEP-6 自动执行，输出落在 `output/case_xxx.md`。
4. 如需 polished 版本，再由同一 case 生成 `output/case_xxx.html`（可选）。

## Output 结构（主交付 .md）

```
STEP-1 第一性原理拆解
├── Axioms（≥ 2，每条有可验证依据）
├── Constraints（≥ 2，每条有来源）
└── Variables（≥ 2，每条有量纲）

STEP-2 问题拆解（3–5 子问题 + 假设 + 验证方式）

STEP-3 决策账本
├── 主方案
├── Decision Ledger（≥ 3 条，每条含 owner/threshold/trigger/rollback）
└── 备选方案 + 切换条件

STEP-4 风险审计（≥ 3 类，风险 → 监控 → 纠偏）

STEP-5 产物呈现
├── 表 A — Decision Ledger 汇总
├── 表 B — KPI 看板（8 字段）
└── 表 C — 风险审计

STEP-6 最终方案
├── Executive Summary（先结论后依据）
├── 主判定 + 备选 + 关键风险
├── [S01] 证据引用
└── 规则自检（R-ASK/SUM/CODE）
```

## Verify

```bash
./scripts/smoke_check.sh examples/golden_case.md    # 结构化校验（ACVD + Decision 4 字段 + [S01] + 自检）
./scripts/smoke_check.sh examples/golden_case.html  # 可选 HTML 结构校验
```

任一项 FAIL → 回到对应 STEP 修复后重输出。

## 目录结构

```
CLAUDE.md                                   # 运行时配置，Claude 自动加载
skills/first_principles_exam_runtime.md     # 第一性原理 SOP（Axiom 提取、ACVD 模板、Decision Ledger 模板）
rag/                                        # 规则契约 / 知识库 / 源索引
examples/                                   # 满分锚点（golden_case.md 主、golden_case.html 可选）
scripts/smoke_check.sh                      # 结构化门禁
output/                                     # 生成的 case 输出落盘处
```

## Fallback

如 Claude 未自动按引擎执行，粘贴 `CLAUDE.md` 底部的 Fallback 模板。
