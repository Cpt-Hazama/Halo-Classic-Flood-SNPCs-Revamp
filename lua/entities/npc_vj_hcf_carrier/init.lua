AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/cpthazama/halo_classic/flood_carrier_ce.mdl" -- Leave empty if using more than one model
ENT.StartHealth = GetConVarNumber("vj_hcf_carrier_hp")
ENT.EntitiesToNoCollide = {"npc_vj_flood_infection","npc_vj_hcf_infection"}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.CustomBlood_Particle = {"cpt_blood_flood"}

ENT.MeleeAttackDistance = 125 -- How close does it have to be until it attacks?
ENT.AttackProps = false -- Should it attack props when trying to move?
ENT.MeleeAttackDamageDistance = 105
ENT.MeleeAttackDamage = GetConVarNumber("vj_hcf_carrier_dmg")
ENT.AnimTbl_MeleeAttack = {ACT_MELEE_ATTACK1}
ENT.TimeUntilMeleeAttackDamage = false
ENT.MeleeAttackDamageType = DMG_SLASH

ENT.DisableFootStepSoundTimer = true

ENT.HasLeapAttack = true -- Should the SNPC have a leap attack?
ENT.AnimTbl_LeapAttack = {ACT_GLIDE} -- Melee Attack Animations
ENT.LeapAttackAnimationFaceEnemy = true
ENT.LeapDistance = 600 -- The distance of the leap, for example if it is set to 500, when the SNPC is 500 Unit away, it will jump
ENT.LeapToMeleeDistance = 400 -- How close does it have to be until it uses melee?
ENT.TimeUntilLeapAttackDamage = 0.1 -- How much time until it runs the leap damage code?
ENT.NextLeapAttackTime_DoRand = 10
ENT.NextLeapAttackTime = 5 -- How much time until it can use a leap attack?
ENT.NextAnyAttackTime_Leap = 0.1 -- How much time until it can use a attack again? | Counted in Seconds
ENT.LeapAttackVelocityForward = 15 -- How much forward force should it apply?
ENT.LeapAttackVelocityUp = 400 -- How much upward force should it apply?
ENT.LeapAttackDamage = 65
ENT.LeapAttackDamageDistance = 50 -- How far does the damage go?

ENT.SoundTbl_FootStep = {
	"vj_floodclassic/carrier/carrier_walk1.mp3",
	"vj_floodclassic/carrier/carrier_walk2.mp3",
	"vj_floodclassic/carrier/carrier_walk3.mp3",
	"vj_floodclassic/carrier/carrier_walk4.mp3",
	"vj_floodclassic/carrier/carrier_walk5.mp3",
	"vj_floodclassic/carrier/carrier_walk6.mp3",
	"vj_floodclassic/carrier/carrier_walk7.mp3",
	"vj_floodclassic/carrier/carrier_walk8.mp3",
	"vj_floodclassic/carrier/carrier_walk9.mp3",
	"vj_floodclassic/carrier/carrier_walk10.mp3",
}
ENT.SoundTbl_Idle = {
	"vj_floodclassic/carrier/idle1_1.mp3",
	"vj_floodclassic/carrier/idle1_2.mp3",
	"vj_floodclassic/carrier/idle1_3.mp3",
	"vj_floodclassic/carrier/idle1_4.mp3",
	"vj_floodclassic/carrier/idle1_5.mp3",
	"vj_floodclassic/carrier/idle2_1.mp3",
	"vj_floodclassic/carrier/idle2_2.mp3",
	"vj_floodclassic/carrier/idle2_3.mp3",
	"vj_floodclassic/carrier/idle2_4.mp3",
	"vj_floodclassic/carrier/idle2_5.mp3",
}
ENT.SoundTbl_CombatIdle = {
	"vj_floodclassic/carrier/carsnd24_1.mp3",
	"vj_floodclassic/carrier/carsnd24_2.mp3",
	"vj_floodclassic/carrier/carsnd24_3.mp3",
	"vj_floodclassic/carrier/carsnd24_4.mp3",
	"vj_floodclassic/carrier/carsnd24_5.mp3",
	"vj_floodclassic/carrier/carsnd24_6.mp3",
	"vj_floodclassic/carrier/carsnd24_7.mp3",
	"vj_floodclassic/carrier/carsnd24_8.mp3",
	"vj_floodclassic/carrier/carsnd24_9.mp3",
}
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_floodclassic/carrier/h_front_kill.mp3"
}
ENT.SoundTbl_Pain = {
	"vj_floodclassic/shared/pain1.mp3",
	"vj_floodclassic/shared/pain2.mp3",
	"vj_floodclassic/shared/pain3.mp3",
	"vj_floodclassic/shared/pain4.mp3",
	"vj_floodclassic/shared/pain5.mp3",
	"vj_floodclassic/shared/pain6.mp3",
}
ENT.SoundTbl_Death = {
	"vj_floodclassic/carrier/die1.mp3",
	"vj_floodclassic/carrier/die2.mp3",
}
ENT.GibOnDeathDamagesTable = {"All"}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "step" then
		self:FootStepSoundCode()
	end
	if key == "fall" then
		VJ_EmitSound(self,"physics/flesh/flesh_strider_impact_bullet2.wav")
	end
	if key == "melee" then
		self:CarrierExplode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	self:CarrierGibs()
	self:SpawnFlood(math.random(3,11))
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CarrierGibs()
	local bloodeffect = EffectData()
	bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
	bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
	bloodeffect:SetScale(300)
	util.Effect("VJ_Blood1",bloodeffect)
	
	local bloodspray = EffectData()
	bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	bloodspray:SetScale(75)
	bloodspray:SetFlags(3)
	bloodspray:SetColor(1)
	util.Effect("bloodspray",bloodspray)
	util.Effect("bloodspray",bloodspray)
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	VJ_EmitSound(self,"vj_floodclassic/carrier/explosion" .. math.random(1,2) .. ".mp3",120,100)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SpawnFlood(count)
	for i = 1,count do
		local pos = self:GetPos() +self:OBBCenter()
		local flood = ents.Create("npc_vj_hcf_infection")
		flood:SetPos(pos +self:GetForward() *math.Rand(-(4 *i),4 *i) +self:GetRight() *math.Rand(-(4 *i),4 *i))
		flood:SetAngles(Angle(self:GetAngles().x,math.Rand(0,360),self:GetAngles().z))
		flood:Spawn()
		flood:SetGroundEntity(NULL)
		local rand = 350
		flood:SetVelocity(self:GetForward() *math.random(-rand,rand) +self:GetUp() *math.random(rand -50,rand) +self:GetRight() *math.random(-rand,rand))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CarrierExplode()
	self:CarrierGibs()
	util.VJ_SphereDamage(self,self,self:GetPos(),150,self.MeleeAttackDamage,DMG_POISON,false,true)
	self:SpawnFlood(math.random(6,14))
	self:Remove()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse) GetCorpse.IsFloodModel = true end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDeath_AfterCorpseSpawned(dmginfo,hitgroup,GetCorpse)
	if IsValid(self:GetActiveWeapon()) then
		local wep = ents.Create(self:GetActiveWeapon():GetClass())
		wep:SetPos(self:GetActiveWeapon():GetPos())
		wep:SetAngles(self:GetActiveWeapon():GetAngles())
		wep:Spawn()
		wep:SetClip1(self:GetActiveWeapon():Clip1())
		self:GetActiveWeapon():Remove()
	end
	if math.random(1,4) == 1 then
		local class = self:GetClass()
		timer.Simple(math.random(5,25),function()
			if IsValid(GetCorpse) then
				local flood = ents.Create(class)
				flood:SetPos(GetCorpse:GetPos())
				flood:SetAngles(GetCorpse:GetAngles())
				flood:Spawn()
				flood:Activate()
				undo.ReplaceEntity(self,flood)
				flood:SetHealth(math.random(12,37))
				if GetCorpse:IsOnFire() then flood:Ignite(5,0) end
				flood:SetNoDraw(true)
				flood:VJ_ACT_PLAYACTIVITY(ACT_ROLL_RIGHT,true,false,false)
				timer.Simple(0.33,function()
					if IsValid(flood) then
						flood:SetNoDraw(false)
						if GetCorpse:IsValid() then
							GetCorpse:Remove()
						end
					end
				end)
			end
		end)
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/