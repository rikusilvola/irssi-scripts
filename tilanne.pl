#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use HTML::TreeBuilder 3 -weak;
use Encode;

use Irssi;
use Irssi::Irc;
my %IRSSI = (
    authors => 'Riku \'riqpe\' Silvola <riqpe@pingtimeout.net>',
    name => 'peto_track',
    description => 'Uudet hälyt peto-mediasta',
    license => 'GPL v2',
    url => 'none', );
my $timeout = 60000;
my $last_time = "29.08.2012 10:22:41";
# lisää virheen hanskausta kaikkialle
open(FILE, '.petotime');
while (<FILE>) {
  chomp;
  $last_time = $_;
}
close(FILE);
sub parse {
my $url = 'http://www.peto-media.fi/';
my $browser = LWP::UserAgent->new;
my $response = $browser->get($url);
die "Error $response->status_line on $url" unless $response->is_success;
my @halyt;
my $tree = HTML::TreeBuilder->new;
my %args = ( "charset" => "ISO-8859-1" );
$tree->parse($response->decoded_content(%args));
my @lines = $tree->find('tr');
my $latest = $last_time;
foreach my $line (@lines) {
  my @haly = $line->content_list;
  if ($haly[2] && !(ref(($haly[2]->content_list)[0]))) {
    my $time = encode("utf-8", ($haly[2]->content_list)[0]);
    my $place = encode("utf-8", ($haly[0]->content_list)[0]);
    my $thing = encode("utf-8", ($haly[1]->content_list)[0]);
    # muuta pattern variableksi
    $place =~ /.*?(Pori).*/i;
    if (($last_time cmp $time) != 1 && ($last_time ne $time) && $1) {
      $place =~ /(\D+?)\//i;
      $place = $1;
      $time =~ /(\d\d)\:(\d\d)\:(\d\d)/;
      unshift(@halyt, "$1:$2 || $place || $thing");
      if (($latest cmp $time) != 1) {
        $latest = $time
      }
    }
  }
}
foreach my $haly (@halyt) {
  # Muokkaa tähän minne haluat tiedotteiden tulevan
  Irssi::print($haly);
}
$last_time = $latest;
open(FILE, '>.petotime');
print FILE $last_time;
close(FILE);
}
parse();
Irssi::timeout_add($timeout,"parse",undef);
