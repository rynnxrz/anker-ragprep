# Anker AI 飞行员试炼 — Prep Repo

Claude Code 运行时仓库。打开即用，无需配置。

## 使用方式

1. 在此目录打开 Claude Code
2. 直接输入 case 题目
3. Claude 自动按六步引擎 + 规则契约执行

## 目录结构

```
CLAUDE.md              ← 运行时配置（自动加载）
rag/                   ← 参考材料（规则/知识库/源索引）
examples/              ← 满分输出示例
scripts/               ← 输出检查脚本
output/                ← 生成的 case 答案存放处
```

## Fallback

如果 Claude 未自动按引擎执行，粘贴 `CLAUDE.md` 底部的 fallback 模板。
