{ pkgs, ... }:

{
  home.file.khal = {
    target = ".config/khal/config";
    text = ''
      [calendars]

      [[private1]]
      path = /home/porto/.local/share/khal/calendars/private
      type = calendar

      [locale]
      timeformat = %H:%M
      dateformat = %Y-%m-%d
      longdateformat = %Y-%m-%d
      datetimeformat = %Y-%m-%d %H:%M
      longdatetimeformat = %Y-%m-%d %H:%M

      [default]
      default_calendar = private1
    '';
  };
}
