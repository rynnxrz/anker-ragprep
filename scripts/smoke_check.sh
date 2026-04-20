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
  # 新 6 段：当前判断 + 假定分支 必须共存
  if grep -qE "^#+[[:space:]]+当前判断[[:space:]]*$" "$FILE" && grep -qE "^#+[[:space:]]+假定分支[[:space:]]*$" "$FILE"; then
    HAS_LITE=1
  # 旧段名兼容（历史文件，会在轻量门禁里报 FAIL）
  elif grep -qE "^#+[[:space:]]+当前判断[[:space:]]*$" "$FILE" && grep -qE "^#+[[:space:]]+下一步动作[[:space:]]*$" "$FILE"; then
    HAS_LITE=1
  elif grep -qE "^#+[[:space:]]+Now[[:space:]]*$" "$FILE" && grep -qE "^#+[[:space:]]+Next[[:space:]]*$" "$FILE"; then
    HAS_LITE=1
  fi

  if [ "$HAS_FULL" = "1" ]; then
    MODE="full"
  elif [ "$HAS_LITE" = "1" ]; then
    MODE="lite"
  else
    echo "FAIL: 无法识别的交付形态（需 STEP-1 + Decision Ledger 或 当前判断 + 假定分支 段落）"
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
    echo "[证据引用 + 锚点 R-EVID-001]"
    check "[S01] 引用" "\[S01\]"
    if grep -qE "[（(]支撑[[:space:]]" "$FILE"; then
      echo "  PASS: 含「（支撑 ...）」锚点格式（R-EVID-001）"
      PASS=$((PASS + 1))
    else
      echo "  FAIL: 证据引用缺「（支撑 <段名> 中 \"<论点>\"）」锚点（违反 R-EVID-001）"
      FAIL=$((FAIL + 1))
    fi

    echo ""
    echo "[规则自检 R-CHECK-001：默认应隐藏，不强制存在]"
    # R-CHECK-001 改为内部执行 + 默认隐藏。L3 最终交付物默认不应含 6 条 Yes/No。
    # 仅在 debug 模式产物里允许出现。
    rulecheck_section=$(extract_section "规则自检" || true)
    if [ -n "$rulecheck_section" ]; then
      rulecheck_hits=$(echo "$rulecheck_section" | grep -cE "R-(ASK|LANG|FMT|SUM|CODE|EVID|CHECK)-[0-9]+:" || true)
      rulecheck_hits="${rulecheck_hits:-0}"
      if [ "$rulecheck_hits" -ge 3 ]; then
        echo "  INFO: 末尾出现规则自检 ${rulecheck_hits} 条（debug 模式产物，不计入门禁）"
      else
        echo "  PASS: 无规则自检条目泄漏"
        PASS=$((PASS + 1))
      fi
    else
      echo "  PASS: 无 ## 规则自检 段（符合 R-CHECK-001 默认隐藏）"
      PASS=$((PASS + 1))
    fi

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
    # 轻量门禁（L1 6 段输出）
    echo "[L1 6 段结构]"

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

    # 假定分支: 段存在，含「假定情况」句式；禁 if/then（R-FMT-002）
    branches_content=$(extract_section "假定分支" || true)
    if [ -z "$branches_content" ]; then
      echo "  FAIL: 假定分支 段不存在（旧段名'下一步动作'已废弃）"
      FAIL=$((FAIL + 1))
    elif echo "$branches_content" | grep -qE "假定情况[[:space:]]*[0-9]+"; then
      # 检查是否还残留 if/then 触发器语法（R-FMT-002 违规）
      if_hit=$(echo "$branches_content" | grep -iE "if[[:space:]]+.*[[:space:]]+then[[:space:]]" || true)
      if [ -n "$if_hit" ]; then
        echo "  FAIL: 假定分支 段含 if/then 残留（违反 R-FMT-002）"
        echo "$if_hit" | sed 's/^/    命中：/'
        FAIL=$((FAIL + 1))
      else
        echo "  PASS: 假定分支 段用「假定情况 N」句式，无 if/then 残留"
        PASS=$((PASS + 1))
      fi
    else
      echo "  FAIL: 假定分支 段缺「假定情况 N」句式（违反 R-FMT-002）"
      FAIL=$((FAIL + 1))
    fi

    # 请你拍板的方向: 上限 3 条；多行展开格式；含 选项: + 我的推荐: + 理由: + 你怎么回复: 四块；禁 union 选项
    decisions_content=$(extract_section "请你拍板的方向" || true)
    if [ -z "$decisions_content" ]; then
      echo "  FAIL: 请你拍板的方向 段不存在（旧段名'不确定的问题'已废弃）"
      FAIL=$((FAIL + 1))
    else
      decisions_n=$(echo "$decisions_content" | grep -cE '^-[[:space:]]+决策点' || true)
      decisions_n="${decisions_n:-0}"
      # 兼容老示例：用顶层 "- " 计数（无"决策点"前缀时）
      if [ "$decisions_n" -eq 0 ]; then
        decisions_n=$(echo "$decisions_content" | grep -cE '^-[[:space:]]+' || true)
        decisions_n="${decisions_n:-0}"
      fi
      if [ "$decisions_n" -gt 3 ]; then
        echo "  FAIL: 请你拍板的方向 条数 ${decisions_n}, 上限 3（违反 R-ASK-002）"
        FAIL=$((FAIL + 1))
      elif [ "$decisions_n" -lt 1 ]; then
        echo "  FAIL: 请你拍板的方向 段为空（至少 1 条）"
        FAIL=$((FAIL + 1))
      else
        # 检查多行展开格式：必须含「选项:」「我的推荐:」「理由:」「你怎么回复:」四块
        miss_keys=""
        echo "$decisions_content" | grep -qE "选项[:：]" || miss_keys="${miss_keys} 选项:"
        echo "$decisions_content" | grep -qE "我的推荐[:：]" || miss_keys="${miss_keys} 我的推荐:"
        echo "$decisions_content" | grep -qE "理由[:：]" || miss_keys="${miss_keys} 理由:"
        echo "$decisions_content" | grep -qE "你怎么回复[:：]" || miss_keys="${miss_keys} 你怎么回复:"

        # 检查老格式残留：单行 ｜ 拼接（违反多行展开要求）
        bar_hit=$(echo "$decisions_content" | grep -E "[｜|]" | grep -E "选项|我建议|我的推荐" || true)

        # union 选项检测（R-CLARITY-001 改为不鼓励但不禁止；仅在缺"前 N 项叠加"标注时 WARN）
        union_hit=$(echo "$decisions_content" | grep -iE "(全部|全做|都要|三者都要|ABC[[:space:]]*都|A\+B\+C[[:space:]]*都)" || true)
        union_labeled=$(echo "$decisions_content" | grep -iE "前[[:space:]]*[0-9]+[[:space:]]*项叠加" || true)

        # R-RESEARCH-001 双轨研究痕迹检查：理由块应含「业界做法」+「第一性原理」两轨
        track_a=$(echo "$decisions_content" | grep -iE "(业界做法|best[[:space:]]*practice|轨道[[:space:]]*A)" || true)
        track_b=$(echo "$decisions_content" | grep -iE "(第一性原理|first[[:space:]]*principles|轨道[[:space:]]*B|公理)" || true)

        # R-CLARITY-001 术语引用痕迹检查（决策块里出现 [依据：…] 或 [S0x]）
        ref_hit=$(echo "$decisions_content" | grep -E "\[(依据|S[0-9]+)" || true)

        if [ -n "$miss_keys" ]; then
          echo "  FAIL: 请你拍板的方向 缺多行展开关键字段:${miss_keys}（每条需 选项: + 我的推荐: + 理由: + 你怎么回复:）"
          FAIL=$((FAIL + 1))
        elif [ -n "$bar_hit" ]; then
          echo "  FAIL: 请你拍板的方向 含旧格式「｜」单行拼接残留（违反多行展开要求）"
          echo "$bar_hit" | head -3 | sed 's/^/    命中：/'
          FAIL=$((FAIL + 1))
        else
          echo "  PASS: 请你拍板的方向 条数 ${decisions_n} (<=3)，多行展开格式齐全"
          PASS=$((PASS + 1))

          # union 选项软提示（不计 FAIL）
          if [ -n "$union_hit" ] && [ -z "$union_labeled" ]; then
            echo "  WARN: 检测到 union 风格关键词（全部/全做/都要 等）但未见「前 N 项叠加」标注（R-CLARITY-001：union 不禁止但需明确标注）"
            echo "$union_hit" | head -2 | sed 's/^/    命中：/'
          fi

          # 双轨研究痕迹软提示（不计 FAIL）
          if [ -z "$track_a" ] || [ -z "$track_b" ]; then
            echo "  WARN: 拍板项理由块缺双轨研究痕迹（R-RESEARCH-001 期望含「业界做法」+「第一性原理」两轨）"
            [ -z "$track_a" ] && echo "    缺：业界做法 / best practice / 轨道 A"
            [ -z "$track_b" ] && echo "    缺：第一性原理 / first principles / 轨道 B"
          fi

          # 术语引用痕迹软提示（不计 FAIL）
          if [ -z "$ref_hit" ]; then
            echo "  WARN: 拍板项未见 [依据：…] 或 [S0x] 引用（R-CLARITY-001：术语应带引用避免编造）"
          fi
        fi
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

    # 你的下一步: 新增段，必须存在且非空
    nextstep_content=$(extract_section "你的下一步" || true)
    if [ -z "$nextstep_content" ]; then
      echo "  FAIL: 你的下一步 段不存在"
      FAIL=$((FAIL + 1))
    else
      nextstep_lines=$(echo "$nextstep_content" | awk 'NF>0' | wc -l | tr -d ' ')
      nextstep_lines="${nextstep_lines:-0}"
      if [ "$nextstep_lines" -ge 1 ]; then
        echo "  PASS: 你的下一步 段存在（非空行 ${nextstep_lines}）"
        PASS=$((PASS + 1))
      else
        echo "  FAIL: 你的下一步 段为空"
        FAIL=$((FAIL + 1))
      fi
    fi

    echo ""
    echo "[中文标签规则 R-LANG-001]"
    # 检查 1：整行英文标题（## Now / ## Blockers 等）
    # 检查 2：中英混写标题
    lang_hit=$(grep -nE "^#+[[:space:]]+(Now|Next|Branches?|Blockers?|Assumptions?|Evidence|Self-check)([[:space:]]|$|（|\()" "$FILE" || true)
    lang_mix_hit=$(grep -nE "^#+[[:space:]]+[^#]*[（(][[:space:]]*(Now|Next|Branches?|Blockers?|Assumptions?|Evidence|Self-check)" "$FILE" || true)
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
    echo "[证据引用 + 锚点 R-EVID-001]"
    check "[S01] 引用存在" "\[S01\]"
    # 验证至少一处出现「（支撑」锚点（半角括号也可）
    if grep -qE "[（(]支撑[[:space:]]" "$FILE"; then
      echo "  PASS: 含「（支撑 ...）」锚点格式（R-EVID-001）"
      PASS=$((PASS + 1))
    else
      echo "  FAIL: 证据引用缺「（支撑 <段名> 中 \"<论点>\"）」锚点（违反 R-EVID-001）"
      FAIL=$((FAIL + 1))
    fi

    echo ""
    echo "[规则自检 R-CHECK-001：默认应隐藏]"
    # R-CHECK-001 改为内部执行 + 默认隐藏，对外输出不应再出现 6 条 Yes/No
    # 检测：若存在 ## 规则自检 段且段内含多条 R-XXX-NNN: Yes/No 即视为违规
    rulecheck_section=$(extract_section "规则自检" || true)
    if [ -n "$rulecheck_section" ]; then
      rulecheck_hits=$(echo "$rulecheck_section" | grep -cE "R-(ASK|LANG|FMT|SUM|CODE|EVID|CHECK)-[0-9]+:" || true)
      rulecheck_hits="${rulecheck_hits:-0}"
      if [ "$rulecheck_hits" -ge 3 ]; then
        echo "  WARN: 末尾出现规则自检 ${rulecheck_hits} 条（R-CHECK-001 默认应隐藏；仅 debug 模式允许）"
        # 不计入 FAIL（兼容 debug 模式产物），但作为警告
      else
        echo "  PASS: 无规则自检条目泄漏"
        PASS=$((PASS + 1))
      fi
    else
      echo "  PASS: 无 ## 规则自检 段（符合 R-CHECK-001 默认隐藏）"
      PASS=$((PASS + 1))
    fi
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
