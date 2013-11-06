#! /usr/bin/perl

use Modern::Perl;
use DBI;
use XML::Feed;
use LWP::Simple;
use utf8;
use Curses;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=feed.db",
    {RaiseError => 1}
    ) or die $DBI::errstr;

initscr();
clear();
noecho();
cbreak();

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
    my $add_win = newwin($COLS, $LINES, 0, 0);
    clear();
    addstr(0, 0,  $add_feed_text1);
    refresh();
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
}

sub delete_feed{
    
}

sub quit{
    print $quit_text; 
    $dbh->disconnect();
    clrtoeol();
    refresh();
    endwin();
    exit;
}

my $width = 30;
my $height = 10;
my $startx = ($COLS - $width) / 2;
my $starty = ($LINES - $height) / 2;
my $menu_win = newwin($height, $width, $starty, $startx);

my @choices = (
    "Add Feed",
    "Show Feed",
    "Delete Feed",
    "Quit",
    );

my $n_choices = @choices;
my $highlight = 1;
my $choice = 0;

keypad(1);
keypad($menu_win, 1);
addstr(0, 0, "Use arrow keys to go up and down, Press enter to select a choice");
refresh();
print_menu($menu_win, $highlight);

while (42) {

    my $c = getch($menu_win);
    if ($c eq KEY_UP) {
        if ($highlight == 1) {
            $highlight = $n_choices;
        }
        else {
            $highlight--;
        }
    }
    elsif ($c eq KEY_DOWN) {
        if ($highlight == $n_choices) {
            $highlight = 1;
        }
        else {
            $highlight++;
        }
    }
    elsif ($c eq "\n") {
	{
	    no strict 'refs';
	    $choice = $highlight;
	    &{$func_hash{$choice}}();
	}
    }
    print_menu($menu_win, $highlight);
    last if ($choice);
}


sub print_menu {
    $menu_win = shift;
    $highlight = shift;

    my $x = 2;
    my $y = 2;
    box($menu_win, 0, 0);
    for (my $i = 0; $i < $n_choices; $i++) {
        if ($highlight == $i + 1) {
            attron($menu_win, A_REVERSE);
            addstr($menu_win, $y, $x, $choices[$i]);
            attroff($menu_win, A_REVERSE);
        }
        else {
            addstr($menu_win, $y, $x, $choices[$i]);
        }
        $y++;
    }
    refresh($menu_win);
}

