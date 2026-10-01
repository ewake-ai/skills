---
name: ewake-connect
description: Connect this coding agent to Ewake. Use when the user wants to connect Ewake. Use also when the user asks for Ewake data and the Ewake tools are not available.
---

# Connect Ewake

This skill connects two MCP servers to the coding agent:

- **ewake**: the service map and the past investigations of the company. It needs a sign-in.
- **ewake-docs**: the public Ewake documentation. It needs no sign-in.

A tool name can have a prefix, for example `mcp__ewake__ewake_list_service_names`.

## Rules

- Do not ask the user for a password, an API key, or a token.
- Do not write a credential to a file.
- The user approves the sign-in in the browser. You cannot approve it.
- Do not guess the Ewake address. Ask the user.
- Show each command and each file change to the user before you make it.
- Do not read or show the configuration of an MCP server. It can contain a key.

## Steps

1. If a tool with a name that ends with `ewake_list_service_names` is available, go to step 7.
2. If this session has no browser, do not add a server. Do not ask for an API key. This is the case for a cloud agent, for example Claude Code on the web, a Cursor background agent, or the Copilot coding agent. If you are not sure, ask the user. Tell the user to add the connection one time in the settings of the agent:
   - **Claude Code**: add a connector on claude.ai, then sign in.
   - **Cursor**: add the server in the MCP settings of the team, then sign in.
   - **Copilot coding agent**: add the server in the settings of the repository. Put a separate Ewake API key in a secret.
   - **Codex cloud**: this is not possible today.

   Give the user this link for the details and the limits: `https://github.com/ewake-ai/skills#cloud-agents`. Then stop.
3. Ask the user for the address of their Ewake dashboard, for example `https://your-company.ewake.ai`. The address must start with `https://`. Remove a `/` at the end. The MCP address is the dashboard address plus `/mcp`.
4. Tell the user to sign in to the Ewake dashboard in the browser. Then tell the user what the approval page shows:
   - the name of the coding agent
   - the access "Read your service map, ownership, incident history, deployments and integrations". An older Ewake shows "Read your service map, ownership and incident history".
   - the return address
   - the buttons **Approve** and **Cancel**

   The user clicks **Approve**.
5. Add the two servers and start the sign-in. Use the method for the agent in use.

   A server can already exist from an earlier sign-in. Check each server with one of these commands. Use only the exit code: 0 means that the server exists. If the server exists, do not add it again.

   ```bash
   claude mcp get <name> >/dev/null 2>&1
   codex mcp get <name> >/dev/null 2>&1
   ```

   The login command waits until the user clicks **Approve**. Give it a timeout of 5 minutes or more. `codex mcp add` can also start the login.

   **Claude Code.** Run these commands:

   ```bash
   claude mcp add --transport http --scope user ewake <MCP address>
   claude mcp add --transport http --scope user ewake-docs https://docs.ewake.ai/mcp
   claude mcp login ewake
   ```

   If `claude mcp login` does not work, tell the user to run `/mcp`, select **ewake**, and sign in.

   **Codex.** Run these commands:

   ```bash
   codex mcp add ewake --url <MCP address>
   codex mcp add ewake-docs --url https://docs.ewake.ai/mcp
   ```

   If the approval page did not open, run `codex mcp login ewake`.

   **Cursor.** Do not open `~/.cursor/mcp.json`. Run these commands. They keep the other entries and do not change an existing entry.

   ```bash
   mkdir -p ~/.cursor
   if [ ! -f ~/.cursor/mcp.json ]; then
     echo '{}' > ~/.cursor/mcp.json
   fi
   merged=$(jq --arg url '<MCP address>' '.mcpServers.ewake //= {url: $url} | .mcpServers["ewake-docs"] //= {url: "https://docs.ewake.ai/mcp"}' ~/.cursor/mcp.json 2>/dev/null) && [ -n "$merged" ] && printf '%s\n' "$merged" > ~/.cursor/mcp.json
   ```

   If the commands fail, give the user the snippet below to add by hand.

   ```json
   {
     "mcpServers": {
       "ewake": { "url": "<MCP address>" },
       "ewake-docs": { "url": "https://docs.ewake.ai/mcp" }
     }
   }
   ```

   Then tell the user to open the Cursor settings and click **Needs login** next to the ewake server.

   **Other agents.** Do not open the MCP configuration of the agent. Give the user the two addresses. Tell the user to add each one as a remote MCP server with the streamable HTTP transport, if it is not there already.

6. Wait until the user tells you that the sign-in is complete.
7. Call `ewake_list_service_names`. If the tool is not available, tell the user to start a new agent session. In Claude Code, the user can also run `/mcp` and reconnect ewake. Then do this step again.
8. Report the result to the user:
   - **The tool returns service names.** The connection works. Show the names. If the result has `truncated`, tell the user that Ewake has more services.
   - **The tool returns no names.** The connection works, but Ewake has no services. Tell the user why. Ewake makes a service from one of these sources:
     - an observability integration, for example Datadog, Grafana, Loki, or Thanos
     - a Backstage `catalog-info.yaml` file
     - a deployment event of the last 14 days

     A repository alone does not make a service.

     If a tool with a name that ends with `ewake_list_integrations` is available, call it. Use only these parts of the result:
     - **Source integration**: an integration with `type` `github`, `gitlab`, `datadog`, `grafana`, `loki`, `thanos`, or `clickhouse`.
     - **Graph run**: a run with `lambda` set to `knowledge-graph` in the `hydrationRuns` of a source integration. Use it only if the `createdAt` of its integration is in the last 24 hours. Only the knowledge-graph runs write the services.

     Tell the user each reason that applies, with its next step:
     - **No integration**: there is no source integration. Tell the user to connect an integration in the Ewake dashboard, or to run the skill `ewake-report-deployments`.
     - **Paused**: there are source integrations, but each has `active` false. Tell the user to resume a source integration in the Ewake dashboard.
     - **In progress**: a graph run is pending or running, and the tool does not say that it has probably stopped. Tell the user to use this skill again after the run ends.
     - **Found nothing**: a graph run succeeded, but its summary shows that it found nothing. Tell the user which integration found nothing. Then give the next step of **No integration**.

     Without the tool, or if no reason applies, tell the user to connect an integration in the Ewake dashboard. The user can also run the skill `ewake-report-deployments`.
   - **The tool returns an authorization error.** Tell the user to sign in again. A sign-in stops 30 days after the approval.
