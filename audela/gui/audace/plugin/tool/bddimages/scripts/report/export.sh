#!/bin/sh
#
# Script de concatenation et d'export des fichiers XML produit par bddimages astrometrie
# 2015, J. Berthier & F. Vachier
#

usage() {
   printf "%s\n" "Usage: $0 -e <export> -f <infile> -o <outfile> [-t <type>]"
   printf "%s\n" " with:  "
   printf "%s\n" "   -e <export>   Export format: XML|FAMOUS|GENOIDE, default XML"
   printf "%s\n" "   -f <infile>   File which contains the list of XML files to concat and export"
   printf "%s\n" "   -o <outfile>  Concatened/exported filename"
   printf "%s\n" "   -t <type>     Data type: astrom (default) | photom"
}

exit_on_error() {
   printf "%s\n" "$1"
   exit 1
}

clean_tmp() {
   file2del=$1
   if [ -f ${file2del} ]
   then
      printf "\n  Cleaning temp files..."
      while read file 
      do
         rm -f $file
      done < ${file2del}
      rm -f ${file2del}
   fi
}

export_astrom2genoide() {
   file_=$1
   tmpfile_=$2
   ${STILTS} tpipe ifmt=votable in=${file_} \
     cmd='addcol tjj -units "d" -ucd "time.epoch" -desc "Observation epoch expressed in Julian day" JD-Date' \
     cmd='addcol tiso -units "isodate" -ucd "time.epoch" -desc "Observation epoch expressed in ISO format" ISO-Date' \
     cmd='addcol ref_name -ucd "meta.id" -desc "Name of the target" Object' \
     cmd='addcol ref_system -ucd "meta.id" -desc "Name of the planetary system" Object' \
     cmd='addcol xobs -units "deg" -ucd "pos.eq.ra" -desc "Computed RA" RA' \
     cmd='addcol yobs -units "deg" -ucd "pos.eq.dec" -desc "Computed DEC" DEC' \
     cmd='addcol xobs_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in RA" RA_err' \
     cmd='addcol yobs_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in DEC" DEC_err' \
     cmd='addcol xcalc -units "deg" -ucd "pos.eq.ra" -desc "Observed RA" 0.0' \
     cmd='addcol ycalc -units "deg" -ucd "pos.eq.dec" -desc "Observed DEC" 0.0' \
     cmd='addcol xomc -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Oberved minus computed RA position" RA_omc' \
     cmd='addcol yomc -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Oberved minus computed DEC position" DEC_omc' \
     cmd='addcol timescale -ucd "time.scale" -desc "Reference time scale (e.g. UTC or TT)" "toString(\"UTC\")"' \
     cmd='addcol centerframe -desc "Reference frame center (e.g. 1:helio, 2:geo, 3:topo, 4:spacecraft)" 3' \
     cmd='addcol typeframe -desc "Type of reference frame (e.g. 1:astromJ2000, 2:apparent, 3:meandate, 4:meanJ2000)" 1' \
     cmd='addcol coordtype -desc "Type of coordinates (e.g. 1:spherical, 2:rectangular)" 1' \
     cmd='addcol refframe -desc "Reference plane (e.g. 1:equator, 2:ecliptic)" 1' \
     cmd='addcol obsuai -desc "IAU code of the observatory" param$IAUCode' \
     cmd='addcol bibitem -desc "Bibliographic reference" "toString(\"Audela/bddimages, 2015\")"'\
     cmd='delcols "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17"' \
    ofmt=votable-tabledata out=${tmpfile_} 
}

export_photom2genoide() {
   file_=$1
   tmpfile_=$2
   ${STILTS} tpipe ifmt=votable in=${file_} \
     cmd='addcol tjj -units "d" -ucd "time.epoch" -desc "Observation epoch expressed in Julian day" JD-Date' \
     cmd='addcol tiso -units "isodate" -ucd "time.epoch" -desc "Observation epoch expressed in ISO format" ISO-Date' \
     cmd='addcol mag -units "mag" -ucd "phot.mag" -desc "Measured magnitude" Magnitude' \
     cmd='addcol mag_err -units "mag" -ucd "stat.error;phot.mag" -desc "Uncertainty on measured magnitude" "Err Mag"' \
     cmd='addcol ra -units "deg" -ucd "pos.eq.ra;meta.main" -desc "Astrometric J2000 right ascension" RA' \
     cmd='addcol dec -units "deg" -ucd "pos.eq.dec;meta.main" -desc "Astrometric J2000 declination" DEC' \
     cmd='addcol fwhm -units "px" -ucd "obs.param;phys.angSize" -desc "FWHM" fwhm' \
     cmd='addcol flux -units "ADU" -ucd "phot.flux" -desc "Integrated flux" Flux' \
     cmd='addcol flux_err -units "ADU" -ucd "stat.error;phot.flux" -desc "Uncertainty on integrated flux" "Err Flux"' \
     cmd='addcol exposure -units "s" -ucd "time.duration;obs.exposure" -desc "Integration time" Exposure' \
     cmd='addcol filter -ucd "meta.id;instr.filter" -desc "Image filter" Filter' \
     cmd='addcol radius -units "px" -ucd "phys.size.radius;instr.pixel" -desc "Radius inside which the PSD where fitted" Radius' \
     cmd='addcol globale -ucd "" -desc "The set of radius where Globale method was used" Globale' \
     cmd='addcol psf_model -ucd "stat.fit;instr.det.psf" -desc "PSF model" "PSF Model"' \
     cmd='delcols "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14"' \
    ofmt=votable-tabledata out=${tmpfile_} 
}

export_astrom2famous() {
   file_=$1
   tmpfile_=$2
   ${STILTS} tpipe ifmt=votable in=${file_} \
     cmd='addcol tjj -units "d" -ucd "time.epoch" -desc "Observation epoch expressed in Julian day" JD-Date' \
     cmd='addcol ra -units "deg" -ucd "pos.eq.ra" -desc "Computed RA" RA' \
     cmd='addcol dec -units "deg" -ucd "pos.eq.dec" -desc "Computed DEC" DEC' \
     cmd='addcol ra_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in RA" RA_err' \
     cmd='addcol dec_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in DEC" DEC_err' \
     cmd='addcol omc_ra -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Oberved minus computed RA position" RA_omc' \
     cmd='addcol omc_dec -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Oberved minus computed DEC position" DEC_omc' \
     cmd='addcol mag -units "" -ucd "phot.mag" -desc "Magnitude" Magnitude' \
     cmd='addcol mag_err -units "" -ucd "stat.error;mag.phot" -desc "Error in magnitude" Magnitude_err' \
     cmd='addcol tiso -units "isodate" -ucd "time.epoch" -desc "Observation epoch expressed in ISO format" ISO-Date' \
     cmd='delcols "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17"' \
    ofmt=votable-tabledata out=${tmpfile_} 
}

export_photom2famous() {
   file_=$1
   tmpfile_=$2
   ${STILTS} tpipe ifmt=votable in=${file_} \
     cmd='addcol tjj -units "d" -ucd "time.epoch" -desc "Observation epoch expressed in Julian day" JD-Date' \
     cmd='addcol ra -units "deg" -ucd "pos.eq.ra;meta.main" -desc "Astrometric J2000 right ascension" RA' \
     cmd='addcol dec -units "deg" -ucd "pos.eq.dec;meta.main" -desc "Astrometric J2000 declination" DEC' \
     cmd='addcol ra_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in RA" 0.0' \
     cmd='addcol dec_err -units "arcsec" -ucd "stat.error.sys;pos.eq.dec" -desc "Error in DEC" 0.0' \
     cmd='addcol flux -units "ADU" -ucd "phot.flux" -desc "Integrated flux" Flux' \
     cmd='addcol flux_err -units "ADU" -ucd "stat.error;phot.flux" -desc "Uncertainty on integrated flux" "Err Flux"' \
     cmd='addcol mag -units "mag" -ucd "phot.mag" -desc "Measured magnitude" Magnitude' \
     cmd='addcol mag_err -units "mag" -ucd "stat.error;phot.mag" -desc "Uncertainty on measured magnitude" "Err Mag"' \
     cmd='addcol tiso -units "isodate" -ucd "time.epoch" -desc "Observation epoch expressed in ISO format" ISO-Date' \
     cmd='delcols "$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14"' \
    ofmt=votable-tabledata out=${tmpfile_} 
}

# Commandes
STILTS=$(command -v stilts)
[ ! -x "${STILTS}" ] && exit_on_error "Error: stilts not found"

# Init
PWD=$(pwd)
infile=""
outfile=""
export=XML
infilegenoide="?"
infilefamous="?"
ftype="astrom"

# Arguments
nbarg=0
while getopts :he:f:o:t: option
do
   case "$option" in
    h)
      usage
      exit 1
      ;;
    e)
      export=$OPTARG
      ;;
    f)
      infile=$OPTARG
      ;;
    o)
      outfile=$OPTARG
      ;;
    t)
      ftype=$OPTARG
      ;;
    *)
      printf "$0: Unknown argument, skipped"
      ;;
   esac
done

# Test l'existence du fichier d'entree
[ ! -f ${infile} ] && exit_on_error "Error: unknown input file: ${infile}"

# Verifie le type de data
[ ! "x${ftype}" == "xastrom" -a ! "x${ftype}" == "xphotom" ] && exit_on_error "Error: unknown data type: ${ftype} (should be 'astrom' or 'photom')"

# Repertoire de travail = repertoire ou se trouve le fichier d'entre
workdir=${infile%/*}
[ ! -d ${workdir} ] && workdir=./

# Nom du fichier de travail = base du nom du fichier de sortie si non defini
infilename=${infile##*/}

# Si aucun fichier de sortie n'est fourni
if [ "x${outfile}" == "x" ]
then
   case ${export^^} in
      GENOIDE)
         outfile=${workdir}/genoide.obsradec.${infilename%.*}.xml
         ;;
      FAMOUS)
         outfile=${workdir}/famous.obsradec.${infilename%.*}.dat
         ;;
      *)
         outfile=${infile%.*}.xml
         ;;
   esac
fi

# Msg
printf "Export cata to: ${export^^}"

# Si export=GENOIDE ...
if [ ${export^^} == "GENOIDE" ]
then
   infilegenoide=${infile}.tmp
   while read file 
   do
      tmpfile=${file%.*}.tmp.xml
      printf "\n  Exporting cata %s..." "${file##*/}" 
      case $ftype in
        astrom) export_astrom2genoide ${file} ${tmpfile}
                ;;
        photom) export_photom2genoide ${file} ${tmpfile}
                ;;
      esac
      printf "%s\n" "${tmpfile}" >> ${infilegenoide}
   done < ${infile}
   infile=${infilegenoide}
fi

# Si export=FAMOUS ...
if [ ${export^^} == "FAMOUS" ]
then
   infilefamous=${infile}.tmp
   while read file 
   do
      tmpfile=${file%.*}.tmp.xml
      printf "\n  Exporting cata %s..." "${file##*/}" 
      case $ftype in
        astrom) export_astrom2famous ${file} ${tmpfile}
                ;;
        photom) export_photom2famous ${file} ${tmpfile}
                ;;
      esac
      printf "%s\n" "${tmpfile}" >> ${infilefamous}
   done < ${infile}
   infile=${infilefamous}
fi

# Concatenation des fichiers
printf "\n  Concatenating VOTables..."
case ${export^^} in
   GENOIDE)
      ${STILTS} tcat ifmt=votable ofmt=votable-tabledata multi=true out=${outfile} in=@${infile}
      clean_tmp ${infilegenoide}
      ;;
   FAMOUS)
      ${STILTS} tcat ifmt=votable ofmt=ascii multi=false out=${outfile} in=@${infile}
      clean_tmp ${infilefamous}
      ;;
   *)
      ${STILTS} tcat ifmt=votable ofmt=votable-tabledata multi=true out=${outfile} in=@${infile}
      ;;
esac

# Output file
printf "\nOutput file: %s\n" "${outfile}"
