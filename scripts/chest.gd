extends Node2D
signal sell_all_pressed

var cash_on_hand: float = 0.0

@onready var sell_button = $SellButton


func set_val(val):
	$FishCountLabel.text = "fish count: " + str(val)


func float_to_dollar(value: float) -> String:
	return "%.2f" % value


func set_cash(value: float):
	cash_on_hand = value
	$CashLabel.text = "Cash: $" + float_to_dollar(cash_on_hand)


func add_cash(value: float):
	cash_on_hand += value
	$CashLabel.text = "Cash: $" + float_to_dollar(cash_on_hand)


func _on_button_pressed():
	print_debug("sell_all pressed")
	sell_all_pressed.emit()
