use Data::Dumper;



my @Instructions;
my @InstructionsValue;
my $totalIndex;


my $cycle = readSprgFile("Program.sprg");

print "cycle = $cycle\n";

# input :sprg file name
sub readSprgFile{
    
    resetInstructsData();
    $fileName = @_[0];

    open(fileHandler,'<',$fileName) or die $!;
    while( $line = <fileHandler> ){
    
        # find Instructions genVec|repeat|loop|loopEnd|stop
        next if($line !~/id *= *"(genVec|repeat|loop|loopEnd|stop)"/);
    
        # add Instructions array
         push(@Instructions,$1);    

        # add value array
        if($line =~/value *= *"(.*?)"/){        
            push(@InstructionsValue,$1);
        }
        else{
            push(@InstructionsValue,null);
        }    
    }   
    close(fileHandler);
    
    #set totalIndex
    $totalIndex = $#Instructions;  

    my $arrayRef = handleInstructions(0,$totalIndex);

   
    @array = @$arrayRef;    
    
    return handleArray(@array);
}

sub resetInstructsData {
    @Instructions = ();
    @InstructionsValue = ();
    $totalIndex = 0;  
}


 # input : startIndex , endIndex  / output : arrayRef
sub handleInstructions{ 
    
    my @array = ();

    my $startIndex = @_[0];
    my $endIndex = @_[1];


    my $skipIndex =  -1;    

    for(my $i=$startIndex;$i<=$endIndex;$i++){
               
        
        next if($i<=$skipIndex);

        my $instruction = @Instructions[$i];
       
        if($instruction eq genVec){
          (my $dicRef,$skipIndex) =  handleGenVec($i);            
            push(@array, $dicRef);
           
        }
        elsif($instruction eq loop){
           (my $dicRef, $skipIndex) = handleLoop($i,$endIndex);            
            push(@array, $dicRef);            
        }        
        
    }

    return \@array;

}

 # input :starItndex / output : dicRef , skipIndex
sub handleGenVec{
    my $index = @_[0];
    
    
    my %dic = (@Instructions[$index]=>@InstructionsValue[$index]);
   

    my $nextIndex = $index+1;
    #check repeat
    if($nextIndex<= $totalIndex){         
        if(@Instructions[$nextIndex] eq repeat){
            
           my %repeatDic = (repeat => @InstructionsValue[$nextIndex]);
           $dic{sub} = \%repeatDic;
         
           my @results = (\%dic,$nextIndex);           
           
            
            return @results;
        }
    }

    my @results = (\%dic,$index);   
    
    return @results;
}

 # input :startIndex endIndex/ output : dicRef , skipIndex
sub handleLoop{
    my $startIndex = @_[0];
    my $endIndex = @_[1];
    my %dic = (@Instructions[$startIndex]=>@InstructionsValue[$startIndex]);

    die "This pattern has endless loop" if(@InstructionsValue[$startIndex] eq endless);
   
    #find loop end from back
    my $loopEndIndex = 0;
    
    for (my $i=$endIndex;$i>$startIndex;$i--){
        if(@Instructions[$i] eq loopEnd){
            $loopEndIndex = $i;                      
            last;
        }
    }    

    my $arrayRef = handleInstructions($startIndex+1,$loopEndIndex-1);
  
    $dic{sub} = $arrayRef;
    

    @results = (\%dic,$loopEndIndex);
    return @results;
}



#############################
#input : array type / output : cycle
sub handleArray{    
    my $cycle = 0;

    foreach my $dicRef (@_){
        my %dic = %$dicRef;
        $cycle += handleDic(%dic);        
    }
   
    return $cycle;
}

#input : loop unknow type dic / output : cycle
sub handleDic{
    
    my $cycle = 0;
    my %dic = @_;
    if ( exists( $dic{"genVec"} ) ){
        $cycle += handleGenVecDic(%dic);
    }
    elsif(exists( $dic{"loop"} ) ){
        $cycle += handleLoopDic(%dic);
    }
    

    return $cycle;
}

#input : loop genVec dic / output : cycle
sub handleGenVecDic{

    my $cycle = 0;
    my %dic = @_;
    
    my $GenVecValue = int($dic{"genVec"}); 
    
    if (exists($dic{"sub"})){                
        
        $subRef = $dic{"sub"};
        %subDic = %$subRef;

        my $repeatValue = int( $subDic{"repeat"} );     


        $cycle +=  $GenVecValue*$repeatValue;

    }
    else{
         $cycle +=  $GenVecValue;
    }

    return $cycle;
}

#input : loop type dic / output : cycle
sub handleLoopDic{
    
    my $cycle = 0;
    my %dic = @_;    
    my $loopValue = int($dic{"loop"}); 

    if (exists($dic{"sub"})){        
        my $subRef = $dic{"sub"};
        my @subArray = @$subRef;        
        $cycle += $loopValue*handleArray(@subArray);
    }

    return $cycle;

}