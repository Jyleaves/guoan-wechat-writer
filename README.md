# guoan-wechat-writer

> 微信公众号"九万里""国家安全部"文风写作与谋题报送工作流 + 研究性文章（研究体）报告写作（Agent Skill；发布包另含可选 DSH Agent 预设）。当前版本：**v1.1.9**（语义化版本，发布记录见 CHANGELOG.md 与文末"近期更新"）。

## 功能一览

- **谋题报送**：从环球、中新社等国际传播头部媒体和权威外媒自动寻题；按审核格式报送（判断式标题 + 简述 + 官方文章链接），审核通过后才写文章；工作日可报次日选题、周日可报下周重大选题
  - **时效当天优先**：优先当天事件（≤24小时），超48小时原则上不报（同行大概率已评论过），每条标注事件首发时间
  - **链接零造假**：附送链接必须逐字复制自真实检索结果、提交前逐条访问核验，找不到真实官方链接就不报送
  - **谋题事实核查**：提交前逐句核对——简述中日期（报道日期/事件日期/当地时间）、数字、人名、机构名与官方文章逐字一致
- **公众号写作**：九万里体（国际时评 2000-2800 字）/ 国安部体（800-2000 字）/ 万里追风速览体 / 万里论剑体；风格严格对标提炼规范；**事实逐句可查证**（每篇文章附事实核查表，每条事实对应信源链接）；数据图表自动生成
- **研究性文章（研究体）**：用户给出主题，按智库内参笔法撰写 4000-8000 字研究报告（默认三段式：总体情况〔节内要点式分段、一段一主体〕/ 对华风险研判 / 对策建议），**交付与示例同格式的 Word 文档（.docx，公文排版：仿宋_GB2312 正文/黑体标题/楷体观点句/Times New Roman 西文与数字）+ 事实核查表**；独立研究报告文体，非公众号文章、不配图
- **持续进化**：审核意见与文章反馈写入反馈记忆（feedback-log 经历记忆 + learned-patterns 模式记忆），越用越聪明；新环境首次使用自动初始化记忆

## 目录结构（仓库）

```
guoan-wechat-writer/
├── SKILL.md                    # 工作流主文件（谋题/写作/研究体/配图/反馈学习/版本）
├── references/
│   ├── style-jiuwanli.md       # "九万里"风格指南（标题/开头/小标题/结尾/词汇弹药库）
│   ├── style-guoanbu.md        # "国家安全部"风格指南
│   ├── style-research.md       # 研究体风格指南（结构/Word 格式/事实核查强化）
│   └── fact-check-protocol.md  # 事实核查协议（信源分层/双重印证/逐句复核，硬约束）
└── tools/                      # 随技能分发的工具（跨环境可用）
    ├── make_chart.py           # 数据图表自动生成（依赖 Python+matplotlib，可选）
    └── research-docx/          # 研究体 Word 生成工具链（依赖 pandoc）
        ├── md2docx.ps1         # Markdown → docx（公文式/宋体小四式模板）
        ├── make-reference.ps1  # 重建 docx 样式模板（纯 .NET）
        ├── lead-sentence.lua   # 观点句楷体自动标记过滤器
        └── reference*.docx     # 样式模板（公文式/宋体小四式/pandoc 基座）
```

## 安装

### 方法一：skills CLI（推荐，GitHub 直接安装）

```bash
npx skills add Jyleaves/guoan-wechat-writer@guoan-wechat-writer -g -y
```

- `-g` 安装到用户级技能目录（全局可用）；不加 `-g` 则装到当前项目
- 安装后技能目录为：`~/.agents/skills/guoan-wechat-writer/`（含 tools/）

### 方法二：手动安装（跨平台）

1. 下载本仓库：`git clone https://github.com/Jyleaves/guoan-wechat-writer.git`，或在 GitHub 页面点 **Code → Download ZIP** 并解压
2. 把里面的 `guoan-wechat-writer` 文件夹（含 SKILL.md、references/、tools/）复制到你的技能目录，任选其一：
   - **用户级**（所有项目可用）：`~/.agents/skills/`（Windows：`%USERPROFILE%\.agents\skills\`）
   - **项目级**（只当前项目）：项目根目录下的 `.agents/skills/` 或 `.dsh/skills/`
3. 完成下方"首次配置"

### 方法三：Windows 发布包（含 Agent 预设 + 一键安装）

从 Releases 下载 `guoan-wechat-writer-v*.zip`，解压后运行：

```powershell
pwsh -File .\install.ps1 -Workdir "你的工作目录"
```

脚本自动安装技能（含 tools/）与"国安公众号写作助手"预设（DSH 环境），并把路径写入技能与预设；`-CorpusPath` 可指定可选语料库。

## 首次配置（GitHub 手动安装时只需一次，1 分钟）

用任意编辑器打开安装好的 `guoan-wechat-writer/SKILL.md`，替换占位符：

| 占位符 | 替换为 | 说明 |
|---|---|---|
| `<你的工作目录>` | 你的实际工作目录，如 `D:\NewsWriter` | 存放 outputs（文章/谋题/配图）与 feedback（反馈记忆）；先建一个空目录即可 |
| `<语料库目录（可选）>` | 不动即可 | **可选**。仅"风格验证翻阅"与"更新风格库"两个进阶功能需要；不配置不影响谋题、写作、研究体等全部核心功能（风格知识已内置在 references/ 中） |
| `<技能目录>` | 不动即可 | 指技能安装位置，由运行环境自动解析；tools/ 随技能分发 |

## 环境依赖

- **PowerShell 7（pwsh）**：研究体 Word 生成（md2docx.ps1）与发布包安装/更新脚本必需。Windows 自带的 PowerShell 5.1 无法正确读取本技能的 UTF-8（无 BOM）脚本（中文会乱码）；运行 `pwsh -v` 确认可用。安装：`winget install --id Microsoft.PowerShell`（macOS/Linux 见 https://aka.ms/powershell ）
- **pandoc**：研究体 Word 文档生成必需。安装：`winget install --id JohnMacFarlane.Pandoc` 或 https://pandoc.org/installing.html
- **Python 3 + matplotlib**：仅数据图表自动生成需要（可选；未安装时自动降级为半自动配图清单）：`pip install matplotlib`
- 谋题、公众号写作、事实核查、反馈学习等核心功能零依赖；缺失依赖时工具脚本会给出安装提示

## 使用

在支持 skill 的 AI 会话中，以下任一方式启动：

- **自动触发**：直接说——
  - "生成明天的谋题" / "报送选题" / "下周选题" / "时评精选选题" / "万里论剑选题"
  - "搜集最新时事新闻，写一篇微信公众号" / "针对XX搜集新闻写一篇文章"
  - "用九万里风格写……" / "用国家安全部风格写……"
  - "写一篇关于XX的研究性文章" / "针对XX写一份研究报告/分析报告"（研究体，交付 Word 文档）
- **手动加载**：用 skill 工具加载 `guoan-wechat-writer`

## 更新

**反馈记忆与历史产出都在你的工作目录（outputs/feedback），与技能目录无关，更新覆盖不影响数据。**任选其一：

- **一键更新脚本（推荐，任意安装方式可用）**——自动下载最新 Release 并重装（工作目录等配置重新写入）：
  ```powershell
  pwsh -c "irm https://raw.githubusercontent.com/Jyleaves/guoan-wechat-writer/main/update.ps1 | iex"
  ```
  免交互版：`pwsh -File update.ps1 -Workdir "你的工作目录"`（发布包内附 update.ps1）；`-Version v1.1.9` 可更新到指定版本
- **skills CLI 安装的用户**：重新执行安装命令即可覆盖更新：`npx skills add Jyleaves/guoan-wechat-writer@guoan-wechat-writer -g -y`
- **git clone 安装的用户**：`git pull` 后把 `guoan-wechat-writer` 文件夹重新复制到技能目录（或直接用一键更新脚本）
- 手动下载：https://github.com/Jyleaves/guoan-wechat-writer/releases/latest

版本语义：补丁=修正；次版本=新功能/新经验模式；主版本=架构变更。详见 CHANGELOG.md

## 近期更新

| 版本 | 日期 | 要点 |
|---|---|---|
| v1.1.9 | 2026-08-16 | 一键更新（update.ps1 + latest 稳定下载地址）；环境依赖补全（PowerShell 7）；install.ps1 编码加固 |
| v1.1.8 | 2026-08-16 | 全面移除 UTF-8 BOM（SKILL.md frontmatter 解析修复）；首发 GitHub Release |
| v1.1.7 | 2026-08-15 | 字体口径校准（楷体固定、仿宋自动检测）+ 多样性保障 |
| v1.1.6 | 2026-08-15 | 研究体观点句规范（30–50 字三要素判断句、五种句式轮换）+ 去样本依赖 |
| v1.1.5 | 2026-08-14 | 研究体结构细化：总体情况节内要点式分段（一段一主体）、体例统一规则 |
| v1.1.4 | 2026-08-14 | 修复观点句过滤器多字节 bug（docx 乱码方框） |
| v1.1.3 | 2026-08-14 | 字体校准（仿宋_GB2312/黑体/楷体_GB2312/Times New Roman）+ 观点句楷体自动化 |
| v1.1.2 | 2026-08-14 | 工具随技能分发（tools/）；本机专属路径可选化；环境依赖声明 |
| v1.1.1 | 2026-08-14 | 研究体与公众号解绑：交付 Word 文档（公文排版）、默认三段式、不配图 |
| v1.1.0 | 2026-08-14 | 新增研究体（研究性文章）体裁与 style-research.md 风格指南 |
| v1.0.5 | 2026-08-14 | 补上谋题事实核查环节（逐句比对+日期专项） |
| v1.0.4 | 2026-08-14 | 谋题时效当天优先+防重复硬约束 |
| v1.0.3 | 2026-08-14 | 链接真实性硬规则（禁止虚构 URL，修复链接造假缺陷） |
| v1.0.2 | 2026-08-14 | 新环境首次使用自动初始化反馈记忆 |
| v1.0.1 | 2026-08-14 | 语料库改为可选配置 |
| v1.0.0 | 2026-08-13 | 首版：双风格指南+事实核查协议+谋题/配图/反馈工作流 |

## 说明

- 技能内的风格指南提炼自公开公众号文章的写作规律，**不包含任何语料原文**，写作时严格禁止抄袭
- 事实真实性是本技能的最高优先级：文章中的每句事实性陈述都必须真实且可查证（每篇交付附事实核查表）
- **个性数据不随仓库/发布包分发**：语料库、feedback/（反馈记忆）、outputs/（历史产出）、研究体样本均为每环境个性化数据，安装后由技能自动初始化
- 本仓库只包含技能本体（SKILL.md + references/ + tools/）；Agent 预设与 install.ps1 仅在发布包中提供
