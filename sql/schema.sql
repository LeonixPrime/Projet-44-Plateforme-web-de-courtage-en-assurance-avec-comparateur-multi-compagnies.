-- AssurCourt - Projet 44, Master CCA ESP Dakar
-- Compatible MySQL 8+ / MariaDB 10.4+ (XAMPP)
-- Encodage : utf8mb4

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
DROP DATABASE IF EXISTS assurcourt;
CREATE DATABASE assurcourt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE assurcourt;

CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    nom VARCHAR(80) NOT NULL,
    description VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE utilisateurs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id BIGINT UNSIGNED NOT NULL,
    nom VARCHAR(80) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    telephone VARCHAR(30) NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    statut ENUM('actif','inactif','bloque') NOT NULL DEFAULT 'actif',
    derniere_connexion DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_utilisateur_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

CREATE TABLE clients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    agent_id BIGINT UNSIGNED NULL,
    numero_client VARCHAR(30) NOT NULL UNIQUE,
    type_client ENUM('particulier','entreprise') NOT NULL DEFAULT 'particulier',
    nom VARCHAR(100) NULL,
    prenom VARCHAR(120) NULL,
    raison_sociale VARCHAR(190) NULL,
    date_naissance DATE NULL,
    email VARCHAR(190) NULL,
    telephone VARCHAR(30) NOT NULL,
    adresse VARCHAR(255) NULL,
    ville VARCHAR(100) NULL,
    profession VARCHAR(120) NULL,
    statut ENUM('prospect','actif','inactif') NOT NULL DEFAULT 'prospect',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_client_recherche (nom, prenom, raison_sociale),
    INDEX idx_client_statut (statut),
    CONSTRAINT fk_client_agent FOREIGN KEY (agent_id) REFERENCES utilisateurs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE interactions_clients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT UNSIGNED NOT NULL,
    utilisateur_id BIGINT UNSIGNED NOT NULL,
    type_interaction ENUM('appel','email','rendez_vous','note') NOT NULL,
    objet VARCHAR(190) NOT NULL,
    compte_rendu TEXT NULL,
    prochaine_action VARCHAR(255) NULL,
    date_interaction DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_interaction_date (date_interaction),
    CONSTRAINT fk_interaction_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    CONSTRAINT fk_interaction_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
) ENGINE=InnoDB;

CREATE TABLE compagnies (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    raison_sociale VARCHAR(190) NOT NULL,
    email VARCHAR(190) NULL,
    telephone VARCHAR(30) NULL,
    adresse VARCHAR(255) NULL,
    contact_commercial VARCHAR(190) NULL,
    statut ENUM('active','inactive') NOT NULL DEFAULT 'active',
    date_partenariat DATE NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories_risque (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    description TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE produits_assurance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    compagnie_id BIGINT UNSIGNED NOT NULL,
    categorie_id BIGINT UNSIGNED NOT NULL,
    code_produit VARCHAR(40) NOT NULL UNIQUE,
    nom VARCHAR(190) NOT NULL,
    description TEXT NULL,
    prime_base DECIMAL(15,2) NOT NULL DEFAULT 0,
    prime_minimale DECIMAL(15,2) NOT NULL DEFAULT 0,
    duree_mois SMALLINT UNSIGNED NOT NULL DEFAULT 12,
    statut ENUM('actif','inactif') NOT NULL DEFAULT 'actif',
    date_debut_validite DATE NOT NULL,
    date_fin_validite DATE NULL,
    INDEX idx_produit_catalogue (compagnie_id, categorie_id, statut),
    CONSTRAINT fk_produit_compagnie FOREIGN KEY (compagnie_id) REFERENCES compagnies(id),
    CONSTRAINT fk_produit_categorie FOREIGN KEY (categorie_id) REFERENCES categories_risque(id)
) ENGINE=InnoDB;

CREATE TABLE garanties (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(40) NOT NULL UNIQUE,
    libelle VARCHAR(150) NOT NULL,
    description TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE produits_garanties (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produit_id BIGINT UNSIGNED NOT NULL,
    garantie_id BIGINT UNSIGNED NOT NULL,
    plafond DECIMAL(15,2) NULL,
    franchise DECIMAL(15,2) NOT NULL DEFAULT 0,
    obligatoire TINYINT(1) NOT NULL DEFAULT 0,
    conditions TEXT NULL,
    UNIQUE KEY uq_produit_garantie (produit_id, garantie_id),
    CONSTRAINT fk_pg_produit FOREIGN KEY (produit_id) REFERENCES produits_assurance(id) ON DELETE CASCADE,
    CONSTRAINT fk_pg_garantie FOREIGN KEY (garantie_id) REFERENCES garanties(id)
) ENGINE=InnoDB;

CREATE TABLE questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    categorie_id BIGINT UNSIGNED NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    libelle VARCHAR(255) NOT NULL,
    type_reponse ENUM('texte','nombre','date','booleen','liste') NOT NULL,
    options_json JSON NULL,
    obligatoire TINYINT(1) NOT NULL DEFAULT 1,
    ordre_affichage SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    statut ENUM('active','inactive') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_question_categorie FOREIGN KEY (categorie_id) REFERENCES categories_risque(id)
) ENGINE=InnoDB;

CREATE TABLE demandes_devis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT UNSIGNED NOT NULL,
    agent_id BIGINT UNSIGNED NOT NULL,
    categorie_id BIGINT UNSIGNED NOT NULL,
    numero_demande VARCHAR(40) NOT NULL UNIQUE,
    description_besoin TEXT NULL,
    budget_maximum DECIMAL(15,2) NULL,
    date_effet_souhaitee DATE NOT NULL,
    statut ENUM('brouillon','complete','comparee','recommandee','convertie','expiree','annulee') NOT NULL DEFAULT 'brouillon',
    date_demande DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_expiration DATE NULL,
    INDEX idx_demande_filtres (categorie_id, statut, date_demande),
    CONSTRAINT fk_demande_client FOREIGN KEY (client_id) REFERENCES clients(id),
    CONSTRAINT fk_demande_agent FOREIGN KEY (agent_id) REFERENCES utilisateurs(id),
    CONSTRAINT fk_demande_categorie FOREIGN KEY (categorie_id) REFERENCES categories_risque(id)
) ENGINE=InnoDB;

CREATE TABLE reponses_questionnaire (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    demande_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,
    valeur_reponse TEXT NOT NULL,
    UNIQUE KEY uq_reponse_demande_question (demande_id, question_id),
    CONSTRAINT fk_reponse_demande FOREIGN KEY (demande_id) REFERENCES demandes_devis(id) ON DELETE CASCADE,
    CONSTRAINT fk_reponse_question FOREIGN KEY (question_id) REFERENCES questions(id)
) ENGINE=InnoDB;

CREATE TABLE regles_tarifaires (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produit_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NULL,
    critere VARCHAR(80) NOT NULL,
    operateur ENUM('egal','different','superieur','superieur_egal','inferieur','inferieur_egal','entre','contient') NOT NULL,
    valeur_comparaison VARCHAR(190) NOT NULL,
    valeur_comparaison_2 VARCHAR(190) NULL,
    type_impact ENUM('pourcentage','montant_fixe') NOT NULL,
    valeur_impact DECIMAL(15,4) NOT NULL,
    priorite SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    statut ENUM('active','inactive') NOT NULL DEFAULT 'active',
    CONSTRAINT fk_regle_produit FOREIGN KEY (produit_id) REFERENCES produits_assurance(id) ON DELETE CASCADE,
    CONSTRAINT fk_regle_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE offres_devis (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    demande_id BIGINT UNSIGNED NOT NULL,
    produit_id BIGINT UNSIGNED NOT NULL,
    numero_offre VARCHAR(40) NOT NULL UNIQUE,
    prime_nette DECIMAL(15,2) NOT NULL,
    taxes DECIMAL(15,2) NOT NULL DEFAULT 0,
    frais DECIMAL(15,2) NOT NULL DEFAULT 0,
    prime_totale DECIMAL(15,2) NOT NULL,
    score_prix DECIMAL(5,2) NOT NULL DEFAULT 0,
    score_garanties DECIMAL(5,2) NOT NULL DEFAULT 0,
    score_franchise DECIMAL(5,2) NOT NULL DEFAULT 0,
    score_global DECIMAL(5,2) NOT NULL DEFAULT 0,
    date_calcul DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_validite DATE NOT NULL,
    statut ENUM('valide','retenue','rejetee','expiree') NOT NULL DEFAULT 'valide',
    UNIQUE KEY uq_offre_demande_produit (demande_id, produit_id),
    INDEX idx_offre_classement (demande_id, score_global, prime_totale),
    CONSTRAINT fk_offre_demande FOREIGN KEY (demande_id) REFERENCES demandes_devis(id) ON DELETE CASCADE,
    CONSTRAINT fk_offre_produit FOREIGN KEY (produit_id) REFERENCES produits_assurance(id)
) ENGINE=InnoDB;

CREATE TABLE offres_garanties (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    offre_id BIGINT UNSIGNED NOT NULL,
    garantie_id BIGINT UNSIGNED NOT NULL,
    plafond_propose DECIMAL(15,2) NULL,
    franchise_proposee DECIMAL(15,2) NOT NULL DEFAULT 0,
    incluse TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_offre_garantie (offre_id, garantie_id),
    CONSTRAINT fk_og_offre FOREIGN KEY (offre_id) REFERENCES offres_devis(id) ON DELETE CASCADE,
    CONSTRAINT fk_og_garantie FOREIGN KEY (garantie_id) REFERENCES garanties(id)
) ENGINE=InnoDB;

CREATE TABLE recommandations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    demande_id BIGINT UNSIGNED NOT NULL UNIQUE,
    offre_id BIGINT UNSIGNED NOT NULL,
    auteur_id BIGINT UNSIGNED NOT NULL,
    validateur_id BIGINT UNSIGNED NULL,
    motif TEXT NOT NULL,
    avantages TEXT NULL,
    limites TEXT NULL,
    statut_validation ENUM('en_attente','validee','rejetee') NOT NULL DEFAULT 'en_attente',
    date_recommandation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_validation DATETIME NULL,
    CONSTRAINT fk_recommandation_demande FOREIGN KEY (demande_id) REFERENCES demandes_devis(id),
    CONSTRAINT fk_recommandation_offre FOREIGN KEY (offre_id) REFERENCES offres_devis(id),
    CONSTRAINT fk_recommandation_auteur FOREIGN KEY (auteur_id) REFERENCES utilisateurs(id),
    CONSTRAINT fk_recommandation_validateur FOREIGN KEY (validateur_id) REFERENCES utilisateurs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE souscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    offre_id BIGINT UNSIGNED NOT NULL UNIQUE,
    agent_id BIGINT UNSIGNED NOT NULL,
    numero_souscription VARCHAR(40) NOT NULL UNIQUE,
    date_souscription DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statut ENUM('initiee','pieces_attendues','transmise','acceptee','refusee','annulee') NOT NULL DEFAULT 'initiee',
    observations TEXT NULL,
    CONSTRAINT fk_souscription_offre FOREIGN KEY (offre_id) REFERENCES offres_devis(id),
    CONSTRAINT fk_souscription_agent FOREIGN KEY (agent_id) REFERENCES utilisateurs(id)
) ENGINE=InnoDB;

CREATE TABLE contrats (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    souscription_id BIGINT UNSIGNED NOT NULL UNIQUE,
    numero_police VARCHAR(60) NOT NULL UNIQUE,
    date_effet DATE NOT NULL,
    date_echeance DATE NOT NULL,
    prime_annuelle DECIMAL(15,2) NOT NULL,
    mode_paiement ENUM('especes','cheque','virement','mobile_money','prelevement') NOT NULL,
    statut ENUM('a_venir','actif','suspendu','resilie','expire') NOT NULL DEFAULT 'a_venir',
    document_contrat VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_contrat_echeance (statut, date_echeance),
    CONSTRAINT fk_contrat_souscription FOREIGN KEY (souscription_id) REFERENCES souscriptions(id)
) ENGINE=InnoDB;

CREATE TABLE suivis_dossiers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    souscription_id BIGINT UNSIGNED NOT NULL,
    utilisateur_id BIGINT UNSIGNED NOT NULL,
    ancien_statut VARCHAR(40) NULL,
    nouveau_statut VARCHAR(40) NOT NULL,
    commentaire TEXT NULL,
    date_suivi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_suivi_souscription FOREIGN KEY (souscription_id) REFERENCES souscriptions(id) ON DELETE CASCADE,
    CONSTRAINT fk_suivi_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
) ENGINE=InnoDB;

CREATE TABLE renouvellements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contrat_id BIGINT UNSIGNED NOT NULL,
    nouvelle_demande_id BIGINT UNSIGNED NULL,
    date_lancement DATE NOT NULL,
    ancienne_prime DECIMAL(15,2) NOT NULL,
    nouvelle_prime DECIMAL(15,2) NULL,
    decision_client ENUM('en_attente','accepte','refuse') NOT NULL DEFAULT 'en_attente',
    statut ENUM('planifie','comparaison_en_cours','termine','annule') NOT NULL DEFAULT 'planifie',
    CONSTRAINT fk_renouvellement_contrat FOREIGN KEY (contrat_id) REFERENCES contrats(id),
    CONSTRAINT fk_renouvellement_demande FOREIGN KEY (nouvelle_demande_id) REFERENCES demandes_devis(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE baremes_commission (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    compagnie_id BIGINT UNSIGNED NOT NULL,
    produit_id BIGINT UNSIGNED NULL,
    type_calcul ENUM('pourcentage','montant_fixe') NOT NULL,
    taux DECIMAL(7,4) NULL,
    montant_fixe DECIMAL(15,2) NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NULL,
    statut ENUM('actif','inactif') NOT NULL DEFAULT 'actif',
    CONSTRAINT fk_bareme_compagnie FOREIGN KEY (compagnie_id) REFERENCES compagnies(id),
    CONSTRAINT fk_bareme_produit FOREIGN KEY (produit_id) REFERENCES produits_assurance(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE commissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contrat_id BIGINT UNSIGNED NOT NULL,
    bareme_id BIGINT UNSIGNED NOT NULL,
    base_calcul DECIMAL(15,2) NOT NULL,
    taux_applique DECIMAL(7,4) NULL,
    montant DECIMAL(15,2) NOT NULL,
    date_exigibilite DATE NOT NULL,
    date_paiement DATE NULL,
    statut ENUM('a_recevoir','facturee','payee','annulee') NOT NULL DEFAULT 'a_recevoir',
    INDEX idx_commission_reporting (statut, date_exigibilite),
    CONSTRAINT fk_commission_contrat FOREIGN KEY (contrat_id) REFERENCES contrats(id),
    CONSTRAINT fk_commission_bareme FOREIGN KEY (bareme_id) REFERENCES baremes_commission(id)
) ENGINE=InnoDB;

CREATE TABLE sinistres (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    contrat_id BIGINT UNSIGNED NOT NULL,
    gestionnaire_id BIGINT UNSIGNED NULL,
    numero_sinistre VARCHAR(50) NOT NULL UNIQUE,
    date_survenance DATE NOT NULL,
    date_declaration DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type_sinistre VARCHAR(120) NOT NULL,
    description TEXT NOT NULL,
    montant_estime DECIMAL(15,2) NULL,
    statut ENUM('declare','transmis','en_instruction','accepte','refuse','clos') NOT NULL DEFAULT 'declare',
    commentaire_accompagnement TEXT NULL,
    INDEX idx_sinistre_suivi (statut, date_declaration),
    CONSTRAINT fk_sinistre_contrat FOREIGN KEY (contrat_id) REFERENCES contrats(id),
    CONSTRAINT fk_sinistre_gestionnaire FOREIGN KEY (gestionnaire_id) REFERENCES utilisateurs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE documents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id BIGINT UNSIGNED NULL,
    demande_id BIGINT UNSIGNED NULL,
    contrat_id BIGINT UNSIGNED NULL,
    sinistre_id BIGINT UNSIGNED NULL,
    ajoute_par BIGINT UNSIGNED NOT NULL,
    nom_original VARCHAR(255) NOT NULL,
    nom_stockage VARCHAR(255) NOT NULL UNIQUE,
    type_document VARCHAR(80) NOT NULL,
    type_mime VARCHAR(120) NOT NULL,
    taille_octets BIGINT UNSIGNED NOT NULL,
    date_ajout DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_document_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    CONSTRAINT fk_document_demande FOREIGN KEY (demande_id) REFERENCES demandes_devis(id) ON DELETE CASCADE,
    CONSTRAINT fk_document_contrat FOREIGN KEY (contrat_id) REFERENCES contrats(id) ON DELETE CASCADE,
    CONSTRAINT fk_document_sinistre FOREIGN KEY (sinistre_id) REFERENCES sinistres(id) ON DELETE CASCADE,
    CONSTRAINT fk_document_auteur FOREIGN KEY (ajoute_par) REFERENCES utilisateurs(id)
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id BIGINT UNSIGNED NULL,
    client_id BIGINT UNSIGNED NULL,
    canal ENUM('application','email') NOT NULL,
    objet VARCHAR(190) NOT NULL,
    contenu TEXT NOT NULL,
    statut ENUM('a_envoyer','envoyee','echec','lue') NOT NULL DEFAULT 'a_envoyer',
    date_programmee DATETIME NOT NULL,
    date_envoi DATETIME NULL,
    CONSTRAINT fk_notification_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_client FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE journal_audit (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id BIGINT UNSIGNED NULL,
    action VARCHAR(80) NOT NULL,
    entite VARCHAR(80) NOT NULL,
    entite_id BIGINT UNSIGNED NULL,
    details TEXT NULL,
    adresse_ip VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,
    date_action DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_recherche (entite, entite_id, date_action),
    CONSTRAINT fk_audit_utilisateur FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Donnees de demonstration
INSERT INTO roles (id, code, nom, description) VALUES
(1, 'ADMIN', 'Administrateur', 'Administration complete et audit'),
(2, 'RESPONSABLE', 'Responsable courtier', 'Validation et pilotage'),
(3, 'AGENT', 'Agent de courtage', 'Gestion operationnelle des dossiers'),
(4, 'CLIENT', 'Client', 'Consultation de son espace personnel');

-- Hashes bcrypt cout 12, compatibles avec password_verify() de PHP.
INSERT INTO utilisateurs (id, role_id, nom, prenom, email, telephone, mot_de_passe) VALUES
(1, 1, 'DIOP', 'Aminata', 'admin@assurcourt.sn', '770000001', '$2b$12$ZytLhFWhu112h4Vx7Ano1uDsIiOXWHAAIPC7r/61UEBEvFoPcxR2G'),
(2, 2, 'NDIAYE', 'Moussa', 'responsable@assurcourt.sn', '770000002', '$2b$12$QMnNNUlkrkqTfflDwb4JlemiidgzlGmmDD2z6vCmbkCa4u2dR6Z5y'),
(3, 3, 'FALL', 'Marieme', 'agent@assurcourt.sn', '770000003', '$2b$12$vXQJ5aYApKjjs58klpf4au8r764kYozTlLbarBw/vDiY0eUQf3z9y'),
(4, 4, 'SARR', 'Ibrahima', 'client@assurcourt.sn', '770000004', '$2b$12$VBJ.NYJ9kBJx4scI2wCu3e/eh/UGejarj/uDZXvBzJKZc.59pKi4a');

INSERT INTO categories_risque (id, code, libelle, description) VALUES
(1, 'AUTO', 'Automobile', 'Assurance des vehicules et responsabilite civile'),
(2, 'HABITATION', 'Habitation', 'Protection des logements et de leur contenu'),
(3, 'SANTE', 'Sante', 'Couverture des frais medicaux');

INSERT INTO compagnies (id, code, raison_sociale, email, telephone, adresse, contact_commercial, date_partenariat) VALUES
(1, 'CS-DEMO', 'Compagnie Sahel - Demonstration', 'partenaires@sahel.test', '338000001', 'Dakar', 'Awa Ba', '2025-01-15'),
(2, 'TA-DEMO', 'Teranga Assurances - Demonstration', 'courtage@teranga.test', '338000002', 'Dakar', 'Oumar Kane', '2025-02-01'),
(3, 'KA-DEMO', 'Keur Assur - Demonstration', 'reseau@keurassur.test', '338000003', 'Thies', 'Fatou Gueye', '2025-03-10');

INSERT INTO produits_assurance (id, compagnie_id, categorie_id, code_produit, nom, description, prime_base, prime_minimale, date_debut_validite) VALUES
(1, 1, 1, 'CS-AUTO-CONF', 'Auto Confort', 'Formule automobile equilibree', 85000, 75000, '2026-01-01'),
(2, 2, 1, 'TA-AUTO-PLUS', 'Auto Plus', 'Formule automobile etendue', 92000, 80000, '2026-01-01'),
(3, 3, 1, 'KA-AUTO-ECO', 'Auto Eco', 'Formule automobile essentielle', 72000, 65000, '2026-01-01'),
(4, 1, 2, 'CS-HAB-SER', 'Habitat Serenite', 'Multirisque habitation', 60000, 50000, '2026-01-01'),
(5, 2, 3, 'TA-SANTE-FAM', 'Sante Famille', 'Couverture sante familiale', 180000, 150000, '2026-01-01');

INSERT INTO garanties (id, code, libelle, description) VALUES
(1, 'RC', 'Responsabilite civile', 'Dommages causes aux tiers'),
(2, 'VOL', 'Vol', 'Vol ou tentative de vol'),
(3, 'INCENDIE', 'Incendie', 'Dommages causes par incendie'),
(4, 'BRIS_GLACE', 'Bris de glace', 'Pare-brise et vitrages'),
(5, 'DOMMAGES', 'Dommages tous accidents', 'Dommages subis par le bien assure'),
(6, 'HOSPITALISATION', 'Hospitalisation', 'Prise en charge des frais hospitaliers');

INSERT INTO produits_garanties (produit_id, garantie_id, plafond, franchise, obligatoire) VALUES
(1,1,50000000,0,1),(1,2,8000000,100000,0),(1,4,1000000,50000,0),
(2,1,75000000,0,1),(2,2,12000000,75000,1),(2,4,1500000,25000,1),(2,5,15000000,150000,0),
(3,1,50000000,0,1),(3,4,750000,75000,0),
(4,2,10000000,100000,0),(4,3,25000000,50000,1),(4,5,20000000,100000,0),
(5,6,5000000,0,1);

INSERT INTO questions (id, categorie_id, code, libelle, type_reponse, options_json, ordre_affichage) VALUES
(1,1,'AUTO_VALEUR','Valeur estimee du vehicule','nombre',NULL,1),
(2,1,'AUTO_AGE','Age du vehicule en annees','nombre',NULL,2),
(3,1,'AUTO_USAGE','Usage principal du vehicule','liste','["prive","professionnel"]',3),
(4,2,'HAB_VALEUR','Valeur estimee du logement et du contenu','nombre',NULL,1),
(5,2,'HAB_ZONE','Zone de localisation','texte',NULL,2),
(6,3,'SANTE_NB','Nombre de personnes a couvrir','nombre',NULL,1),
(7,3,'SANTE_AGE_MAX','Age de la personne la plus agee','nombre',NULL,2);

INSERT INTO regles_tarifaires (produit_id, question_id, critere, operateur, valeur_comparaison, type_impact, valeur_impact, priorite) VALUES
(1,1,'AUTO_VALEUR','superieur','10000000','pourcentage',15,10),
(1,2,'AUTO_AGE','superieur','10','pourcentage',12,20),
(2,3,'AUTO_USAGE','egal','professionnel','pourcentage',20,10),
(3,2,'AUTO_AGE','superieur','15','pourcentage',18,10),
(4,4,'HAB_VALEUR','superieur','50000000','pourcentage',20,10),
(5,6,'SANTE_NB','superieur','4','montant_fixe',50000,10);

INSERT INTO clients (id, agent_id, numero_client, type_client, nom, prenom, date_naissance, email, telephone, adresse, ville, profession, statut) VALUES
(1,3,'CLI-2026-0001','particulier','SARR','Ibrahima','1988-06-14','ibrahima.sarr@example.test','770000004','Liberte 6','Dakar','Comptable','actif'),
(2,3,'CLI-2026-0002','particulier','DIALLO','Sokhna','1992-11-03','sokhna.diallo@example.test','770000005','Mermoz','Dakar','Consultante','prospect');

INSERT INTO demandes_devis (id, client_id, agent_id, categorie_id, numero_demande, description_besoin, budget_maximum, date_effet_souhaitee, statut, date_expiration) VALUES
(1,1,3,1,'DEM-2026-0001','Assurance automobile avec vol et bris de glace',120000,'2026-09-01','recommandee','2026-09-30');

INSERT INTO reponses_questionnaire (demande_id, question_id, valeur_reponse) VALUES
(1,1,'8500000'),(1,2,'4'),(1,3,'prive');

INSERT INTO offres_devis (id, demande_id, produit_id, numero_offre, prime_nette, taxes, frais, prime_totale, score_prix, score_garanties, score_franchise, score_global, date_validite, statut) VALUES
(1,1,1,'OFF-2026-0001',85000,11900,3000,99900,88,78,75,81.20,'2026-09-30','valide'),
(2,1,2,'OFF-2026-0002',92000,12880,3000,107880,78,95,90,87.20,'2026-09-30','retenue'),
(3,1,3,'OFF-2026-0003',72000,10080,3000,85080,100,62,60,76.80,'2026-09-30','valide');

INSERT INTO offres_garanties (offre_id, garantie_id, plafond_propose, franchise_proposee, incluse) VALUES
(1,1,50000000,0,1),(1,2,8000000,100000,1),(1,4,1000000,50000,1),
(2,1,75000000,0,1),(2,2,12000000,75000,1),(2,4,1500000,25000,1),(2,5,15000000,150000,1),
(3,1,50000000,0,1),(3,4,750000,75000,1);

INSERT INTO recommandations (demande_id, offre_id, auteur_id, validateur_id, motif, avantages, limites, statut_validation, date_validation) VALUES
(1,2,3,2,'Meilleur equilibre entre etendue des garanties, franchises et cout total.','Vol, bris de glace et dommages avec plafonds eleves.','Prime superieure a la formule economique.','validee',CURRENT_TIMESTAMP);

INSERT INTO baremes_commission (id, compagnie_id, produit_id, type_calcul, taux, date_debut) VALUES
(1,1,1,'pourcentage',12.5000,'2026-01-01'),
(2,2,2,'pourcentage',15.0000,'2026-01-01'),
(3,3,3,'pourcentage',10.0000,'2026-01-01');

INSERT INTO journal_audit (utilisateur_id, action, entite, entite_id, details, adresse_ip) VALUES
(1,'CREATION','base_de_donnees',NULL,'Initialisation des donnees de demonstration','127.0.0.1');

SET FOREIGN_KEY_CHECKS = 1;

-- Comptes de test (a changer avant toute mise en production)
-- admin@assurcourt.sn       / Admin@2026!
-- responsable@assurcourt.sn / Responsable@2026!
-- agent@assurcourt.sn       / Agent@2026!
-- client@assurcourt.sn      / Client@2026!
