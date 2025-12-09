import { COOKIE_NAME, ONE_YEAR_MS } from "@shared/const";
import type { Express, Request, Response } from "express";
import * as db from "../db";
import { getSessionCookieOptions } from "./cookies";
import { sdk } from "./sdk";
import { generateOAuthState, handleSpotifyCallback, verifyOAuthState } from "../spotify-auth";

function getQueryParam(req: Request, key: string): string | undefined {
  const value = req.query[key];
  return typeof value === "string" ? value : undefined;
}

export function registerOAuthRoutes(app: Express) {
  app.get("/api/oauth/callback", async (req: Request, res: Response) => {
    const code = getQueryParam(req, "code");
    const state = getQueryParam(req, "state");

    if (!code || !state) {
      res.status(400).json({ error: "code and state are required" });
      return;
    }

    try {
      const tokenResponse = await sdk.exchangeCodeForToken(code, state);
      const userInfo = await sdk.getUserInfo(tokenResponse.accessToken);

      if (!userInfo.openId) {
        res.status(400).json({ error: "openId missing from user info" });
        return;
      }

      await db.upsertUser({
        openId: userInfo.openId,
        name: userInfo.name || null,
        email: userInfo.email ?? null,
        loginMethod: userInfo.loginMethod ?? userInfo.platform ?? null,
        lastSignedIn: new Date(),
      });

      const sessionToken = await sdk.createSessionToken(userInfo.openId, {
        name: userInfo.name || "",
        expiresInMs: ONE_YEAR_MS,
      });

      const cookieOptions = getSessionCookieOptions(req);
      res.cookie(COOKIE_NAME, sessionToken, { ...cookieOptions, maxAge: ONE_YEAR_MS });

      res.redirect(302, "/");
    } catch (error) {
      console.error("[OAuth] Callback failed", error);
      res.status(500).json({ error: "OAuth callback failed" });
    }
  });

  app.get("/api/oauth/spotify/authorize", (req: Request, res: Response) => {
    const state = generateOAuthState();
    const params = new URLSearchParams({
      client_id: process.env.SPOTIFY_CLIENT_ID || "",
      response_type: "code",
      redirect_uri: process.env.SPOTIFY_REDIRECT_URI || "",
      scope: "playlist-modify-public playlist-modify-private",
      state,
    });

    res.redirect(`https://accounts.spotify.com/authorize?${params.toString()}`);
  });

  app.get("/api/oauth/spotify/callback", async (req: Request, res: Response) => {
    const code = getQueryParam(req, "code");
    const state = getQueryParam(req, "state");
    const error = getQueryParam(req, "error");

    if (error) {
      return res.redirect(`/?error=${error}`);
    }

    if (!code || !state) {
      return res.status(400).json({ error: "Missing code or state" });
    }

    if (!verifyOAuthState(state)) {
      return res.status(400).json({ error: "Invalid state" });
    }

    const user = (req as any).user;
    if (!user) {
      return res.status(401).json({ error: "Not authenticated" });
    }

    const result = await handleSpotifyCallback(code, user.openId);

    if (!result.success) {
      return res.redirect(`/?error=${encodeURIComponent(result.error || "Unknown error")}`);
    }

    res.redirect("/");
  });
}
