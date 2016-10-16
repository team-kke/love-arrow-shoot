# ラブアローシュート

![ラブアローシュート](https://cloud.githubusercontent.com/assets/1013641/19418188/01a67742-93fa-11e6-9ff2-9a8286a89767.gif)

A super simple reverse proxy on Warp :sparkling_heart:

## What's this?

It's a reverse proxy server with dynamic configuration from web
UI. It's basically for webhook development where only HTTPS is
allowed. With love-arrow-shoot, HTTPS requests can be proxied to any
local HTTP server.

*As you may already have noticed, love-arrow-shoot shouldn't be used
in production for security and performance reason.*

## How to use

Run:

```
$ stack install
$ love-arrow-shoot
```

Configuration:

```
$ love-arrow-shoot --help
```

## License

[BSD3](LICENSE)
