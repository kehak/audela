
LD_LIBRARY_PATH=/usr/lib/postgresql93/lib64/
export LD_LIBRARY_PATH

/sbin/ldconfig /usr/lib/postgresql93/lib64/

http://www.portailsig.org/content/installation-de-postgresql-et-postgis-sous-linux-opensuse


/usr/bin/pg_ctl -D /var/lib/pgsql/data -l journal_applicatif start

# Démarrons le service PostGreSQL, ouvrez un terminal, passez en root (tapez su) et entrez : 
rcpostgresql start


################################################################################################
# reinit mdp postgres
editer le fichier /var/lib/pgsql/data/pg_hba.conf
remplacer la ligne par : 
local   all             postgres                                trust

relancer le serveur :
service postgresql restart
ou
systemctl start postgresql.service
ou
/etc/init.d/postgresql start

entant qu user :
sudo psql -U postgres

on obtient le prompt "postgres=#"
ALTER USER postgres with password 'postgres';

il faut obtenir ALTER ROLE

pour quitter :
\q 

editer le fichier /var/lib/pgsql/data/pg_hba.conf
remplacer la ligne par : 
local   all             postgres                                md5

relancer le serveur :
service postgresql restart


################################################################################################
demarrer le client : 
psql -U postgres

################################################################################################
creer une base :
CREATE DATABASE bdi;



################################################################################################
apres creation de la base et avant remplissage il y a 43 Mo dans le repertoire /var/lib/pgsql/data
apres remplissage : 400M	

taille pgbjson sur disque : 357 Mo (mais tout est stoqué en chaine de caractere pour l instant)
taille mysql sur disque   : 72 Mo

# NB img = 74345
# Temps de Lecture Mysql + Insertion Postgres en 981.781 sec
# Temps d'Insertion Postgres en 180.892 sec

temps de reponse des select de type 1

   # Tous les objets distinct : 1.9 sec

   # Nb d images de 2008 FU6
      # nb 864
      # requete en    1.2 sec
      # requete en   13.3 sec

   # Nb d images du t1m%
      # nb 74136
      # requete en   1.2 sec


  # toutes les images du t1m% dans un tableau memoire
     # requete en   5.3 sec
     # en mysql : 

temps de reponse des select de type 2
 
    memes temps de reponses, alors que ce n est pas le cas sur des table JSON
    le type 2 est bien plus rapide. 

