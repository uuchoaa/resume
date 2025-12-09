/**
 * Mock data for testing without real Spotify API calls
 */

export interface MockPlaylist {
  id: string;
  name: string;
  description: string | null;
  public: boolean;
  collaborative: boolean;
  externalUrl: string;
  imageUrl: string | null;
  tracksTotal: number;
  ownerName: string;
}

export const MOCK_PLAYLISTS: MockPlaylist[] = [
  {
    id: "mock-1",
    name: "Workout Hits 2024",
    description: "High energy tracks to keep you motivated during your workout",
    public: true,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-1",
    imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop",
    tracksTotal: 47,
    ownerName: "Spotify",
  },
  {
    id: "mock-2",
    name: "Chill Vibes",
    description: "Relaxing ambient and lo-fi beats for studying or unwinding",
    public: false,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-2",
    imageUrl: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300&h=300&fit=crop",
    tracksTotal: 63,
    ownerName: "You",
  },
  {
    id: "mock-3",
    name: "Summer Road Trip",
    description: null,
    public: true,
    collaborative: true,
    externalUrl: "https://open.spotify.com/playlist/mock-3",
    imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
    tracksTotal: 82,
    ownerName: "You",
  },
  {
    id: "mock-4",
    name: "Indie Discoveries",
    description: "Fresh indie rock and alternative tracks from emerging artists",
    public: true,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-4",
    imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop",
    tracksTotal: 34,
    ownerName: "You",
  },
  {
    id: "mock-5",
    name: "Jazz Classics",
    description: "Timeless jazz standards and modern interpretations",
    public: false,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-5",
    imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=300&h=300&fit=crop",
    tracksTotal: 28,
    ownerName: "You",
  },
  {
    id: "mock-6",
    name: "Party Bangers",
    description: "Dance floor favorites and club hits",
    public: true,
    collaborative: true,
    externalUrl: "https://open.spotify.com/playlist/mock-6",
    imageUrl: "https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=300&h=300&fit=crop",
    tracksTotal: 56,
    ownerName: "You",
  },
  {
    id: "mock-7",
    name: "Acoustic Sessions",
    description: "Stripped down acoustic performances and singer-songwriter tracks",
    public: false,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-7",
    imageUrl: "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=300&h=300&fit=crop",
    tracksTotal: 41,
    ownerName: "You",
  },
  {
    id: "mock-8",
    name: "Hip-Hop Essentials",
    description: "Classic and contemporary hip-hop tracks",
    public: true,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-8",
    imageUrl: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300&h=300&fit=crop",
    tracksTotal: 72,
    ownerName: "You",
  },
  {
    id: "mock-9",
    name: "Electronic Dreams",
    description: "Synth-pop, house, and electronic music",
    public: false,
    collaborative: true,
    externalUrl: "https://open.spotify.com/playlist/mock-9",
    imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300&h=300&fit=crop",
    tracksTotal: 51,
    ownerName: "You",
  },
  {
    id: "mock-10",
    name: "Podcast Recommendations",
    description: "Interesting podcasts and audio content",
    public: true,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-10",
    imageUrl: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300&h=300&fit=crop",
    tracksTotal: 19,
    ownerName: "You",
  },
  {
    id: "mock-11",
    name: "Throwback Hits",
    description: "The best songs from the 80s, 90s, and 2000s",
    public: true,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-11",
    imageUrl: "https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=300&h=300&fit=crop",
    tracksTotal: 95,
    ownerName: "You",
  },
  {
    id: "mock-12",
    name: "Focus & Productivity",
    description: "Music to help you concentrate and stay productive",
    public: false,
    collaborative: false,
    externalUrl: "https://open.spotify.com/playlist/mock-12",
    imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&h=300&fit=crop",
    tracksTotal: 38,
    ownerName: "You",
  },
];

export function getMockPlaylists(): MockPlaylist[] {
  return MOCK_PLAYLISTS;
}

export function getMockPlaylistById(id: string): MockPlaylist | undefined {
  return MOCK_PLAYLISTS.find((p) => p.id === id);
}

export function updateMockPlaylistStatus(
  id: string,
  isPublic: boolean
): MockPlaylist | undefined {
  const playlist = MOCK_PLAYLISTS.find((p) => p.id === id);
  if (playlist) {
    playlist.public = isPublic;
  }
  return playlist;
}
