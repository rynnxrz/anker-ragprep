#!/bin/bash
# smoke_check.sh — 检查 case 输出是否满足门禁要求
# 用法: ./scripts/smoke_check.sh output/case_xxx.md

set -euo pipefail

FILE="${1:?用法: $0 <output_file.md>}"

if [ ! -f "$FILE" ]; then
  echo "FAIL: 文件不存在: $FILE"
  exit 1
fi

PASS=0
FAIL=0

check() {
  local label="$1"
  local pattern="$2"
  if grep -qiE "$pattern" "$FILE"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== 门禁检查: $FILE ==="
echo ""

echo "[六步引擎]"
check "STEP-1 洞察本质" "STEP-1"
check "STEP-2 问题拆解" "STEP-2"
check "STEP-3 策略输出" "STEP-3"
check "STEP-4 审核优化" "STEP-4"
check "STEP-5 可视化呈现" "STEP-5"
check "STEP-6 最终方案" "STEP-6"

echo ""
echo "[证据引用]"
check "[S01] 引用" "\[S01\]"

echo ""
echo "[HTML 看板字段]"
check "metric_name" "metric_name"
check "baseline" "baseline"
check "target" "target"
check "threshold" "threshold"
check "owner" "owner"
check "update_freq" "update_freq"
check "risk_signal" "risk_signal"
check "action_if_triggered" "action_if_triggered"

echo ""
echo "[规则自检]"
check "R-ASK-001" "R-ASK-001"
check "R-SUM-001" "R-SUM-001"
check "R-CODE-001" "R-CODE-001"

echo ""
echo "=== 结果: $PASS 通过, $FAIL 未通过 ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
