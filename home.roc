import Configuration
import Home
import HpkCore

config : {} -> Try(HpkCore.Plan, List(HpkCore.ConfigError))
config = |_| Configuration.make({
	id: "dotfiles",
	fragments: [
		Home.fileSource({
			path: ".config/fish/config.fish",
			source: "dot_config/fish/config.fish",
			mode: 0o644,
		}),
	],
})
