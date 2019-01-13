   # connect
   package require tdbc::postgres 1.0 
   set db [tdbc::postgres::connection create dbbdi -user postgres -db bdi]

   # create
   set stmt [dbbdi prepare {
       CREATE TABLE books ( id integer, data json )
   }]
   $stmt foreach row {::console::affiche_resultat "[dict get $row]\n" }
   $stmt close

   # insert
   set stmt [dbbdi prepare {
       INSERT INTO books VALUES (:id,:json)
   }]
   set id 1
   set json {{ "name": "Book the First", "author": { "first_name": "Bob", "last_name": "White" } }}
   $stmt execute

   set id 2
   set json {{ "name": "Book the Second", "author": { "first_name": "Charles", "last_name": "Xavier" } }}
   $stmt execute

   set id 3
   set json {{ "name": "Book the Third", "author": { "first_name": "Jim", "last_name": "Brown" } }}
   $stmt execute

   $stmt close

   # select
   set stmt [dbbdi prepare {
       SELECT * FROM books
   }]
   $stmt foreach row {::console::affiche_resultat "[dict get $row]\n"}
   $stmt close

   # select
   set stmt [dbbdi prepare {
       SELECT id, data->>'name' AS name FROM books
   }]
   $stmt foreach row {::console::affiche_resultat "[dict get $row]\n"}
   $stmt close

   # select
   set stmt [dbbdi prepare {
       SELECT data->'author'->>'first_name' as author_first_name FROM books
   }]
   $stmt foreach row {::console::affiche_resultat "[dict get $row]\n"}
   $stmt close

   # select
   set stmt [dbbdi prepare {
       SELECT * FROM books WHERE data->'author'->>'first_name' = 'Charles' AND data->'author'->>'last_name' = 'Xavier' 
   }]
   $stmt foreach row {::console::affiche_resultat "[dict get $row]\n"}
   $stmt close

   # effacement
   set stmt [dbbdi prepare {
      DROP TABLE books
   } ]
   $stmt execute
   $stmt close


