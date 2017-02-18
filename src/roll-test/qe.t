#!/usr/bin/perl -w
# qe roll installation test.  Usage:
# qe.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = 'Compute';
my $output;
my $TESTFILE = 'tmpqe';

# qe-install.xml
if($appliance =~ /$installedOnAppliancesPattern/) {
  ok(-d "/opt/qe", "quantum espresso installed");
} else {
  ok(! -d "/opt/qe", "quantum espresso not installed");
}

SKIP: {

  skip 'quantum espresso not installed', 1 if ! -d "/opt/qe";
  skip 'quantum espresso test not installed', 1 if ! -d "/opt/qe/tests";
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
mkdir $TESTFILE.dir
cd $TESTFILE.dir
cp -r /opt/qe/tests/* .
module load qe
/opt/qe/tests/check-neb.x.j
END
  close(OUT);
 `/bin/bash $TESTFILE.sh >& $TESTFILE.out`;
  ok(`grep -c 'grep -c 'Parallel version' $TESTFILE.dir/neb1.out ` == 1, 'quantum espresso will run in parallel');
  ok(`grep -c passed $TESTFILE.out` >= 3, 'quantum espresso works');
}

SKIP: {
  skip 'quantum espresso not installed', 1
    if $appliance !~ /$installedOnAppliancesPattern/;
  `/bin/ls /opt/modulefiles/applications/qe/[0-9]* 2>&1`;
  ok($? == 0, "quantum espresso module installed");
  `/bin/ls /opt/modulefiles/applications/qe/.version.[0-9]* 2>&1`;
  ok($? == 0, "quantum espresso version module installed");
  ok(-l "/opt/modulefiles/applications/qe/.version",
     "quantum espresso version module link created");
}

`rm -fr $TESTFILE*`;
