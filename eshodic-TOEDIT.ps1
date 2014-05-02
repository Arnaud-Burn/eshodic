#################################################################
# Date : May 2014
# Author : Arnaud Comein (arnaud.comein@gmail.com)
# Stage SNMP 2014
#################################################################

# Req: Windows avec Powershell v3 et Windows Framework Management

# Sort un fichier "$NameSrv-storclean-unix.log" dans le dossier "logstor" d'un utilisateur backman (voir tuto SSH sous windows)
# Le fichier est trié, nettoyé et peut-être lu par les système Linux

# Importation des jeux de commandes
import-module CimCmdlets

############ DONNEES SERVEUR #################
$NameSrv = "ESX_SERVER_NAME"
$ipaddress = "ESX_SERVER_IP"
$HostUsername = "ESX_SERVER_USER"
$password = "ESX_SERVER_PASSWORD" | ConvertTo-SecureString -asPlainText -Force
$path = "PATH_WHARE_TO_STORE_FILE"
##############################################

# Description des paramètres de la session ESXi
$credential = New-Object System.Management.Automation.PSCredential($HostUsername,$password)
$CIOpt = New-CimSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck -Encoding Utf8 -UseSsl
$Session = New-CimSession -Authentication Basic -Credential $credential -ComputerName $Ipaddress -port 443 -SessionOption $CIOpt

# Récupération des données brutes dans un fichier
Get-CimInstance -CimSession $Session -ClassName CIM_StorageExtent > $path\$NameSrv-stor.log

# Procedures de tri et filtrage
Get-Content $path\$NameSrv-stor.log | Select-String -Pattern ElementName,HealthState > $path\$NameSrv-storclean.log
Get-Content $path\$NameSrv-storclean.log | Foreach-Object {$_ -replace "HealthState                   : ", ""} | Set-Content $path\$NameSrv-storclean1.log
Get-Content $path\$NameSrv-storclean1.log | Foreach-Object {$_ -replace "ElementName                   : ", ""} | Set-Content $path\$NameSrv-storclean2.log 
Get-Content $path\$NameSrv-storclean2.log | Where-Object {$_ -notmatch 'HealthState'} | Set-Content $path\$NameSrv-storclean3.log
Get-Content $path\$NameSrv-storclean3.log | Where-Object {$_ -notmatch 'ElementName'} | Set-Content $path\$NameSrv-storclean4.log
Get-Content $path\$NameSrv-storclean4.log | Where-Object {$_ -notmatch 'Memory'} | Set-Content $path\$NameSrv-storclean5.log
Get-Content $path\$NameSrv-storclean5.log | Where-Object {$_ -notmatch 'Local'} | Set-Content $path\$NameSrv-storclean6.log 
Get-Content $path\$NameSrv-storclean6.log | ? {$_.trim() -ne "" } | set-content $path\$NameSrv-storclean-final.log

# Conversion au format Utf8
Get-Content $path\$NameSrv-storclean-final.log | Set-Content -Encoding UTF8 $path\$NameSrv-storclean-unix.log

# Suppression des fichiers tampon
rm $path\$NameSrv-stor.log
rm $path\$NameSrv-storclean.log
rm $path\$NameSrv-storclean1.log
rm $path\$NameSrv-storclean2.log
rm $path\$NameSrv-storclean3.log
rm $path\$NameSrv-storclean4.log
rm $path\$NameSrv-storclean5.log
rm $path\$NameSrv-storclean6.log
rm $path\$NameSrv-storclean-final.log