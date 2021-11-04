#!/usr/local/bin/perl -w
use strict;
use diagnostics;

if ($#ARGV != 1) {
	print $#ARGV;
    print "*******************************\n";
	print "using syntax ./x.pl -m path\n";
    print "*******************************\n";
} elsif ($ARGV[0] eq "-m") {
	my $SRC_PATH=$ARGV[1];
	if($SRC_PATH!~/\w*\/$/) {
		$SRC_PATH=$SRC_PATH."/";
	}
	scan_pattern($SRC_PATH);
}
	
sub scan_pattern {
	my($SRC_PATH)=@_;
	opendir(my $DIR, $SRC_PATH) or die "$SRC_PATH can't open directory!\n";
	while (my $FILE = readdir($DIR)) {
		my $FILE_PATH=$SRC_PATH.$FILE;
        if((-f $FILE_PATH) && ($FILE_PATH=~/.pat/)) {
			modify_pattern($FILE_PATH);
		}
    }
    closedir($DIR);
}	

sub modify_pattern {
	my($NAME)=@_;
	my $TARGET_FILE="Program.sprg";
	my $OLD_FILE=$TARGET_FILE."_old";
	my $REPLACE_TEXT="jtag_";
	system("unzip", $NAME);
	rename $TARGET_FILE, $OLD_FILE;
	open(OUTS,">","$TARGET_FILE") || die "$TARGET_FILE can't open!\n";
	open(my $IN,'<',"$OLD_FILE") || die "$OLD_FILE can't open!\n";
	while(readline($IN)){
		chomp($_);
		if($_=~/Instrument id/){
			$_=~s/$REPLACE_TEXT//g;
		}
		print OUTS $_."\n";
	}
	close($IN);
	close(OUTS);
	unlink($NAME);
	system("zip $NAME Program.sprg Vectors.vec PatternComment.txt");
	chmod(0775, $NAME);
	unlink("Program.sprg");
	unlink("Vectors.vec");
	unlink("PatternComment.txt");
	unlink($OLD_FILE);
}

