#!/usr/bin/perl

use Modern::Perl;
use Curses::UI;

# Create the root object and main window.
my $cui = new Curses::UI ( 
    -clear_on_exit => 1, 
);
$cui->set_binding( sub { exit(0); } , "\cQ");

my $main = $cui->add(
    undef, 'Window',
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
    #insert code here
    );

my $page_show_feed = $notebook->add_page("Show Feed");
$page_showw_feed->add(
    #insert code here
    );

#my @pagename = (
#    "Manage Feed",
#    "Show Feed",
#    );
#my @pages;
#for (my $i = 1; $i <= 2; ++$i) {
#    $pages[$i] = $notebook->add_page("$pagename[$i -1]");
#    $pages[$i]->add(
#        undef, 'TextViewer',
#        -x    => 1,
#        -y    => 5,
#        -text => $pagename[$i-1],
#    );
#}
$notebook->focus;

# Let user play.
$cui->mainloop;
