fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'bonez-bodycam'
description 'Bodycam overlay with Axon, Motorola, and Generic styles. Optional night_ers integration for on-shift detection.'
author      'Bonez Workshop'
version     '2.1.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/fonts/KlartextMonoBold.ttf',
    'html/img/logo.png',
    'html/sound/beep.wav',
    'html/sound/axon_rec_on.wav',
    'html/sound/axon_rec_off.wav',
    'html/sound/motorola_rec_on.wav',
    'html/sound/motorola_rec_off.wav',
    'html/sound/generic_rec_on.wav',
    'html/sound/generic_rec_off.wav',
}

shared_scripts {
    'config.lua',
    'shared/util.lua',
}

client_scripts {
    'client/settings.lua',
    'client/ers.lua',
    'client/NativeUI.lua',
    'client/menu.lua',
    'client/main.lua',
}

server_scripts {
    'server/svConfig.lua',   -- Discord credentials (bot token + guild ID)
    'server/discord.lua',    -- Discord API helpers (reads configS)
    'server/server.lua',
}
