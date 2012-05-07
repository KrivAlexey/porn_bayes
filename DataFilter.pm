#===============================================================================
#         FILE: DataFilter.pm
#       AUTHOR: Krivykh Alexey, krivykhalexey@gmail.com
#      COMPANY: SPbGU
#      CREATED: 13.03.2012 22:38:04
#===============================================================================

package DataFilter;
use strict;
use warnings;
use Encode;
use HTML::Parser;
use LWP::UserAgent;
use List::MoreUtils qw(uniq);
use utf8;
use open qw(:std :utf8);
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
require Exporter;
our $VERSION = '1.0';
our @ISA = qw(Exporter);
@EXPORT = qw(getData);

#Экспортируемая функция, возвращает список уникальных слов с главной страницы
sub getData{
    my ($url) = @_;
    my %cont = parse(get_content($url))or die"OLOLO";
    return %cont;
}

#Парсим контент, делим его по словам
sub parse{
    my ($content) = @_;
    my @words;
    my %cont;
    my @text;

    #Создание и настройка объекта HTML::Parser
    my $p = HTML::Parser->new(api_version => 3, handlers=>{start=>[\&startH, "self, tagname, attr, text"], text=>[\&textH, "self, text"]});   
    $p->ignore_elements(qw(script style));
    $p->unbroken_text(1);
    $p->attr_encoded(1);

    #Делим контент по строкам и парсим
    my @content_strings = split (/\n/,$content);
    foreach (@content_strings){
        $p->parse($_);
    }
    $p->eof;

    $cont{text} = [lowerAndDiv($p->{TEXT})];
    $cont{meta} = [lowerAndDiv($p->{meta})];
    print "End of parsing\n";
    return %cont; 

    #Обработчик тегов
    sub startH{
        my ($self ,$tag, $attr, $text) = @_;
        if($tag eq 'meta'){
            $self->{meta} .= ' ' . $attr->{content};
        }
    }

    #Обработчик текста
    sub textH{
        my ($self, $text) = @_;
        $self->{TEXT} .= $text;
    }
}

#Приводим к нижнему регистру и делим на слова не короче 3х букв
sub lowerAndDiv{
    my ($text) = @_;
    $text = lc($text);
    my @words = $text =~ /[a-zа-я]{3,}/g;
    @words = uniq(@words);
    return @words;
}

#достаем контент главной страницы страницы
sub get_content{

    my ($url) = @_;
    my $ua = LWP::UserAgent->new;
    my $content =  $ua->get($url)or die "$!";
    $content = $content-> decoded_content();
    print "End of get_content\n";
    return $content;

}
