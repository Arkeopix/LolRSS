#! /usr/bin/perl

use Modern::Perl;

my $done = 0;
my %func_hash = (
    1 => 'add_feed',
    2 => 'show_feeds',
    3 => 'delete_feed',
    4 => 'quit',
    );

my $welcome_text = q|
Hello and welcome to LolRSS. What would you like to do ?
1: add a feed
2: show feeds
3: delete a feed
4: quit
|;



sub add_feed{
    print "coucou";
}

sub show_feeds{

}

sub delete_feed{

}

sub quit{
    
}

while ($done == 0) {
    print $welcome_text;
    my $buff = <STDIN>;
    chomp $buff;
    &{$func_hash{$buff}}();
}
