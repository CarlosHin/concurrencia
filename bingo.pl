#!/usr/bin/env perl
use warnings;
use strict;

my @numeros = (1..99);
rand(); 

my $ale;
my $lenght = @numeros;
my $max = $lenght -1;

for(my $i= 1; $i<= $lenght ;$i++){
		
  $ale = &alea(0,$max-1);
  print "Numero $i: $numeros[$ale]\n";			
  $numeros[$ale] = $numeros[$max];
  $max--;
  sleep(1);
	
}

sub alea {
  (my $min, my $max)= @_;
  return ($min+int(rand($max-$min+1)));
}
