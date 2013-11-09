#!/usr/bin/env perl

# crop_convert.pl SIZE SRCDIR DSTDIR

use strict;
use warnings;
use utf8;
use File::Temp qw/ tempfile /;
use POSIX qw/ floor /;

use Imager;

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
        # my $tmpfile = crop_square("$srcdir/$fname", $suffix);
        # convert($tmpfile, "$dstdir/$fname", $size, $size);
        convert("$srcdir/$fname", "$dstdir/$fname", $suffix, $size);
    }
}

sub convert {
    my ($src, $dst, $suffix, $size) = @_;
    my $img = Imager->new();
    $img->read(file => $src, type => $suffix);
    my $h = $img->getheight();
    my $w = $img->getwidth();
    my $shorter = ($h > $w ? $w : $h);
    my $offset = floor(abs($h - $w) / 2);
    my $cropped;
    if ($h > $w) {
        $cropped = $img->crop(top => $offset, left => 0, width => $shorter, height => $shorter);
    } else {
        $cropped = $img->crop(top => 0, left => $offset, width => $shorter, height => $shorter);
    }
    my $resized = $cropped->scale(xpixels => $size, ypixels => $size);
    $resized->write($dst);
}

main(@ARGV);

