#!/usr/bin/perl
use v5.18;
use File::Temp qw/ tempfile tempdir /;

binmode(STDOUT, ":utf8");
my $data;
my $data_primos;

my $cracha_file = 'cracha.svg';
{ open(my $cracha_fh, '<', $cracha_file) or die "Could not open file '$cracha_file' $!";
	local $/ = undef;
	$data = <$cracha_fh>;
	close $cracha_fh;
}

my $cracha_primos_file = 'cracha_primos.svg';
{ open(my $cracha_primos_fh, '<', $cracha_primos_file) or die "Could not open file '$cracha_primos_file' $!";
	local $/ = undef;
	$data_primos = <$cracha_primos_fh>;
	close $cracha_primos_fh;
}

my $filename = 'Cracha_festaSwart2018.txt';
open(my $fh, '<:encoding(UTF-8)', $filename) or die "Could not open file '$filename' $!";
my $dir = tempdir('SK_CRACHAS_XXXX', CLEANUP => 0, TMPDIR => 1);

my $script_file = "$dir\\convert_files.bat";
open(my $script_fh, '>:encoding(UTF-8)', $script_file) or die "Could not open file '$script_file' $!";

print $script_fh 'PATH="C:\Program Files\Inkscape"';
print $script_fh "\n";

my $counter = 0;
while (my $row = <$fh>) {
	chomp $row;
	my ($nome_completo, $codigo1, $parente1, $codigo2, $parente2) = split /;/, $row;
	$nome_completo =~ s/^\s*//s;
	my $nome = (split(/\s+/,$nome_completo,2))[0];
	$codigo1 =~ s/^\s*//s;
	$parente1 =~ s/^\s*//s;
	$codigo2 =~ s/^\s*//s;
	$parente2 =~ s/^\s*//s;
	next unless $nome;
	# my $file_content = "GABRIEL PERSON_NAME_CCC PRADO SERIAL_NUMBER_AAA DE PARENT_NAME_BBB\n";
	my $file_content;
	if($codigo2) {
		$file_content = $data_primos;
	} else {
		$file_content = $data;
	}

	$file_content =~ s/NAME_CCC/$nome/;
	$file_content =~ s/S_AAA/$codigo1/;
	$file_content =~ s/P_AAA/$parente1/;
	$file_content =~ s/S_BBB/$codigo2/;
	$file_content =~ s/P_BBB/$parente2/;

	# my $outfile = sprintf "%s\\%05d-%s.svg", $dir, ++$counter, $codigo;
	my $outfile = sprintf "%s\\%05d.svg", $dir, ++$counter;
	printf "%05d) NOME: -%s-\t\tCODIGO: -%s-\t\tPARENT: -%s-\t\tCODIGO: -%s-\t\tPARENT: -%s-\n", $counter, $nome, $codigo1, $parente1, $codigo2, $parente2;

	open(my $output_fh, '>encoding(UTF-8)', $outfile) or die "Could not open file '$outfile' $!";
	print $output_fh $file_content;
	close $output_fh;
	
	my @extensions = split /\./, $outfile;
	my $ext = $extensions[-1];
	my $png_file = $outfile;
	if($ext) {
		$png_file =~ s/$ext/png/g;
	}

	print $script_fh "inkscape.exe --export-area-page --export-dpi=655 --export-png=\"" . $png_file . "\" \"" . $outfile . "\"";
	print $script_fh "\n";
	print $script_fh "del $outfile";
	print $script_fh "\n";
}

print $script_fh "start magica.bat\n\n";
close $fh;
close $script_fh;
print $dir;
print "\n";

# ============ MAGICA ============ #
my $magica_file = "$dir\\magica.bat";
open(my $magica_fh, '>:encoding(UTF-8)', $magica_file) or die "Could not open file '$magica_file' $!";

my $ver = 3;
my $first = 1;
my $last = $counter;
my $ver_counter = 0;

$counter = 0;

print $magica_fh 'PATH="C:\Program Files\ImageMagick-7.0.8-Q16"';
print $magica_fh "\n\n";

while($counter < $last) {
	my @files;
	for(my $i = 0; $i < $ver && $counter < $last; $i++) {
		my $file = sprintf "%05d.png", ++$counter;
		push @files, $file; 
	}
	my $ver_filename = sprintf "V3_%d.png", ++$ver_counter;
	print $magica_fh "magick ";
	print $magica_fh join " ", @files;
	print $magica_fh " -append $ver_filename\n";
	print $magica_fh "del ", join " ", @files;
	print $magica_fh "\n\n";
}

print $magica_fh "\n\n";

close $magica_fh;
# ============ MAGICA ============ #

exec "start $dir";

