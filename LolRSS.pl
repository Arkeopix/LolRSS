#! /usr/bin/perl

use Modern::Perl;
use DBI;
use XML::Feed;
use LWP::Simple;
use utf8;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=feed.db",
    {RaiseError => 1}
    ) or die $DBI::errstr;

my %func_hash = (
    1 => 'add_feed',
    2 => 'show_feeds',
    3 => 'delete_feed',
    4 => 'quit',
    );

my $feed_file = "feed.db";

my $welcome_text = q|Hello and welcome to LolRSS. What would you like to do ?
1: add a feed
2: show feeds
3: delete a feed
4: quit
|;

my $add_feed_text1 = q|Here you can add a feed. Just follow the instructions.
First add a name for the feed you want to follow: |;
my $add_feed_text2 = "And now add the URL of the feed you want to follow: ";

my $quit_text = "Later mon\n";


my $opt_error = "Option must be between 1 and 4\n";
my $opn_error = "Could not open file\n";
my $feed_exists_error = "Feed name/url already exists: ";

sub add_feed{
    print $add_feed_text1;
    my $feed_name = <STDIN>;
    chomp $feed_name;
    print $add_feed_text2;
    my $feed_url = <STDIN>;
    chomp $feed_url;
    
    unless (-e $feed_file) {
	my $FH;
	open $FH, '>', $feed_file and close $FH;
    }
    
    $dbh->do("CREATE TABLE IF NOT EXISTS FeedsNames(Id INT PRIMARY KEY, Name TEXT UNIQUE, URL TEXT UNIQUE)");
    my $sth = $dbh->prepare("INSERT INTO FeedsNames(Name, URL) VALUES(?, ?)");
    $sth->execute($feed_name, $feed_url);
    $sth->finish();
}

sub show_feeds{
    $dbh->do("DROP TABLE IF EXISTS Articles");
    $dbh->do("CREATE TABLE Articles(ID INT PRIMARY KEY, Name TEXT, Title TEXT, Link TEXT)");
        
    my $sth = $dbh->prepare("SELECT Name, URL FROM FeedsNames");
    $sth->execute();
        
    my $row;
    while ($row = $sth->fetchrow_arrayref()) {
	print "NAME: @$row[0] | URL: @$row[1]\n"; #Test printing
	
	my $feed = XML::Feed->parse(URI->new(@$row[1]))
	    or die XML::Feed->errstr;
	
	for my $entry ($feed->entries) {
	    #do stuff here
	}
	print "quit\n";
    }
}

sub delete_feed{
    
}

sub quit{
    print $quit_text; 
    $dbh->disconnect();
    exit;
}

while (42) {
    print $welcome_text;
    my $buff = <STDIN>;
    chomp $buff;    
    
    {
	no strict 'refs';
	$buff > 4 ?  print $opt_error : &{$func_hash{$buff}}();
    }
}
