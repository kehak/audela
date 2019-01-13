<?php

function dirToArray ($dir, $cpath="") 
{

  $result = array();
  $cdir = array_diff(scandir($dir), array('..', '.'));
  foreach ($cdir as $key => $value) {
    $fname = "";
    if (is_dir($dir.DIRECTORY_SEPARATOR.$value)) {
      $fname .= $dir.DIRECTORY_SEPARATOR.$value.DIRECTORY_SEPARATOR;
      $result[$value] = dirToArray($dir.DIRECTORY_SEPARATOR.$value, $fname);
    } else {
      $result[] = $cpath.$value;
      $fname = "";
    }
  }

  return $result;
}

function gz_file_get_contents ($file)
{
    // gzread needs the uncompressed file size as a second argument
    // this might be done by reading the last bytes of the file
    $handle = fopen($file, "rb");
    fseek($handle, -4, SEEK_END);
    $buf = fread($handle, 4);
    $unpacked = unpack("V", $buf);
    $uncompressedSize = end($unpacked);
    fclose($handle);

    // read the gzipped content, specifying the exact length
    $handle = gzopen($file, "rb");
    $contents = gzread($handle, $uncompressedSize);
    gzclose($handle);

    return $contents;
}

function extract_catatable ($xml)
{
  // Chargement du source XML
  $xmldoc = new DOMDocument();
  if (($ok = $xmldoc->loadXML($xml)) === FALSE) {
    return FALSE;
  }
  // Extraction des donnees
  $a = '';
  try {
    $cata_table = array();
    $nodeTABLE = $xmldoc->getElementsByTagName('TABLE');
    foreach ($nodeTABLE as $node) {
      $cata_name = trim($node->getAttribute('name'));
      $cata_nrows = $node->getAttribute('nrows');
      array_push($cata_table, array($cata_name, $cata_nrows));
    }
  } catch (DOMException $e){
    $cata_table = FALSE;
  }
  // Retour du resultat
  return $cata_table;
}

function count_cata_sources ($a, $base)
{
   foreach ($a as $key => $value) {
     if (is_array($value)) {
       count_cata_sources($value,$base);
     } else {
       // Try to get the content of the cata file
       if (($c = gz_file_get_contents($value)) === FALSE) {
         echo "Error: Cannot read the cata XML file (".$value.")\n";
         exit;
       }
       $cata_table = extract_catatable($c);
       $nbcata = count($cata_table);
       $flag = "o";
       if ($nbcata != $base) $flag = "!";
       $l = $flag.", ".$value.", ".$nbcata.", ";
       // Insertion du nombre de sources IMG et ASTROID
       $nbimg = 0;
       $nbastroid = 0;
       foreach ($cata_table as $c) {
         if ($c[0] == 'IMG') $nbimg = $c[1];
         if ($c[0] == 'ASTROID') $nbastroid = $c[1];
       }
       $l .= $nbimg.", ".$nbastroid.", ";
       foreach ($cata_table as $c) {
         $l .= $c[0]." = ".$c[1]."; ";
       }
       echo substr($l,0,-2)."\n";
      }
   }

}

$nb_cata_base = 7;
$cata_dir = "/observ/bddimages/bdi_Patroclus/cata";
$cata_dir_list = dirToArray($cata_dir);
echo "Flag, Filename, nbCata, nbIMG, nbASTROID, ((Cata = NbSources;) i=1,nbcata)\n";
count_cata_sources($cata_dir_list, $nb_cata_base);

?>