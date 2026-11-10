# Go Worker Chunking & Sequential Parallel Processing (SPP) — Golang Standards (AI Execution Prompt)

> **/goal** Master and enforce Go-specific chunked batching, bounded goroutine concurrency, isolated buffer tree rendering, and zero-sleep synchronization across all repository and fleet commands.
> **/learn** Internalize chunk slicing with Go 1.21+ `min()`, `sync.WaitGroup` synchronization barriers, thread-safe `RepoExecutionLog` buffering, elimination of stdout interleaving, and total ban on `time.Sleep` polling loops.

## 🎯 Actionable CI/CD & Agent Checklist

- [ ] `/goal` Partition multi-repository tasks into chunks using Go 1.21+ builtin `targets[i:min(i+batchSize, n)]`.
- [ ] `/learn` Never use `time.Sleep` loops to poll goroutine status; enforce synchronization using `sync.WaitGroup` or channels.
- [ ] `/goal` Isolate all worker logging into an in-memory `RepoExecutionLog` buffer; ban direct `fmt.Print*` inside goroutines.
- [ ] `/learn` Keep all worker functions under 15 lines, eliminate nested conditionals, and enforce positive booleans (`isSuccess`, `hasErrors`).

. **CRITICAL AI INSTRUCTION:** This specification is an active AI execution directive. All code generated or modified must strictly follow the rules below.

> **Version:** 1.0.0
> **Updated:** 2026-11-09
> **Applies to:** All Go multi-repository and fleet commands
> **Cross-refs:** [cross-lang spp](../01-cross-language/41-sequential-parallel-processing.md), [defer rules](./05-defer-rules.md), [boolean standards](./02-boolean-standards.md)

---

## 1. Chunk Slicing Idiom: `targets[i:min(i+batchSize, n)]`

When batching slice operations in Go 1.21+, developers MUST use the standard library `min()` function to calculate the upper bound of the chunk slice.

### ✅ Canonical Chunking Loop

```go
func RunBatches(targets []string, batchSize int) {
	total := len(targets)

	for i := 0; i < total; i += batchSize {
		end := min(i+batchSize, total)
		chunk := targets[i:end]

		processChunk(chunk)
	}
}
```

### ❌ Anti-Pattern: Manual Math or Out-of-Bounds Checks
```go
// ❌ WRONG: Verbose boundary logic and nested conditionals
for i := 0; i < len(targets); i += batchSize {
	end := i + batchSize
	if end > len(targets) { // ❌ Unnecessary conditional
		end = len(targets)
	}
	chunk := targets[i:end]
	processChunk(chunk)
}
```

---

## 2. Synchronization Barrier & Zero-Sleep Polling

### ❌ TOTAL BAN on `time.Sleep` Polling Loops
Polling goroutines using `time.Sleep` loops is strictly forbidden in GitMap:
```go
// ❌ FORBIDDEN: Burning CPU / wall-clock time with sleep loops
for !isDone {
	time.Sleep(50 * time.Millisecond) // ❌ BANNED
}
```

### ✅ Canonical Synchronization: `sync.WaitGroup` Barrier
Goroutines within a chunk must be synchronized using `sync.WaitGroup`. Execution blocks cleanly on `wg.Wait()` with zero sleep polling and zero CPU spin.

```go
func processChunk(chunk []string) []*RepoExecutionLog {
	logs := make([]*RepoExecutionLog, len(chunk))
	var wg sync.WaitGroup

	for i, target := range chunk {
		wg.Add(1)

		go func(idx int, repo string) {
			defer wg.Done()

			logs[idx] = executeRepoWorker(repo)
		}(i, target)
	}

	wg.Wait()

	return logs
}
```

---

## 3. Buffered Tree-View Rendering (`RepoExecutionLog`)

To eliminate stdout interleaving and visual line corruption, concurrent workers MUST log to an in-memory log buffer.

### 3.1 Thread-Safe Execution Log Buffer

```go
package spp

import "sync"

type StepEntry struct {
	StepName  string
	Detail    string
	IsSuccess bool
}

type RepoExecutionLog struct {
	mu        sync.Mutex
	RepoName  string
	Steps     []StepEntry
	IsSuccess bool
	HasErrors bool
}

func (r *RepoExecutionLog) AppendStep(name string, detail string, isSuccess bool) {
	r.mu.Lock()
	defer r.mu.Unlock()

	r.Steps = append(r.Steps, StepEntry{
		StepName:  name,
		Detail:    detail,
		IsSuccess: isSuccess,
	})
}
```

### 3.2 Sequential Stdout Tree Renderer

Once `wg.Wait()` releases the barrier, the parent orchestrator renders each repository log cleanly in sequence:

```go
func RenderChunkLogs(logs []*RepoExecutionLog) {
	for _, repoLog := range logs {
		renderRepoTree(repoLog)
	}
}

func renderRepoTree(log *RepoExecutionLog) {
	fmt.Printf("├── %s\n", log.RepoName)

	for i, step := range log.Steps {
		marker := "├──"
		if i == len(log.Steps)-1 {
			marker = "└──"
		}

		fmt.Printf("│   %s %s: %s\n", marker, step.StepName, step.Detail)
	}
}
```

---

## 4. Coding Standards Compliance Checklist

1. **Function Length**: All SPP functions MUST remain under 15 lines (prefer <= 8 lines). Decompose chunk setup, goroutine spawning, and tree rendering into discrete helpers.
2. **Boolean Naming**: All booleans MUST use `is` or `has` prefixes (`isSuccess`, `hasErrors`, `isCompleted`).
3. **No Nested Ifs**: Guard clauses and early returns only.
4. **Error Sovereignty**: Leaf worker functions return `*appfault.AppError` and store error status inside `RepoExecutionLog`; workers MUST NEVER call `os.Exit` or CLI exit handlers.
5. **Whitespace Discipline**: Exactly one blank line after `}` and one blank line before `return`.

---

## 5. Verification & Acceptance Criteria

### AC-CG-GO-010: Go SPP Worker Chunking Standard
**Given** A multi-repository batch command implemented in Go.
**When** Executed across $N$ targets.
**Then** Targets are processed in chunks bounded by `min()`, synchronized via `sync.WaitGroup` with zero sleep polling, and output rendered via buffered tree logs.
