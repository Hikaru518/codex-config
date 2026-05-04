---
name: product-designer
description: "仅当用户显式输入 `$product-designer`，或明确要求使用 product-designer workflow 时使用。将用户想法转化为可确认的 design 文档并落盘。"
---

# product-designer

## 概述

product-designer 技能帮助用户把一个想法转变为更详细的 design 文档。

## 强制的工作流程

按下面流程执行。在回复中维护简短 checklist；所有持久产物写入同一个 `docs/plans/YYYY-MM-DD-HH-MM/` 目录。

### Step 1: 检查设置

1. 检查项目目录下是否有 `docs/plans`，如果没有则创建。
2. 在 `docs/plans` 中创建 `YYYY-MM-DD-HH-MM` 目录。
3. 将用户最初输入的内容记录到 `docs/plans/YYYY-MM-DD-HH-MM/initial.md`。

**重要**：`YYYY-MM-DD-HH-MM` 是本次 product design 的目录，后续所有内容都放在这里。

### Step 2: research 前的准备

1. 询问用户是否需要研究项目中的内容：

```text
问题: "我是否需要探索已有的代码库中的内容"
选项 A: 请探索现在的代码库中的内容。
选项 B: 不用探索。
```

2. 判断是否需要互联网研究。针对用户的问题列出 2-4 个研究主题，并直接询问用户选择哪些主题：

```text
问题: "我应该在互联网中进行下列关于哪些内容的探索？"
选项 A: [Topic 1]. [Reason why need research on topic 1].
选项 B: [Topic 2]. [Reason why need research on topic 2].
选项 C: [Topic 3]. [Reason why need research on topic 3].
选项 D: 不用探索。
```

3. 将用户回答记录到 `docs/plans/YYYY-MM-DD-HH-MM/research-topics.md`。

### Step 3: research

根据 Step 2 的回答执行研究：

1. 如果需要项目内探索，研究：
   - 项目内现有模式（existing patterns/conventions）
   - 项目中的领域知识文档（domain knowledge）
   - 最近的提交

2. 如果需要互联网研究，搜索：
   - 关于这个问题的常见做法、最佳实践、sota
   - 相关官方文档。需要查阅文档时，优先官方文档，避免二手资料

3. 将研究报告保存到 `docs/plans/YYYY-MM-DD-HH-MM/research.md`，格式参考 `references/research-template.md`。

原则：

- 获取相关文档页面，收集关键事实（API、限制、最佳实践、版本说明）。
- 若参考 URL 不可用，查找官方替代来源并标注不确定性。
- 如果使用 subagent 做研究，项目内探索应只读；互联网研究只负责研究，不写最终 design。

### Step 4: 用户访谈 interview

参考 `references/product-interview.md` 对用户进行访谈。

访谈目标：

- 明确 MVP 范围。
- 澄清用户故事。
- 明确非目标。
- 明确约束、风险和开放问题。
- 避免直接进入实现讨论。

### Step 5: 保存产物

最终产出：

- `docs/plans/YYYY-MM-DD-HH-MM/<topic>-design.md`
- `docs/plans/YYYY-MM-DD-HH-MM/<topic>-interview.md`

design 文档格式参考 `references/design-template.md`。

## 完成产出之后

总结本次产出内容和保存路径。

重要：不要询问用户是否要开始实施，等待用户的指令。
