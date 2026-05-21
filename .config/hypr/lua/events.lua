----------------
---- EVENTS ----
----------------
hl.on("screenshare.state",function(active,type,display) 
    if active then
    	hl.exec_cmd("hyprctl hyprpaper wallpaper 'eDP-1, /home/vetula/.assets/wallhaven-6opprx.jpg'")
    else
    	hl.exec_cmd("hyprctl hyprpaper wallpaper 'eDP-1, /home/vetula/.assets/wallhaven-3kwll9.jpg'")
    end
end)
