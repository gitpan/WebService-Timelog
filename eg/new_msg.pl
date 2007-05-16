#!/usr/bin/perl

# This example demonstrates to update your status on both Twitter and
# Timelog at the same time.

use strict;
use warnings;

use lib qw(lib);
use Net::Twitter;
use WebService::Timelog;
use YAML;

my $status = shift or die "Usage: $0 <status>";

for my $site ((
    Net::Twitter->new(username => $ENV{TWITTER_USER}, password => $ENV{TWITTER_PASS}),
    WebService::Timelog->new(username => $ENV{TIMELOG_USER}, password => $ENV{TIMELOG_PASS}),
)) {
    $site->update($status);
}
