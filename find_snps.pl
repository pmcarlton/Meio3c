# 20100411, Yuri's night
#perl script for the 3C-SNP-mapping project, Pete Carlton, iCeMS
#
#it works, apparently. should refine selection of output, error checking, etc.
#
##i want to give the program a list of confirmed SNPs, a chromosome, a window size, and a set of restriction enzymes, and for the program to spit out the size of expected fragments with the location of the SNP (SNPname, left end, SNPloc, right end) at pos 0.
#

#*** *** customized -- the "xs" argument must reflect the filename AND the first column in the snplist, e.g. using V.txt for the sequence selects SNPs whose 0th column is "V" 

#put 5kb extract size as hard-coded in program to simplify, for now.
#

use File::Basename;

$excludesize = 50;    #closest allowed SNPs
$extractsize = 2000;   #uses +-, so extracted seq is 2x extractsize
$mingelsize = 10;     #the smallest fragment you're willing to resolve
$maxgelsize = 1500;     #the largest fragment you're willing to resolve
$minprimersize = 35;     #the smallest distance needed to prime the PCR
$cutwithdifferentenzymes=0; #0=allow one enzyme to cut both ends

if($cutwithdifferentenzymes) {
print "#Will only report SNPs on bands cut by >1 enzyme. \n";
}
else {
print "#Will report SNPs found on all bands. \n";
}

$argc=$#ARGV;
$snplist=$ARGV[0]; $xs=$ARGV[1];

open OCT,">tmp.oct";

$#relist=-1;
for $i (2..$argc){
	$relist[$i-2]=$ARGV[$i];
}

$rell=$#relist+1;
if($rell>1) {
print "#",$rell," enzymes will be used: ",join(" ",@relist),"\n";
}
if($rell == 1) {
print "#",$rell," enzyme will be used: ",join(" ",@relist),"\n";
}

$xsn = basename($xs); $xsn =~ s/\..*//;
# so no matter what directory the sequence file is in, all that goes into $xsn is the first part of the filename, which should be the letter designation of the chromosome (ii, x, etc)

print "#","Looking on Chromosome ",uc $xsn,": \n";
open IN, $snplist;
$e=0;
for (<IN>) {
	@q=split;
	if ((uc $q[0]) eq (uc $xsn)) {
	$snplist[$e++]=join(" ",($q[3],$q[9]));
	}
	}
@snplist = sort {$a <=> $b} @snplist;
print "#",$e, " SNPs found initially.\n";

#put positions of only the separated-enough SNPs into $snppos:
$e=0;$lastpos=0;
for (@snplist) {
	@q=split;
	$testpos=$q[0];
	if ($testpos - $lastpos > $excludesize) {
	$snppos[$e++]=$_;
	$lastpos = $testpos;
	}
	}
for (@snppos) {
	@q=split; $testpos=$q[0];
	$regstring.=($testpos-$extractsize)."-".($testpos+$extractsize).";";
	}
chop($regstring);
$regstring=qw/"/.$regstring.qw/"/;
system("/opt/local/bin/extractseq -auto -seq $xs -separate -region $regstring -outseq .tmp");

$aa=`grep CHROMOSOME .tmp`; @q=split("\n",$aa);
$e=0;
for (@snppos) {
$_ .= "  $q[$e++]";
$snppos[$e-1]=$_;
}

#when ready for the restriction, use this:
#
$relist=join(",",@relist);
$aa=`/opt/local/bin/restrict -auto -stdout -seq .tmp -enzymes $relist -sitelen 4`; 
@aa=split("\n",$aa);
$e=(-1);$goflag=0;
for (@aa) {
	@q=split;
	if (/Sequence/ || /Total/) {
		push @seqnames, $q[2];
		$e++;
		if($cuts[0]){   #just so we don't print out from the get-go
			$le=0;$re=0; #left and right ends
			for $cut(@cuts) {
				@l=split(" ",$cut);
				if($l[0] < $extractsize) { $le = $l[0]; $lenz=$l[1]; }
				}
			@cuts = sort {$b <=> $a} @cuts;
			for $cut(@cuts) {
				@l=split(" ",$cut);
				if($l[0] > $extractsize) { $re = $l[0]; $renz=$l[1]; }
				}
		if ($le && $re) {
			push @result,"$seqnames[$e-1] $lenz $le $re $renz";
#			print $seqnames[$e-1]," ";
#			print "$lenz $le $re $renz \n";
			}
		}
		$#cuts=-1;
		}
	if (/^ *\d/) {
		push @cuts,"$q[0] $q[3]";
		}
}

$foundsnps=0;
for (@result){
	@q=split;
	$locname=$q[0];
	foreach $test(@snppos) {
		@qq=split(" ",$test);
		$qq1=$qq[2];$qq1 =~ s/>//;
		if ($locname eq $qq1) {
			$qq1=$qq[1];$qq1 =~ s/"//g;
#			print $qq1," ",$_,"\n";
			$q[2]-=$extractsize;$q[3]-=$extractsize;
			if ((abs($q[2])>$mingelsize)||(abs($q[3])>$mingelsize)){
			if ((abs($q[2])>$minprimersize)&&(abs($q[3])>$minprimersize)&&((abs($q[2])<$maxgelsize)||(abs($q[3]<$maxgelsize)))){
			unless ($cutwithdifferentenzymes && ($q[1] eq $q[4])) {
			print $qq1," ",$q[0]," ",$q[1]," ",$q[2]," ",$q[3]," ",$q[4],"\n";
			$absloc=$q[0];$absloc =~ s/.*_//;
			print OCT $absloc," ",$q[2]," ",$q[3],"\n";
			$foundsnps++;
			}
			}}
			}
		}
	}
print "#",$foundsnps," SNP locations found.\n";
close OCT;
