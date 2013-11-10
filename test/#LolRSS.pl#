#! /usr/bin/perl

use Modern::Perl;
use DBI;
use XML::Feed;
use LWP::Simple;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=feed.db",
    {RaiseError => 1}
    ) or die $DBI::errstr;

my $feed_file = "feed.db";

sub add_feed{
    my $feed_name = shift;
    my $feed_url = shift;

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
    $dbh->do("CREATE TABLE Articles(ID INT PRIMARY KEY, Name TEXT, Title TEXT, Desc TEXT, Link TEXT)");
        
    my $sth = $dbh->prepare("SELECT Name, URL FROM FeedsNames");
    $sth->execute();
        
    my $row;
    while ($row = $sth->fetchrow_arrayref()) {
	print "NAME: @$row[0] | URL: @$row[1]\n"; #Test printing
	
	my $feed = XML::Feed->parse(URI->new(@$row[1]))
	    or die XML::Feed->errstr;

	for my $entry ($feed->entries) {
	    my $title = $entry->title;
	    my $body = $entry->content->body; $body =~ s|<.+?>||g;
	    my $link = $entry->link;
	    my $h = $dbh->prepare("INSERT INTO Articles(Name, Title, Desc, Link) VALUES(?,?,?,?)");
	    $h->execute(@$row[0], $title, $body, $link);
	}
    }
    my $query = $dbh->prepare("Select Name, Title, Desc, Link FROM Articles");
    $query->execute();
    my $entries;
    while ($entries = $query->fetchrow_arrayref()) {
	print "@$entries[1]\n @$entries[2]\n\t @$entries[3]";
    }
}

sub delete_feed{
    
}

sub quit{
    $dbh->disconnect();
    exit;
}
