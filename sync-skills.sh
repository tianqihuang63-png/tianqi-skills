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
    if [[ "$name" == lark-* ]]; then echo "飞书集成"; return; fi

    # baoyu 内容系列
    if [[ "$name" == baoyu-* ]]; then echo "内容创作"; return; fi

    # 设计相关
    if [[ "$desc" =~ [Dd]esign|[Uu][Ii]/[Uu][Xx]|[Cc]anvas|[Aa]rt|[Ss]hadcn|[Tt]heme|[Pp]encil|[Ff]rontend-design|[Ii]nterface-design|[Tt]aste|[Ii]mpeccable ]]; then
        echo "设计工具"; return; fi

    # 工作流
    if [[ "$name" =~ ^(freeze|unfreeze|guard|ship|health|autoplan|neat-freak|checkpoint|office-hours|pair-agent)$ ]]; then
        echo "工作流"; return; fi
    if [[ "$desc" =~ [Pp]arallel.agent|[Ss]ubagent|[Ww]orktree|[Vv]erification|work.flows? ]]; then
        echo "工作流"; return; fi

    # 内容创作
    if [[ "$name" =~ ^(hv-analysis|khazix-writer|doc-coauthoring|internal-comms|brainstorming|targeted-chatroom|emotion-self-coach)$ ]]; then
        echo "内容创作"; return; fi
    if [[ "$desc" =~ [Ww]riting|[Cc]oauthor|[Bb]log|[Aa]rticle|[Tt]ranslat|[Cc]ontent.creat ]]; then
        echo "内容创作"; return; fi

    # 开发工具
    if [[ "$name" =~ ^(claude-api|mcp-builder|systematic-debugging|code-review|qa|test-driven|skill-creator|writing-skill|writing-plan|release|review|investigate|benchmark|web-access|webapp|vercel|learn|canary|codex|cso|devex|plan-|retro|using-superpower|web-design|web-artifact)$ ]]; then
        echo "开发工具"; return; fi
    if [[ "$desc" =~ [Dd]ebug|[Tt]est|[Rr]eview|[Mm]CP|[Aa]PI|[Cc]laude|[Rr]elease|[Bb]enchmark ]]; then
        echo "开发工具"; return; fi

    # 第三方工具
    if [[ "$name" =~ ^(pdf|docx|xlsx|pptx|image-utils|slack-gif|seo-audit|browse|open-gstack|yunshu|setup-browser|setup-deploy|document-release|brand-guidelines|design-consultation|design-html|design-review|design-shotgun)$ ]]; then
        echo "第三方工具"; return; fi

    # 默认归到开发工具
    echo "开发工具"
}

# ─── 安全扫描：检测敏感信息 ───
# 扫描单个 skill 目录，返回 0（安全）或 1（有风险）
security_check() {
    local target="$1"
    local name=$(basename "$target")
    local findings=""

    # 1. 硬编码密钥/Token（排除测试文件和占位符）
    local secrets=$(grep -rn \
        -E '(sk-[a-z0-9]{20,}|ghp_[a-zA-Z0-9]{30,}|gho_[a-zA-Z0-9]{30,}|AKIA[0-9A-Z]{16}|t0k_[a-zA-Z0-9]{20,}|xox[bpsa]-[a-zA-Z0-9-]{20,})' \
        "$target" \
        --include='*.py' --include='*.js' --include='*.ts' --include='*.json' --include='*.yaml' --include='*.yml' --include='*.env' --include='*.md' --include='*.sh' \
        2>/dev/null | grep -v 'example\|placeholder\|YOUR_\|your_\|xxx\|<\|```' | grep -v '/test/' | grep -v '__tests__')

    if [ -n "$secrets" ]; then
        findings="${findings}  [硬编码密钥] 检测到疑似真实密钥:\n${secrets}\n"
    fi

    # 2. 密码明文
    local passwords=$(grep -rn \
        -iE '(password\s*[=:]\s*['\''"][^'\''"]{6,}['\''"]|passwd\s*[=:]\s*['\''"][^'\''"]{6,}['\''"])' \
        "$target" \
        --include='*.py' --include='*.js' --include='*.ts' --include='*.json' --include='*.yaml' --include='*.yml' --include='*.env' --include='*.sh' \
        2>/dev/null | grep -v 'example\|placeholder\|YOUR_\|your_\|xxx\|changeme\|password123\|test')

    if [ -n "$passwords" ]; then
        findings="${findings}  [密码明文] 检测到疑似密码:\n${passwords}\n"
    fi

    # 3. 私钥文件
    local private_keys=$(find "$target" -type f \( -name "*.pem" -o -name "*.key" -o -name "id_rsa*" -o -name "id_ed25519*" -o -name "*.p12" -o -name "*.pfx" \) 2>/dev/null)

    if [ -n "$private_keys" ]; then
        findings="${findings}  [私钥文件] 检测到:\n${private_keys}\n"
    fi

    # 4. .env 文件（可能包含环境变量密钥）
    local env_files=$(find "$target" -maxdepth 2 -name ".env" -o -name ".env.local" -o -name ".env.production" 2>/dev/null)

    if [ -n "$env_files" ]; then
        # 检查 .env 里是否有真实值（排除空值和占位符）
        local env_secrets=$(grep -E '=.+' $env_files 2>/dev/null | grep -v '=false\|=true\|=$\|=#[^=]*$\|YOUR_\|your_\|placeholder\|changeme\|xxx' | head -5)
        if [ -n "$env_secrets" ]; then
            findings="${findings}  [.env 文件] 检测到可能含敏感信息的配置:\n${env_secrets}\n"
        fi
    fi

    # 5. 数据库连接串
    local db_urls=$(grep -rn \
        -iE '(mongodb(\+srv)?://[^$\s]+|postgres(ql)?://[^$\s]+:[^$\s]+@|mysql://[^$\s]+:[^$\s]+@|redis://[^$\s]+:[^$\s]+@)' \
        "$target" \
        --include='*.py' --include='*.js' --include='*.ts' --include='*.json' --include='*.yaml' --include='*.yml' --include='*.env' \
        2>/dev/null | grep -v 'example\|localhost\|127\.0\.0\.1\|YOUR_\|placeholder')

    if [ -n "$db_urls" ]; then
        findings="${findings}  [数据库连接串] 检测到含密码的连接串:\n${db_urls}\n"
    fi

    # 6. Webhook URL（可能被滥用）
    local webhooks=$(grep -rn \
        -iE '(https://hooks\.slack\.com/services/T[A-Z0-9]+/|https://discord\.com/api/webhooks/[0-9]+/|https://qyapi\.weixin\.qq\.com/cgi-bin/webhook/send\?key=)' \
        "$target" \
        --include='*.py' --include='*.js' --include='*.ts' --include='*.json' --include='*.yaml' --include='*.yml' --include='*.md' \
        2>/dev/null | grep -v 'example\|YOUR_\|placeholder\|xxx')

    if [ -n "$webhooks" ]; then
        findings="${findings}  [Webhook URL] 检测到真实 Webhook 地址:\n${webhooks}\n"
    fi

    if [ -n "$findings" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  SECURITY ALERT: $name 存在安全风险"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "$findings"
        echo "  已阻止上传。请先移除敏感信息后再同步。"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 1
    fi

    return 0
}

cd "$REPO_DIR"

CHANGED=0
ADDED=0
BLOCKED=0
BLOCKED_LIST=""

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
    for cat_dir in 飞书集成 工作流 设计工具 内容创作 开发工具 第三方工具; do
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
        # 新增 skill 必须通过安全扫描
        if ! security_check "$item"; then
            BLOCKED=$((BLOCKED + 1))
            BLOCKED_LIST="${BLOCKED_LIST}  - $category/$name\n"
            continue
        fi
        echo "[新增] $category/$name"
        mkdir -p "$REPO_DIR/$category"
        if [ -d "$item" ]; then
            cp -r "$item" "$REPO_DIR/$category/"
        else
            cp "$item" "$REPO_DIR/$category/"
        fi
        ADDED=$((ADDED + 1))
    fi

    # 已有 skill 有变更时也要扫描
    if [ "$found" = true ] && [ $CHANGED -gt 0 ]; then
        for cat_dir in 飞书集成 工作流 设计工具 内容创作 开发工具 第三方工具; do
            if [ -e "$REPO_DIR/$cat_dir/$name" ]; then
                if ! security_check "$item"; then
                    BLOCKED=$((BLOCKED + 1))
                    BLOCKED_LIST="${BLOCKED_LIST}  - $category/$name（更新）\n"
                    # 回滚：删除已复制的文件
                    rm -rf "$REPO_DIR/$cat_dir/$name"
                    # 恢复旧版本
                    git checkout -- "$cat_dir/$name" 2>/dev/null || true
                    CHANGED=$((CHANGED - 1))
                fi
                break
            fi
        done
    fi
done

if [ $CHANGED -eq 0 ] && [ $ADDED -eq 0 ] && [ $BLOCKED -eq 0 ]; then
    echo "所有 skill 已是最新，无需同步。"
    exit 0
fi

echo ""
echo "变更: $CHANGED 个更新, $ADDED 个新增"

if [ $BLOCKED -gt 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  BLOCKED: $BLOCKED 个 skill 因安全风险被阻止"
    echo -e "$BLOCKED_LIST"
    echo "  请检查上述 skill，移除敏感信息后重新运行。"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

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
