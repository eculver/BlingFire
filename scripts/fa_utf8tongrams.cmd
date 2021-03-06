@perl -Sx %0 %*
@goto :eof
#!perl

use encoding 'utf8';

sub usage {

print <<EOM;

Usage: fa_utf8tongrams [OPTIONS]

This tool reads plain text in UTF-8 encoding and extracts character n-grams
with counts.

  --order=N - n-gram order, 3 is used by default

  --line-step=N - the amount of lines processed at once,
    by default full input is processed at once

  --anchor=C - character used as an left/right anchor, ^ used by default

  --no-counts - returns all ngrams without calculating counts

Note: This program substitutes input tabs with spaces.

EOM

}

$order = 3;
$max_lines = -1;
$anchor = "^";
$no_counts = "";

while (0 < 1 + $#ARGV) {

    if("--help" eq $ARGV [0]) {

        usage ();
        exit (0);

    } elsif ($ARGV [0] =~ /^--order=(.+)/) {

        $order = 0 + $1;

    } elsif ($ARGV [0] =~ /^--anchor=(.+)/) {

        $anchor = $1;

    } elsif ($ARGV [0] =~ /^--line-step=(.+)/) {

        $max_lines = 0 + $1;

    } elsif ("--no-counts" eq $ARGV [0]) {

        $no_counts = $ARGV [0];

    } elsif ($ARGV [0] =~ /^-.*/) {

        print STDERR "ERROR: Unknown parameter $$ARGV[0], see fa_utf8tongrams --help";
        exit (1);

    } else {

        last;
    }
    shift @ARGV;
}


### $left_right = "";

### for($i = 0; $i < $order; ++$i) {
###   $left_right .= $anchor ;
### }

$left_right = $anchor . $anchor;

$curr_lines = 0;

while (<>) {

    s/[\r\n]+$//;
    s/^\xEF\xBB\xBF//;

    # substitute tabs with spaces
    s/[\t]/ /g;

    $curr_lines++;

    $_ = $left_right . $_ . $left_right;

    $to = length($_) - $order - 1;

    for($from = 1; $from <= $to; ++$from) {

      # get the substring
      $s = substr($_, $from, $order);

      if("" eq $no_counts) {
        # update the counts
        $counts{$s} = 1 + $counts{$s};
      } else {
        # put ngrams there
        print "$s\n" ;
      }
    }

    if("" eq $no_counts && $curr_lines == $max_lines) {

      foreach $s (keys %counts) {
        print "$s\t$counts{$s}\n";
      }

      %counts = ();
      $curr_lines = 0;
    }
}

if("" eq $no_counts && 0 != $curr_lines) {

  foreach $s (keys %counts) {
    print "$s\t$counts{$s}\n";
  }
}
