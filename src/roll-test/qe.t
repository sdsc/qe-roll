#!/usr/bin/perl -w
# qe roll installation test.  Usage:
# qe.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend
my $compiler="ROLLCOMPILER";
my $mpi="ROLLMPI";
my $network="ROLLNETWORK";

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
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load qe
fi
mkdir $TESTFILE.dir
cd $TESTFILE.dir
cp -r /opt/qe/tests/* .
/opt/qe/tests/check-pw.x.j *paw*.in
END
  close(OUT);
 `/bin/bash $TESTFILE.sh >& o`;
  ok(`grep -c passed o` == 6,'quantum espresso works');
}

SKIP: {
  skip 'quantum espresso not installed', 1
    if $appliance !~ /$installedOnAppliancesPattern/;
  skip 'modules not installed', 1 if ! -f '/etc/profile.d/modules.sh';
    my ($noVersion) = "qe" =~ m#([^/]+)#;
    `/bin/ls /opt/modulefiles/applications/$noVersion/[0-9]* 2>&1`;
    ok($? == 0, "quantum espresso module installed");
    `/bin/ls /opt/modulefiles/applications/$noVersion/.version.[0-9]* 2>&1`;
    ok($? == 0, "quantum espresso version module installed");
    ok(-l "/opt/modulefiles/applications/$noVersion/.version",
       "quantum espresso version module link created");
}

`rm -fr $TESTFILE*`;
