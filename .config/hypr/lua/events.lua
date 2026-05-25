----------------
---- EVENTS ----
----------------

hl.on("screenshare.state",function(active,type,display)
     currentWindows = hl.get_active_workspace().windows
     if active then
	if currentWindows > 0 then
		--hl.exec_cmd("notify-send EVENTS 'now sharing " .. display .. "'")
		hl.exec_cmd("hyprctl hyprpaper wallpaper 'eDP-1, /home/vetula/.assets/wallhaven-6opprx.jpg'")
    	end
    else
	if currentWindows > 0 then
		--hl.exec_cmd("notify-send EVENTS 'stopped sharing " .. display .. "'")
		hl.exec_cmd("hyprctl hyprpaper wallpaper 'eDP-1, /home/vetula/.assets/wallhaven-3kwll9.jpg'")
	end
    end
end)
