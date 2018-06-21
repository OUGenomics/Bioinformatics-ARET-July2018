#!/usr/bin/env perl
#use strict;
use warnings;
#--INCLUDE PACKAGES-----------------------------------------------------------
use IO::String;
use File::Basename;
use File::Copy;
use Cwd;

#-----------------------------------------------------------------------------
#-variables-------------------------------------------------------------------
#-----------------------------------------------------------------------------

my $filenameA = $ARGV[0];
my $filenameB = $ARGV[1];
my $minlen    = $ARGV[2];
my $out1      = $ARGV[3];
my $out2      = $ARGV[4];
my $out3      = $ARGV[5];
my $out4      = $ARGV[6];

my @file1;
my @file2;

#open $OUTFILEA, "> $filenameA".".paired.fastq";
#open $OUTFILEB, "> $filenameB".".paired.fastq";


if (not defined $ARGV[2] ) {
   $minlen =50;
} 
if (not defined $ARGV[3] ) {
   open $OUTFILEA, "> $filenameA".".paired.fastq";
} else {
   open $OUTFILEA, "> $out1";
}

if (not defined $ARGV[4] ) {
   open $OUTFILEB, "> $filenameB".".paired.fastq";
} else {
   open $OUTFILEB, "> $out2";
}

if (not defined $ARGV[5] ) {
   open $OUTFILEC, "> $filenameA".".unpaired.fastq";
} else {
   open $OUTFILEC, "> $out3";
}

if (not defined $ARGV[6] ) {
   open $OUTFILED, "> $filenameB".".unpaired.fastq";
} else {
   open $OUTFILED, "> $out4";
}

my $match_count = 0;
my $mismatch_count =0;
my $short_count =0;

my $eofA = 0;
my $eofB = 0;

#-----------------------------------------------------------------------------
#-open infiles and load first element-----------------------------------------
#-----------------------------------------------------------------------------


open $FILEA, "< $filenameA";
push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);

open $FILEB, "< $filenameB";
push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);

my $l_buffer_size =1;
my $r_buffer_size =1;

#-----------------------------------------------------------------------------
#-load up---------------------------------------------------------------------
#-----------------------------------------------------------------------------

my $fillerup = 100;
my $load_depth = $fillerup;
my $annoyance_level = 0;
my $annoyance_step = 500;
my $max_annoyance = 5000;
my $max_annoyance_observed =0;

do {

$_ = <$FILEA>;push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);
$_ = <$FILEA>;push (@file1, $_);

$_ = <$FILEB>;push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);
$_ = <$FILEB>;push (@file2, $_);

$load_depth = $load_depth - 1;
$l_buffer_size = $l_buffer_size + 1;
$r_buffer_size = $r_buffer_size + 1;

} until ($load_depth == 0);

#-----------------------------------------------------------------------------
#-main loop-------------------------------------------------------------------
#-----------------------------------------------------------------------------

my $main_loop_true = 1;
my $reached_eof=0;


while ($main_loop_true == 1)
{

my $l_position = 1; my $r_position =1;
my $match =0;

#-----------------------------------------------------------------------------
#check forward
#-----------------------------------------------------------------------------

for(my $i = 1; $i < $r_buffer_size ; $i++) 
   {
   my @lsplit = split (" ", $file1[1]);
   my @rsplit = split (" ", $file2[($i*4)-3]);
   
   if ($lsplit[0] eq $rsplit[0]) 
      {
      $r_position = $i;
      $match = 1;
      $i = $r_buffer_size;
      }
   }

#-----------------------------------------------------------------------------
# check reverse
#-----------------------------------------------------------------------------

if ($match == 0)
{
for(my $i = 1; $i < $l_buffer_size ; $i++) 
   {
   my @lsplit = split (" ", $file1[($i*4)-3]);
   my @rsplit = split (" ", $file2[1]);
   
   if ($lsplit[0] eq $rsplit[0]) 
      {
      $l_position = $i;
      $match = 1;
      $i = $r_buffer_size;
      }
   }
}

#-----------------------------------------------------------------------------
#shift up and align
#-----------------------------------------------------------------------------

if ($match == 1)
{
while ($l_position > 1)
      {

       $_ = $file1[1];
       print $OUTFILEC $_;  
       $_ = $file1[2];
       print $OUTFILEC $_;  
       $_ = $file1[3];
       print $OUTFILEC $_;  
       $_ = $file1[4];
       print $OUTFILEC $_;  


      shift @file1;shift @file1;shift @file1;shift @file1;
      $mismatch_count = $mismatch_count +1;
      $l_position = $l_position-1;
      $l_buffer_size = $l_buffer_size -1;
      }
while ($r_position > 1)
      {
       $_ = $file2[1];
       print $OUTFILED $_;  
       $_ = $file2[2];
       print $OUTFILED $_;  
       $_ = $file2[3];
       print $OUTFILED $_;  
       $_ = $file2[4];
       print $OUTFILED $_;  


      shift @file2;shift @file2;shift @file2;shift @file2;
      $mismatch_count = $mismatch_count +1;
      $r_position = $r_position-1;
      $r_buffer_size = $r_buffer_size -1;
      }
if ($annoyance_level>0) {$annoyance_level=$annoyance_level-1;}
}

if ($match == 0)
#discard both
{

       $_ = $file1[1];
       print $OUTFILEC $_;  
       $_ = $file1[2];
       print $OUTFILEC $_;  
       $_ = $file1[3];
       print $OUTFILEC $_;  
       $_ = $file1[4];
       print $OUTFILEC $_;  

       $_ = $file2[1];
       print $OUTFILED $_;  
       $_ = $file2[2];
       print $OUTFILED $_;  
       $_ = $file2[3];
       print $OUTFILED $_;  
       $_ = $file2[4];
       print $OUTFILED $_;  

      shift @file1;shift @file1;shift @file1;shift @file1;
      shift @file2;shift @file2;shift @file2;shift @file2;
      $mismatch_count = $mismatch_count +2;
      $l_buffer_size = $l_buffer_size -1;
      $r_buffer_size = $r_buffer_size -1;
      $annoyance_level = $annoyance_level + $annoyance_step; 
      if ($annoyance_level >= $max_annoyance) { $annoyance_level = $max_annoyance;}
}

#-----------------------------------------------------------------------------
# now save the top, aligned position
#-----------------------------------------------------------------------------

if ($match == 1)
   {
   if ((length ($file1[2]) >= $minlen) && (length ($file2[2]) >= $minlen))
      {
       $_ = $file1[1];
       print $OUTFILEA $_;  
       $_ = $file1[2];
       print $OUTFILEA $_;  
       $_ = $file1[3];
       print $OUTFILEA $_;  
       $_ = $file1[4];
       print $OUTFILEA $_;  

       $_ = $file2[1];
       print $OUTFILEB $_;  
       $_ = $file2[2];
       print $OUTFILEB $_;  
       $_ = $file2[3];
       print $OUTFILEB $_;  
       $_ = $file2[4];
       print $OUTFILEB $_;  
      } else {$short_count += 1;}

      shift @file1;shift @file1;shift @file1;shift @file1;
      shift @file2;shift @file2;shift @file2;shift @file2;

      $match_count = $match_count +1;
      $l_buffer_size = $l_buffer_size -1;
      $r_buffer_size = $r_buffer_size -1;

   }
#-----------------------------------------------------------------------------
#fill buffer back up
#-----------------------------------------------------------------------------

for(my $k = 1; $k < $fillerup ; $k++) 
   {
   if ($eofA ==0 && $l_buffer_size < ($fillerup+$annoyance_level))
     {
     if (eof ($FILEA) == 0)
      {
        $_ = <$FILEA>;push (@file1, $_);
        $_ = <$FILEA>;push (@file1, $_);
        $_ = <$FILEA>;push (@file1, $_);
        $_ = <$FILEA>;push (@file1, $_);
        $l_buffer_size = $l_buffer_size + 1;
      }  else
      {
        $eofA =1;
      }
     }
   }




for(my $k = 1; $k < $fillerup ; $k++) 
   {
   if ($eofB ==0 && $r_buffer_size < ($fillerup+$annoyance_level))
     {
     if (eof ($FILEB) == 0)
      {
        $_ = <$FILEB>;push (@file2, $_);
        $_ = <$FILEB>;push (@file2, $_);
        $_ = <$FILEB>;push (@file2, $_);
        $_ = <$FILEB>;push (@file2, $_);
        $r_buffer_size = $r_buffer_size + 1;
      }  else
      {
        $eofB =1;
      }
     }
   }

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------

if (eof ($FILEA))
    {
    printf(".");
    $reached_eof = $reached_eof + 1;
    if ($reached_eof >= $fillerup)
        {
        printf "\nNumber of reads matched: ". $match_count;
        printf "\nNumber of reads mismatched: ". $mismatch_count;
        printf "\nNumber of reads too short: ".$short_count."\n";
        $main_loop_true = -1;
        }
    }
if (eof ($FILEB))
    {
    $reached_eof = $reached_eof + 1;
    if ($reached_eof >= $fillerup)
        {
        printf "\nNumber of reads matched: ". $match_count;
        printf "\nNumber of reads mismatched: ". $mismatch_count;
        printf "\nNumber of reads too short: ".$short_count."\n";
        $main_loop_true = -1;
        }
    }

}


#-----------------------------------------------------------------------------
#--cleanup--------------------------------------------------------------------
#-----------------------------------------------------------------------------

close $FILEA;
close $FILEB;
close $OUTFILEA;
close $OUTFILEB;
close $OUTFILEC;
close $OUTFILED;

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
