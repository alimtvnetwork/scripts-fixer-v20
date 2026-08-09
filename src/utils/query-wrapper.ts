export const safeQuery = async (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
  try {
    const response = await fetch(input, init);
    // Explicit positive check for success
    if (response.ok) {
      // no-op
    } else {
      console.error("[Query Error] Query failed with status", response.status, "for URL", input);
    }
    return response;
  } catch (error) {
    console.error("[Query Error] Network error for URL", input, error);
    throw error;
  }
};
