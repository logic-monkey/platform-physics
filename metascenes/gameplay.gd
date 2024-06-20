extends Node2D
class_name GP_PLA

static var START_ROOM : PackedScene
static var HERO : PackedScene
static var GAMEPLAY : GP_PLA

var rooms : Dictionary = {}
var current_room: String = ""
var start : GP_PLA_Room
var hero : CharacterBody2D

func _ready():
	GAMEPLAY = self
	if not is_node_ready(): await  ready
	var t = get_tree()
	if not GP_PLA.START_ROOM or not GP_PLA.HERO: 
		#_IMP.input_mode_waiting.connect(_always_explore)
		await t.process_frame
		await t.process_frame
		_IMP.mode = _IMP.EXPLORE
		return

	start = GP_PLA.START_ROOM.instantiate()
	add_child(start)
	rooms[start.unique_title] = start
	current_room = start.unique_title
	hero = HERO.instantiate()
	add_child(hero)
	match_positions(hero, start)
	load_current_room()
	start.activate()
	
	#_IMP.input_mode_waiting.connect(_always_explore)
	await t.process_frame
	await t.process_frame
	_UI.heart_bar.hero_hp = hero.get_node("hp")
	#_IMP.mode = _IMP.EXPLORE

var rooms_loading: int = 0
func load_current_room():
	var cr = rooms[current_room] as GP_PLA_Room
	var neighbors = [current_room]
	if not cr.is_node_ready(): await  cr.ready
	for n in cr.neighbors:
		var neighbor = n as GP_PLA_Neighbor
		neighbors.append(neighbor.unique_name)
		if not neighbor.unique_name in rooms.keys():
			rooms[neighbor.unique_name] = neighbor.file
			load_neighbor(neighbor.unique_name, neighbor.global_position)
	for room_name in rooms.keys():
		if not room_name in neighbors:
			if rooms[room_name] is Node: rooms[room_name].queue_free()
			rooms.erase(room_name)
	
func load_neighbor(neighbor: String, location: Vector2):
	rooms_loading+=1
	if not neighbor in rooms:
		print("Failed to load '%s'; not in room list." % neighbor)
		rooms_loading-=1
		return
	if rooms[neighbor] is GP_PLA_Room:
		print("Tried to load '%s', but it was already loaded." % neighbor)
		rooms_loading-=1
		return
	if not rooms[neighbor] is String:
		print("Failed to load '%s'; '%s' is not a string." % [neighbor, rooms[neighbor]])
		rooms_loading-=1
		return
	if not ResourceLoader.exists(rooms[neighbor]):
		print("Failed to load '%s'; '%s' is not an existing resource." % [neighbor, rooms[neighbor]])
		rooms_loading-=1
		return
	var file = rooms[neighbor]
	ResourceLoader.load_threaded_request(file, "PackedScene")
	var tree = get_tree()
	while ResourceLoader.load_threaded_get_status(file) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await tree.process_frame
		if not neighbor in rooms:
			rooms_loading-=1
			return
	var status = ResourceLoader.load_threaded_get_status(file)
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		print("Failed to load '%s'. Resource Loader error." % neighbor)
		rooms_loading-=1
		return
	if not neighbor in rooms: 
		rooms_loading-=1
		return
	var room =  ResourceLoader.load_threaded_get(file).instantiate() as GP_PLA_Room
	rooms[neighbor] = room
	add_child.call_deferred(room)
	match_positions(room, location)
	rooms_loading-=1

func _always_explore():
	_IMP.mode=_IMP.EXPLORE

func _process(_delta):
	if _IMP.mode != _IMP.EXPLORE: return
	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("p1_start"):
		_OPT.FadeIn(false)

func make_me_main(room : GP_PLA_Room):
	if room.unique_title == current_room: return
	current_room = room.unique_title
	load_current_room()
	
func match_positions(node1: Node2D, location):
	if not node1.is_node_ready(): await  node1.ready
	if location is Node2D and not location.is_node_ready(): 
		await location.ready
		node1.global_position = location.global_position
	if location is Vector2: node1.global_position = location
