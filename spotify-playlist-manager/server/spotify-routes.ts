import { Router } from "express";
import { generateOAuthState, handleSpotifyCallback, verifyOAuthState } from "./spotify-auth";
import { ENV } from "./_core/env";

const router = Router();

/**
 * Redirect to Spotify authorization
 */
router.get("/authorize", (req, res) => {
  const state = generateOAuthState();
  const params = new URLSearchParams({
    client_id: ENV.spotifyClientId,
    response_type: "code",
    redirect_uri: ENV.spotifyRedirectUri,
    scope: "playlist-modify-public playlist-modify-private",
    state,
  });

  res.redirect(`https://accounts.spotify.com/authorize?${params.toString()}`);
});

/**
 * Handle Spotify OAuth callback
 */
router.get("/callback", async (req, res) => {
  const { code, state, error } = req.query;

  if (error) {
    return res.redirect(`/?error=${error}`);
  }

  if (!code || !state || typeof code !== "string" || typeof state !== "string") {
    return res.status(400).json({ error: "Missing code or state" });
  }

  // Verify state
  if (!verifyOAuthState(state)) {
    return res.status(400).json({ error: "Invalid state" });
  }

  // Get user from session
  const user = (req as any).user;
  if (!user) {
    return res.status(401).json({ error: "Not authenticated" });
  }

  // Handle callback
  const result = await handleSpotifyCallback(code, user.openId);

  if (!result.success) {
    return res.redirect(`/?error=${encodeURIComponent(result.error || "Unknown error")}`);
  }

  res.redirect("/");
});

export default router;
