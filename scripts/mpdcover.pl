#!/usr/bin/perl 
use strict;
use warnings;
use LWP::UserAgent;
use File::Copy;

### CONFIG ###
my $cover_dir = "$ENV{HOME}/.covers";
my $tmp_dir = "/tmp/";
my $nocover = "/secure/Common/Pictures/icons/conky/mpd/nocover.png";
### END CONFIG ###

$| = 1;

my $current_track = `mpc --format "%artist%+%album%" current`;
chomp $current_track;

my $cover_path = "$cover_dir/$current_track";
my $cover_tmppath = "$tmp_dir/$current_track";

$cover_path =~ s/\s+/_/g;
$cover_tmppath =~ s/\s+/_/g;

sub fetchMediumSizeCover
{
	my ($artist , $album) = (shift , shift) or die "you forget to specify a artist+album parameter";

	my $mediumCoverURL = "";
	my $ua             = LWP::UserAgent->new;
	my $resp           = $ua->get ("http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key=f3a26c7c8b4c4306bc382557d5c04ad5&album=" . $album . "&artist=" . $artist);

	# Ignore error check here

	for (split /\r\n/ , $resp->decoded_content)
	{
		if ($_ =~ /size="medium">(http:.*)<\/image>/)
		{
			$mediumCoverURL = $1;
			last;
		}
	}

	my $current_track_ = $current_track;
	$current_track_ =~ s/\s+/_/g;

	if ($mediumCoverURL ne "")
	{
		# Now fetch it
#		system ("aria2c" , $mediumCoverURL , "-d" , $tmp_dir , "-o" , $current_track_);
#		print "aria2c $mediumCoverURL -d $tmp_dir -o $current_track_";
		`aria2c "$mediumCoverURL" -d "$tmp_dir" -o "$current_track_"`;
		if ( -f $cover_tmppath )
		{
			move ($cover_tmppath , $cover_dir);
		}
	}

}

my $imagePath = $nocover;

if ( ! -f $cover_path )
{
	if ( ! -e $cover_tmppath )
	{
		my @track_info = split /\+/ , $current_track;
		if (scalar @track_info eq 2)
		{
			fetchMediumSizeCover ($track_info[0] , $track_info[1]);
		}
	}
}
else
{
	$imagePath = $cover_path;
}
	
print '${image ' , $imagePath , ' -p 13,13 -s 52x52}';
