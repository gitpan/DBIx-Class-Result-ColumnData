#!/usr/bin/perl -w

use Test::More;

use t::app::Main;
use strict;

use DateTime;

system "sqlite3 t/app/db/example.db < t/app/db/example.sql";
if ($@)
{
  plan skip_all => "sqlite3 is require for these tests : $@";
  exit;
}
eval "use DBIx::Class::Result::Validation";
if ($@)
{
  plan skip_all => "This test is about compatibility with component Result::Validation but you don't install it";
  exit;
}

plan tests => 2;

system "perl t/app/insertdb.pl";

my $schema = t::app::Main->connect('dbi:SQLite:t/app/db/example.db');

my @rs = $schema->resultset('ValidCd')->search({'title' => 'Bad'});
my $cd = $rs[0];
my $rh_result = {'artistid' => $cd->artistid(),'cdid' => $cd->cdid(),'title' => $cd->title, 'date' => undef, 'last_listen' => undef};
is_deeply( $cd->columns_data, $rh_result, "columns_data return all column value of object");

$cd->add_result_error("key 1", "comment 1 to key 1");
$cd->add_result_error("key 1", "comment 2 to key 1");
$cd->add_result_error("key 2", "comment 1 to key 2");
$rh_result->{'result_errors'} = {'key 1' => ["comment 1 to key 1","comment 2 to key 1"],'key 2' => ["comment 1 to key 2"]};
is_deeply( $cd->columns_data, $rh_result, "columns_data return all column value of object with result_errors column");

