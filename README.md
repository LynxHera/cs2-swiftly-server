CS2 + SwiftlyS2 Coolify - revised

SteamCMD previously installed CS2 to /home/steam/Steam/steamapps/common/Counter-Strike Global Offensive, ignoring the requested install location. This version persists the actual Steam library steamapps directory, including the appmanifest.

Create a new Coolify Docker Compose application using these three files at repository root. Configure CS2_GSLT as environment variable. Deploy and monitor logs. Do not reuse the previous empty cs2_data volume expecting it to populate automatically. First install requires substantial disk space. Update toggles are opt-in.

Swiftly installation logic is carried over from the original package and has not been tested on a running server. Check release archive layout and gameinfo loader compatibility if Swiftly installation fails.
