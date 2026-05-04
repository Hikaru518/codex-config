---
name: codex-workflow-guide
description: "仅当用户显式输入 `$codex-workflow-guide` 时使用。回答 codex-config 开发流水线、skill 职责、custom subagent、产物流转、模板位置和安装方式等问题。"
---

# codex-workflow-guide

## 概述

此 skill 用于回答关于 codex-config 开发流水线的一切问题。

它采用混合回答策略：

1. 流水线全局架构、职责、产物流转、执行策略 -> 读取 `references/development-workflow.md`。
2. 某个具体 skill 或 custom subagent 的详细行为 -> 动态读取当前 repo 中的实际文件。
3. 模板或 schema 的具体格式 -> 动态读取对应 skill 的 `references/` 文件。

## 何时使用

仅当用户显式输入 `$codex-workflow-guide` 时使用。

常见问题：

- "开发流程是怎么样的？"
- "有哪些入口 skill？"
- "task-dispatcher 和 developer custom subagent 分别做什么？"
- "tasks.json 的格式是什么？"
- "如何把 codex-config 安装到另一个 repo？"

## 回答策略

### 策略 1：流水线全局问题

适用场景：

- 用户问整体流程。
- 用户问角色职责。
- 用户问产物如何流转。
- 用户问安装和启动方式。

动作：

1. 读取 `references/development-workflow.md`。
2. 基于其中的 Codex 口径回答。

### 策略 2：具体 skill 或 custom subagent

适用场景：

- 用户问 `$product-designer`、`$tech-designer`、`$task-dispatcher`、`$quality-reviewer`、`$developer` 的行为。
- 用户问 capability skill，例如 `$code-review`、`$json-lint`、`$systematic-debugging`。
- 用户问 developer custom subagent。

动作：

1. 读取对应的实际文件：
   - `.agents/skills/<skill-name>/SKILL.md`
   - `.codex/agents/developer.toml`
2. 如果该 skill 有 `references/`，只读取回答所需的具体 reference 文件。
3. 综合当前文件内容回答，避免只复述静态概览。

### 策略 3：模板或 schema

适用场景：

- 用户问 design 文档模板。
- 用户问 technical design / implementation plan 模板。
- 用户问 `tasks.json` schema。
- 用户问 developer subagent prompt 或 `progress.md`。
- 用户问 review report、project context、changelog 模板。

动作：

读取对应 skill 的 `references/` 文件，并用 Markdown 链接标出路径。

## 回答要求

- 使用中文回答，除非用户或原文件使用其他语言。
- 优先简洁结构化，避免长篇复述。
- 引用具体文件时使用 Markdown 链接。
- 如果问题涉及当前 repo 实际实现，先读取当前文件再回答。
- 如果问题超出 codex-config workflow 范围，说明边界并建议用户查看相关项目文件。

## 边界

- 只回答 workflow、skill、custom subagent、模板、安装方式相关问题。
- 不执行 `$product-designer`、`$tech-designer`、`$task-dispatcher`、`$quality-reviewer` 的实际 workflow。
- 不修改文件。
- 不提交、不创建 PR。
