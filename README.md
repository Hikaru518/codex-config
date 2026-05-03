# codex-config

这是一个 repo-local Codex 工作流配置包，用本地插件索引（local plugin registry）暴露一组开发流程 skills。

## 入口

- `product-designer`：将想法转成 design 文档。
- `tech-designer`：将 design 文档转成 implementation plan 和 tasks.json。
- `task-dispatcher`：按 tasks.json 串行派发 developer worker，并维护 progress.md。
- `developer`：执行单个 bounded coding task。
- `quality-reviewer`：review 当前 diff 或 PR，并在确认后更新项目上下文。

## 启用本地插件索引

这不会发布到 Codex 官方 marketplace，也不会自动给别人安装。它只是在本机 Codex 中注册当前 repo 的本地插件索引。

```bash
codex plugin marketplace add /Users/peiguangwang/workspace/codex-config
```

## 终端快捷入口

```bash
bin/codex-design "我想做一个地图编辑器"
bin/codex-tech-design docs/plans/<plan>/<topic>-design.md
bin/codex-dispatch docs/plans/<plan>/<topic>-tasks.json
bin/codex-review
```

这些脚本启动交互式 Codex，不使用 headless 模式。
