#!/usr/bin/perl -w

use strict;
use warnings;

use Mojo::UserAgent;
use Mojo::DOM;

#Config
my $out = 'dobro24ru'; #Output filename
my $media = 'media'; #Directory for media files

my $ua = Mojo::UserAgent->new;
my $imgsrc = Mojo::UserAgent->new;
my $dom = Mojo::DOM->new;

$dom = $ua->get('http://www.dobro24.ru')->res->dom;

my @content = ();
my @parse_content = ();
my $n = 0;

$dom->find('div.detka_')->each(sub{
	#Image source
	$content[0] = $_->find('img[src]')->attr('src');
	my $img_path = $content[0];
	$content[0]=~s/.*publ\///; #Clear image filename
	$imgsrc->max_redirects(5)->get("http://www.dobro24.ru$img_path" => {DNT=>1})->res->content->asset->move_to("$media/$content[0].jpg");

	#Title
	$content[1] = $_->find('img[src]')->attr('alt');
	utf8::encode($content[1]);
	
	#Age
	$content[2] = $_->text;
	utf8::encode($content[2]);
	use Data::Dumper;
	my $flag = utf8::is_utf8($content[2]);
	$content[2]=~s/\///;

	#Target link
	$content[3] = $_->at('a[href]')->attr('href');
	utf8::encode($content[3]);

	$parse_content[$n] = "<a href=\"http://dobro24.ru$content[3]\" target=_blank><img src=\"/media/images/misc/dobro24ru/$content[0]\" class=\"image-center\"></a><p class=\"align-center\"><a href=\"http://dobro24.ru$content[3]\" target=_blank>$content[1]</a><br/><i>$content[2]</i></p>\n";
	$n++;
});


open (FILE,'>', $out) || die "Cannot open file to write";
print FILE @parse_content;
close FILE;

