#!/usr/bin/perl/

use LWP::UserAgent;
use HTML::Parser;
use YAML::Tiny qw 'DumpFile LoadFile';
use utf8;
use List::MoreUtils qw 'uniq';
use strict;
use open qw(:std :utf8);
use Encode;

#Флаг для обучения, 
my $file4content = "content.txt";
my @bad_urls = qw(http://gigporno.ru/ http://www.trahun.tv/ http://xrest.net/ http://www.mega-porno.ru/ http://www.dojki.com/ http://www.bigsexshok.ru/ 
http://www.porno4all.info/ http://www.5xxx.ru/ http://arhiv-porno.com/ http://www.5porno.ru/ http://www.porn.com/ http://www.pornhub.com/ 
http://www.xnxx.com/);
#my $urls =  'http://www.trahun.tv/';
my @good_urls = qw(http://www.zoovet.ru/ http://www.dikiezveri.com/ http://www.ikea.com/ http://ekologiya.net/ http://www.ecology.com/ http://help.com/ 
http://www.polit.ru/ http://www.bz.ru/ http://www.spbu.ru/structure/ http://zhitomir.info/ http://www.boston.com/ http://www.gismeteo.ru/ 
http://www.b177.ru/);

my @words;
    my $p = HTML::Parser->new(api_version => 3, text_h=>[ \&x, "text"]);
     
    $p->ignore_elements(qw(script style));
    $p->unbroken_text(1);
    $p->utf8_mode(1);
    $p->attr_encoded(1);
   
    sub x {
        my  ($qq) = @_;
        utf8::decode($qq);
        $qq = lc($qq);
        @words =  $qq=~ /([a-zа-я]{3,})/g;
    }

learn_filter ( 1, @bad_urls);

learn_filter ( 0, @good_urls);

#учим фильтр\
sub learn_filter{
    my ($porn_flag, @urls) = @_;
    
    foreach (@urls){   
        get_content($_);
        $p-> parse_file($file4content) ;
        make_stat($porn_flag, @words);
    }

}

#достаем контент страницы
sub get_content{
    my ($url) = @_;
    my $encoding = 'utf-8';
    my $ua = LWP::UserAgent->new;
    my $content =  $ua->get($url)->content ;
    $content =~ /charset=\"?(.*?)\"/;
    print "$url\n";
    $encoding = $1 unless $1=='';
    $content = decode($encoding, $content);
    
    open X, ">", $file4content
    or die  "$0 : failed to open  input file '$file4content' : $!\n";
    print X $content;
    close X
    or warn "$0 : failed to close input file '$file4content' : $!\n";
}

#создаем статистику
sub make_stat {
    my ($pornFlag, @words) = @_;
    print "$pornFlag \n";
    my $file_name = 'stat.yml';
    my %stat;
    my $quantityOfpages = 'quantityOfpages';

    @words = uniq @words;    
    #map{$_/=scalar @words}values %stat;

    if (-e $file_name){
        my $old_stat = LoadFile($file_name);
        foreach (@words){
           $pornFlag ? $$old_stat{$_}++ :$$old_stat{$_}--; 
        }
        $$old_stat{$quantityOfpages} ++;
        DumpFile($file_name, $old_stat)or die "ololo: $!" ;
    }
    else { 
        $stat{$quantityOfpages} = 1;
        DumpFile($file_name, \%stat)or die "ololo: $!" ;
   }
} ## --- end sub make_stat
