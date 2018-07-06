#!/usr/bin/perl
use v5.18;
use File::Temp qw/ tempfile tempdir /;

binmode(STDOUT, ":utf8");
my $cracha_file = 'cracha.svg';
my $data;

{ open(my $cracha_fh, '<', $cracha_file) or die "Could not open file '$cracha_file' $!";
	local $/ = undef;
	$data = <$cracha_fh>;
	close $cracha_fh;
}

my $filename = 'Cracha_festaSwart2018.txt';
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
my $dir = tempdir('SK_CRACHAS_XXXX', CLEANUP => 0, TMPDIR => 1);

my $script_file = "$dir\\convert_files.bat";
open(my $script_fh, '>:encoding(UTF-8)', $script_file) or die "Could not open file '$script_file' $!";

print $script_fh 'PATH="C:\Program Files\Inkscape"';
print $script_fh "\n";

while (my $row = <$fh>) {
	chomp $row;
	my ($codigo, $nome_completo, $parent) = split /;/, $row;
	print $parent;
	$nome_completo =~ s/^\s*//s;
	my $nome = (split(/\s+/,$nome_completo,2))[0];
	next unless $nome;
	printf "NOME: %s\t\tCODIGO: %s\t\tPARENT: %s\n", $nome, $codigo, $parent;
	# my $file_content = "GABRIEL PERSON_NAME_CCC PRADO SERIAL_NUMBER_AAA DE PARENT_NAME_BBB\n";
	my $file_content = $data;

	$file_content =~ s/PERSON_NAME_CCC/$nome/;
	$file_content =~ s/SERIAL_NUMBER_AAA/$codigo/;
	$file_content =~ s/PARENT_NAME_BBB/$parent/;

	my $outfile = "$dir/$codigo.svg";

	open(my $output_fh, '>encoding(UTF-8)', $outfile) or die "Could not open file '$outfile' $!";
	print $output_fh $file_content;
	close $output_fh;
	print $script_fh "inkscape.exe --export-area-page --export-dpi=655 --export-png=\"" . $outfile . ".png \" \"" . $outfile . "\"";
	print $script_fh "\n";
}

close $fh;
close $script_fh;
print $dir;
print "\n";


