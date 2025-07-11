local bannedPlayers = {
	["mr0neoncat"] = "Concern trolling / attempting to defame the lead developer is not a good idea if you enjoy playing so much. https://discordapp.com/channels/278805140708786177/278805140708786177/1393273553893200004 . This gameside ban will remain until you provide a handwritten, sincere letter of apology to the lead developer.",
} -- expects name = reason

local bannedPlayersByLobbyID = {
	[598102] = bannedPlayers["mr0neoncat"],
}

return bannedPlayers, bannedPlayersByLobbyID
