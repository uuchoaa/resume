import { nanoid } from "nanoid";
import {
  exchangeCodeForToken,
  getUserProfile,
  refreshAccessToken,
  SpotifyTokenResponse,
} from "./spotify";
import { getDb, getSpotifyTokenByUserId, upsertSpotifyToken } from "./db";
import { getUserByOpenId, upsertUser } from "./db";

const OAUTH_STATE_STORE = new Map<string, { expiresAt: number }>();

/**
 * Clean up expired OAuth states
 */
function cleanupExpiredStates() {
  const now = Date.now();
  const keysToDelete: string[] = [];
  OAUTH_STATE_STORE.forEach((value, key) => {
    if (value.expiresAt < now) {
      keysToDelete.push(key);
    }
  });
  keysToDelete.forEach((key) => OAUTH_STATE_STORE.delete(key));
}

/**
 * Generate a random state for OAuth
 */
export function generateOAuthState(): string {
  cleanupExpiredStates();
  const state = nanoid();
  OAUTH_STATE_STORE.set(state, {
    expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
  });
  return state;
}

/**
 * Verify OAuth state
 */
export function verifyOAuthState(state: string): boolean {
  const stored = OAUTH_STATE_STORE.get(state);
  if (!stored) {
    return false;
  }

  if (stored.expiresAt < Date.now()) {
    OAUTH_STATE_STORE.delete(state);
    return false;
  }

  OAUTH_STATE_STORE.delete(state);
  return true;
}

/**
 * Handle Spotify OAuth callback
 */
export async function handleSpotifyCallback(
  code: string,
  openId: string
): Promise<{ success: boolean; error?: string }> {
  try {
    // Exchange code for token
    const tokenResponse = await exchangeCodeForToken(code);

    // Get user profile
    const userProfile = await getUserProfile(tokenResponse.access_token);

    // Get or create user
    let user = await getUserByOpenId(openId);
    if (!user) {
      await upsertUser({
        openId,
        name: userProfile.display_name,
        email: userProfile.email,
        loginMethod: "manus",
      });
      user = await getUserByOpenId(openId);
    }

    if (!user) {
      return {
        success: false,
        error: "Failed to create or retrieve user",
      };
    }

    // Store Spotify token
    const expiresAt = new Date(Date.now() + tokenResponse.expires_in * 1000);
    await upsertSpotifyToken(user.id, {
      accessToken: tokenResponse.access_token,
      refreshToken: tokenResponse.refresh_token || null,
      expiresAt,
      spotifyUserId: userProfile.id,
    });

    return { success: true };
  } catch (error) {
    console.error("[Spotify Auth] Callback error:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  }
}

/**
 * Get valid access token for user, refreshing if necessary
 */
export async function getValidAccessToken(userId: number): Promise<string> {
  const token = await getSpotifyTokenByUserId(userId);

  if (!token) {
    throw new Error("No Spotify token found for user");
  }

  // Check if token is expired or about to expire (within 5 minutes)
  const now = new Date();
  const expiresAt = new Date(token.expiresAt);
  const timeUntilExpiry = expiresAt.getTime() - now.getTime();

  if (timeUntilExpiry < 5 * 60 * 1000) {
    // Token is expired or about to expire, refresh it
    if (!token.refreshToken) {
      throw new Error("No refresh token available");
    }

    try {
      const newTokenResponse = await refreshAccessToken(token.refreshToken);
      const newExpiresAt = new Date(
        Date.now() + newTokenResponse.expires_in * 1000
      );

      await upsertSpotifyToken(userId, {
        accessToken: newTokenResponse.access_token,
        refreshToken:
          newTokenResponse.refresh_token || token.refreshToken,
        expiresAt: newExpiresAt,
        spotifyUserId: token.spotifyUserId,
      });

      return newTokenResponse.access_token;
    } catch (error) {
      console.error("[Spotify Auth] Token refresh error:", error);
      throw new Error("Failed to refresh Spotify token");
    }
  }

  return token.accessToken;
}
