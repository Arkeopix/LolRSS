#! /usr/bin/perl

use Modern::Perl;
use Curses::UI;

my $cui = new Curses::UI (
    -clear_on_exit	=> 1,
    -collor_suport	=> 1,
);

my $current_page = 1;
my %win = ();

#-----------------------------------------------------------------------------
#Menu Creation
#-----------------------------------------------------------------------------

sub select_page($;) {
    my $nr = shift;
    $current_page = $nr;
    $win{$current_page}->focus;
}

my $menu_manage = [
    { -label => 'Add Feed',		-value => sub{select_page(1)}	},
    { -label => 'Delete Feed',		-value => sub{select_page(2)}	},
];

my $menu = [
    { -label => 'Manage Feed',		-submenu => $menu_manage	},
    { -label => 'Show Feed'		-value	 => sub{select_page(3)}	},
    { -label => '-----------',		-value	 => sub{}		},
    { -label => 'Quit',			-value	 => sub{\&quit}		},
];

$cui->add('menu', 'Menubar', -menu => $menu);

#-----------------------------------------------------------------------------
#Explanation Window
#-----------------------------------------------------------------------------

my $win0 = $cui->add('win0', 'Window',
		     -border	=> 1,
		     -y		=> -1,
		     -height	=> 3,
);
$win0->add('explanation', 'Label',
	   -text	=> "CTRL+P: Previous Page CTRL+N: Next Page  "
			   ."CTRL+X: Menu CTRL+Q: Quit"
);

#-----------------------------------------------------------------------------
#Main Screen
#-----------------------------------------------------------------------------

my %pages = (
    '1'	=> 'Add Feed',
    '2' => 'Delete Feed',
    '3' => 'Show Feeds',
);
my @pages = sort{$a<=>$b} keys %pages;

my %args = (
    -border		=> 1,
    -titlereverse	=> 0,
    -padtop		=> 2,
    -padbottom		=> 3,
    -ipad		=> 1,
);

while (my ($nr, $title) = each %pages) {
    my $id = "window_$nr";
    $win{$nr} = $cui->add($id, 'Window',
			  -title => "$title",
			  %args,
	);
}

#----------------------------------------------------------------------------
#Add Feed
#----------------------------------------------------------------------------

$win{1}->add(undef, 'Label'
	     -border	=> 1,
	     -bfg	=> 'blue',
	     -x		=> 30,
	     -text	=> "Here you can add feeds. It's as simple a filling\n"
			  ."the empty fields and clicking < ADD > !!."
			  ."Go o, try it =)"
);
    
$win{1}->add('FeedNameText', 'TextEntry',
	     -border	=> 0,
	     -fg	=> 'blue',
	     -x		=> 5,
	     -y		=> 9,
	     -width	=> 10,
	     -text	=> 'Feed Name',
	     -focusable	=> 0,
	     -readonly	=> 1,
);

my $FeedName = $win{1}->add('FeedName', 'TextEntry',
			    -border	=> 1,
			    -bfg	=> 'blue',
			    -x		=> 15,
			    -y		=> 8,
			    -width	=> 20,
);

$win{1}->add('FeedURLText', 'TextEntry',
	     -border	=> 0,
	     -fg	=> 'blue',
	     -x		=> 5,
	     -y		=> 13,
	     -width	=> 10,
	     -text	=> 'Feed Url',
	     -focusable	=> 0,
	     -readonly	=> 1,
);

my $FeedUrl = $win{1}->add('FeedURL', 'TextEntry',
			   -border	=> 1,
			   -bfg		=> 'blue',
			   -y		=> 12,
			   -x		=> 15,
			   -width	=> 20,
);


my $add_button = $win{1}->add('AddButton', 'Buttonbox',
			      -buttons	=>[{-label	=> "< ADD >",
					    -onpress	=> \&add_feed}],
			      -y	=> 16,
			      -x	=> 15,
);

#----------------------------------------------------------------------
#Delete Feed
#----------------------------------------------------------------------

$win{2}->add(undef, 'Label'
	     -border	=> 1,
	     -bfg	=> 'red',
	     -x		=> 30,
	     -text	=> "Here you can delete feeds. Just check the"
			  ."one you want to supress",
);

$win{2}->add(undef, 'Listbox',
	     -y		=> 5,
	     -x		=> 2,
	     -padbottom	=> 10,
	     -fg	=> 'red',
	     -bfg	=> 'red',
	     -values	=> [1, 2, 3,],
	     -labels	=> {1 => 'lol', 2 => 'poil', 3 => 'mdr'},
	     -width	=> 40,
	     -border	=> 1,
	     -multi	=> 1,
	     -title	=> 'Feed List',
	     -vscrollbar=> 1,
	     -onchange	=> \&add_to_delete,
);

my $del_button = $win{2}->add('DelButton', 'Buttonbox'
			      -buttons	=>[ { -label	=> '< DEL >',
					      -onpress	=> \&delete_feed } ],
			      -y	=> 40,
			      -x	=> 5,
);

#----------------------------------------------------------------------------
#Show Feeds
#----------------------------------------------------------------------------



#----------------------------------------------------------------------------
#Bindings and Focus
#----------------------------------------------------------------------------
$cui->set_binding(\&quit, "\cQ");
$cui->set_binding(sub{ shift()->root->focus('menu') }, "\cX");

sub goto_next_page() {
    $current_page++;
    $current_page = @pages if $current_page > @pages;
    $win{$current_page}->focus;
}
$cui->set_binding(\&goto_next_page, "\cN" );

sub goto_prev_page() {
    $current_page--;
    $current_page = 1 if $current_page < 1;
    $win{$current_page}->focus;
}
$cui->set_binding(\&goto_prev_page, "\cP");

$win{$current_page}->focus;

$cui->mainloop;
