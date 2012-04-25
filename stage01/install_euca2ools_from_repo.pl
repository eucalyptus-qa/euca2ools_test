#!/usr/bin/perl

use strict;

$ENV{'EUCALYPTUS'} = "";

print "\nRunning Script install_euca2ools_from_repo.pl\n";

read_input_file();

is_euca2ools_repo_for_test_from_memo();

install_euca2ools_from_repo();

exit(0);

1;



############################ SUBROUTINES #############################################


# does_It_Have( $arg1, $arg2 )
# does the string $arg1 have $arg2 in it ??
sub does_It_Have{
	my ($string, $target) = @_;
	if( $string =~ /$target/ ){
		return 1;
	};
	return 0;
};


sub ubuntu_euca2ools_repo_install{

	my $roll = $ENV{'QA_ROLL'};
	my $bzr_dir = $ENV{'QA_BZR_DIR'};

	### set up Euca2ools REPO	020411
        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
                system("( echo deb $euca2ools_repo lucid universe >> /etc/apt/sources.list )");
        }else{
                system("( echo deb http://192.168.7.65/auto-repo/nightly/current-euca2ools-ubuntu lucid universe >> /etc/apt/sources.list )");
	};

	system("apt-get update");

	system("apt-get --force-yes -y install gcc");

	system("apt-get --force-yes -y install euca2ools");

	return 0;
};


sub debian_euca2ools_repo_install{

	my $distro = $ENV{'QA_DISTRO'};
	my $source = $ENV{'QA_SOURCE'};
	my $roll = $ENV{'QA_ROLL'};
	
	### set up Euca2ools REPO	020411
        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
                system("( echo deb $euca2ools_repo squeeze main  >> /etc/apt/sources.list )");
        }else{
                system("( echo deb http://192.168.7.65/auto-repo/nightly/current-euca2ools-debian squeeze main  >> /etc/apt/sources.list )");
	};

	system("apt-get update");

	system("apt-get --force-yes -y install gcc");

	system("apt-get --force-yes -y install euca2ools");

	return 0;
};


sub opensuse_euca2ools_repo_install{
	
	my $distro = $ENV{'QA_DISTRO'};
	my $source = $ENV{'QA_SOURCE'};
	my $roll = $ENV{'QA_ROLL'};

	### set up Euca2ools REPO	020411
        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
                system("zypper ar --refresh $euca2ools_repo Euca2ools");
	}else{
                system("zypper ar --refresh http://192.168.7.65/auto-repo/nightly/current-euca2ools-opensuse Euca2ools");
	};

	system("zypper --no-gpg-checks refresh Euca2ools");

	system("zypper -n in gcc");

	system("zypper -n in euca2ools");

	return 0;
};


sub centos_euca2ools_repo_install{

        my $distro = $ENV{'QA_DISTRO'};
	my $arch = $ENV{'QA_ARCH'};
        my $source = $ENV{'QA_SOURCE'};
        my $roll = $ENV{'QA_ROLL'};

	system("rm -f /etc/yum.repos.d/euca2ools.repo");

	system("touch /etc/yum.repos.d/euca2ools.repo");
	system("(echo \"[euca2ools]\" >> /etc/yum.repos.d/euca2ools.repo)");
	system("(echo \"name=Euca2ools\" >> /etc/yum.repos.d/euca2ools.repo)");

        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
		system("(echo \"baseurl=" . $euca2ools_repo ."\" >> /etc/yum.repos.d/euca2ools.repo)");
	}else{
		system("(echo \"baseurl=http://192.168.7.65/auto-repo/nightly/current-euca2ools-centos\" >> /etc/yum.repos.d/euca2ools.repo)");
	};
	system("(echo \"enabled=1\" >> /etc/yum.repos.d/euca2ools.repo)");


	system("yum update");

	system("yum -y install gcc");

	system("yum -y install euca2ools --nogpgcheck");

	return 0;
};


sub fedora_euca2ools_repo_install{

	my $distro = $ENV{'QA_DISTRO'};
	my $arch = $ENV{'QA_ARCH'};
	my $source = $ENV{'QA_SOURCE'};
	my $roll = $ENV{'QA_ROLL'};

	system("rm -f /etc/yum.repos.d/euca2ools.repo");

	system("touch /etc/yum.repos.d/euca2ools.repo");
	system("(echo \"[euca2ools]\" >> /etc/yum.repos.d/euca2ools.repo)");
	system("(echo \"name=Euca2ools\" >> /etc/yum.repos.d/euca2ools.repo)");

	### set up Euca2ools REPO	020411
        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
		system("(echo \"baseurl=" . $euca2ools_repo . "\" >> /etc/yum.repos.d/euca2ools.repo)");
	}else{
		system("(echo \"baseurl=http://192.168.7.65/auto-repo/nightly/current-euca2ools-fedora\" >> /etc/yum.repos.d/euca2ools.repo)");
	};

	system("(echo \"enabled=1\" >> /etc/yum.repos.d/euca2ools.repo)");

	system("yum update");

	system("yum -y install gcc");

	system("yum -y install euca2ools --nogpgcheck");

	return 0;
};


sub rhel_euca2ools_repo_install{

        my $distro = $ENV{'QA_DISTRO'};
	my $arch = $ENV{'QA_ARCH'};
        my $source = $ENV{'QA_SOURCE'};
        my $roll = $ENV{'QA_ROLL'};

	system("rm -f /etc/yum.repos.d/euca2ools.repo");

	system("touch /etc/yum.repos.d/euca2ools.repo");
	system("(echo \"[euca2ools]\" >> /etc/yum.repos.d/euca2ools.repo)");
	system("(echo \"name=Euca2ools\" >> /etc/yum.repos.d/euca2ools.repo)");

        if( $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} ne "" ){
                my $euca2ools_repo = $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'};
		system("(echo \"baseurl=" . $euca2ools_repo ."\" >> /etc/yum.repos.d/euca2ools.repo)");
	}else{
		system("(echo \"baseurl=http://192.168.7.65/auto-repo/nightly/current-euca2ools-centos\" >> /etc/yum.repos.d/euca2ools.repo)");
	};
	system("(echo \"enabled=1\" >> /etc/yum.repos.d/euca2ools.repo)");


	system("yum update");

	system("yum -y install gcc");

	system("yum -y install euca2ools --nogpgcheck");

	return 0;
};


sub install_euca2ools_from_repo{

	my $distro = $ENV{'QA_DISTRO'};

	if( $distro eq "UBUNTU"){

		ubuntu_euca2ools_repo_install();

	}elsif( $distro eq "DEBIAN" ){

		debian_euca2ools_repo_install();

	}elsif( $distro eq "OPENSUSE" ){

		opensuse_euca2ools_repo_install();

	}elsif( $distro eq "CENTOS" ){
		
#		fix_python_link();
		centos_euca2ools_repo_install();
#		return_python_link();

	}elsif( $distro eq "FEDORA" ){

#		fix_python_link();
		fedora_euca2ools_repo_install();
#		return_python_link();

	}elsif( $distro eq "RHEL" ){

#		fix_python_link();
		rhel_euca2ools_repo_install();
#		return_python_link();

	}else{
		return 1;
	};

	return 0;
};


sub read_input_file{

	my $memo = "";
	my $is_memo = 0;

	print "Reading the input file ../input/2b_tested.lst\n\n";

	open( LIST, "./2b_tested.lst" ) or die "$!";
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
				$ENV{'QA_DISTRO'} = $2;
				$ENV{'QA_VERSION'} = $3;
				$ENV{'QA_ARCH'} = $4;
				$ENV{'QA_SOURCE'} = $5;				
				$ENV{'QA_ROLL'} = $6;				
			};
		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		};
	
	};

	close(LIST);

	$ENV{'QA_MEMO'} = $memo;

	return 0;

};



sub is_euca2ools_repo_for_test_from_memo{
        $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} = "";
        if( $ENV{'QA_MEMO'} =~ /EUCA2OOLS_REPO_FOR_TEST=(.+)\n/ ){
                my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "EUCA2OOLS_REPO_FOR_TEST=$extra\n";
                $ENV{'QA_MEMO_EUCA2OOLS_REPO_FOR_TEST'} = $extra;
                return 1;
        };
        return 0;
};


sub fix_python_link{
	system("rm -f /usr/bin/python");
	system("ln -sf /usr/bin/python2.4 /usr/bin/python");
	return 0;
};

sub return_python_link{
        system("rm -f /usr/bin/python");
        system("ln -sf /usr/bin/python2.5 /usr/bin/python");
        return 0;
};



1;

