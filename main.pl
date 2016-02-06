#!/usr/bin/perl -w

use URI::Escape;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

sub get_token;
sub get_meta;
sub build_meta;

my @ntorrents;

if (defined $ARGV[0]) {
my $query = uri_escape("$ARGV[0]");

my %vars = ('token' => get_token(),
	 'API' => 'http://torrentapi.org/pubapi_v2.php?',
	 'sortS' => '&sort=seeders',
	 'sortL' => '&sort=leechers',
	 'sortD' => '&sort=last',
	 'json' => '&format=json',
	 'jsonE' => '&format=json_extended',
	 'tv' => '&category=tv',
	 'movies' => '&category=movies',
	 'q' => "mode=search&search_string=$query"
	);

my $rtorrents = get_meta();
build_meta();
##########################


foreach my $h (@ntorrents) {
	print "title: $h->{title}\n";
	print "seed: $h->{seeders}\n";
	print "magnet: $h->{magnet}\n";
	print "size:" . int($h->{size}/1024/1024) . "MB" . "\n\n";

}

##########################
sub build_meta {

for my $item( @{$rtorrents->{torrent_results}} ){
push @ntorrents, {
		title => "$item->{title}",
		seeders => "$item->{seeders}",
		magnet => "$item->{download}",
		size => "$item->{size}",
		category => "$item->{category}",
		air => "$item->{episode_info}->{airdate}",
};
};
};


sub get_meta {
my $q = "$vars{API}$vars{q}$vars{jsonE}$vars{sortS}$vars{token}";
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
my $response = $ua->get("$q");
if ( $response->is_success ) {

   my $json = decode_json $response->decoded_content;
	return $json;

}
else {
    die $response->status_line;
}
}


sub get_token {
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
my $response = $ua->get('https://torrentapi.org/pubapi_v2.php?get_token=get_token');
if ( $response->is_success ) {
   my $json = decode_json $response->decoded_content;
	return '&token=' . "$json->{token}";
}
else {
    die $response->status_line;
}
}
}else {

print "need argument\n";
exit 1;
}
