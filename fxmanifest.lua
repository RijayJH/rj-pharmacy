fx_version 'cerulean'
game 'gta5'

description 'Simple Pharmacy Script for FiveM'
author 'RijayJH'
version '0.1.0'

client_scripts {
    'client/**/*'
}

server_scripts {
    'server/**/*'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

lua54 'yes'
