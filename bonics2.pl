#!/usr/bin/env perl
# Números bonics versió 2
# Ús: bonics2 [num] (per defecte 100_000_000)
use warnings;
use strict;
use threads;
use threads::shared;
use Time::HiRes qw (time);


my $max= 1E8;
my $ARGC= @ARGV;
$max= $ARGV[0] if $ARGC > 0;
$max--;

my @bonicsTotal :shared;
print "Introduixca en nombre de fils(Entre 1 i 8): ";
my $fils = <>;
chop($fils);
if($fils <=0 || $fils >8){
  print "Numero de fils no vàlid.\n";
  $fils = 4;
 
}
print "S'usaràn $fils fils \n";

for(1..$fils){
  
  push @bonicsTotal, 0;

}

my $ti= time();

my @fil_list;

for my $num (1..$fils) {
  $fil_list[$num] = threads->create(\&calc_bonics,$num,($num-1) *($max+1)/$fils, $num*($max+1)/$fils -1);  
}

for my $i(1..$fils){

  $fil_list[$i]->join();

}

my $tot = 0;
for my $n(0..$fils-1){

  $tot += $bonicsTotal[$n];

}

print ("Entre 0 i $max hi ha $tot números bonics.\n");
my $s= time()-$ti;
print ("Càlculs realitzats en $s segons.\n");


sub calc_bonics{

  (my $num, my $min, my $max, ) = @_;
  my $bonics = 0;
  $min = int($min);
  $max = int($max);

  for my $n ($min..$max){ 
    my $cont= 0; 
    $cont++ if ($n%5 == 0);
    $cont++ if ($n%7 == 2);
    $cont++ if ($n%9 == 0);
    $bonics++ if ($cont == 1);
  }

  $bonicsTotal[$num-1] = $bonics;
}
