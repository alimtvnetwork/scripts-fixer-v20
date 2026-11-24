# React Code Examples (Anti-Magic-String & Grounded Models)

> **Parent:** [Error Modal Reference](./readme.md)
> **Version:** 3.0.0
> **Updated:** 2026-11-15
> **Canonical Go Implementations:** [`04-code/golang/examples/database_query.go`](../../../../../04-code/golang/examples/database_query.go) and [`04-code/golang/examples/workflow_service.go`](../../../../../04-code/golang/examples/workflow_service.go)
> **Bug Recording Reference:** [`02-spec/03-error-manage/04-bug-recording/01-bug-record-schema-spec.md`](../../../../03-error-manage/04-bug-recording/01-bug-record-schema-spec.md)

---

## Example: Capturing an API Error with Full Context (Zero Magic Strings)

```typescript
import { useErrorStore } from '@/stores/errorStore';
import { api } from '@/lib/api';
import { ApiEndpointType, HttpMethodType, SessionKindType, UIComponentType, UIActionType } from '@/constants/enums';

async function enablePlugin(slug: string, siteId: number) {
  try {
    const response = await api.post(ApiEndpointType.PluginEnable, {
      slug,
      siteId,
    });

    // Positive boolean convention: isFailed / hasError (never !response.success)
    if (response.isFailed) {
      useErrorStore.getState().captureError(response.error, {
        endpoint: ApiEndpointType.PluginEnable,
        method: HttpMethodType.Post,
        requestBody: { slug, siteId },
        responseStatus: response.error.statusCode,
        siteUrl: response.siteUrl,
        sessionId: response.error.sessionId,
        sessionType: SessionKindType.PluginLifecycle,
        context: {
          source: 'PluginActions.enablePlugin',
          triggerComponent: UIComponentType.PluginCard,
          triggerAction: UIActionType.EnableClicked,
        },
      });
    }
  } catch (error) {
    useErrorStore.getState().captureException(error, {
      source: 'PluginActions.enablePlugin',
      triggerComponent: UIComponentType.PluginCard,
      triggerAction: UIActionType.EnableClicked,
      endpoint: ApiEndpointType.PluginEnable,
      method: HttpMethodType.Post,
      requestBody: { slug, siteId },
    });
  }
}
```

---

## Example: Opening the Error Modal Manually

```typescript
import { useErrorStore } from '@/stores/errorStore';
import { UIComponentType, UIActionType } from '@/constants/enums';

function MyComponent() {
  const { openErrorModal, captureException } = useErrorStore();

  const handleDangerousAction = async () => {
    try {
      await riskyOperation();
    } catch (error) {
      const captured = captureException(error, {
        source: 'MyComponent.handleDangerousAction',
        triggerComponent: UIComponentType.MyComponent,
        triggerAction: UIActionType.DangerousActionClicked,
      });
      // Automatically opens the modal:
      openErrorModal(captured);
    }
  };

  return <Button onClick={handleDangerousAction}>Do Something</Button>;
}
```

---

## Example: Using the Error Boundary

```tsx
import { AppErrorBoundary } from '@/components/errors/AppErrorBoundary';

function App() {
  return (
    <AppErrorBoundary>
      <Router>
        <Routes>
          {/* All routes are wrapped — any unhandled error opens the modal */}
        </Routes>
      </Router>
    </AppErrorBoundary>
  );
}
```

---

## Example: Consuming Envelope Errors in a Hook

```typescript
import { useApiQuery } from '@/hooks/useApiQuery';

function usePlugins() {
  return useApiQuery<Plugin[]>('/plugins', ['plugins']);
  // If the query fails:
  // 1. useApiQuery calls requireSuccess()
  // 2. requireSuccess() detects envelope failure
  // 3. Error is auto-captured into errorStore with full envelope data
  // 4. Modal opens with Backend → Overview → "Backend Error" red banner
}
```

---

## Example: Rendering PHP Stack Frames

```tsx
// Extracting PHP frames from error context:
const phpStackFrames: PHPStackFrame[] = (() => {
  const ctx = selectedError?.context as Record<string, unknown> | undefined;
  if (!ctx) return [];
  if (Array.isArray(ctx.stackTraceFrames)) return ctx.stackTraceFrames;
  const errorDetails = ctx.errorDetails as Record<string, unknown> | undefined;
  if (errorDetails && Array.isArray(errorDetails.stackTraceFrames))
    return errorDetails.stackTraceFrames;
  return [];
})();

// Rendering:
{phpStackFrames.map((frame, i) => (
  <tr key={i}>
    <td className="p-2 font-mono text-muted-foreground">{i}</td>
    <td className="p-2 font-mono text-orange-500">
      {frame.class ? `${frame.class}::${frame.function}()` : `${frame.function}()`}
    </td>
    <td className="p-2 font-mono text-muted-foreground">{frame.fileBase || frame.file}</td>
    <td className="p-2 font-mono text-right">{frame.line || '?'}</td>
  </tr>
))}
```

---

*Code examples — updated: 2026-03-31*
