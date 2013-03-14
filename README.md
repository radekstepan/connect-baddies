# connect-baddies

A [Connect](http://www.senchalabs.org/connect/) middleware for filtering suspicious HTTP requests based on 422 request user-agent and url rules.

```coffee-script
http    = require 'http'
connect = require 'connect'
baddies = require 'connect-baddies'

logger = (msg) -> console.log msg

app = connect()
.use(baddies({ 'log': logger }))
.use (req, res) -> res.end 'Hello from Connect!'

http.createServer(app).listen 3000
```

## Sources

1. http://wordpress.org/extend/plugins/bad-behavior/developers/
1. http://johannburkard.de/blog/www/spam/The-top-10-spam-bot-user-agents-you-MUST-block-NOW.html
1. http://en.linuxreviews.org/HOWTO_stop_automated_spam-bots_using_.htaccess
1. http://www.askapache.com/htaccess/fight-blog-spam-with-apache.html
1. http://www.symantec.com/connect/articles/detection-sql-injection-and-cross-site-scripting-attacks