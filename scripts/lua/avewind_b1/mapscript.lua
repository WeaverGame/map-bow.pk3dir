-- printf wrapper
function et.G_Printf(...)
	et.G_Print(string.format(unpack(arg)))
end

spawnGroupRed = 1
spawnGroupBlue = 1
LTFFlagOwner = TEAM_RED
LTFFlagLocked = 0
LTFFlagEnt = -1
UCGFlagOwner = TEAM_FREE
UCGFlagLocked = 1
UCGFlagEnt = -1


-- called when game inits
function et_InitGame( levelTime, randomSeed, restart )
	--et.G_Printf("avewind Mapscript Loaded: et_InitGame :D\n")
	--et.G_Printf("VMnum=%d VMname=mapscript\n", et.FindSelf())
	et.RegisterModname("mapscript")
	
	spawnGroupBlue = 1
	game.SpawnGroup(TEAM_BLUE, 1, 1)
	game.SpawnGroup(TEAM_BLUE, 2, 0)
	game.SpawnGroup(TEAM_BLUE, 3, 0)
	
	spawnGroupRed = 1
	
	game.SpawnGroup(TEAM_RED, 1, 1)
	game.SpawnGroup(TEAM_RED, 2, 0)
	
	game.SetDefender(TEAM_RED)	--Red is defending
	game.SetTimeLimit(15)		--15 min
	
	LTFFlagOwner = (TEAM_RED)
	LTFFlagLocked = 0
	UCGFlagOwner = (TEAM_FREE)
	UCGFlagLocked = 0
	
	--et.G_Printf("LTFFlagOwner=%d LTFFlagLocked=%d\n", LTFFlagOwner, LTFFlagLocked)
end

--Lower Town Fortress
--Gate
LTFGateHurtLast = 0

function LTFGateHurt(self, inflictor, attacker)
	if ((game.Leveltime() - LTFGateHurtLast) < 5000) then
		return 0
	end
	LTFGateHurtLast = game.Leveltime()
	game.ObjectiveAnnounce(TEAM_BLUE, "The Lower Fortress Gate is taking damage!")
end

function LTFGateShieldTrigger(self, other)
	game.ObjectiveAnnounce(TEAM_BLUE, "The Lower Fortress Gate Shield has dissolved!")
end

function LTFGateTrigger(self, other)
	game.ObjectiveAnnounce(TEAM_BLUE, "The Lower Fortress Gate has been destroyed!")
	PhaseOne_End()
end

--Lower Town Fortress
--Flag
function LTFFlagTouch(self, other)
	team = et.gentity_get(other, "sess.sessionTeam", 0)
	--et.G_Printf("LTFFlagTouch1 spawnGroupBlue=%d spawnGroupRed=%d\n", spawnGroupBlue, spawnGroupRed)
	--et.G_Printf("    locked=%d flagowner=%d team=%d\n", LTFFlagLocked, LTFFlagOwner, team)
	
	if (team == LTFFlagOwner or LTFFlagLocked == 1) then
		return 0
	end
	
	if (team ~= TEAM_RED and team ~= TEAM_BLUE) then
		return 0
	end
	
	--et.G_Printf("LTFFlagTouch2 LTFFlagOwner=%d LTFFlagLocked=%d team=%d\n", LTFFlagOwner, LTFFlagLocked, team)
	
	LTFFlagOwner = team
	et.SetModelindex(self, team)
	
	if (team==TEAM_RED) then
		game.ObjectiveAnnounce(TEAM_RED, "The Lower Fortress Flag has been reclaimed by Red!")
		spawnGroupBlue = 1
		
		game.SpawnGroup(TEAM_BLUE, 1, 1)
		game.SpawnGroup(TEAM_BLUE, 2, 0)
		
		spawnGroupRed = 1
		
		game.SpawnGroup(TEAM_RED, 1, 1)
		game.SpawnGroup(TEAM_RED, 2, 0)
	else
		game.ObjectiveAnnounce(TEAM_BLUE, "The Lower Fortress Flag has been claimed by Blue!")
		spawnGroupBlue = 2
		
		game.SpawnGroup(TEAM_BLUE, 2, 1)
		game.SpawnGroup(TEAM_BLUE, 1, 0)
		
		spawnGroupRed = 2
		
		game.SpawnGroup(TEAM_RED, 2, 1)
		game.SpawnGroup(TEAM_RED, 1, 0)
	end
	
	--et.G_Printf("LTFFlagTouch3\n")
end

function LTFFlagSpawn(self)
	LTFFlagEnt = self
end

function PhaseOne_End()
	et.G_Printf("Phase One End\n")
	game.ObjectiveAnnounce(TEAM_BLUE, "The Lower Fortress has fallen!")
	
	LTFFlagOwner = TEAM_BLUE
	et.SetModelindex(LTFFlagEnt, TEAM_BLUE)
	LTFFlagLocked = 1
	
	if(spawnGroupBlue==3) then
		--attackers already have second forward spawn
		game.SpawnGroup(TEAM_BLUE, 3, 1)
		game.SpawnGroup(TEAM_BLUE, 2, 0)
		game.SpawnGroup(TEAM_BLUE, 1, 0)
	else
		--attackers do not have second forward spawn
		spawnGroupBlue = 2
		game.SpawnGroup(TEAM_BLUE, 3, 0)
		game.SpawnGroup(TEAM_BLUE, 2, 1)
		game.SpawnGroup(TEAM_BLUE, 1, 0)
	end
	
	spawnGroupRed = 2
	
	game.SpawnGroup(TEAM_RED, 2, 1)
	game.SpawnGroup(TEAM_RED, 1, 0)
	
	UCGFlagLocked = 0
end

--Upper Citadel Garden
function UCGFlagTouch(self, other)
	team = et.gentity_get(other, "sess.sessionTeam", 0)
	
	if (team == UCGFlagOwner or UCGFlagLocked == 1) then
		return 0
	end
	
	if (team ~= TEAM_RED and team ~= TEAM_BLUE) then
		return 0
	end
	
	--et.G_Printf("UCGFlagTouch2 UCGFlagOwner=%d UCGFlagLocked=%d team=%d\n", UCGFlagOwner, UCGFlagLocked, team)
	
	UCGFlagOwner = team
	
	if (team==TEAM_RED) then
		game.ObjectiveAnnounce(TEAM_RED, "The Upper Citadel Garden Flag has been deactivated by Red!")
		spawnGroupBlue = 2
		-- UCGFlag was lost by blue, revert blue spawn to either LTFFlag or Original
		if (LTFFlagOwner == TEAM_RED) then
			-- Red owns LTFFlag, revert blue spawn to original
			game.SpawnGroup(TEAM_BLUE, 1, 1)
			game.SpawnGroup(TEAM_BLUE, 2, 0)
		else
			-- Blue must own LTFFlag, revert blue spawn to LTFFlag
			game.SpawnGroup(TEAM_BLUE, 1, 0)
			game.SpawnGroup(TEAM_BLUE, 2, 1)
		end
		game.SpawnGroup(TEAM_BLUE, 3, 0)
		et.SetModelindex(self, TEAM_FREE)
	else
		game.ObjectiveAnnounce(TEAM_BLUE, "The Upper Citadel Garden Flag has been claimed by Blue!")
		spawnGroupBlue = 3
		
		game.SpawnGroup(TEAM_BLUE, 3, 1)
		game.SpawnGroup(TEAM_BLUE, 2, 0)
		game.SpawnGroup(TEAM_BLUE, 1, 0)
		et.SetModelindex(self, TEAM_BLUE)
	end
	
	--et.G_Printf("UCGFlagTouch3\n")
end

function UCGFlagSpawn(self)
	UCGFlagEnt = self
end

--Upper Citadel
--Gate
UCGateHurtLast = 0

function UCGateHurt(self, inflictor, attacker)
	if ((game.Leveltime() - UCGateHurtLast) < 5000) then
		return 0
	end
	UCGateHurtLast = game.Leveltime()
	game.ObjectiveAnnounce(TEAM_BLUE, "The Upper Citadel Gate is taking damage!")
end

function UCGateShieldTrigger(self, other)
	UCGateShieldTrig = 1
	game.ObjectiveAnnounce(TEAM_BLUE, "The Upper Citadel Gate Shield has dissolved!")
end

function UCGateTrigger(self, other)
	game.ObjectiveAnnounce(TEAM_BLUE, "The Upper Citadel Gate has been destroyed!")
	PhaseTwo_End()
end

function PhaseTwo_End()
	game.ObjectiveAnnounce(TEAM_BLUE, "The Upper Citadel is breached!")
	
	LTFFlagOwner = TEAM_BLUE
	et.SetModelindex(LTFFlagEnt, TEAM_BLUE)
	LTFFlagLocked = 1
	
	UCGFlagOwner = TEAM_BLUE
	et.SetModelindex(UCGFlagEnt, TEAM_BLUE)
	UCGFlagLocked = 1
	
	spawnGroupBlue=3
	
	game.SpawnGroup(TEAM_BLUE, 3, 1)
	game.SpawnGroup(TEAM_BLUE, 2, 0)
	game.SpawnGroup(TEAM_BLUE, 1, 0)
	
	spawnGroupRed = 2
	
	game.SpawnGroup(TEAM_RED, 2, 1)
	game.SpawnGroup(TEAM_RED, 1, 0)
end

-- Final objective
-- Flag

function CapFlagUse(self, other, activator)
	game.ObjectiveAnnounce(TEAM_BLUE, "Objective Captured!")
	et.G_Print("Blue team completed the objective.\n")
	game.SetWinner(TEAM_BLUE)
	et.G_Print("Ending the round\n")
	game.EndRound()
end
