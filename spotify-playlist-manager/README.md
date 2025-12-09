# Spotify Playlist Manager

An elegant web application for managing Spotify playlist privacy settings with batch operations and a modern, responsive interface.

## 🎵 Features

- **OAuth 2.0 Authentication**: Secure authentication with Spotify using industry-standard OAuth 2.0 flow
- **Playlist Management**: View all your Spotify playlists with images, descriptions, and track counts
- **Batch Operations**: Select multiple playlists and change their privacy status (public/private) in one action
- **Direct Links**: Open any playlist directly in Spotify with a single click
- **Modern UI**: Built with HeroUI and Tailwind CSS for a beautiful, responsive design
- **Real-time Feedback**: Visual loading states and toast notifications for all operations
- **Type-Safe API**: Full-stack TypeScript with tRPC for end-to-end type safety

## 🛠️ Tech Stack

### Frontend
- **React 19** - Modern React with latest features
- **HeroUI** - Beautiful UI component library
- **Tailwind CSS** - Utility-first CSS framework
- **tRPC** - End-to-end typesafe APIs
- **Wouter** - Lightweight routing
- **React Query** - Data fetching and caching
- **Vite** - Fast build tool and dev server

### Backend
- **Express.js** - Web server framework
- **tRPC** - Type-safe API layer
- **Drizzle ORM** - TypeScript ORM for database operations
- **MySQL** - Relational database
- **Jose** - JWT token handling

### Development Tools
- **TypeScript** - Type safety
- **Vitest** - Testing framework
- **Prettier** - Code formatting
- **ESBuild** - Fast bundler

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher)
- **yarn** - Package manager
- **MySQL** - Database server
- **Spotify Developer Account** - For OAuth credentials

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd spotify-playlist-manager
```

### 2. Install Dependencies

```bash
yarn install
```

### 3. Set Up Environment Variables

Create a `.env` file in the root directory:

```env
# Database
DATABASE_URL=mysql://user:password@localhost:3306/spotify_playlist_manager

# JWT Secret (generate a secure random string)
JWT_SECRET=your-secret-key-here

# OAuth Server (Manus)
OAUTH_SERVER_URL=https://your-oauth-server.com
VITE_APP_ID=your-app-id

# Spotify OAuth
SPOTIFY_CLIENT_ID=your-spotify-client-id
SPOTIFY_CLIENT_SECRET=your-spotify-client-secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/oauth/spotify/callback

# Optional: Owner OpenID for admin features
OWNER_OPEN_ID=your-open-id

# Optional: Forge API (if using image generation features)
BUILT_IN_FORGE_API_URL=https://api.example.com
BUILT_IN_FORGE_API_KEY=your-api-key
```

### 4. Set Up Spotify OAuth

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account
3. Click "Create an App"
4. Fill in the app details and create the app
5. Copy your **Client ID** and **Client Secret**
6. Add a redirect URI:
   - For development: `http://localhost:3000/api/oauth/spotify/callback`
   - For production: `https://your-domain.com/api/oauth/spotify/callback`
7. Add the credentials to your `.env` file

For detailed instructions, see [SPOTIFY_SETUP.md](./SPOTIFY_SETUP.md).

### 5. Set Up Database

```bash
# Generate and run migrations
yarn db:push
```

### 5. Start Development Server

```bash
yarn dev
```

The application will be available at `http://localhost:3000` (or the next available port).

## 📁 Project Structure

```
spotify-playlist-manager/
├── client/                 # Frontend React application
│   ├── src/
│   │   ├── _core/         # Core hooks and utilities
│   │   ├── components/    # React components
│   │   │   └── ui/        # UI component library
│   │   ├── contexts/      # React contexts
│   │   ├── hooks/         # Custom React hooks
│   │   ├── lib/           # Utility libraries
│   │   └── pages/         # Page components
│   └── public/            # Static assets
├── server/                # Backend Express application
│   ├── _core/             # Core server utilities
│   │   ├── context.ts     # tRPC context
│   │   ├── oauth.ts       # OAuth handlers
│   │   ├── trpc.ts        # tRPC setup
│   │   └── ...
│   ├── routers/           # tRPC routers
│   │   └── spotify.ts     # Spotify API procedures
│   ├── spotify.ts         # Spotify API client
│   ├── spotify-auth.ts    # Spotify authentication
│   └── db.ts              # Database connection
├── shared/                 # Shared types and constants
├── drizzle/               # Database migrations and schema
│   ├── schema.ts          # Database schema
│   └── migrations/        # Migration files
└── package.json           # Dependencies and scripts
```

## 🎯 Usage

### 1. Sign In

- Click "Sign In with Manus" to authenticate with your account
- This is required to use the application

### 2. Connect Spotify

- After signing in, click "Connect with Spotify"
- Authorize the application to access your playlists
- You'll be redirected to Spotify to grant permissions

### 3. View Playlists

- Once connected, all your Spotify playlists will be displayed
- Each playlist card shows:
  - Playlist image
  - Name and description
  - Number of tracks
  - Privacy status (Public/Private)
  - Collaborative status

### 4. Manage Privacy

**Single Playlist:**
- Click the "Open in Spotify" button to open a playlist directly in Spotify

**Batch Operations:**
- Select playlists using the checkboxes
- Use "Select All" to select all playlists at once
- Click "Make Public" or "Make Private" to update all selected playlists
- Changes are applied immediately with visual feedback

## 🧪 Development

### Available Scripts

```bash
# Start development server
yarn dev

# Build for production
yarn build

# Start production server
yarn start

# Type checking
yarn check

# Format code
yarn format

# Run tests
yarn test

# Database migrations
yarn db:push
```

### Code Structure

- **Frontend**: React components in `client/src/`
- **Backend**: Express server with tRPC routers in `server/`
- **Database**: Drizzle ORM schema in `drizzle/schema.ts`
- **Shared**: Common types and constants in `shared/`

## 🔌 API Reference

### tRPC Procedures

#### `spotify.getPlaylists()`
Returns all playlists for the authenticated user.

**Response:**
```typescript
Array<{
  id: string;
  name: string;
  description: string | null;
  public: boolean;
  collaborative: boolean;
  externalUrl: string;
  imageUrl: string | null;
  tracksTotal: number;
  ownerName: string;
}>
```

#### `spotify.updatePlaylistStatus(input)`
Updates a single playlist's privacy status.

**Input:**
```typescript
{
  playlistId: string;
  isPublic: boolean;
}
```

#### `spotify.updatePlaylistsStatusBatch(input)`
Updates multiple playlists' privacy status in batch.

**Input:**
```typescript
{
  playlistIds: string[];
  isPublic: boolean;
}
```

**Response:**
```typescript
{
  success: boolean;
  successful: number;
  failed: number;
}
```

#### `spotify.hasSpotifyToken()`
Checks if the user has connected their Spotify account.

**Response:**
```typescript
{
  hasToken: boolean;
}
```

### OAuth Routes

- `GET /api/oauth/spotify/authorize` - Initiate Spotify OAuth flow
- `GET /api/oauth/spotify/callback` - Handle Spotify OAuth callback

## 🔒 Security

- **Token Storage**: Spotify tokens are securely stored in the database
- **Token Refresh**: Access tokens are automatically refreshed when expired
- **HTTPS**: All OAuth flows use HTTPS in production
- **Session Management**: User sessions are managed with secure cookies
- **CORS Protection**: API endpoints are protected with proper CORS headers

## 🐛 Troubleshooting

### "No Spotify token found"
- Make sure you've clicked "Connect with Spotify" after signing in
- The connection might have expired - try reconnecting

### "Failed to update playlists"
- Check that you have the necessary permissions in Spotify
- Verify your Spotify token is still valid
- Try signing out and signing back in

### "Invalid state" error
- This usually means the OAuth session expired
- Try the authorization process again

### Playlists not loading
- Check your internet connection
- Verify your Spotify account is active
- Try refreshing the page

### Port already in use
- The server will automatically find the next available port
- Check the console output for the actual port number

## 📝 License

MIT

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📚 Additional Documentation

- [Spotify Setup Guide](./SPOTIFY_SETUP.md) - Detailed Spotify OAuth setup instructions
- [TODO List](./todo.md) - Current development tasks and future enhancements

## 🔮 Future Enhancements

Potential features for future versions:

- Playlist filtering and search
- Bulk playlist creation/deletion
- Playlist analytics
- Collaborative playlist management
- Scheduled privacy changes
- Playlist templates
- Mock mode for testing

---

**Version**: 1.0.0  
**Last Updated**: December 2025
