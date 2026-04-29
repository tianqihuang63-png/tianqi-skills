#!/bin/bash
# sync-skills.sh — 从 ~/.claude/skills/ 同步到 tianqi-skills 仓库
# 自动检测新增 skill，按描述分类，提交推送

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$HOME/tianqi-skills"

# 如果仓库不在 /tmp（可能被清理），尝试 ~/Projects
if [ ! -d "$REPO_DIR/.git" ]; then
    REPO_DIR="$HOME/Projects/tianqi-skills"
fi
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "ERROR: 找不到 tianqi-skills 仓库"
    echo "请先 git clone https://github.com/tianqihuang63-png/tianqi-skills.git"
    exit 1
fi

# 分类规则（基于 skill 名称前缀或关键词）
categorize() {
    local name="$1"
    local desc="$2"

    # lark 系列
    if [[ "$name" == lark-* ]]; then echo "lark"; return; fi

    # baoyu 内容系列
    if [[ "$name" == baoyu-* ]]; then echo "content"; return; fi

    # 设计相关
    if [[ "$desc" =~ [Dd]esign|[Uu][Ii]/[Uu][Xx]|[Cc]anvas|[Aa]rt|[Ss]hadcn|[Tt]heme|[Pp]encil|[Ff]rontend-design|[Ii]nterface-design|[Tt]aste|[Ii]mpeccable ]]; then
        echo "design"; return; fi

    # 工作流
    if [[ "$name" =~ ^(freeze|unfreeze|guard|ship|health|autoplan|neat-freak|checkpoint|office-hours|pair-agent)$ ]]; then
        echo "workflow"; return; fi
    if [[ "$desc" =~ [Pp]arallel.agent|[Ss]ubagent|[Ww]orktree|[Vv]erification|work.flows? ]]; then
        echo "workflow"; return; fi

    # 内容创作
    if [[ "$name" =~ ^(hv-analysis|khazix-writer|doc-coauthoring|internal-comms|brainstorming|targeted-chatroom|emotion-self-coach)$ ]]; then
        echo "content"; return; fi
    if [[ "$desc" =~ [Ww]riting|[Cc]oauthor|[Bb]log|[Aa]rticle|[Tt]ranslat|[Cc]ontent.creat ]]; then
        echo "content"; return; fi

    # 开发工具
    if [[ "$name" =~ ^(claude-api|mcp-builder|systematic-debugging|code-review|qa|test-driven|skill-creator|writing-skill|writing-plan|release|review|investigate|benchmark|web-access|webapp|vercel|learn|canary|codex|cso|devex|plan-|retro|using-superpower|web-design|web-artifact)$ ]]; then
        echo "dev-tools"; return; fi
    if [[ "$desc" =~ [Dd]ebug|[Tt]est|[Rr]eview|[Mm]CP|[Aa]PI|[Cc]laude|[Rr]elease|[Bb]enchmark ]]; then
        echo "dev-tools"; return; fi

    # 第三方工具
    if [[ "$name" =~ ^(pdf|docx|xlsx|pptx|image-utils|slack-gif|seo-audit|browse|open-gstack|yunshu|setup-browser|setup-deploy|document-release|brand-guidelines|design-consultation|design-html|design-review|design-shotgun)$ ]]; then
        echo "third-party"; return; fi

    # 默认归到 dev-tools
    echo "dev-tools"
}

cd "$REPO_DIR"

CHANGED=0
ADDED=0

# 遍历所有本地 skill
for item in "$SKILLS_DIR"/*; do
    name=$(basename "$item")

    # 跳过非目录和非 .skill.md 文件
    if [ ! -d "$item" ] && [[ ! "$name" == *.skill.md ]]; then
        continue
    fi

    # 获取描述
    if [ -d "$item" ] && [ -f "$item/SKILL.md" ]; then
        desc=$(grep -m1 "^description:" "$item/SKILL.md" 2>/dev/null | sed 's/description:[[:space:]]*//' | head -c 300 || echo "")
    else
        desc=""
    fi

    category=$(categorize "$name" "$desc")

    # 检查是否已在仓库中
    found=false
    for cat_dir in lark workflow design content dev-tools third-party; do
        if [ -e "$REPO_DIR/$cat_dir/$name" ]; then
            found=true
            # 检查是否有变更
            if [ -d "$item" ]; then
                if ! diff -rq "$item" "$REPO_DIR/$cat_dir/$name" > /dev/null 2>&1; then
                    echo "[更新] $category/$name"
                    rm -rf "$REPO_DIR/$cat_dir/$name"
                    cp -r "$item" "$REPO_DIR/$cat_dir/$name"
                    CHANGED=$((CHANGED + 1))
                fi
            fi
            break
        fi
    done

    if [ "$found" = false ]; then
        echo "[新增] $category/$name"
        mkdir -p "$REPO_DIR/$category"
        if [ -d "$item" ]; then
            cp -r "$item" "$REPO_DIR/$category/"
        else
            cp "$item" "$REPO_DIR/$category/"
        fi
        ADDED=$((ADDED + 1))
    fi
done

if [ $CHANGED -eq 0 ] && [ $ADDED -eq 0 ]; then
    echo "所有 skill 已是最新，无需同步。"
    exit 0
fi

echo ""
echo "变更: $CHANGED 个更新, $ADDED 个新增"

# Git 操作
git add -A
DATE=$(date +%Y-%m-%d)
git commit -m "sync: ${DATE} — ${ADDED}新增 ${CHANGED}更新" || echo "没有需要提交的变更"

# 推送（如果远程可用）
if git remote get-url origin > /dev/null 2>&1; then
    git push origin main 2>&1 || echo "推送失败，请检查网络或手动推送"
else
    echo "无远程仓库，跳过推送。"
fi

echo "同步完成。"
