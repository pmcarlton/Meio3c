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
$matchenz=shift; #case-insensitve
$dist=shift; #minimum room from the central SNP on either the left or right sides
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

#if (/$matchenz/i) {
if (/\W$matchenz\W/i) { ##NEED THE \W to prevent MaeII =~ MaeIII &c.
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
  if($snp[$iter]{'matched'}) {
@c=split(" ",$snp[$iter]{'cuts'});
$#cut1=-1;$minacc=10000;$ee=0;$minind=(-5);
for $cc(@c){
  $r=abs($cc-500);
  push @cut1,$r;
  if($minacc > $r) { $minacc=$r;$minind=$ee; }
  $ee++;
}
#if($minind < 0) {die "Something's jacked up!!";} ##died at EOF, so keep it out for now
$snploc=$c[$minind];

if($minind<=1) {$minind1=0;} else {$minind1 = $minind-1;}
if($minind>=($#c-1)) {$minind2=$#c;} else {$minind2 = $minind+1;}
$#goodcut=-1;
$fe=0;
for $lli($minind1..$minind2){
if($c[$minind]==$c[$lli]) {$snpind=$fe;}
$fe++;
push @goodcut,$c[$lli];
}
#now "goodcut" has the locations of ±2 from the center..but maybe this is unnecessary

$printflag=1;	#deciding whether to print the record or not.
if ($minind1==$minind2) {$printflag=0;} #easy case
if ($#goodcut==1) {if(abs($goodcut[0]-$goodcut[1])<$dist) {$printflag=0;}}
$tst1=10000;$tst2=10000;
if ($#goodcut==2) {
	if(($snpind==0) | ($snpind==2)) {$tst1=$goodcut[1];}
	elsif (($snpind==1)) {$tst1=$goodcut[0];$tst2=$goodcut[2];}
	else {die "Something jacked up!\n";}
	if ((abs($snploc-$tst1)<$dist)|(abs($snploc-$tst2)<$dist)) {$printflag=0;}
	}
if($#goodcut>2) {die "jacked!";}


if ($printflag) {
print ":::Record begin\n";
  print $snp[$iter]{'name'},"\n";
  print $snp[$iter]{'seq'},"\n";
print "the index of the snp is $snpind :\n";
  for $loc(@goodcut) {print $loc," ";}
  #for $li($minind1..$minind2) {print $c[$li]," ";}
  print "= \n";
	}
  }
}
close IN;
