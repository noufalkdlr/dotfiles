-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XDG_MENU_PREFIX", "arch-")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Toolkit Backend
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

-- XDG Specifications
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- QT
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- NVIDIA hardware acceleration (desktop only, when the nvidia driver is loaded)
-- Read the first line of a file, or nil if it can't be read
local function read_first_line(path)
	local ok, f = pcall(io.open, path, "r")
	if not ok or not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	return line
end

-- DMI chassis types: 9 = Laptop, 10 = Notebook, 14 = Sub Notebook
local chassis = read_first_line("/sys/class/dmi/id/chassis_type")
local is_laptop = chassis == "9" or chassis == "10" or chassis == "14"

-- NVIDIA env vars only on desktops with the nvidia driver loaded.
-- On hybrid (Intel + NVIDIA) laptops they can break the Intel-driven display.
local nvidia_loaded = read_first_line("/proc/driver/nvidia/version") ~= nil

if nvidia_loaded and not is_laptop then
	hl.env("LIBVA_DRIVER_NAME", "nvidia")
	hl.env("GBM_BACKEND", "nvidia-drm")
	hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end
