#!/usr/local/bin/perl -w
#
# File: mailmanWrapper.pl
# Author: Morgan Jones (morgan@commnav.com)
# Date: 10/15/02
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
use strict;
use Mail::SendEasy;

my $domain = "kutztown.edu";

$ENV{LD_LIBRARY_PATH} = "/usr/local/ssl/lib";

open (OUT, ">/tmp/getSubscribers.$$");

# set input separator to two or more carriage returns.
$/="";
# get the first chunk, the headers
my @message = <>;
my $headers = $message[0];
$headers =~ s/\n\s+//g;
my @addrs;

# pull out the To: header
my $to = $headers;
my $from = $headers;
my $cc;
die "no To: header !?"
    unless ($to =~ /^To:\s*([^\n]+)$/mi);
$to = $1;
die "no From: header !?"
    unless ($from =~ /^From:\s*([^\n]+)$/mi);
$from = $1;
#print OUT "FROM is: $from\n";

if ($cc =~ "[Cc][Cc]:"){
    $cc =~ /^Cc:\s*([^\n]+)$/mi;
    $cc = $1;
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
    my $eaddrs = getAddrs($to);
    $eaddrs .= getAddrs($cc);
    chop ($eaddrs);
#    print OUT "eaddrs is: $eaddrs\n";
    my @addr =  split(/\,/,$eaddrs);
    my $members;
    foreach my $ful_sin_addr (@addr) {
	my ($sin_addr, $dom_addr) = split(/\@/,$ful_sin_addr,2);
	my ($listname, $junk) = split(/-/,$sin_addr,2);
	my $var = `ldapsearch -Lb o=kutztown.edu cn=$listname dn`;
	if ($var ne ""){
	   my $str = `ldapsearch -Lb o=kutztown.edu cn=$listname uniqueMember | grep uniqueMember | awk '{ print \$2 }'`;
	   my @subscribers = split(/\n/,$str);
	   foreach my $ind_sub (@subscribers){
	        $ind_sub =~ /^([a-z0-9=]+)=([a-z0-9]*)/i;
		$members .= "$2\@kutztown.edu\n";
	   }
#	print OUT "Members are $members\n";
        my $efrom = getAddrs($from);
	my $status = Mail::SendEasy::send(
  	   smtp => 'localhost' ,
  	   from    => 'postmaster@kutztown.edu' ,
  	   reply   => 'admin@kutztown.edu' ,
  	   error   => 'admin@kutztown.edu' ,
  	   to      => "$efrom" ,
  	   subject => "Course $listname: Subscribers" ,
  	   msg     => "$members" ,
  	) ;
  
  	if (!$status) { print OUT "Error: " . Mail::SendEasy::error . "\n";}
	
	}
	 
	#print OUT "execing /$cmd/\n";

	#print OUT @message;
	my $rc = $? >> 8;
	#print OUT "rc: $rc\n";
#	print OUT "sin_addr is: $sin_addr\n";

    }
}
close OUT;

system "/usr/bin/rm /tmp/getSubscribers.$$";

sub getAddrs {
    my $to = $_[0];
#    print OUT "$to\n";
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
    return $return;
}



__END__

