# PhoneGap iOS Map Plugin #

## Adding the Plugin to your project ##

Using this plugin requires [iOS PhoneGap](http://github.com/phonegap/phonegap-iphone) and the MapKit framework.

1. Add the "MapKit" framework to your Xcode project (different in Xcode 3 and 4, search for instructions)
2. Add the .h and .m files to your Plugins folder in your project
3. Add the .js files to your "www" folder on disk, and add reference(s) to the .js files as &lt;script&gt; tags in your html file(s)
4. In your config.xml, add &lt;plugin name="MapKit" value="MapKit" /&gt; in the plugins section

