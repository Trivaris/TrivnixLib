{ lib, config, ... }:
let
  inherit (lib) mkOption types;

  calendarSubmodule = types.submodule {
    options = {
      type = mkOption {
        type = types.enum [ "caldav" ];
        default = "caldav";
        description = "Type of calendar resource.";
      };
      uri = mkOption {
        type = types.str;
        description = "URI for the calendar.";
      };
      username = mkOption {
        type = types.str;
        description = "Username for authentication.";
      };
      uuid = mkOption {
        type = types.str;
        description = "Unique ID for the calendar.";
      };
      color = mkOption {
        type = types.str;
        default = "#ffffff";
        description = "Display color for the calendar.";
      };
    };
  };

in
{
  options.private.calendarAccounts = mkOption {
    type = types.attrsOf (types.attrsOf calendarSubmodule);
    default = { };
    description = "Calendar accounts per user.";
  };
}
