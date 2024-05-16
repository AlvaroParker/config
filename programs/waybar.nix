{ ... }:
{
  enable = true;

  settings = {
    mainBar = {
      layer = "top";
      height = 35;
      margin-top = 10;
      margin-left = 10;
      spacing = 0;

      modules-left = [
        "custom/launcher"
        "custom/separator"
        "cpu"
        "memory"
        "custom/separator"
        "custom/window-name"
        "tray"
      ];

      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "battery"
        "backlight"
        "pulseaudio"
        "custom/right-arr"
        "network"
        "custom/clock-icon"
        "clock"
      ];

      "hyprland/workspaces" = {
        all-outputs = true;
        active-only = false;
        on-click = "activate";
        format = "{icon}";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "";
          urgent = "";
          active = "";
          default = "";
        };
      };

      tray = {
        icon-size = 20;
        spacing = 8;
      };

      "custom/clock-icon" = {
        format = "󱑅";
      };

      clock = {
        format = "<b>{:%I:%M %p}</b>";
        format-alt = "<b>{:%a.%d,%b}</b>";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        interval = 10;
        format = " {usage}%";
        max-length = 10;
        tooltip = false;
      };
      memory = {
        interval = 30;
        format = " {used}GiB";
        format-alt = " {used:0.1f}G";
        max-length = 10;
      };

      backlight = {
        device = "amdgpu_bl1";
        format = "{icon} {percent}";
        tooltip = false;
        format-icons = [ "󰃚 " "󰃛 " "󰃜 " "󰃝 " "󰃞 " "󰃟 " "󰃠 " ];
      };
      network = {
        format-wifi = "  {essid}";
        on-click = "iwgtk";
        format-ethernet = "󰈀 wired";
        tooltip = false;
        format-disconnected = "";
      };

      pulseaudio = {
        format = "{icon} <b>{volume}</b>";
        format-bluetooth = "  <b>{volume}</b>";
        format-bluetooth-muted = "   ";
        tooltip = false;
        format-muted = " ";
        format-icons = {
          default = [ "󰕿 " "󰖀 " "󰕾 " ];
        };
        on-click = "pavucontrol";
      };

      battery = {
        bat = "BAT1";
        interval = 30;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        "format-charging" = " {icon} {capacity}%";
        "format-icons" = [ " " " " " " " " ];
        "max-length" = 25;
        "tooltip" = false;
      };
      "custom/right-arr" = {
        format = "  ";
      };
      "custom/launcher" = {
        format = "";
      };
      "custom/separator" = {
        format = " ";
      };
      "custom/window-name" = {
        "format" = "<b>{}</b>";
        "interval" = 1;
        "exec" = "hyprctl activewindow | grep class | awk '{print $2}' | sed 's/\\([[:alpha:]]\\)/\\U\\1/'";
      };

      "custom/window-icon" = { };
      "custom/wrap-left" = {
        format = "<b>[</b>";
      };

      "custom/wrap-right" = {
        format = "<b>]</b>";
      };
    };
  };

  style = ''
    * {
      padding: 0;
      margin: 0;
      font-family: JetBrainsMono NF;
      font-size: 16px;
    }

    window#waybar {
      background-color: rgba(0, 0, 0, 0);
    }

    .modules-left {
      background-color: #1e2030;
      border-radius: 8px;
      padding-right: 15px;
      padding-left: 15px;
    }

    .modules-center {
      background-color: #1e2030;
      border-radius: 8px;
      padding-right: 10px;
      padding-left: 10px;
    }

    .modules-right {
      background-color: #1e2030;
      border-radius: 8px;
      padding-right: 15px;
      padding-left: 15px;
    }

    #custom-launcher {
      font-size: 20px;
      color: #00bfff; /* deepskyblue */
      padding-right: 10px;
    }

    #cpu,
    #memory,
    #temperature {
      font-size: 14px;
      background: #363a4f;
      margin-top: 5px;
      margin-bottom: 5px;
    }

    #cpu {
      color: #eed49f;
      padding: 0px 10px 0px 12px;
      border-radius: 5px 0px 0px 5px;
    }

    #memory {
      color: #a6da95;
      padding: 0px 10px 0px 0px;
    }

    #temperature {
      color: #8aadf4;
      padding: 0px 12px 0px 0px;
      border-radius: 0px 5px 5px 0px;
    }

    #custom-window-name {
      margin-right: 10px;
    }

    #custom-pacman-update-icon {
      background-color: #8bd5ca;
      color: #181926;
      padding-left: 5px;
      padding-right: 5px;
      margin-top: 5px;
      margin-bottom: 5px;
      border-radius: 5px;
    }

    #custom-pacman-update {
      color: #8bd5ca;
      margin: 5px 10px 5px 0px;
    }

    #workspaces button:nth-child(1) label {
      color: #8aadf4;
      margin: 0px 8px;
    }

    #workspaces button:nth-child(2) label {
      color: #ed8796;
      margin: 0px 8px;
    }

    #workspaces button:nth-child(3) label {
      color: #a6da95;
      margin: 0px 8px;
    }

    #workspaces button:nth-child(4) label {
      color: #c6a0f6;
      margin: 0px 8px;
    }

    #workspaces button:nth-child(5) label {
      color: #f4dbd6;
      margin: 0px 8px;
    }

    #workspaces button:nth-child(6) label {
      color: #f5a97f;
      margin: 0px 8px;
    }

    #battery {
      color: #a6da95;
      margin: 0px 10px 0px 0px;
    }

    #pulseaudio,
    #backlight {
      font-size: 14px;
      background: #363a4f;
      margin-top: 5px;
      margin-bottom: 5px;
    }

    #backlight {
      color: #eed49f;
      padding: 0px 10px 0px 10px;
      border-radius: 5px 0px 0px 5px;
    }

    #pulseaudio {
      color: #91d7e3;
      padding: 0px 10px 0px 0px;
      border-radius: 0px 5px 5px 0px;
    }

    #custom-right-arr {
      color: #8aadf4;
    }

    #network {
      color: #c6a0f6;
      margin-right: 10px;
    }

    #custom-dot {
      color: #6e738d;
      padding-left: 10px;
      padding-right: 10px;
    }

    #custom-dot-alt {
      color: #a5adcb;
      padding-left: 10px;
      padding-right: 10px;
    }

    #custom-clock-icon {
      background-color: #cad3f5;
      color: #181926;
      padding-left: 10px;
      padding-right: 10px;
      margin-top: 5px;
      margin-bottom: 5px;
      border-radius: 5px;
    }

    #clock {
      padding-left: 10px;
    }

    /*# sourceMappingURL=style.css.map */
  '';
}
