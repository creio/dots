# Polybar Gmail

## Dependencies

```bash
google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client
```

## Installation

```sh
cd ~/.config/polybar/gmail
```

and obtain/refresh credentials

```sh
~/.config/polybar/gmail/get_token.py
```

### Module

```ini
[module/gmail]
type = custom/script
exec = ~/.config/polybar/gmail/launch.py
tail = true
click-left = xdg-open https://mail.google.com
```

## Script arguments

`-l` or `--label` - set user's mailbox [label](https://developers.google.com/gmail/api/v1/reference/users/labels/list), default: INBOX

`-p` or `--prefix` - set email badge, default: 

`-c` or `--color` - set new email badge color, default: #e06c75

`-ns` or `--nosound` - turn off new email sound

### Example

```sh
./launch.py --label 'CATEGORY_PERSONAL' --prefix '📧' --color '#be5046' --nosound
```
