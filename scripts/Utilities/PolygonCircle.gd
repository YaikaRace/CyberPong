extends Polygon2D
class_name PolygonCircle2D
tool

export var radius: float = 10 setget set_radius
export var number_of_sides: int = 30 setget set_num_sides
export var circle_position: Vector2 = Vector2(0, 0) setget set_pos

func set_radius(new_radius) -> void:
	radius = new_radius
	generate_circle_polygon(radius, number_of_sides, circle_position)

func set_num_sides(new_sides) -> void:
	number_of_sides = new_sides
	generate_circle_polygon(radius, number_of_sides, circle_position)

func set_pos(new_pos) -> void:
	circle_position = new_pos
	generate_circle_polygon(radius, number_of_sides, circle_position)

func generate_circle_polygon(radius: float, num_sides: int, pos: Vector2) -> PoolVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var new_polygon: PoolVector2Array
	for _i in num_sides:
		new_polygon.append(vector + pos)
		vector = vector.rotated(angle_delta)
	polygon = new_polygon
	return new_polygon
