import { z } from "zod";
import { EditionType } from "@/pages/Settings";

const MIN_EDITIONS = 1;
const MAX_EDITIONS = 2;
const MAX_URL_LENGTH = 255;
const MAX_TOKEN_LENGTH = 256;
const PROTOCOL_HTTP = "http:";
const PROTOCOL_HTTPS = "https:";
const HOST_IP4 = "127.0.0.1";
const HOST_LOCAL = "localhost";
const HOST_IP6 = "::1";

// Schema for the options the Settings page can change in script-52 config.json.
// Mirrors the bridge's validation surface; keeps client + server in sync.
export const editionSchema = z.enum([EditionType.Stable, EditionType.Insiders]);

export const script52OptionsSchema = z.object({
  enabledEditions: z
    .array(editionSchema)
    .min(MIN_EDITIONS, { message: "Pick at least one edition" })
    .max(MAX_EDITIONS, { message: "At most two editions" }),
  requireAdmin: z.boolean(),
  nonInteractive: z.boolean(),
  requireSignature: z.boolean(),
});

export type Script52Options = z.infer<typeof script52OptionsSchema>;

export const bridgeUrlSchema = z
  .string()
  .trim()
  .url({ message: "Bridge URL must be a valid URL" })
  .max(MAX_URL_LENGTH)
  .refine(
    (u) => {
      try {
        const { hostname, protocol } = new URL(u);
        if (protocol !== PROTOCOL_HTTP && protocol !== PROTOCOL_HTTPS) return false;
        // Localhost only — never POST settings to a remote host
        return (
          hostname === HOST_IP4 ||
          hostname === HOST_LOCAL ||
          hostname === HOST_IP6
        );
      } catch {
        return false;
      }
    },
    { message: "Bridge URL must point to localhost (127.0.0.1)" },
  );

export const bridgeTokenSchema = z
  .string()
  .max(MAX_TOKEN_LENGTH, { message: "Token must be ≤ 256 chars" })
  // Disallow control chars and header-breaking newlines
  .regex(/^[\x20-\x7E]*$/, { message: "Token has invalid characters" });
