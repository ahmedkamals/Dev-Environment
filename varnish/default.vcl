##
# @file
# Varnish configuration - default configurations settings.
#
# Copyright © 2015, Ahmed Kamal. (https://github.com/ahmedkamals)
#
# This file is part of Ahmed Kamal's server configurations.
# ® Redistributions of files must retain the above copyright notice.
#
# @copyright     Ahmed Kamal (https://github.com/ahmedkamals)
# @link          https://github.com/ahmedkamals/dev-environment
# @package       AK
# @subpackage
# @version       1.0
# @since         2015-01-25 Happy day :)
# @license
# @author        Ahmed Kamal <me.ahmed.kamal@gmail.com>
# @modified      2015-01-25
#


# http://iyubo.blogbus.com/logs/35013331.html
# https://github.com/halcyonCorsair/varnish-for-drupal

include "acl.vcl";
include "default-backends.vcl";
include "backends.vcl";

# Respond to incoming requests.
sub vcl_recv {

	# Check the number of restarts before you select a back end. Try your normal, fast director first.
	# https://www.varnish-cache.org/lists/pipermail/varnish-misc/2011-March/005826.html
	if (req.restarts <= 1) {

		if (req.url ~ "(?i)\.(bmp|jpg|jpeg|png|gif|ico|css|js|html|htm|eot|otf|svg|ttf|woff|zip|rar|tar|gz|tgz|bz2|tbz|doc|pdf|txt|rtf|wav|mp3|mp4|ogg|flv|swf|m3u|m3u8|ts)(\?[a-z0-9]+)?$") {

		  set req.backend = Nginx;

		  # Always cache the following static file types for all users.
		  unset req.http.Cookie;
	    remove req.http.authenticate;
		}
		elsif (server.port == 443) {

			set req.backend = SSL_Director;
		}
		else {

	   		set req.backend = Default_Director;
		}
        } else {

                if (req.url ~ "(?i)\.(bmp|jpg|jpeg|png|gif|ico|css|js|html|htm|eot|otf|svg|ttf|woff|zip|rar|tar|gz|tgz|bz2|tbz|doc|pdf|txt|rtf|wav|mp3|mp4|ogg|flv|swf|m3u|m3u8|ts)(\?[a-z0-9]+)?$") {

			set req.backend = WaitALongTime_Nginx;

			# Always cache the following static file types for all users.
			unset req.http.Cookie;
			remove req.http.authenticate;
		}
		elsif (server.port == 443) {

			set req.backend = WaitALongTime_SSL;
		}
		else {

			set req.backend = WaitALongTime_Apache;
		}
        }

	if (req.backend.healthy) {

		set req.grace = 30s;
	} else {

		set req.grace = 5h;
	}

	if (req.request == "GET" && req.url ~ "^/varnishcheck$") {

		error 200 "Varnish is Ready";
	}

	# Add a unique header containing the client address, if it is not there.
	if (!req.http.X-Forwarded-For) {

		set req.http.X-Forwarded-For = client.ip;
	}

	# Allow PURGE from localhost and 192.168.{129,229}.0/24.
	if (req.request == "PURGE") {

	  if (!client.ip ~ internal) {

	    error 405 "Not allowed.";
	  }

	  return (lookup);
	}

	if (req.http.Cookie ~ "SESS") {

	  if (!(req.url ~ "(?i)\.(bmp|jpg|jpeg|png|gif|ico|css|js|html|htm|eot|otf|svg|ttf|woff|zip|rar|tar|gz|tgz|bz2|tbz|doc|pdf|txt|rtf|wav|mp3|mp4|ogg|flv|swf|m3u|m3u8|ts)(\?[a-z0-9]+)?$")) {

	    #return (pipe);
	    return (pass);
	  }
	}

	# Get ride of progress.js query params
	if (req.url ~ "^/misc/progress\.js\?[0-9]+$") {

	  set req.url = "/misc/progress.js";
	}

	# If global redirect is on
	#if (req.url ~ "node\?page=[0-9]+$") {
	#  set req.url = regsub(req.url, "node(\?page=[0-9]+$)", "\1");
	#  return (lookup);
	#}

	/* Non-RFC2616 or CONNECT which is weird. */
	if (req.request != "GET" &&
	req.request != "HEAD" &&
	req.request != "PUT" &&
	req.request != "POST" &&
	req.request != "TRACE" &&
	req.request != "OPTIONS" &&
	req.request != "DELETE") {

		return (pipe);
	}

	if(req.request != "GET" && req.request != "HEAD"){

		return (pipe);
	}

	# Do not cache data which has an autorization header
	# Do not cache any POST'ed data
	# Do not cache these paths.
	if (req.http.Authorization ||
            req.request == "POST" ||
	    req.url ~ "^/status\.php$" ||
	    req.url ~ "^/phpMyAdmin/.*$" ||
	    req.url ~ "^/update\.php$" ||
	    req.url ~ "^/ooyala/ping$" ||
	    req.url ~ "^/admin" ||
	    req.url ~ "^/admin/.*$" ||
	    req.url ~ "^/user" ||
	    req.url ~ "^/user/.*$" ||
	    req.url ~ "^/users/.*$" ||
	    req.url ~ "^/info/.*$" ||
	    req.url ~ "^/flag/.*$" ||
	    req.url ~ "^.*/ajax/.*$" ||
	    req.url ~ "^.*/ahah/.*$") {

	       return (pass);
	}

	# Pipe these paths directly to Apache for streaming.
	if (req.url ~ "^/admin/content/backup_migrate/export") {

		return (pipe);
	}

	# Do not allow outside access to cron.php or install.php.
	if (req.url ~ "^/(cron|install)\.php$" && !client.ip ~ internal) {

	    # Have Varnish throw the error directly.
	    error 404 "Page not found.";

	    # Use a custom error page that you've defined in Drupal at the path "404".
	    # set req.url = "/404";
	}

	# Handle compression correctly. Different browsers send different
	# "Accept-Encoding" headers, even though they mostly all support the same
	# compression mechanisms. By consolidating these compression headers into
	# a consistent format, we can reduce the size of the cache and get more hits.=
	# @see: http:// varnish.projects.linpro.no/wiki/FAQ/Compression
	if (req.http.Accept-Encoding) {

	    if (req.url ~ "(?i)\.(jpg|jpeg|png|gif|zip|rar|tar|gz|tgz|bz2|tbz|mp3|mp4|ogg|swf|flv|ts)(\?[a-z0-9]+)?$") {

                # don't try to compress already compressed files
                remove req.http.Accept-Encoding;
            }
	    elsif (req.http.Accept-Encoding ~ "gzip") {

	      # If the browser supports it, we'll use gzip.
	      set req.http.Accept-Encoding = "gzip";
	    }
	    elsif (req.http.Accept-Encoding ~ "deflate") {

	      # Next, try deflate if it is supported.
	      set req.http.Accept-Encoding = "deflate";
	    }
	    else {

	      # Unknown algorithm. Remove it and send unencoded.
	      unset req.http.Accept-Encoding;
	    }
	}

	# Remove all cookies that Drupal doesn't need to know about. ANY remaining
	# cookie will cause the request to pass-through to Apache. For the most part
	# we always set the NO_CACHE cookie after any POST request, disabling the
	# Varnish cache temporarily. The session cookie allows all authenticated users
	# to pass through as long as they're logged in.
	if (req.http.Cookie) {

	    # Appending space at the beginning of cookie string.
	    set req.http.Cookie = ";" + req.http.Cookie;

	    # Replacing all spaces that are after semicolumns with just semicolumn
	    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");

	    # Replacing ";SESS#.." or "NO_CACHE" with "; SESS#" or "; NO_CACHE"
	    set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|NO_CACHE)=", "; \1=");

	    # Replacing spaces after semicolumn.
	    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
	    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

	    # Remove empty cookies.
	    if (req.http.Cookie == "" || req.http.Cookie ~ "^\s*$") {

	      # If there are no remaining cookies, remove the cookie header. If there
	      # aren't any cookie headers, Varnish's default behavior will be to cache
	      # the page.
	      unset req.http.Cookie;
	    }
	    else {

	      # If there is any cookies left (a session or NO_CACHE cookie), do not
	      # cache the page. Pass it on to Apache directly.
	      return (pass);
	    }
	}

	 if (req.http.host == "nilecode.local") {

		#You will need the following line only if your backend has multiple virtual host names
		set req.http.host = "nilecode.local";
		set req.backend = Nilecode;
		return (lookup);
	    }
	if (req.http.host == "b2b.local") {

		#You will need the following line only if your backend has multiple virtual host names
		set req.http.host = "b2b.local";
		set req.backend = B2B;
		return (lookup);
	}

	return (lookup);
}

sub vcl_fetch {

	set    beresp.http.Copyright = "Nilecode";
	set    beresp.http.Author    = "Ahmed Kamal";
	#set    beresp.http.Server    = server.ip;

	# All object will be kept up as stale if needed to five hours past their expiration time or a fresh object is generated.
  	set beresp.grace = 5h;

	# beresp == Back-end response from the web server.
	# Add a unique header containing the cache servers IP address:

	## If the request to the backend returns a code other than 200, restart the loop
        ## If the number of restarts reaches the value of the parameter max_restarts,
        ## the request will be error'ed.  max_restarts defaults to 4.  This prevents
        ## an eternal loop in the event that, e.g., the object does not exist at all.
	if (beresp.status == 503 || beresp.status == 501 || beresp.status == 500) {

		## Doesn't seem to work as expected, serve the good page from the cache and re-check in one minute.
		set beresp.saintmode = 10s;
		set beresp.grace     = 60s;
		return(restart);
        }

	elsif (beresp.status == 301) {

		set beresp.ttl = 1h;
		return(deliver);
	}

	# Don't allow static files to set cookies, in order to get the files cached.
        if (req.url ~ "(?i)\.(bmp|jpg|jpeg|png|gif|ico|css|js|html|htm|eot|otf|svg|ttf|woff|zip|rar|tar|gz|tgz|bz2|tbz|doc|pdf|txt|rtf|wav|mp3|mp4|ogg|flv|swf|m3u|m3u8|ts)(\?[a-z0-9]+)?$") {

		unset beresp.http.set-cookie;
        }

	# Added security, the "w00tw00t" attacks are pretty annoying so lets block it before it reaches our webserver.
        if (req.url ~ "^/w00tw00t") {

	         error 403 "Not permitted";
        }

        # You don't wish to cache content for logged in users.
        if(req.http.Cookie ~"(UserID|_session)") {

                set beresp.http.X-Cacheable = "NO:Got Session";
                return(hit_for_pass);
        }

        # You are respecting the Cache-Control=private header from the backend
        elsif ( beresp.http.Cache-Control ~ "private") {

		unset beresp.http.Expires;
                set beresp.http.X-Cacheable = "NO:Cache-Control=private";
                return(hit_for_pass);
        }

        elsif (beresp.http.Cache-Control ~ "(no-cache|no-store)" || beresp.http.Pragma ~ "no-cache") {

		unset beresp.http.Expires;
		set beresp.http.X-Cacheable = "Refetch forced by user";
	    	return(hit_for_pass);
	}

	# Anything that is cacheable, but has expiration date too low which prevents caching gets cached by varnish to take
  	# the load off apache.
        elsif ( beresp.ttl < 1s ||
		beresp.http.Set-Cookie ||
        	beresp.http.Vary == "*") {

		# You are extending the lifetime of the object artificially by setting how long Varnish will keep it.
                set beresp.ttl   	    = 5m;
                set beresp.grace 	    = 300s;
                set beresp.http.X-Cacheable = "YES:FORCED";

		# Marker for vcl_deliver to reset Age.
	    	set beresp.http.magicmarker = "1";

		return(hit_for_pass);
        }

        # Varnish determined the object was cacheable.
        else {

                set beresp.http.X-Cacheable = "YES";
        }

        return(deliver);
}

## Deliver
sub vcl_deliver {

	## We'll be hiding some headers added by Varnish. We want to make sure people are not seeing we're using Varnish.

        ## Since we're not caching (yet), why bother telling people we use it?
        remove resp.http.X-Varnish;
	remove resp.http.X-Drupal-Cache;
        remove resp.http.Via;

	## We'd like to hide the X-Powered-By headers. Nobody has to know we can run PHP and have version xyz of it.
        remove resp.http.X-Powered-By;

	# To add a header indicating whether a request was a cache-hit or miss
	if (obj.hits > 0) {

                set resp.http.X-Cache 	   = "HIT";
		set resp.http.X-Cache-Hits = obj.hits;

		# Chaning Age to X-Age.
		set resp.http.X-Age = resp.http.Age;
		remove resp.http.Age;
        } else {

                set resp.http.X-Cache = "MISS";
        }

	# The magic marker is used to reset the age to 0 as else the object is older than its ttl.
	if (resp.http.magicmarker) {

		# Remove the magic marker
		unset resp.http.magicmarker;

		# By definition we have a fresh object
		set resp.http.X-Age = "0";
	}
}

sub vcl_pipe {
     /* Force the connection to be closed afterwards so subsequent reqs don't use pipe */
     set bereq.http.connection = "close";
}

# Routine used to determine the cache key if storing/retrieving a cached page.
sub vcl_hash {

	# Include cookie in cache hash to serve cached content to users with cookies.
	#
	# This check is unnecessary because we already pass on all cookies.
	#if (req.http.Cookie) {
	#  set req.hash += req.http.Cookie;
	#}
	if (req.http.X-Forwarded-Proto == "https") {

		hash_data(req.http.X-Forwarded-Proto);
	}

	hash_data(req.url);

	if (req.http.host) {

		hash_data(req.http.host);
	} else {

		hash_data(server.ip);
	}

	return (hash);
}

sub vcl_hit {

	if (req.request == "PURGE") {

		ban_url(req.url);
		purge;
		error 200 "Purged.";
	}

	if (!obj.ttl > 0s){

		return(pass);
	}

	return (pass);
}

sub vcl_miss {

	if (req.request == "PURGE") {

		purge;
		error 200 "Not in cache.";
	}

	return (fetch);
}

sub vcl_error {

        if (obj.status == 503 && req.restarts < 4) {

                return(restart);
        } else {

		  # Redirect to some other URL in the case of a homepage failure.
		  #if (req.url ~ "^/?$") {
		  #  set obj.status = 302;
		  #  set obj.http.Location = "http://backup.example.com/";
		  #}

		  # Otherwise redirect to the homepage, which will likely be in the cache.
		  set obj.http.Content-Type = "text/html; charset=utf-8";
		  set obj.http.Retry-After = "5";
		  synthetic {"
		<!doctype html>
		<html>
		<head>
		  <title>Page Unavailable - "} + obj.status + " " + obj.response + {"</title>
		  <style>
		    body { background: #303030; text-align: center; color: white; }
		    #page { border: 1px solid #CCC; width: 500px; margin: 100px auto 0; padding: 30px; background: #323232; }
		    a, a:link, a:visited { color: #CCC; }
		    .error { color: #222; }
		  </style>
		</head>
		<body onload="setTimeout(function() { window.location = '/' }, 15000)">
		  <div id="page">
	            <h1 class="title">Error Page Unavailable</h1>
		    <div class="error">(Error "} + obj.status + " " + obj.response + {")</div>
		    <p>The page you requested is temporarily unavailable.</p>
		    <h3>Guru Meditation:</h3>
		    <p>XID: "} + req.xid + {"</p>
		    <hr>
		    <p>Varnish cache server</p>
		    <p>We're redirecting you to the <a href="/">homepage</a> in 5 seconds.</p>
		  </div>
		</body>
		</html>
		"};
		  return (deliver);
	}
}


sub vcl_init {

    return (ok);
}

sub vcl_fini {

    return (ok);
}
