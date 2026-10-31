import Configuration
import Home
import HpkCore
import Systemd

config : {} -> Try(HpkCore.Plan, List(HpkCore.ConfigError))
config = |_| Configuration.make({
	id: "dotfiles",
	fragments: [
		Home.fileSource({
			path: ".config/fish/config.fish",
			source: "dot_config/fish/config.fish",
			mode: 0o644,
		}),
		# The script itself is deployed by chezmoi. It exits when BlueZ refuses to
		# register it (bluetoothd not up yet, say), so it's retried.
		Systemd.service({
			name: "bluez-agent",
			unit: { description: "BlueZ pairing agent" },
			service: {
				execStart: "%h/.local/bin/bluez-agent",
				restart: OnFailure,
				restartSec: "5s",
			},
			install: { wantedBy: ["default.target"] },
		}),
	],
})
