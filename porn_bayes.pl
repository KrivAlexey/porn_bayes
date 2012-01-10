#!/usr/bin/perl/

use LWP::UserAgent;
use HTML::Parser;
use YAML::Tiny qw (DumpFile LoadFile);
use utf8;
use List::MoreUtils qw (uniq);
use strict;
use open qw(:std :utf8);
use Encode;

my $file4pornStat = 'pornStat.yml';
my $file4otherStat = 'otherStat.yml'; 
my $file4content = 'content.txt';

my @bad_urls = qw(http://gigporno.ru/ http://www.trahun.tv/ http://xrest.net/ http://www.mega-porno.ru/ http://www.dojki.com/ http://www.bigsexshok.ru/ 
http://www.porno4all.info/ http://www.5xxx.ru/ http://arhiv-porno.com/ http://www.5porno.ru/ http://www.porn.com/ http://www.pornhub.com/ 
http://www.xnxx.com/ http://www.bigsexshok.ru/);

my @good_urls = qw(http://www.zoovet.ru/ http://www.dikiezveri.com/ http://www.ikea.com/ http://ekologiya.net/ http://www.ecology.com/ http://help.com/ 
http://www.polit.ru/ http://www.bz.ru/ http://www.spbu.ru/structure/ http://zhitomir.info/ http://www.boston.com/ http://www.gismeteo.ru/ 
http://www.b177.ru/ http://www.biznet.ru/ http://instaforex.com/ru/ http://www.isco-i.ru/ http://www.vienna.info/ru http://www.apteka-a.ru/);

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

#learn_filter ( 1, @bad_urls);
#learn_filter ( 0, @good_urls);

check('http://www.ydacha.ru/');

sub check {

    my ($url) = @_;
    get_content($url);
    $p -> parse_file($file4content);

    if( check_site(@words) > 0.6){
        print "ololo PORNO!!!!\n";
    }
    else{
        print "GOOOD!!!\n";
    }
    return ;

} ## --- end sub check



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
    $encoding = $1 if $1;
    $content = decode($encoding, $content);
    
    open X, ">", $file4content
    or die  "$0 : failed to open  input file '$file4content' : $!\n";
    print X $content;
    close X
    or warn "$0 : failed to close input file '$file4content' : $!\n";

}# --- end sub get_content

#создаем статистику
sub make_stat {

    my ($pornFlag, @words) = @_;
    my $stat;
    my $file_name = $pornFlag ? $file4pornStat : $file4otherStat;
    @words = uniq @words;    

    if (-e $file_name){
        $stat = LoadFile($file_name);
        $$stat{$_}++ for @words;
    }
    else {
        $$stat{$_}++ for @words;
    }

    DumpFile($file_name, $stat);

} ## --- end sub make_stat

#Проверяем сайт
sub check_site {
    my @words= @_;

    my $pornStat = LoadFile($file4pornStat);
    my $otherStat = LoadFile($file4otherStat);
    my @a;
    
    foreach (@words){
        #push(@a, $$pornStat{$_}/($$pornStat{$_} + $otherStat{$_})) if $$pornStat{$_};
        push(@a,  $$pornStat{$_}/($$pornStat{$_} + $$otherStat{$_})) if $$pornStat{$_};
        #print "$_    $$pornStat{$_}   $$otherStat{$_}\n";
    }   

    my ($a, $b) = (1,1);
    foreach (@a){ 
        $a *= $_;
        $b *= 1 - $_;
        #print "$a   $b\n";   
    }
    return $a/($a + $b);

} ## --- end sub check_site
