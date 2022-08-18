version = 0.1                       -- Version of your script
local dcwebhook = ""                -- your discord webhook url
local scriptname = "script_name"    -- your script name
local dataurl =  scriptname..".json"-- your data url (json)
local githubscriptrepolink = "https://raw.githubusercontent.com/abdulkadiraktas/tebexvalidation/main/"..dataurl -- example please change yours.
-- "https://raw.githubusercontent.com/{your_github_user_name}/{reponame}/{branch}/"..dataurl

local githubMainDatalink = "https://raw.githubusercontent.com/abdulkadiraktas/tebexvalidation/main/datas.json" -- example please change yours.
-- "https://raw.githubusercontent.com/{your_github_user_name}/{reponame}/{branch}/datas.json"


if GetCurrentResourceName() ~= scriptname then for k=1,20 do print("Please change resource folder name to "..scriptname) end return end
print("--------------------- "..GetCurrentResourceName().." v"..version.." has loaded ---------------------")

function versionchecker()	
	local data = getdatafromapi(githubrepolink, function(data)
		if data then
			local dataversion = data.version
			local change = data.changelog
            if version < dataversion then
				print("A new update is available!","\nYour version : " ..version,"\nNew version :  "..dataversion ,"\nChange log : \n".. change.."\nDownload from keymaster!")
			end
		end
	end)
end
function verificationchecker()
	local hash, L = GetHost()
	local localhash = "Not Found"
	local datavarmi = false
	local getserverOwner = GetConvar("web_baseUrl", "")
	local sv_hostname = GetConvar("sv_hostname","sv_hostname Not Found")
	local sv_projectName = GetConvar("sv_projectName","sv_projectName Not Found")
	local rName = GetCurrentResourceName()
	if hash then localhash = GetHashKey(hash) end
	while getserverOwner == "" do
		getserverOwner = GetConvar("web_baseUrl", "")
		Wait(100)
	end
	getdatafromapi(githubMainDatalink, function(data)		
		local i, j = string.find(getserverOwner,"-")
		local serverowner = string.sub(getserverOwner,1,i-1) -- server owner name, If the server owner's name has this sign "-", it may not be validated in the verification system.
		local ownedScript = data?[serverowner]
		local color = 15158332 -- red color 
		if data and ownedScript and ownedScript?.ownedScript?[rName] then
			datavarmi = true
            color = 1821730 -- green color
		end
		SendWebhookMessage(dcwebhook,nil,{
			color=color,
			title="Script Started",
			description="Script started by "..getserverOwner,
			fields={
				{name="Script Version",value=version,inline=true},
				{name="|",value="|",inline=true},
				{name="Server Hash",value=localhash,inline=true},
				{name="Server IP",value=hash,inline=true},
				{name="|",value="|",inline=true},
				{name="Server Name",value=sv_hostname,inline=true},
				{name="Server Project Name",value=sv_projectName,inline=true},
				{name="|",value="|",inline=true},
				{name="Server Owner",value=serverowner,inline=true},
				{name="Data Verified",value=datavarmi,inline=false},
			}
		})
	end)
end
function GetHost()
    local data = nil
    PerformHttpRequest("http://api.ipify.org/", function(code, result, headers)
        if result and #result then
			data = result
        end
    end, "GET")
	local timeout = 0
	while not data and timeout < 10000 do
		Wait(100)
		timeout = timeout + 1
		print(timeout)
	end
	print(data)
	return data
end
function getdatafromapi(url,cb)
	local data = nil
	PerformHttpRequest(url, function(code, result, headers)
		if result and #result then
			data = json.decode(result)
			cb(data)
		end
	end, "GET")
end
function SendWebhookMessage(webhook,message,embed)
	if embed then
		local _embed = embedcreator(embed.color,embed.title,embed.description,embed.footer,embed.fields)
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({embeds = _embed}), { ['Content-Type'] = 'application/json' })		
	end
	if message then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end
function embedcreator(color,name,message,footer,fields)
	local embed = {
        {
            ["color"] = color,
            ["title"] = "**"..name.."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Powered By Abdulkadir AKTAS | ".. os.date("%X"),
            },
			["fields"] = {},
        }
    }
	for k,v in pairs(fields) do
		table.insert(embed[1].fields,{name=tostring(v.name),value=tostring(v.value),inline=v.inline})
	end
	return embed
end

Citizen.CreateThread(function()
    verificationchecker()
    while true do
        Wait(10000)
        versionchecker()
    end
end)
