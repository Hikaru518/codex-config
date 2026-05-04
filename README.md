# codex-config

这是一个 repo-local Codex 工作流配置包，用 `.agents/skills` 暴露一组开发流程 skills。

## 入口

- `$product-designer`：将想法转成 design 文档。
- `$tech-designer`：将 design 文档转成 implementation plan 和 tasks.json。
- `$task-dispatcher`：按 tasks.json 串行派发 developer custom subagent，并维护 progress.md。
- `$developer`：执行单个 bounded coding task。
- `$quality-reviewer`：review 当前 diff 或 PR，并在确认后更新项目上下文。

## 使用 repo-local skills

根据 [Codex Agent Skills](https://developers.openai.com/codex/skills) 官方文档，repo-scoped skills 放在 `.agents/skills`。进入目标 repo 后启动 Codex，即可显式使用这些 skills。

不需要运行 `codex plugin marketplace add ...`，也不需要修改 `~/.codex/config.toml`。

所有 repo-local skills 都通过 `$skill-name` 显式触发；`developer` 同时是 Codex project-scoped custom subagent，定义在 `.codex/agents/developer.toml`。

## 终端快捷入口

```bash
bin/codex-design "我想做一个地图编辑器"
bin/codex-tech-design docs/plans/<plan>/<topic>-design.md
bin/codex-dispatch docs/plans/<plan>/<topic>-tasks.json
bin/codex-review
```

这些脚本启动交互式 Codex，不使用 headless 模式。
