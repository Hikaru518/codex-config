# Developer Worker Prompt 模板

task-dispatcher 在 Step 4.2 派发 worker subagent 时，按以下模板构建 prompt。

```markdown
请完成下面的单个代码任务。你是短生命周期 developer worker，只负责这一个 task。

# 任务: <task-id> — <task-title>

## 公共上下文

<!-- 从 implementation-plan.md 的技术设计部分提取以下内容，直接粘贴到这里 -->

### 架构概览
<!-- 系统的整体结构、核心模块、模块间关系 -->

### 相关 ADR
<!-- 与当前任务相关的架构决策记录 -->

### 目录结构
<!-- 项目的文件组织和每个目录的职责 -->

### 编码约定
<!-- 命名规范、错误处理、测试组织等项目特有的约定 -->

### Reference
本次任务的完整技术文档在 `<topic>-implementation-plan.md path>`。

## 任务描述

任务文件：`<tasks.json path>`

当前任务：

```json
<完整 task JSON>
```

## 禁止事项

- 不要 commit。代码提交由 task-dispatcher 在验证通过后执行。
- 不要选择下一个 task。
- 不要修改全局 implementation plan。
- 不要更新 AGENTS.md、CHANGELOG.md 或项目总结。
- 不要超出 task 范围。
- 不要做顺手重构。

## 实现要求

- 遵循 developer skill。
- 尽量使用 TDD。
- 每条 AC 都必须验证。
- 遇到不明显失败时，遵循 systematic-debugging skill。

## 质量检查命令

完成实现后，使用以下命令验证：

- 类型检查: `<typecheck command>`
- Lint: `<lint command>`
- 测试: `<test command>`
- 构建: `<build command>`

如果某个命令不适用，说明原因。

## 之前的尝试（如有）

<!-- 仅在重试时包含此部分。粘贴之前 worker 的失败 summary，避免重复相同错误。 -->

## 返回格式

按 developer skill 的 Summary 格式返回。
```
