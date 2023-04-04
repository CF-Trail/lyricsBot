repeat task.wait() until game:IsLoaded()
local votedata = Instance.new('Folder')
local skipdata = 0
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

game:GetService('ReplicatedStorage').DefaultChatSystemChatEvents:WaitForChild('OnMessageDoneFiltering').OnClientEvent:Connect(function(msgdata)
	if plr ~= nil and (msgdata.FromSpeaker == plr or msgdata.FromSpeaker == game:GetService('Players').LocalPlayer.Name) then
		if string.lower(msgdata.Message) == '>stop' then
			getgenv().stopped = true
			debounce = true
			task.wait(3)
			debounce = false
		end
	end
	if msgdata.Message == '>skip' and not votedata:FindFirstChild(msgdata.FromSpeaker) then
	    local xf = Instance.new('StringValue',votedata)
	    xf.Name = msgdata.FromSpeaker
	    skipdata += 1
	    if skipdata >= 3 then
		sendMessage("Seems like people don't like this song. Votestopped!")
		votedata:ClearAllChildren()
		skipdata = 0
		getgenv().stopped = true
	    end
	end
	if debounce or not string.match(msgdata.Message, '>lyrics ') or string.gsub(msgdata.Message, '>lyrics', '') == '' or game:GetService('Players')[msgdata.FromSpeaker] == game:GetService('Players').LocalPlayer then
		return
	end
	debounce = true
	local speaker = msgdata.FromSpeaker
	local msg = string.lower(msgdata.Message):gsub('>lyrics ', ''):gsub('"', ''):gsub(' by ','/')
	local speakerDisplay = game:GetService('Players')[speaker].DisplayName
	plr = game:GetService('Players')[speaker].Name
	songName = string.gsub(msg, " ", ""):lower()
	local response
    local suc,er = pcall(function()
	response = httprequest({
		Url = "https://lyrist.vercel.app/api/" .. songName,
		Method = "GET",
	})
    end)
    if not suc then
	sendMessage('Unexpected error, please retry')
	task.wait(3)
	debounce = false
	return
    end
	local lyricsData = game:GetService('HttpService'):JSONDecode(response.Body)
	local lyricsTable = {}
	if lyricsData.error and lyricsData.error == "Lyrics Not found" then
		debounce = true
		sendMessage('Lyrics were not found')
		task.wait(3)
		debounce = false
		return
	end
	local suc, er = pcall(function() for line in string.gmatch(lyricsData.lyrics, "[^\n]+") do
		table.insert(lyricsTable, line)
	end end)
      if not suc then
	sendMessage('Unexpected error, please retry')
	task.wait(3)
	debounce = false
	return
      end
	sendMessage('Fetched lyrics')
	task.wait(2)
	sendMessage('Playing song requested by ' .. speakerDisplay .. '. They can stop it by saying ">stop"')
	task.wait(3)
	sendMessage('You can always do >skip to do a vote for skipping the song [3 votes needed!]')
	task.wait(4)
	for i, line in ipairs(lyricsTable) do
		if getgenv().stopped then
			getgenv().stopped = false
			break
		end
		sendMessage('🎙️ | ' .. line)
		task.wait(4.8)
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
