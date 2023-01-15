if not getgenv().executedHi then
	getgenv().executedHi = true
else
	return
end

local songName
local debounce = false

local function sendMessage(text)
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
end

local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/main/Library.lua"))()

function notifynotify(message, duration)
	notif:SendNotification("Success", message, duration)
end

function notifyerror(message, duration)
	notif:SendNotification("Error", message, duration)
end

notifynotify('Loaded! | dotgg / szze#6220 / 502#8277',6)


game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents:WaitForChild('OnMessageDoneFiltering').OnClientEvent:Connect(function(msgdata)
	if debounce or not string.match(msgdata.Message, '>lyrics ') or string.gsub(msgdata.Message, '>lyrics', '') == '' or game:GetService('Players')[msgdata.FromSpeaker] == game:GetService('Players').LocalPlayer then
		return
	end
	local speaker = msgdata.FromSpeaker
	local msg = msgdata.Message:gsub('>lyrics ', ''):gsub('"', '')
	local speakerDisplay = game:GetService('Players')[speaker].DisplayName
	songName = string.gsub(msg, " ", "")
	local response = syn.request({
		Url = "https://lyrist.vercel.app/api/" .. songName,
		Method = "GET",
	})
	print(response.Body)
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
	sendMessage('Playing song requested by ' .. speakerDisplay)
	notifynotify('Singing ' .. songName, 5)
	task.wait(3)
	for i, line in ipairs(lyricsTable) do
		sendMessage('🎙️ | ' .. line)
		task.wait(6)
	end
	task.wait(3)
	debounce = false
	sendMessage('Ended. You can request songs again.')
end)

task.spawn(function()
	while task.wait(60) do
		if not debounce then
			sendMessage('I am a lyrics bot! Type ">lyrics SongName" and I will sing the song for you!')
		end
	end
end)

sendMessage('I am a lyrics bot! Type ">lyrics SongName" and I will sing the song for you!')
