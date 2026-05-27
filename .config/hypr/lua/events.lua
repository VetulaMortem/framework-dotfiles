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

--local function toggleWaybar(windowNr)
--	if windowNr < 1 then
--		hl.exec_cmd("pidof waybar || waybar -c " .. home .."/.config/waybar/config-eDP-1")
--	elseif windowNr > 1 then
--		hl.exec_cmd("pidof waybar || waybar -c " .. home .."/.config/waybar/config-eDP-1")
--	else
--		hl.exec_cmd("killall waybar")
--	end
--end
--
--hl.on("window.close",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.open",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.open_early",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.destroy",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.kill",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.active",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.update_rules",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
--hl.on("window.fullscreen",function()
--	toggleWaybar(hl.get_active_workspace().windows)
--end)
