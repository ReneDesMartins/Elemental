# Log Formats
## List of log formats
### Irssi
The format used by the Irssi IRC client.

### Ergo
Custom log format designed to be compact, and easy to parse.

## Creating Log Formats
A log format is a table, containing multiple functions, and a string:
The date_format field specifies the string fed into the os.date() function.
Other required fields are privmsg, nick, join, part, kick, quit, mode, and topic. All these fields require a function that accepts the parsed message as it's only argument.
Whatever this function returns is written to the log file. It is advised to use string.format(), rather than manually concatenating strings, as this is cleaner, and quicker.