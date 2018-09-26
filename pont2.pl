#!/usr/bin/env perl
use warnings;
use strict;
use threads;
use threads::shared;
use Time::HiRes qw (usleep);

my $pont :shared= 0; #Pont muntat = 1 Pont Baixat =0
my $n_coches :shared=0;
my $n_barcos :shared= 0;
my $w_coches :shared= 0;
my $w_barcos :shared=0;
my $cua_coches :shared;
my $cua_barcos :shared;
my $p_barcos = 10;
my $t_gen = 100000;
my $t_cruzar = 100000;
rand();
$SIG{INT}= \&mostrarInfo;

threads->create(\&chivato);

while(1){

  if(alea(0,100)>$p_barcos){
		threads->create(\&coche);
	}
	else{
		threads->create(\&barco)
	}

	usleep($t_gen);

}

sub barco {
  threads->detach();
  my $id = threads->tid();
  print("B Vol creuar el baixel $id\n");
  {lock($pont);
  	if(!$pont){ #Si el pont està baixat
  		if($n_coches){ #Si hi ha cotxes creuat
  			$w_barcos++;
  			cond_wait($cua_barcos,$pont);
  			$w_barcos--;
  		}
  		else{ #Quan està baixat pero no hi ha ningun cotxe creuant
  			&subirPuente();
  		}
  	}
  	$n_barcos++;
  }
  print("Comença a creuar el baixel $id\n");
  usleep($t_cruzar* &alea(1,9));
  print("Ha creuat el baixel $id\n");
  {
  	lock($pont);
    $n_barcos--;
    if($n_barcos == 0 && $w_coches){ #Baixa el pont si no queden baixels i hi han cotxes esperan
      lock($cua_coches);
      &bajarPuente();
      cond_broadcast($cua_coches);
      print("Despertem a tots els cotxes\n");
    }

  }



}
sub coche{
	threads->detach();
	my $id = threads->tid();
    print("C Vol creuar el cotxe $id\n");
	{
	lock($pont);
	 if($n_barcos || $w_barcos){ #Es suspén si hi ha algún baixel creuant o esperan
      $w_coches++;
      cond_wait($cua_coches,$pont);
      $w_coches--;
	 }
  }
   &bajarPuente() if($pont); #Baixa el pont si esta muntat
	 $n_coches++;

	print("Comença a creuar el cotxe $id\n");
	usleep($t_cruzar * &alea(1,9));
	print("Ha creuat el cotxe $id\n");

	{
		lock($pont);
		$n_coches--;
		if($n_coches ==0 && $w_barcos){ #Munta el pont si no queden cotxes i hi han baixels esperan

			lock($cua_barcos);
			&subirPuente();
			cond_broadcast($cua_barcos);
			print("Despertem a tots els baixels\n");
		}
	}
}
sub chivato{
	threads->detach();
	while(1){
		sleep(5);

		 &mostrarInfo();

	}

}
sub subirPuente{
  print "Pujan el pont\n";
  usleep(10000);
  $pont=1;
  print "Pont pujat\n";
}
sub bajarPuente{
  print "Baixant pont\n";
  usleep(100000);
  $pont=0;
  print "Pont baixat\n";
}
sub mostrarInfo{
	my $estatPont = "Putjat";
	$estatPont = "Baixat" if($pont==0);
	print("\nPont $estatPont\n Nº Cotxes: $n_coches Nº Baixels: $n_barcos\nNº Cotxes esperan: $w_coches Nº Baixell esperant: $w_barcos\n\n");

}
sub alea {
  (my $min, my $max)= @_;
  return ($min+int(rand($max-$min+1)));
}
