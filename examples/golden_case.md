# Golden Case 示例：AI客服方案选型

> 本文件是满分输出锚点。Claude 输出应对齐此结构与密度。

---

## STEP-1 洞察本质（第一性）

**根问题**：在客服成本压缩 30% 的硬约束下，选择 AI 客服落地路径，使客户满意度不低于现有水平。

- 边界：仅覆盖售后文字客服，不含语音/售前。
- 核心约束：预算上限 200 万/年，上线周期 ≤ 3 个月，现有 CSAT ≥ 4.2/5.0。

---

## STEP-2 问题拆解

| # | 子问题 | 关键假设 |
|---|--------|----------|
| 1 | 哪些工单类型可被 AI 处理？ | 假设：标准化问题占比 ≥ 60% |
| 2 | AI 处理质量如何保证？ | 假设：可通过人工兜底控制质量下限 |
| 3 | 团队如何过渡？ | 假设：现有客服可转为 AI 训练/质检角色 |
| 4 | 如何衡量成功？ | 假设：CSAT + 解决率 + 成本三指标可同时追踪 |

---

## STEP-3 策略输出

### 主方案：分层部署

- Phase 1（第 1 月）：AI 处理 Top 5 高频标准问题（占工单量 ~40%），人工兜底。
- Phase 2（第 2–3 月）：扩展至 Top 15 问题类型，覆盖 ~65% 工单。
- 预期收益：客服人力成本降低 35%，CSAT 维持 4.1–4.3。

### 备选方案：全量外包 + AI 辅助

- 切换条件：Phase 1 上线后 AI 解决率 < 50% 或 CSAT 跌破 3.8。
- 实施成本：外包成本约 150 万/年，AI 辅助工具 50 万/年。
- 对主目标影响：成本节省收窄至 ~15%，但风险可控。

---

## STEP-4 审核优化

| 风险类型 | 风险点 | 监控指标 | 纠偏动作 |
|----------|--------|----------|----------|
| 质量风险 | AI 错答导致客诉上升 | 每日客诉率 | 客诉率 > 2% 时回退该问题类型至人工 |
| 进度风险 | 知识库搭建延迟 | 周完成工单类型数 | 延迟 > 1 周时缩减 Phase 1 覆盖范围 |
| 组织风险 | 客服团队抵触转型 | 月度离职率 | 离职率 > 10% 时启动转岗激励方案 |

---

## STEP-5 可视化呈现

```html
<table border="1" cellpadding="6" cellspacing="0" style="border-collapse:collapse; font-family:sans-serif; font-size:14px;">
  <thead style="background:#f0f0f0;">
    <tr>
      <th>metric_name</th>
      <th>baseline</th>
      <th>target</th>
      <th>threshold</th>
      <th>owner</th>
      <th>update_freq</th>
      <th>risk_signal</th>
      <th>action_if_triggered</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>AI 解决率</td>
      <td>0%</td>
      <td>65%</td>
      <td style="color:red;">&lt; 50% at Week 4</td>
      <td>AI 产品负责人</td>
      <td>每周</td>
      <td>连续 2 周低于 50%</td>
      <td>启动备选方案评估</td>
    </tr>
    <tr>
      <td>CSAT</td>
      <td>4.2</td>
      <td>≥ 4.1</td>
      <td style="color:red;">&lt; 3.8</td>
      <td>客服总监</td>
      <td>每日</td>
      <td>单日 CSAT &lt; 3.8</td>
      <td>暂停 AI 自动回复，全量转人工</td>
    </tr>
    <tr>
      <td>客服人力成本</td>
      <td>300 万/年</td>
      <td>≤ 200 万/年</td>
      <td style="color:red;">&gt; 250 万/年 at Month 3</td>
      <td>财务 BP</td>
      <td>每月</td>
      <td>Phase 2 后成本未下降</td>
      <td>审计 AI 覆盖率与人工兜底比例</td>
    </tr>
    <tr>
      <td>客诉率</td>
      <td>1.5%</td>
      <td>≤ 2%</td>
      <td style="color:red;">&gt; 2%</td>
      <td>质检主管</td>
      <td>每日</td>
      <td>连续 3 日 &gt; 2%</td>
      <td>回退该问题类型至人工处理</td>
    </tr>
  </tbody>
</table>
```

---

## STEP-6 最终方案

**主判定**：采用分层部署方案，Phase 1 聚焦 Top 5 高频问题，Phase 2 扩展至 65% 覆盖率。

**备选方案**：若 AI 解决率不达标，切换至外包 + AI 辅助模式。

**关键风险**：AI 错答客诉（日监控）、知识库进度（周监控）、团队离职（月监控）。

**证据**：本方案遵循"先业务问题后技术方案"原则 [S01]，业务抉择基于"价值产出、资源效率、执行可控性"三维判定 [S01][S10]，团队过渡参考"找对人、分好钱、责任边界"框架 [S01][S08][S11]。

---

## 规则自检

- R-ASK-001: No（未在回答中提问）
- R-SUM-001: No（无比喻）
- R-CODE-001: N/A（无代码场景）
