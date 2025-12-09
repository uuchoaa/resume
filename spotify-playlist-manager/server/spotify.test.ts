import { describe, expect, it } from "vitest";

/**
 * Test to validate Spotify OAuth credentials
 * This test checks if the provided credentials are valid by attempting to get an access token
 */
describe("Spotify OAuth Credentials", () => {
  it("should have valid Spotify OAuth environment variables", async () => {
    const clientId = process.env.SPOTIFY_CLIENT_ID;
    const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;
    const redirectUri = process.env.SPOTIFY_REDIRECT_URI;

    // Check if all required environment variables are set
    expect(clientId).toBeDefined();
    expect(clientSecret).toBeDefined();
    expect(redirectUri).toBeDefined();

    // Validate format
    expect(typeof clientId).toBe("string");
    expect(typeof clientSecret).toBe("string");
    expect(typeof redirectUri).toBe("string");

    // Basic validation
    expect(clientId?.length).toBeGreaterThan(0);
    expect(clientSecret?.length).toBeGreaterThan(0);
    expect(redirectUri?.length).toBeGreaterThan(0);
    expect(redirectUri).toMatch(/^https?:\/\//);
  });

  it("should be able to request Spotify access token with client credentials", async () => {
    const clientId = process.env.SPOTIFY_CLIENT_ID;
    const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;

    if (!clientId || !clientSecret) {
      throw new Error("Missing Spotify credentials");
    }

    const auth = Buffer.from(`${clientId}:${clientSecret}`).toString("base64");

    const response = await fetch("https://accounts.spotify.com/api/token", {
      method: "POST",
      headers: {
        Authorization: `Basic ${auth}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    });

    expect(response.ok).toBe(true);
    const data = (await response.json()) as { access_token?: string };
    expect(data.access_token).toBeDefined();
  });
});
