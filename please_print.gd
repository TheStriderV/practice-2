## Customs quick print class, use P.p(var1, var2)
## 
class_name P

const COLORS: PackedStringArray = [
	"hot_pink","gold", "lime_green", "deep_sky_blue", "orchid", "orange",
	]

## Flip to false to silence every PP call at once.
static var enabled: bool = true
static var _seen: Dictionary = {}

## P.p print feature that only accepts vars
static func p(...args: Array) -> void:
	if not enabled:
		return
	print_rich(_where() + _format(args))


## Named values: PP.d({"health": health, "gold": gold})
static func d(values: Dictionary) -> void:
	if not enabled:
		return
	var parts: PackedStringArray = []
	var i := 0
	for key in values:
		parts.append("[color=%s]%s: %s[/color]" % [_color(i), key, _safe(values[key])])
		i += 1
	print_rich(_where() + "  ".join(parts))

static func log(message: String) -> void:
	print_rich(_where() + str(message))

## Prints only the first time this key is hit. Good for _process().
static func once(key: String, ...args: Array) -> void:
	if not enabled or _seen.has(key):
		return
	_seen[key] = true
	print_rich(_where() + _format(args))


static func warn(...args: Array) -> void:
	push_warning(_plain(args))


static func err(...args: Array) -> void:
	push_error(_plain(args))


static func _format(args: Array) -> String:
	var parts: PackedStringArray = []
	for i in args.size():
		parts.append("[color=%s]Var %d: %s[/color]" % [_color(i), i + 1, _safe(args[i])])
	return "  ".join(parts)


static func _plain(args: Array) -> String:
	var parts: PackedStringArray = []
	for a in args:
		parts.append(str(a))
	return " ".join(parts)


static func _color(i: int) -> String:
	return COLORS[i % COLORS.size()]


static func _safe(value: Variant) -> String:
	return str(value).replace("[", "[lb]")


## Prefix showing which script and line called P.
static func _where() -> String:
	var stack := get_stack()
	if stack.size() < 3:
		return ""
	var frame: Dictionary = stack[2]
	return "[color=dodger_blue]%s:%d[/color]:  " % [frame.source.get_file(), frame.line]