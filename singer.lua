repeat task.wait() until game:IsLoaded()

if not getgenv().executedHi then
	getgenv().executedHi = true
else
	return
end
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request

local songName,plr
local debounce = false

getgenv().stopped = false

local function sendMessage(text)
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
end

local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/main/Library.lua"))()

function notifynotify(message, duration)
	notif:SendNotification("Info", message, duration)
end

function notifyerror(message, duration)
	notif:SendNotification("Error", message, duration)
end

notifynotify('Loaded! | dotgg / szze#6220 / 502#8277',6)

game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents:WaitForChild('OnMessageDoneFiltering').OnClientEvent:Connect(function(msgdata)
	if plr ~= nil and (msgdata.FromSpeaker == plr or msgdata.FromSpeaker == game:GetService('Players').LocalPlayer.Name) then
		if string.lower(msgdata.Message) == '>stop' then
			notifynotify('Stopped',3)
			getgenv().stopped = true
			debounce = true
			task.wait(3)
			debounce = false
		end
	end
	if debounce or not string.match(msgdata.Message, '>lyrics ') or string.gsub(msgdata.Message, '>lyrics', '') == '' or game:GetService('Players')[msgdata.FromSpeaker] == game:GetService('Players').LocalPlayer then
		return
	end
	local speaker = msgdata.FromSpeaker
	local msg = string.lower(msgdata.Message):gsub('>lyrics ', ''):gsub('"', ''):gsub(' by ','/')
	local speakerDisplay = game:GetService('Players')[speaker].DisplayName
	plr = game:GetService('Players')[speaker].Name
	songName = string.gsub(msg, " ", ""):lower()
    local suc,er = pcall(function()
	local response = httprequest({
		Url = "https://lyrist.vercel.app/api/" .. songName,
		Method = "GET",
	})
    end)
    if not suc then
	sendMessage('Unexpected error, please retry')
    end
	local lyricsData = game.HttpService:JSONDecode(response.Body)
	local lyricsTable = {}
	if lyricsData.error and lyricsData.error == "Lyrics Not found" then
		debounce = true
		sendMessage('Lyrics were not found')
		notifyerror('Lyrics were not found', 5)
		task.wait(2)
		debounce = false
		return
	end
	for line in string.gmatch(lyricsData.lyrics, "[^\n]+") do
		table.insert(lyricsTable, line)
	end
	debounce = true
	sendMessage('Fetched lyrics')
	task.wait(2)
	sendMessage('Playing song requested by ' .. speakerDisplay .. '. They can stop it by saying ">stop"')
	notifynotify('Singing ' .. songName, 5)
	notifynotify('You can stop songs by saying >stop',5)
	task.wait(3)
	for i, line in ipairs(lyricsTable) do
		if getgenv().stopped then
			getgenv().stopped = false
			break
		end
		sendMessage('🎙️ | ' .. line)
		task.wait(5)
	end
	task.wait(3)
	debounce = false
	sendMessage('Ended. You can request songs again.')
end)

task.spawn(function()
	while task.wait(60) do
		if not debounce then
			sendMessage('I am a lyrics bot! Type ">lyrics SongName" and I will sing the song for you!')
			task.wait(2)
			if not debounce then
				sendMessage('You can also do ">lyrics SongName by Author"')
			end
		end
	end
end)

sendMessage('I am a lyrics bot! Type ">lyrics SongName" and I will sing the song for you!')
task.wait(2)
sendMessage('You can also do ">lyrics SongName by Author"')
