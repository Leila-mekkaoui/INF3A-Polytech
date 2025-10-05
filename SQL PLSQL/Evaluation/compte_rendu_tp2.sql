-- MEKKAOUI LEILA INF3A P2301688
-- COMPTE RENDU TP2 BD SQL/PLSQL

-- Q1.Création des tables
CREATE TABLE Utilisateur (
     id_u INT PRIMARY KEY NOT NULL,
     nom VARCHAR2(50),
     email VARCHAR2(50) UNIQUE,
     nb_action INT
);

CREATE TABLE Salle (
    id_s INT PRIMARY KEY NOT NULL,
    id_moderateur INT REFERENCES Utilisateur(id_U),
    titre VARCHAR2(50) UNIQUE
);

CREATE TABLE Message (
     id_m INT PRIMARY KEY NOT NULL,
     id_auteur INT REFERENCES Utilisateur(id_u),
     id_salle INT REFERENCES Salle(id_s),
     id_parent INT REFERENCES Message(id_m),
     date_envoi TIMESTAMP NOT NULL,
     titre_m VARCHAR2(20),
     corps VARCHAR2(200),
     etat CHAR(1) CHECK (etat IN ('O','C'))
)

-- Q2.Création des séquences

CREATE SEQUENCE sequence_utilisateur
    start with 1
    increment by 1;

CREATE SEQUENCE sequence_message
    start with 1
    increment by 1;

CREATE SEQUENCE sequence_salle
    start with 1
    increment by 1;

-- Q3. Ajout utilisateur

CREATE OR REPLACE PROCEDURE nouvel_user(pnom in VARCHAR2, pmail in VARCHAR2) AS
BEGIN
    INSERT INTO UTILISATEUR (id_u, nom, email, nb_action)
    VALUES (sequence_utilisateur.NEXTVAL, pnom, pmail, 0);
    COMMIT;
end;
/
BEGIN
    nouvel_user('Jean', 'jean@gmail.com');
    nouvel_user('Leila', 'leilamkoui@gmail.com');
    nouvel_user('Lea', 'lea@gmail.com');
    nouvel_user('Tom', 'tom@gmail.com');
    nouvel_user('Leonardo', 'leoleo@gmail.com');
    nouvel_user('Guide', 'gudie@gmail.com');
    nouvel_user('lanabuzz', 'lananas@gmail.com');
    nouvel_user('stroobang', 'troll@gmail.com');
end;
/

--Q4. Ajouts des salles
CREATE OR REPLACE PROCEDURE nouvel_salle(ptheme in VARCHAR2) AS
    BEGIN
    INSERT INTO SALLE(id_s, id_moderateur, titre)
    VALUES (sequence_salle.NEXTVAL,NULL , ptheme);
    COMMIT;
end;
/
BEGIN
    nouvel_salle('steam');
    nouvel_salle('blabla');
    nouvel_salle('zenbook');
    nouvel_salle('vicegame');
    nouvel_salle('little_nightmares');
    nouvel_salle('eldenring');
    nouvel_salle('shadowoftheedtree');
    nouvel_salle('hollowknight');
end;
/

-- Met à jour le modérateur selon le nombre de messages envoyés dans le salon, pour Q5

CREATE OR REPLACE PROCEDURE mettre_a_jour_modo(
    pid_salle IN INTEGER
)
AS
BEGIN
    UPDATE SALLE
    SET id_moderateur =
            (SELECT id_auteur FROM (
                SELECT id_auteur, COUNT(*) AS Nb_msg FROM MESSAGE M
                JOIN SALLE S ON S.id_s = M.ID_SALLE
                WHERE id_s = pid_salle
                GROUP BY id_auteur
                ORDER BY Nb_msg DESC
                                   )
             WHERE ROWNUM=1
            )
    WHERE id_s = pid_salle;
end;
/

-- Q5 insert un nouveau message
CREATE OR REPLACE PROCEDURE nouveau_message(
    pid_salle IN INTEGER,
    auteur IN INTEGER,
    ptitre IN VARCHAR2,
    pcorps IN VARCHAR2)
AS
BEGIN
    UPDATE UTILISATEUR
    SET nb_action = nb_action+1
    WHERE id_u = auteur;

    INSERT INTO MESSAGE(id_m, id_auteur, id_salle, id_parent, date_envoi, titre_m, corps, etat)
    VALUES(SEQUENCE_MESSAGE.NEXTVAL, auteur,
       pid_salle, NULL, CURRENT_TIMESTAMP,
       ptitre, pcorps, 'O');


    mettre_a_jour_modo(pid_salle);
    COMMIT;
end;
/

-- P2. insert une nouvelle réponse
CREATE OR REPLACE PROCEDURE nouvelle_reponse(
    pere IN INTEGER,
    auteur IN INTEGER,
    ptitre IN VARCHAR2,
    pcorps IN VARCHAR2)
AS
    salle_id MESSAGE.id_salle%TYPE;
BEGIN

    SELECT id_salle INTO salle_id
    FROM MESSAGE M
    WHERE M.id_m = pere
    AND ROWNUM = 1;

    INSERT INTO MESSAGE(id_m, id_auteur, id_salle, id_parent, date_envoi, titre_m, corps, etat)
    VALUES(SEQUENCE_MESSAGE.NEXTVAL, auteur, salle_id, pere,
           CURRENT_TIMESTAMP, ptitre, pcorps, 'O');

    mettre_a_jour_modo(salle_id);

    COMMIT;
end;
/

-- Q6 Trigger action

CREATE OR REPLACE TRIGGER maj_nb_actions
    AFTER INSERT ON MESSAGE
    FOR EACH ROW
BEGIN
    UPDATE UTILISATEUR
    SET nb_action = nb_action + 1
    WHERE id_u = :NEW.id_auteur;
END;
/

-- Q7 clos un sujet

CREATE OR REPLACE PROCEDURE clore_sujet(
    pid_message IN INTEGER,
    pid_utilisateur IN INTEGER
)
AS
    v_modo SALLE.id_moderateur%TYPE;
BEGIN

    SELECT S.id_moderateur
    INTO v_modo
    FROM SALLE S
    JOIN MESSAGE M ON M.id_salle = S.id_s
    WHERE M.id_m = pid_message;

    IF pid_utilisateur != v_modo THEN
            RAISE_APPLICATION_ERROR(-20001, 'Vous navez pas les droits pour clore ce sujet.');
    END IF;

    UPDATE MESSAGE
    SET etat = 'C'
    WHERE id_m = pid_message;

    COMMIT;
END;
/

-- Q8. Réponse à sujet clos
CREATE OR REPLACE TRIGGER reponse_sujet_clot
    BEFORE INSERT ON MESSAGE
    FOR EACH ROW
DECLARE
    v_etat MESSAGE.etat%TYPE;
BEGIN
    -- Vérifier si on insère une réponse (id_parent non NULL)
    IF :NEW.id_parent IS NOT NULL THEN
    SELECT etat
    INTO v_etat
    FROM MESSAGE
    WHERE id_m = :NEW.id_parent;

        IF v_etat = 'C' THEN
            RAISE_APPLICATION_ERROR(-20010, 'Impossible de répondre : ce sujet est clôt.');
        END IF;
    END IF;
END;
/



--9 : pas besoin de trigger la contrainte d'ingrité gère
-- DELETE FROM MESSAGE WHERE id_m = 6;
-- [23000][2292]
-- 	ORA-02292: violation de contrainte (INF3A22.SYS_C00486141) d'intégrité - enregistrement fils existant
--
-- 	https://docs.oracle.com/error-help/db/ora-02292/
-- Position: 0

--10 Clôture fil de discussion

CREATE OR REPLACE PROCEDURE clore_fil(
    pid_message     IN INTEGER,
    pid_utilisateur IN INTEGER
) AS
    v_racine MESSAGE.id_m%TYPE;
BEGIN
    -- retrouver la racine
    v_racine := pid_message;
    LOOP
        DECLARE v_parent MESSAGE.id_parent%TYPE;
        BEGIN
            SELECT id_parent INTO v_parent
            FROM MESSAGE
            WHERE id_m = v_racine;

            EXIT WHEN v_parent IS NULL;
        v_racine := v_parent;
        END;
    END LOOP;

    -- vérifier les droits sur le fil racine
    clore_sujet(v_racine, pid_utilisateur);

    -- clore tous les messages du fil (tous les descendants)
    UPDATE MESSAGE
    SET etat = 'C'
    WHERE id_m IN (
        SELECT id_m
        FROM MESSAGE
                 START WITH id_m = v_racine
    CONNECT BY PRIOR id_m = id_parent);
END;
/


BEGIN
    nouveau_message(3, 24, 'nv pc2', 'mon patrimoine est de 1000');
    nouveau_message(1, 23, 'vice game2', 'laissez le etre mmodo pitiz');
    nouveau_message(1, 23, 'vice game', 'le jeu arrive sur steam passez 100 balles');
    nouveau_message(21, 10, 'sorti coctobre', 'le jeu arrive sur steam le 10 octobre');
    nouveau_message(24, 1, 'palace blanc', 'comment farm des aiguillons de reve rapide');
    nouveau_message(22, 21, 'battre mogh', 'je narrive pas a battre mogh sans invoc');
    nouveau_message(3, 24, 'nv pc', 'gnagnagna g pas largent pour un nv pc');

    nouvelle_reponse(6, 23, 'palce blc', 'bah joue zinc');
    nouvelle_reponse(6, 23, 'paiiilce blc', 'c le seul truc que tu peux faire jouer');
    nouvelle_reponse(6, 23, 'lllllll blc', 'message de tesdsdt');
    nouvelle_reponse(6, 23, 'lllllll blc', 'message de tesdsdt');
    nouvelle_reponse(6, 23, 'paiiilce blc', 'message de test');
    nouvelle_reponse(2, 5, 'lllllll dlc', 'bah abadonne le dlc');

    clore_fil(31, 23);
end;
