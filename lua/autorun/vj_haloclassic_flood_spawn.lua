/*--------------------------------------------------
	=============== Autorun File ===============
	*** Copyright (c) 2012-2020 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
------------------ Addon Information ------------------
local PublicAddonName = "Halo Classic Flood SNPCs"
local AddonName = "Halo Classic Flood"
local AddonType = "SNPC"
local AutorunFile = "autorun/vj_haloclassic_flood_spawn.lua"
-------------------------------------------------------
local VJExists = file.Exists("lua/autorun/vj_base_autorun.lua","GAME")
if VJExists == true then
	include('autorun/vj_controls.lua')

	VJ.AddConVar("vj_hcf_human_hp",100)
	VJ.AddConVar("vj_hcf_human_dmg",20)
	VJ.AddConVar("vj_hcf_carrier_hp",50)
	VJ.AddConVar("vj_hcf_carrier_dmg",80)
	VJ.AddConVar("vj_hcf_infection_hp",60)
	VJ.AddConVar("vj_hcf_infection_dmg",3)
	VJ.AddConVar("vj_hcf_elite_hp",200)
	VJ.AddConVar("vj_hcf_elite_dmg",16)

	local vCat = "Halo 1 Flood"
	VJ.AddCategoryInfo(vCat,{Icon = "vj_icons/halo1_flood.png"})
	VJ.AddNPC("Flood Combat Form","npc_vj_hcf_human",vCat)
	VJ.AddNPC("Flood Carrier Form","npc_vj_hcf_carrier",vCat)
	VJ.AddNPC("Flood Infection Form","npc_vj_hcf_infection",vCat)
	VJ.AddNPC("Flood Combat Sangheili Form","npc_vj_hcf_elite",vCat)

	local vCat = "Halo 2 Flood"
	VJ.AddCategoryInfo(vCat,{Icon = "vj_icons/halo2_flood.png"})
	VJ.AddNPC("Flood Combat Form","npc_vj_hcf_human2",vCat)
	VJ.AddNPC("Flood Infection Form","npc_vj_hcf_infection2",vCat)
	VJ.AddNPC("Flood Combat Sangheili Form","npc_vj_hcf_elite2",vCat)
	VJ.AddNPC("Flood Juggernaut Form","npc_vj_hcf_juggernaut",vCat)

	game.AddParticles("particles/cpt_flood_spores.pcf")
	/*
		cpt_flood_spore
		cpt_flood_sporegas
		cpt_flood_sporeimpact
		cpt_flood_sporeparticles
	*/
	
-- !!!!!! DON'T TOUCH ANYTHING BELOW THIS !!!!!! -------------------------------------------------------------------------------------------------------------------------
	AddCSLuaFile(AutorunFile)
	VJ.AddAddonProperty(AddonName,AddonType)
else
	if (CLIENT) then
		chat.AddText(Color(0,200,200),PublicAddonName,
		Color(0,255,0)," was unable to install, you are missing ",
		Color(255,100,0),"VJ Base!")
	end
	timer.Simple(1,function()
		if not VJF then
			if (CLIENT) then
				VJF = vgui.Create("DFrame")
				VJF:SetTitle("ERROR!")
				VJF:SetSize(790,560)
				VJF:SetPos((ScrW()-VJF:GetWide())/2,(ScrH()-VJF:GetTall())/2)
				VJF:MakePopup()
				VJF.Paint = function()
					draw.RoundedBox(8,0,0,VJF:GetWide(),VJF:GetTall(),Color(200,0,0,150))
				end
				
				local VJURL = vgui.Create("DHTML",VJF)
				VJURL:SetPos(VJF:GetWide()*0.005, VJF:GetTall()*0.03)
				VJURL:Dock(FILL)
				VJURL:SetAllowLua(true)
				VJURL:OpenURL("https://sites.google.com/site/vrejgaming/vjbasemissing")
			elseif (SERVER) then
				timer.Create("VJBASEMissing",5,0,function() print("VJ Base is Missing! Download it from the workshop!") end)
			end
		end
	end)
end