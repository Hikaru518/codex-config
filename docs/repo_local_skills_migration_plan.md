# Repo-local Skills 迁移方案

## 背景

最初方案使用 repo-local plugin registry：

```text
.agents/plugins/marketplace.json
plugins/codex-dev-workflow/
```

这个方案可以工作，但需要通过：

```bash
codex plugin marketplace add /path/to/codex-config
```

把本地插件索引注册到用户级 Codex 配置中。这样会让它更像 per-user 配置，而不是严格 per-repo 配置。

根据 Codex 官方文档 [Agent Skills](https://developers.openai.com/codex/skills) 和最小实验确认，当前 Codex 可以自动发现 repo 内的 skills：

```text
.agents/skills/<skill-name>/SKILL.md
```

因此主方案应改为 repo-local skills。

## 目标

把当前工作流配置改为：

- 不依赖 `codex plugin marketplace add`。
- 不修改 `~/.codex/config.toml`。
- 不使用 plugin registry 作为默认路径。
- skills 跟随目标 repo 版本管理。
- 进入目标 repo 后，Codex 自动发现 `.agents/skills`。
- 用户通过 `$product-designer`、`$tech-designer` 等显式触发流程。

## 目标目录结构

```text
AGENTS.md
.agents/
  skills/
    product-designer/
      SKILL.md
      agents/openai.yaml
      references/
    tech-designer/
      SKILL.md
      agents/openai.yaml
      references/
    task-dispatcher/
      SKILL.md
      agents/openai.yaml
      references/
    developer/
      SKILL.md
      agents/openai.yaml
    quality-reviewer/
      SKILL.md
      agents/openai.yaml
    code-review/
      SKILL.md
      agents/openai.yaml
      references/
    project-summary/
      SKILL.md
      agents/openai.yaml
      references/
    json-lint/
      SKILL.md
      agents/openai.yaml
    test-driven-development/
      SKILL.md
      agents/openai.yaml
      references/
    systematic-debugging/
      SKILL.md
      agents/openai.yaml
      references/
    writing-clearly-and-concisely/
      SKILL.md
      agents/openai.yaml
      references/
.codex/
  agents/
    developer.toml
bin/
  codex-design
  codex-tech-design
  codex-dispatch
  codex-review
docs/
  codex_workflow_migration_implementation.md
  repo_local_skills_migration_plan.md
```

## 不再作为默认路径的内容

删除：

```text
.agents/plugins/marketplace.json
plugins/codex-dev-workflow/.codex-plugin/plugin.json
plugins/codex-dev-workflow/
```

如果未来需要把这套 workflow 做成可安装 plugin，可以重新引入 plugin packaging。但第一版不保留，避免混淆 per-repo 与 per-user 的边界。

## 显式触发策略

所有 repo-local skills 必须显式触发。

这些 skill 的 `description` 应包含类似表达：

```yaml
description: "仅当用户显式输入 `$product-designer`，或明确要求使用 product-designer workflow 时使用。..."
```

入口型 skills：

- `product-designer`
- `tech-designer`
- `task-dispatcher`
- `developer`
- `quality-reviewer`

能力型 skills 也设置 `agents/openai.yaml`：

```yaml
policy:
  allow_implicit_invocation: false
```

能力型 skills：

- `code-review`
- `project-summary`
- `json-lint`
- `test-driven-development`
- `systematic-debugging`
- `writing-clearly-and-concisely`

## 使用方式

在目标 repo 中放入：

```text
.agents/skills/
.codex/agents/developer.toml
AGENTS.md
```

然后：

```bash
cd /path/to/target-repo
codex
```

在 Codex 中显式输入：

```text
$product-designer
```

或：

```text
$tech-designer
```

不需要运行：

```bash
codex plugin marketplace add ...
```

## 安装到其他 repo

第一版使用手动复制：

```bash
mkdir -p /path/to/target-repo/.agents /path/to/target-repo/.codex/agents
cp -R /Users/peiguangwang/workspace/codex-config/.agents/skills /path/to/target-repo/.agents/
cp /Users/peiguangwang/workspace/codex-config/.codex/agents/developer.toml /path/to/target-repo/.codex/agents/
```

然后手动合并 `AGENTS.md` 中的 workflow 入口规则。

不要直接覆盖目标 repo 现有的 `AGENTS.md`。

## 后续可选脚本

可以新增：

```bash
bin/install-into-repo /path/to/target-repo
```

职责：

- 创建 `/path/to/target-repo/.agents/skills`
- 创建 `/path/to/target-repo/.codex/agents/developer.toml`
- 同步 skills
- 检查目标 repo 是否已有 `AGENTS.md`
- 如果有，只提示用户合并 workflow 入口规则，不自动覆盖
- 如果没有，可以创建最小 `AGENTS.md`
- 不修改 `~/.codex/config.toml`
- 不注册 marketplace

## 当前 PR 改造步骤

1. 创建 `.agents/skills/`。
2. 将 `plugins/codex-dev-workflow/skills/*` 移动到 `.agents/skills/`。
3. 删除 plugin packaging：

```bash
rm -rf plugins/codex-dev-workflow
rm -rf .agents/plugins
```

4. 更新 README：
   - 删除 `codex plugin marketplace add ...`。
   - 说明 `.agents/skills` 会被 Codex 在 repo 内发现。
   - 说明入口必须通过 `$skill` 显式触发。
5. 更新 `docs/codex_workflow_migration_implementation.md`：
   - 将 repo-local plugin registry 改为 repo-local skills。
   - 移除 marketplace 作为默认路径。
6. 保留 `bin/codex-*` 作为快捷入口。
7. 新增 `.codex/agents/developer.toml`，将短生命周期执行者落实为 Codex custom subagent。
8. 为所有 `.agents/skills/*` 增加 `agents/openai.yaml`，设置 `allow_implicit_invocation: false`。
9. 验证所有 skills：

```bash
for d in .agents/skills/*; do
  python3 /Users/peiguangwang/.codex/skills/.system/skill-creator/scripts/quick_validate.py "$d"
done
```

10. 跳过 Codex 发现验证；该项已经单独验证过。

## 验收标准

完成后应满足：

1. `.agents/skills` 下包含全部 workflow skills。
2. repo 中不再包含 plugin registry 默认路径。
3. 不需要执行 `codex plugin marketplace add`。
4. `~/.codex/config.toml` 不需要修改。
5. 进入 repo 后，Codex 能发现这些 skills。
6. 所有 repo-local skills 只通过显式 `$skill` 触发。
7. `developer` 是 Codex custom subagent，并显式使用 `$developer` 执行协议。
8. README 和实施文档中的安装说明与实际行为一致。
