# AI Instruction: GitMap MCP Server Performance and Parallel GitLab Integration

## Directive Metadata
- **Prompt ID**: `117`
- **Spec ID**: `438`
- **Slug**: `gitmap-mcp-server-performance-and-gitlab-integration`
- **Target Component**: `cli/cmdmcp`, `cli/cmdautomation`, `cli/usercontext`, `cli/cmdissue`, `cli/cmdspec`

---

## High Priority Context & Non-Negotiable Instructions
Execute the complete implementation of Spec 438 covering:
1. **MCP Server Search Latency & Duration Output**:
   - In `cli/cmdmcp/tools_dispatch_search.go`: Eliminate forced `IsRegex: true` default so literal strings bypass Go's regex engine.
   - Format MCP search results with duration, total files scanned, and total hits matching CLI: `Search completed: %d hit(s) across %d file(s) in %s`.
   - In `cli/cmdautomation/search_worker.go`: Eliminate full-file `bytes.ToLower(data)` allocations via zero-allocation ASCII case-insensitive comparison.
   - Replace external subprocess calls in `handleFindTool` and `handleLfTool` with direct in-process calls.
2. **Parallel Dual-Platform Multi-User Support**:
   - Implement GitLab CLI status and multi-user account detection in `cli/usercontext/glab_auth.go`.
   - Update `cli/usercontext/gh_auth.go` to parse all authenticated accounts and designate the active user.
   - Implement default provider configuration (`github` or `gitlab`) in `cli/usercontext/provider_config.go`.
   - Update `gitmap status` and `gitmap user info` cards to concurrently render both GitHub and GitLab authorization status.
3. **Issue Comments, Directory Auto-Zipping, & Public Link Governance**:
   - Implement `gitmap issue comment <id> --body "..." [--attach <path>]`.
   - Automatically bundle directories into temporary `.zip` files under 5MB prior to invoking provider CLI.
   - Document and surface public asset URL formats (GitLab project `/uploads/` and GitHub releases).
4. **Spec Discovery Path Expansion**:
   - Support `gitmap spec next [slug]` to emit full directory and architecture spec paths.
   - Support `gitmap spec latest --path` to emit latest spec file path.
