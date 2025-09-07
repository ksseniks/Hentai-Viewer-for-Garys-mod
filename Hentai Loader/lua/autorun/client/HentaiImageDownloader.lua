---------------------------------CONCOMMAND HENTAI---------------------------------
CreateClientConVar("ks_saveHentaiTags", 1)
CreateClientConVar("ks_consoleMessage", 1)
CreateClientConVar("ks_enableHentaiUi", 1)

concommand.Add("ks_hentai", function()
	LoadingHentai()
end)
---------------------------------END CONCOMMAND HENTAI---------------------------------
--==========================================================================================================--	
---------------------------------READ RAITING FILE---------------------------------
local function ReadFileToTable(pathToFile, gameDirectory)
	-- local files, directories = file.Find(pathToFile, "DATA")
	if file.Find(pathToFile, gameDirectory) == nil then
		file.Write(pathToFile, "" )
	end


    local fileContent = file.Read(pathToFile, gameDirectory)
    local tableTags = {}

    if fileContent then
        for line in string.gmatch(fileContent, "[^\r\n]+") do
            local tag, count = string.match(line, "([^:]+): (%d+)")
            if tag && count then
                tableTags[tag] = tonumber(count)
            end
        end
    end

    return tableTags
end
---------------------------------READ RAITING FILE---------------------------------
--==========================================================================================================--
---------------------------------SAVE HENTAI TAGS---------------------------------	
function SaveHentaiTags(tableTags)
    local existingTags = ReadFileToTable("hentai/TagsPriorities.txt", "DATA")
    for tag, count in pairs(tableTags) do
        if existingTags[tag] then
            existingTags[tag] = existingTags[tag] + count
        else
            existingTags[tag] = count
        end
    end

	local sortedTags = {}
	for tag, count in pairs(existingTags) do
		table.insert(sortedTags, {tag = tag, count = count})
	end

	table.sort(sortedTags, function(a, b) 
		return a. count > b. count 
	end )

	local fileContent = ""
	for _, tagData in ipairs(sortedTags) do
		fileContent = fileContent .. tagData.tag .. ": " .. tagData.count .. "\n"
	end
	file.Write("hentai/TagsPriorities.txt", fileContent)
end
---------------------------------END SAVE HENTAI TAGS---------------------------------
--==========================================================================================================--	
---------------------------------GETTING RAITING LIST---------------------------------
local function GettingRaitingList(raitingCount)
    local fileContent = file.Read("hentai/TagsPriorities.txt", "DATA")
    local resultString = ""

    if fileContent then
        for line in string.gmatch(fileContent, "[^\r\n]+") do
            local tag, count = string.match(line, "([^:]+): (%d+)")
            if tag and count then
                count = tonumber(count)
                if count >= raitingCount then
                    resultString = resultString .. "+" .. tag
                end
            end
        end
    end

    return resultString
end
---------------------------------END GETTING RAITING LIST---------------------------------
--==========================================================================================================--
---------------------------------LOADING HENTAI---------------------------------	
local idHentai = 99264
function LoadingHentai()
	local files = file.Find("hentai/*.jpg", "DATA")
	if (!file.Exists("hentai", "DATA") || files[#files] == nil) then
		file.CreateDir("hentai")
	end

	CreateLinkHentai(math.random(1, 99264))
end
---------------------------------END LOADING HENTAI---------------------------------
--==========================================================================================================--	
---------------------------------CREATE HENTAI LINK---------------------------------	
local tags = "+-male+-animal_genitalia+-my_little_pony+-warcraft+-male_only+-hyper+-overweight+-big_breasts+-big_ass+-big_breasts+-huge_breats+-cuntboys"
function CreateLinkHentai(count)
	if (GettingRaitingList(10) != "") then
		tags = GettingRaitingList(10)
	end
	local hentaiLink = "https://api.rule34.xxx/index.php?&api_key=79f67625912bc51fea665be1d7d9b7ec5234399e0cd5df477321784b3e1a6e1e11df75ca3ce3b173132c1ca14f1d6629c1798df7bbe6b3bea7d09db4c1f997d7&user_id=1179743&page=dapi&s=post&tags=".. tags .."&json=1&q=index&limit=1&pid=" .. count

	http.Fetch(hentaiLink, 
		function(response)
			if (GetConVar("ks_consoleMessage"):GetBool()) then
				print("We are checking if the " .. count .. " image is suitable for us using the specified tags!")
			end
			
			local data = util.JSONToTable(response) --page run 
			if (data != nil) then
				if (data[1] != nil) then
					local imageHentai = data[1].file_url

					if (!GetConVar("ks_enableHentaiUi"):GetBool()) then
						LoadingHentai()
						print("Save Image № ".. count)
						return WriteHentai(imageHentai, data[1].id,  data[1].tags)
					end

					print("Uploading Image № ".. count)
					print("Tags: ".. tags)

					return DrawHentaiUI(imageHentai, data[1].width, data[1].height, data[1].id, data[1].tags)
				end
			end

			if (GetConVar("ks_consoleMessage"):GetBool()) then
				print("This doesn't fit!")
			end
			LoadingHentai()
		end,
		function(error)
			print("[HTTP ERROR] hentaiLink:", error)
		end
	)
end
---------------------------------END CREATE HENTAI LINK---------------------------------	
--==========================================================================================================--	
---------------------------------DRAW HENTAI UI---------------------------------	
function DrawHentaiUI(imageHentai, width, height, id, tags)
	local heightUi = ScrH()/1.5
	local wightUi = heightUi * (width/height)

	local frame = vgui.Create("DFrame")
	frame:SetSize(wightUi, heightUi + heightUi/7)
	frame:SetVisible(true)
	frame:MakePopup()
	frame:Center()

	local img = frame:Add('DHTML')
	img:SetSize(wightUi, heightUi)
	img:AlignTop(25)
	img:SetHTML( ([[
		<body>
			<style>
				body {
					margin: 0;
					padding: 0;
				}

				img {
					width: 100%%;
					height: 100%%;
					margin: 0;
					padding: 0;
				}
			</style>
			<img src="%s">
		</body>
	]]):format(imageHentai))

	local button = frame:Add('DButton')
	button:SetSize(wightUi/2, heightUi/12)
	button:SetText("Skip")
	button:AlignBottom(heightUi/100)
	button:AlignRight(heightUi/100)

	function button:DoClick()
		local files = file.Find("hentai/*.jpg", "DATA")
		if (files[#files] != nil) then
			file.Rename("hentai/" .. files[#files], "hentai/" .. idHentai + 1 .. ".jpg")
		end

		LoadingHentai()
		frame:Close()
	end

	local button = frame:Add('DButton')
	button:SetSize(wightUi/2, heightUi/12)
	button:SetText("Save")
	button:AlignBottom(heightUi/100)
	button:AlignLeft(heightUi/100)

	function button:DoClick()
		WriteHentai(imageHentai, id, tags)
		frame:Close()
	end

	-- frame:Close()
end
---------------------------------END DRAW HENTAI UI---------------------------------
--==========================================================================================================--	
---------------------------------WRITE HENTAI---------------------------------	
function WriteHentai(imageHentai, id, tags)
	local tableTags = {}
	http.Fetch(imageHentai, function(imageData)
		local files = file.Find("hentai/*.jpg", "DATA")
		file.Write("hentai/" ..  id .. ".jpg", imageData)

		local files = file.Find("hentai/*.jpg", "DATA")
		file.Rename("hentai/" .. files[#files], "hentai/" .. id + 1 .. ".jpg")

		for tag in string.gmatch(tags, "%S+") do
			if (tableTags[tag] == nil) then
				tableTags[tag] = 1
			else
				tableTags[tag] = tableTags[tag] + 1
			end
		end

		if (GetConVar("ks_SaveHentaiTags"):GetBool()) then
			SaveHentaiTags(tableTags)
		end

		LoadingHentai()
	end)
end

---------------------------------END WRITE HENTAI---------------------------------	
