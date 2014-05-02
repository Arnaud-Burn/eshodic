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
my $FILE2;
my $TEST;
my $TEMP;
my $TEMP2;
my $err = 0;
my $errTmp = 0;
my $line;
my $lineTest;
my $lastLine;
my $i = 0;
my $i2 = 0;
my $tempOut;
my $end = 0;

#Definitions Erreurs pour retour Shinken
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

my $errTemp = "Pas d'acces au dossier /tmp !";
my $errfile = "Fichier specifie introuvable !";

open $TEST, "<", "$filename" or $err = 1;
open $FILE, "<", "$filename" or $err = 1;
open $FILE2, "<", "$filename" or $err = 1;
open $TEMP, ">", "/tmp/eshodic-temp.log" or $errTmp = 1;

if ($err == 0)
{	
	while( $line = <$TEST> )
	{ 
		chomp $line;
		no warnings;
	
		if( $line == 20 || $line == 5 )
		{ $end++; }

		if ( $lastLine =~ m/Logical/ && $line == 20)
		{ $numVolLog++; }

		$lastLine = $line;
 
	}

	print $TEMP "Locaux : ";	

	# Calcul du total de disques en erreur
	while( $line = <$FILE> && $i < $numLocHdd ) 
	{	
		chomp $line;
		no warnings;		
		
		if ( $line == 20 || $line == 5 )
		{	
			$i++;
			if ($line == 20)
			{ 
				print $TEMP "$i.";
				$err = 2;
			}
		}
	}	
	
	print $TEMP "Externes : ";
	
	while( $line = <$FILE2> )
	{
		chomp $line;
		no warnings;		

		if ( $line == 20 || $line == 5)
		{	
			$i++;
			$i2 = ($i - $numLocHdd);
			if ( $line == 20 && $i <= ($end - $numVolLog))
			{
				print $TEMP "$i2.";
				$err = 2;
			}
		}
	}

	close $FILE;	
	close $TEMP;

	# Sortie
	if ($err == 2)
	{	
		open $TEMP2, "<", "/tmp/eshodic-temp.log";
		$tempOut = <$TEMP2>;
		print "$tempOut\n";
		close $TEMP2;
		exit $ERRORS{"CRITICAL"};
	}
	else
	{
		print "Tout les disques sont OK\n";
		exit $ERRORS{"OK"};
	}
}

else
{	
	if ($errTmp == 1)
	{
		print $errTemp;
		exit $ERRORS{"WARNING"};
	}
	else
	{
		print $errfile;
		exit $ERRORS{"WARNING"};
	}
}

