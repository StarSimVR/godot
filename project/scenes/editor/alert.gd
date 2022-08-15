extends AcceptDialog

func info(text: String, title := "Information") -> void:
	window_title = title
	dialog_text = text
	popup_centered()
