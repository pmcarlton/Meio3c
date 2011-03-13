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

print $e;print "\n";
for $iter(0..$e){
  if($snp[$iter]{'matched'}) {
	  print $snp[$iter]{'name'},"\n";
	  #print $snp[$iter]{'xs'},"\n";
	  print $snp[$iter]{'seq'},"\n";
	  print $snp[$iter]{'cuts'},"\n";
	}
  }

close IN;
