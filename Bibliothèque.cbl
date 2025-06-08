       IDENTIFICATION DIVISION. 
       PROGRAM-ID. Bibliotheque.

       ENVIRONMENT DIVISION. 
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-LIVRES ASSIGN TO 'livres-input.txt'
              ORGANIZATION IS LINE SEQUENTIAL
              FILE STATUS IS F-LIVRES-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD FICHIER-LIVRES.
       01 LIGNE-FICHIER-LIVRES.
           05 F-CODE-ISBN             PIC X(13).
           05 F-TITRE                 PIC X(38).
           05 F-NOM-AUTEUR            PIC X(22).
           05 F-PRENOM-AUTEUR         PIC X(22).
           05 F-GENRE-LIVRE           PIC X(16).
           05 F-ANNEE-PUB             PIC X(04).
           05 F-EDITEUR               PIC X(20).


       WORKING-STORAGE SECTION.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.

       01 S-CODE-ISBN                PIC X(13).
       01 S-TITRE                    PIC X(50).  
       01 S-NOM-AUTEUR               PIC X(22).
       01 S-PRENOM-AUTEUR            PIC X(22).
       01 S-GENRE-LIVRE              PIC X(50).
       01 S-ANNEE-PUB                PIC X(04).
       01 S-EDITEUR                  PIC X(50).

       01 S-ID-GENRE                 PIC 9(10).
       01 S-ID-AUTEUR                PIC 9(10).
       
       01  USERNAME       PIC X(30) VALUE "postgres".
       01  PASSWD         PIC X(30) VALUE "postgres".
       01  DBNAME         PIC X(20) VALUE "gestion_bibliotheque".

       EXEC SQL END DECLARE SECTION END-EXEC.
       
       EXEC SQL INCLUDE SQLCA END-EXEC.


       01  F-LIVRES-STATUS         PIC X(02) VALUE SPACE.
           88 F-LIVRES-STATUS-OK   VALUE '00'.
           88 F-LIVRES-STATUS-EOF  VALUE '10'.


       PROCEDURE DIVISION.
           
           DISPLAY " CONNEXION À LA BASE DE DONNÉES...".
       EXEC SQL 
           CONNECT :USERNAME IDENTIFIED BY :PASSWD USING :DBNAME
       END-EXEC.


           PERFORM 0100-LECTURE-ET-INSERTION-DONNEES-DEB
              THRU 0100-LECTURE-ET-INSERTION-DONNEES-FIN
              

           STOP RUN.

      ******************************************************************
      **************************PARAGRAPHES***************************** 

       0100-LECTURE-ET-INSERTION-DONNEES-DEB.
           OPEN INPUT FICHIER-LIVRES.

             PERFORM UNTIL F-LIVRES-STATUS-EOF
               READ FICHIER-LIVRES 
                  NOT AT END
  
                    MOVE F-CODE-ISBN      TO S-CODE-ISBN
                    MOVE F-TITRE          TO S-TITRE
                    MOVE F-NOM-AUTEUR     TO S-NOM-AUTEUR
                    MOVE F-PRENOM-AUTEUR  TO S-PRENOM-AUTEUR
                    MOVE F-GENRE-LIVRE    TO S-GENRE-LIVRE
                    MOVE F-ANNEE-PUB      TO S-ANNEE-PUB
                    MOVE F-EDITEUR        TO S-EDITEUR
            
               END-READ

      * INSERTION DES DONNÉES (GENRE) DANS LA TABLE GENRE     
           EXEC SQL
              INSERT INTO genre (genre)
              VALUES (:S-GENRE-LIVRE)
           END-EXEC

      * RÉCUPÉRATION DE L'ID GENRE    
           EXEC SQL 
              SELECT id_genre INTO :S-ID-GENRE FROM genre 
              WHERE genre = :S-GENRE-LIVRE
           END-EXEC

      * AFFICHAGE DE L'ID GENRE POUR CONTRÔLE     
      *     DISPLAY "Genre : " S-ID-GENRE

      * INSERTION DES DONNÉES (AUTEUR) DANS LA TABLE AUTEUR 
           EXEC SQL 
              INSERT INTO auteur (nom, prenom)
              VALUES (:S-NOM-AUTEUR, :S-PRENOM-AUTEUR)
           END-EXEC
        
      * RÉCUPÉRATION DE L'ID AUTEUR  
           EXEC SQL 
              SELECT id_auteur INTO :S-ID-AUTEUR FROM auteur 
              WHERE nom = :S-NOM-AUTEUR AND prenom = :S-PRENOM-AUTEUR
           END-EXEC

      * AFFICHAGE DE L'ID AUTEUR POUR CONTRÔLE     
      *     DISPLAY "Auteur : " S-ID-AUTEUR

      * INSERTION DES DONNÉES (LIVRE) DANS LA TABLE PRINCIPALE RELIANT
      * TOUTES LES INFORMATIONS SUR UN LIVRE 
           EXEC SQL
              INSERT INTO livres (isbn, titre, editeur, date_pub,
                   id_auteur, id_genre)
              VALUES (:S-CODE-ISBN, :S-TITRE,:S-EDITEUR,:S-ANNEE-PUB,
                     :S-ID-AUTEUR, :S-ID-GENRE)
           END-EXEC
           
             END-PERFORM.
           CLOSE FICHIER-LIVRES.
      
           IF SQLCODE NOT = 0
           DISPLAY "ERREUR DE CONNEXION SQLCODE : " SQLCODE
           STOP RUN
           END-IF
           
           EXEC SQL COMMIT WORK END-EXEC.
       0100-LECTURE-ET-INSERTION-DONNEES-FIN.





