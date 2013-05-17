local _G = getfenv(0)
local flint = _G.object

flint.heroName = "Hero_FlintBeastwood"
runfile 'bots/core_herobot.lua'

local core, behaviorLib = flint.core, flint.behaviorLib

behaviorLib.StartingItems = { "Item_RunesOfTheBlight", "Item_HealthPotion", "2 Item_DuckBoots" }
behaviorLib.LaneItems = { "Item_Soulscream", "Item_Marchers", "Item_Steamboots", "Item_Fleetfeet", "Item_Quickblade" , "Item_Sicarius", "Item_WhisperingHelm", "Item_Weapon3", "Item_Critical1", "Item_Critical2", "Item_DaemonicBreastplate", "Item_LifeSteal4", "Item_Sasuke", "Item_Damage9" }
behaviorLib.MidItems = {  }
behaviorLib.LateItems = { "Item_Critical1", "Item_Critical2", "Item_DaemonicBreastplate", "Item_LifeSteal4", "Item_Sasuke", "Item_Damage9" }

---------------------------------------------------------------
-- SkillBuild override --
-- Handles hero skill building. To customize just write own --
---------------------------------------------------------------
-- @param: none
-- @return: none


flint.skills = {}
local skills = flint.skills


flint.tSkills = {
  1, 2, 2, 1, 2,
  3, 2, 1, 1, 4,
  3, 4, 4, 4, 4,
  3, 4, 4, 4, 4,
  4, 0, 0, 0, 0
}

function flint:SkillBuildOverride()
 local unitSelf = self.core.unitSelf
  if skills.abilNuke == nil then
    skills.abilNuke = unitSelf:GetAbility(0)
    skills.abilHeadshot = unitSelf:GetAbility(1)
    skills.abilRange = unitSelf:GetAbility(2)
    skills.abilUlti = unitSelf:GetAbility(3)
    skills.stats = unitSelf:GetAbility(4)
  end
  self:SkillBuildOld()
end
flint.SkillBuildOld = flint.SkillBuild
flint.SkillBuild = flint.SkillBuildOverride

------------------------------------------------------
-- onthink override --
-- Called every bot tick, custom onthink code here --
------------------------------------------------------
-- @param: tGameVariables
-- @return: none
function flint:onthinkOverride(tGameVariables)
  self:onthinkOld(tGameVariables)

  -- custom code here
end
flint.onthinkOld = flint.onthink
flint.onthink = flint.onthinkOverride

----------------------------------------------
-- oncombatevent override --
-- use to check for infilictors (fe. buffs) --
----------------------------------------------
-- @param: eventdata
-- @return: none
function flint:oncombateventOverride(EventData)
  self:oncombateventOld(EventData)

  -- custom code here
end


local function CustomHarassUtilityFnOverride(hero)
  local nUtil = 0

  if skills.abilUlti:CanActivate() then
    nUtil = nUtil + 30
    if hero:GetHealthPercent() < 0.4 then
      nUtil = nUtil + 100
    end
  end
  return nUtil
end
behaviorLib.CustomHarassUtility = CustomHarassUtilityFnOverride

local function HarassHeroExecuteOverride(botBrain)

  local unitTarget = behaviorLib.heroTarget
  if unitTarget == nil then
    return flint.harassExecuteOld(botBrain)
  end

  local unitSelf = core.unitSelf
  local nTargetDistanceSq = Vector3.Distance2DSq(unitSelf:GetPosition(), unitTarget:GetPosition())

  local bActionTaken = false

  if core.CanSeeUnit(botBrain, unitTarget) then
    local abilUlti = skills.abilUlti

    if abilUlti:CanActivate() then
      local nRange = abilUlti:GetRange()
      if nTargetDistanceSq < (nRange * nRange) then
        bActionTaken = core.OrderAbilityEntity(botBrain, abilUlti, unitTarget)
      else
        bActionTaken = core.OrderMoveToUnitClamp(botBrain, unitSelf, unitTarget)
      end
    end
  end

  if not bActionTaken then
    return flint.harassExecuteOld(botBrain)
  end
end
flint.harassExecuteOld = behaviorLib.HarassHeroBehavior["Execute"]
behaviorLib.HarassHeroBehavior["Execute"] = HarassHeroExecuteOverride

flint.oncombateventOld = flint.oncombatevent
flint.oncombatevent = flint.oncombateventOverride
