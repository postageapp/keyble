# keyble

Simple distributed SSH keychain management for servers.

## Usage

```
keyble --import keyfile
keyble --import keyfile server [server [...]]
keyble --add user@host server [server [...]]
keyble --remove user@host server [server [...]]
keyble --list
keyble --list server [server [...]]
```

## Files

A local database of keys and servers is maintained by default in `~/.keyble`
but this can be changed using either the `--config-path` option or the
`KEYBLE_CACHE_PATH` environment variable. It should also be possible to create
a symlink that establishes where the actual `.keyble` directory is located.

## Copyright

Copyright (c) 2012 Scott Tadman, The Working Group Inc.
See LICENSE.txt for further details.
