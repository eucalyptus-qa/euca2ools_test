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


print "\nRunning Script plant_euca2ools_tarball.pl\n\n";

#### read the input list

read_input_file();

prepare_setup_directory();

if( is_euca2ools_repo_for_test_from_memo() == 1){

	direct_euca2ools_installation_from_repo();

}else{

	direct_euca2ools_installation_from_bzr();	

};

print "\n\n[TEST_REPORT]\tCOMEPLETED INSTALLATION OF EUCA2OOLS on CLC MACHINE\n";

exit(0);



################################ SUBROUTINES #############################################


sub prepare_setup_directory{

	my $headnode = $ENV{'QA_HEADNODE'};

	#run the REPO install script
        print("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root; mkdir -p /root/euca2ools_test_setup \"\n");
        system("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root; mkdir -p /root/euca2ools_test_setup \" ");
        print "\n";

	#copy the input file to the head node
	print("scp -o StrictHostKeyChecking=no ../input/2b_tested.lst root\@$headnode:/root/euca2ools_test_setup/.\n");
	system("scp -o StrictHostKeyChecking=no ../input/2b_tested.lst root\@$headnode:/root/euca2ools_test_setup/.");
	print "\n";

	return 0;
};


sub direct_euca2ools_installation_from_repo{

	my $headnode = $ENV{'QA_HEADNODE'};

	print "\nEuca2ools Test will be performed from REPO installation\n";
	print "\nREPO\t$ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'}\n";
	print "\n";

	#copy the euca2ool install from REPO script to the head node
	
	print("scp -o StrictHostKeyChecking=no ./install_euca2ools_from_repo.pl root\@$headnode:/root/euca2ools_test_setup/.\n");
	system("scp -o StrictHostKeyChecking=no ./install_euca2ools_from_repo.pl root\@$headnode:/root/euca2ools_test_setup/.");
	print "\n";


	#run the REPO install script
	print("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root/euca2ools_test_setup; perl ./install_euca2ools_from_repo.pl \"\n");
	system("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root/euca2ools_test_setup; perl ./install_euca2ools_from_repo.pl \" ");
	print "\n";

	return 0;

};


sub direct_euca2ools_installation_from_bzr{

	my $headnode = $ENV{'QA_HEADNODE'};
	my $bzr_dir = $ENV{'QA_BZR_DIR'};
	my $bzr_name = $ENV{'QA_BZR_NAME'};

	print "BZR_BRANCH\t$bzr_dir\n";
	print "BZR_NAME\t$bzr_name\n";

	my $bzr_group = "default";
	my $temp_dir = "$ENV{'TEST_HOME'}/temp_space/temp_bzr_euca2ools/" . $headnode;

	if( $bzr_name =~ /main/ ){
		$bzr_group = "main";
	}elsif( $bzr_name =~ /eee/ ){
		$bzr_group = "eee";
	}elsif( $bzr_name =~ /2\.0\.0/ ){
		$bzr_group = "2.0.0";
	}else{
		$bzr_group = "default";
	};

	$temp_dir .= $bzr_group;

	print "BZR_GROUP\t$bzr_group\n";
	print "TEMP_DIR \t$temp_dir\n";

	system("rm -fr $temp_dir");
	system("mkdir -p $temp_dir");

	chdir("$temp_dir");

	my $euca2ools_bzr;

	if( $bzr_group eq "main" ){
		$euca2ools_bzr = "euca2ools-main";
	}elsif( $bzr_group eq "eee" ){
		$euca2ools_bzr = "euca2ools-1.3";
	}elsif( $bzr_group eq "2.0.0" ){
		$euca2ools_bzr = "euca2ools-1.3";
	}else{
		$euca2ools_bzr = "euca2ools-1.3";
	};

	if( is_euca2ools_bzr_for_test_from_memo() == 1){
		my $euca2ools_bzr_for_test = $ENV{'QA_MEMO_EUCA2OOLS_BZR_FOR_TEST'};
		if( $euca2ools_bzr_for_test =~ /(euca2ools\S+)/ ){
			$euca2ools_bzr = $1;
		};
	};

	print "\nCOMMAND: bzr co sftp://root\@192.168.7.1/home/repositories/tools/$euca2ools_bzr\n";
	system("bzr co sftp://root\@192.168.7.1/home/repositories/tools/$euca2ools_bzr");


	my $pkg_temp_dir = $temp_dir . "/" . $euca2ools_bzr;

	chdir("$pkg_temp_dir");

	# get the revno for euca2ools
	my $revno_euca2ools = 0;

	my $temp_out = `bzr revno`;
	chomp($temp_out);

	if( $temp_out =~ /(\d+)/ ){
		$revno_euca2ools = $1;
	}else{
		print "Error : Couldn't detect REVISION NUMBER !!\n";
		exit(1);
	};

	print "REVISION NUMBER\t$revno_euca2ools\n";

	system("touch $temp_dir/revno-$revno_euca2ools");

	system("bzr export $temp_dir/euca2ools-for-test.tgz");


	# delete $pkg_branch
	chdir("$temp_dir");

	# untar tgz
	system("rm -fr $pkg_temp_dir");
	system("tar -zxvf ./euca2ools-for-test.tgz");

	# remove the tar
	system("rm -f ./euca2ools-for-test.tgz");

	# change the directory
	chdir("$temp_dir/euca2ools-for-test");

	# add /deps
	system("mkdir -p ./deps");
	system("cp $ENV{'TEST_HOME'}/temp_space/4_euca2ools/deps/* $temp_dir/euca2ools-for-test/deps/.");

	# retar tgz
	chdir("$temp_dir");
	system("tar -zcvf euca2ools-for-test.tgz ./euca2ools-for-test");

	chdir("$ENV{'PWD'}");


	#copy the tarball that contains the latest euca2ools 
	print("scp -o StrictHostKeyChecking=no $temp_dir/euca2ools-for-test.tgz root\@$headnode:/root/euca2ools_test_setup/.\n");
	system("scp -o StrictHostKeyChecking=no $temp_dir/euca2ools-for-test.tgz root\@$headnode:/root/euca2ools_test_setup/.");


	#copy the euca2ool install script to the head node
	print("scp -o StrictHostKeyChecking=no ./install_euca2ools.pl root\@$headnode:/root/euca2ools_test_setup/.\n");
	system("scp -o StrictHostKeyChecking=no ./install_euca2ools.pl root\@$headnode:/root/euca2ools_test_setup/.");


	#run the install script
	print("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root/euca2ools_test_setup/.; perl ./install_euca2ools.pl \"\n");
	system("ssh -o StrictHostKeyChecking=no root\@$headnode \"cd /root/euca2ools_test_setup/.; perl ./install_euca2ools.pl \" ");

	#clean up
	system("rm -fr $temp_dir");

	return 0;

};


sub read_input_file{

	my $headnode;
	my $bzr_dir;
	my $bzr_name;

	my $is_memo = 0;
	my $memo = "";

	print "Reading the input file ../input/2b_tested.lst\n\n";

	open( LIST, "../input/2b_tested.lst" ) or die "$!";
	my $line;
	while( $line = <LIST> ){
		chomp($line);
		if( $is_memo ){
			if( $line ne "END_MEMO" ){
				$memo .= $line . "\n";
			}else{
				$is_memo = 0;
			};
		}elsif( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[(.+)\]/ ){
			my $this_roll = $6;
			if( does_It_Have($this_roll, "CLC") ){
				$headnode = $1;
			};
        	}elsif($line =~ /^BZR_BRANCH\s+(.+)/ ){
			$bzr_dir = $1;
			if( $bzr_dir =~ /\/eucalyptus\/(.+)/ ){
				$bzr_name = $1;
			};
		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		};
	
	};

	close(LIST);

        $ENV{'QA_HEADNODE'} = $headnode;
        $ENV{'QA_BZR_DIR'} = $bzr_dir;
        $ENV{'QA_BZR_NAME'} = $bzr_name;
	$ENV{'QA_MEMO'} = $memo;

	return 0;
};


sub is_euca2ools_bzr_for_test_from_memo{
	if( $ENV{'QA_MEMO'} =~ /EUCA2OOLS_BZR_FOR_TEST=(.+)\n/ ){
		my $bzr = $1;
		$bzr =~ s/\r//g;
		print "FOUND in MEMO\n";
		print "EUCA2OOLS_BZR_FOR_TEST=$bzr\n";
		$ENV{'QA_MEMO_EUCA2OOLS_BZR_FOR_TEST'} = $bzr;
		return 1;
	};
	return 0;
};


sub is_euca2ools_repo_for_test_from_memo{
	if( $ENV{'QA_MEMO'} =~ /EUCA2OOLS_REPO_FOR_TEST=(.+)\n/ ){
		my $bzr = $1;
		$bzr =~ s/\r//g;
		print "FOUND in MEMO\n";
		print "EUCA2OOLS_REPO_FOR_TEST=$bzr\n";
		$ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} = $bzr;
		return 1;
	};
	return 0;
};


