#!/usr/bin/perl
#
#general processing of the data in CelegansPolymorphisms
#
#put everything into a record: SNP name, location, everything, into a hash
#then you can query, i.e. “show me all the DraI cut sites with the SNP name"
#
## hash fields: 'xs', 'cuts', 'seq', 'matched'
#


$fn=shift; open IN,$fn;
$matchenz=shift;
$e=0;

while(<IN>) {
@line=split;

#$snp[$e]{'matched'} = 0;   #start off assuming a non-match

if (/^>/) {
  $snp[$e]{'xs'}=$line[1];
  $snp[$e]{'name'}=join("_",@line);
}

if ($#line==0 && (!(/\d/))){
chomp;
push @seq,$_;
}

if (/$matchenz/i) {
  $snp[$e]{'matched'}=1;   #now we can say this SNP has matched the enzyme
  for $num(@line) {
	push @cuts,$num if ($num =~ /^\d+$/);
  }
}

if (/^\n$/) {
  $snp[$e]{'seq'}=join("",@seq); $#seq=-1;
  $snp[$e]{'cuts'}=join(" ",@cuts); $#cuts=-1;
  $e++;
}

}

#if you want to select certain cut parameters, such as ±N from the center
for $iter(0..$e){
#$cutstring=$snp[$iter]{'cuts'};
@c=split(" ",$snp[$iter]{'cuts'});
$#cut1=-1;$minacc=10000;$ee=0;$minind=(-5);
for $cc(@c){
  $r=abs($cc-500);
  push @cut1,$r;
  if($minacc > $r) { $minacc=$r;$minind=$ee; }
  $ee++;
}
#if($minind < 0) {die "Something's jacked up!!";} ##died at EOF, so keep it out for now

if($minind<=1) {$minind1=0;} else {$minind1 = $minind-2;}
if($minind>=($#c-1)) {$minind2=$#c;} else {$minind2 = $minind+2;}
$#goodCut=-1;
for $li($minind1..$minind2){push @goodCut,$c[$li];}

#for $iter(0..$e){
  if($snp[$iter]{'matched'}) {
	  print $snp[$iter]{'name'},"\n";
	  #print $snp[$iter]{'xs'},"\n";
	  print $snp[$iter]{'seq'},"\n";
	  for $li($minind1..$minind2) {print $c[$li]," ";}
#	  print "\n $minind mi $minind1 m1 $minind2 m2 \n";
	  #print $snp[$iter]{'cuts'},"\n";
	  print "= \n";
#	  print $ret,"\n";
	}
  }

close IN;
