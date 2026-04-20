# Skill: Final Artifact Assembly（多轮收敛到最终交付物）

> 目的：考试 Phase 3 触发时（用户说 `/finalize` / `做最终交付` 等），把多轮累积的 L1 内容收敛成一份**可审阅、可提交**的最终交付物 —— 主交付 .md，必要时配套 HTML。
>
> 触发条件：用户消息含 `/finalize` / `做最终交付` / `给我最终交付物` / `给我考试 final` / `完整版` / `L3` / `full report` 之一，或 `skills/exam_progression_v1.md` 判定进入 Phase 3。

---

## 收敛 SOP（4 步）

### Step A：盘点多轮内容

从对话历史中抽取以下要素（按出现顺序）：

| 抽取目标 | 从历史哪里找 |
|---------|-----------|
| Axioms（公理） | 内部 ACVD 记录 + 历轮 `当前判断` 与 `证据` 段 |
| Constraints（约束） | 题目原文 + 用户在多轮中补充的约束 |
| Variables（变量） | 历轮 `假定分支` 段中的分支条件 |
| 已用户拍板的方向 | 用户消息中的 "走 X" / "选 A" / "用 B 方法" |
| 默认假设（未拍板） | 历轮 `默认假设` 段聚合 |
| 关键证据 | 历轮 `证据` 段（带锚点） |

### Step B：题型 → 交付物形态映射

按题目原文判定输出形态：

| 题目特征 | 主交付 | 配套 HTML |
|---------|-------|----------|
| 含"生成 HTML" / "做一个网页" / "对比波形/频谱/音频" | .md（含分析） | **必须配 HTML**（含可视化 + 音频 player + 频谱图） |
| 含"小程序" / "面板" / "dashboard" | .md（含分析） + Decision Ledger 表 + KPI 表 | 可选 HTML mock 面板（含 wireframe） |
| 含"分析" / "策略" / "方案" 但无可视化要求 | .md（STEP-1..STEP-6 全量） | 可选（用户显式要才出） |
| 题目纯技术 SOP / 算法选型 | .md（含 ACVD + 算法对比表） | 可选（涉及对比时配） |

heuristic：宁可多出 HTML 也不要漏。题目里只要出现"对比" / "可视化" / "图" / "看板"任一关键词，默认配 HTML。

### Step C：组装 .md（按 STEP-1..STEP-6）

```markdown
# <题目简述> — 最终方案

## Executive Summary
（3-5 句，先结论后依据。综合多轮收敛后的主判定 + 关键风险）

## STEP-1 第一性原理拆解

### Axioms
- <axiom 1>（依据：...）
- <axiom 2>（依据：...）

### Constraints
- <constraint 1>: <值>（来源：题目 / 用户补充第 N 轮）
- <constraint 2>: ...

### Variables
- <variable 1>（量纲，取值范围）
- <variable 2>: ...

## STEP-2 问题拆解
- 子问题 1: ...（关键假设：...，可验证方式：...）
- 子问题 2-5: ...

## STEP-3 决策账本（Decision Ledger）

### 主方案
- D1 <决策名>
  owner: ...
  threshold: ...
  trigger: if ... then ...
  rollback: ...
- D2, D3 同上（≥ 3 条）

### 备选方案
- 备选 A: <名> | 切换条件: ... | 预期收益损益: ...

## STEP-4 风险审核

| 风险点 | 监控指标 | 纠偏动作 |
|-------|---------|---------|
| ≥ 3 行 | | |

## STEP-5 交付呈现（看板）

### Decision Ledger 速览表
| ID | 决策 | owner | threshold | trigger | rollback |
|----|------|-------|-----------|---------|----------|

### KPI 看板（8 字段）
| metric_name | baseline | target | threshold | owner | update_freq | risk_signal | action_if_triggered |
|------------|----------|--------|-----------|-------|-------------|-------------|---------------------|

### Risk 表
（同 STEP-4 表）

## STEP-6 最终方案
- 主判定: ...
- 备选方案: ...
- 关键风险 + 已设缓释: ...
- 用户已拍板的方向（multi-turn 来源）:
  - 第 N 轮: 用户选定 X
  - 第 N+1 轮: 用户拍板 Y

## 证据
- [S01]（支撑 Executive Summary 中 "<论点>"）：<内容>
- [S02-Sxx]（按需，每条带锚点）
```

### Step D：组装 HTML（仅在 Step B 判定需要时）

骨架结构（参考 `examples/golden_case.html`）：

```html
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <title><题目简述> — 最终方案</title>
  <!-- 内联 CSS，不依赖 CDN -->
</head>
<body>
  <header>
    <h1><题目简述></h1>
    <p>Executive Summary</p>
  </header>

  <section id="visualization">
    <!-- 必填：题目要求的可视化对比 -->
    <!-- 音频题：waveform canvas + spectrogram + audio player（处理前/后） -->
    <!-- 数据题：图表 / KPI 卡片 -->
    <!-- 流程题：流程图（SVG / mermaid 内联） -->
  </section>

  <section id="decisions">
    <table>
      <caption>Decision Ledger</caption>
      <thead><tr><th scope="col">ID</th><th scope="col">决策</th>...</tr></thead>
      <tbody>...</tbody>
    </table>
  </section>

  <section id="kpi">
    <table>
      <caption>KPI 看板</caption>
      <thead>
        <tr>
          <th scope="col">metric_name</th>
          <th scope="col">baseline</th>
          <th scope="col">target</th>
          <th scope="col">threshold</th>
          <th scope="col">owner</th>
          <th scope="col">update_freq</th>
          <th scope="col">risk_signal</th>
          <th scope="col">action_if_triggered</th>
        </tr>
      </thead>
      <tbody>...</tbody>
    </table>
  </section>

  <section id="risks">
    <table>
      <caption>Risk 表</caption>
      ...
    </table>
  </section>

  <footer>
    <p>证据：[S01](支撑 ...)：...</p>
  </footer>
</body>
</html>
```

KPI 8 字段必须出现在 HTML 中（`scripts/smoke_check.sh` 的 HTML 模式会强制校验）。

---

## 输出存盘建议（用户视角）

模型在 Phase 3 输出后，告诉用户怎么存：

```
建议存盘路径：
- output/<case_short_name>.md
- output/<case_short_name>.html（如有）

跑门禁验证：
./scripts/smoke_check.sh output/<case_short_name>.md
./scripts/smoke_check.sh output/<case_short_name>.html
```

---

## 不该做的

- ❌ Phase 3 输出还保留 L1 6 段标题（应直接进入 STEP-1..STEP-6 全量结构）
- ❌ 把多轮中所有未拍板的 `请你拍板的方向` 留在 .md 里（应在 Step A 收敛时全部转为 `默认假设` 或固化进 D 决策）
- ❌ 漏掉 HTML 触发判据（音频题没出 HTML = 失分）
- ❌ KPI 表少于 8 字段（自动门禁会 FAIL）
- ❌ 证据无 R-EVID-001 锚点（自动门禁会 FAIL）

---

## 与其它文件的关系

- 多轮节奏触发条件见 `skills/exam_progression_v1.md`
- ACVD 模板和 Axiom 提取规则见 `skills/first_principles_exam_runtime.md`
- L3 锚点示例见 `examples/golden_case.md` 与 `examples/golden_case.html`
- 门禁脚本见 `scripts/smoke_check.sh`
