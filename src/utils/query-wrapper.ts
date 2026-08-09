export enum StatusType {
  SUCCESS = "success",
  FAIL = "fail"
}

export interface QueryResult {
  isFail: boolean;
  status: StatusType;
  response?: Response;
  error?: unknown;
}

export const safeQuery = async (input: RequestInfo | URL, init?: RequestInit): Promise<QueryResult> => {
  try {
    const response = await fetch(input, init);
    // Explicit positive check for success
    if (response.ok) {
      return { isFail: false, status: StatusType.SUCCESS, response };
    } else {
      console.error("[Query Error] Query failed with status", response.status, "for URL", input);
      return { isFail: true, status: StatusType.FAIL, response };
    }
  } catch (error) {
    console.error("[Query Error] Network error for URL", input, error);
    return { isFail: true, status: StatusType.FAIL, error };
  }
};
