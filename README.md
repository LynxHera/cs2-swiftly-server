# Coolify CS2 + SwiftlyS2

Coolify > New Resource > Git Repository > Docker Compose. Commit all three deployment files to a Git repository.

Set `CS2_GSLT` in Coolify environment variables (Steam game server token, App ID 730). Open UDP 27015 in host/provider firewall. Deploy.

First boot installs CS2 and latest **stable** Linux SwiftlyS2 with runtimes. A persistent named volume preserves CS2, plugins and configs between redeploys/restarts. Do **not** delete the volume.

Optional environment flags (default 0):
- `CS2_UPDATE_ON_START=1`: validate/update CS2 on next start; set back to 0 afterward.
- `SWIFTLY_UPDATE_ON_START=1`: download latest SwiftlyS2 on next start; set back to 0 afterward. Back up plugin files before framework upgrades.

Verify Swiftly by entering `sw` in the CS2 server console. Plugin location: `/home/steam/cs2/game/csgo/addons/swiftlys2/` (follow plugin-specific directory instructions).

**Note:** This package has not been deployed/tested on your host. If your existing deployment uses a different named volume, migrate its data before switching, otherwise a fresh volume will be created.
