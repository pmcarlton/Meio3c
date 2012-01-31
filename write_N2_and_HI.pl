#!/usr/bin/perl
#
#code to write N2 and HI records separately in FASTA
#(ie 1 >TITLE per sequence)
#020110311pmc


$fn=shift; open IN,$fn;
while(<IN>) {
  $title=$_ if /^>/;
  $title=~s/\s+/__/g;
  $titleN2=$title."___N2\n";
  $titleHI=$title."___HI\n";
  if (/\[/) { 
	$k=1;
	$seq=$_;
	$seqN2=$seq;
	$seqHI=$seq;
	$seqN2=~s/\[(\w*)\/.*\]/$1/;
	$seqHI=~s/\[.*\/(\w.*)\]/$1/;
  }
  if (/^>/ && $k){
	print $titleN2;
	print $seqN2;
	print $titleHI;
	print $seqHI;
  }
}


