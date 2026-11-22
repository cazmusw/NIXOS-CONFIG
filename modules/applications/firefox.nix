{ ... }:

let
  docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
in
{
  programs.firefox = {
    enable = true;

    policies.Handlers = {
      mimeTypes.${docx} = {
        action = "saveToDisk";
        ask = false;
      };

      extensions.docx = {
        action = "saveToDisk";
        ask = false;
      };
    };
  };

  xdg.mime = {
    enable = true;

    defaultApplications = {
      ${docx} = "wordcraft.desktop";
      "application/msword" = "wordcraft.desktop";
    };
  };
}
