#!/usr/bin/perl

use Modern::Perl;
use Curses::UI;
use DBI;
use XML::Feed;
#use LWP::Simple;

#-----------------------------------------------------------------------
#Full scope vars and init
#-----------------------------------------------------------------------

open STDERR, '>/dev/null';
 
my $cui = new Curses::UI ( 
    -clear_on_exit => 1, 
    -color_support  => 1,
);

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=feed.db",
) or die $DBI::errstr;

my $current_page = 1;
my %w = ();
my $feed_file = "feed.db";
my @val;
my $value;

unless (-e $feed_file) {
    my $FH;
    open $FH, '>', $feed_file and close $FH;
}
$dbh->do("CREATE TABLE IF NOT EXISTS FeedsNames(id INT PRIMARY KEY, Name TEXT UNIQUE, URL TEXT UNIQUE)");

# ----------------------------------------------------------------------
#Menu
# ----------------------------------------------------------------------

sub select_page($;)
{
    my $nr = shift;
    $current_page = $nr;
    $w{$current_page}->focus;
}

my $menu_manage = [
    { -label => 'Show Feed',		-value	 => sub{select_page(3)}	},
    { -label => 'Add Feed',		-value	 => sub{select_page(1)}	},
    { -label => 'Delete Feed',		-value   => sub{select_page(2)}	},
    { -label => '-----------',		-value	 => sub{}		},
    { -label => 'Quit',			-value	 => sub{quit()}		},
];

my $menu = [
    { -label => 'Menu',			-submenu => $menu_manage	},
];

$cui->add('menu', 'Menubar', -menu => $menu);

# ----------------------------------------------------------------------
#Create the explanation window
# ----------------------------------------------------------------------

my $w0 = $cui->add(
    'w0', 'Window', 
    -border        => 1, 
    -y             => -1, 
    -height        => 3,
);
$w0->add('explain', 'Label', 
  -text => "CTRL+P: previous page  CTRL+N: next page  "
         . "CTRL+X: menu  CTRL+Q: quit"
);

# ----------------------------------------------------------------------
#Page Creation
# ----------------------------------------------------------------------

my %screens = (
    '1'  => 'Add Feed',
    '2'  => 'Delete Feed',
    '3'  => 'Show Feed',
);

my @screens = sort {$a<=>$b} keys %screens;

my %args = (
    -border       => 1, 
    -titlereverse => 0, 
    -padtop       => 2, 
    -padbottom    => 3, 
    -ipad         => 1,
);

while (my ($nr, $title) = each %screens){
    my $id = "window_$nr";
    if ($nr >= 2) {
	$w{$nr} = $cui->add(
	    $id, 'Window',
	    -title => $title,
	    -onfocus => sub{refresh_list($nr)},
	    %args,
	);
    } else {
	$w{$nr} = $cui->add(
	    $id, 'Window', 
	    -title => $title,
	    %args
	    );
    }
}

#---------------------------------------------------------------------------
#Refresh pages 2 and 3 on focus
#---------------------------------------------------------------------------

sub refresh_list() {
    my $nr = shift;
    my $sth = $dbh->prepare("SELECT Name FROM FeedsNames");
    $sth->execute();
    
    if ((my $size = @val) > 0){
	undef @val;
    }
    
    my $feeds_list;
    while ($feeds_list = $sth->fetchrow_arrayref()) {
	push @val, @$feeds_list[0];
    }
    $value = \@val;
    
    if ($nr == 2) {
	$w{$nr}->add(undef, 'Listbox',
		     -y			=> 5,
		     -x			=> 2,
		     -fg		=> "red",
		     -bfg		=> "red",
		     -padbottom		=> 10,
		     -values		=> $value,
		     -width		=> 30,
		     -border		=> 1,
		     -multi		=> 1,
		     -title		=> 'Feed List',
		     -vscrollbar	=> 1,
		     -onchange		=> \&add_to_del,
	    );
    } else {
	$w{$nr}->add(undef, 'Listbox',
		     -y			=> 5,
		     -x			=> 2,
		     -fg		=> 'green',
		     -bfg		=> 'green',
		     -padbottom		=> 10,
		     -values		=> $value,
		     -width		=> 15,
		     -border		=> 1,
		     -title		=> 'Feed List',
		     -vscrollbar	=> 1,
		     -onchange		=> \&fetch_articles,
	    );
    }
}

    
# ----------------------------------------------------------------------
#Add Feed
# ----------------------------------------------------------------------

$w{1}->add(undef, 'Label',
	   -border	=> 1,
	   -fg		=> 'blue',
	   -bfg		=> 'blue',
	   -text	=> "Here you can add feed. Just fill in\n"
			."the empty fields and press add =)",
	   -x		=> 15,
);

$w{1}->add('FeedNameText', 'TextEntry',
	   -fg		=> 'blue',
	   -x		=> 1,
	   -y		=> 7,
	   -width	=> 10,
	   -text	=> 'Feed Name',
	   -focusable	=> 0,
	   -readonly	=> 1,
);

my $FeedName = $w{1}->add('FeedName', 'TextEntry',
			  -border	=> 1,
			  -bfg		=> 'blue',
			  -x		=> 13,
			  -y		=> 6,
			  -width	=> 20,
);

$w{1}->add('FeedURLText', 'TextEntry',
	     -fg	=> 'blue',
	     -x		=> 1,
	     -y		=> 11,
	     -width	=> 10,
	     -text	=> 'Feed Url',
	     -focusable	=> 0,
	     -readonly	=> 1,
);

my $FeedUrl = $w{1}->add('FeedUrl', 'TextEntry',
			 -border	=> 1,
			 -bfg		=> 'blue',
			 -y		=> 10,
			 -x		=> 13,
			 -width		=> 20,
);

$w{1}->add('AddButton', 'Buttonbox',
	   -buttons	=> [ {-label	=> '< ADD >',
			      -onpress	=> \&add_feed } ],
	   -y		=> 15,
	   -x		=> 16,
);

sub add_feed {
    my $sth = $dbh->prepare("INSERT INTO FeedsNames(Name, URL) VALUES(?, ?)");
    $sth->execute($FeedName->get(), $FeedUrl->get())
	or $cui->error("Something went wrong: $DBI::errstr");
    $sth->finish();
}

# ----------------------------------------------------------------------
#Delete Feed
# ----------------------------------------------------------------------
$w{2}->add(undef, 'Label',
	   -border	=> 1,
	   -bfg		=> 'red',
	   -fg		=> 'red',
	   -x		=> 15,
	   -text	=> "Here You can delete feeds you don't want anymore\n"
			  ."To do so, just check the one you want to see removed and press < DEL >",
);

$w{2}->add('DelButton', 'Buttonbox',
	   -buttons	=> [ {-label	=> '< DEL >',
			      -onpress	=> \&del_feed } ],
	   -y		=> 35,
	   -x		=> 10,
);

my @to_del;

sub add_to_del {
    my $listbox = shift;
    my $label = $listbox->parent->getobj('listboxlabel');
    @to_del = $listbox->get;
    @to_del = ('< none >') unless @to_del;
    my $to_del = "selected " . join (", ", @to_del);
    $label->text($listbox->title . " $to_del");
}

$w{2}->add(
    'listboxlabel', 'Label',
    -y => -1,
    -bold => 1,
    -text => "Select the feeds you want to remove please....",
    -width => -1,
);


sub del_feed {
    
    foreach (@to_del) {
	my $sth = $dbh->prepare("DELETE FROM FeedsNames WHERE Name = ?");
	$sth->execute($_)
	    or $cui->errstr("Somethin went wrong: $DBI::errstr");
    }
}

# ----------------------------------------------------------------------
#Show Feed
# ----------------------------------------------------------------------

$w{3}->add(undef, 'Label',
	   -border	=> 1,
	   -bfg		=> 'green',
	   -fg		=> 'green',
	   -x		=> 15,
	   -text	=> "Here you can view your feeds",
);

$w{3}->add('articlename', 'Listbox',
	   -y		=> 5,
	   -x		=> 18,
	   -padbottom	=> 10,
	   -fg		=> 'green',
	   -bfg		=> 'green',
	   -width	=> 40,
	   -border	=> 1,
	   -title	=> 'Article List',
	   -vscrollbar  => 1,
	   -wrapping	=> 1,
	   -onchange	=> \&display_content,
);

$w{3}->add('articletext', 'TextViewer',
	   -title		=> "Article",
	   -fg			=> 'green',
	   -bfg			=> 'green',
	   -border		=> 1,
	   -y			=> 5,
	   -x			=> 60,
	   -padbottom		=> 10,
	   -vscrollbar		=> 1,
	   -wrapping		=> 1,
	   -width		=> 70,
);
	 
sub fetch_articles {
    $dbh->do("DROP TABLE IF EXISTS Articles");
    $dbh->do("CREATE TABLE Articles(id INT PRIMARY KEY, Name TEXT, Title TEXT UNIQUE, Desc TEXT UNIQUE, Link TEXT UNIQUE)");

    my $listbox = shift;
    my $values = $listbox->parent->getobj('articlename');
    my $to_fetch = $listbox->get;
        
    my $sth = $dbh->prepare("SELECT Name, URL FROM FeedsNames WHERE Name = ?");
    $sth->execute($to_fetch);
    
    my $row;
    my $val1;
    my @val1;
    while ($row = $sth->fetchrow_arrayref()) {
	my $feed = XML::Feed->parse(URI->new(@$row[1]));
	
	for my $entry ($feed->entries) {
            my $title = $entry->title;
            my $body = $entry->content->body; $body =~ s|<.+?>||g;
            my $link = $entry->link;
            my $h = $dbh->prepare("INSERT INTO Articles(Name, Title, Desc, Link) VALUES(?,?,?,?)");
            $h->execute(@$row[0], $title, $body, $link);
	    push @val1, $title;
	}
    }
    $val1 = \@val1;
    $values->values($val1); 
}

sub display_content {
    my $listbox = shift;
    my $textview = $listbox->parent->getobj('articletext');
    my $to_display = $listbox->get;
    
    my $sth = $dbh->prepare("SELECT Desc FROM Articles WHERE Title = ?");
    $sth->execute($to_display);
    
    my $row;
    my $text;
    while ($row = $sth->fetchrow_arrayref()) {
	$text = @$row[0];
    }
    $textview->text($text);
}

# ----------------------------------------------------------------------
#Bindings and focus 
# ----------------------------------------------------------------------

$cui->set_binding( sub{ exit }, "\cQ" );
$cui->set_binding( sub{ shift()->root->focus('menu') }, "\cX" );

sub goto_next_page()
{
    $current_page++;
    $current_page = @screens if $current_page > @screens;
    $w{$current_page}->focus;
}
$cui->set_binding( \&goto_next_page, "\cN" );

sub goto_prev_page()
{
    $current_page--;
    $current_page = 1 if $current_page < 1;
    $w{$current_page}->focus;
}
$cui->set_binding( \&goto_prev_page, "\cP" );

$w{$current_page}->focus;
$cui->mainloop;

