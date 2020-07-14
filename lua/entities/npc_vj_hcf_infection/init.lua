AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2017 by Cpt. Hazama, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = "models/cpthazama/halo_classic/flood_infection_ce.mdl" -- Leave empty if using more than one model
ENT.StartHealth = GetConVarNumber("vj_hcf_infection_hp")
ENT.EntitiesToNoCollide = {"npc_vj_flood_infection","npc_vj_hcf_infection"}
ENT.HullType = HULL_TINY
ENT.GibOnDeathDamagesTable = {"All"}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_FLOOD","CLASS_PARASITE"}
ENT.BloodColor = "Yellow"
ENT.CustomBlood_Particle = {"cpt_blood_flood"}

ENT.HasMeleeAttack = false -- Should the SNPC have a leap attack?

ENT.HasLeapAttack = true -- Should the SNPC have a leap attack?
ENT.AnimTbl_LeapAttack = {ACT_GLIDE} -- Melee Attack Animations
ENT.LeapDistance = 200 -- The distance of the leap, for example if it is set to 500, when the SNPC is 500 Unit away, it will jump
ENT.LeapToMeleeDistance = 0 -- How close does it have to be until it uses melee?
ENT.TimeUntilLeapAttackDamage = 0.2 -- How much time until it runs the leap damage code?
ENT.NextLeapAttackTime = 1 -- How much time until it can use a leap attack?
ENT.NextAnyAttackTime_Leap = 0.4 -- How much time until it can use a attack again? | Counted in Seconds
ENT.LeapAttackExtraTimers = {0.4,0.6,0.8,1} -- Extra leap attack timers | it will run the damage code after the given amount of seconds
ENT.LeapAttackVelocityForward = 15 -- How much forward force should it apply?
ENT.LeapAttackVelocityUp = 300 -- How much upward force should it apply?
ENT.LeapAttackDamage = GetConVarNumber("vj_hcf_infection_dmg")
ENT.LeapAttackDamageDistance = 50 -- How far does the damage go?
ENT.AttackProps = false -- Should it attack props when trying to move?

ENT.DisableFootStepSoundTimer = true

ENT.SoundTbl_FootStep = {"vj_floodclassic/shared/walk3.mp3"}
ENT.SoundTbl_Idle = {
	"vj_floodclassic/infection/move1.mp3",
	"vj_floodclassic/infection/move2.mp3",
	"vj_floodclassic/infection/move3.mp3",
	"vj_floodclassic/infection/move4.mp3",
	"vj_floodclassic/infection/move5.mp3",
	"vj_floodclassic/infection/move6.mp3",
	"vj_floodclassic/infection/move7.mp3",
	"vj_floodclassic/infection/move8.mp3",
	"vj_floodclassic/infection/move9.mp3",
	"vj_floodclassic/infection/move10.mp3",
	"vj_floodclassic/infection/move11.mp3",
	"vj_floodclassic/infection/move12.mp3",
	"vj_floodclassic/infection/move13.mp3",
	"vj_floodclassic/infection/move14.mp3",
	"vj_floodclassic/infection/move15.mp3",
}
ENT.SoundTbl_CombatIdle = {
	"vj_floodclassic/infection/move_v1.mp3",
	"vj_floodclassic/infection/move_v2.mp3",
	"vj_floodclassic/infection/move_v3.mp3",
	"vj_floodclassic/infection/move_v4.mp3",
	"vj_floodclassic/infection/move_v5.mp3",
	"vj_floodclassic/infection/move_v6.mp3",
	"vj_floodclassic/infection/move_v7.mp3",
	"vj_floodclassic/infection/move_v8.mp3",
	"vj_floodclassic/infection/move_v9.mp3",
	"vj_floodclassic/infection/move_v10.mp3",
	"vj_floodclassic/infection/move_v11.mp3",
	"vj_floodclassic/infection/move_v12.mp3",
	"vj_floodclassic/infection/move_v13.mp3",
	"vj_floodclassic/infection/move_v14.mp3",
	"vj_floodclassic/infection/move_v15.mp3",
}
ENT.SoundTbl_BeforeLeapAttack = {
	"vj_floodclassic/infection/melee1.mp3",
	"vj_floodclassic/infection/melee2.mp3",
	"vj_floodclassic/infection/melee3.mp3",
}
ENT.SoundTbl_Death = {
	"vj_floodclassic/infection/die1.mp3",
	"vj_floodclassic/infection/die2.mp3",
	"vj_floodclassic/infection/die3.mp3",
}

ENT.IdleSoundLevel = 60
ENT.NextIdleSound1 = 1
ENT.NextIdleSound2 = 1
ENT.FootStepSoundLevel = 45
ENT.FootStepSoundPitch1 = 105
ENT.FootStepSoundPitch2 = 110
ENT.LeapAttackSoundLevel = 50
ENT.MeleeAttackSoundLevel = 50
ENT.DeathSoundLevel = 60
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize()
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_JUMP))
	self:CapabilitiesAdd(bit.bor(CAP_MOVE_CLIMB))
	self.IsLatched = false
	self.LatchedEnt = NULL
	self.LatchBone = nil
	self.LatchT = CurTime()
	self.NextInfectionThinkT = 0
	self:DrawShadow(false)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	local bloodeffect = EffectData()
	bloodeffect:SetOrigin(self:GetPos() +self:OBBCenter())
	bloodeffect:SetColor(VJ_Color2Byte(Color(255,221,35)))
	bloodeffect:SetScale(10)
	util.Effect("VJ_Blood1",bloodeffect)
	
	local bloodspray = EffectData()
	bloodspray:SetOrigin(self:GetPos() +self:OBBCenter())
	bloodspray:SetScale(1)
	bloodspray:SetFlags(3)
	bloodspray:SetColor(1)
	util.Effect("bloodspray",bloodspray)
	util.Effect("bloodspray",bloodspray)
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Small")
	self:CreateGibEntity("obj_vj_gib","UseAlien_Big")
	return true
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CanDoInfection()
	if !IsValid(self:GetEnemy()) then
		return true
	elseif IsValid(self:GetEnemy()) && self:GetEnemy():GetPos():Distance(self:GetPos()) > 500 then
		return true
	end
	return false
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Latch(ent)
	local tb = {}
	for i = 1,ent:GetBoneCount() -1 do
		tb[i] = i
	end
	local bone = tb[math.random(1,#tb)]
	self.LatchBone = bone
	local pos,ang = ent:GetBonePosition(self.LatchBone)
	if pos then
		self:SetPos(pos)
		self:SetAngles(ang)
	end
	self:FloodFollowBone(ent,self.LatchBone)
	self.LatchT = CurTime() +1.5
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:LatchAI(ent)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetNotSolid(true)
	if CurTime() > self.LatchT then
		if math.random(1,75) == 1 then
			self:VJ_ACT_PLAYACTIVITY("vjseq_feeding",true,nil,false)
			timer.Simple(2,function()
				if IsValid(self) && IsValid(ent) then
					ent:TakeDamage(999999999,self,self)
					ParticleEffect("cpt_blood_flood",self:GetPos(),Angle(0,0,0),nil)
				end
			end)
			self.LatchT = CurTime() +7
		else
			self:VJ_ACT_PLAYACTIVITY("vjseq_melee",true,nil,false)
			ent:TakeDamage(5,self,self)
			ParticleEffect("cpt_blood_flood",self:GetPos(),Angle(0,0,0),nil)
			self.LatchT = CurTime() +2
		end
		if self:GetPos() == ent:GetPos() || self.LatchBone == 0 then
			self:Unlatch()
		end
		if !IsValid(ent) or ent:Health() <= 0 then
			self:Unlatch()
		end
	end
	self:NextThink(CurTime())
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:Unlatch()
	self.IsLatched = false
	self.LatchedEnt = NULL
	self.LatchBone = nil
	self.HasLeapAttack = true
	self:SetMoveType(MOVETYPE_STEP)
	self:SetNotSolid(false)
	self:SetAngles(Angle(0,self:GetAngles().y,0))
	self:FloodFollowBone()
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:InfectionAI()
	if self.IsLatched then
		self.HasLeapAttack = false
		if IsValid(self.LatchedEnt) then
			local ent = self.LatchedEnt
			if IsValid(ent) then
				if self.LatchBone == nil then
					self:Latch(ent)
				end
				self:LatchAI(ent)
			end
		elseif !IsValid(self.LatchedEnt) or (IsValid(self.LatchedEnt) && self.LatchedEnt:Health() <= 0) then
			self:Unlatch()
		end
		return
	end

end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if CurTime() > self.NextInfectionThinkT then
		self:InfectionAI()
		self.NextInfectionThinkT = CurTime() +1
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnLeapAttack_AfterChecks(TheHitEntity)
	if GetConVarNumber("vj_halo_infectexplode") == 1 then
		if (TheHitEntity:IsNPC() or TheHitEntity:IsPlayer()) && TheHitEntity:Health() > 0 then
			ParticleEffect("cpt_blood_flood",self:GetPos(),Angle(0,0,0),nil)
			ParticleEffect("cpt_blood_flood",self:GetPos(),Angle(0,0,0),nil)
			ParticleEffect("cpt_blood_flood",self:GetPos(),Angle(0,0,0),nil)
			self:Remove()
		end
	else
		local ent = TheHitEntity
		if !self.IsLatched && IsValid(ent) && ent:Health() < 50 && ent:Health() > 0 then
			self.IsLatched = true
			self.LatchedEnt = ent
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key,activator,caller,data)
	if key == "step" then
		self:FootStepSoundCode()
	end
	if key == "melee" then
		-- self:MeleeAttackCode()
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