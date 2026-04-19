#!/bin/bash
# smoke_check.sh — 结构化门禁。阻断"拼关键词假通过"。
# 用法:
#   ./scripts/smoke_check.sh output/case_xxx.md    # 主交付：校验 ACVD + Decision Ledger 结构
#   ./scripts/smoke_check.sh output/case_xxx.html  # 可选辅助：校验 HTML 结构

set -euo pipefail

FILE="${1:?用法: $0 <output_file.md|html>}"

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

check_count() {
  local label="$1"
  local pattern="$2"
  local min="$3"
  local n
  n=$(grep -ciE "$pattern" "$FILE" || true)
  n="${n:-0}"
  if [ "$n" -ge "$min" ]; then
    echo "  PASS: $label (found ${n}, >= ${min})"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label (found ${n}, need >= ${min})"
    FAIL=$((FAIL + 1))
  fi
}

# 提取 markdown 中指定标题 (任意级别 ## / ### / ####) 下的正文，
# 终止条件：遇到下一个任意级别 markdown 标题。
extract_section() {
  local name="$1"
  awk -v name="$name" '
    $0 ~ "^#+[[:space:]]+" name "[[:space:]]*$" { in_sec = 1; next }
    /^#+[[:space:]]+/ { if (in_sec) exit }
    in_sec { print }
  ' "$FILE"
}

# 统计指定 section 下顶层 markdown 列表项数量（以 "- " 开头，列 0）。
check_section_items() {
  local label="$1"
  local section="$2"
  local min="$3"
  local content
  content=$(extract_section "$section" || true)
  if [ -z "$content" ]; then
    echo "  FAIL: ${label} (section '${section}' 不存在或为空)"
    FAIL=$((FAIL + 1))
    return
  fi
  local n
  n=$(echo "$content" | grep -cE '^-[[:space:]]+' || true)
  n="${n:-0}"
  if [ "$n" -ge "$min" ]; then
    echo "  PASS: ${label} (${section} 列表项 ${n}, >= ${min})"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ${label} (${section} 列表项 ${n}, 需 >= ${min})"
    FAIL=$((FAIL + 1))
  fi
}

# 校验 Decision Ledger 段：每条 decision（顶层 "- " 列表项）
# 必须在其子行中同时包含 owner: / threshold: / trigger: / rollback: 四字段。
check_decision_fields() {
  local label="Decision Ledger 4 字段齐全"
  local content
  content=$(extract_section "Decision Ledger" || true)
  if [ -z "$content" ]; then
    echo "  FAIL: ${label} (Decision Ledger 不存在)"
    FAIL=$((FAIL + 1))
    return
  fi
  local result good bad
  result=$(echo "$content" | awk '
    BEGIN { chunk = ""; good = 0; bad = 0 }
    function check_chunk() {
      if (chunk == "") return
      if (chunk ~ /owner:/ && chunk ~ /threshold:/ && chunk ~ /trigger:/ && chunk ~ /rollback:/) {
        good++
      } else {
        bad++
      }
    }
    /^-[[:space:]]+/ { check_chunk(); chunk = $0; next }
    chunk != "" { chunk = chunk "\n" $0 }
    END { check_chunk(); print good " " bad }
  ')
  good=$(echo "$result" | awk '{print $1}')
  bad=$(echo "$result" | awk '{print $2}')
  good="${good:-0}"
  bad="${bad:-0}"
  if [ "$bad" -eq 0 ] && [ "$good" -ge 3 ]; then
    echo "  PASS: ${label} (${good} decisions, 全部 4 字段 OK)"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: ${label} (OK ${good}, 缺字段 ${bad}, 需 >= 3 全 OK)"
    FAIL=$((FAIL + 1))
  fi
}

ext="${FILE##*.}"
echo "=== 门禁检查 (.${ext}): ${FILE} ==="
echo ""

if [ "$ext" = "md" ]; then
  # 自动分流：按特征识别交付形态（轻量 L1 / 完整版 L3）
  HAS_FULL=0
  if grep -qE "^#+[[:space:]]+STEP-1" "$FILE" || grep -qE "^#+[[:space:]]+Decision Ledger[[:space:]]*$" "$FILE"; then
    HAS_FULL=1
  fi
  HAS_LITE=0
  if grep -qE "^#+[[:space:]]+当前判断[[:space:]]*$" "$FILE" && grep -qE "^#+[[:space:]]+下一步动作[[:space:]]*$" "$FILE"; then
    HAS_LITE=1
  elif grep -qE "^#+[[:space:]]+Now[[:space:]]*$" "$FILE" && grep -qE "^#+[[:space:]]+Next[[:space:]]*$" "$FILE"; then
    HAS_LITE=1
  fi

  if [ "$HAS_FULL" = "1" ]; then
    MODE="full"
  elif [ "$HAS_LITE" = "1" ]; then
    MODE="lite"
  else
    echo "FAIL: 无法识别的交付形态（需 STEP-1 + Decision Ledger 或 当前判断 + 下一步动作 段落）"
    exit 2
  fi
  echo "[识别模式] ${MODE}"
  echo ""

  if [ "$MODE" = "full" ]; then
    echo "[六步引擎关键词]"
    check "STEP-1" "STEP-1"
    check "STEP-2" "STEP-2"
    check "STEP-3" "STEP-3"
    check "STEP-4" "STEP-4"
    check "STEP-5" "STEP-5"
    check "STEP-6" "STEP-6"

    echo ""
    echo "[ACVD 硬结构]"
    check_section_items "Axioms >= 2 条" "Axioms" 2
    check_section_items "Constraints >= 2 条" "Constraints" 2
    check_section_items "Variables >= 2 条" "Variables" 2

    echo ""
    echo "[Decision Ledger]"
    check_section_items "Decision Ledger >= 3 条" "Decision Ledger" 3
    check_decision_fields

    echo ""
    echo "[证据引用]"
    check "[S01] 引用" "\[S01\]"

    echo ""
    echo "[规则自检]"
    check "R-ASK-001" "R-ASK-001"
    check "R-ASK-002" "R-ASK-002"
    check "R-LANG-001" "R-LANG-001"
    check "R-FMT-001" "R-FMT-001"
    check "R-SUM-001" "R-SUM-001"
    check "R-CODE-001" "R-CODE-001"

    echo ""
    echo "[配套 HTML（可选）]"
    html_path="${FILE%.md}.html"
    if [ -f "$html_path" ]; then
      echo "  INFO: 找到可选 HTML: ${html_path}"
      echo "  提示: 运行 $0 ${html_path} 可额外校验 HTML 结构"
    else
      echo "  INFO: 无配套 HTML（可选产物，不影响通过）"
    fi
  else
    # 轻量门禁（L1 轻量输出）
    echo "[L1 四段结构]"

    # 当前判断: 段存在，非空行 1..3（兼容旧标题 Now）
    now_content=$(extract_section "当前判断" || true)
    if [ -z "$now_content" ]; then
      now_content=$(extract_section "Now" || true)
    fi
    if [ -z "$now_content" ]; then
      echo "  FAIL: 当前判断 段不存在或为空"
      FAIL=$((FAIL + 1))
    else
      now_lines=$(echo "$now_content" | awk 'NF>0' | wc -l | tr -d ' ')
      now_lines="${now_lines:-0}"
      if [ "$now_lines" -ge 1 ] && [ "$now_lines" -le 3 ]; then
        echo "  PASS: 当前判断 段存在（非空行 ${now_lines}, 在 1..3 范围）"
        PASS=$((PASS + 1))
      else
        echo "  FAIL: 当前判断 段非空行 ${now_lines}, 需 1..3"
        FAIL=$((FAIL + 1))
      fi
    fi

    # 下一步动作: 段存在，含 if/then 或 触发/则（兼容旧标题 Next）
    next_content=$(extract_section "下一步动作" || true)
    if [ -z "$next_content" ]; then
      next_content=$(extract_section "Next" || true)
    fi
    if [ -z "$next_content" ]; then
      echo "  FAIL: 下一步动作 段不存在"
      FAIL=$((FAIL + 1))
    elif echo "$next_content" | grep -qiE "if[[:space:]].*then|触发|则"; then
      echo "  PASS: 下一步动作 段含触发条件 + 动作"
      PASS=$((PASS + 1))
    else
      echo "  FAIL: 下一步动作 段缺 if/then 或 触发/则 关键词"
      FAIL=$((FAIL + 1))
    fi

    # 不确定的问题: 上限 3 条（兼容旧标题 Blockers）
    blockers_content=$(extract_section "不确定的问题" || true)
    if [ -z "$blockers_content" ]; then
      blockers_content=$(extract_section "Blockers" || true)
    fi
    if [ -z "$blockers_content" ]; then
      echo "  FAIL: 不确定的问题 段不存在"
      FAIL=$((FAIL + 1))
    else
      blockers_n=$(echo "$blockers_content" | grep -cE '^-[[:space:]]+' || true)
      blockers_n="${blockers_n:-0}"
      if [ "$blockers_n" -le 3 ]; then
        echo "  PASS: 不确定的问题 条数 ${blockers_n} (<=3)"
        PASS=$((PASS + 1))
      else
        echo "  FAIL: 不确定的问题 条数 ${blockers_n}, 上限 3（超出须降级到 默认假设）"
        FAIL=$((FAIL + 1))
      fi
    fi

    # 默认假设: 段存在，含 assumed 或 假设（兼容旧标题 Assumptions）
    assumptions_content=$(extract_section "默认假设" || true)
    if [ -z "$assumptions_content" ]; then
      assumptions_content=$(extract_section "Assumptions" || true)
    fi
    if [ -z "$assumptions_content" ]; then
      echo "  FAIL: 默认假设 段不存在"
      FAIL=$((FAIL + 1))
    elif echo "$assumptions_content" | grep -qiE "assumed|假设"; then
      echo "  PASS: 默认假设 段含 assumed/假设 标注"
      PASS=$((PASS + 1))
    else
      echo "  FAIL: 默认假设 段缺 assumed/假设 标注"
      FAIL=$((FAIL + 1))
    fi

    echo ""
    echo "[中文标签规则 R-LANG-001]"
    # 检查 1：整行英文标题（## Now / ## Blockers 等）
    # 检查 2：中英混写标题（## 不确定的问题（Blockers） / ## Blockers（P0/P1） 等）
    lang_hit=$(grep -nE "^#+[[:space:]]+(Now|Next|Blockers?|Assumptions?|Evidence|Self-check)([[:space:]]|$|（|\()" "$FILE" || true)
    lang_mix_hit=$(grep -nE "^#+[[:space:]]+[^#]*[（(][[:space:]]*(Now|Next|Blockers?|Assumptions?|Evidence|Self-check)" "$FILE" || true)
    if [ -n "$lang_hit" ] || [ -n "$lang_mix_hit" ]; then
      echo "  FAIL: L1 标题含英文或中英混写（R-LANG-001）"
      [ -n "$lang_hit" ] && echo "    命中：${lang_hit}"
      [ -n "$lang_mix_hit" ] && echo "    混写：${lang_mix_hit}"
      FAIL=$((FAIL + 1))
    else
      echo "  PASS: L1 标题全中文，无英文残留"
      PASS=$((PASS + 1))
    fi

    echo ""
    echo "[Meta 标题规则 R-FMT-001]"
    # 策略：扫描 "当前判断" 之前的所有行，不允许出现 meta 包装标记。
    # 命中条件（任一即 fail）：
    #   - 行以 L1/L2/L3 起头后跟空格和非空白（允许前导 #+ 空格）
    #   - 行含 "决策卡" / "决策 card" / "轻量卡片" / "分析卡"
    # 允许：文档顶部的 # H1 文档标题、frontmatter、空行、引用块、水平线。
    lines_before=$(awk '/^#*[[:space:]]*当前判断[[:space:]]*$/ { exit } { print }' "$FILE")
    meta_pre=$(echo "$lines_before" | grep -nE "^[[:space:]]*(#+[[:space:]]+)?(L[123][[:space:]]+[^[:space:]]|.*决策卡|.*决策[[:space:]]*card|.*轻量卡片|.*分析卡)" || true)
    if [ -n "$meta_pre" ]; then
      echo "  FAIL: '当前判断' 之前存在 meta 标题行（R-FMT-001）"
      echo "$meta_pre" | sed 's/^/    命中：/'
      FAIL=$((FAIL + 1))
    else
      echo "  PASS: '当前判断' 之前无 meta 包装"
      PASS=$((PASS + 1))
    fi

    echo ""
    echo "[证据引用]"
    check "[S01] 引用" "\[S01\]"

    echo ""
    echo "[规则自检]"
    check "R-ASK-001" "R-ASK-001"
    check "R-ASK-002" "R-ASK-002"
    check "R-LANG-001" "R-LANG-001"
    check "R-FMT-001" "R-FMT-001"
    check "R-SUM-001" "R-SUM-001"
    check "R-CODE-001" "R-CODE-001"
  fi

elif [ "$ext" = "html" ]; then
  echo "[HTML 文档骨架]"
  check "<!doctype html>" "<!doctype html>"
  check "<html> 根元素" "<html[[:space:]>]"
  check "<head>" "<head[[:space:]>]"
  check "<body>" "<body[[:space:]>]"

  echo ""
  echo "[段落结构]"
  check "<header>" "<header[[:space:]>]"
  check_count "<section> >= 3" "<section[[:space:]>]" 3
  check "<footer>" "<footer[[:space:]>]"

  echo ""
  echo "[表格语义]"
  check "<table>" "<table[[:space:]>]"
  check "<caption>" "<caption[[:space:]>]"
  check "<thead>" "<thead[[:space:]>]"
  check "<tbody>" "<tbody[[:space:]>]"
  check "<th scope=\"col|row\">" "<th[^>]*scope=[\"'](col|row)[\"']"

  echo ""
  echo "[KPI 8 字段]"
  check "metric_name" "metric_name"
  check "baseline" "baseline"
  check "target" "target"
  check "threshold" "threshold"
  check "owner" "owner"
  check "update_freq" "update_freq"
  check "risk_signal" "risk_signal"
  check "action_if_triggered" "action_if_triggered"

  echo ""
  echo "[证据引用]"
  check "[S01] 引用" "\[S01\]"

else
  echo "FAIL: 不支持的扩展名 .${ext} (仅支持 .md / .html)"
  exit 1
fi

echo ""
echo "=== 结果: ${PASS} 通过, ${FAIL} 未通过 ==="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
