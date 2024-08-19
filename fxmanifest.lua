fx_version "cerulean"

description "A boilerplate is being made for solving recursive actions while scripting in FiveM"
author "GFX Development"
version '1.0.0'
repository 'https://github.com/GFX-Fivem/fivem-script-boilerplate'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

ui_page 'web/build/index.html'

client_scripts {
  "config/locale.lua",
  "config/client_config.lua",
  "client/utils.lua",
  "client/*.lua",
}
server_script {
  "config/locale.lua",
  "config/server_config.lua",
  "server/utils.lua",
  "server/*.lua",
}

files {
	'web/build/index.html',
	'web/build/**/*',
}

local isEscrowed = false
if isEscrowed then
  escrow_ignore {
    "config/*.lua",
    "client/editable.lua",
    "server/editable.lua",
  }
else
  escrow_ignore {
    "config/*.lua",
    "client/**/*",
    "server/**/*",
  }
end