#!/usr/bin/env perl

# crop_convert.pl SIZE SRCDIR DSTDIR

use strict;
use warnings;
use utf8;
use File::Temp qw/ tempfile /;
use POSIX qw/ floor /;

my $SIZE_MAP = {
    ICON_S => 32,
    ICON_M => 64,
    ICON_L => 128,
    IMAGE_S => 128,
    IMAGE_M => 256,
};

sub main {
    my ($size_str, $srcdir, $dstdir) = @_;
    my $size = $SIZE_MAP->{$size_str};
    opendir(my $dh, $srcdir);
    foreach my $fname (grep { /^[^\.]/ } readdir($dh)) {
        my ($suffix) = ($fname =~ /\.(jpg|png)$/);
        my $tmpfile = crop_square("$srcdir/$fname", $suffix);
        convert($tmpfile, "$dstdir/$fname", $size, $size);
    }
}

sub crop_square {
    my ($orig, $ext) = @_;
    my $identity = `identify $orig`; 
    my (undef, undef, $size) = split / +/, $identity;
    my ($w, $h) = split /x/, $size;
    my ($crop_x, $crop_y, $pixels);
    if ( $w > $h ) {
        $pixels = $h;
        $crop_x = floor(($w - $pixels) / 2);
        $crop_y = 0;
    }
    elsif ( $w < $h ) {
        $pixels = $w;
        $crop_x = 0;
        $crop_y = floor(($h - $pixels) / 2);
    }
    else {
        $pixels = $w;
        $crop_x = 0;
        $crop_y = 0;
    }
    my ($fh, $filename) = tempfile();
    system("convert", "-crop", "${pixels}x${pixels}+${crop_x}+${crop_y}", $orig, "$filename.$ext");
    unlink $filename;
    return "$filename.$ext";
}

sub convert {
    my ($src, $dst, $w, $h) = @_;
    my ($fh, $filename) = tempfile();
    system("convert", "-geometry", "${w}x${h}", $src, $dst);
}

main(@ARGV);

