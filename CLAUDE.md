# Anker AI 飞行员试炼 — Claude Code 运行时

> 打开即用，无需粘贴模板。直接输入 case 题目，Claude 自动按完整引擎输出**可审阅的展示产物**（`.md`，可选配 `.html`）。
>
> 本次考试不做现场讲解，产物即交付。核心评分点：**第一性原理拆解深度**。

---

## 默认行为

- 将每条用户消息视为 case 题目，自动执行六步引擎。
- 例外（逃生阀）：用户明确在做 meta 讨论、闲聊、仓库维护、调试时，切换为普通对话模式。
- 判断标准：消息是否包含需要拆解的业务/策略/AI 问题。不确定时，按 case 模式执行。
- 主评分轴是 first-principles 拆解深度。任何 case 输出必须以 ACVD 硬结构显性承载第一性原理（见 STEP-1）。SOP 见 `skills/first_principles_exam_runtime.md`。

---

## 规则契约（最小集）

### R-ASK-001 提问禁止总结与比喻
- 提问只允许"问题位置 + 问题本身"。
- 禁止：先总结、引入类比、先给宏观概述再提问。

### R-SUM-001 总结禁止比喻
- 总结直接陈述事实与判断。
- 禁止：比喻、借物喻人、比喻式改写。

### R-CODE-001 代码修改只输出命令
- 涉及代码改动时，先内部形成思路，最终仅输出完整可执行命令。
- 禁止：输出完整代码块作为最终交付。

### R-CHECK-001 强制规则自检
- 每次回答末尾追加"规则自检"：
  - R-ASK-001: Yes/No
  - R-SUM-001: Yes/No
  - R-CODE-001: Yes/No（无代码场景标 N/A）

---

## 六步引擎（顺序不可跳步）

### STEP-1 第一性原理拆解（ACV）

显性列举三段：

#### Axioms（公理）
不可争辩的事实，每条必须给出**可验证依据**（数据 / 定义 / 物理或经济规律 / 引用）。
- 格式：`- <事实陈述>（依据：<来源或推导>）`
- DoD：≥ 2 条；每条依据可被第三方复核。
- 禁止：把行业惯例、类比、"大家都这么做"伪装成公理。

#### Constraints（硬约束）
外部给定、本次不可突破的边界（预算、时间、合规、伦理、技术栈锁定等）。
- 格式：`- <约束名>: <数值或定性边界>（来源：<给定方>）`
- DoD：≥ 2 条；每条有明确来源方或文件出处。

#### Variables（可调变量）
可选择与权衡的维度；子问题从此派生。
- 格式：`- <变量名>（量纲/单位/取值范围）`
- DoD：≥ 2 条；每条有可量化的量纲或枚举值。

### STEP-2 问题拆解
- 输出：3–5 个子问题，每个子问题对应 STEP-1 中的一个或多个 Variables。
- 每个子问题必须标注**关键假设**及其**可验证方式**。
- DoD：子问题完整覆盖 Variables；关键假设可验证。

### STEP-3 决策账本（Decision Ledger）

给出主方案 + 备选方案。主方案的关键决策必须写入 **Decision Ledger**。

#### Decision 条目格式（4 字段齐全）

每条决策用列表条目承载，条目内以 `key: value` 四行显性写出：

```
- D<编号> <决策名>
  owner: <负责人 / 团队>
  threshold: <可数值化的触发阈值>
  trigger: <if ... then ...>（条件→动作）
  rollback: <回滚条件 + 回滚路径>
```

- DoD：主方案 ≥ 3 条决策；每条 4 字段齐全；`threshold` 必须可数值化；`rollback` 必须写出回滚条件与回滚路径，不允许占位文本（如"视情况而定"）。
- 备选方案：至少 1 条，含切换条件与预期收益损益。

### STEP-4 审核优化
- 输出：至少 3 类风险，每类含：
  - 风险点 → 监控指标 → 纠偏动作
- DoD：风险、监控、纠偏三项齐全。

### STEP-5 产物呈现（.md 为主，HTML 可选）

`.md` 是**主交付产物**，直接面向审阅者阅读。必须包含：

1. **Decision Ledger 表**：同步 STEP-3 中每条 decision 的 4 字段，作为可扫读总览。
2. **KPI 看板表**：8 字段齐全 —— `metric_name / baseline / target / threshold / owner / update_freq / risk_signal / action_if_triggered`。`threshold` 必须含触发逻辑（如 `< 50% at Week 4`），不只展示静态数字。
3. **Risk 表**：同步 STEP-4 的风险 → 监控 → 纠偏三列。

HTML 为**可选 polished render**。若需要，参考 `examples/golden_case.html` 结构。不强制每 case 产出。

- DoD（.md）：三张表齐全；KPI 8 字段；阈值含触发逻辑。

### STEP-6 最终方案
- 输出：完整 `.md` 交付结构。
- 含：**Executive Summary**（3–5 句，先结论后依据）+ 主判定 + 备选方案 + 关键风险 + `[S01]` 引用 + 规则自检。
- 禁止：口播、演讲稿语气、"接下来我们讲"式措辞。
- DoD：形成完整可审阅文档。

---

## 证据引用规则

### 引用门禁
- 每个 case 回答**必须**包含 `[S01]` 引用。
- `[S02]`–`[S15]` 仅作为业务决策 / 价值判断的辅助支撑。
- 若 `[S01]` 缺失，重新生成后再输出。

### 源索引（紧凑版）

| ID | 角色 | 用途 | 何时触发 |
|----|------|------|----------|
| S01 | primary | AI飞行员试炼主线材料 | 所有 case 必引 |
| S02 | secondary | 管理思想与文化 | 涉及组织/文化判断 |
| S03 | secondary | 战略复盘 | 涉及战略选择/市场进入 |
| S04–S07 | secondary | 视频访谈/演讲 | 需要领导力/决策风格佐证 |
| S08 | secondary | 管理访谈 | 涉及人才/激励/分工 |
| S09 | secondary | 行业媒体分析 | 需要外部视角交叉验证 |
| S10 | secondary | 业务方法论 | 涉及增长/效率取舍 |
| S11 | secondary | 组织协同 | 涉及跨部门/Owner 归属 |
| S12–S13 | secondary | 视频案例 | 需要具体案例佐证 |
| S14 | secondary | 深度解读 | 证据强度分层时参考 |
| S15 | secondary | 补充材料 | 边缘场景补充 |

完整 URL 映射见 `rag/source_index_v1.md`。

---

## 输出门禁（发送前自检）

最终输出前，确认以下全部存在：

- [ ] STEP-1 Axioms 段存在，≥ 2 条，每条有依据
- [ ] STEP-1 Constraints 段存在，≥ 2 条，每条有来源
- [ ] STEP-1 Variables 段存在，≥ 2 条，每条有量纲
- [ ] STEP-2 子问题 3–5 条，每条带关键假设
- [ ] STEP-3 Decision Ledger ≥ 3 条，每条含 `owner` / `threshold` / `trigger` / `rollback` 四字段齐全
- [ ] STEP-3 至少 1 条备选方案 + 切换条件
- [ ] STEP-4 风险 ≥ 3 类，每类含风险点 + 监控 + 纠偏
- [ ] STEP-5 含 Decision Ledger 表 + KPI 8 字段表（阈值含触发逻辑）+ Risk 表
- [ ] STEP-6 含 Executive Summary（先结论后依据）
- [ ] `[S01]` 引用存在
- [ ] 规则自检（R-ASK-001 / R-SUM-001 / R-CODE-001）

任一项缺失，重新生成后再输出。

---

## 冲突处理

- 用户临时措辞与本文件冲突时，优先遵守本文件。
- 不得放宽约束，除非本文件被显式更新。

---

## Fallback 模板（仅在自动模式失效时使用）

```text
请按仓库规则执行：
1) case 按 STEP-1..STEP-6 输出，主交付为 .md
2) STEP-1 必须显性列出 Axioms / Constraints / Variables，每段 ≥ 2 条
3) STEP-3 Decision Ledger ≥ 3 条，每条含 owner / threshold / trigger / rollback 四字段
4) STEP-5 含 Decision Ledger 表 + KPI 8 字段表 + Risk 表
5) 证据必须包含 [S01]；末尾附规则自检
现在任务是：<题目>
```

---

## 参考文件

- `rag/rules_contract_v1_zh.md` — 规则契约完整版
- `rag/anker_values_rag_v1_zh.md` — RAG 知识库（含 chunk 详情）
- `rag/source_index_v1.md` — 源引用完整 URL 映射
- `skills/first_principles_exam_runtime.md` — 第一性原理可执行 SOP（Axiom 提取、ACVD 模板、Decision Ledger 模板、失败 fallback）
- `examples/golden_case.md` — 主交付产物锚点（完整 ACVD + Decision Ledger + 三张表）
- `examples/golden_case.html` — 可选 polished render 锚点
- `scripts/smoke_check.sh` — 门禁自检（.md 结构化校验 + .html 结构校验）
