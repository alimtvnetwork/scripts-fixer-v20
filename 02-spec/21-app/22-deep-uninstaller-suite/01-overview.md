# 22-deep-uninstaller-suite — Antigravity, AGM, Copilot & Edge Uninstaller Suite

> **Spec Version:** 1.0.0  
> **Status:** active  
> **Domain:** System Maintenance, Uninstallation & Cache Optimization

---

## 1. Domain Architecture & System Context

This specification defines the unified uninstallation, cleanup, and state preservation architecture for:
1. **Google Antigravity (IDE & CLI)**: Standard uninstallation (`agy uninstall`) and deep total wipe (`agy uninstall-all` / `cli uninstall agy-all` / `uninstall agy-all`).
2. **State Preservation Engine**: Pre-uninstallation extraction that captures and serializes active project metadata and conversation names to an isolated JSON file before any file or registry removal occurs.
3. **Anti-Gravity Manager (AGM)**: Standard and deep removal of AGM binaries, updater caches, and registry markers.
4. **Windows Copilot Deep Uninstaller**: AppX package removal, provisioned package purge, and registry policy debloating.
5. **Microsoft Edge Uninstaller**: Chris Titus WinUtil methodology implementation (uninstall flag execution, update service disablement, and update blocking policies).
6. **Dev-Tool Cache Cleaner Enhancement**: Comprehensive extension to `dev-clean` for deep AI temp artifacts, dangling task logs, and build cache sweeping with strict preservation of workspace repositories (`d:\work\`).

---

## 2. User Request (Verbatim)

```text
are you confident? can you please check?

is it done properly?

Let me just create a command that would actually uninstall Antigravity from the machine, everything. But also at the same time, that would also save a JSON file that only contains the project information and conversation name, so that anytime we can re-enqueue this and have all the project ready after the removal. The removal will remove every brain, every cache, everything. It's just full fresh of the Antigravity from the machine. And you can test it out in your system fully. So there is no problem with it. But make sure you do the end-to-end test. After you complete the task, you make a release, you make a push, and you check the Gitmap DE. After that, you do the end-to-end testing to check if it can remove everything. To give you the safe side, it is taken using a snapshot, so you can remove anything. There is no worries. Nothing would be wasted. So you can do anything that you want, and you will be safe. I hope it makes sense, and you feel the confidence, and you can do what I'm saying. So the thing is that you should create a command like CLI space uninstall AGY hyphen all. There would be AGY uninstall that just uninstalls it without removing everything. There would be another with all. That means every trace, Gemini trace, Gemini brain, wherever there is the thing that it had, it will try to remove that. Also, I want you to check and enhance the dev tool clear option. So if this can be improved, it would be a great thing for me. Is it understood by you?


Let me just create a command that would actually uninstall Antigravity from the machine, everything. But also at the same time, that would also save a JSON file that only contains the project information and conversation name, so that anytime we can re-enqueue this and have all the project ready after the removal. The removal will remove every brain, every cache, everything. It's just full fresh of the Antigravity from the machine. And you can test it out in your system fully. So there is no problem with it. But make sure you do the end-to-end test. After you complete the task, you make a release, you make a push, and you check the Gitmap DE. After that, you do the end-to-end testing to check if it can remove everything. To give you the safe side, it is taken using a snapshot, so you can remove anything. There is no worries. Nothing would be wasted. So you can do anything that you want, and you will be safe. I hope it makes sense, and you feel the confidence, and you can do what I'm saying. So the thing is that you should create a command like CLI space uninstall AGY hyphen all. There would be AGY uninstall that just uninstalls it without removing everything. There would be another with all. That means every trace, Gemini trace, Gemini brain, wherever there is the thing that it had, it will try to remove that. Also, I want you to check and enhance the dev tool clear option. So if this can be improved, it would be a great thing for me. Is it understood by you? The similar one we can have for AGM as well, Anti-Gravity Manager tool. So everything removed from the system. Also similar to this, you can have uninstall for Copilot for Windows. Add the Copilot uninstall option. That will basically remove the Copilot from your machine and everything related to this. Similarly, you can add the uninstall for the Edge browser, and you can find this in the Chris's section. You don't have it in your machine. So Chris is a famous guy who actually wrote several tools. So basically, if you can access to Chris's stuff, then you know all that how to do it. But I guess you also know how to deal with this stuff, okay? So try to work on it, and make sure the uninstall is finally tested into end-to-end, and you confirm that you can run it and that removes everything. There is no trace of anything. That can be run from a PowerShell rather than running from the IDE, because it's going to close the IDE and then try to remove everything. Do you understand me? Can you please do that? So make sure you place extra caution before you remove that IDE, AGM, and test out both of these. So no worries, I can revert back using the snapshot. Do not try to remove anything inside the work directory, okay, per se. I hope it's clear, right? You can work on it
```

---

## 3. High-Level Technical Architecture

```mermaid
flowchart TD
    CLI["cli / run.ps1 Dispatcher"] --> ModeSwitch{"Subcommand / Target"}

    ModeSwitch -->|"uninstall agy"| StandardAGY["Standard Antigravity Uninstall<br/>Process Stop + Uninstaller.exe + CLI/Path Clean"]
    ModeSwitch -->|"uninstall agy-all<br/>(agy-all / --all)"| DeepAGYFlow["Deep Antigravity Total Wipe"]
    ModeSwitch -->|"uninstall agm / agm-all"| AGMFlow["Anti-Gravity Manager Removal"]
    ModeSwitch -->|"uninstall copilot"| CopilotFlow["Windows Copilot Deep Removal"]
    ModeSwitch -->|"uninstall edge"| EdgeFlow["Chris Titus WinUtil Edge Removal"]
    ModeSwitch -->|"clean-dev / dev-cleanup"| DevClean["Enhanced Dev-Tool Cleaner"]

    subgraph DeepAGYFlow ["Deep AGY Uninstallation Flow"]
        B1["1. Extract & Backup State<br/>(JSON with project info & conversation names)"] --> B2["2. Terminate Processes<br/>(antigravity*, agy*)"]
        B2 --> B3["3. Invoke Official Uninstaller"]
        B3 --> B4["4. Purge Directories<br/>.antigravity, AppData, LocalAppData, .gemini"]
        B4 --> B5["5. Scrub Registry, Shortcuts & PATH"]
        B5 --> B6["6. Safety Check: Verify d:\\work Intact"]
    end
```
