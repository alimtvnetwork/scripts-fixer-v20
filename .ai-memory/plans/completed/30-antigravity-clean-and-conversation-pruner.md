# Plan: Antigravity Clean, SQLite Conversation Pruner & Gemini Brain Reducer

- **Slug:** `30-antigravity-clean-and-conversation-pruner`
- **Status:** `completed`
- **Date Completed:** 2026-09-22
- **Target OS:** Windows, Ubuntu Linux, macOS

---

## User Request (Verbatim)

```text
https://prnt.sc/4kUxF4yeDzZU
https://prnt.sc/VeicLkLRj9ca
https://prnt.sc/BwnuHigw8hVE


So I have added a clear AGY, that means anti-gravity clear command, that you can include in your run command, like AGY space clear or clean. That will clean and run this PowerShell. So keep the PowerShell in the right order, how the folder is structured and how you keep it. So same way, I think you should enhance this PowerShell. That's the next step. Afterwards, you should also create the script for the Ubuntu so that we can clear this up. Do you understand what I'm saying? Can you please help me in this regard? And yeah, so this is what I want right now. Can you please do that for me?

also at the same time enhance it, there should be gemini brain folder which also requires removal of somethings to reduce the conversation weight or issues, can you please do that???

DOn't run the script it will close the antigravity okay, just predict for now, can you please

C:\Users\Administrator\.gemini

%appdata%\..\.gemini

C:\Users\Administrator\.gemini\antigravity\conversations
%appdata%\..\.gemini\antigravity\conversations
%appdata%\..\.gemini\antigravity\brain


So here, basically in this section, the conversations are saved as a SQLite database. Okay? Now here our goal would be looking into the big conversation, which is more than 100 KB or let's say 200 KB. All the conversations like this, we would read that database table and try to pull out the conversation to a backup section of our own database. So we would create our own database and keep all of these with a separate database, and keep a log from which ID we have done what. And also inside that database, we should see the project full path, project slug, GitHub, everything should be saved first. Okay. Extract from this, and then it would reduce the last few conversation only so that the size remains under 200 kilobytes. Okay? That is a hard process, so a lot of computation needs to be done. Also at the same time, it can be redo and undo as well. So this is very important. And at the end of your transaction, you would update, this is how user can undo all the conversation if they wanted to. Okay? But this is the optimized. So we will not remove everything, but just keep the last one or two conversation, keep it under 100 KB. Do you understand? So this is the most crucial part I think we need to work on. I think this is what nobody has worked on. Okay. And yeah, but this is the most important concept. And then we also have to go inside the Gemini brain folder. The brain folder has lots of conversation. We cannot just directly delete stuff. Remember that. So anything we remove, we should also keep a backup to our temp directory. Not inside the repository, probably the OS temp directory. Okay? So that user can revert back if they wanted to, but it's for a short period of time, it's not for a long period of time. And also that should show up after the transaction is done. It should say, "You can revert back only now, but not later on" with the warning sign. Okay? And when the script's running, it should also say, "It's unrevertible, so take actions with your knowledge, please."



So our job is also to reduce this brain section, but not to just remove everything, but remove it in an engineering way so that the project and the last conversation does not remove from the anti-gravity. So we always wanted to keep the last conversation so that the project does not remove or conversation does not remove. Make sure of that. Okay? So think a lot. Okay, then you start doing it and do not from the script. I repeat, do not from the script. Is it clear?

Also the same thing needs to be done for macos, ubuntu etc, can you please plan and do for those, clear???
```

---

## Visual Specification References (Ingested Screenshots)

The user supplied 3 screenshots demonstrating key target locations:

1. **`AppData\Roaming\Antigravity` Caches & Storages:**
   ![Antigravity Roaming Caches](assets/screenshots/30-antigravity-clean-01.png)
   - Targets highlighted: `blob_storage`, `Cache`, `Code Cache`, `DawnGraphiteCache`, `DawnWebGPUCache`, `GPUCache`, `Local Storage`, `Session Storage`, `Shared Dictionary`.

2. **`.gemini` Root Layout:**
   ![Gemini Root Structure](assets/screenshots/30-antigravity-clean-02.png)
   - Illustrates: `antigravity`, `antigravity-ide`, `bin`, `config`, `logs`, `google_accounts.json`, `oauth_creds.json`.

3. **`~/.gemini/antigravity/brain` 147 Conversation UUIDs:**
   ![Gemini Brain Conversations](assets/screenshots/30-antigravity-clean-03.png)
   - Illustrates 147 subdirectories containing conversation workspaces, task outputs, scratch files, and logs.

---

## Delivered Architecture & Artifacts

1. **Cross-Platform Optimizer Engine:**
   - Files: `scripts/69-install-antigravity/helpers/agy_optimizer.py`, `scripts-linux/69-install-antigravity/helpers/agy_optimizer.py`
   - Scans and indexes `conversation_summaries.db`, extracts project metadata and git repositories.
   - Identifies conversations exceeding the configured threshold (default 200 KB).
   - Prunes historical steps while preserving the latest 2 turns so conversations never disappear from the Antigravity UI.
   - Transactional undo/redo backed by `~/.scripts-fixer/antigravity-backup.db`.
   - Ephemeral brain directory backup to OS temp with user warnings.
   - Non-destructive `--predict` / `--json` mode by default with console-safe ASCII glyphs.

2. **Windows PowerShell Integration:**
   - Helper: `scripts/69-install-antigravity/helpers/clear-agy.ps1`
   - Entry point forwarders: root `clear-agy.ps1` and `clean-agy.ps1`
   - Dispatcher: `scripts/69-install-antigravity/run.ps1` supporting `clean`, `clear`, `predict`.

3. **Ubuntu Linux & macOS Parity:**
   - Helper: `scripts-linux/69-install-antigravity/helpers/clear-agy.sh`
   - Entry point forwarders: root `clear-agy.sh` and `clean-agy.sh`
   - Dispatcher: `scripts-linux/69-install-antigravity/run.sh` supporting `clean`, `clear`, `predict`.
   - Manifests updated in both platforms.

4. **Root Dispatcher Wiring:**
   - `run.ps1`: Added `$isBareAgyCommand` and `$isBareCleanAgyCommand` routing directly to `clear-agy.ps1`.
   - `scripts/os/run.ps1`: Added `clean-agy` routing.
   - `scripts-linux/run.sh`: Added `agy`, `antigravity`, and `clean-agy` top-level shortcuts.
   - `scripts/aliases.generated.json` & `scripts-linux/aliases.generated.json` regenerated and in sync.

---

## Verification Results

- `.\run.ps1 agy clean`: Verified exit 0, outputs prediction summary without killing processes.
- `.\run.ps1 agy clear`: Verified exit 0, outputs prediction summary.
- `.\run.ps1 clean-agy`: Verified exit 0.
- `.\run.ps1 os clean-agy`: Verified exit 0.
- `.\clear-agy.ps1`: Verified exit 0.
- `clear-agy.sh`: Verified exit 0 via Git Bash.
- `scripts-linux/run.sh agy clean`: Verified exit 0 via Git Bash.
- PowerShell AST parser: 0 errors across all modified `.ps1` files.
- Bash syntax check (`bash -n`): 0 errors across all `.sh` files.
