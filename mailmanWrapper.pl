#!/bin/perl -w
#
# File: mailmanWrapper.pl
# Authors: Morgan Jones (morgan@morganjones.org)
#          with modifications by Frank Fossa
# Date: 02/12/04
#
#   Description: This is a workaround to allow mailman to work with
#       iPlanet/Sun ONE Messenger.  iPlanet/Sun ONE Messenger requires a
#       mail delivery command to be registered with argument list with
#       the MTA prior to execution.  Mailman requires commands like the
#       below to be run for each mailing list.  The problem is that for
#       each new mailing list that's created, three new commands would
#       need to be registered with the mta.  This would quickly get
#       cumbersome.
#
#       ## morgantest mailing list
#       ## created: 14-Oct-2002 root
#       morgantest:         "|/opt/mailman/mail/mailman post morgantest"
#       morgantest-admin:   "|/opt/mailman/mail/mailman mailowner morgantest"
#       morgantest-bounces: "|/opt/mailman/mail/mailman bounces morgantest"
#       morgantest-confirm: "|/opt/mailman/mail/mailman confirm morgantest"
#       morgantest-join:    "|/opt/mailman/mail/mailman join morgantest"
#       morgantest-leave:   "|/opt/mailman/mail/mailman leave morgantest"
#       morgantest-owner:   "|/opt/mailman/mail/mailman owner morgantest"
#       morgantest-request: "|/opt/mailman/mail/mailman request morgantest"
#       morgantest-subscribe: "|/opt/mailman/mail/mailman subscribe morgantest"
#       morgantest-unsubscribe: "|/opt/mailman/mail/mailman unsubscribe morgantest"
#       morgantest-owner:   morgantest-admin
#
#       Rather than registering commands such as the above with the MTA,
#       place this perl script it <messaging
#       root>/msg-<instance>/imta/programs and set any Mailman aliases
#       to deliver to it.  The ldap entries for the above aliases are
#       below the script.
#
use strict;

my $domain = "kutztown.edu";
my $wrapperCmd = "/opt/mailman/mail/mailman";

# $ENV{LD_LIBRARY_PATH} = "/usr/local/ssl/lib";

open (OUT, ">/tmp/mailmanWrapper.$$");

# set input separator to two or more carriage returns.
$/="";
# get the first chunk, the headers
my @message = <>;
my $headers = $message[0];
$headers =~ s/\n\s+//g;
my @addrs;

# pull out the To: header
my $to = $headers;
#my $cc = $headers;
my $cc;
die "no To: header !?"
    unless ($to =~ /^To:\s*([^\n]+)$/mi);
$to = $1;
#if ($cc =~ "[Cc][Cc]:"){
#    print OUT "does contain CC\n";
#    $cc =~ /^Cc:\s*([^\n]+)$/mi;
#    $cc = $1;
#}
if ($headers =~ /^Cc:\s*([^\n]+)$/mi) {
	$cc = $1;
	#print OUT "CC is 1234: $cc\n";
}

if ($to !~ /^[^@]+@[^\.]*\.*$domain/) {
    # sanity check to make sure we're sending to this domain.  This
    # may not be necessary. (?)
    print OUT "not in $domain.  Exiting.\n";
} else {
    # parse the to: address, call the mailman wrapper appropriately
    # Frank Fossa 02062004
    # sometimes addresses don't come first, sometimes they come in <>
    # sometimes they send to multiple addresses
    # so need to modify to accomodate
    # also need to look for CC: addresses
    #$to =~ /^([^@]+)@/;
    #print OUT "To is: ";
    my $eaddrs = getAddrs($to);
    #print OUT "Cc is: ";
    $eaddrs .= getAddrs($cc);
    chop ($eaddrs);
    #print OUT "eaddrs is: $eaddrs\n";
	my @addr =  split(/\,/,$eaddrs);
	foreach my $ful_sin_addr (@addr) {
		my $cmd;
		my ($sin_addr, $dom_addr) = split(/\@/,$ful_sin_addr,2);
		if ($sin_addr =~ /(-admin)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd admin $sin_addr";
		} elsif ($sin_addr =~ /(-bounces)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd bounces $sin_addr";
		} elsif ($sin_addr =~ /(-confirm)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd confirm $sin_addr";
		} elsif ($sin_addr =~ /(-join)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd join $sin_addr";
		} elsif ($sin_addr =~ /(-leave)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd leave $sin_addr";
		} elsif ($sin_addr =~ /(-owner)$/i ) {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd owner $sin_addr";
		} elsif ($sin_addr =~ /(-request)$/i)  {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd request $sin_addr\n";
		} elsif ($sin_addr =~ /(-subscribe)$/i)  {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd subscribe $sin_addr\n";
		} elsif ($sin_addr =~ /(-unsubscribe)$/i)  {
			$sin_addr =~ s/$1$//i;
			$cmd = "$wrapperCmd unsubscribe $sin_addr\n";
		} else {
			$cmd = "$wrapperCmd post $sin_addr\n";
		}
		#print OUT "execing /$cmd/\n";

		open (CMD, "|$cmd");
		print CMD @message;
		close CMD;
		#print OUT @message;
		my $rc = $? >> 8;
		print OUT "rc: $rc\n";
		#print OUT "sin_addr is: $sin_addr\n";
	}
}

close OUT;
#system "/usr/bin/rm /tmp/mailmanWrapper.$$";

sub getAddrs {
    my $to = $_[0];
    print OUT "TO is: $to\n";
    my $return;
    $to =~ /^[^@]+@[^@]+\,[^@]+@[^@]+/;
    $to =~ s/\"//g;
    @addrs = split(/\,\s*/,$to);
    my $maddr;
    my $newmaddr;
    foreach $maddr (@addrs){
        unless ($maddr =~ /^[^@]+@[^@]+/) { next; }
        if (($maddr =~ '<') and ($maddr =~ '>')){
           $maddr =~ /^([^<]+)<([^>]+)>$/;
           $newmaddr = $2;
        }else{
           $newmaddr = $maddr;
        }
        $return .= "$newmaddr,";
    }
    return lc($return);
}



__END__

## morgantest mailing list
## created: 14-Oct-2002 root
morgantest:         "|/opt/mailman/mail/wrapper post morgantest"
morgantest-admin:   "|/opt/mailman/mail/wrapper mailowner morgantest"
morgantest-request: "|/opt/mailman/mail/wrapper mailcmd morgantest"
morgantest-owner:   morgantest-admin




dn: cn=morgantest,ou=groups,o=domain.com
mailProgramDeliveryInfo: mailmanWrapper
mailDeliveryOption: program
mailAlternateAddress: morgantest@mailhost.domain.com
mail: morgantest@domain.com
mailHost: mailhost.domain.com
objectClass: top
objectClass: inetLocalMailRecipient
objectClass: inetMailGroup
objectClass: groupOfUniqueNames
inetMailGroupStatus: active
cn: morgantest

dn: cn=morgantest-admin,ou=groups,o=domain.com
mailProgramDeliveryInfo: mailmanWrapper
mailDeliveryOption: program
mailAlternateAddress: morgantest-admin@mailhost.domain.com
mail: morgantest-admin@domain.com
mailHost: mailhost.domain.com
objectClass: top
objectClass: inetLocalMailRecipient
objectClass: inetMailGroup
objectClass: groupOfUniqueNames
inetMailGroupStatus: active
cn: morgantest-admin

dn: cn=morgantest-request,ou=groups,o=domain.com
mailProgramDeliveryInfo: mailmanWrapper
mailDeliveryOption: program
mailAlternateAddress: morgantest-request@mailhost.domain.com
mail: morgantest-request@domain.com
mailHost: mailhost.domain.com
objectClass: top
objectClass: inetLocalMailRecipient
objectClass: inetMailGroup
objectClass: groupOfUniqueNames
inetMailGroupStatus: active
cn: morgantest-request

dn: cn=morgantest-owner,ou=groups,o=domain.com
mailAlternateAddress: morgantest-owner@mailhost.domain.com
mail: morgantest-owner@domain.com
mailHost: mailhost.domain.com
objectClass: top
objectClass: inetLocalMailRecipient
objectClass: inetMailGroup
objectClass: groupOfUniqueNames
inetMailGroupStatus: active
cn: morgantest-owner
mgrpRFC822MailMember: morgantest-admin

