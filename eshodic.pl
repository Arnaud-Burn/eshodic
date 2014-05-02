#!/usr/bin/perl -w

############ ESX Host Hard Drive Check ##########################
# Version : 0.2
# Date : May 2 2014
# Author : Arnaud Comein (arnaud.comein@gmail.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
# NOTE : To use with the PowerShell Script "ESX_Drives.ps1"
#################################################################

use strict;
use warnings;

# Definition des variables
my $filename = shift;
my $numLocHdd = shift;
my $numVolLog = 0;
my $FILE;
my $TEST;
my $err = 0;
my $line;
my $lineTest;
my $lastLine;
my $locDiskErr = 0;
my $extDiskErr = 0;
my $i = 0;

#Definitions Erreurs pour retour Shinken
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

my $errfile = "Fichier specifie introuvable !";

open $TEST, "<", "$filename" or $err = 1;
open $FILE, "<", "$filename" or $err = 1;

if ($err == 0)
{
	# Comptage des volumes logiques en erreur pour élimination du total
	while( $lineTest = <$TEST>)
	{
		chomp $lineTest;
		no warnings;
		
		if ( $lastLine =~ m/Logical/ && $lineTest == 20) 
		{ $numVolLog++; }
		
		$lastLine = $lineTest;
	}
	
	# Calcul du total de disques en erreur
	while( $line = <$FILE> ) 
	{	
		chomp $line;
		no warnings;
		
		if ( $line == 20 )
		{	
			if ( $i < $numLocHdd )
			{ 
				$locDiskErr = ($locDiskErr + 1);
			}
			else
			{
				$extDiskErr = ($extDiskErr + 1);
			}	

			$err = 2;
		}
		$i++;
	}	

	close $FILE;
	close $TEST;	
	
	# Sortie
	if ($err == 2)
	{	
		$extDiskErr = ($extDiskErr - $numVolLog);
		print "Locaux : $locDiskErr - Externes : $extDiskErr - Volumes Impactés : $numVolLog\n";
		exit $ERRORS{"CRITICAL"};
	}
	else
	{
		print "Tout les disques sont OK";
		exit $ERRORS{"OK"};
	}
}

else
{	
	print $errfile;
	exit $ERRORS{"WARNING"};
}
