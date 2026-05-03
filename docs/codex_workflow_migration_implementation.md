# Codex 工作流迁移实施文档

## 目标

把现有 OpenCode 工作流迁移成 Codex 可使用、可版本管理、可复用的配置包。

迁移目标不是复刻 OpenCode 的 agent/mode/permission 机制，而是保留工作流本身：

1. 从想法生成 design 文档。
2. 从 design 文档生成技术方案和任务列表。
3. 按任务依赖顺序调度执行。
4. 用短生命周期执行者完成单个 bounded task。
5. 做 review，并在确认后更新项目上下文。

## 已确认决策

### 入口命名

不再使用拟人化名称。迁移后的用户入口统一使用职责型名称：

| 职责 | 新入口 |
|---|---|
| 需求澄清 / design 文档 | `product-designer` |
| 技术方案 / 任务拆解 | `tech-designer` |
| 任务调度 / progress 维护 | `task-dispatcher` |
| 单任务实现 | `developer` |
| review / 项目上下文更新 | `quality-reviewer` |

旧 OpenCode 文件中的拟人化名称只作为迁移来源存在，不作为新文件名、skill 名、脚本名、文档主入口名继续出现。

### 语言策略

1. 新增的迁移 glue 文档默认使用中文。
2. 每个迁移文件尽量保留原文语言。
3. 不做额外语言润色。
4. 只在确实需要适配 Codex 时改写，例如：
   - OpenCode 的 `mode: primary` / `mode: subagent`
   - OpenCode 的 permission frontmatter
   - OpenCode 专用工具名
   - OpenCode 专用 agent 调用语法

### Headless 策略

不迁移 headless 模式。

明确不做：

- 不迁移 `opencode_headless.json`。
- 不创建 `headless` skill。
- 不创建 headless profile。
- 不用 `codex exec` 作为这套工作流的主要入口。
- 不为非交互场景设计额外 fallback。

终端快捷入口应启动交互式 Codex，并注入对应 workflow prompt。

### Per-repo 策略

优先做 per-repo 配置包。

实现方式采用 repo 内的本地插件索引（local plugin registry）：

- workflow 源文件保存在当前 repo。
- Codex 通过本地插件索引发现 repo 内插件。
- 这不是发布到 Codex 官方 marketplace。
- 不会自动上传、公开或给别人安装。

如果当前 Codex 版本无法完全做到 repo 自动发现，则提供一个安装/初始化脚本，把这个 repo 的本地插件索引注册到用户 Codex 配置中。即使使用 per-user 注册，源文件仍然保留在 repo 内，后续更新通过 repo 管理。

## 目标目录结构

```text
AGENTS.md
.agents/
  plugins/
    marketplace.json
plugins/
  codex-dev-workflow/
    .codex-plugin/
      plugin.json
    skills/
      product-designer/
        SKILL.md
        references/
      tech-designer/
        SKILL.md
        references/
      task-dispatcher/
        SKILL.md
        references/
      developer/
        SKILL.md
      quality-reviewer/
        SKILL.md
      code-review/
        SKILL.md
      project-summary/
        SKILL.md
      json-lint/
        SKILL.md
      test-driven-development/
        SKILL.md
      systematic-debugging/
        SKILL.md
      writing-clearly-and-concisely/
        SKILL.md
bin/
  codex-design
  codex-tech-design
  codex-dispatch
  codex-review
```

## 本地插件索引设计

`.agents/plugins/marketplace.json` 是本地插件索引，不是公开 marketplace 发布配置。

建议内容：

```json
{
  "name": "codex-dev-workflow-local",
  "interface": {
    "displayName": "Codex Dev Workflow Local"
  },
  "plugins": [
    {
      "name": "codex-dev-workflow",
      "source": {
        "source": "local",
        "path": "./plugins/codex-dev-workflow"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

说明：

- `source.local` 表示插件来自当前 repo 的本地路径。
- `AVAILABLE` 表示它可以被本机 Codex 安装/启用。
- 如果后续希望初始化脚本一键启用，可以评估是否改成 `INSTALLED_BY_DEFAULT`，但第一版先保持显式启用。

`plugins/codex-dev-workflow/.codex-plugin/plugin.json` 只描述本地插件本身，不包含发布信息。

## Skill 迁移规则

每个 skill 必须包含：

- `SKILL.md`
- YAML frontmatter
- `name`
- `description`

命名规则：

- 小写。
- 使用 hyphen-case。
- 不使用拟人化名称。
- folder 名与 frontmatter `name` 保持一致。

迁移时删除或改写以下 OpenCode 专用内容：

- `mode: primary`
- `mode: subagent`
- `permission:`
- `skill({ name: "..." })`
- `todowrite`
- `todoread`
- `question`
- `lsp`
- `webfetch`
- `@...` agent 调用约定
- “primary agent” 这类 OpenCode 概念

替代方式：

| OpenCode 内容 | Codex 迁移方式 |
|---|---|
| primary agent | entry skill |
| subagent wrapper | `developer` skill + worker prompt |
| `todowrite` / `todoread` | `tasks.json`、`progress.md`、普通 checklist |
| `question` | 交互式直接询问用户 |
| `lsp` | 项目已有 typecheck / lint / test 命令 |
| permission frontmatter | Codex sandbox / approval / 用户确认 |
| `@...` 调用 | 明确写成 Codex subagent delegation 行为 |

## Entry Skills

### `product-designer`

职责：把用户想法转成可确认的 design 文档。

输入：

- 用户初始想法。
- 可选：已有 repo 代码上下文。
- 可选：用户指定的参考资料或 URL。

输出：

- `docs/plans/YYYY-MM-DD-HH-MM/initial.md`
- `docs/plans/YYYY-MM-DD-HH-MM/research-topics.md`
- `docs/plans/YYYY-MM-DD-HH-MM/research.md`
- `docs/plans/YYYY-MM-DD-HH-MM/design.md`
- `docs/plans/YYYY-MM-DD-HH-MM/interview.md`

Codex 适配要求：

- 不依赖 OpenCode question tool。
- 需要用户确认时直接提问。
- 需要互联网研究时，优先官方文档，并在结果中标注来源和不确定性。
- 完成后只总结产物路径、关键假设和开放问题，不主动推进到实现。

### `tech-designer`

职责：把已确认的 design 文档转成技术方案和任务列表。

输入：

- `docs/plans/.../design.md`
- 可选：`interview.md`
- 可选：用户补充约束。

输出：

- `docs/plans/.../implementation-plan.md`
- `docs/plans/.../tasks.json`

任务列表要求：

- 任务必须足够小。
- 每个任务必须可独立验证。
- 每个任务必须包含验收标准。
- 数组顺序表示建议执行顺序。

`tasks.json` 字段建议：

```json
{
  "id": "T001",
  "title": "",
  "description": "",
  "dependencies": [],
  "files": [],
  "acceptance_criteria": [],
  "verification": {
    "commands": [],
    "expected_result": ""
  },
  "notes": ""
}
```

Codex 适配要求：

- 只做计划，不写业务代码。
- JSON 产物必须可 parse。
- 不预写完整测试实现，只描述验收标准和建议验证方式。

### `task-dispatcher`

职责：读取技术方案和任务列表，按顺序调度执行任务，维护进度。

输入：

- `implementation-plan.md`
- `tasks.json`

输出：

- `progress.md`
- 每个任务的代码变更。
- 每个任务的验证结果。
- 每个通过验证任务的 commit。
- 最终执行总结。

Codex 适配要求：

- 默认串行执行。
- 每个任务派发一个全新 worker subagent。
- worker subagent 必须只执行一个 task。
- 调度者不直接写业务代码。
- 调度者负责验证、更新 `progress.md` 和 commit。
- 失败任务最多重试 3 次。
- 3 次失败后暂停，向用户报告 blocker。
- 创建 PR 前必须询问用户。

worker prompt 必须包含：

- task id
- task description
- 完整 acceptance criteria
- 技术方案中的公共上下文
- 预期修改文件
- 验证命令
- 禁止事项
- 如果是重试，包含之前失败 summary

### `developer`

职责：短生命周期执行者说明。它本身是 skill/prompt 规范，不是用户主入口。

边界：

- 只做一个 task。
- 不选择下一个 task。
- 不 commit。
- 不修改全局 implementation plan。
- 不更新 changelog 或项目总结。
- 不做 task 之外的顺手重构。
- 尽量按 TDD 执行。
- 遇到不明显失败时按 systematic debugging 执行。

返回格式：

```md
## Summary

### 状态
成功 / 失败

### 完成内容
- ...

### 修改文件
- `path/to/file`：...

### AC 验证
- [x] AC1：...，验证方式：...

### 质量检查
- typecheck: PASS/FAIL/NOT RUN
- lint: PASS/FAIL/NOT RUN
- test: PASS/FAIL/NOT RUN

### Blockers
- ...

### 风险
- ...
```

### `quality-reviewer`

职责：review 当前 diff 或 PR，并在用户确认后更新项目上下文。

输入：

- 当前 working tree diff，或 PR diff。
- 可选：相关 plan/progress 文件。

输出：

- review findings。
- 测试覆盖和残余风险。
- 用户确认后的 `AGENTS.md` / `CHANGELOG.md` 更新。

Codex 适配要求：

- review 阶段只审查，不修复。
- findings 按严重程度排序。
- blocker 必须基于事实和可复现风险。
- 更新项目上下文前必须确认 review 已通过。
- 合并 PR 前必须询问用户。

## Capability Skills

能力型 skill 保持可复用，不作为主流程入口：

| Skill | 职责 |
|---|---|
| `writing-clearly-and-concisely` | 约束文档表达清晰、短句、可执行。 |
| `json-lint` | 约束 JSON 输出合法、字段稳定、可 parse。 |
| `test-driven-development` | 指导 RED / GREEN / REFACTOR。 |
| `systematic-debugging` | 指导复现、缩小范围、假设验证、修复。 |
| `code-review` | 指导 review 输出结构和 severity。 |
| `project-summary` | 指导更新项目上下文和 changelog。 |

## AGENTS.md 设计

`AGENTS.md` 只放长期稳定规则，不放完整流程。

建议内容：

```md
# Project Agent Guidance

## General

- 使用中文作为默认沟通语言，除非用户或原文件使用其他语言。
- 保持改动小而可审查。
- 优先遵循仓库已有模式。
- 不要主动提交，除非当前 workflow 明确要求。
- 不要主动创建或合并 PR，除非用户确认。

## Workflow Entrypoints

- 使用 `product-designer` 将想法转成 design 文档。
- 使用 `tech-designer` 将 design 文档转成 implementation plan 和 tasks.json。
- 使用 `task-dispatcher` 按任务列表执行实现。
- 使用 `quality-reviewer` 进行 review 和项目上下文更新。

## Planning Artifacts

- 计划文件放在 `docs/plans/YYYY-MM-DD-HH-MM/`。
- 执行进度记录在同目录的 `progress.md`。
- `tasks.json` 是任务状态恢复和调度的主要依据。
```

## 终端快捷入口

终端脚本只作为交互式快捷入口，不使用 headless。

### `bin/codex-design`

用途：启动 `product-designer`。

行为：

- 接收用户 idea。
- 启动交互式 Codex。
- 注入 `$product-designer` 入口提示。

### `bin/codex-tech-design`

用途：启动 `tech-designer`。

行为：

- 接收 design path。
- 启动交互式 Codex。
- 要求生成 `implementation-plan.md` 和 `tasks.json`。

### `bin/codex-dispatch`

用途：启动 `task-dispatcher`。

行为：

- 接收 plan directory 或 `tasks.json` path。
- 启动交互式 Codex。
- 要求按顺序执行任务并维护 `progress.md`。

### `bin/codex-review`

用途：启动 `quality-reviewer`。

行为：

- 启动交互式 Codex。
- review 当前 working tree 或用户指定 PR。

## 实施阶段

### Phase 0：准备

1. 确认 `tmp/` 已加入 `.gitignore`。
2. 保留现有 `tmp/` 迁移讨论文档，不迁移到正式产物。
3. 不处理 `.DS_Store`，除非用户另行要求。

验收：

- `.gitignore` 包含 `tmp/`。
- `git status --short` 中不再显示 `tmp/`。

### Phase 1：创建本地插件索引和插件骨架

1. 创建 `.agents/plugins/marketplace.json`。
2. 创建 `plugins/codex-dev-workflow/.codex-plugin/plugin.json`。
3. 创建 `plugins/codex-dev-workflow/skills/`。
4. 暂不写入实际 workflow 逻辑。

验收：

- JSON 文件可 parse。
- local plugin registry 指向 repo 内插件路径。
- 不包含远程发布配置。

### Phase 2：迁移 capability skills

迁移以下 skills：

- `writing-clearly-and-concisely`
- `json-lint`
- `test-driven-development`
- `systematic-debugging`
- `code-review`
- `project-summary`

操作：

1. 复制原 `SKILL.md` 和必要 `references/`。
2. 删除 OpenCode 专用工具调用语法。
3. 保留原文语言。
4. 不做额外润色。

验收：

- 每个 skill 都有合法 frontmatter。
- skill 名和目录名一致。
- 不包含 OpenCode 专用工具名。

### Phase 3：迁移 entry skills

创建并迁移：

- `product-designer`
- `tech-designer`
- `task-dispatcher`
- `quality-reviewer`
- `developer`

操作：

1. 把旧 agent wrapper 中的职责说明合并到对应 skill。
2. 把旧 workflow skill 中的流程迁移到对应 skill。
3. 替换拟人化入口名。
4. 替换 OpenCode subagent 调用语法。
5. 明确输入、输出、失败处理和最终 summary。

验收：

- 新入口只使用职责型名称。
- 不再暴露旧拟人化入口名。
- 每个 entry skill 都能独立说明何时触发、产出什么、何时停止。

### Phase 4：实现 task-dispatcher 的 worker 派发规范

1. 在 `task-dispatcher/references/worker-prompt-template.md` 中定义 worker prompt。
2. 在 `developer/SKILL.md` 中定义单任务执行边界。
3. 在 `task-dispatcher/SKILL.md` 中明确：
   - 每个 task 一个 worker subagent。
   - worker 只做一个 task。
   - 调度者负责验证和 commit。
   - 失败最多重试 3 次。

验收：

- worker prompt 包含足够上下文。
- worker 被禁止 commit。
- task-dispatcher 被禁止直接写业务代码。

### Phase 5：新增 AGENTS.md

1. 新建根目录 `AGENTS.md`。
2. 只写长期稳定规则。
3. 引导使用新入口 skill。

验收：

- 内容短小。
- 不复制完整 workflow。
- 不包含 headless 方案。

### Phase 6：新增终端快捷入口

1. 创建 `bin/codex-design`。
2. 创建 `bin/codex-tech-design`。
3. 创建 `bin/codex-dispatch`。
4. 创建 `bin/codex-review`。
5. 所有脚本使用交互式 `codex`，不使用 `codex exec`。

验收：

- 脚本可执行。
- 参数校验清楚。
- 不使用 headless。

### Phase 7：安装/启用说明

编写简短安装说明。

推荐命令：

```bash
codex plugin marketplace add /path/to/codex-config
```

如果需要自动启用插件，再补一个显式 init 脚本。该脚本必须说明它会修改用户 Codex 配置。

验收：

- 用户知道这是本地插件索引。
- 用户知道不会发布到官方 marketplace。
- 用户知道是否修改了 per-user Codex 配置。

### Phase 8：试运行

用一个小 feature 跑完整链路：

```text
idea
 -> product-designer
 -> design.md
 -> tech-designer
 -> implementation-plan.md + tasks.json
 -> task-dispatcher
 -> worker tasks
 -> progress.md + commits
 -> quality-reviewer
```

重点检查：

- 入口是否容易触发。
- 是否出现旧拟人化入口名。
- 是否误触发 headless 假设。
- `tasks.json` 是否稳定可 parse。
- `progress.md` 是否足够恢复执行。
- worker 是否越权规划、commit 或扩大范围。
- review 是否只输出事实性发现。

## 全局验收标准

迁移完成后应满足：

1. 新 workflow 可以通过 Codex skill 入口使用。
2. 新入口全部是职责型名称。
3. 新产物不依赖 OpenCode agent frontmatter。
4. 新产物不依赖 OpenCode 专用工具。
5. 不迁移 headless。
6. workflow 源文件保存在 repo 内。
7. 本地插件索引不会发布到 Codex 官方 marketplace。
8. 文档语言和原文语言保持一致，不做额外润色。
9. `tmp/` 被 git 忽略。

## 暂不处理

以下内容不在第一版实施范围内：

- 自动发布插件。
- 远程 marketplace。
- CI/headless workflow。
- GitHub Action。
- 自定义 Codex agent 文件。
- 自动合并 PR。
- 自动修改用户全局 Codex 配置，除非用户明确要求。

## 实施注意事项

1. 每个 phase 单独提交，便于 review。
2. 迁移文件时优先保留内容，再做最小必要适配。
3. 不要因为改名而重写整段文档。
4. 如果某段 OpenCode 机制没有明确 Codex 对应物，先改成流程性文字，不强行虚构工具。
5. 涉及用户配置的操作必须显式说明。
