#!/usr/bin/perl

use strict;

local $| = 1;

my $arch = "32";
my $distro = "CENTOS";
my $source = "";
my $roll = "";
my $bzr_name = "";
my $bzr_group = "";

($distro, $source, $roll) = read_input_file();
$arch = $ENV{'ARCH'};
$bzr_name = $ENV{'BZR_DIR'};

print "BZR_NAME\t$bzr_name\n";

if( $bzr_name =~ /main/ ){
	$bzr_group = "main";
}elsif( $bzr_name =~ /eee/ ){
	$bzr_group = "eee";
}elsif( $bzr_name =~ /2\.0\.0/ ){
	$bzr_group = "2.0.0";
}else{
	$bzr_group = "default";
};

print "BZR_GROUP\t$bzr_group\n";


# for ubuntu and debian only for now

if( $distro eq "UBUNTU" || $distro eq "DEBIAN" ){

	system("apt-get -y install python-dev swig libssl-dev make help2man gcc");

}elsif( $distro eq "OPENSUSE"  ){

	system("zypper -n in swig python-devel make help2man gcc");

}elsif( $distro eq "FEDORA" ){
	
	system("yum -y install swig python-devel make m2crypto help2man gcc");

	system("cp /usr/include/openssl/opensslconf.h /usr/include/");

}elsif( $distro eq "CENTOS" ){

	system("yum -y install swig make gcc");

	system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/help2man-1.33.1-2.noarch.rpm");
        system("rpm -i help2man-1.33.1-2.noarch.rpm");


	if( $arch eq "64" ){
		system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-2.5.1-bashton1.x86_64.rpm");
		system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-devel-2.5.1-bashton1.x86_64.rpm");
		system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-libs-2.5.1-bashton1.x86_64.rpm");

		system("rpm -i python25-libs-2.5.1-bashton1.x86_64.rpm python25-2.5.1-bashton1.x86_64.rpm");
		system("rpm -i python25-devel-2.5.1-bashton1.x86_64.rpm");

		system("cp /usr/include/openssl/opensslconf-x86_64.h /usr/include/");
	
       	}else{
		system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-2.5.1-bashton1.i386.rpm");
                system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-devel-2.5.1-bashton1.i386.rpm");
                system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/python25-libs-2.5.1-bashton1.i386.rpm");

                system("rpm -i python25-libs-2.5.1-bashton1.i386.rpm python25-2.5.1-bashton1.i386.rpm");
                system("rpm -i python25-devel-2.5.1-bashton1.i386.rpm");

		system("cp /usr/include/openssl/opensslconf-i386.h /usr/include/");

       	};

}elsif( $distro eq "RHEL" ){

	system("yum -y install swig make gcc");
	system("wget http://192.168.7.84/4_test_server/4_euca2ools/python25/help2man-1.33.1-2.noarch.rpm");
        system("rpm -i help2man-1.33.1-2.noarch.rpm");
};


# untar

system("tar zxvf ./euca2ools-for-test.tgz");

chdir("/root/euca2ools_test_setup/euca2ools-for-test/deps");

if( is_use_custom_boto_from_memo() == 1 ){
	my $custom_boto = $ENV{'QA_MEMO_USE_CUSTOM_BOTO'};
	system("wget -O boto-custom-version.tar.gz $custom_boto");
	system("tar zxvf ./boto-custom-version.tar.gz");
	my $boto_dir = get_directory_name_begins_with("boto");
	chdir("./$boto_dir");
}else{
	# install boto
	if( $bzr_group eq "main" ){
		system("tar zxvf boto-2.0b3.tar.gz");
		chdir("./boto-2.0b3");
	}elsif( $bzr_group eq "eee" ){
		system("tar zxvf boto-1.9b.tar.gz");
		chdir("./boto-1.9b");
	}elsif( $bzr_group eq "2.0.0" ){
		system("tar zxvf boto-1.9b.tar.gz");
		chdir("./boto-1.9b");
	}else{
		system("tar zxvf boto-1.9b.tar.gz");
		chdir("./boto-1.9b");
	};
};

if( $distro eq "CENTOS" ){
	system("python2.5 setup.py install");
}else{
	system("python setup.py install");
};

#install M2Crypto
chdir("/root/euca2ools_test_setup/euca2ools-for-test/deps");

system("tar zxvf M2Crypto-0.20.1.tar.gz");
chdir("./M2Crypto-0.20.1");


if( $distro eq "CENTOS" ){
        system("python2.5 setup.py install");
}else{
	system("python setup.py install");
};


if( $distro eq "CENTOS" ){
	chdir("/root/euca2ools_test_setup/euca2ools-for-test");
#	system("python2.5 setup.py build");
	system("python2.5 setup.py install");

###	070811
#	system("ln -sf /usr/bin/python25 /usr/bin/python");

###	070811
#	chdir("/root/euca2ools_test_setup/euca2ools-for-test");
#        system("make");

	my $file_list = `ls /usr/bin/euca-*`;
	my @file_array = split( "\n", $file_list );

	my $from = "#!/usr/bin/python";
	my $to = "#!/usr/bin/env python2.5";

	foreach my $e_file ( @file_array ){
#		my_sed($from, $to, $e_file);	
	};

}else{
	chdir("/root/euca2ools_test_setup/euca2ools-for-test");
	system("make");
};


# then change all the files with python2.5 at the top


exit(0);


# Read input values from input.txt
sub read_input_file{

	my $distro = "";
        my $source = "";
        my $roll = "";

	my $is_memo = 0;
	my $memo = "";

	open( INPUT, "< /root/euca_builder/input.txt" ) || die $!;

	my $line;
	while( $line = <INPUT> ){
		chomp($line);
		if( $is_memo ){
			if( $line ne "END_MEMO" ){
				$memo .= $line . "\n";
			}else{
				$is_memo = 0;
			};
		}elsif( $line =~ /^([\d\.]+)\t(.+)\t(.+)\t(\d+)\t(.+)\t\[(.+)\]/ ){
			print "IP $1 [Distro $2, Version $3, Arch $4] will be built from $5 with Eucalyptus-$6\n";
			$distro = $2;
			$source = $5;
			$roll = $6;

			$ENV{'ARCH'} = $4;

        	}elsif( $line =~ /^NETWORK\t(.+)/ ){
        	        print( "\nThe testing network environment will be $1\n" );
        	        $ENV{'BUILD_NETWORK'} = $1;
        	        # $build_network = $1;
        	}elsif( $line =~ /^BZR_DIRECTORY\t(.+)/ ){
        	        print ( "\nBZR Directory is $1\n" );
        	        $ENV{'BZR_DIR'} = $1;
        	        # $bzr_dir = $1;
        	}elsif( $line =~ /^BZR_REVISION\t(.+)/ ){
        	        print ( "\nBZR Revision Number is $1\n" );
        	        $ENV{'BZR_REV'} = $1;
        	        # $bzr_rev = $1;
		}elsif( $line =~ /^MEMO/ ){
			$is_memo = 1;
		}elsif( $line =~ /^END_MEMO/ ){
			$is_memo = 0;
		}; 

	};	

	close(INPUT);

	$ENV{'QA_MEMO'} = $memo;

	return ($distro, $source, $roll);
};


sub is_use_custom_boto_from_memo{
	$ENV{'QA_MEMO_USE_CUSTOM_BOTO'} = "NO";
	if( $ENV{'QA_MEMO'} =~ /USE_CUSTOM_BOTO=(.+)\n/ ){
		my $extra = $1;
                $extra =~ s/\r//g;
                print "FOUND in MEMO\n";
                print "USE_CUSTOM_BOTO=$extra\n";
                $ENV{'QA_MEMO_USE_CUSTOM_BOTO'} = $extra;
                return 1;
        };
        return 0;
};

sub get_directory_name_begins_with{

        my $str = shift @_;
        my $result = "";

        my $this_dir = `ls`;
        chomp($this_dir);

        my @this_array = split(' ', $this_dir);

        foreach my $this_item (@this_array){
                if( $this_item =~ /^$str/ && !($this_item =~ /\.gz/ || $this_item =~ /\.tgz/) ){
                        $result = $this_item;
                };
        };

        return $result;

};


# To make 'sed' command human-readable
# my_sed( target_text, new_text, filename);
#   --->
#        sed --in-place 's/ <target_text> / <new_text> /' <filename>
sub my_sed{

        my ($from, $to, $file) = @_;

        $from =~ s/([\'\"\/])/\\$1/g;
        $to =~ s/([\'\"\/])/\\$1/g;

        my $cmd = "sed --in-place 's/" . $from . "/" . $to . "/' " . $file;

        system("$cmd");

        return 0;
};


