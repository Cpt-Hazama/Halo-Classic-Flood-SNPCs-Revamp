AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/cpthazama/halo_classic/flood_human_ce.mdl" -- Leave empty if using more than one model
ENT.StartHealth = GetConVarNumber("vj_hcf_human_hp")
ENT.EntitiesToNoCollide = {"npc_vj_flood_infection","npc_vj_hcf_infection"}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.CustomBlood_Particle = {"cpt_blood_flood","cpt_blood_flood","cpt_blood_flood","vj_impact1_red"}

ENT.MeleeAttackDistance = 75
ENT.MeleeAttackDamageDistance = 105
ENT.MeleeAttackDamage = GetConVarNumber("vj_hcf_human_dmg")
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

ENT.SoundTbl_FootStep = {"vj_floodclassic/shared/run1.mp3","vj_floodclassic/shared/run2.mp3","vj_floodclassic/shared/run3.mp3","vj_floodclassic/shared/walk1.mp3","vj_floodclassic/shared/walk2.mp3","vj_floodclassic/shared/walk3.mp3","vj_floodclassic/shared/walk4.mp3","vj_floodclassic/shared/walk5.mp3","vj_floodclassic/shared/walk6.mp3"}
ENT.SoundTbl_Idle = {
	"vj_floodclassic/shared/idle_nocombat1.mp3",
	"vj_floodclassic/shared/idle_nocombat2.mp3",
	"vj_floodclassic/shared/idle_nocombat3.mp3",
	"vj_floodclassic/shared/idle_nocombat4.mp3",
	"vj_floodclassic/shared/idle_nocombat5.mp3",
}
ENT.SoundTbl_CombatIdle = {
	"vj_floodclassic/shared/leap1.mp3",
	"vj_floodclassic/shared/leap2.mp3",
	"vj_floodclassic/shared/leap3.mp3",
	"vj_floodclassic/shared/leap4.mp3",
	"vj_floodclassic/shared/leap5.mp3",
}
ENT.SoundTbl_BeforeMeleeAttack = {
	"vj_floodclassic/shared/melee1.mp3",
	"vj_floodclassic/shared/melee2.mp3",
	"vj_floodclassic/shared/melee3.mp3",
	"vj_floodclassic/shared/melee4.mp3",
	"vj_floodclassic/shared/melee5.mp3",
	"vj_floodclassic/shared/melee6.mp3",
	"vj_floodclassic/shared/melee7.mp3",
	"vj_floodclassic/shared/melee8.mp3",
	"vj_floodclassic/shared/melee9.mp3",
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
	"vj_floodclassic/shared/death1.mp3",
	"vj_floodclassic/shared/death2.mp3",
	"vj_floodclassic/shared/death3.mp3",
	"vj_floodclassic/shared/death4.mp3",
	"vj_floodclassic/shared/death5.mp3",
	"vj_floodclassic/shared/death6.mp3",
	"vj_floodclassic/shared/death7.mp3",
	"vj_floodclassic/shared/death8.mp3",
}
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	-- print(key)
	if key == "step" then
		self:FootStepSoundCode()
	end
	if key == "melee" then
		self:MeleeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:MultipleMeleeAttacks()
	if self:IsMoving() then
		local anim = ACT_MELEE_ATTACK1
		if IsValid(self:GetActiveWeapon()) then
			anim = ACT_MELEE_ATTACK2
		end
		self.AnimTbl_MeleeAttack = {anim}
		self.MeleeAttackAnimationAllowOtherTasks = false
	else
		local anim = "vjges_melee_gest"
		if IsValid(self:GetActiveWeapon()) then
			anim = "vjges_weapon_melee_gest"
		end
		self.AnimTbl_MeleeAttack = {anim}
		self.MeleeAttackAnimationAllowOtherTasks = true
	end
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