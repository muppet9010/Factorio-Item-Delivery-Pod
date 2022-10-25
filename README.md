# Factorio-Item-Delivery-Pod

A mod to send items towards a player/position from space in a ship/pod. They will crash land in a destroyed spaceship making a mess.

![Delivery pods landing](https://thumbs.gfycat.com/LongImmenseKinglet-size_restricted.gif)

Details
----------

The pods will land on both water and land, causing damage and making a mess. The crashs create smoke, wreckage and fires that will slowly burn out. The larger pods/ships come down with additional debris pieces.
A modular ship is made up of large debris parts of the number specified. Any contents will be within the main part of the ship/wrecks and can be aquired by mining the pod. A pods internal inventory is 999 slots so a lot can be fitted in to them.


Usage Notes
------------

Is designed to be used with integraions or other mods triggering the item deliveries.
Command & Remote Interface are the way to trigger a delivery providng the delivery information as arguments.

The "modular" crash type is special in that it is a multiple part ship wreck. it can have its number of parts defined in 1 of 2 ways:

- The number of parts in the total ship can be defined as a number on the end of the name, i.e. "modular6".
- Setting the weight of the total ship and using auto sizing mode in a special syntax, i.e. "modular-auto-500". The total ship weight is devided by the "Modular ship part weight" setting and rounded down to give the number of parts of the ship. The default for modular ship part weight is 100, but this is an abstract number and only matters in relation to the commands used to supply the total ship weight.

Remote Interface: "item_delivery_pod", "call_crash_ship"
Command: "item_delivery_pod-call_crash_ship"

Arguments (in order):

 - target = either a player name to target or a position (array of x and y [0,0] or a dictionary of x and y key value pairs {"x"=0,"y"=0})
 - radius = either a single number for radius (integer) from the target that the pod will randomly select somewhere to land within. Or as a simple 2 number array [2,10] for the min and max radius from the target it will centre on, for use if you don't want to hit the target position directly.
 - crashTypeName = the name of a pod/ship type for the delivery, either: "tiny", "small", "medium", "large", or "modular".
 - contents = a table (dictionary) of itemName (string) and quantity (integer). Modular pods will have the contents devided up across the large debris pieces. Can be intentionally empty with "nil"

All arguments in the command accept strings with spaces in if the strings are wrapped in double or single quotes, i.e. "User Name 53". You can escape quote characters with \ if needed, i.e. "m\"e" = m"e . They also accept tables in JSON format, i.e. {"iron-plate": 100,"coin": 100}
Interface (remote) calls should be made using Lua syntax and not JSON format arguments.

Command examples:

- Call a large ship down near a named player with some iron and coins in it:
	- `/item_delivery_pod-call_crash_ship "muppet9010" 5 "large" {"iron-plate":100, "coin":100}`
- Call a tiny ship down in an area around a specific position with no contents:
	- `/item_delivery_pod-call_crash_ship [10,-10] 50 "tiny" nil`

Mod Settings:

- Modular ship part weight: The weight per modular ship part. Used when the "modular" crash type is used in the "auto" sizing mode and the total ship weight is supplied in the command.


Muppet Coin Based Mod Collection
------------------

This mod is part of my collection of mods that use the vanilla Factorio coins. They are designed to work togeather or seperately as required. You can also mix with other people's mods that use vanilla Factorio coins.

- Prime Intergalactic Delivery: a market to buy player items for coins.
- Item Delivery Pod: a crashing spaceship that can bring items to the map with an explosive delivery.
- Coin Generation: a mod with a variety of ways for players and streamers to generate/obtain coins.
- Streamlabs RCON Integration: an external tool that lets streamers trigger ingame actions from Streamlabs: https://github.com/muppet9010/Streamlabs-Rcon-Integration

A number of my other mods are designed for streamers or have features to make them streamer friendly.