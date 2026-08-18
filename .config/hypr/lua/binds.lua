------------------
---- KEYBINDS ----
------------------
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
local function zoom(increment)
	local zoom_level = hl.get_config("cursor.zoom_factor")
	zoom_level = zoom_level + increment
	if zoom_level < 1 then
		zoom_level = 1.0
	end
	hl.exec_cmd("hyprctl eval 'hl.config({cursor = {zoom_factor = " .. zoom_level .. "}})'")
end
hl.bind(mainMod .. " + ALT +mouse_down",
function()
	zoom(0.1)
end)
hl.bind(mainMod .. " + ALT +mouse_up",
function()
	zoom(-0.1)
end)
hl.bind(mainMod .. " + F1",hl.dsp.exec_cmd("systemctl --user start hyprsunset"))
hl.bind(mainMod .. "+ SHIFT + F1",hl.dsp.exec_cmd("systemctl --user stop hyprsunset"))
local mousestate = true
hl.bind(mainMod .. " + F2",function()
	mousestate = not mousestate
	if mousestate then
		hl.notification.create({ text = "Touchpad ON", timeout = 2000, icon = "ok" })
	else
		hl.notification.create({ text = "Touchpad OFF", timeout = 2000, icon = "ok" })
	end
	hl.device({
		name = "pixa3854:00-093a:0274-touchpad",
		enabled = mousestate,
	})
end)
local  touchstate = true
hl.bind(mainMod .. " + F3",function()
	touchstate = not touchstate
	if touchstate then
		hl.notification.create({ text = "Touchscreen  ON", timeout = 2000, icon = "ok" })
	else
		hl.notification.create({ text = "Touchscreen OFF", timeout = 2000, icon = "ok" })
	end
	hl.device({
		name = "csw1322:00-3558:14fd",
		enabled = touchstate,
		transform = 0,
	})
end)
hl.bind(mainMod .. " + CTRL + D" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({debug = { overlay = true }})'"))
hl.bind(mainMod .. " + CTRL + SHIFT + D" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({debug = { overlay = false }})'"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | " .. sizedWofi .. " --dmenu  | cliphist decode | wl-copy"))
--hl.bind( mainMod .. " + , Space, global, kando:hypr
hl.bind("CTRL + SHIFT + Q" , hl.dsp.exec_cmd(home .. ".scripts/commandwrapper.sh " .. terminal .. "\" -o background_opacity=1.0 --class btop -e btop\"")) 
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + ALT + 1" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({cursor = {zoom_factor = 1.0}})'"))
hl.bind(mainMod .. " + ALT + 2" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({cursor = {zoom_factor = 2.0}})'"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(home .. ".scripts/logouthyprland.sh"), { locked = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(runmenu))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("firefox --private-window"))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("LD_PRELOAD=/home/vetula/GIT/extest/target/i686-unknown-linux-gnu/release/libextest.so steam"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(home .. ".scripts/cavaembed.sh"))
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + TAB", function()
	layout = hl.get_config("general.layout")
	--Define switch
	local value = ""
	local layoutswitch = {
	 ["monocle"] = function()
		hl.dispatch(hl.dsp.layout("cyclenext tiled"))
	 end,
	 ["default"] = function()
		hl.dispatch(hl.dsp.focus({ direction = "up" }))
	 end
	}
	--Execute Switch

	if layoutswitch[layout] then
	   layoutswitch[layout]()
	else
	   layoutswitch["default"]()
	end
end)
hl.bind("SHIFT + ALT + TAB", hl.dsp.layout("cycleprev tiled"))
hl.bind(mainMod .. " + RETURN", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .." + CTRL + 1",hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output = \"eDP-1\",mode=\"preferred\",position=\"auto\",scale=\"2\"})'"))
hl.bind(mainMod .." + CTRL + 2",hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output = \"eDP-1\",mode=\"preferred\",position=\"auto\",scale=\"1\"})'"))
hl.bind(mainMod .." + CTRL + 3",hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output = \"eDP-1\",mode=\"2880x1920@60\"})'"))
hl.bind(mainMod .." + CTRL + 4",hl.dsp.exec_cmd("hyprctl eval 'hl.monitor({output = \"eDP-1\",mode=\"2880x1920@120\"})'"))
hl.bind("mouse:276", hl.dsp.exec_cmd("wpctl set-volume -l 2 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"))
hl.bind("mouse:275", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"))
hl.bind("switch:on:[Lid Switch]", hl.dsp.exec_cmd("hyprlock --immediate"), { locked = true })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -zm region"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("CTRL + " .. mainMod .. " + P", hl.dsp.cursor.move({ x=750,  y=500}))
hl.bind("CTRL + " .. mainMod .. " + P", hl.dsp.exec_cmd("hypremoji"))
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
--hl.bind( mainMod .. " +, SPACE, hyprexpo:expo, toggle
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 2 @DEFAULT_AUDIO_SINK@ 5%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ "), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- "), { locked = true, repeating = true })
--hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true, repeating = true })
--hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true, repeating = true })
--hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true, repeating = true })
--hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl previous"), { locked = true, repeating = true })
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(home .. ".scripts/togglehypridle.sh"))

hl.bind(mainMod .. " + ALT + L",hl.dsp.submap("LayoutControl"))
hl.define_submap("LayoutControl",function()
	hl.bind("1" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({general = {layout = \"dwindle\",}})'"))
	hl.bind("2" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({general = {layout = \"master\",}})'"))
	hl.bind("3" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({general = {layout = \"scrolling\",}})'"))
	hl.bind("4" , hl.dsp.exec_cmd("hyprctl eval 'hl.config({general = {layout = \"monocle\",}})'"))
	hl.bind("5" , hl.dsp.exec_cmd("hyprctl reload"))
	hl.bind("escape",hl.dsp.submap("reset"))
end)
