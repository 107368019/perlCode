#!/usr/local/bin/perl -w


# $str = '<Instrument id> = "Jtag_IO2", "Jtag_IO0","Jtag_IO1"';


$string = '<Instrument id="CP,DS0,DS7,I_O0,I_O1,I_O2,I_O3,I_O4,I_O5,I_O6,I_O7,Q0,Q7,S0,S1,_MR">';

my $resultStr = addStrToSignals($string,"Jtag_");
print "resultStr = $resultStr \n";


$string = '<Instrument id="Jtag_CP,Jtag_DS0,Jtag_DS7,Jtag_I_O0,Jtag_I_O1,Jtag_I_O2,Jtag_I_O3,Jtag_I_O4,Jtag_I_O5,Jtag_I_O6,Jtag_I_O7,Jtag_Q0,Jtag_Q7,Jtag_S0,Jtag_S1,Jtag_MR">';

$resultStr = deleteStrInSignals($string,"Jtag_");
print "resultStr = $resultStr \n";


sub addStrToSignals(){
   
   my ($targetStr,$addStr) = @_; 

   # find str inside " "
   $targetStr=~/"(.*?)"/;
   my($beforeMatch,$match,$afterMatch) = ($`,$&,$'); 

   # edit str inside " "  
   $match =~ s/([^,"]+)/$addStr$1/g;
   my $targetStr = $beforeMatch.$match.$afterMatch;

   #Squashes duplicate  '_'
   $targetStr =~ tr/_/_/s;

   return $targetStr;
}

sub deleteStrInSignals(){
   my ($targetStr,$deleteStr) = @_; 

   $targetStr =~ s/$deleteStr//g;

   return $targetStr;
}



