# Factorio-Item-Delivery-Pod

A mod to send items towards a player/position from space in a ship/pod. They will crash land in a destroyed spaceship making a mess.
If only there was a technology to direct the pods to be landed in a safe manner...

The pods will land on both water and land, causing damage and making a mess. The crashs create smoke, wreckage and fires that will slowly burn out. The larger pods/ships come down with additional debris pieces. 
A modular ship is made up of large debris parts of the number specified. Any contents will be within the main part of the ship/wrecks and can be aquired by mining the pod. A pods internal inventory is 999 slots so a lot can be fitted in to them.

Is designed to be used with integraions or other mods triggering the item deliveries.
Command & Remote Interface are the way to trigger a delivery providng the delivery information as arguments.
Remote Interface: "item_delivery_pod", "call_crash_ship"
Command: "item_delivery_pod-call_crash_ship"
Arguments (in order):
 - target = either a player name to target or a position table.
 - radius = radius (integer) from the target that the pod will randomly select somewhere to land within.
 - crashTypeName = the name of a pod/ship type for the delivery, either: "tiny", "small", "medium", "large", or "modular". If modular then the number of modules must be specified as a number on the end of the name, i.e. "modular6".
 - contents = a table (dictionary) of itemName (string) and quantity (integer). Modular pods will have the contents devided up across the large debris pieces.
All arguments via command accept strings with spaces in if wrapped in double or single quotes, i.e. "User Name 53". They also accept tables in JSON format WITHOUT spaces, i.e. [{"name"="iron-ore","count"=100]}]    or   {"iron-plate":100,"coin":100}