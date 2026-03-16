-- Bonez-Bodycam | server/svConfig.lua
-- Server-only Discord credentials — never sent to clients.
--
-- HOW TO GET THESE VALUES:
--   1. Go to https://discord.com/developers/applications and create a new application.
--   2. Open the "Bot" tab, create a bot, and copy the token → paste into bot_token below.
--   3. Under "Privileged Gateway Intents", enable "Server Members Intent".
--   4. Invite the bot to your Discord server with the "bot" scope and "View Channels" + "Read Messages" permissions.
--   5. Enable Developer Mode in Discord (User Settings → Advanced), right-click your server icon → "Copy Server ID" → paste into server_id below.

configS = {}

configS.bot_token = ""   -- paste your Discord bot token here
configS.server_id = ""   -- paste your Discord server (guild) ID here
