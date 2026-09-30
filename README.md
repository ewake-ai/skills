# Ewake skills

Skills that help a coding agent set up and use [Ewake](https://www.ewake.ai).

> **Preview.** These skills are in preview. They can change without notice.

## Install

```bash
npx skills add ewake-ai/skills
```

The command installs the skills into the repository for the coding agents that you select. Commit the files so that your team gets them.

Then ask your coding agent, for example:

- "Connect Ewake"
- "Report our deployments to Ewake"
- "Teach Ewake about this repository"
- "Check the Ewake setup"

For Cursor, the connect skill uses `jq` to add the servers. If `jq` is not installed, the skill gives you the entries to add by hand.

## Skills

| Skill | What it does |
|---|---|
| `ewake-connect` | Connects the coding agent to Ewake and to the Ewake documentation. Start here. |
| `ewake-report-deployments` | Adds the deployment report step to the CI pipeline and opens a pull request. |
| `ewake-teach` | Maps the services of the repository to `.ewake/repo-metadata.yml` and opens a pull request. |
| `ewake-check-setup` | Reports what Ewake knows about the repository and what is missing. Changes nothing. |

## Safety

- No skill asks for an API key, a password, or a token.
- Each skill shows the change and waits for your approval before it commits.
- The Ewake MCP server only reads data. Its only scope is `mcp:read`.
- The deployment report step cannot cause a deployment to fail.

## Cloud agents

A cloud agent cannot open a browser, so it cannot do the sign-in. Add the connection one time in the settings of the agent, not in a session. The MCP address is your Ewake dashboard address plus `/mcp`, for example `https://your-company.ewake.ai/mcp`.

| Agent | Where to add the connection | Access |
|---|---|---|
| Claude Code | A custom connector on claude.ai | Sign-in |
| Cursor | The MCP server settings of the team | Sign-in |
| GitHub Copilot coding agent | The MCP configuration in the repository settings | Ewake API key in a secret |
| Codex cloud | Not possible today | None |

**Copilot coding agent.** An Ewake API key is not limited to the MCP server. It can also send deployment events. Create a separate key for the agent, and delete it in **API Keys** if it leaks. The secret name must start with `COPILOT_MCP_`, for example `COPILOT_MCP_EWAKE_API_KEY`. Send the key in the header `Authorization: Bearer $COPILOT_MCP_EWAKE_API_KEY`. See [the GitHub documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp).

Limits:

- The agent must have permission to reach your Ewake address.
- A cloud agent cannot reach a self-hosted Ewake instance that has a private load balancer.
- A sign-in stops 30 days after the approval. Then the person must approve again.

## License

[MIT](LICENSE)
