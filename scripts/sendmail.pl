#!/usr/bin/perl
## INSTALL libio-socket-ssl-perl,libemail-simple-perl on docker

use Net::SMTP;
use Email::Simple;
use warnings;

##INIT SMTP Parameters
if(defined $ENV{SMTP_SERVER}){
  $mailhost = $ENV{SMTP_SERVER};
}
else{
  die "No smtp server configured";
}

$mailfrom = $ENV{SMTP_FROM};
$mailport = $ENV{SMTP_PORT};
$mailuser = $ENV{SMTP_USERNAME};
$mailpass = $ENV{SMTP_PASSWORD};
$debug = $ENV{SMTP_DEBUG};
$debug_file = $ENV{SMTP_DEBUG_FILE};
$debug_mhserver = $ENV{SMTP_DEBUG_MH_SERVER};
$debug_mhport = $ENV{SMTP_DEBUG_MH_PORT};
$starttls = $ENV{SMTP_STARTTLS};

if(defined $ENV{SMTP_HEADERS}){
  @mailheaders = split(';', $ENV{SMTP_HEADERS});
}

local $/;
my $mailin = <STDIN>;

my $email = Email::Simple->new($mailin);

my @rcpt;

foreach ($email->header("to")){
  if ($_ =~ /.*<(.*?)>/){
    push(@rcpt,$1);
  }
  else{
    push(@rcpt,$_);
  }
}

foreach ($email->header("cc")){
  if ($_ =~ /.*<(.*?)>/){
    push (@rcpt,$1);
  }
  else{
    push (@rcpt,$_);
  }
}

foreach ($email->header("bcc")){
  if ($_ =~ /.*<(.*?)>/){
    push(@rcpt,$1);
  }
  else{
    push(@rcpt,$_);
  }
}

if($debug){
  if ($debug_file){
    open(my $mailout, '>>', $debug_file) or die $!;
    print $mailout $email->as_string; # Print each entry in our array to the file
    close($mailout);
  }
  if($debug_mhserver){ ## Send Mail also to a mailhog server (or other configured)
    $mhsmtp = Net::SMTP->new($debug_mhserver, Port=>$debug_mhport) or die "Unable to contact SMTP Server";
    if($ENV{SMTP_KEEP_FROM}){
      $mhsmtp->mail($email->header("from"));
    }
    else{
      $mhsmtp->mail($mailfrom);
    }
    foreach (@rcpt){
      $mhsmtp->recipient($_);
    }
    $mhsmtp->data();
    foreach (@mailheaders){
      $mhsmtp->datasend($_);
    }
    $mhsmtp->datasend($email->as_string);
    $mhsmtp->dataend;
    $mhsmtp->quit();
  }
  
}

$smtp = Net::SMTP->new($mailhost, Port=>$mailport) or die "Unable to contact SMTP Server";
if ($starttls){
  $smtp->starttls;
}
if($mailuser){
  $smtp->auth($mailuser,$mailpass);
}
if($ENV{SMTP_KEEP_FROM}){
  $smtp->mail($email->header("from"));
}
else{
  $smtp->mail($mailfrom);
}
foreach (@rcpt){
  $smtp->recipient($_);
}
$smtp->data();
foreach (@mailheaders){
  $smtp->datasend($_);
}
$smtp->datasend($email->as_string);
$smtp->dataend;
$smtp->quit();

