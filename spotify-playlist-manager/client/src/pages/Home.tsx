import { useAuth } from "@/_core/hooks/useAuth";
import { getLoginUrl } from "@/const";
import { trpc } from "@/lib/trpc";
import {
  Button,
  Card,
  CardBody,
  CardHeader,
  Checkbox,
  Chip,
  Image,
  Link,
  Spinner,
  Tooltip,
} from "@heroui/react";
import { Music, LogOut, ExternalLink, Globe, Lock } from "lucide-react";
import { useState, useMemo } from "react";
import { toast } from "sonner";

export default function Home() {
  const { user, logout, isAuthenticated, loading: authLoading } = useAuth();
  const [selectedPlaylists, setSelectedPlaylists] = useState<Set<string>>(
    new Set()
  );
  const [isUpdating, setIsUpdating] = useState(false);

  const { data: playlists, isLoading: playlistsLoading } =
    trpc.spotify.getPlaylists.useQuery(undefined, {
      enabled: isAuthenticated,
    });

  const { data: hasToken } = trpc.spotify.hasSpotifyToken.useQuery(undefined, {
    enabled: isAuthenticated,
  });

  const updatePlaylistMutation =
    trpc.spotify.updatePlaylistsStatusBatch.useMutation({
      onSuccess: (result) => {
        toast.success(
          `${result.successful} playlist(s) updated successfully${
            result.failed > 0 ? `, ${result.failed} failed` : ""
          }`
        );
        setSelectedPlaylists(new Set());
        utils.spotify.getPlaylists.invalidate();
      },
      onError: (error) => {
        toast.error(error.message || "Failed to update playlists");
      },
    });

  const utils = trpc.useUtils();

  const handleSelectPlaylist = (playlistId: string) => {
    const newSelected = new Set(selectedPlaylists);
    if (newSelected.has(playlistId)) {
      newSelected.delete(playlistId);
    } else {
      newSelected.add(playlistId);
    }
    setSelectedPlaylists(newSelected);
  };

  const handleSelectAll = () => {
    if (selectedPlaylists.size === playlists?.length) {
      setSelectedPlaylists(new Set());
    } else {
      setSelectedPlaylists(new Set(playlists?.map((p) => p.id) || []));
    }
  };

  const handleMakePublic = async () => {
    if (selectedPlaylists.size === 0) {
      toast.error("Please select at least one playlist");
      return;
    }

    setIsUpdating(true);
    try {
      await updatePlaylistMutation.mutateAsync({
        playlistIds: Array.from(selectedPlaylists),
        isPublic: true,
      });
    } finally {
      setIsUpdating(false);
    }
  };

  const handleMakePrivate = async () => {
    if (selectedPlaylists.size === 0) {
      toast.error("Please select at least one playlist");
      return;
    }

    setIsUpdating(true);
    try {
      await updatePlaylistMutation.mutateAsync({
        playlistIds: Array.from(selectedPlaylists),
        isPublic: false,
      });
    } finally {
      setIsUpdating(false);
    }
  };

  const handleLogout = async () => {
    await logout();
  };

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100">
        <Spinner size="lg" />
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100 px-4">
        <div className="max-w-md w-full space-y-8">
          <div className="text-center">
            <div className="flex justify-center mb-6">
              <div className="bg-gradient-to-br from-green-500 to-emerald-600 p-4 rounded-2xl">
                <Music className="w-8 h-8 text-white" />
              </div>
            </div>
            <h1 className="text-4xl font-bold text-slate-900 mb-2">
              Spotify Playlist Manager
            </h1>
            <p className="text-slate-600 text-lg">
              Manage your playlists with elegance and efficiency
            </p>
          </div>

          <Card className="border-0 shadow-lg">
            <CardBody className="gap-6 p-8">
              <p className="text-slate-600 text-center">
                Sign in with your Manus account to get started
              </p>
              <Button
                as={Link}
                href={getLoginUrl()}
                size="lg"
                className="bg-gradient-to-r from-blue-600 to-blue-700 text-white font-semibold"
                fullWidth
              >
                Sign In with Manus
              </Button>
            </CardBody>
          </Card>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-12">
            {[
              {
                icon: "🎵",
                title: "List Playlists",
                description: "View all your Spotify playlists",
              },
              {
                icon: "🔐",
                title: "Manage Privacy",
                description: "Control who can see your playlists",
              },
              {
                icon: "⚡",
                title: "Batch Actions",
                description: "Update multiple playlists at once",
              },
            ].map((feature, idx) => (
              <Card key={idx} className="border-0 shadow-md">
                <CardBody className="gap-3 p-6">
                  <div className="text-3xl">{feature.icon}</div>
                  <h3 className="font-semibold text-slate-900">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-slate-600">{feature.description}</p>
                </CardBody>
              </Card>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (!hasToken?.hasToken) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100 px-4">
        <div className="max-w-md w-full space-y-8">
          <div className="text-center">
            <div className="flex justify-center mb-6">
              <div className="bg-gradient-to-br from-green-500 to-emerald-600 p-4 rounded-2xl">
                <Music className="w-8 h-8 text-white" />
              </div>
            </div>
            <h1 className="text-3xl font-bold text-slate-900 mb-2">
              Connect Spotify
            </h1>
            <p className="text-slate-600">
              Authorize access to your Spotify account to manage your playlists
            </p>
          </div>

          <Card className="border-0 shadow-lg">
            <CardBody className="gap-6 p-8">
              <Button
                as={Link}
                href="/api/oauth/spotify/authorize"
                size="lg"
                className="bg-gradient-to-r from-green-500 to-emerald-600 text-white font-semibold"
                fullWidth
              >
                Connect with Spotify
              </Button>
              <Button
                variant="bordered"
                size="lg"
                onClick={handleLogout}
                fullWidth
              >
                Sign Out
              </Button>
            </CardBody>
          </Card>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      {/* Header */}
      <div className="bg-white border-b border-slate-200 shadow-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="bg-gradient-to-br from-green-500 to-emerald-600 p-2 rounded-lg">
                <Music className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold text-slate-900">
                  Spotify Playlist Manager
                </h1>
                <p className="text-sm text-slate-600">
                  {user?.name || "User"}
                </p>
              </div>
            </div>
            <Button
              isIconOnly
              variant="light"
              onClick={handleLogout}
              title="Sign out"
            >
              <LogOut className="w-5 h-5 text-slate-600" />
            </Button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {playlistsLoading ? (
          <div className="flex justify-center items-center min-h-96">
            <Spinner size="lg" />
          </div>
        ) : !playlists || playlists.length === 0 ? (
          <Card className="border-0 shadow-lg">
            <CardBody className="gap-4 p-8 text-center">
              <Music className="w-12 h-12 text-slate-400 mx-auto" />
              <h2 className="text-xl font-semibold text-slate-900">
                No playlists found
              </h2>
              <p className="text-slate-600">
                You don't have any playlists yet. Create one on Spotify to get
                started!
              </p>
            </CardBody>
          </Card>
        ) : (
          <>
            {/* Batch Actions */}
            {selectedPlaylists.size > 0 && (
              <Card className="border-0 shadow-lg mb-6 bg-blue-50">
                <CardBody className="gap-4 p-6">
                  <div className="flex items-center justify-between flex-wrap gap-4">
                    <div className="flex items-center gap-3">
                      <Checkbox
                        isSelected={
                          selectedPlaylists.size === playlists.length
                        }
                        onChange={handleSelectAll}
                      />
                      <span className="font-semibold text-slate-900">
                        {selectedPlaylists.size} selected
                      </span>
                    </div>
                    <div className="flex gap-3">
                      <Button
                        size="sm"
                        className="bg-gradient-to-r from-green-500 to-emerald-600 text-white font-semibold"
                        onClick={handleMakePublic}
                        isLoading={isUpdating}
                        disabled={isUpdating}
                      >
                        <Globe className="w-4 h-4" />
                        Make Public
                      </Button>
                      <Button
                        size="sm"
                        className="bg-gradient-to-r from-slate-600 to-slate-700 text-white font-semibold"
                        onClick={handleMakePrivate}
                        isLoading={isUpdating}
                        disabled={isUpdating}
                      >
                        <Lock className="w-4 h-4" />
                        Make Private
                      </Button>
                    </div>
                  </div>
                </CardBody>
              </Card>
            )}

            {/* Playlists Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {playlists.map((playlist) => (
                <Card
                  key={playlist.id}
                  className="border-0 shadow-lg hover:shadow-xl transition-shadow duration-200 overflow-hidden group"
                >
                  <CardHeader className="flex-col items-start px-0 py-0">
                    <div className="relative w-full h-48 bg-slate-200 overflow-hidden">
                      {playlist.imageUrl ? (
                        <Image
                          src={playlist.imageUrl}
                          alt={playlist.name}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-slate-300 to-slate-400">
                          <Music className="w-12 h-12 text-slate-600" />
                        </div>
                      )}
                      <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors duration-200" />
                    </div>
                  </CardHeader>

                  <CardBody className="gap-3 p-4">
                    <div className="flex items-start justify-between gap-2">
                      <div className="flex-1">
                        <h3 className="font-bold text-slate-900 line-clamp-2">
                          {playlist.name}
                        </h3>
                        <p className="text-sm text-slate-600 mt-1">
                          {playlist.tracksTotal} tracks
                        </p>
                      </div>
                      <Checkbox
                        isSelected={selectedPlaylists.has(playlist.id)}
                        onChange={() => handleSelectPlaylist(playlist.id)}
                      />
                    </div>

                    {playlist.description && (
                      <p className="text-sm text-slate-600 line-clamp-2">
                        {playlist.description}
                      </p>
                    )}

                    <div className="flex items-center gap-2 pt-2">
                      <Chip
                        size="sm"
                        variant="flat"
                        className={
                          playlist.public
                            ? "bg-green-100 text-green-700"
                            : "bg-slate-100 text-slate-700"
                        }
                        startContent={
                          playlist.public ? (
                            <Globe className="w-3 h-3" />
                          ) : (
                            <Lock className="w-3 h-3" />
                          )
                        }
                      >
                        {playlist.public ? "Public" : "Private"}
                      </Chip>
                      {playlist.collaborative && (
                        <Chip size="sm" variant="flat" className="bg-blue-100 text-blue-700">
                          Collaborative
                        </Chip>
                      )}
                    </div>

                    <Tooltip content="Open in Spotify">
                      <Button
                        as={Link}
                        href={playlist.externalUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        isIconOnly
                        variant="light"
                        size="sm"
                        className="text-green-600 hover:text-green-700 mt-2"
                      >
                        <ExternalLink className="w-4 h-4" />
                      </Button>
                    </Tooltip>
                  </CardBody>
                </Card>
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}
