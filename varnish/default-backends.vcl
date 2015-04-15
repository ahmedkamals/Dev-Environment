##
# @file
# Varnish configuration - default backends settings.
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

# .window is how many of the latest polls we examine
# .threshold is how many of those must have succeeded for us to consider the backend healthy.

# Define the list of backends (web servers).
# Port 80 Backend Servers

probe ApacheHealthCheck {
  .request =
  "GET /apache-status HTTP/1.1"
  "Host: localhost"
  "Connection: close";
  .interval = 5s;
  .timeout = 10s;
  .window = 5;
  .threshold = 1;
  .expected_response = 200;
}

probe NginxHealthCheck {
  .request =
  "GET /ngnix-status HTTP/1.1"
  "Host: localhost"
  "Connection: close";
  .interval = 5s;
  .timeout = 10s;
  .window = 5;
  .threshold = 1;
  .expected_response = 200;
}

backend default { .host = "127.0.0.1"; .port = "8090"; .connect_timeout = 15s; .first_byte_timeout = 15s; .between_bytes_timeout = 15s; .max_connections = 210; .probe = ApacheHealthCheck;}

backend Apache { .host = "127.0.0.1"; .port = "8090"; .connect_timeout = 20s; .first_byte_timeout = 20s; .between_bytes_timeout = 20s; .max_connections = 250; .probe = ApacheHealthCheck;}

backend Nginx { .host = "localhost"; .port = "80"; .connect_timeout = 10s; .first_byte_timeout = 10s; .between_bytes_timeout = 10s; .max_connections = 250; .probe = NginxHealthCheck;}

# Set up a "patient" back end; you can collect your back ends into a patient director.
backend WaitALongTime_Apache { .host = "127.0.0.1"; .port = "8090"; .connect_timeout=600s; .first_byte_timeout = 600s; .between_bytes_timeout = 600s; .max_connections = 250; .probe = { .url = "/apache-status"; .interval = 10s; .timeout = 15s; .window = 5; .threshold = 1; }}

backend WaitALongTime_Nginx { .host = "127.0.0.1"; .port = "80"; .connect_timeout=600s; .first_byte_timeout = 600s; .between_bytes_timeout = 600s; .max_connections = 250; }

# Port 443 Backend Servers for SSL
backend Apache_SSL { .host = "127.0.0.1"; .port = "443"; .connect_timeout = 20s; .first_byte_timeout = 20s; .between_bytes_timeout = 20s; .max_connections = 250; .probe = { .url = "/apache-status"; .interval = 5s; .timeout = 1s; .window = 5; .threshold = 3; }}

backend WaitALongTime_SSL { .host = "127.0.0.1"; .port = "443"; .connect_timeout=600s; .first_byte_timeout = 600s; .between_bytes_timeout = 600s; .max_connections = 250; .probe = { .url = "/nginx-status"; .interval = 10s; .timeout = 15s; .window = 5; .threshold = 3; }}

# Define the directors that determines how to distribute incoming requests which cycle between web servers, and choose from different backends based on health status and a per-director algorithm. There currently exists a round-robin and a random director.

director Default_Director round-robin {

  /* or refer to named backends */
  { .backend = default;}
  { .backend = Apache;}
}

# The random director takes one per-director option .retries. This specifies how many tries it will use to find a working backend. The default is the same as the number of backends defined for the director.
director SSL_Director random {

  .retries = 5;

  { .backend = Apache_SSL; .weight = 1; }
    /* We can define them inline */
  {
      .backend = { .host = "127.0.0.1"; .port = "443"; .connect_timeout = 30s; .first_byte_timeout = 30s; .between_bytes_timeout = 30s; }
      .weight = 2;
  }

}
