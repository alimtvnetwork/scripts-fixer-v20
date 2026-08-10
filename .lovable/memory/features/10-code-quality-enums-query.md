# Code Quality Enums and Query Wrapper

## Query Wrapper

- **Rule**: Create and use a wrapper for queries (in TypeScript, `src/utils/query-wrapper.ts`) that handles automatic failure logging. This reduces scattered logging code.
- **Explicit Booleans**: Always use explicit boolean state checks like `response.isFail`. Never invert success booleans (e.g. `!response.isSuccess`).
- **Signature**: The wrapper should return a `QueryResult` object containing `isFail: boolean`, `status: StatusType`, and potentially `error` or `response`.

## Enums

- **Rule**: In TypeScript, rather than using strings as sub-items or comparing string union types (pipes) like `"pass" | "fail" | "fallback"`, you must use Enums.
- **Suffix**: Every single Enum must end with the suffix `Type` (e.g., `StatusType`).

## Logging

- **Rule**: All caught errors must be explicitly logged following the guidelines in the error manage folder. The query wrapper handles this for network requests.

## Common Mistakes to Avoid (Lessons Learned)

- **UI Components (Shadcn)**: Do NOT leave string union types (e.g. `"horizontal" | "vertical"` or `"line" | "dot"`) in imported UI components like `carousel.tsx`, `chart.tsx`, or `sidebar.tsx`. They MUST be converted to Enums with the `Type` suffix (e.g. `CarouselOrientationType`).
- **Empty Catch Blocks**: Do NOT use `catch { // ignore }` to swallow errors, even for non-critical operations like `localStorage` or `JSON.parse`. Every single `catch` block MUST log the exact file path and failure reason using `console.error` (e.g., `console.error('[Error] path: localStorage(key) — reason:', err)`).
