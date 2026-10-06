{
  programs.starship = {
    enable = true;
    interactiveOnly = true;
  };

  programs.bash.blesh.enable = true;

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = false;
      update_check = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      style = "compact";
      inline_height = 18;
      show_preview = true;
      show_help = false;
      enter_accept = true;
      history_filter = [ "^ " "^clear$" "^exit$" "^ls$" "^pwd$" ];
    };
  };
}
