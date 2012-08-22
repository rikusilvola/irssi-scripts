#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use Irssi;       
use Irssi::Irc; 

sub getRatings{
  my ($movie, $server, $target) = @_;                                
  my $uri = "http://www.imdbapi.com/?t=" . $movie . "&tomatoes=true"; 
  my $imdb;
  my $rotten;
  my $year;
  my $html = get($uri) or die "Could not fetch " . $uri;
  
  $html =~ /Title\"\:(\".+?\")/i;
  $movie = $1;
  $html =~ /Year\"\:\"(\d\d\d\d)/i;
  $year  = $1;

  $html =~ /Rating\"\:\"(\d.\d)/i;
  $imdb = $1;

  $html =~ /tomatoMeter\"\:\"(\d\d).+?\:.+?\:\"(\d\.\d)(")/i;
  $rotten = $1 . "% / " . $2 . " "; 

  Irssi::print("$movie ($year) :: imdb: $imdb rotten: $rotten"); 
}

Irssi::command_bind('rating', 'getRatings');                                   
