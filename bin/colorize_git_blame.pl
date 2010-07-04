#!/usr/bin/env perl
#
# Colorize git blame output.
# @author jdelong@
#
use strict;

######################################################################

my $color_off = "\e[0m";
my $brown = "\e[33m";
my $green = "\e[32m";
my $cyan = "\e[36m";
my $bold = "\e[1m";

my $yellow = $bold . $brown;

sub print_color {
    my ($color, $text) = @_;
    print $color . $text . $color_off;
}

my $color_comment = $brown;
my $color_string = $green;
my $color_keyword = $cyan;
my $color_info = $bold;

my $color_hash = $yellow;
my $color_author = $bold . $cyan;
my $color_date = $color_off;

######################################################################

my $highlight_state = \&detect_lang_state;
my $keyword_highlight = \&cxx_keywords;

sub change_highlight_state {
    $highlight_state = shift;
    &$highlight_state(shift);
}

sub make_state {
    my ($color, $end, $escape) = @_;

    return sub {
        local $_ = shift;

        my $match = $escape eq ''
            ? m@((?:(?!$end).)*$end)(.*)@
            : m@((?:(?:$escape$end)|(?:(?!$end).))*$end)(.*)@;

        if ($match) {
            print_color($color, $1);
            change_highlight_state(\&highlight_main, $2);
        } else {
            print_color($color, $_);
        }
    }
}

# This could be improved...  It seems to work well enough on our code
# though.
sub detect_lang_state {
    local $_ = shift;

    if (m@\s*<\?(php)?@ || m@\#\!.*php@) {
        $keyword_highlight = \&php_keywords;
        change_highlight_state(\&highlight_main, $_);
    } elsif (m@[^ \t]@) {
        change_highlight_state(\&highlight_main, $_);
    } else {
        print;
    }
}

sub highlight_main {
    local $_ = shift;

    if (m@(\'|\"|(?://)|(?:/\*))(.*)@) {
        &$keyword_highlight($`);

        if ($1 eq '\'') {
            print_color($color_string, $1);
            change_highlight_state(
                make_state($color_string, $1, "\\\\"), $2);
        } elsif ($1 eq '"') {
            print_color($color_string, $1);
            change_highlight_state(
                make_state($color_string, '\"', "\\\\"), $2);
        } elsif ($1 eq "//") {
            print_color($color_comment, "//");
            print_color($color_comment, $2);
        } elsif ($1 eq '/*') {
            print_color($color_comment, "/*");
            change_highlight_state(
                make_state($color_comment, '\*\/', ''), $2);
        }
    } else {
        &$keyword_highlight($_);
    }
}

######################################################################

sub cxx_keywords {
    local $_ = shift;

    s{(\#[[:space:]]*include[[:space:]]*)(<.*>)}
     {$1$color_string$2$color_off}g;

    s{(
       \#
       [[:space:]]*
       (?:define|include|pragma|error|ifndef|ifdef|if|endif|elif|
        warning|else|undef)
       )
      }{$color_keyword$1$color_off}xg;

    s{\b(
         asm|auto|break|case|catch|const|const_cast|continue|default|delete|do|
         double|dynamic_cast|else|explicit|export|extern|false|for|friend|goto|
         if|inline|mutable|namespace|new|operator|private|protected|public|
         register|reinterpret_cast|return|signed|sizeof|static|static_cast|
         switch|template|this|throw|true|try|typedef|typename|union|unsigned|
         using|virtual|volatile|while
         )\b
     }{$color_keyword . $1 . $color_off}xeg;

    s{\b(bool|char|class|enum|float|int|long|short|struct|void)\b}
     {$color_keyword . $1 . $color_off}eg;

    print;
}

######################################################################

sub php_keywords {
    local $_ = shift;

    s{\b(
         and|or|xor|exception|array|as|break|case|class|const|continue|
         declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|
         endforeach|endif|endswitch|endwhile|eval|exit|extends|for|foreach|
         function|global|if|include|include_once|isset|list|new|print|
         require|require_once|return|static|switch|unset|use|var|while|final|
         interface|implements|instanceof|public|private|protected|abstract|
         clone|try|catch|throw|this|namespace|goto
         )\b
     }{$color_keyword . $1 . $color_off}xeg;

    print;
}

######################################################################

sub hl_blame_prefix {
    local $_ = shift;

    if (/([0-9a-f]+)[^(]*\(([a-zA-Z ]+) (\d\d\d\d-\d\d-\d\d)/) {
        print_color($color_hash, $1);
        print " (";
        print_color($color_author, $2);
        print ' ';
        print_color($color_date, $3);

        # Line number at the end.
        if (/( *\d*)$/) {
            print $1;
        }
    } else {
        print_color($color_info, $_);
    }

    print ")";
}

while (<>) {
    if (/([^\)]*)\)(.*)/) {
        my ($prefix, $code) = ($1, $2);
        hl_blame_prefix($prefix);

        &$highlight_state($code);
        print "\n";
    } else {
        print;
    }
}
