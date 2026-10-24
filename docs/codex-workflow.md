# Codex workflow

How Claude hands work to ChatGPT Codex. Codex writes **big code changes** and builds **Blender models**; Claude writes the spec, then reviews, fixes, and tests the result. Small fixes are made by Claude directly.

## Finding Codex

Codex is not on PATH. It ships inside the ChatGPT VS Code extension, and the version folder changes when the extension updates, so search for it instead of hard-coding it:

```
%USERPROFILE%\.vscode\extensions\openai.chatgpt-<version>-win32-x64\bin\windows-x86_64\codex.exe
```

## Running a spec

Write the spec to a file, then run it from the repo root:

```bash
codex.exe exec -m <model> -c model_reasoning_effort="medium" -s workspace-write -C . - < spec.txt > codex.log 2>&1
```

- `-m <model>`: choose per run. Use the cheaper default model unless the owner asks for a stronger one, and don't edit `~/.codex/config.toml` to change it.
- `-s workspace-write`: Codex can write only inside the repo. (`--full-auto` no longer exists.)
- For Blender work, also pass `-c 'mcp_servers.blender.default_tools_approval_mode="approve"'`. A non-interactive run can't approve tool calls, so without it every Blender MCP call fails with "requires approval, but approval policy is never".
- Run it in the background and read the end of `codex.log` when it finishes.

`scripts/codex-run.sh <spec> [model] [reasoning] [code|blender|studio]` does all of this and logs to `.codex-tmp/logs/`:

- **`code` (default)**: no automatic reviewer (owner's rule, 2026-09-28). Codex writes the code and runs `rojo build` to check it compiles; it does not use the Roblox Studio MCP. Claude does all Studio testing afterwards, as it always has, so Codex testing in Studio first was duplicate work.
- **`blender`**: no automatic reviewer; only the Blender MCP tools are pre-approved.
- **`studio`**: keeps `--approve-for-me`, which routes approval requests to Codex's automatic reviewer. Use it only for runs that must work in Studio through the Roblox Studio MCP, such as placing generated map props.

Why the reviewer is off by default: it is a second model that re-reads the whole run on every tool call and bills the same Codex credits. On an earlier project it added 0.5–1.7M tokens to each run and doubled one of them, and it was the main reason credits ran out much faster than before.

## Keeping Codex usage down (owner's rules, 2026-09-28)

Codex re-sends everything in the run so far (tool outputs, images) on every tool call, so each step of a long run costs more than the last. For every spec:

- **One job per run.** One model per Blender run; one milestone per code run. Put the next one in its own spec after reviewing the first.
- **Short printouts and messages.** Ask Codex to print only summaries and failures, never whole files, scene dumps or long logs, and to keep its messages short.
- **Short, focused inputs.** Point Codex at the exact files and sections it needs rather than long shared documents.
- **Cap the retries (owner's rule, 2026-10-10).** Every spec says: if the same step fails twice, stop, leave the work saved as it is, and report the step, the error and what was tried. Never rebuild from scratch to fix a failure. A failure then costs a little instead of draining the credit, because Codex tends to loop on a fix.
- **Reuse a tested helper, don't re-write it.** When several models share a base file, the repeated steps (snapshot the base, recolour, bake, export, validate, review images) live in one tested script, [blender/model_tools.py](../blender/model_tools.py). The spec tells Codex to read its docstring and write only a short per-model script that calls it. On an earlier project this took a run from about 71k tokens to about 47k. A fix to the helper helps every later model.
- **Check the first model before queueing more.** Run one, review it, fix the spec if needed, then run the next. A problem in a queue repeats for every model in it. Don't chain runs with a script that starts the next one on its own.
- **Blender runs** also build in two stages (mesh, then finish, or `full` when the owner is away), check with one composite image per check, and use one short brief per model. Details in [blender/README.md](../blender/README.md), section 3.

## Code spec template

```
<Game name> (Roblox, Rojo, Luau). <One-line goal>.

CONSTRAINTS
- Do NOT edit: <map files, default.project.json, unrelated services, docs/>.
- Match the surrounding code style (naming, comment density, module API style).
- Workspace.StreamingEnabled is on: client code must look up map objects lazily.
- Server authority: the server decides outcomes; validate every remote.

DATA
<config tables to add, with exact values>

FILES
<each file to create or change, the functions, and the rules they follow>

EDGE CASES
<leaving mid-action, respawn, duplicate requests, missing models>

After editing, run `rojo build -o .codex-tmp/build.rbxlx` and fix any errors. If the same build error survives two fixes, stop and report the error and what you tried instead of continuing. Do not use the Roblox Studio MCP; Claude tests in Studio. Print only errors, keep messages short, and report the files changed and a short summary.
```

## Blender spec template

```
TASK SCOPE (strictly enforced):
- Your ONLY job: build <asset> in Blender using the Blender MCP tools. One model per spec.
- STAGE: mesh | finish | full (see blender/README.md, section 3).
- Do NOT edit src/, docs/, default.project.json, or Roblox/Studio files. Do NOT use the Roblox_Studio MCP.
- Write files only under blender/. Follow the build rules in blender/README.md.
- Brief: blender/briefs/<Model>.md. Visual reference: blender/design/<file>.
- Check each step with one composite image (views tiled into one PNG, about 800px) and fix obvious problems. Print only summaries and failures.
- RETRY CAP (credits): if the same bake, build or export step fails twice, STOP. Leave the .blend saved as it is and report exactly which step failed, the error message and what you tried. Never rebuild from scratch to fix a failure.
- USE THE SHARED HELPER (when the model comes from a shared base): blender/model_tools.py already does the base snapshot, recolour, bake, FBX export, validation and review images, and is tested. Read its docstring, then write only a SHORT per-model script that supplies this model's colours and details and calls it. Do not rewrite the bake, export or preview code.
- Report: objects, triangle counts, bones, actions, export paths, what to check by eye.

THE BRIEF:
<the asset brief>
```

## Claude's review checklist

1. Read the whole diff, not only Codex's summary.
2. Check the scope: nothing outside the allowed files changed.
3. Look for client/server mistakes: trusting the client, unvalidated remotes, missing cleanup on leave or destroy.
4. Look for Roblox pitfalls: instances used before they are parented (animations won't load), StreamingEnabled lookups, yields in hot loops.
5. Fix small problems directly; send big ones back to Codex with a focused follow-up spec.
6. Run `rojo build`, sync, playtest through the Studio MCP, and check Output for errors.
7. Commit with a message that says what was built and what was tested.
