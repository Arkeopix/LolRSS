#! /usr/bin/perl

use Modern::Perl;
use Curses::UI;

my $cui = new Curses::UI ( 
    -clear_on_exit => 1, 
    -color_support  => 1,
);

my $current_demo = 1;
my %w = ();

# ----------------------------------------------------------------------
# Create a menu
# ----------------------------------------------------------------------

sub select_page($;)
{
    my $nr = shift;
    $current_demo = $nr;
    $w{$current_demo}->focus;
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
# Ceate the explanation window
# ----------------------------------------------------------------------

my $w0 = $cui->add(
    'w0', 'Window', 
    -border        => 1, 
    -y             => -1, 
    -height        => 3,
);
$w0->add('explain', 'Label', 
  -text => "CTRL+P: previous demo  CTRL+N: next demo  "
         . "CTRL+X: menu  CTRL+Q: quit"
);

# ----------------------------------------------------------------------
# Create the demo windows
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

while (my ($nr, $title) = each %screens)
{
    my $id = "window_$nr";
    $w{$nr} = $cui->add(
        $id, 'Window', 
        -title => $title,
        %args
    );
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

# ----------------------------------------------------------------------
# Delete Feed
# ----------------------------------------------------------------------

$w{2}->add(undef, 'Label',
	   -border	=> 1,
	   -bfg		=> 'red',
	   -fg		=> 'red',
	   -x		=> 15,
	   -text	=> "Here You can delete feeds you don't want anymore\n"
			  ."To do so, just check the one you want to see removed and press < DEL >",
);

$w{2}->add(undef, 'Listbox',
	   -y		=> 5,
	   -x		=> 2,
	   -padbottom	=> 10,
	   -fg		=> 'red',
	   -bfg		=> 'red',
	   -values	=>[1, 2, 3,],
	   -labels	=> {1 => 'lol', 2 => 'poil', 3 => 'mdr'},
	   -width	=> 40,
	   -border	=> 1,
	   -multi	=> 1,
	   -title	=> 'Feed List',
	   -vscrollbar  => 1,
	   -onchange	=> \&add_to_delete,
);

$w{2}->add('DelButton', 'Buttonbox',
	   -buttons	=> [ {-label	=> '< DEL >',
			      -onpress	=> \&add_feed } ],
	   -y		=> 35,
	   -x		=> 10,
);


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

$w{3}->add(undef, 'Listbox',
	   -y		=> 5,
	   -x		=> 2,
	   -padbottom	=> 10,
	   -fg		=> 'green',
	   -bfg		=> 'green',
	   -values	=>[1, 2, 3,],
	   -labels	=> {1 => 'lol', 2 => 'poil', 3 => 'mdr'},
	   -width	=> 20,
	   -border	=> 1,
	   -title	=> 'Feed List',
	   -vscrollbar  => 1,
	   -onchange	=> \&fetch_articles,
);

$w{3}->add(undef, 'Listbox',
	   -y		=> 5,
	   -x		=> 30,
	   -padbottom	=> 10,
	   -fg		=> 'green',
	   -bfg		=> 'green',
	   -values	=>[1, 2, 3,],
	   -labels	=> {1 => 'lol', 2 => 'poil', 3 => 'mdr'},
	   -width	=> 20,
	   -border	=> 1,
	   -title	=> 'Article List',
	   -vscrollbar  => 1,
	   -onchange	=> \&display_content,
);

$w{3}->add('articletext', 'TextViewer',
	   -title		=> "Article",
	   -text		=> "lol",
	   -fg			=> 'green',
	   -bfg			=> 'green',
	   -border		=> 1,
	   -y			=> 5,
	   -x			=> 55,
	   -padbottom		=> 10,
	   -vscrollbar		=> 1,
	   -wrapping		=> 1,
	   -width		=> 70,
);
	 


# ----------------------------------------------------------------------
#Bindings and focus 
# ----------------------------------------------------------------------

$cui->set_binding( sub{ exit }, "\cQ" );
$cui->set_binding( sub{ shift()->root->focus('menu') }, "\cX" );

sub goto_next_demo()
{
    $current_demo++;
    $current_demo = @screens if $current_demo > @screens;
    $w{$current_demo}->focus;
}
$cui->set_binding( \&goto_next_demo, "\cN" );

sub goto_prev_demo()
{
    $current_demo--;
    $current_demo = 1 if $current_demo < 1;
    $w{$current_demo}->focus;
}
$cui->set_binding( \&goto_prev_demo, "\cP" );

$w{$current_demo}->focus;
$cui->mainloop;

