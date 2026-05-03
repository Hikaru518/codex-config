---
name: quality-reviewer
description: "用于审查当前 diff 或 PR，并在审查通过且用户确认后更新项目上下文。先做事实性 code review，再处理 AGENTS.md / CHANGELOG.md。"
---

# quality-reviewer

## 概述

quality-reviewer 负责质量层工作：

1. 审查当前 working tree 或 PR 代码变更。
2. 输出结构化 review findings。
3. 审查通过后，在用户确认下更新项目级上下文。
4. 合并 PR 前必须再次询问用户。

## 强制流程

### Step 1: 确定审查对象

优先使用用户显式提供的对象：

- PR 链接或编号
- 当前 working tree diff
- 指定分支对比

如果用户没有提供，先询问用户要 review 哪个对象。

### Step 2: 代码审查

遵循 code-review skill。

审查维度：

- 业务目标是否达成。
- 架构位置是否合理。
- 正确性和回归风险。
- 安全与健壮性。
- 测试覆盖。
- 代码清晰度与单一职责。
- 是否符合关联 implementation plan 和 tasks.json。

要求：

- review 阶段只审查，不修复。
- findings 按严重程度排序。
- blocker 必须基于事实和可复现风险。
- 不要仅仅聚焦 diff，必要时检查上下游代码。
- 可以运行相关验证命令；如果不能运行，说明原因。

### Step 3: 输出 review 结论

输出：

- findings（按 blocker / warning / suggestion 分组）
- 质量检查结果
- 测试覆盖判断
- 残余风险
- 是否通过 review

如果有 blocker，停止流程，等待用户修复。

### Step 4: 更新项目上下文（review 通过后）

只有在 review 通过后，才进入项目上下文更新。

遵循 project-summary skill，基于实际代码状态更新：

- `AGENTS.md`
- `CHANGELOG.md`

要求：

- 文档反映现实，而不是计划中的设计。
- 只写项目特有、agent 可能猜不到的规则。
- 不写通用最佳实践。
- 更新前向用户说明要改哪些文档。

### Step 5: 合并 PR（用户确认后）

如果审查对象是 PR：

1. 展示 review 结论和文档更新摘要。
2. 询问用户是否合并 PR。
3. 用户确认后再执行 merge。

如果用户不确认，PR 保持 open 状态。

## 完成产出之后

总结：

- 审查对象
- review 结论
- blocker / warning 数量
- 已运行的验证命令
- 已更新的文档
- PR 状态（如适用）
