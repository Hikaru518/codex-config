# codex-config

这是一个 repo-local Codex 工作流配置包，用 `.agents/skills` 暴露一组开发流程 skills。

## 入口

- `$product-designer`：将想法转成 design 文档。
- `$tech-designer`：将 design 文档转成 implementation plan 和 tasks.json。
- `$task-dispatcher`：按 tasks.json 串行派发 developer custom subagent，并维护 progress.md。
- `$developer`：执行单个 bounded coding task。
- `$quality-reviewer`：review 当前 diff 或 PR，并在确认后更新项目上下文。
- `$codex-workflow-guide`：说明开发流水线、入口职责、产物流转、模板位置和安装方式。

## 使用 repo-local skills

根据 [Codex Agent Skills](https://developers.openai.com/codex/skills) 官方文档，repo-scoped skills 放在 `.agents/skills`。进入目标 repo 后启动 Codex，即可显式使用这些 skills。

不需要运行 `codex plugin marketplace add ...`，也不需要修改 `~/.codex/config.toml`。

除写作辅助 `$writing-clearly-and-concisely` 可按场景隐式触发外，workflow 相关 repo-local skills 都通过 `$skill-name` 显式触发；`developer` 同时是 Codex project-scoped custom subagent，定义在 `.codex/agents/developer.toml`。

## 安装到目标 repo

一次性安装命令（需在本仓库目录内运行）：

```bash
make install
```

在任意目标 repo 目录初始化配置：

```bash
cd /path/to/target-repo
codex-config-init
```

或直接指定目标目录：

```bash
codex-config-init /path/to/target-repo
```

行为说明：

- 命令会复制 `.agents/skills` 和 `.codex/agents/developer.toml`。
- 命令不会创建、修改或合并目标 repo 的 `AGENTS.md`。
- 命令不会修改 `~/.codex/config.toml`，也不会注册 plugin marketplace。
- 若目标 repo 已有同名 skill 或 `.codex/agents/developer.toml`，默认报错退出；确认要替换时使用 `--force`。

安装完成后，在目标 repo 中启动 Codex 并输入 `$codex-workflow-guide` 查看流程说明。

## 终端快捷入口

```bash
bin/codex-design "我想做一个地图编辑器"
bin/codex-tech-design docs/plans/<plan>/<topic>-design.md
bin/codex-dispatch docs/plans/<plan>/<topic>-tasks.json
bin/codex-review
```

这些脚本启动交互式 Codex，不使用 headless 模式。
