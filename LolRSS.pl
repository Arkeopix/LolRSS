#! /usr/bin/perl

use Modern::Perl;

my $done = 0;
my %func_hash = (
    1 => 'add_feed',
    2 => 'show_feeds',
    3 => 'delete_feed',
    4 => 'quit',
    );

my $welcome_text = q|Hello and welcome to LolRSS. What would you like to do ?
1: add a feed
2: show feeds
3: delete a feed
4: quit
|;

my $add_feed_text1 = q|Here you can add a feed. Just follow the instructions.
Fisrt add a name for the feed you want to follow: |;

my $add_feed_text2 = q|
And now add the URL of the feed you want to follow: |;

my $opt_error = "Option must be between 1 and 4\n";

sub add_feed{
    print $add_feed_text1;
    my $feed_name = <STDIN>;
    print $add_feed_text2;
    my $feed_url = <STDIN>;
    
    
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
    {
	no strict 'refs';
	$buff > 4 ?  print $opt_error : &{$func_hash{$buff}}();
    }
}
