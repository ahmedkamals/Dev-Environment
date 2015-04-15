##
# @file
# Varnish configuration - backends settings.
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

backend ahmedkamal { .host = "ahmedkamal.local"; .port = "8090"; .connect_timeout = 15s; .first_byte_timeout = 15s; .between_bytes_timeout = 15s; .max_connections = 210; .probe = ApacheHealthCheck;}

backend ahmedkamals { .host = "ahmedkamals.local"; .port = "8090"; .connect_timeout = 20s; .first_byte_timeout = 20s; .between_bytes_timeout = 20s; .max_connections = 250; .probe = ApacheHealthCheck;}
