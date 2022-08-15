extends ConfirmationDialog

var _ctx: GDScriptFunctionState = null

func _ready() -> void:
	connect("confirmed", self, "_on_confirmed")
	get_cancel().connect("pressed", self, "_on_canceled")

func _yield_func() -> GDScriptFunctionState:
	return yield()

func ask(text: String, title := "Confirmation") -> GDScriptFunctionState:
	get_cancel().set_text("Cancel")
	window_title = title
	dialog_text = text
	popup_centered()
	_ctx = _yield_func()
	return yield(_ctx, "completed")

func _on_confirmed() -> void:
	_ctx.resume(true)

func _on_canceled() -> void:
	_ctx.resume(false)
