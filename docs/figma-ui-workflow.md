# Figma UI workflow (experimental)

**Status: optional and experimental.** It was tested once on Grow a Yokai Fighter (2026-09-26, one Daily Rewards panel) and is not the default yet. The default is still: HTML artifact mockup → owner approves → build in Roblox with BuiltByBit assets (see CLAUDE.md). Use this route when the owner wants an editable design file, and update this doc as the workflow gets proven.

## What it does

Claude builds the UI in Figma through the official Figma MCP. The owner reviews it and can edit it by hand. **RoImport** then converts it into a Roblox ScreenGui, and Claude repairs what the converter misses through the Studio MCP.

## One-time setup

1. **Figma account.** The free Starter plan works, but it caps MCP tool calls: the first test ran out partway through. Heavy use needs a paid plan.
2. **Figma plugin for Claude Code:**
   `claude plugin marketplace add anthropics/claude-plugins-official`, then `claude plugin install figma@claude-plugins-official`.
3. **Log in.** Reload the window, run `/mcp` in an interactive Claude Code terminal, choose `plugin:figma:figma` → Authenticate → Allow access. Claude can't do this step for you.
4. **RoImport** ([roimport.com](https://roimport.com/), free): install the Figma plugin and the Roblox Studio plugin.

## Build rules for Claude (so the converter has less to break)

- **Font: Fredoka One.** It matches Roblox's built-in `FredokaOne`, so text converts exactly.
- **Flatten every icon** into a single vector (select → Flatten) and name it `Icon/<name>`. Unflattened icons arrive as dozens of empty `Vector` ImageLabels.
- **One fill per layer.** A layer with two fills (for example a dark fill plus a glow) is exported as an image instead of a Frame.
- **Don't fade a tile's contents** with opacity on layers you might export icons from. Faded source layers produce faded images.
- **Name layers for the code:** `Header`, `Title`, `CloseButton`, `Tab/<name>`, `ClaimButton`, `Day 1`, and so on. The names survive conversion, so controllers can find them.
- **Use auto-layout.** RoImport turns it into UIListLayout, UIGridLayout and UIPadding.
- Keep badges that stick out (like an "OP!" tag) inside the panel's bounds, because the panel clips its contents.

## Export and import (owner)

1. In Figma, select the **outer panel frame** and run RoImport → Export.
2. Copy the **JSON**, and **save the image zip** into the game repo under `docs/reference/figma-export/`.
3. In Studio, open RoImport, paste the JSON into "input JSON here", and import. A `RoImport` ScreenGui appears in StarterGui.

## Repair pass (Claude, through the Studio MCP)

1. **Upload the images from the zip.** Serve the folder locally (`python -m http.server 8765` in that folder) and pass `http://localhost:8765/<file>.png` URLs to the Studio MCP's `upload_image`. Figma's own asset links are rejected as "not trusted". Set each `Icon/<name>` frame to one ImageLabel with the uploaded ID.
2. **Text outlines.** RoImport copies Figma's stroke weight straight into UIStroke, which looks blocky. Set `Thickness` to about 0.45 × the Figma value (minimum 1.5) and `LineJoinMode = Round`.
3. **Any empty ImageLabel** that should be a colour (a dark tile, a gradient header): set its background colour or add a UIGradient (Rotation 90 for top-to-bottom).
4. Screenshot it in Studio, compare it with the Figma frame, then move it into place (for example `ReplicatedStorage.UiTemplates.<Panel>`) for the controller to clone.

## First test results (2026-09-26)

- **Converted well:** layout and auto-layout, corners, borders, gradients, Fredoka One text, and layer names.
- **Broke:** icons (not flattened, no images), the tile backgrounds (two fills), blocky text outlines, and a clipped badge. All were fixed with the repair pass above.
- **Cost:** the Figma Starter plan ran out of MCP calls during the repair.
- **Verdict:** promising, especially with the zip and the build rules above. Keep it experimental until a full panel goes Figma → Roblox with only the scripted repair.
