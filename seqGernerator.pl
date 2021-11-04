#!/usr/local/bin/perl -w
use strict;
use diagnostics;


my $csvFileName;
my $patternPath;
my $outputDir;

if ($#ARGV != 2) {	
    printLog("command error : using syntax ./x.pl cssfile patternPath outputDir");
} else {

    $csvFileName=$ARGV[0];
	$patternPath=$ARGV[1];
    $outputDir=$ARGV[2];

	if($csvFileName !~ m{(.*).csv}) {        
        printLog("Didn't find csv file");
        die ("csvFileName error : $csvFileName ");
	}

    createDir();

    readCsvfileAndGenerator();

}



sub createDir {
     
    open(my $dir,$outputDir) or mkdir($outputDir, 0777);   
    close($dir);
    printLog("create dir succeed");
}



sub readCsvfileAndGenerator {
    
    open(my $csvFile,'<',"$csvFileName") || die "$csvFileName can't open!\n error: $!";
	my $index = -1; 
    
    while(my $line = readline($csvFile)){
		chomp $line;  
        $index++;
        if($index == 0){
            
            next;
        }
        my @datas = split(",",$line);

        generatorFile(@datas);
        
	}
    close($csvFile);
}

sub generatorFile {
    
    my $seqName = $_[0];
    my $testSetupName = $_[1];    
    
    my $string = "sequence SeqName_XMD{
        parallel TestSetupName_XMD_para0{
            sequential exList1{
                patternCall r1xxxxx.ATPG.IOP.patterns.TestSetupName_jtag_X8 TestSetupName_jtag_X8;
            }
            sequential exList2{
                patternCall r1xxxxx.ATPG.IOP.patterns.TestSetupName_reg_X5 TestSetupName_reg_X5;
            }
            sequential exList3{
                patternCall r1xxxxx.ATPG.IOP.patterns.TestSetupName_static TestSetupName_static;
            }
            sequential exList4{
                patternCall r1xxxxx.ATPG.IOP.patterns.TestSetupName_clk TestSetupName_clk;
            }
        }
    }";

    $string =~ s/r1xxxxx/$patternPath/g;
    $string =~ s/SeqName/$seqName/g;
    $string =~ s/TestSetupName/$testSetupName/g;
    

    open(FILE, '>', "./$outputDir/$seqName.seq") or die $!;
    print FILE $string;
    close(FILE);

    printLog("create  seq file: $seqName succeed");
    
}


sub printLog {
    print "\n";
    print "*******************************\n";
    print "@_\n";
    print "*******************************\n";
    print "\n";
    
}
