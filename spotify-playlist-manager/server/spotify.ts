import { ENV } from "./_core/env";

export interface SpotifyTokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  refresh_token?: string;
  scope: string;
}

export interface SpotifyUserProfile {
  id: string;
  display_name: string;
  external_urls: {
    spotify: string;
  };
  followers: {
    href: string | null;
    total: number;
  };
  href: string;
  images: Array<{
    height: number | null;
    url: string;
    width: number | null;
  }>;
  type: string;
  uri: string;
  email: string;
}

export interface SpotifyPlaylist {
  id: string;
  name: string;
  description: string | null;
  public: boolean;
  collaborative: boolean;
  external_urls: {
    spotify: string;
  };
  href: string;
  images: Array<{
    height: number | null;
    url: string;
    width: number | null;
  }>;
  owner: {
    display_name: string;
    external_urls: {
      spotify: string;
    };
    href: string;
    id: string;
    type: string;
    uri: string;
  };
  tracks: {
    href: string;
    total: number;
  };
  type: string;
  uri: string;
}

export interface SpotifyPlaylistsResponse {
  href: string;
  items: SpotifyPlaylist[];
  limit: number;
  next: string | null;
  offset: number;
  previous: string | null;
  total: number;
}

/**
 * Get the authorization URL for Spotify OAuth
 */
export function getSpotifyAuthorizationUrl(state: string): string {
  const params = new URLSearchParams({
    client_id: ENV.spotifyClientId,
    response_type: "code",
    redirect_uri: ENV.spotifyRedirectUri,
    scope: "playlist-modify-public playlist-modify-private",
    state,
  });

  return `https://accounts.spotify.com/authorize?${params.toString()}`;
}

/**
 * Exchange authorization code for access token
 */
export async function exchangeCodeForToken(
  code: string
): Promise<SpotifyTokenResponse> {
  const auth = Buffer.from(
    `${ENV.spotifyClientId}:${ENV.spotifyClientSecret}`
  ).toString("base64");

  const response = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code,
      redirect_uri: ENV.spotifyRedirectUri,
    }).toString(),
  });

  if (!response.ok) {
    throw new Error(`Failed to exchange code for token: ${response.statusText}`);
  }

  return (await response.json()) as SpotifyTokenResponse;
}

/**
 * Refresh access token using refresh token
 */
export async function refreshAccessToken(
  refreshToken: string
): Promise<SpotifyTokenResponse> {
  const auth = Buffer.from(
    `${ENV.spotifyClientId}:${ENV.spotifyClientSecret}`
  ).toString("base64");

  const response = await fetch("https://accounts.spotify.com/api/token", {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "refresh_token",
      refresh_token: refreshToken,
    }).toString(),
  });

  if (!response.ok) {
    throw new Error(`Failed to refresh token: ${response.statusText}`);
  }

  return (await response.json()) as SpotifyTokenResponse;
}

/**
 * Get user profile from Spotify
 */
export async function getUserProfile(
  accessToken: string
): Promise<SpotifyUserProfile> {
  const response = await fetch("https://api.spotify.com/v1/me", {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to get user profile: ${response.statusText}`);
  }

  return (await response.json()) as SpotifyUserProfile;
}

/**
 * Get all playlists for the current user
 */
export async function getUserPlaylists(
  accessToken: string,
  limit = 50,
  offset = 0
): Promise<SpotifyPlaylistsResponse> {
  const params = new URLSearchParams({
    limit: limit.toString(),
    offset: offset.toString(),
  });

  const response = await fetch(
    `https://api.spotify.com/v1/me/playlists?${params.toString()}`,
    {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    }
  );

  if (!response.ok) {
    throw new Error(`Failed to get playlists: ${response.statusText}`);
  }

  return (await response.json()) as SpotifyPlaylistsResponse;
}

/**
 * Update playlist details (public/private status)
 */
export async function updatePlaylistDetails(
  accessToken: string,
  playlistId: string,
  isPublic: boolean
): Promise<void> {
  const response = await fetch(
    `https://api.spotify.com/v1/playlists/${playlistId}`,
    {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        public: isPublic,
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`Failed to update playlist: ${response.statusText}`);
  }
}

/**
 * Get all playlists for the current user (paginated)
 */
export async function getAllUserPlaylists(
  accessToken: string
): Promise<SpotifyPlaylist[]> {
  const allPlaylists: SpotifyPlaylist[] = [];
  let offset = 0;
  const limit = 50;

  while (true) {
    const response = await getUserPlaylists(accessToken, limit, offset);
    allPlaylists.push(...response.items);

    if (!response.next) {
      break;
    }

    offset += limit;
  }

  return allPlaylists;
}
