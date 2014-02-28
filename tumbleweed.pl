#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket;

print "Running tumbleweed 0.0.001-pre-alpha-RC19 IRC spam script. Have fun!\n\n";

# Settings!
my $server  = "irc.quakenet.org";
my $mynick  = "tumbleweed`";
my $login   = "tumbleweed";
my $port    = 6667;
my $verbose = 1;
###

my $channel;
my @nicks;
my @tumbles;
my $sock;
populateTumbles();

print "Connecting to $server...\n";

# Stay connected
while (1) {
  if (serverConnect ()) {
    ircLoop();
    print "Connection to $server lost. Reconnection in 10 seconds.";
  } else {
    print "Connection to $server failed. Retrying in 10 seconds.";
  }
  sleep 10;
}
### 

sub serverConnect {
  # Connect to the IRC server.
  $sock = IO::Socket::INET->new(
    PeerAddr => $server, 
    PeerPort => $port, 
    Proto => 'tcp',
    Timeout => 5
  ) or return 0;
  ###
  
  print "Connected to $server!\n";

  # Log on to the server.
  $sock->print ("NICK $mynick\r\n");
  $sock->print ("USER $login 8 * :tumbleweed, in ur chanul tumblin ma wead\r\n");
  ###
  
  return 1;
}

sub ircLoop {
  while (my $input = <$sock>) {
    
    print $input if $verbose;
    
    # Parsing (such as it is)
    $input =~ s/\r\n//g;
    my @stream = split(' ',$input,4);
    
    # Deal with PINGs
    $sock->print ("PONG $stream[1]\r\n") if $stream[0] eq "PING";
    ###

    ### Successfully connected to server
    if ($stream[1] eq "001") {
      print "Successfully connected to $server!\n";
      sleep 1;
      
      # AUTH
      $sock->print ("AUTH tumblee zCGoZ2HSbZ\r\n");
      $sock->print ("MODE $mynick +x\r\n"); 
      sleep 1;
      ###
    }
    ###
    
    ### Invited!
    if ($stream[1] eq "INVITE") {
      $channel = $stream[3];
      $sock->print ("JOIN $channel\r\n");
      print "Invited to $channel!\n";
    }
    ###
      
    ### Joined a channel
    if ($stream[1] eq "353") {
      
      # Grab everyone's nicks.
      $input =~ s/\r\n//g;             # No newlines please, we're British.
      $input =~ s/^:[^:]+:(.+)$/$1/;   # Discard unwanted gubbins
      $input =~ s/@//g;                # Discard @. WE TUMBLE EVEN THE OPS
      $input =~ s/\+//g;               # Discard +
      @nicks = split (" ",$input);
      print "Nickname list retrieved.\n";
      ###
        
      # Do some tumbling, it's what you were born to do!
      $sock->print ("PRIVMSG $channel :\001ACTION " . tumble() . "\001\r\n");
      sleep 1;
      print "Tumbling...\n";
      ###
        
      # Tumble loop; chance of 1/5 of exiting channel instead of tumbling.
      while (1) {
        unless (int rand 5) {
          $sock->print ("PRIVMSG $channel :\001ACTION tumbles out of $channel\001\r\n");
          sleep 1;
          $sock->print ("PART $channel :Tumble on, fellows!\r\n");
          print "Parting $channel\n";
          sleep 1;
          last;
        }
        $sock->print ("PRIVMSG $channel :\001ACTION " . tumble() . "\001\r\n");
        sleep 1;
      }
      ###
    }
  }
}

sub populateTumbles {
  @tumbles = (
    "tumbles around for a while.",
    "tumbles in small circles.",
    "tumbles happily.",
    "thinks about tumbling for a moment.",
    "tumbles around and around [nick]'s feet.",
    "tumbles [nick].",
    "thinks [nick] should tumble more.",
    "tumbles [nick] into [nick2].",
    "doesn't tumble!",
    "tumbles into [nick], knocking him over!",
    "was going to tumble, but trips over [nick]."
  );
}

sub tumble {
  
  my $c = @nicks[rand @nicks];
  my $d = @nicks[rand @nicks];
    
  my $t = @tumbles[rand @tumbles];

  $t =~ s/\[nick\]/$c/g;
  $t =~ s/\[nick2\]/$d/g;

  return $t;
}
