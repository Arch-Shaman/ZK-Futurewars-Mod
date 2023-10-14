local function PreprendTable(prependee, prepender)
	for i=1, #prependee do
		prepender[#prepender+1] = prependee[i]
	end
	return prepender
end

local briefing = {
	modname = "Future Wars",
	version = "v0.38.0",
	entries = {
		{"Update v0.38.0", fontsize = 24},
		{"This update brings with it a new exciting gamemodes - Commander wars, as well as a complete overhaul for Chickens. Superweapons have also been completely reworked in order to make them more interactive. The economy overlay has also been overhauled. Finally, a suit of balance changes makes the balance ever better"},
		{"A new gamemode has been added: Commander wars - In this gamemode you only have your commander. Upgrade your commander with Future War's massive arsonal of commander modules and hunt down the enemy commander. Features a unique trophy and rebalances to commander modules", image = "unitpics/commstrike.png"},
		{"The chickens gamemode also recived a massive overhaul. Future wars chickens are now much, much harder and significantly more dynamic. Featuring coordinated waves, powerful menace chickens, 2 new awards, and one chonky queen.", image = "unitpics/roost.png"},
		{"Snare also recieved a new fancy model and a complete overhaul. The unit is now significantly strong and gives ambushers the frontal assault strength which the previously lacked, making them much more viable in the mid-game", image = "unitpics/cloakassault.png"},
		{"Balance Changes:", fontsize = 18},
		{"Disco Rave Party, Starlight, Commander Shields, All Factories, Striker, Waylayer and Titan have been \255\64\255\64Buffed\255\255\255\255",
		"Azimuth, Liberator, Parcel, Flare, Froth and Prosperity have been \255\255\64\64Nerfed\255\255\255\255",
		"Wolf, Hermit, Zenith, Duster, Divinity have been \255\255\255\0Tweaked\255\255\255\255"},
		{"Additionally, Bugs relating to resign state, comm spawns, DRP have been fixed, and more polish have been given to queue colours, death messages, Health Bars and income share"},
	},
}

if Spring.GetGameRulesParam("chicken_difficulty") then
	briefing.entries = PreprendTable(briefing.entries, {
		{"Gamemode: Chickens", fontsize = 24},
		{"Chickens will alternate between launching all out assaults on your base with huge hordes and staying back in order to regain their forces. Ensure you destroy the chicken's roosts while the chickens are resting to weaken their attacks", image = "unitpics/chicken.png"},
		{"Chickens will eventually start to construct incredibily powerful chickens known as menaces. Destroy them before they are finished. Menaces under construction are protected by the Raffesia's indestructible shield, rendering them immune to artillery.", image = "unitpics/chicken_dragon.png"},
		{"The Hive's anger will increase over time. Once the hive anger reaches 100%, the Chicken Queen herself will arrive on the battlefield (unless you are in endless mode) and the chickens will start attacking nonstop. Focus all your firepower upon the chicken queen as her death will cause the swarm to crumble", image = "unitpics/chickenflyerqueen.png"},
		{""},
		{""},
	})
end

if tonumber((Spring.GetModOptions()["commwars"]) or 0) == 1 then
	briefing.entries = PreprendTable(briefing.entries, {
		{"Gamemode: Commander Wars", fontsize = 24},
		{"In this gamemode you have access to only your commander and nothing else. Your commander can no longer build, only repair and reclaim. Upgrade your commander by giving it more modules through the commander morph system and defeat the enemy commanders!", image = "unitpics/commstrike.png"},
		{"Additionally, balance changes have been made to many commander modules and weapons in order to make the more balanced in a commander-only gamemode. The balance is still experimental however so feedback would be greatly appricated", image = "unitpics/commweapon_disintegrator.png"},
		{""},
		{""},
	})
end


return briefing
