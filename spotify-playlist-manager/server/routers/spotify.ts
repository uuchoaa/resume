import { z } from "zod";
import { protectedProcedure, router } from "../_core/trpc";
import { getValidAccessToken } from "../spotify-auth";
import {
  getAllUserPlaylists,
  updatePlaylistDetails,
} from "../spotify";
import { TRPCError } from "@trpc/server";

export const spotifyRouter = router({
  /**
   * Get all playlists for the current user
   */
  getPlaylists: protectedProcedure.query(async ({ ctx }) => {
    try {
      const accessToken = await getValidAccessToken(ctx.user.id);
      const playlists = await getAllUserPlaylists(accessToken);

      return playlists.map((playlist) => ({
        id: playlist.id,
        name: playlist.name,
        description: playlist.description,
        public: playlist.public,
        collaborative: playlist.collaborative,
        externalUrl: playlist.external_urls.spotify,
        imageUrl: playlist.images[0]?.url || null,
        tracksTotal: playlist.tracks.total,
        ownerName: playlist.owner.display_name,
      }));
    } catch (error) {
      console.error("[Spotify] Failed to get playlists:", error);
      throw new TRPCError({
        code: "INTERNAL_SERVER_ERROR",
        message: "Failed to fetch playlists from Spotify",
      });
    }
  }),

  /**
   * Update a single playlist's public/private status
   */
  updatePlaylistStatus: protectedProcedure
    .input(
      z.object({
        playlistId: z.string(),
        isPublic: z.boolean(),
      })
    )
    .mutation(async ({ ctx, input }) => {
      try {
        const accessToken = await getValidAccessToken(ctx.user.id);
        await updatePlaylistDetails(
          accessToken,
          input.playlistId,
          input.isPublic
        );

        return { success: true };
      } catch (error) {
        console.error("[Spotify] Failed to update playlist:", error);
        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Failed to update playlist status",
        });
      }
    }),

  /**
   * Update multiple playlists' public/private status in batch
   */
  updatePlaylistsStatusBatch: protectedProcedure
    .input(
      z.object({
        playlistIds: z.array(z.string()),
        isPublic: z.boolean(),
      })
    )
    .mutation(async ({ ctx, input }) => {
      try {
        const accessToken = await getValidAccessToken(ctx.user.id);

        const results = await Promise.allSettled(
          input.playlistIds.map((playlistId) =>
            updatePlaylistDetails(accessToken, playlistId, input.isPublic)
          )
        );

        const successful = results.filter(
          (result) => result.status === "fulfilled"
        ).length;
        const failed = results.filter(
          (result) => result.status === "rejected"
        ).length;

        if (failed > 0) {
          console.warn(
            `[Spotify] Batch update: ${successful} successful, ${failed} failed`
          );
        }

        return {
          success: true,
          successful,
          failed,
        };
      } catch (error) {
        console.error("[Spotify] Failed to update playlists batch:", error);
        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Failed to update playlists status",
        });
      }
    }),

  /**
   * Check if user has Spotify token
   */
  hasSpotifyToken: protectedProcedure.query(async ({ ctx }) => {
    try {
      await getValidAccessToken(ctx.user.id);
      return { hasToken: true };
    } catch {
      return { hasToken: false };
    }
  }),
});
