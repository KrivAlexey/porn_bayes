#!/usr/bin/perl/

use LWP::UserAgent;
use HTML::Parser;
use utf8;
use strict;
use open qw(:std :utf8);

my $ua = LWP::UserAgent->new;
my $content =  $ua->get("http://gigporno.ru/")->content;
utf8::decode($content);

my $file4content = "content.txt";
open X, ">", $file4content
or die  "$0 : failed to open  input file '$file4content' : $!\n";
print X $content;
close X
or warn or die  "$0 : failed to close input file '$file4content' : $!\n";

my $p = HTML::Parser->new(api_version => 3, text_h =>[\&x, "dtext"]);

$p->ignore_elements(qw(script style));
$p->unbroken_text(1);
$p->utf8_mode(1);
$p->attr_encoded(1);

$p-> parse_file($file4content) || die $!;

sub x {
    my ($qq) = @_;
    utf8::decode($qq);
    $qq = lc($qq);
    my @a = $qq=~ /([a-zа-я]{3,})/g;
    make_stat(@a);
}
    
sub make_stat {
    my @words = @_;
    open FH, ">", "porn.txt";
    print FH join "\n", @words;
    my $file_name = "stat.txt";
    if (-e $file_name){
       open my $fh, "<", $file_name;
       #@oldStat = 
    }
    else { 
       my %stat;
       foreach (@words) {
           $stat{$_} ++;   
       }
       #map{$_/=scalar @words}values %stat;
       open my $fh, ">", $file_name
       or die "$0 :faild to open input file $file_name : $!\n";
       print $fh join " ", %stat;
       close $fh;
   }

} ## --- end sub make_stat
