local default_apps = {}

default_apps.browser = "gtk-launch \"$(xdg-settings get default-web-browser)\""

return default_apps
