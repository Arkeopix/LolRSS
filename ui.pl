#!/usr/bin/perl

use Modern::Perl;
use Curses::UI;

# Create the root object and main window.
my $cui = new Curses::UI ( 
    -clear_on_exit => 1, 
    -color_support => 1,
);
$cui->set_binding( \&quit, "\cQ");

my $main = $cui->add(
    'mainw', 'Window',
    -title => 'Main Window',
);
$main->add(
    undef, 'Label',
    -y     => $main->height - 1,
    -width => $main->width,
    -text  => '<PageUp> / <PageDown> cycles through pages; <Ctrl>-Q exits',
    -textalignment => 'middle',
    -bold  => 1,
);


# Create notebook and a couple of pages.
my $notebook = $main->add(
    undef, 'Notebook',
    -height => $main->height - 1,
);

my $page_manage_feed = $notebook->add_page("Manage Feed");
$page_manage_feed->add(
    undef, 'Label',
    -border	=> 1,
    -bfg	=> 'blue',
    -text	=> "Here You can Manage your Feeds.\n"
		  ."To add a Feed you just have to fill the empty fields and press the add Button\n"
		  ."To delete a feed, just check it and press the delete button",
    -x		=> 30,
    );

$page_manage_feed->add(
    'FeedNameText', 'TextEntry',
    -border	=> 0,
    -fg		=> 'blue',
    -x		=> 1,
    -y		=> 6,
    -width	=> 10,
    -text	=> 'Feed Name',
    -focusable	=> 0,
    -readonly	=> 1,
    );

my $FeedName = $page_manage_feed->add(
    'FeedName', 'TextEntry',
    -border	=> 1,
    -bfg	=> 'blue',
    -x		=> 12,
    -y		=> 5,
    -width	=> 20,
    );

$page_manage_feed->add(
    'FeedURLText', 'TextEntry',
    -border	=> 0,
    -fg		=> 'blue',
    -x		=> 1,
    -y		=> 10,
    -width	=> 10,
    -text	=> 'Feed Url',
    -focusable	=> 0,
    -readonly	=> 1,
    );

my $FeedUrl = $page_manage_feed->add(
    'FeedURL', 'TextEntry',
    -border	=> 1,
    -bfg	=> 'blue',
    -y		=> 9,
    -x		=> 12,
    -width	=> 20,
    );


my $add_button = $page_manage_feed->add(
    'AddButton', 'Buttonbox',
    -buttons	=>[{-label	=> "< ADD >",
		    -onpress	=> \&add_feed}],
    -y		=> 12,
    -x		=> 5,
    );
		    
$page_manage_feed->add(
    undef, 'Listbox',
    -y		=> 5,
    -x		=> 90,
    -padbottom	=> 10,
    -fg		=> 'red',
    -fbg	=> 'red',
    -values	=> [1, 2, 3],
    -labels	=> {1 => 'lol', 2 => 'poil', 3 => 'mdr'},
    -width	=> 40,
    -border	=> 1,
    -multi	=> 1,
    -title	=> 'List of Feeds',
    -vscrollbar	=> 1,
    -onchange	=> \&add_to_del,
    );

my $del_button = $page_manage_feed->add(
    'DelButton', 'Buttonbox',
    -buttons	=>[{-label	=> "< DEL >",
		    -onpress	=> \&Delete_feed}],
    -y		=> 40,
    -x		=> 90,
    );


#my $page_show_feed = $notebook->add_page("Show Feed");
#$page_show_feed->add(
    #insert code here
#   );

$notebook->focus;
$cui->mainloop;
