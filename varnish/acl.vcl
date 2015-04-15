##
# @file
# Varnish configuration - Access control list configurations settings.
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

# Define the internal network subnet.
# These are used below to allow internal access to certain files while not
# allowing access from the public internet.
acl internal {
  "localhost";
  "127.0.0.1"/24;
  "::1"/24;
  "192.10.0.0"/24; /* and everyone on the local network */
  ! "192.0.2.23"; /* except for the dialin router */
}
