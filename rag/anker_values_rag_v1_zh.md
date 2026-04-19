# Anker Values RAG v1 (ZH)

## Usage
- Retrieval unit: section-level chunk.
- Required fields per chunk:
  - `chunk_id`
  - `结论`
  - `证据`
  - `适用场景`
  - `citations`
  - `related_rules`
- Case answers must follow six steps:
  - `STEP-1 洞察本质（第一性）`
  - `STEP-2 问题拆解`
  - `STEP-3 策略输出`
  - `STEP-4 审核优化`
  - `STEP-5 可视化呈现`
  - `STEP-6 最终方案`
- Evidence gate for case answers:
  - Must include `[S01]`
  - `S02..S15` only for business decision support and value-based audit

---

## Chunk: AIP-01
- `chunk_id`: AIP-01
- `结论`: AI飞行员试炼题目作答主线应优先体现“问题定义清晰、结构化求解、可执行落地”。
- `证据`:
  - 试炼导向强调候选人对复杂问题的拆解与执行能力，而非空泛表述。
  - 作答过程要求从理解问题到给出可落地方案的完整链路。
- `适用场景`: 所有 AI 飞行员试炼 case 的开场框架。
- `citations`: [S01]
- `related_rules`: [R-SUM-001, R-CHECK-001]

## Chunk: AIP-02
- `chunk_id`: AIP-02
- `结论`: 对于 AI + 业务题，先明确业务目标和约束，再选择AI能力与实现路径。
- `证据`:
  - 主线材料强调“先业务问题后技术方案”的思路，避免工具先行。
  - 有效方案需要在目标、资源、时效之间取得平衡。
- `适用场景`: 需要在业务影响与技术可行性之间做取舍的题目。
- `citations`: [S01]
- `related_rules`: [R-SUM-001, R-CHECK-001]

## Chunk: DEC-01
- `chunk_id`: DEC-01
- `结论`: 业务抉择题应基于“价值产出、资源效率、执行可控性”三维判定主方案。
- `证据`:
  - 安克价值观材料强调资源取舍与执行闭环。
  - 组织协同与分工激励常作为可持续执行条件。
- `适用场景`: 增长 vs 成本、速度 vs 风险、短期 vs 长期等冲突目标题。
- `citations`: [S01][S02][S10]
- `related_rules`: [R-SUM-001, R-CHECK-001]

## Chunk: DEC-02
- `chunk_id`: DEC-02
- `结论`: 当题目涉及团队协作或组织机制时，需补充“找对人、分好钱、责任边界”判断。
- `证据`:
  - 管理访谈材料将人才质量与激励一致性视为执行质量前提。
  - 结构化分工可降低方案落地过程中的责任漂移风险。
- `适用场景`: 跨部门推进、Owner不清、执行延迟等案例。
- `citations`: [S01][S02][S08][S11]
- `related_rules`: [R-SUM-001, R-CHECK-001]

## Chunk: CASE-ENGINE-01
- `chunk_id`: CASE-ENGINE-01
- `结论`: 所有 case 必须按六步引擎输出，顺序不可跳步。
- `证据`:
  - 该引擎来自历史高分经验，适配 AI 飞行员试炼问题类型。
- `适用场景`: 任意 case 作答。
- `citations`: [S01]
- `related_rules`: [R-ASK-001, R-SUM-001, R-CHECK-001]

## Chunk: CASE-ENGINE-02
- `chunk_id`: CASE-ENGINE-02
- `结论`: 六步完成标准（DoD）用于交付前验收。
- `证据`:
  - STEP-1 DoD: 根问题、边界、约束明确。
  - STEP-2 DoD: 子问题分解完整，关键假设可验证。
  - STEP-3 DoD: 主方案可执行且含量化指标。
  - STEP-4 DoD: 至少3类风险、监控指标、纠偏动作。
  - STEP-5 DoD: 有看板字段、阈值、异常信号说明。
  - STEP-6 DoD: 形成完整 `.md` 交付结构。
- `适用场景`: 回答前自查、审核窗口复核。
- `citations`: [S01]
- `related_rules`: [R-CHECK-001]

## Chunk: CASE-ENGINE-03
- `chunk_id`: CASE-ENGINE-03
- `结论`: 每题固定输出“主判定 + 备选方案 + 关键风险”。
- `证据`:
  - 主判定: 推荐方案、触发条件、预期收益。
  - 备选方案: 切换条件、实施成本、对主目标影响。
  - 关键风险: 风险点、监控指标、纠偏动作。
- `适用场景`: 业务抉择题与策略题。
- `citations`: [S01][S10][S11]
- `related_rules`: [R-SUM-001, R-CHECK-001]

## Chunk: CASE-ENGINE-04
- `chunk_id`: CASE-ENGINE-04
- `结论`: 可视化输出采用最小 HTML 看板字段集，保证可审计与可追踪。
- `证据`:
  - 最小字段: `metric_name`, `baseline`, `target`, `threshold`, `owner`, `update_freq`, `risk_signal`, `action_if_triggered`。
  - 必须给出阈值触发逻辑，不只展示静态数字。
- `适用场景`: STEP-5 可视化呈现。
- `citations`: [S01]
- `related_rules`: [R-CHECK-001]

## Chunk: CASE-OUTLINE-01
- `chunk_id`: CASE-OUTLINE-01
- `结论`: 标准交付骨架按 STEP-1..STEP-6 组织，结尾附规则自检。
- `证据`:
  - 结构稳定可减少答题漂移和漏项。
  - 统一骨架可提升双窗口协作效率。
- `适用场景`: 最终 `.md` 输出。
- `citations`: [S01]
- `related_rules`: [R-ASK-001, R-SUM-001, R-CODE-001, R-CHECK-001]

## Chunk: G-01
- `chunk_id`: G-01
- `结论`: 不确定或证据不足的表述必须标注“待核实”，不得作为确定结论输出。
- `证据`:
  - 多源材料存在解释差异，必须做证据强度分层。
- `适用场景`: 所有输出中的事实陈述质量控制。
- `citations`: [S01][S09][S14]
- `related_rules`: [R-SUM-001, R-CHECK-001]
