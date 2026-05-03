# Project Agent Guidance

## General

- 默认使用中文沟通；如果用户或原文件使用其他语言，保持原语言。
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
