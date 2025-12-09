# Spotify Playlist Manager - Setup Guide

## Overview

**Spotify Playlist Manager** is an elegant web application that allows you to manage the privacy settings of your Spotify playlists efficiently. With batch operations and a beautiful interface, you can quickly make multiple playlists public or private.

## Features

- **OAuth 2.0 Authentication**: Secure authentication with Spotify using industry-standard OAuth 2.0 flow
- **Playlist Listing**: View all your Spotify playlists with images, descriptions, and track counts
- **Batch Operations**: Select multiple playlists and change their privacy status in one action
- **Direct Links**: Open any playlist directly in Spotify with a single click
- **Elegant UI**: Built with HeroUI and Tailwind CSS for a modern, responsive design
- **Real-time Feedback**: Visual loading states and toast notifications for all operations

## Prerequisites

Before you can use this application, you need to:

1. Have a Spotify account (free or premium)
2. Create a Spotify Developer Application
3. Obtain OAuth credentials from Spotify

## Setting Up Spotify OAuth

### Step 1: Create a Spotify Developer Account

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account (create one if you don't have it)
3. Accept the terms and create your developer account

### Step 2: Create an Application

1. In the Dashboard, click "Create an App"
2. Give your app a name (e.g., "Spotify Playlist Manager")
3. Accept the terms and create the app
4. You'll now see your app's credentials

### Step 3: Get Your Credentials

In your app's settings, you'll find:

- **Client ID**: A unique identifier for your application
- **Client Secret**: A secret key (keep this confidential!)

### Step 4: Set Redirect URI

1. In your app settings, find the "Redirect URIs" section
2. Add your callback URL. For local development, use:
   ```
   http://localhost:3000/api/oauth/spotify/callback
   ```
3. For production, use your actual domain:
   ```
   https://your-domain.com/api/oauth/spotify/callback
   ```

### Step 5: Configure Environment Variables

Set the following environment variables in your application:

```
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/oauth/spotify/callback
```

## How to Use

### 1. Sign In

- Click "Sign In with Manus" to authenticate with your Manus account
- This is required to use the application

### 2. Connect Spotify

- After signing in, you'll be prompted to "Connect with Spotify"
- Click the button to authorize the application to access your playlists
- You'll be redirected to Spotify to grant permissions
- Grant the necessary permissions (playlist management)

### 3. View Your Playlists

- Once connected, you'll see all your Spotify playlists displayed in a grid
- Each playlist card shows:
  - Playlist image (or a placeholder)
  - Playlist name
  - Number of tracks
  - Description (if available)
  - Privacy status (Public/Private badge)
  - Collaborative status (if applicable)

### 4. Manage Privacy

#### Single Playlist
- Click the "Open in Spotify" button (external link icon) to open a playlist directly in Spotify

#### Batch Operations
- **Select Playlists**: Click the checkbox on any playlist card to select it
- **Select All**: Use the checkbox in the batch actions bar to select all playlists
- **Make Public**: Click "Make Public" to change all selected playlists to public
- **Make Private**: Click "Make Private" to change all selected playlists to private
- **Deselect**: Click the checkbox again to deselect, or use the batch actions bar

### 5. Sign Out

- Click the logout icon (top-right corner) to sign out of the application

## Technical Details

### Architecture

The application uses a modern full-stack architecture:

- **Frontend**: React 19 with HeroUI components and Tailwind CSS
- **Backend**: Express.js with tRPC for type-safe API calls
- **Database**: MySQL with Drizzle ORM
- **Authentication**: Manus OAuth for user authentication + Spotify OAuth for playlist access

### API Endpoints

#### OAuth Routes
- `GET /api/oauth/spotify/authorize` - Initiate Spotify OAuth flow
- `GET /api/oauth/spotify/callback` - Handle Spotify OAuth callback

#### tRPC Procedures
- `spotify.getPlaylists()` - Fetch all user playlists
- `spotify.updatePlaylistStatus()` - Update a single playlist's privacy
- `spotify.updatePlaylistsStatusBatch()` - Update multiple playlists' privacy
- `spotify.hasSpotifyToken()` - Check if user has connected Spotify

### Security

- **Token Storage**: Spotify tokens are securely stored in the database with encryption
- **Token Refresh**: Access tokens are automatically refreshed when they expire
- **HTTPS Only**: All OAuth flows use HTTPS
- **CORS Protection**: API endpoints are protected with proper CORS headers
- **Session Management**: User sessions are managed with secure cookies

## Troubleshooting

### "No Spotify token found"
- Make sure you've clicked "Connect with Spotify" after signing in
- The connection might have expired - try reconnecting

### "Failed to update playlists"
- Check that you have the necessary permissions in Spotify
- Make sure your Spotify token is still valid
- Try signing out and signing back in

### "Invalid state" error
- This usually means the OAuth session expired
- Try the authorization process again

### Playlists not loading
- Check your internet connection
- Verify your Spotify account is active
- Try refreshing the page

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review the application logs for error messages
3. Ensure your Spotify credentials are correct
4. Verify your redirect URI matches exactly in both the app and Spotify settings

## Privacy & Permissions

This application requests the following Spotify permissions:

- **playlist-modify-public**: To change the public/private status of your playlists
- **playlist-modify-private**: To manage your private playlists

These permissions are only used to update playlist privacy settings as requested.

## Limitations

- The application does not modify playlist content (tracks)
- The application does not create or delete playlists
- Changes are applied directly to your Spotify account
- Batch operations may take a few seconds depending on the number of playlists

## Future Enhancements

Potential features for future versions:

- Playlist filtering and search
- Bulk playlist creation/deletion
- Playlist analytics
- Collaborative playlist management
- Scheduled privacy changes
- Playlist templates

---

**Version**: 1.0.0  
**Last Updated**: December 2025
