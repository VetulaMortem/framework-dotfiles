-------------------
---- AUTOSTART ---- 
-------------------
hl.on("hyprland.start",function()
   hl.exec_cmd("hyprpm reload -n")
   hl.exec_cmd("sleep 1 && hyprctl reload")
   hl.exec_cmd("wl-paste --type text --watch cliphist store # Stores only text data")
   hl.exec_cmd("wl-paste --type image --watch cliphist store # Stores only image data")
   hl.exec_cmd("mpv --no-video /home/vetula/.assets/audio/NGE.opus")
   hl.exec_cmd("udiskie -A -n -t &")
   hl.exec_cmd("swayosd-server")
   hl.exec_cmd(home .. ".scripts/waybarwatchdog_v3_instancer.sh")
   hl.exec_cmd(home .. ".scripts/setwallpaper.sh")
   hl.exec_cmd("gtk-launch fw-fanctrl-ui")
   --hl.exec_cmd("whatsie")
   hl.exec_cmd("Telegram -startintray")
end)
