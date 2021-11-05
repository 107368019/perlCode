if ($#ARGV != 1) {
	print $#ARGV;
    print "*******************************\n";
	print "using syntax ./x.pl -m patternPath\n";
    print "*******************************\n";
} elsif ($ARGV[0] eq "-m") {
	my $SRC_PATH=$ARGV[1];
	if($SRC_PATH!~/\w*\/$/) {
		$SRC_PATH=$SRC_PATH."/";
	}
	scan_pattern($SRC_PATH);
}




my $cycle = readSprgFile("Program.sprg");

print "cycle = $cycle\n";


sub scan_pattern {
	my($SRC_PATH)=@_;
	opendir(my $DIR, $SRC_PATH) or die "$SRC_PATH can't open directory!\n";

    my $csvStr = "PatternName,TotalCycle\n";


	while (my $FILE = readdir($DIR)) {
		my $FILE_PATH=$SRC_PATH.$FILE;
        if((-f $FILE_PATH) && ($FILE_PATH=~/.pat/)) {
			
            $cycle = read_pattern($FILE_PATH);

            $cycle =($cycle == -1) ?endless:$cycle;
            $csvStr = $csvStr."$FILE,$cycle\n";

            writeCsvFile($csvStr);
		}
    }
    closedir($DIR);
}	

sub read_pattern {
	my($NAME)=@_;
	my $TARGET_FILE="Program.sprg";
	
    system("tar", xvf,$NAME);
  

    $cycle = readSprgFile($TARGET_FILE);
	
	unlink("Program.sprg");
	unlink("Vectors.vec");
	unlink("PatternComment.txt");

    return $cycle;
	
}

# input :sprg file name
sub readSprgFile{
   
    $fileName = @_[0];
   
    my $fomularStr = ''; 

    open(fileHandler,'<',$fileName) or die $!;
    while( $line = <fileHandler> ){
    
        # find Instructions genVec|repeat|loop|loopEnd|stop
        next if($line !~/id *= *"(genVec|repeat|loop|loopEnd|stop)"/);
        my $instruction = $1;

        my $value = ($line =~/value *= *"(.*?)"/) ?$1:null;

        # translate Instructions 
         push(@Instructions,$1);    
        if($instruction eq genVec){
            $fomularStr = $fomularStr."+$value";
        }
        elsif($instruction eq repeat){
            $fomularStr = $fomularStr."*$value";
        }
        elsif($instruction eq loop){
            if($value eq endless){
                return -1;
            }
            $fomularStr = $fomularStr."+$value*(";
        }
        elsif($instruction eq loopEnd){
            $fomularStr = $fomularStr.")";
        }
        elsif($1 eq stop){
            # not yet maybe do in the furture
        }    
    }   
    close(fileHandler);

    print "fomularStr = $fomularStr\n";
    $cycle =  eval($fomularStr);
    print "cycle = $cycle\n";
    return $cycle;
}

sub writeCsvFile(){
    my ($csvStr) = @_; 
    my $csvFileName = "output.csv";

    #delete exist file
    if(-e $csvFileName){
        unlink($csvFileName);
    }

    open(FILE, '>', "output.csv") or die $!;
    print FILE $csvStr;
    close(FILE);
}