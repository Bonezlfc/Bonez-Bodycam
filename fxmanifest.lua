fx_version 'cerulean'
game 'gta5'

name        'Bonez-Bodycam'
description 'Bodycam overlay with Axon, Motorola, and Generic styles. Optional night_ers integration for on-shift detection.'
author      'Bonez Workshop'
version     '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/fonts/KlartextMonoBold.ttf',
    'html/img/logo.png',
    'html/sound/beep.wav',
}

shared_scripts {
    'config.lua',
    'shared/util.lua',
}

client_scripts {
    'client/settings.lua',
    'client/ers.lua',
    'client/menu.lua',
    'client/main.lua',
}

server_scripts {
    'server/server.lua',
}
