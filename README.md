# tianqi-skills

> 黄天骐的 Claude Code Skills 合集。飞书深度集成、公众号发布、AI 日报、设计工具、开发工作流等。

**124 个 Skill** | 按用途分类 | 一键安装 | 跨平台兼容（Claude Code / Codex / OpenCode / OpenClaw）

---

## 快速安装

### 装全部

```bash
git clone https://github.com/tianqihuang63-png/tianqi-skills.git
cp -r tianqi-skills/* ~/.claude/skills/
```

### 按分类装

```bash
git clone https://github.com/tianqihuang63-png/tianqi-skills.git

# 只装飞书集成（24个）
cp -r tianqi-skills/lark/* ~/.claude/skills/

# 只装开发工作流（15个）
cp -r tianqi-skills/workflow/* ~/.claude/skills/

# 只装设计工具（10个）
cp -r tianqi-skills/design/* ~/.claude/skills/

# 只装内容创作（11个）
cp -r tianqi-skills/content/* ~/.claude/skills/

# 只装开发工具（34个）
cp -r tianqi-skills/dev-tools/* ~/.claude/skills/
```

### 装单个 Skill

```bash
git clone https://github.com/tianqihuang63-png/tianqi-skills.git
cp -r tianqi-skills/lark/lark-im ~/.claude/skills/
```

---

## 目录结构

```
tianqi-skills/
├── lark/              # 飞书/Lark 深度集成（24个）— 核心
├── workflow/          # 开发工作流与自动化（15个）
├── design/            # UI/UX 设计与视觉（10个）
├── content/           # 内容创作与发布（11个）
├── dev-tools/         # 开发工具与代码质量（34个）
├── third-party/       # 第三方工具与格式处理（18个）
└── references/        # 参考资料
```

---

## Skill 索引

### lark/ — 飞书深度集成

| Skill | 说明 |
|-------|------|
| **lark-im** | 飞书即时通讯：收发消息、搜索、群管理 |
| **lark-calendar** | 飞书日历：日程管理、会议创建 |
| **lark-doc** | 飞书云文档：Markdown 创建、编辑、发布 |
| **lark-drive** | 飞书云空间：文件上传下载、文件夹管理 |
| **lark-sheets** | 飞书电子表格：创建、读写、格式化 |
| **lark-base** | 飞书多维表格：记录增删改查 |
| **lark-wiki** | 飞书知识库：知识空间管理 |
| **lark-mail** | 飞书邮箱：收发、草稿、搜索 |
| **lark-minutes** | 飞书妙记：会议纪要获取与转录 |
| **lark-task** | 飞书任务：待办创建与跟踪 |
| **lark-approval** | 飞书审批：审批实例管理 |
| **lark-attendance** | 飞书考勤：打卡记录查询 |
| **lark-contact** | 飞书通讯录：组织架构与人员查询 |
| **lark-event** | 飞书事件订阅：WebSocket 实时监听 |
| **lark-slides** | 飞书幻灯片：PPT 创建与管理 |
| **lark-vc** | 飞书视频会议：会议记录与纪要 |
| **lark-whiteboard** | 飞书白板：画板绘制 |
| **lark-whiteboard-cli** | 飞书白板 CLI 工具版 |
| **lark-shared** | 飞书 CLI 共享基础：认证、配置 |
| **lark-skill-maker** | 飞书 Skill 创建器 |
| **lark-openapi-explorer** | 飞书 OpenAPI 探索器 |
| **lark-daily-group-report** | 飞书群消息每日日报 |
| **lark-workflow-meeting-summary** | 会议纪要整理工作流 |
| **lark-workflow-standup-report** | 日程待办摘要 |

### workflow/ — 开发工作流

| Skill | 说明 |
|-------|------|
| **neat-freak** | 文档/记忆洁癖级同步（会话结束前跑 `/neat`） |
| **freeze/unfreeze** | 冻结/解冻目录，防止误改 |
| **guard** | 敏感文件保护 |
| **ship** | 代码提交与发布流程 |
| **health** | 项目健康检查 |
| **autoplan** | 自动规划 |
| **dispatching-parallel-agents** | 并行 Agent 调度 |
| **subagent-driven-development** | 子 Agent 驱动开发 |
| **executing-plans** | 执行已有实施计划 |
| **finishing-a-development-branch** | 完成开发分支 |
| **verification-before-completion** | 交付前验证 |
| **using-git-worktrees** | Git Worktree 管理 |
| **pair-agent** | 结对编程 Agent |
| **office-hours** | 办公时间（hackathon 规划） |
| **checkpoint** | 检查点 |

### design/ — UI/UX 设计

| Skill | 说明 |
|-------|------|
| **frontend-design** | 前端界面设计（Anthropic 出品） |
| **impeccable** | 高质量前端设计（Apache 2.0） |
| **ui-ux-pro-max** | UI/UX 设计智能（67风格+96配色） |
| **interface-design** | 界面设计（仪表盘/管理后台） |
| **taste-skill** | 高级 UI/UX 工程 |
| **shadcn-ui** | shadcn/ui 组件库 |
| **pencil-design** | Pencil 设计转代码 |
| **canvas-design** | 视觉设计（海报/艺术） |
| **algorithmic-art** | 算法艺术（p5.js） |
| **theme-factory** | 主题样式工厂 |

### content/ — 内容创作

| Skill | 说明 |
|-------|------|
| **hv-analysis** | 横纵分析法深度研究（万字 PDF 报告） |
| **khazix-writer** | 公众号长文写作（卡兹克风格） |
| **baoyu-post-to-wechat** | 微信公众号发布（API/Chrome CDP） |
| **baoyu-markdown-to-html** | Markdown 转 HTML（微信兼容） |
| **baoyu-translate** | 多语言翻译（快速/标准/专业三档） |
| **baoyu-url-to-markdown** | URL 抓取转 Markdown |
| **doc-coauthoring** | 文档协作编写 |
| **internal-comms** | 内部沟通文档 |
| **brainstorming** | 头脑风暴 |
| **targeted-chatroom** | 定向聊天室（专家模拟） |
| **emotion-self-coach** | 情绪自助教练 |

### dev-tools/ — 开发工具

| Skill | 说明 |
|-------|------|
| **claude-api** | Claude API / Anthropic SDK 开发 |
| **mcp-builder** | MCP Server 构建器 |
| **systematic-debugging** | 系统化调试 |
| **code-review-specialist** | 代码审查（安全/性能/质量） |
| **qa / qa-only** | 测试与质量保证 |
| **test-driven-development** | TDD 测试驱动开发 |
| **skill-creator** | Skill 创建器 |
| **writing-skills** | Skill 编写指南 |
| **writing-plans** | 实施计划编写 |
| **release-skills** | 发布流程 |
| **review / receiving-code-review** | 代码审查双向 |
| **investigate** | 问题调查 |
| **benchmark** | 性能基准测试 |
| **web-access** | Web 访问（MIT 开源） |
| **webapp-testing** | Web 应用测试（Playwright） |
| **vercel-react-best-practices** | React 最佳实践（Vercel 出品，MIT） |
| **learn** | 学习模式 |
| **canary** | 金丝雀测试 |
| **checkpoint** | 检查点 |
| **codex** | Codex 集成 |
| **cso** | CSO 安全官 |
| **devex-review** | 开发体验审查 |
| **plan-\*** | 各类 Review 计划（CEO/Design/DevEx/Eng） |
| **retro** | 回顾会 |
| **using-superpowers** | Skill 使用入门 |
| **web-design-guidelines** | Web 设计规范 |
| **web-artifacts-builder** | HTML Artifacts 构建 |

### third-party/ — 第三方工具

| Skill | 说明 |
|-------|------|
| **pdf** | PDF 文件处理 |
| **docx** | Word 文档处理 |
| **xlsx** | Excel 电子表格处理 |
| **pptx** | PowerPoint 演示文稿 |
| **image-utils** | 图像处理（Pillow，MIT） |
| **slack-gif-creator** | Slack GIF 创建 |
| **seo-audit** | SEO 审计 |
| **browse** | 浏览器控制 |
| **yunshu_skillshub** | 云舒 Skill Hub（MIT） |

---

## 许可说明

本仓库中的 Skill 按来源分为三类：

1. **自有 Skill**（lark/ 目录全部）：可自由使用、修改、分发
2. **开源第三方 Skill**（标注 MIT / Apache 2.0）：遵循原许可证
3. **引用 Skill**（部分 claude-api、brand-guidelines 等）：遵循各自的 LICENSE.txt

每个 Skill 目录下如有 `LICENSE.txt` 或 `NOTICE.md`，请遵循其条款。

---

## 推荐组合

**飞书运营**：`lark/` + `workflow/neat-freak` + `content/baoyu-markdown-to-html`

**独立开发**：`workflow/` + `dev-tools/` + `design/frontend-design`

**内容创作**：`content/hv-analysis` + `content/khazix-writer` + `content/baoyu-post-to-wechat`

---

## 跨平台安装路径

| 工具 | Skill 目录 |
|------|-----------|
| Claude Code | `~/.claude/skills/` |
| OpenAI Codex | `~/.codex/skills/` |
| OpenCode | `.opencode/skills/`（项目级）或 `~/.config/opencode/skills/`（全局） |
| OpenClaw | `~/.openclaw/skills/` |

---

## 维护

本仓库通过自动化脚本从本地 `~/.claude/skills/` 同步，新增 Skill 会自动分类提交。
