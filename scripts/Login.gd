extends Control

func _on_LoginButton_pressed():
    var email = $VBoxContainer/Email.text
    var password = $VBoxContainer/Password.text
    # Implement authentication logic using Hathora
    NetworkManager.authenticate(email, password)