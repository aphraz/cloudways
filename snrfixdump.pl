#!/usr/bin/perl

use strict;
use warnings;

my $src_filename = $ARGV[0];
rename($src_filename,$src_filename . '.bak');
my $dest_filename = $src_filename;

sub fix_numbers
{
  # Get the subroutine's argument.
	my ($orig_number) = $_[0];
	my ($string) = $_[2];
	my ($ser_data) = $_[1] . $_[2] . $_[3];

	# Get length
	my $len = length $string;

	if(defined($len))
	{
		# Got a replacement; return it.
		return "s:" . $len . $ser_data;
	}

	# No replacement; return original text.
	return "s:" . $orig_number . $ser_data;
}

sub main
{
	open(IN, '<', $src_filename . '.bak') or die "Cannot open $src_filename: $!";
	open(OUT, '>', $dest_filename ) or die "Cannot open file $dest_filename to write: $!";
	while (my $line = readline(IN)) {
	    ## ... process the line in here
		$line =~ s/s:(\d+)(:\\?\")(.*?)(\\?\";)/fix_numbers($1, $2, $3, $4)/eig;
		print OUT $line;
	}
	close(IN);
	close(OUT);
	exec("del $src_filename . .bak");

}

main();
