package check_modules;
use strict;
use warnings;

sub installed_modules {
        foreach my $module (@_) {
		next unless defined $module;
		chomp($module);
                eval "use $module";
                if ($@) {
                        print "A module $module not installed. Install his.";
                        exit 0;
                }
        }
}


my $filename = "requirements.txt";

open(my $fh, '<:encoding(utf8)', $filename) or die "[Error] $!";
my @array_modules = <$fh>;
&installed_modules(@array_modules);
1;
