-- Exo Raid Setup v1.34
-- Bioquark of Eredar
local ERSver = "1.34"
local ERScoord = {}
local ERSInputRequestor
local TempSetup = {}
local ERSbackgrounds = {"Blank",
	"Lord Kazzak_Blasted Lands","Azuregos_Azshara","Emeriss_Feralas","Lethon_Hinterlands","Taerar_Duskwood","Ysondre_Ashenvale",
	"Kel'Thuzad_NAXX","Sapphiron_NAXX","Thaddius_NAXX","Gluth_NAXX","Grobbulus_NAXX","Patchwerk_NAXX","Loatheb_NAXX","Heigan the Unclean_NAXX","Noth the Plaguebringer_NAXX","The Four Horsemen_NAXX","Gothik the Harvester_NAXX",
	"Instructor Razuvious_NAXX","Maexxna_NAXX","Grand Widow Faerlina_NAXX","Anub'Rekhan_NAXX",
	"C'thun_AQ40","Ouro_AQ40","Twin Emperors_AQ40","Princess Huhuran_AQ40","Viscidus_AQ40","Fankriss the Unyielding_AQ40","Battleguard Sartura_AQ40","Bug Trio_AQ40","The Prophet Skeram_AQ40",
	"Nefarian_BWL","Chromaggus_BWL","Flamegor_BWL","Ebonroc_BWL","Firemaw_BWL","Broodlord Lashlayer_BWL","Vaelastrasz the Corrupt_BWL","Razorgore the Untamed_BWL",
	"Ragnaros_MC","Majordomo Executus_MC","Golemagg the Incinerator_MC","Sulfuron Harbinger_MC","Shazzrah_MC","Baron Geddon_MC","Garr_MC","Gehennas_MC","Magmadar_MC","Lucifron_MC",
	"Onyxia_ONY",
	"Ossirian the Unscarred_AQ20","Ayamiss the Hunter_AQ20","Buru the Gorger_AQ20","Moam_AQ20","General Rajaxx_AQ20","Kurinnaxx_AQ20",
	"Gahz'ranka_ZG","Hakkar_ZG","Jin'do the Hexxer_ZG","High Priestess Arlokk_ZG","High Priest Thekal_ZG","Edge of Madness_ZG","Bloodlord Mandokir_ZG","High Priestess Mar'li_ZG","High Priest Venoxis_ZG","High Priestess Jeklik_ZG",
	"AV_North","AV_Middle","AV_South","AB","WSG","Gurubashi_Arena","TheMaul_Arena","Darnassis","Ironforge","Stormwind","Undercity","ThunderBluff","Orgrimmar",
	"MiniMap"}
local ERSbackground = 0
local firstshow = true
local firstRaidshow = true
local ERScheckRaid = {}
local ERSchecking = false
local ERSarrow = 1
local ERSnumArrows = 0
local ERSnumVisArrows = 0
local ERSisAFK = false
local leaderBroadcast = false
local ERSWindowsOpen = false
local ERSlastSend = 0
local ERSanimationSeq = {}
local ERSanimationFrame = 1
local ERSanimationActive = false
local ERSanimationRate = 3
local ERSsendingAnimation = false
local ERSrecievingAnimation = false
local ERSanimationReplay = false
local ERSnumberAniFrames = 0
ERSscale = 1
ERSmmMask = 0
local targetAudience

function ers_onload()
	SlashCmdList["ExoRaidSetup"] = ers_slashHandler
	SLASH_ExoRaidSetup1 = "/ers";
	ExoRaidSetupMainText:SetText("Set Title Here");
	local prepaa
	for prepaa = 1,10 do
		ERScoord[(prepaa + 20)] = "BS"
	end
	ERSbackdrop:ClearAllPoints()
	ERSbackdrop:SetWidth(290)
	ERSbackdrop:SetHeight(290)
	ERSbackdrop:SetPoint("CENTER",ExoRaidSetupMain)
	ExoRaidSetupMain:SetClampedToScreen(true)
	ERShide:SetTextColor(.9,.5,0)
	ERSanimation:SetText("#")
	ERSanimation:SetTextColor(.5,.5,.5)
	ERSmmInfo:Hide()
end

function ers_animationToggle(click)
	if ers_IsOfficer() or not UnitInRaid("player") then
		if click == "LeftButton" then
			if ERSanimationActive  then
				ERSanimationActive = false
				ers_animationStoreFrame(true)
				ERSanimation:SetText("#")
				ERSanimation:SetTextColor(.5,.5,.5)
				ers_sendReset("RightButton")
			else
				ERSanimationActive = true
				ERSanimation:SetText(ERSanimationFrame)
				ERSanimation:SetTextColor(0,1,0)
				if ERSanimationSeq[ERSanimationFrame] then
					ERScoord = {}
					for k,v in ERSanimationSeq[ERSanimationFrame] do
						ERScoord[k] = v
					end
					ers_animArrowAdjust()
					ers_setSym(true)
				end
			end
		elseif click == "RightButton" then 
			if not ERSanimationActive then
				RaidWarningFrame:AddMessage("Animation Frames Cleared")
				ERSanimationFrame = 1
				ERSanimationSeq = {}
			else
				RaidWarningFrame:AddMessage("Animation Frame "..ERSanimationFrame.." Deleted")
				ers_animationStoreFrame(true)
				ers_deleteAnimationFrame()
			end
		end
		if MouseIsOver(ERSanimation) then
			ers_setTT("ERSanimation")
		end
	else
		if ERSanimationActive then
			ERSanimation:Hide()
			ERSlastSend = GetTime() - (ERSanimationRate + 1)
			ERSanimationFrame = 1
			ERSanimationReplay = true
		end
	end
end

function ers_mmMaskToggle()
	if ERSmmMask == 0 then
		ERSmmMask = 1
		ERSmmInfo:SetText("[ ]")
	else
		ERSmmMask = 0
		ERSmmInfo:SetText("O")
	end
	ers_setTT("ERSmmInfo")
end

function ers_mmScale(mWheel)
	if mWheel == 1 then
		ERSscale = ERSscale + .05
		if ERSscale > 1 then
			ERSscale = 1
		end
	elseif mWheel == -1 then
		ERSscale = ERSscale - .05
		if ERSscale < .5 then
			ERSscale = .5
		end
	end
	ExoRaidSetupMain:SetScale(ERSscale)	
	ExoRaidSetupMain:ClearAllPoints()
	ExoRaidSetupMain:SetPoint("TOPLEFT","UIParent","CENTER",(TempSetup[109] - (10 - (ERSscale*10))),(TempSetup[110] - (10 - (ERSscale*10))))
end


function ers_mmToggle()
	--on the default UI almost ALL of these have only one anchor FYI
	if Minimap:GetParent() ~= ExoRaidSetupMain then
		local mmParent = Minimap:GetParent()
		TempSetup[111] = Minimap:GetScale()
		TempSetup[103] = mmParent:GetName()
		TempSetup[104] = Minimap:GetNumPoints()
		local getMMAnchors
		TempSetup[101] = {} --this will store all sub components of the Minimap's current anchors
		for getMMAnchors = 1,TempSetup[104] do
			TempSetup[101][getMMAnchors] = {}
			TempSetup[101][getMMAnchors]["point"],
			TempSetup[101][getMMAnchors]["relTo"],
			TempSetup[101][getMMAnchors]["relPoint"],
			TempSetup[101][getMMAnchors]["xOfs"],
			TempSetup[101][getMMAnchors]["yOfs"] = Minimap:GetPoint(getMMAnchors)
		end

		local mmKids = {Minimap:GetChildren()}
		TempSetup[102] = {}
		TempSetup[105] = {}
		local getMMKidAnchors
		local xPos = {-150,-120,-90,-60,-30,0,30,60,90,120,150}
		local xSpot = 1
		for k,v in mmKids do
			if v:IsVisible() and v ~= MinimapBackdrop then
				TempSetup[105][k] = v:GetNumPoints()
				TempSetup[102][k] = {}
				TempSetup[102][k][0] = v
				for getMMKidAnchors = 1,TempSetup[105][k] do
					TempSetup[102][k][getMMKidAnchors] = {}
					TempSetup[102][k][getMMKidAnchors]["point"],
					TempSetup[102][k][getMMKidAnchors]["relTo"],
					TempSetup[102][k][getMMKidAnchors]["relPoint"],
					TempSetup[102][k][getMMKidAnchors]["xOfs"],
					TempSetup[102][k][getMMKidAnchors]["yOfs"] = v:GetPoint(getMMKidAnchors)
				end
				if v:GetName() then
					v:SetParent(ExoRaidSetupMain)
					v:ClearAllPoints()
					v:SetPoint("CENTER","ExoRaidSetupMain","BOTTOM",xPos[xSpot],-40)
					xSpot = xSpot + 1
				end
			end
		end	
		
		if MinimapZoomIn:IsVisible() then	
			TempSetup[108] = true
			
			TempSetup[106] = {}
			TempSetup[106]["point"],
			TempSetup[106]["relTo"],
			TempSetup[106]["relPoint"],
			TempSetup[106]["xOfs"],
			TempSetup[106]["yOfs"] = MinimapZoomIn:GetPoint(1)
			
			TempSetup[107] = {}
			TempSetup[107]["point"],
			TempSetup[107]["relTo"],
			TempSetup[107]["relPoint"],
			TempSetup[107]["xOfs"],
			TempSetup[107]["yOfs"] = MinimapZoomOut:GetPoint(1)					

		else
			MinimapZoomIn:Show()
			MinimapZoomOut:Show()
			TempSetup[108] = false
		end
		
		MinimapZoomIn:SetParent(ExoRaidSetupMain)
		MinimapZoomOut:SetParent(ExoRaidSetupMain)
		MinimapZoomIn:ClearAllPoints()
		MinimapZoomOut:ClearAllPoints()
		MinimapZoomIn:SetPoint("LEFT",ExoRaidSetupMain,"BOTTOMRIGHT",-20,50)
		MinimapZoomOut:SetPoint("LEFT",ExoRaidSetupMain,"BOTTOMRIGHT",-20,10)		
		
		MinimapBackdrop:Hide()	
		
		Minimap:SetMaskTexture("Interface\\AddOns\\ExoRaidSetup\\ERSart\\mmMask.blp")
		Minimap:SetScale(2.0)
		Minimap:SetParent(ExoRaidSetupMain)
		mmParent:Hide()
		Minimap:ClearAllPoints()
		ERSbackdrop:SetTexture("Interface\\AddOns\\ExoRaidSetup\\ERSart\\mmBackground")
		Minimap:SetPoint("TOPLEFT",ExoRaidSetupMain,"TOPLEFT",12,-12)
		Minimap:SetPoint("TOPRIGHT",ExoRaidSetupMain,"TOPRIGHT",-12,-12)
		Minimap:SetPoint("BOTTOMLEFT",ExoRaidSetupMain,"BOTTOMLEFT",12,12)
		Minimap:SetPoint("BOTTOMRIGHT",ExoRaidSetupMain,"BOTTOMRIGHT",-12,12)
	else
		Minimap:SetScale(TempSetup[111])
		Minimap:SetParent(TempSetup[103])
		getglobal(TempSetup[103]):Show()
		Minimap:ClearAllPoints()
		if ERSmmMask == 0 then
			Minimap:SetMaskTexture("Textures\\MinimapMask")
		end
		local restoMMAnchors
		for restoMMAnchors = 1,TempSetup[104] do
			Minimap:SetPoint(	TempSetup[101][restoMMAnchors]["point"],
							TempSetup[101][restoMMAnchors]["relTo"],
							TempSetup[101][restoMMAnchors]["relPoint"],
							TempSetup[101][restoMMAnchors]["xOfs"],
							TempSetup[101][restoMMAnchors]["yOfs"])
		end

		local restoMMKids
		for k,_ in TempSetup[102] do
			TempSetup[102][k][0]:SetParent(Minimap)
			TempSetup[102][k][0]:ClearAllPoints()
			for restoMMKids = 1,TempSetup[105][k]  do
				TempSetup[102][k][0]:SetPoint(	TempSetup[102][k][restoMMKids]["point"],
											TempSetup[102][k][restoMMKids]["relTo"],
											TempSetup[102][k][restoMMKids]["relPoint"],
											TempSetup[102][k][restoMMKids]["xOfs"],
											TempSetup[102][k][restoMMKids]["yOfs"])
			end
		end
		MinimapBackdrop:Show()
		if TempSetup[108] then
			MinimapZoomIn:SetParent(MinimapBackdrop)
			MinimapZoomIn:ClearAllPoints()
			MinimapZoomIn:SetPoint(TempSetup[106]["point"],
								TempSetup[106]["relTo"],
								TempSetup[106]["relPoint"],
								TempSetup[106]["xOfs"],
								TempSetup[106]["yOfs"])
								
			MinimapZoomOut:SetParent(MinimapBackdrop)
			MinimapZoomOut:ClearAllPoints()
			MinimapZoomOut:SetPoint(	TempSetup[107]["point"],
													TempSetup[107]["relTo"],
													TempSetup[107]["relPoint"],
													TempSetup[107]["xOfs"],
													TempSetup[107]["yOfs"])	
		else
			MinimapZoomIn:Hide()
			MinimapZoomOut:Hide()
		end
	end
	ExoRaidSetupMain:ClearAllPoints()
	ExoRaidSetupMain:SetScale(1)
	ExoRaidSetupMain:SetPoint("TOPLEFT","UIParent","CENTER",(TempSetup[109] - (10 - (ERSscale*10))),(TempSetup[110] - (10 - (ERSscale*10))))	
end

function ers_animationStoreFrame(GetSym)
	if GetSym then
		ers_getSymData()
	end
	ERSanimationSeq[ERSanimationFrame] = {}	
	for k,v in ERScoord do
		ERSanimationSeq[ERSanimationFrame][k] = v
	end
end

function ers_animationCycle(mWheel)
	if ERSanimationActive then
		if ers_IsOfficer() or not UnitInRaid("player") then
			if mWheel == 1 then
				if IsShiftKeyDown() then
					ERSanimationRate = ERSanimationRate + 1
					if ERSanimationRate > 10 then
						ERSanimationRate = 10
					end
					RaidWarningFrame:AddMessage("Animation Rate Set to "..ERSanimationRate.." Seconds")
				else
					ers_animationStoreFrame(true)
					ERSanimationFrame = ERSanimationFrame + 1
					ERSanimation:SetText(ERSanimationFrame)
					if ERSanimationSeq[ERSanimationFrame] then
						local checkForNew
						ers_animArrowAdjust()
						for checkForNew = 1,10 do
							if abs(ERSanimationSeq[ERSanimationFrame][checkForNew]) < 150 and abs(ERSanimationSeq[ERSanimationFrame][(checkForNew + 10)]) < 150 then
								ERScoord[checkForNew] = ERSanimationSeq[ERSanimationFrame][checkForNew]
								ERScoord[(checkForNew + 10)] = ERSanimationSeq[ERSanimationFrame][(checkForNew + 10)]
							else
								ERScoord[checkForNew] = ERSanimationSeq[(ERSanimationFrame -1)][checkForNew]
								ERScoord[(checkForNew + 10)] = ERSanimationSeq[(ERSanimationFrame -1)][(checkForNew + 10)]							
							end
							ERScoord[(checkForNew + 20)] = ERSanimationSeq[ERSanimationFrame][(checkForNew + 20)]
							ERScoord[(checkForNew + 30)] = ERSanimationSeq[ERSanimationFrame][(checkForNew + 30)]
							ERScoord[(checkForNew + 40)] = ERSanimationSeq[ERSanimationFrame][(checkForNew + 40)]
							ERScoord[(checkForNew + 50)] = ERSanimationSeq[ERSanimationFrame][(checkForNew + 50)]
						end
						ers_setSym(true)
					end
				end
			elseif mWheel == -1 then
				if IsShiftKeyDown() then
					ERSanimationRate = ERSanimationRate - 1
					if ERSanimationRate <  1 then
						ERSanimationRate = 1
					end
					RaidWarningFrame:AddMessage("Animation Rate Set to "..ERSanimationRate.." Seconds")
				else		
					ers_animationStoreFrame(true)
					ERSanimationFrame = ERSanimationFrame - 1
					if  ERSanimationFrame < 1 then
						ERSanimationFrame = 1
					end
					ERSanimation:SetText(ERSanimationFrame)
					
					if ERSanimationSeq[ERSanimationFrame] then
						local checkForNew
						 ers_animArrowAdjust()					
						for k,v in ERSanimationSeq[ERSanimationFrame] do
							ERScoord[k] = v
						end
						ers_setSym(true)
					end	
				end
			end
		else
			if mWheel == 1 then
				ERSanimationFrame = ERSanimationFrame + 1
				if ERSanimationFrame > ERSnumberAniFrames then
					ERSanimationFrame = ERSnumberAniFrames
				end
				ERSanimation:SetText(ERSanimationFrame)
			else
				ERSanimationFrame = ERSanimationFrame - 1
				if ERSanimationFrame < 1 then
					ERSanimationFrame = 1
				end
				ERSanimation:SetText(ERSanimationFrame)
			end
			ers_animArrowAdjust()
			for k,v in ERSanimationSeq[ERSanimationFrame] do
				ERScoord[k] =v
			end
			ers_setSym(true)
		end
	end
end

function ers_deleteAnimationFrame()
	local numAniFrames = table.getn(ERSanimationSeq)

	if ERSanimationFrame < numAniFrames and numAniFrames > 1 and ERSanimationFrame ~= numAniFrames then
		local shuffleAnim = 0
		for shuffleAnim = ERSanimationFrame, (numAniFrames -1) do
			ERSanimationSeq[shuffleAnim] = {}
			for k2,v2 in ERSanimationSeq[(shuffleAnim + 1)] do
				ERSanimationSeq[shuffleAnim][k2] = v2
			end
		end
	end

	if ERSanimationFrame == 1 and numAniFrames ==1  then
		ERSanimationSeq = {}
		ers_sendReset("LeftButton")
	else
		if ERSanimationFrame == numAniFrames then
			ERSanimationFrame = ERSanimationFrame - 1
			ERSanimation:SetText(ERSanimationFrame)
		end
		ERSanimationSeq[numAniFrames] = nil
		ERScoord = {}
		for k,v in ERSanimationSeq[ERSanimationFrame] do
			ERScoord[k] = v
		end
		ers_animArrowAdjust()
		ers_setSym(true)
	end

end
function ers_OnUpdate()
	if ERSsendingAnimation then
		if GetTime() > ERSlastSend + ERSanimationRate then
			if ERSanimationSeq[ERSanimationFrame] then
				ers_sendData()
				RaidWarningFrame:AddMessage("Sending Frame "..ERSanimationFrame)
				ERSanimationFrame = ERSanimationFrame + 1
			else
				ERSsendingAnimation = false
				SendAddonMessage("EXRS","Y", "RAID");
				ers_toggleButtonLock()
				ERSanimationFrame = 1
				ERScoord = {}
				ers_animArrowAdjust()			
				for k,v in ERSanimationSeq[ERSanimationFrame] do
					ERScoord[k] = v
				end
				ers_setSym(true)		
			end
		end
	end
	if ERSchecking then
		if GetTime() > ERSlastSend  + 5 then
			ers_verReport()
			ERSchecking = false
		end
	end
	if ERSanimationReplay then
		if ERSanimationFrame <= ERSnumberAniFrames then
			if GetTime() > ERSlastSend + ERSanimationRate then
				ERSlastSend = GetTime()
				ERScoord = {}
				ers_animArrowAdjust()	
				for k,v in ERSanimationSeq[ERSanimationFrame] do
					ERScoord[k] = v
				end
				ers_setSym(true)
				ERSanimationFrame = ERSanimationFrame + 1
			end
		else
			ERSanimationReplay = false	
			ERSanimation:Show()
			ERSanimation:SetText(ERSanimationFrame - 1)
		end	
	end
end

function ers_checkSysMsg(msg)
	if string.find(msg,"You are now AFK") then
		ERSisAFK = true
	elseif string.find(msg,"You are no longer AFK") then
		ERSisAFK = false
	elseif msg == "You have joined a raid group" then
		firstRaidshow = true
		if ExoRaidSetupMain:IsVisible() then
			ers_toggle()
		end
	elseif msg == "You have left the raid group" then
		if ExoRaidSetupMain:IsVisible() then
			ers_toggle()
		end	
	end
end

function ers_afkLogoutSend(whoToLog)
	SendAddonMessage("EXRS","A:"..whoToLog, "RAID");
	RaidWarningFrame:AddMessage("Logging Off "..whoToLog);
end

function ers_afkLogout(sentData)
	if ERSisAFK then
		local whoToLog = string.gsub(sentData,"A%:(%w+).*","%1")
		if UnitName("player") == whoToLog then
			Logout()
			StaticPopup1:ClearAllPoints()
			StaticPopup1:SetPoint("TOP","UIParent","TOP",0,100)
		end
	end
end

function ers_sendHideRaid()
	SendAddonMessage("EXRS","H", "RAID");
	RaidWarningFrame:AddMessage("Closing Raid Member Windows");
	ERSWindowsOpen = false
	ERShide:SetTextColor(.9,.5,0)
	ers_setTT("ERShide")
end

function ers_setTT(setThis)
	local whichTT
	if setThis then
		whichTT = setThis
	else
		whichTT = this:GetName()
	end
	GameTooltip:SetOwner(getglobal(whichTT), "ANCHOR_TOP");
	
	if whichTT == "ERShide" then
		if ers_IsOfficer() then
			if ERSWindowsOpen then
				GameTooltip:SetText("|cFF11F20FLeft-Click |r: Hide\n|cFF11F20FRight-Click |r: Hide Raid Member Windows\n|cFFFF9200--ALERT: Raid Member Windows Open--|r")
			else
				GameTooltip:SetText("|cFF11F20FLeft-Click |r: Hide\n|cFF11F20FRight-Click |r: Hide Raid Member Windows");
			end
		else
			GameTooltip:SetText("Click to Hide");
		end
	elseif whichTT == "ERSanimation" then
		if ERSanimationActive then
			if ers_IsOfficer() or not UnitInRaid("Player") then
				GameTooltip:SetText("|cFF11F20FLeft-Click|r: deactivate animation editing\n|cFF11F20FRight-Click|r: delete current animation frame\n|cFF11F20FMousewheel|r: set animation frame\n|cFF11F20FShift-Mousewheel|r: set time between frames (default 3 seconds)\n|cFFFF9200!!saves must be done while editing active!!|r");
			else
				GameTooltip:SetText("|cFF11F20FLeft-Click|r: Replay Animation\n|cFF11F20FMousewheel|r: move through frames\n")
			end
		else
			GameTooltip:SetText("|cFF11F20FLeft-Click|r: activate animation editing\n|cFF11F20FRight-Click|r: clear animation sequence info")
		end
	
	elseif whichTT == "ERStitle" then
		GameTooltip:SetText("|cFF11F20FLeft-Click|r: set title\n|cFF11F20FMousewheel|r: cycle backgrounds")
	elseif whichTT == "ERSload" then
		GameTooltip:SetText("|cFF11F20FLeft-Click:|r type in setup to load\n|cFF11F20FRight-Click:|r list saved setups");
	elseif whichTT == "ERSsave" then
		GameTooltip:SetText("|cFF11F20FLeft-Click:|r save current setup\n|cFF11F20FRight-Click:|r delete current setup (by title)");
	elseif whichTT == "ERSsendLeaders" then
		GameTooltip:SetText("Send current setup to raid leader and assistants",nil,nil,nil,nil,1);
	elseif whichTT == "ERSsendAll" then
		GameTooltip:SetText("|cFF11F20FLeft-Click:|r Send current setup to entire raid\n|cFF11F20FShift-Left-Click:|r send to warriors (and officers) only");
	elseif whichTT == "ERSreset" then
		GameTooltip:SetText("|cFF11F20FLeft-Click:|r resets symbol positions\n|cFF11F20FRight-Click:|r resets labels and positions");
	elseif whichTT == "ERSrestore" then
		GameTooltip:SetText("Restore setup overwritten by transmission or help info.",nil,nil,nil,nil,1);	
	elseif whichTT == "ERSarrowSelect" then
		GameTooltip:SetText("1)Use Mousewheel to select arrow.\n2)Click to create arrow.\n3)Drag arrow to window.")
	elseif whichTT == "ERSmmInfo" then
		if ERSmmMask == 0 then
			mmode = "Circular"
		else
			mmode = "Square"
		end
		GameTooltip:SetText("|cFF11F20FLeft-Click:|r toggle your minimap type\n|cFF11F20FMouseWheel:|r sets ERS minimap mode scale\n|cFFFF9200Current minimap mode: "..mmode.."|r");
	end	
	GameTooltip:Show();
end

function ers_slashHandler(slashArg)
	if slashArg and slashArg ~= "" and (not ERSsendingAnimation and not ERSrecievingAnimation) then
		if slashArg == "help" then
			ers_storeTemp()
			ers_sendReset("RightButton")
			ERSbackdropText:SetText("Help")
			ERSbackdrop:ClearAllPoints()
			ERSbackdrop:SetWidth(290)
			ERSbackdrop:SetHeight(290)
			ERSbackdrop:SetPoint("CENTER",ExoRaidSetupMain)
			ERSbackdrop:SetTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\ERSHELP")	
			ExoRaidSetupMainText:SetText("Click Restore to Resume")
		elseif slashArg =="check" then
			if ers_IsOfficer() then
				ers_checkVer()
			end
		elseif slashArg == "nag" then
			if ers_IsOfficer() then
				ers_updateNag()
			end
		elseif string.find(slashArg,"AFKlog") then
			if ers_IsOfficer() then
				local whoToLog = string.gsub(slashArg,"AFKlog%s(%w+).*","%1")
				ers_afkLogoutSend(whoToLog)
			end
		end
	else
		ers_toggle()
	end
end
function ers_toggle()
	if ExoRaidSetupMain:IsVisible() then
		if ers_IsOfficer() or not UnitInRaid("player") then
			ExoRaidSetupMain:Hide()
		else
			if not leaderBroadcast then
				ExoRaidSetupMain:Hide()
			end
		end
	else
		ExoRaidSetupMain:Show()
		ers_modeSet()
		if firstshow then
			ers_sendReset("RightClick")
			firstshow = false
		end
		if firstRaidshow then
			ers_getSymData()
			ers_setSym()
			firstRaidshow = false
			if ERSmmMask == 0 then
				ERSmmInfo:SetText("O")
			else
				ERSmmInfo:SetText("[ ]")
			end
		end
	end
end

function ers_toggleButtonLock()
	if ERSsendingAnimation or ERSrecievingAnimation then
		ERShide:Disable()
		ERSanimation:Disable()
		ERStitle:Disable()
		ERSload:Disable()
		ERSsave:Disable()
		ERSsendLeaders:Disable()
		ERSsendAll:Disable()
		ERSreset:Disable()
		ERSrestore:Disable()
		ERSarrowSelect:Disable()
		if ERSInputBox:IsVisible() then
			ERSInputBox:Hide()
		end
	else
		ERShide:Enable()
		ERSanimation:Enable()
		ERStitle:Enable()
		ERSload:Enable()
		ERSsave:Enable()
		ERSsendLeaders:Enable()
		ERSsendAll:Enable()
		ERSreset:Enable()
		ERSrestore:Enable()
		ERSarrowSelect:Enable()	
	end
end

function ers_modeSet()
	if ers_IsOfficer() or not UnitInRaid("player") then
		if not ERSsendLeaders:IsVisible() then
			ERSsendLeaders:Show()
			ERSsendAll:Show()
			ERSrestore:Show()
			ERStitle:Show()
			ERSreset:Show()
			ERSarrowSelect:Show()
			ERSanimation:Show()
		end
	else
		if ERSreset:IsVisible() then
			ERSanimation:Hide()
			ERStitle:Hide()
			if ERSsendLeaders:IsVisible() then
				ERSsendLeaders:Hide()
				ERSsendAll:Hide()
			end
			ERSrestore:Hide()
			ERSreset:Hide()
			ERSarrowSelect:Hide()
		end
	end
	if not UnitInRaid("player") then
		if ERSsendLeaders:IsVisible() then
			ERSsendLeaders:Hide()
			ERSsendAll:Hide()
		end
	end
end
function ers_setSymbolText(symtoset)
	local symTextFrame = getglobal("ERSsymbol"..symtoset.."Text")
	local symTextParentName = getglobal("ERSsymbol"..symtoset):GetName()
	local symTextPos = string.gsub(ERScoord[(symtoset + 20)],"^(%a%a).*","%1")
	
	symTextFrame:ClearAllPoints()
	
	if symTextPos == "TS" then
		symTextFrame:SetPoint("BOTTOM",symTextParentName,"TOP",0,2)
	elseif symTextPos == "TL" then
		symTextFrame:SetPoint("BOTTOMRIGHT",symTextParentName,"TOPLEFT",-2,0)
	elseif symTextPos == "LS" then
		symTextFrame:SetPoint("RIGHT",symTextParentName,"LEFT",-2,0)
	elseif symTextPos == "BL" then
		symTextFrame:SetPoint("TOPRIGHT",symTextParentName,"BOTTOMLEFT",-2,0)
	elseif symTextPos == "BS" then
		symTextFrame:SetPoint("TOP",symTextParentName,"BOTTOM",0,-2)
	elseif symTextPos == "BR" then
		symTextFrame:SetPoint("TOPLEFT",symTextParentName,"BOTTOMRIGHT",2,0)
	elseif symTextPos == "RS" then
		symTextFrame:SetPoint("LEFT",symTextParentName,"RIGHT",2,0)
	elseif symTextPos == "TR" then
		symTextFrame:SetPoint("BOTTOMLEFT",symTextParentName,"TOPRIGHT",2,0)
	end
end

function ers_symbolTextSelect(mWheel)
	if (ers_IsOfficer() or not UnitInRaid("player")) and (not ERSsendingAnimation and not ERSrecievingAnimation) then
		local symTextPos1 = {"TS","TL","LS","BL","BS","BR","RS","TR"}
		local symNum = string.gsub(this:GetName(),"%a+([%d%z]+)","%1") + 0
		local currTextPos = string.gsub(ERScoord[(symNum + 20)],"^(%a%a).*","%1")
		local symTextIndex
		for k,v in symTextPos1 do
			if currTextPos == v then
				symTextIndex = k
			end
		end
		if mWheel == 1 then
			symTextIndex = symTextIndex + 1
			if symTextIndex > 8 then
				symTextIndex = 1
			end
		elseif mWheel == -1 then
			symTextIndex = symTextIndex- 1
			if symTextIndex < 1 then
				symTextIndex = 8
			end
		end
		ERScoord[(symNum + 20)] = symTextPos1[symTextIndex]..string.gsub(ERScoord[(symNum + 20)],"%a%a(.*)","%1") 
		ers_setSymbolText(symNum)
	end
end

function ers_cycleBackground(mWheel)
	if ERSbackground == 228 and mWheel then
		ERSmmInfo:Hide()
		ers_mmToggle()
	end
	if mWheel == 1 then
		ERSbackground = ERSbackground + 1
		if ERSbackground > 79 then--Oldi
			ERSbackground = 1
		end
	elseif mWheel == -1 then
		ERSbackground = ERSbackground - 1
		if ERSbackground < 1 then
			ERSbackground = 79--Oldi
		end
	end
	if ERSbackground == 228 then
		ERSbackdrop:SetTexture(nil)
		ERSbackdropText:SetText(ERSbackgrounds[ERSbackground])
		ERSmmInfo:Show()
		local ers1X,ers1Y = ERSmmInfo:GetCenter()
		local uipX,uipY = UIParent:GetCenter()
		local dx = (ers1X - 10) - uipX
		local dy = (ers1Y - 10) - uipY
		TempSetup[109] = dx
		TempSetup[110] = dy
		ers_mmToggle()
		ers_mmScale()
	else
		ERSbackdropText:SetText(ERSbackgrounds[ERSbackground])
		ERSbackdrop:ClearAllPoints()
		ERSbackdrop:SetWidth(290)
		ERSbackdrop:SetHeight(290)
		ERSbackdrop:SetPoint("CENTER",ExoRaidSetupMain)
		ERSbackdrop:SetTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\ERB"..ERSbackground)
	end
end

function ers_arrowHandler(mWheel)
	if (not ERSsendingAnimation and not ERSrecievingAnimation) then
		if mWheel then
			if mWheel == 1 then
				ERSarrow = ERSarrow + 1
				if ERSarrow > 8 then
					ERSarrow = 1
				end
			elseif mWheel == -1 then
				ERSarrow = ERSarrow - 1
				if ERSarrow < 1 then
					ERSarrow = 8
				end
			end
			this:SetNormalTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\ERA"..ERSarrow)
		else
			if ERSnumVisArrows < 10 then
				ers_arrowCreate(false)
			else
				DEFAULT_CHAT_FRAME:AddMessage("Too many arrows created; please destroy one. (ALT-CLICK)")
			end
		end
	end
end

function ers_arrowCreate(makeBlank)
	local newArrow,newArrowTexture
	if ERSnumVisArrows < ERSnumArrows then
		ERSnumVisArrows = ERSnumVisArrows + 1
		newArrow = getglobal("ERSarrow"..ERSnumVisArrows)
		newArrowTexture = getglobal("ERSarrow"..ERSnumVisArrows.."Texture")
		newArrow:ClearAllPoints()
	else
		ERSnumArrows = ERSnumArrows + 1
		ERSnumVisArrows = ERSnumVisArrows + 1
		newArrow = CreateFrame("Frame", "ERSarrow"..ERSnumArrows, ExoRaidSetupMain, "ERSarrowTemplate")
		newArrow:SetFrameStrata("HIGH")
		newArrowTexture = getglobal("ERSarrow"..ERSnumArrows.."Texture")
		newArrow:SetMovable(true)		
	end
	if not makeBlank then
		newArrowTexture:SetTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\ERA"..ERSarrow)
		newArrowTexture:SetAllPoints(newArrow)
		newArrow.texture = "ERA"..ERSarrow
		newArrow:SetPoint("CENTER","ERSarrowSelect","CENTER",0,30)
		newArrow:Show()
		ERScoord[(ERSnumVisArrows + 30)] = -195
		ERScoord[(ERSnumVisArrows + 40)] = 30
		ERScoord[(ERSnumVisArrows + 50)] = newArrow.texture
	end
end

function ers_arrowRecycle(recycle)
	if recycle then
		local recycleArrow
		for recycleArrow = recycle, ERSnumVisArrows do
			ERSnumVisArrows = ERSnumVisArrows - 1
			ERScoord[(recycleArrow + 30)] = nil
			ERScoord[(recycleArrow + 40)] = nil
			ERScoord[(recycleArrow + 50)] = nil
			local whichArrow = getglobal("ERSarrow"..recycleArrow)
			whichArrow:ClearAllPoints()
			whichArrow:SetPoint("CENTER","ERSarrowSelect","CENTER",0,-30)
			whichArrow:Hide()
		end
	else
		local whichArrow
		whichArrow = string.gsub(this:GetName(),"%a+([%d%z]+)","%1") + 0
		if whichArrow < 10 and ERSnumVisArrows > 1 and whichArrow ~= ERSnumVisArrows then
				local shuffleArrows
				for shuffleArrows = whichArrow,(ERSnumVisArrows - 1) do
					ERScoord[(shuffleArrows + 30)] = ERScoord[(shuffleArrows + 31)]
					ERScoord[(shuffleArrows + 40)] = ERScoord[(shuffleArrows + 41)]
					ERScoord[(shuffleArrows + 50)] = ERScoord[(shuffleArrows + 51)]
					local thisArrow = getglobal("ERSarrow"..shuffleArrows)
					local thisArrowTexture = getglobal("ERSarrow"..shuffleArrows.."Texture")
					thisArrow:ClearAllPoints()
					thisArrow:SetPoint("CENTER","ExoRaidSetupMain","CENTER",ERScoord[(shuffleArrows + 30)],ERScoord[(shuffleArrows + 40)])
					thisArrowTexture:SetTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\"..ERScoord[(shuffleArrows + 50)])
					thisArrow.texture = ERScoord[(shuffleArrows + 50)]
					thisArrowTexture:SetAllPoints(thisArrow)
				end
		end
		ERScoord[(ERSnumVisArrows + 30)] = nil
		ERScoord[(ERSnumVisArrows + 40)] = nil
		ERScoord[(ERSnumVisArrows + 50)] = nil
	
		local clearArrowFrame = getglobal("ERSarrow"..ERSnumVisArrows)
		clearArrowFrame:ClearAllPoints()
		clearArrowFrame:SetPoint("CENTER","ERSarrowSelect","CENTER",0,-30)
		clearArrowFrame:Hide()	
		ERSnumVisArrows = ERSnumVisArrows - 1
	end
end

function ers_animArrowAdjust()
	local numVisArrows = 0
	local checkArrows
	for checkArrows = 31,40 do 
		if ERSanimationSeq[ERSanimationFrame][checkArrows] then
			numVisArrows = numVisArrows + 1
		else
			break
		end
	end
	ers_ArrowAdjust(numVisArrows)
end

function ers_ArrowAdjust(numVisArrows)
	if numVisArrows < ERSnumVisArrows then
		ers_arrowRecycle((numVisArrows + 1))
	elseif numVisArrows > ERSnumVisArrows then
		local createArrows
		for createArrows = (ERSnumVisArrows + 1), numVisArrows do
			ers_arrowCreate(true)
		end
	end	
end

function ers_IsOfficer()
	if IsRaidLeader() or IsRaidOfficer() then
		return true
	else
		return false
	end
end
function ers_sendData()
-- exrsData1 (R/L),backdrop:title;chunk1@chunk2$chunk3&
--                                       symbol |x values|y values| names |
--exrsData2 (S/M).numArrows*chunk4#chunk5^chunk6-
--         number of arrow |x values|y values|
	if ers_IsOfficer() then
		local setupName = ExoRaidSetupMainText:GetText()
		if setupName ~= "" and setupName ~= "Set Title Here" then
			if this:GetName() == "ERSsendLeaders" then
				targetAudience = "L"
				RaidWarningFrame:AddMessage("Setup Sent To Leaders")
			elseif this:GetName() == "ERSsendAll" then
				if IsShiftKeyDown() then
					targetAudience = "T"
					RaidWarningFrame:AddMessage("Setup Sent To Warriors")
					ERSWindowsOpen = true
					ERShide:SetTextColor(0,1,1)
				else
					targetAudience = "R"
					RaidWarningFrame:AddMessage("Setup Sent To Raid")
					ERSWindowsOpen = true
					ERShide:SetTextColor(0,1,1)
				end
			end
			if ERSanimationActive and not ERSsendingAnimation then
				ers_animationStoreFrame(true)	
				ERSsendingAnimation = true
				ERSanimationFrame = 1
				ERSlastSend = GetTime() - (ERSanimationRate + 1) --make first send instant
				ers_toggleButtonLock()
				SendAddonMessage("EXRS","X."..ERSanimationRate, "RAID");
				return
			elseif ERSanimationActive and ERSsendingAnimation then
				ers_animArrowAdjust()
				ERScoord = {}
				for k,v in ERSanimationSeq[ERSanimationFrame] do
					ERScoord[k] = v
				end
				ers_setSym(true)			
				if  ERSanimationSeq[(ERSanimationFrame + 1)] then
					ERSlastSend = GetTime()
				else
					ERSlastSend = GetTime() - (ERSanimationRate + 1) -- make last send reenable sooner
				end
			else
				ers_getSymData()
			end
			
			local exrsData1 = targetAudience..","..ERSbackground..":"..setupName..";"
			local getSymInfo,getArrInfo
			local exrsChunk1 = ""
			local exrsChunk2 = ""
			local exrsChunk3 = ""
			-- arrow data (part of second stream)
			local exrsChunk4 = ""
			local exrsChunk5 = ""
			local exrsChunk6 = ""
			
			for getSymInfo = 1,9 do
				exrsChunk1 = exrsChunk1..ERScoord[getSymInfo].."_"
				exrsChunk2 = exrsChunk2..ERScoord[(getSymInfo + 10)].."_"
				if ERScoord[(getSymInfo + 20)] == "" or not ERScoord[(getSymInfo + 20)] then
					exrsChunk3 = exrsChunk3.."usn".."_"
				else
					exrsChunk3 = exrsChunk3..ERScoord[(getSymInfo + 20)].."_"
				end
			end
			exrsChunk1 = exrsChunk1..ERScoord[10].."@"
			exrsChunk2 = exrsChunk2..ERScoord[20].."$"
			if ERScoord[30] == "" or not ERScoord[30] then
				exrsChunk3 = exrsChunk3.."usn".."&"
			else
				exrsChunk3 = exrsChunk3..ERScoord[30].."&"
			end		
			
			local exrsData2=""
			if targetAudience == "L" then
				exrsData2= exrsData2.."M."
			elseif targetAudience == "R" then
				exrsData2= exrsData2.."S."
			elseif targetAudience == "T" then
				exrsData2= exrsData2.."U."
			end
			
			if ERSnumVisArrows > 0 then
				for getArrInfo = 1,(ERSnumVisArrows -1) do
					exrsChunk4 = exrsChunk4..ERScoord[(getArrInfo + 30)].."_"
					exrsChunk5 = exrsChunk5..ERScoord[(getArrInfo + 40)].."_"
					exrsChunk6 = exrsChunk6..ERScoord[(getArrInfo + 50)].."_"
				end
				exrsChunk4 = exrsChunk4..ERScoord[(30 + ERSnumVisArrows)].."#"
				exrsChunk5 = exrsChunk5..ERScoord[(40 + ERSnumVisArrows)].."^"
				exrsChunk6 = exrsChunk6..ERScoord[(50 + ERSnumVisArrows)].."-"
				exrsData2 = exrsData2..ERSnumVisArrows.."*"..exrsChunk4..exrsChunk5..exrsChunk6
			else
				exrsData2 = exrsData2..ERSnumVisArrows.."*"
			end
			
			exrsData1 = exrsData1..exrsChunk1..exrsChunk2..exrsChunk3

			SendAddonMessage("EXRS",exrsData1, "RAID");
			SendAddonMessage("EXRS",exrsData2, "RAID");

		else
			DEFAULT_CHAT_FRAME:AddMessage("Please Set Title First (click above main window)")
		end
	end
end

function ers_recieveData(AddonId,sentData,pVariety,FromWhom)
-- arg1=prefix 
-- arg2 = message 
-- arg3 = distribution type ("PARTY","RAID","GUILD" or "BATTLEGROUND") 
-- arg4 = sender
	if FromWhom ~= UnitName("player") then
		if AddonId == "EXRS" then
			local firstChar = string.sub (sentData,1 , 1)
			if firstChar  == "L" or firstChar =="M" then
				if ers_IsOfficer() then
					if firstChar =="L"  then
						if not ERSrecievingAnimation then
							ers_storeTemp()
							RaidWarningFrame:AddMessage("Setup Recieved From "..FromWhom)
							if ERSanimationActive then
								ers_animationToggle("LeftButton")
							end							
						else
							RaidWarningFrame:AddMessage("Recieving Frame "..ERSanimationFrame.. "("..FromWhom..")")
						end
					end					
					if not ExoRaidSetupMain:IsVisible() then
						ers_toggle()
					end				
					ers_processData(sentData,firstChar)
				end
			elseif firstChar  == "R" or firstChar == "S" then
				if not ers_IsOfficer() then
					leaderBroadcast = true
					ERShide:Hide()
					if not ERSrecievingAnimation and ERSanimationActive then
						ERSanimationActive = false
						ERSanimation:Hide()
					end
				else
					if firstChar == "R" then
						if not ERSrecievingAnimation then
							RaidWarningFrame:AddMessage("Setup Recieved From "..FromWhom)
							ERSWindowsOpen = true
							ers_storeTemp()
							if ERSanimationActive then
								ers_animationToggle("LeftButton")
							end
						else
							RaidWarningFrame:AddMessage("Recieving Frame "..ERSanimationFrame.. "("..FromWhom..")")
						end
						ERShide:SetTextColor(0,1,1)						
					end
				end
				if not ExoRaidSetupMain:IsVisible() then
					ers_toggle()
				end				
				ers_processData(sentData,firstChar)
			elseif firstChar == "C" then
				ers_checkSendVer()
			elseif firstChar == "D" then
				ers_checkRecieveVer(sentData,FromWhom)
			elseif firstChar == "A" then
				ers_afkLogout(sentData)
			elseif firstChar =="X" then
				if ers_IsOfficer() then
					ers_storeTemp()
				end
				ERSanimationFrame = 1
				ERSanimationSeq = {}
				ERSrecievingAnimation = true
				ers_toggleButtonLock()
				ERSanimationRate = string.gsub(sentData,"%X%.([%d%z]+).*","%1") + 0
				
			elseif firstChar =="Y" then
				ERSrecievingAnimation = false
				ers_toggleButtonLock()
				if not ers_IsOfficer() then
					ERSanimationFrame = ERSanimationFrame - 1
					ERSnumberAniFrames = ERSanimationFrame
					ERSanimation:Show()
					ERSanimation:SetText(ERSanimationFrame)
					ERSanimation:SetTextColor(0,1,0)
					ERSanimationActive = true
				else
					ERSanimationFrame = ERSanimationFrame - 1
					if not ERSanimationActive then
						ers_animationToggle("LeftButton")
					end
				end
			elseif firstChar == "T" or firstChar =="U" then
				if UnitClass("player") == "Warrior" or ers_IsOfficer() then
					if not ers_IsOfficer()then
						leaderBroadcast = true
						ERShide:Hide()
					else
						if firstChar == "T" then
							RaidWarningFrame:AddMessage("Setup Recieved From "..FromWhom)
							ERSWindowsOpen = true
							ERShide:SetTextColor(0,1,1)
							ers_storeTemp()
						end
					end
					if not ExoRaidSetupMain:IsVisible() then
						ers_toggle()
					end	
					ers_processData(sentData,firstChar)
				end
			elseif firstChar == "H" then
				if not ers_IsOfficer() then
					if ERSanimation:IsVisible() then
						ERSanimation:Hide()
					end
					ExoRaidSetupMain:Hide()
					ERShide:Show()
					leaderBroadcast = false
					if ERSanimationActive then
						ERSanimationActive = false
						ERSanimation:SetText("#")
						ERSanimation:SetTextColor(.5,.5,.5)
					end
				else
					RaidWarningFrame:AddMessage("Raid Member Windows Closed ("..FromWhom..")")
					ERSWindowsOpen = false
					ERShide:SetTextColor(.9,.5,0)
				end
			end
		end
	end
end

function ers_processData(symData,targAudience)
-- exrsData1 (R/L),backdrop:title;chunk1@chunk2$chunk3&
--                                       symbol |x values|y values| names |
---exrsData2 (S/M).numArrows*chunk4#chunk5^chunk6-
--      			arrow |x values|y values| textures
	if targAudience == "L" or targAudience == "R" or targAudience == "T" then
		if ERSbackground == 228 then
			ERSmmInfo:Hide()
			ers_mmToggle()
		end	
		ERSbackground = string.gsub(symData,".*%,([%d%z]+)%:.*","%1") + 0
		local exrsTitle = string.gsub(symData,".*%:([%<%s%w%>]+)%;.*","%1")
		local exrsChunk1 = string.gsub(symData,".*%;(.*)%@.*","%1")
		local exrsChunk2 = string.gsub(symData,".*%@(.*)%$.*","%1")
		local exrsChunk3 = string.gsub(symData,".*%$(.*)%&.*","%1")
		
		ExoRaidSetupMainText:SetText(exrsTitle)
		ers_cycleBackground()
		
		local symIndex = 0
		-- x values
		for c in string.gfind (exrsChunk1,"[%-%w]+") do
			symIndex = symIndex + 1
			ERScoord[symIndex] = c + 0
		end
		--y values
		for c in string.gfind (exrsChunk2,"[%-%w]+") do
			symIndex = symIndex + 1
			ERScoord[symIndex] = c + 0
		end	
		--names
		for c in string.gfind (exrsChunk3,"[^%_]+") do
			symIndex = symIndex + 1
			if c == "usn" then
				ERScoord[symIndex] = ""
			else
				ERScoord[symIndex] = c
			end
		end
	else
		local numSentArrows = string.gsub(symData,"%w%.([%d%z]+)%*.*","%1") + 0
		
		ers_ArrowAdjust(numSentArrows)
		
		if numSentArrows > 0 then
			local exrsChunk4 = string.gsub(symData,".*%*(.*)%#.*","%1")
			local exrsChunk5 = string.gsub(symData,".*%#(.*)%^.*","%1")
			local exrsChunk6 = string.gsub(symData,".*%^(.*)%-.*","%1")
			local arrIndex = 30
			--x values
			for c in string.gfind (exrsChunk4,"[%-%w]+") do
				arrIndex = arrIndex + 1
				ERScoord[arrIndex] = c + 0
			end		
			--y values
			arrIndex = 40
			for c in string.gfind (exrsChunk5,"[%-%w]+") do
				arrIndex = arrIndex + 1
				ERScoord[arrIndex] = c + 0
			end
			--textures
			arrIndex = 50
			for c in string.gfind (exrsChunk6,"(%w+)") do
				arrIndex = arrIndex + 1
				ERScoord[arrIndex] = c
			end
		end
		PlaySound("RaidWarning")
		if ERSrecievingAnimation then
			ers_animationStoreFrame(false)
			ERSanimation:SetText(ERSanimationFrame)
			ERSanimationFrame = ERSanimationFrame + 1
		end
		ers_setSym(true)
	end
end


function ers_checkSendVer()
	SendAddonMessage("EXRS","D:"..ERSver, "RAID")
end

function ers_checkRecieveVer(sentData,FromWhom)
	if  ERSchecking then
		ERScheckRaid[FromWhom] = string.gsub(sentData,"%w%:(%d%.%d+)","%1")
	end
end

function ers_checkVer()
	if ExoRaidSetupMain:IsVisible() then
		local ri  --raid index 
		ERScheckRaid = {}
		for ri = 1,GetNumRaidMembers() do
			ERScheckRaid[UnitName("raid"..ri)] = "Not Installed."
		end
		ERSchecking = true
		SendAddonMessage("EXRS","C", "RAID")
		RaidWarningFrame:AddMessage("Checking raid ...")
		ERSlastSend = GetTime()
	else
		DEFAULT_CHAT_FRAME:AddMessage("Please show window to preform a check")
	end
end

function ers_verReport()
	for k,v in ERScheckRaid do
		if v ~= ERSver and k ~= UnitName("player") then
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFEB00"..k.."|r: |cFFFF6B00"..v.."|r")
		end
	end
end

function ers_updateNag()
	local whispLang
	if UnitFactionGroup("player") == "Alliance" then
		whispLang = "common";
	else
		whispLang = "orcish";
	end
	for k,v in ERScheckRaid do
		if v ~= ERSver and k ~= UnitName("player") then
			if v~= "Not Installed (or pre 1.29)" then
				SendChatMessage("Please upgrade your version of ExoRaidSetup to "..ERSver,"WHISPER",whispLang,k)
			else
				SendChatMessage("Please download and install ExoRaidSetup v"..ERSver,"WHISPER",whispLang,k)
			end
		end
	end
end

function ers_storeTemp()
	if not TempSetup[100] then
		TempSetup[120] = ERSnumVisArrows
		if ERSanimationActive then
			if not ERSanimationSeq[ERSanimationFrame] then
				ers_animationStoreFrame(true)
			end
			TempSetup[85] = true
			TempSetup[86] = {}
			local numAnimFrames = 0
			for k,_ in ERSanimationSeq do
				numAnimFrames = numAnimFrames + 1
				TempSetup[86][k] = {}
				for k2,v2 in ERSanimationSeq[k] do
					TempSetup[86][k][k2] = v2
				end
			end
			TempSetup[87] = numAnimFrames
			ers_animationToggle("LeftButton")
		else
			ers_getSymData()
			local storetemp
			for storetemp = 1,10 do
				TempSetup[storetemp] = ERScoord[storetemp]										--symbol x coord
				TempSetup[(storetemp + 10)] = ERScoord[(storetemp + 10)]								--symbol y coord
				TempSetup[(storetemp + 20)] = ERScoord[(storetemp + 20)]								--symbol labels
				if storetemp <= ERSnumVisArrows then					
					TempSetup[(storetemp + 30)] = ERScoord[(storetemp + 30)]							--arrow x coord
					TempSetup[(storetemp + 40)] = ERScoord[(storetemp + 40)]							--arrow y coord
					TempSetup[(storetemp + 50)] = ERScoord[(storetemp + 50)]							--arrow textures
				end
			end	
		end
		TempSetup[75] = ERSbackground
		TempSetup[99] = ExoRaidSetupMainText:GetText()
		TempSetup[100] = true
	end	
end

function ers_GetInput()
	local InputText = this:GetText()
	if string.find(InputText,"[^%s%w%<%>]+") then
		DEFAULT_CHAT_FRAME:AddMessage("Please use only numbers and letters to define.")
	else
		this:SetText("")
		this:Hide()
		if InputText ~= "" then 
			if ERSInputRequestor == "ERStitle" then
					ExoRaidSetupMainText:Show()
					ExoRaidSetupMainText:SetText(InputText)
			elseif ERSInputRequestor == "ERSload" then
				ers_LoadSetup(InputText)
			else
				getglobal(ERSInputRequestor.."Text"):SetText(InputText)
				getglobal(ERSInputRequestor.."Text"):Show()				
			end
		end
	end
end

function ers_autoComplete()
	if ERSInputRequestor == "ERSload" then
		local findSetup = "^";
		findthis = "^"..ERSInputBox:GetText();
		local matchingSetup = {};
		matchingSetup[1] = "";
		matchingSetup[2] = 0;
		for k,_ in ExoRaidSetupz do
			if string.find(k,findthis) then
				matchingSetup[1] = k;
				matchingSetup[2] = matchingSetup[2] + 1;
			end
		end
		if matchingSetup[2] == 1 then
			ERSInputBox:SetText(matchingSetup[1])
		end
	end
end

function ers_hideEdit()
	this:Hide()
	if ERSInputRequestor == "ERStitle" then
		ExoRaidSetupMainText:Show()		
	elseif ERSInputRequestor == "ERSload" then
		--do nothing
	else
		getglobal(ERSInputRequestor.."Text"):Show()				
	end
end

function ers_setTitle()
	ERSInputRequestor = this:GetName()
	ERSInputBox:ClearAllPoints()
	ERSInputBox:Show()
	ERSInputBox:SetPoint("CENTER",ExoRaidSetupMain,"CENTER",0,130)
	ExoRaidSetupMainText:Hide()
end

function ers_load(click)
	if click == "LeftButton" then
		ERSInputRequestor = this:GetName()
		ERSInputBox:ClearAllPoints()
		ERSInputBox:Show()
		ERSInputBox:SetPoint("CENTER",ERSInputRequestor,"CENTER",0,-15)
	else
		if ExoRaidSetupz then
			DEFAULT_CHAT_FRAME:AddMessage("Saved Setups:")
			for k,v in ExoRaidSetupz do
				DEFAULT_CHAT_FRAME:AddMessage(k)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("No Saved Setups Found.")
		end
	end
end

function ers_LoadSetup(whichsetup)
	local setupfound = false
	for k,v in ExoRaidSetupz do
		if k == whichsetup then
			setupfound = true
			local restoresym
			if string.find(whichsetup,"%<animation%>") then
				ERSanimationSeq = {}
				ERSanimationRate = ExoRaidSetupz[whichsetup][79]
				local numSavedFrames = 0
				for k2,_ in ExoRaidSetupz[whichsetup][80] do
					numSavedFrames = numSavedFrames + 1
					ERSanimationSeq[k2] = {}
					for k3,v3 in ExoRaidSetupz[whichsetup][80][k2] do
						ERSanimationSeq[k2][k3] = v3
						if k2 == 1 then
							ERScoord[k3] = v3
						end
					end
				end
				ERSnumberAniFrames = numSavedFrames
				ERSanimationFrame = 1
				ers_animArrowAdjust()
				ExoRaidSetupMainText:SetText(string.gsub(whichsetup,"^(%w+)%<.*","%1"))
				if ers_IsOfficer() or not UnitInRaid("player") then
					if not ERSanimationActive then
						ers_animationToggle("LeftButton")
					end
				else
					ERSanimationActive = true
					ERSanimation:Show()
					ERSanimation:SetText(ERSanimationFrame)
					ERSanimation:SetTextColor(0,1,0)					
				end
			else
				if ERSanimationActive then
					ers_animationToggle("LeftButton")
				end
				ExoRaidSetupMainText:SetText(whichsetup)
				
				ers_ArrowAdjust(ExoRaidSetupz[whichsetup][65])

				for restoresym = 1,10 do
					ERScoord[restoresym] = ExoRaidSetupz[whichsetup][restoresym]
					ERScoord[(restoresym + 10)] = ExoRaidSetupz[whichsetup][(restoresym + 10)]
					ERScoord[(restoresym + 20)] = ExoRaidSetupz[whichsetup][(restoresym + 20)]
					if restoresym <= ExoRaidSetupz[whichsetup][65] then
						ERScoord[(restoresym + 30)] = ExoRaidSetupz[whichsetup][(restoresym + 30)]
						ERScoord[(restoresym + 40)] = ExoRaidSetupz[whichsetup][(restoresym + 40)]
						ERScoord[(restoresym + 50)] = ExoRaidSetupz[whichsetup][(restoresym + 50)]
					end
				end
			end
			if ERSbackground == 228 then
				ERSmmInfo:Hide()
				ers_mmToggle()
			end			
			ERSbackground = ExoRaidSetupz[whichsetup][75]		
			ers_cycleBackground()
			break;
		end
	end
	if not setupfound then
		DEFAULT_CHAT_FRAME:AddMessage("Setup Not Found")
	else 
		ers_setSym(true)
	end
end

function ers_save(click)
	local setupname = ExoRaidSetupMainText:GetText()
	if click == "LeftButton" then
		if setupname then
			if setupname ~= "" and setupname ~= "Set Title Here" then
				if not ExoRaidSetupz then
					ExoRaidSetupz = {}
				end
				if ERSanimationActive then
					ers_animationStoreFrame(true)
					setupname = setupname.."<animation>"
					ExoRaidSetupz[setupname] = {}
					ExoRaidSetupz[setupname][80] = {}
					for k,_ in ERSanimationSeq do
						ExoRaidSetupz[setupname][80][k] = {}
						for k2,v2 in  ERSanimationSeq[k] do
							ExoRaidSetupz[setupname][80][k][k2] = v2
						end
					end
					ExoRaidSetupz[setupname][79] = ERSanimationRate
				else
					ExoRaidSetupz[setupname] = {}
					ers_getSymData()
					local getsyminfo
					for getsyminfo = 1,10 do
						ExoRaidSetupz[setupname][getsyminfo] = ERScoord[getsyminfo]
						ExoRaidSetupz[setupname][(getsyminfo + 10)] = ERScoord[(getsyminfo+10)]
						ExoRaidSetupz[setupname][(getsyminfo + 20)] = ERScoord[(getsyminfo+20)]
						if getsyminfo <= ERSnumVisArrows then
							ExoRaidSetupz[setupname][(getsyminfo + 30)] = ERScoord[(getsyminfo + 30)]
							ExoRaidSetupz[setupname][(getsyminfo + 40)] = ERScoord[(getsyminfo + 40)]
							ExoRaidSetupz[setupname][(getsyminfo + 50)] = ERScoord[(getsyminfo + 50)]
						end
					end
					
					ExoRaidSetupz[setupname][65] = ERSnumVisArrows
				end
				ExoRaidSetupz[setupname][75] = ERSbackground
				RaidWarningFrame:AddMessage(setupname.." Saved")
			else
				if ers_IsOfficer() or not UnitInRaid("player") then
					DEFAULT_CHAT_FRAME:AddMessage("Please Create a Title Before Saving.")
				else
					DEFAULT_CHAT_FRAME:AddMessage("Nothing to Save.")
				end
			end
		end
	else
		if ExoRaidSetupz[setupname] then
			ExoRaidSetupz[setupname] = nil
			DEFAULT_CHAT_FRAME:AddMessage("Setup named '"..setupname.."' deleted.")
		elseif ExoRaidSetupz[setupname.."<animation>"] then
			ExoRaidSetupz[setupname.."<animation>"] = nil
			DEFAULT_CHAT_FRAME:AddMessage("Setup named '"..setupname.."<animation>' deleted.")
		else
			DEFAULT_CHAT_FRAME:AddMessage("'"..setupname.."' is not a saved setup.")
		end
	end
end

function ers_sendRestore()
	if TempSetup[100] then
		ers_ArrowAdjust(TempSetup[120])
		if TempSetup[1] then
			local restoretemp
			for restoretemp = 1,10 do
				ERScoord[restoretemp] = TempSetup[restoretemp]
				ERScoord[(restoretemp + 10)] = TempSetup[(restoretemp + 10)]
				ERScoord[(restoretemp + 20)] = TempSetup[(restoretemp + 20)]
				
				if restoretemp <= ERSnumVisArrows then				
					ERScoord[(restoretemp + 30)] = TempSetup[(restoretemp + 30)]
					ERScoord[(restoretemp + 40)] =TempSetup[(restoretemp + 40)]
					ERScoord[(restoretemp + 50)] =TempSetup[(restoretemp + 50)]
				end
			end
			if ERSanimationActive then
				ers_animationToggle("LeftButton")
			end
		elseif TempSetup[85] then
			TempSetup[85] = false
			ERSanimationSeq = {}
			for k,_ in TempSetup[86] do
				ERSanimationSeq[k] = {}
				for k2,v2 in TempSetup[86][k] do
					ERSanimationSeq[k][k2] = v2
				end
			end	
			ERSanimationFrame = TempSetup[87]	
			for k3,v3 in ERSanimationSeq[ERSanimationFrame] do
				ERScoord[k3] = v3
			end
			if not ERSanimationActive then
				ers_animationToggle("LeftButton")
			end
		end
		if ERSbackground == 228 then
			ERSmmInfo:Hide()
			ers_mmToggle()
		end	
		ERSbackground = TempSetup[75]	
		ers_cycleBackground()
		ExoRaidSetupMainText:SetText(TempSetup[99])
		TempSetup[100] = false
	end
	ers_setSym(true)
end

function ers_sendReset(click)
	if click == "RightButton" then
		local symnum
		for symnum = 1,10 do
			ERScoord[(symnum + 20)] = "BS"
		end
		ers_arrowRecycle(1)
		ExoRaidSetupMainText:SetText("Set Title Here");
	else
		if ERSnumVisArrows > 0 then
			local ArrIndex
			local ArrYvals = {120,60,0,-60,-120,120,60,0,-60,-120}
			for ArrIndex = 1,ERSnumVisArrows do
				if ArrIndex > 5 then
					ERScoord[(ArrIndex+ 30)] = 205
				else
					ERScoord[(ArrIndex+ 30)] = 190
				end	
				ERScoord[(ArrIndex+ 40)] = ArrYvals[ArrIndex]
			end
		end
	end
	
	local SymIndex
	local SymYvals = {120,60,0,-60,-120}
	
	for SymIndex = 1,5 do
		ERScoord[SymIndex] = -170
		ERScoord[(SymIndex + 10)] = SymYvals[SymIndex]
		ERScoord[(SymIndex+5)] = 170
		ERScoord[(SymIndex + 15)] = SymYvals[SymIndex]
	end

	ers_setSym(true)
	
end

function ers_getSymData(whichsym)
	local mainX , mainY = ExoRaidSetupMain:GetCenter()
	if whichsym then
		local symindex = string.gsub(whichsym,"%a+([%d%z]+)","%1") + 0
		local whichFrame = getglobal(whichsym)
		local SymhasText = getglobal("ERSsymbol"..symindex.."Text"):GetText()
		local symX , symY = whichFrame:GetCenter()
		local deltaX = ers_roundCoord(symX - mainX)
		local deltaY = ers_roundCoord(symY - mainY)
		if string.find(whichsym,"symbol") then
			ERScoord[symindex] = deltaX
			ERScoord[(symindex + 10)] = deltaY
			if SymhasText then
				ERScoord[(symindex + 20)] = string.gsub(ERScoord[(symindex + 20)],"^(%a%a).*","%1")..SymhasText
			end
		else
			ERScoord[(symindex + 30)] = deltaX
			ERScoord[(symindex + 40)] = deltaY
			ERScoord[(symindex + 50)] = whichFrame.texture
		end
		whichFrame:ClearAllPoints()
		whichFrame:SetPoint("CENTER","ExoRaidSetupMain","CENTER",deltaX,deltaY)
	else
		local symnum = 0
		for symnum = 1,10 do
			local symX,symY = getglobal("ERSsymbol"..symnum):GetCenter()
			local SymhasText = getglobal("ERSsymbol"..symnum.."Text"):GetText()
			ERScoord[symnum] = ers_roundCoord(symX - mainX)
			ERScoord[(symnum + 10)] = ers_roundCoord(symY - mainY)
			if SymhasText then
				ERScoord[(symnum + 20)] = string.gsub(ERScoord[(symnum + 20)],"^(%a%a).*","%1")..SymhasText
			end
			if symnum <= ERSnumVisArrows then
				local whichArrow = getglobal("ERSarrow"..symnum)
				local asymX,asymY = whichArrow:GetCenter()
				ERScoord[(symnum + 30)] = ers_roundCoord(asymX - mainX)
				ERScoord[(symnum + 40)] = ers_roundCoord(asymY - mainY)
				ERScoord[(symnum + 50)] = whichArrow.texture
			end
		end
	end
end

function ers_roundCoord(coord)
	local coordUp,coordDown
	coordUp = ceil(coord)
	coordDown = floor(coord)
	if abs(coord - coordUp) < abs(coord - coordDown) then
		coord = coordUp
	else
		coord = coordDown
	end
	return coord
end
function ers_setSym(doFull)
	local symnum = 0
	for symnum = 1,10 do
		local whichsym = getglobal("ERSsymbol"..symnum)
		if not ers_IsOfficer() and UnitInRaid("player") then
			if abs(ERScoord[symnum]) < 150 and abs(ERScoord[(symnum + 10)]) < 150 then
				if not whichsym:IsVisible() then
					whichsym:Show()
				end
				whichsym:ClearAllPoints()
				whichsym:SetPoint("CENTER","ExoRaidSetupMain","CENTER",ERScoord[symnum],ERScoord[(symnum + 10)])
				if doFull then
					getglobal("ERSsymbol"..symnum.."Text"):SetText(string.gsub(ERScoord[(symnum + 20)],"%a%a(.*)","%1"))
					ers_setSymbolText(symnum)
				end
			else
				whichsym:ClearAllPoints()
				whichsym:SetPoint("CENTER","ExoRaidSetupMain","CENTER",ERScoord[symnum],ERScoord[(symnum + 10)])			
				if whichsym:IsVisible() then
					whichsym:Hide()
				end
			end
		else
			if not whichsym:IsVisible() then
				whichsym:Show()
			end		
			whichsym:ClearAllPoints()
			whichsym:SetPoint("CENTER","ExoRaidSetupMain","CENTER",ERScoord[symnum],ERScoord[(symnum + 10)])
			if doFull then
				getglobal("ERSsymbol"..symnum.."Text"):SetText(string.gsub(ERScoord[(symnum + 20)],"%a%a(.*)","%1"))
				ers_setSymbolText(symnum)
			end
		end
		local whicharrow = getglobal("ERSarrow"..symnum)
		if symnum <= ERSnumVisArrows  then
			whicharrow:ClearAllPoints()
			whicharrow:SetPoint("CENTER","ExoRaidSetupMain","CENTER",ERScoord[(symnum + 30)],ERScoord[(symnum + 40)])
			if doFull then
				local whichArrowTexture = getglobal("ERSarrow"..symnum.."Texture")
				whichArrowTexture:SetTexture("Interface\\Addons\\ExoRaidSetup\\ERSart\\"..ERScoord[(symnum + 50)])
				whichArrowTexture:SetAllPoints(whicharrow)
				whicharrow.texture = ERScoord[(symnum + 50)]
				if not whicharrow:IsVisible() then
					whicharrow:Show()
				end
			end
		else
			if whicharrow then
				if whicharrow:IsVisible() then
					whicharrow:Hide()
				end
			end
		end
	end
end

function ers_MouseDown()
	if (ers_IsOfficer() or not UnitInRaid("player")) and (not ERSsendingAnimation and not ERSrecievingAnimation) then
		if IsShiftKeyDown() and not string.find(this:GetName(),"arrow") then
			ERSInputRequestor = this:GetName()
			if ERSInputRequestor ~= "ERSload" then
				getglobal(ERSInputRequestor.."Text"):Hide()				
			end
			ERSInputBox:ClearAllPoints()
			ERSInputBox:Show()
			ERSInputBox:SetPoint("CENTER",ERSInputRequestor,"CENTER",0,-15)						
		else
			ers_OnDragStart();
		end
	end
end

function ers_OnDragStart()
	if (not ERSsendingAnimation and not ERSrecievingAnimation) then
		if this:GetName() == "ExoRaidSetupMain" then
			if IsShiftKeyDown() then
				ers_getSymData() 
				ers_StartMoving()
			end
		else 
			ers_StartMoving()
		end
	end
end

function ers_StartMoving()
		if ( ( ( not this.isLocked ) or ( this.isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then
			this:StartMoving();
			this.isMoving = true;
		end 
end

function ers_OnDragStop()
	if ( this.isMoving ) then
		this:StopMovingOrSizing();
		this.isMoving = false; 
		if this:GetName() == "ExoRaidSetupMain" then
			ers_setSym()
		else
			local symtostore = this:GetName()
			ers_getSymData(symtostore)
		end
	end
end
