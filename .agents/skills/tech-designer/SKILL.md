---
name: tech-designer
description: "仅当用户显式输入 `$tech-designer`，或明确要求使用 tech-designer workflow 时使用。将 design doc 转化为 technical design、implementation plan 和 tasks.json。"
---

# tech-designer

## 概述

在开始任何实现（写代码/改配置/改行为）之前，将产品视角的 design 文档转化为统一的技术方案与可调度的任务拆解，作为后续串行开发的输入。

最终输出三个文件：

1. `<topic>-implementation-plan.md` — 技术设计 + 任务的整合摘要
2. `<topic>-technical-design.md` — 统一的技术设计文档（架构、ADR、数据模型、编码约定等）
3. `<topic>-tasks.json` — 细粒度任务列表与执行顺序

## 强制的工作流程

按下面流程执行。在回复中维护简短 checklist，并把持久产物写入对应的 plan 目录。

### Step 1: 读取并理解输入

目的：加载 product design 阶段产出的 design doc 与讨论材料，建立公共上下文。

具体动作：

1. 定位本次 planning 的输入：
   - 优先使用用户显式提供的路径。
   - 否则询问用户本次 planning 的输入是什么。
2. 读取相关文件：
   - `<topic>-design.md`
   - `research.md`
   - `<topic>-interview.md`
3. 整理要点：
   - 项目一句话目标、MVP 范围、关键约束/假设
   - User Stories（尤其是 P0）
   - 已做过的研究结论（来自 `research.md`）
4. 输出一段简要总结，并向用户确认，避免理解偏差。

### Step 2: 代码库探索（可选）

如果是在已有代码库上开发，需要先理解现有模式与约束。

直接询问用户：

```text
问题: "这是一个全新项目还是在已有代码库上开发？"
选项 A: 全新项目（greenfield），跳过代码库探索
选项 B: 在已有代码库上开发（brownfield），请探索现有代码与模式
```

如果选择 B，完成只读代码库探索：

- 技术栈（语言/框架/构建工具/测试框架）
- 目录结构与模块边界
- 现有编码约定（命名、错误处理、日志、测试组织）
- 可复用的组件/模式（给出证据：文件路径）

将探索发现汇总到技术设计的“开发背景 / 现有约束”部分。

### Step 3: 架构决策访谈

目的：和用户讨论并最终决定关键技术决策。

步骤：

1. 根据 design、research 和代码库探索结果，自主分析需要决策的技术问题。
2. 必要时进行互联网技术搜索。优先官方文档和一手资料。
3. 一次提出一个问题。每个问题提供 2-3 种方案、权衡和推荐。
4. 按重要程度排序，从最重要的问题开始。
5. 当没有更多问题时，展示决策摘要，等待用户确认。

原则：

- 一次一个问题。
- 优先使用多项选择题。
- 无情地践行 YAGNI。
- 在确定最终方案之前，始终探索备选方案。
- 展示设计，获得批准后再继续推进。
- 如果某些内容不清晰，随时返回并澄清。

### Step 4: 技术设计（technical design）

目的：统一架构与关键技术决策，确保后续开发流程中不会做出互相冲突的实现选择。

1. 根据复杂度判断采用轻量模式还是完整模式，并让用户确认：

```text
问题: "本次 technical design 采用哪种深度？"
选项 A: 轻量模式（跳过「数据模型」「API/接口设计」「目录结构」3 节，必要时仅给出最小约定）
选项 B: 完整模式（输出全部 7 节）
```

2. 按 `references/technical-design-template.md` 输出技术设计。
3. 将技术设计保存到 `docs/plans/<YYYY-MM-DD-HH-MM>/<topic>-technical-design.md`。
4. 展示技术设计要点，请用户 review。

注意：技术设计必须自成体系。没有任何先验知识的工程师或 coding agent 应该仅通过阅读该文档就能理解如何构建，并可以开始代码工作。

### Step 5: 任务拆解与排序（tasks）

目的：根据 design 和 technical design 拆解细粒度开发任务，并按逻辑依赖关系排出串行执行顺序。

任务粒度标准（必须同时满足）：

- 单个 LLM agent 在一个 session 内可完成。
- 产出可独立编译/运行的代码变更。
- 影响文件数（create + modify + test）建议 <= 5-8。
- 至少包含 1 条可自动验证的验收标准（AC）。

任务格式遵循 `references/task-template.md`。

排序原则：

- 基础设施/初始化任务优先。
- 被依赖的任务排在依赖它的任务之前。
- 同等条件下，优先级高的任务（P0 > P1 > P2）排在前面。

呈现方式：

- 将任务列表整体展示给用户，而不是逐条确认。
- 说明排序理由。
- 用户确认后，将任务信息保存为 `<topic>-tasks.json`。
- `tasks.json` 必须遵循 `references/tasks-json-schema.md`，并按 $json-lint 的要求确保可 parse。

### Step 6: 生成总结文档

把技术设计 + 任务整合为可被人类审阅与机器调度的最终产物。

输出位置：默认保存到 `docs/plans/<YYYY-MM-DD-HH-MM>/`，除非用户指定其它目录。

产出文件：`<topic>-implementation-plan.md`，格式遵循 `references/implementation-plan-template.md`。

## 完成产出之后

总结本次产出内容和保存路径。

重要：不要主动开始实施 tasks（写代码/改配置/跑命令），等待用户明确指令。
