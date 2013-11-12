#! /usr/bin/perl

use Modern::Perl;
use Curses::UI;
use DBI;
use XML::Feed;
use LWP::Simple;
use encoding "utf-8";

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=feed.db",
) or die $DBI::errstr;


$dbh->do("DROP TABLE IF EXISTS Articles");
$dbh->do("CREATE TABLE Articles(id INT PRIMARY KEY, Name TEXT UNIQUE, Title TEXT UNIQUE, Desc TEXT UNIQUE, Link TEXT UNIQUE");

my $to_fetch = "madmoizelle";

my $sth = $dbh->prepare("SELECT Name, URL FROM FeedsNames WHERE Name = ?");
$sth->execute($to_fetch);

my $row;
my $val1;
my @val1;

while ($row = $sth->fetchrow_arrayref()) {
    my $feed = XML::Feed->parse(URI->new(@$row[1]));
    
    for my $entry ($feed->entries) {
	my $title = $entry->title;
	push @val1, $title . ",";
    }
}

$val1 = @val1;
my $i = 0;

foreach (@val1) {
    say $i . "=" . $_;
    $i++;
}
    
