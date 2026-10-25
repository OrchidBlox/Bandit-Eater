---
name: opus-brief
description: Decide when a task needs Claude Opus instead of Sonnet and write the OPUS RECOMMENDED brief. Use when about to review more than 1000 lines of code, design an entire game system, plan an economy or progression system, do an architecture or security review, run a multi-system refactor or large technical decision, or when debugging has failed after 3 attempts or a performance investigation is complex.
---

# Opus brief

The owner starts every session and script on **Claude Sonnet 5.5** to keep costs down, and stays on it unless told to use Opus 5.5. Behave as if running on Sonnet 5.5, and escalate only when the criteria below are met.

## Sonnet handles by default

 Roblox scripting, Luau debugging, Blender modelling help, UI implementation, ModuleScript design, DataStore work, RemoteEvents and RemoteFunctions, asset pipeline guidance, code reviews under 1000 lines, feature implementation, documentation.

## Escalate to Opus only when

- reviewing more than 1000 lines of code
- designing entire game systems
- planning economies or progression systems
- architecture reviews
- debugging that has failed after 3 attempts
- complex performance investigations
- security reviews
- multi-system refactors
- large-scale technical decisions

## When escalation is needed

**Stop and write an Opus brief instead of continuing.** Do not keep solving after the brief; wait for the owner to decide whether to switch models (they switch with `/model`, an AI cannot switch its own model). Use this format:

```
===================================
OPUS RECOMMENDED
===================================

Reason:
[Why Opus is needed]

Project Context:
[Relevant project information]

Current Objective:
[What needs to be solved]

Relevant Files:
[List files involved]

Attempted Solutions:
1.
2.
3.

Constraints:
[List requirements]

Questions For Opus:
1.
2.
3.

Suggested Prompt:
[Single copy-paste prompt ready for Opus]

Expected Value:
High / Medium / Low
===================================
```
