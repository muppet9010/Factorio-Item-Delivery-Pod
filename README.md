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
Remote Interface: "item_delivery_pod", "call_crash_ship"
Command: "item_delivery_pod-call_crash_ship"
Arguments (in order):
 - target = either a player name to target or a position (array of x and y [0,0] or a dictionary of x and y key value pairs {"x"=0,"y"=0})
 - radius = either a single number for radius (integer) from the target that the pod will randomly select somewhere to land within. Or as a simple 2 number array [2,10] for the min and max radius from the target it will centre on, for use if you don't want to hit the target position directly.
 - crashTypeName = the name of a pod/ship type for the delivery, either: "tiny", "small", "medium", "large", or "modular". If modular then the number of modules must be specified as a number on the end of the name, i.e. "modular6".
 - contents = a table (dictionary) of itemName (string) and quantity (integer). Modular pods will have the contents devided up across the large debris pieces. Can be intentionally empty with "nil"
All arguments via command accept strings with spaces in if wrapped in double or single quotes, i.e. "User Name 53". They also accept tables in JSON format WITHOUT spaces, i.e. {"iron-plate":100,"coin":100}
Interface calls should be made using Lua syntax and not JSON format arguments.

Command examples:
`/item_delivery_pod-call_crash_ship "muppet9010" 5 "large" {"iron-plate":100,"coin":100}`
`/item_delivery_pod-call_crash_ship [10,-10] 50 "tiny" nil`