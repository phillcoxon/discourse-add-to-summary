# Overview

This plugin has been forked from https://github.com/pfaffman/discourse-add-to-summary for testing some Discourse features.  

Specifically: 
- using a plugin to override the default digest.html.erb template with a custom template. 
- Testing automatic language translation 

Note that I haven't removed any of the existing features in the `discourse-add-to-summary` plugin - I've simply added additional functionality for testing. As such this version should not be used on a production site.  


# Thoughts

Forking and extending this plugin has been great to get some quick insight into Discourse plugin development.

As a new Discourse user it also gave me the opportunity to test some additional command line functionality such as logging into the app instance directly to test minor changes of the plugin template without having to do a full app rebuild. 

For example: 

```
./launcher enter app
apt-get update  # must update apt-get remote repos after a rebuild
apt-get install nano # install the nano editor
cd plugins/discourse-add-to-summary/app/views/user_notifications/
nano digest.html.erb  # edit template file directly to test quick changes
rake assets:clean # cleans out cached assets
sv restart unicorn # restart the unicorn web server
```

Doing this made it very easy to test changes quickly on the live site without excessive downtime. 




