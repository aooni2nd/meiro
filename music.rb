
require 'dxruby'

menu_sound = Sound.new("menu.wav")

Window.loop do
  if Input.key_push?(K_SPACE)
    menu_sound.play
  end


end


