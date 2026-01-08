{ lib, config, ... }:
let
  inherit (lib) mkOption types;

  tlsSubmodule = types.submodule {
    options = {
      useStartTls = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to use StartTLS.";
      };
    };
  };

  serverSubmodule = types.submodule {
    options = {
      host = mkOption {
        type = types.str;
        description = "Server hostname.";
      };
      port = mkOption {
        type = types.port;
        description = "Server port.";
      };
      tls = mkOption {
        type = tlsSubmodule;
        default = { };
        description = "TLS configuration.";
      };
    };
  };

  accountSubmodule = types.submodule {
    options = {
      address = mkOption {
        type = types.str;
        description = "Email address.";
      };
      realName = mkOption {
        type = types.str;
        description = "Real name of the account owner.";
      };
      userName = mkOption {
        type = types.str;
        description = "Login username.";
      };
      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Whether this is the primary account.";
      };
      imap = mkOption {
        type = serverSubmodule;
        description = "IMAP server configuration.";
      };
      smtp = mkOption {
        type = serverSubmodule;
        description = "SMTP server configuration.";
      };
    };
  };

in
{
  options.private.emailAccounts = mkOption {
    type = types.attrsOf (types.attrsOf accountSubmodule);
    default = { };
    description = "Email accounts per user.";
  };

  config.private.emailAccounts = import ./emailAccounts.nix;
}
