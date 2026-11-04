# Ewake skills

Skills that help a coding agent set up and use [Ewake](https://www.ewake.ai), an AI on-call agent for production incidents.

The skills are for Claude Code and other coding agents. They need a shell and a Git repository.

The guide is in the Ewake documentation: [Setup skills for coding agents](https://docs.ewake.ai/interfaces/setup-skills).

## Install

Use one install method for each coding agent. If you use two methods in Claude Code, each skill loads two times.

Each plugin has the four skills. The plugins for Claude Code, Cursor, and Gemini CLI also have the two Ewake MCP servers, `ewake` and `ewake-docs`. The plugin for VS Code, GitHub Copilot CLI, and Kiro has only `ewake-docs`. In these agents, you add the `ewake` server by hand. To get its address, ask the agent to "Connect Ewake".

| Coding agent | The install asks for |
|---|---|
| Claude Code | The MCP address, for example `https://your-company.ewake.ai/mcp` |
| Cursor, Gemini CLI | The host, for example `your-company.ewake.ai` |
| VS Code, GitHub Copilot CLI, Kiro | Nothing. The skill `ewake-connect` asks for the dashboard address. |

The dashboard address is the address of your Ewake dashboard, for example `https://your-company.ewake.ai`. The host is the dashboard address without `https://`. The MCP address is the dashboard address plus `/mcp`.

### Any coding agent

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

### Claude Code plugin

The plugin has the four skills and the two Ewake MCP servers, `ewake` and `ewake-docs`. The setting `ewake_mcp_address` is your Ewake dashboard address plus `/mcp`. The address must start with `https://`.

```bash
claude plugin marketplace add ewake-ai/skills
claude plugin install ewake@ewake --config ewake_mcp_address=https://your-company.ewake.ai/mcp
```

In a Claude Code session, you can also run `/plugin install ewake --marketplace ewake-ai/skills`. This command needs Claude Code 2.1.275 or later. Claude Code then asks for the address.

To sign in, run `/mcp` and select **plugin:ewake:ewake**. You can also ask Claude Code to "Connect Ewake". The plugin skills have the prefix `ewake:`, for example `/ewake:ewake-connect`.

By default, Claude Code does not update the plugin. To get the latest version, run this command, then restart Claude Code:

```bash
claude plugin update ewake@ewake
```

If you add the plugin from the plugin directory on claude.ai, its name in Claude Code is `ewake@synced`. To set the address, run `/plugin configure ewake@synced`. When you sign in to Claude Code with your claude.ai account, Claude Code updates the plugin each time it starts.

### Cursor

1. Open **Customize**.
2. Select **From GitHub Repository**. Enter `https://github.com/ewake-ai/skills`.
3. Install the plugin **ewake**. Enter your Ewake host.
4. In **Customize**, sign in to the **ewake** MCP server of the plugin.

### VS Code

1. In the Command Palette, run **Chat: Install Plugin from Source**.
2. Enter `https://github.com/ewake-ai/skills`.
3. Ask the agent to "Connect Ewake". The skill asks for your dashboard address and gives you the two server addresses.
4. Add the `ewake` server by hand, as the skill tells you.

### GitHub Copilot CLI

```bash
copilot plugin marketplace add ewake-ai/skills
copilot plugin install ewake@ewake
```

Then ask Copilot to "Connect Ewake". Add the `ewake` server by hand, as the skill tells you. VS Code also finds the plugins that Copilot CLI installs.

### Gemini CLI

```bash
gemini extensions install https://github.com/ewake-ai/skills
```

Gemini CLI asks for your Ewake host. To sign in, run `/mcp auth ewake` in a session. To change the host, run `gemini extensions config ewake`.

### Kiro

1. In the **Powers** panel, select **Add Custom Power**.
2. Select **Import power from GitHub**.
3. Enter `https://github.com/ewake-ai/skills`.
4. Select **Install**.
5. Ask Kiro to "Connect Ewake". Add the `ewake` server by hand, as the skill tells you.

### MCP Registry

The file `server.json` describes the `ewake` server for the official MCP Registry, with the name `ai.ewake/ewake`. It has no skills. A client that reads the registry asks for your Ewake host.

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
- The `ewake` MCP server reads data. It can also change the Ewake skills and the workflow prompt of each ingestion source. Each Ewake run of your company can use them. For a user with the Root role, it can also read and change `ewake.md`.
- The `ewake` server tells the coding agent to make a change only when you ask for it. Each change takes effect at once and records you as its author. Set your coding agent to ask for your approval before it uses `ewake_write_skill`, `ewake_archive_skill`, `ewake_edit_workflow_prompt`, and `ewake_edit_ewake_md`. In Cursor, the default mode Auto-review can run these tools without asking you. In **Settings > Agents > Approvals & Execution**, select **Allowlist**. Do not add these tools to the allowlist.
- The OAuth scope of the `ewake` server has the name `mcp:read`. This name does not limit the server to reads.
- The deployment report step cannot cause a deployment to fail.

For how Ewake uses your data, read the [Ewake privacy policy](https://www.ewake.ai/privacy-policy/). For data that your company sends to Ewake, your customer agreement applies.

### What each file adds and asks for

| File | Coding agent | MCP servers | Asks for |
|---|---|---|---|
| `.claude-plugin/plugin.json` | Claude Code | `ewake`, `ewake-docs` | `ewake_mcp_address`, the MCP address |
| `.cursor-plugin/plugin.json` | Cursor | `ewake`, `ewake-docs` | `EWAKE_HOST`, the host |
| `gemini-extension.json` | Gemini CLI | `ewake`, `ewake-docs` | `EWAKE_HOST`, the host |
| `plugin.json` and `mcp.json` | VS Code, GitHub Copilot CLI, Kiro | `ewake-docs` | Nothing |
| `server.json` | A client of the MCP Registry | `ewake` | `ewake_host`, the host |

Each file except `server.json` also adds the four skills. Claude Code keeps the address in its `settings.json` file. Gemini CLI keeps the host in the file `~/.gemini/extensions/ewake/.env`. In a trusted folder, a value of `EWAKE_HOST` in the file `.env` of that folder replaces this host. When a session starts, the coding agent connects to the MCP servers of its plugin:

- `ewake`: `https://<host>/mcp`, or the address in `ewake_mcp_address`. It needs a sign-in. With it, the coding agent can read the service map, the ownership data, the past investigations, the received deployments, and the integrations of your company. It can also change data, as the Safety list above shows.
- `ewake-docs`: `https://docs.ewake.ai/mcp`. It needs no sign-in. It gives the coding agent search and read access to the public Ewake documentation. The coding agent can also send feedback about a documentation page to Ewake.

### What the skills run, send, and write

**All skills.** The skills call these Ewake tools: `ewake_list_service_names`, `ewake_load_cypher_skill`, `ewake_run_cypher_query`, `ewake_list_deployments`, and `ewake_list_integrations`. A call sends service names, the repository name, a time range, or a graph query to the `ewake` server.

**`ewake-connect`** runs only the commands for the coding agent in use. `<MCP address>` is the address that you give.

```bash
# Find the servers that exist. The skill uses only the exit code.
claude mcp get <name>
claude mcp get plugin:ewake:ewake
claude mcp get plugin:ewake:ewake-docs && ! claude mcp get ewake
codex mcp get <name>

# Claude Code: add the servers to the user configuration, then open the sign-in page.
claude mcp add --transport http --scope user ewake <MCP address>
claude mcp add --transport http --scope user ewake-docs https://docs.ewake.ai/mcp
claude mcp login ewake

# Claude Code and Codex: if the sign-in reports that the address of the ewake server is not valid,
# remove the server, then add it again.
claude mcp remove ewake --scope user
codex mcp remove ewake

# Claude Code with the plugin: add no server. Only open the sign-in page.
claude mcp login plugin:ewake:ewake

# Codex: add the servers to the Codex configuration, then open the sign-in page.
codex mcp add ewake --url <MCP address>
codex mcp add ewake-docs --url https://docs.ewake.ai/mcp
codex mcp login ewake

# Cursor: merge the two servers into ~/.cursor/mcp.json with jq. The skill keeps the other entries.
# The full command is in skills/ewake-connect/SKILL.md.
mkdir -p ~/.cursor
```

**`ewake-report-deployments`**

- Reads and changes the pipeline definition, for example `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`, or `azure-pipelines.yml`.
- Runs `git ls-remote https://github.com/ewake-ai/report-deployment-action 'refs/tags/v1^{}'` if the repository pins actions to a commit SHA.
- Adds a report step to the pipeline. The step is the GitHub Action `ewake-ai/report-deployment-action`, or the script `scripts/ewake-report-deployment.sh` with the command `sh scripts/ewake-report-deployment.sh || true`.
- Creates a branch, commits the change, and opens a pull request, for example with `git` and `gh`.
- If the deployment does not show in Ewake, reads `https://docs.ewake.ai/integrations/deployment/deployment-tracking.md`.

After the merge, each production deployment sends one HTTPS POST request to `https://api.ewake.ai/api/v1/events/deployment`, or to the same path on your self-hosted Ewake address. The header `Authorization: Bearer` has the Ewake API key from the CI secret `EWAKE_API_KEY`. The body has the time, the repository name and URL, the artifact name, and the commit SHA. The body also has a fixed source name. The GitHub Action also sends the URL of the workflow run. If the CI system does not give the commit SHA, the script runs `git rev-parse HEAD`.

**`ewake-teach`**

- Reads the repository and runs `git remote get-url origin`.
- Writes only `.ewake/repo-metadata.yml`. Creates a branch, commits the file, and opens a pull request.

**`ewake-check-setup`**

- Reads the pipeline definition and runs `git remote get-url origin`.
- Changes nothing.

## Cloud agents

A cloud agent cannot open a browser, so it cannot do the sign-in. Add the connection one time in the settings of the agent, not in a session. The MCP address is your Ewake dashboard address plus `/mcp`, for example `https://your-company.ewake.ai/mcp`.

| Agent | Where to add the connection | Access |
|---|---|---|
| Claude Code | A custom connector on claude.ai | Sign-in |
| Cursor | The MCP server settings of the team | Sign-in |
| GitHub Copilot coding agent | The MCP configuration in the repository settings | Ewake API key in a secret |
| Codex cloud | Not possible today | None |

**Copilot coding agent.** An Ewake API key is not limited to the MCP server. It can also send deployment events. Through the MCP server, it can also change skills and workflow prompts, and the agent calls tools without your approval. In `tools`, list only the read tools that the agent needs, not `*`.

Create a separate key for the agent, and delete it in **API Keys** if it leaks. The secret name must start with `COPILOT_MCP_`, for example `COPILOT_MCP_EWAKE_API_KEY`. Send the key in the header `Authorization: Bearer $COPILOT_MCP_EWAKE_API_KEY`. See [the GitHub documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/extend-coding-agent-with-mcp).

**Cursor.** A Cursor cloud agent calls tools without your approval. Through the `ewake` server, it can also change skills and workflow prompts. On the Enterprise plan, an admin can limit the tools of the server for the team. Cloud agents use this limit when Team list enforcement is on.

Limits:

- The agent must have permission to reach your Ewake address.
- A cloud agent cannot reach a self-hosted Ewake instance that has a private load balancer.
- A sign-in stops 30 days after the approval. Then the person must approve again.

## Support

For help, go to [Ewake support](https://www.ewake.ai/support/).

## License

[MIT](LICENSE)
