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
