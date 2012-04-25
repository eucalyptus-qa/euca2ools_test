#!/usr/bin/perl

use strict;

local $| = 1;

$ENV{'TEST_HOME'} = "/home/test-server";


# does_It_Have( $arg1, $arg2 )
# does the string $arg1 have $arg2 in it ??
sub does_It_Have{
	my ($string, $target) = @_;
	if( $string =~ /$target/ ){
		return 1;
	};
	return 0;
};

#### read the input list

my $headnode;

open( LIST, "../input/2b_tested.lst" ) or die "$!";
my $line;
while( $line = <LIST> ){
	chomp($line);
	if( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[([\w\s\d]+)\]/ ){
		my $this_roll = $6;
		if( does_It_Have($this_roll, "CLC") ){
			$headnode = $1;
		};

        };
};

#copy the euca2ools test framework to the head node
system("scp -r -o StrictHostKeyChecking=no /home/test-server/temp_space/dan_test_euca2ool root\@$headnode:/disk1/storage/eucalyptus/instances/");


#copy the 2b_tested.lst to the test
system("scp -o StrictHostKeyChecking=no ../input/2b_tested.lst root\@$headnode:/disk1/storage/eucalyptus/instances/dan_test_euca2ool/input/.");


#run the test
system("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /disk1/storage/eucalyptus/instances/dan_test_euca2ool; perl ./run_test.pl dan_test_euca2ool.conf \" ");



