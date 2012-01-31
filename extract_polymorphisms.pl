#!/usr/bin/perl
#
#code to extract records from the CelegansPolymorphisms file
#loop over entire file, placing records (delimited by the initial '>' char) into @a,
#then printing @a if it matches something.
#020110311pmc


$fn=shift; open IN,$fn;
$matchme=shift;
while(<IN>) {
  if (/^>/) {
	if ($pflag) {
	  $pflag=0;
	  print @a;
	  print "\n";
	}
	$#a=-1;
  }
  $b=$_;chomp;$_=$b if /\W/;chomp if /\[/;
  push @a,$_;
  $pflag=1 if /\W$matchme\W/i;
}
