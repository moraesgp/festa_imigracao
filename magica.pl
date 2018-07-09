#!/usr/bin/perl
use v5.18;
my $hor = 16;
my $first = 1;
my $last = 157;

my $counter = 0;

my @hor_files;

while($counter < $last) {
	print "magick ";
	for(my $i = 0; $i < $hor && $counter < $last; $i++) {
		printf "%05d.png ", ++$counter;
	}
	my $hor_filename = sprintf "HORIZONTAL_%d.png", $counter;
	printf "+append %s\n\n", $hor_filename;
	push @hor_files, $hor_filename;

}

print "magick ";
foreach(@hor_files) {
	print "$_ ";
}
print "-append FINAL.png\n\n";
