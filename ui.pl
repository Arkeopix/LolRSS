#! /usr/bin/perl

use Modern::Perl;
use Curses::UI;

my $cui = new Curses::UI (
    -clear_on_exit => 1,
    -color_support => 1,
    );
$cui->set_binding( sub {exit(0); }, "\cQ");

my $main = 
