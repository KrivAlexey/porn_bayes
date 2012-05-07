#
#===============================================================================
#   FILE: Filters.pm
#  DESCRIPTION: 
#       AUTHOR: Krivykh Alexey (), krivykhalexey@gmail.com
#      CREATED: 14.04.2012 17:45:12
#===============================================================================


package Filters; 
use strict;
use warnings;
use DataFilter;
use YAML::Tiny qw(DumpFile LoadFile);
 
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
our $VERSION = '1.0';
our @ISA = qw(Exporter);
@EXPORT = qw(learn check_site);


use constant META_FACTOR => 1.01;
use constant TEXT_FACTOR => 0.9; 

my $file4PornStat = 'pornStat.yml';
my $file4OtherStat = 'otherStat.yml';

my @bad_urls = qw(http://gigporno.ru/ http://www.trahun.tv/ http://xrest.net/ http://www.mega-porno.ru/ http://www.dojki.com/ http://www.bigsexshok.ru/ 
                  http://www.porno4all.info/ http://www.5xxx.ru/ http://arhiv-porno.com/ http://www.5porno.ru/ http://www.porn.com/ http://www.pornhub.com/ 
                  http://www.xnxx.com/ http://www.bigsexshok.ru/ http://pornobi.ru/  http://kashtanka.com/ http://www.plombir.ru/  http://www.mega-xxx.ru/  http://bljadki.net/
                  http://www.porno-mama.ru/  http://www.sexsupervideo.ru/ http://www.youjizz.com/ http://www.4tube.com/ http://assholefever.com/ http://givemepink.com/ 
                  http://www.evilangel.com/ http://www.private.com/ http://www.pornolab.net/ http://www.roccoshiffredi.com/ http://www.xhamster.com/  
                  http://www.digitaldesire.com/ http://asian4you.com/ http://www.brazzers.com/);

my @good_urls = qw(http://www.zoovet.ru/ http://www.dikiezveri.com/ http://www.ikea.com/ http://ekologiya.net/ http://www.ecology.com/ http://help.com/ 
                   http://www.polit.ru/ http://www.bz.ru/ http://www.spbu.ru/structure/ http://zhitomir.info/ http://www.boston.com/ http://www.gismeteo.ru/ 
                   http://www.b177.ru/ http://www.biznet.ru/ http://instaforex.com/ru/ http://www.isco-i.ru/ http://www.vienna.info/ru http://www.apteka-a.ru/ 
                   http://habrahabr.ru/post/142085/ http://www.etoday.ru/ http://blograsskazov.ru/ http://www.horse.com/ http://www.pokerstars.com/ http://www.allmusic.com/
                   http://www.apple.com/ http://www.imdb.com/ http://aboveandbeyond.nu/ http://www.arminvanbuuren.com/ http://www.paulvandyk.de/ http://www.globalgathering.com/
                   http://finlandborder.ru/ https://www.cia.gov/ http://eu.battle.net/);


#обучаем фильтр на хороших и плохих сайтах
sub learn{
    make_stat($file4PornStat, @bad_urls);
    make_stat($file4OtherStat, @good_urls);
}

#Экспортируемая функция - проверка сайта
sub check_site{
    my ($url) = @_;
    my %cont = getData($url);
    my @text = @{$cont{text}};
    my @meta = @{$cont{meta}};

    my $meta_probab = META_FACTOR * (@meta ? check_data(@meta) : 0.5);
    my $text_probab = TEXT_FACTOR * check_data(@text);
    print "$meta_probab\n$text_probab\n";
    
    my $a = $meta_probab * $text_probab;
    my $b = (1 - $meta_probab) * (1 - $text_probab);
    my $probab = $a / ($a + $b);
    print "$probab\n";
    return ($probab > 0.7);
}

# Проверяет порцию данных - слов
sub check_data{
    my @data = @_;
    my $pornStat = LoadFile($file4PornStat);
    my $otherStat = LoadFile($file4OtherStat);
    my ($a, $b) = (1, 1);
    foreach (@data){
        if ($$pornStat{$_} && $$otherStat{$_}){

            my $term = $$pornStat{$_} / @bad_urls;
            my $temp = $term / ($term + $$otherStat{$_} / @good_urls); 
            
            #не учитываем слова с вероятностью близкой к 0.5
            if(($temp >= 0.556) || ($temp <= 0.4556)){
                $a *= $temp;
                $b *= 1 - $temp;
            }
        }   
    }

    my $probabillity = $a/($a + $b); 
    return $probabillity;
}

#Создаем статистику
sub make_stat{
    my ($fileName, @urls) = @_;
    my $stat;

    foreach (@urls){
        my %cont;
        %cont = getData($_);
        my @words = @{$cont{text}};
        $$stat{$_}++ for @words;
    }
    DumpFile($fileName, $stat);
}
