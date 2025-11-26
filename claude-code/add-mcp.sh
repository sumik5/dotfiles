#!/bin/bash

claude mcp add -s user --transport http figma https://mcp.figma.com/mcp
claude mcp add -s user --transport stdio modular-mcp -- npx -y @kimuson/modular-mcp@latest $HOME/.claude/modular-mcp.json
