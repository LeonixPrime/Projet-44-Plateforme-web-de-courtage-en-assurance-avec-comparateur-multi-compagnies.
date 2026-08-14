# AssurCourt - Projet 44

Plateforme web de courtage en assurance avec comparateur multi-compagnies, réalisée pour le Master CCA de l'ESP Dakar.

## Projet complet - lots 1 à 8

- Authentification par mot de passe bcrypt (`password_verify`)
- Quatre rôles : administrateur, responsable, agent et client
- Session sécurisée, expiration après 20 minutes et déconnexion explicite
- Protection CSRF, échappement XSS et requêtes PDO préparées
- Tableau de bord alimenté par MySQL
- CRUD clients avec validation PHP/JavaScript
- Recherche multicritère, filtre et pagination à 20 résultats
- Journal d'audit des actions sensibles
- Interface Bootstrap responsive
- CRUD des compagnies partenaires
- CRUD du référentiel des garanties
- CRUD des produits avec rattachement à une compagnie, un risque et plusieurs garanties
- Recherche et filtres du catalogue
- Administration des questionnaires auto, habitation et santé
- Création et suivi des demandes de devis
- Saisie dynamique des réponses selon le type de question
- Moteur tarifaire appliquant les règles de chaque produit
- Génération et régénération sécurisée des offres
- Comparateur multi-compagnies prix, garanties et franchises
- Recommandations motivées avec validation du responsable
- Souscriptions et historique des changements de statut
- Création des contrats et portefeuille des polices
- Barèmes et suivi des commissions
- Planification des renouvellements
- Déclaration et accompagnement des sinistres
- Tableau de bord avancé avec graphiques dynamiques
- Indicateurs commerciaux et alertes d'échéance
- Administration des utilisateurs et journal d'audit
- Exports CSV, devis imprimable en PDF et notifications e-mail
- Plan de recette et documentation de sécurité

## Installation sous XAMPP

1. Copier le dossier `AssurCourt` dans `C:\\xampp\\htdocs\\`.
2. Démarrer Apache et MySQL depuis le panneau XAMPP.
3. Ouvrir `http://localhost/phpmyadmin`.
4. Importer `sql/schema.sql`. La base `assurcourt` est créée automatiquement.
5. Vérifier les paramètres dans `config/config.php` : par défaut, utilisateur MySQL `root` sans mot de passe.
6. Ouvrir `http://localhost/AssurCourt/public/`.

Si le dossier ou le port diffère, modifier `APP_URL`, `DB_PORT`, `DB_USER` et `DB_PASS` dans `config/config.php`.

## Comptes de démonstration

| Rôle | E-mail | Mot de passe |
|---|---|---|
| Administrateur | admin@assurcourt.sn | Admin@2026! |
| Responsable | responsable@assurcourt.sn | Responsable@2026! |
| Agent | agent@assurcourt.sn | Agent@2026! |
| Client | client@assurcourt.sn | Client@2026! |

Ces comptes sont réservés à la démonstration. Changez les mots de passe avant toute utilisation réelle.

## Autorisations du module clients

- Admin, responsable et agent : consultation, recherche, ajout et modification.
- Admin et responsable : suppression.
- Client : pas d'accès au portefeuille global.

## Structure

```text
AssurCourt/
├── config/       configuration et connexion PDO
├── includes/     authentification, CSRF, fonctions et mise en page
├── public/       pages accessibles par Apache et ressources front-end
│   └── clients/  premier module CRUD
└── sql/          schéma et données de démonstration
```

## Vérifications conseillées

1. Tester la connexion avec chacun des quatre rôles.
2. Vérifier qu'un client ne peut pas ouvrir `/clients/index.php`.
3. Ajouter puis modifier un particulier et une entreprise.
4. Tester recherche, filtre et pagination avec plus de 20 lignes.
5. Vérifier qu'un agent ne peut pas supprimer un client.
6. Contrôler les lignes créées dans `journal_audit`.

## Dépannage courant

- Si Apache ne démarre pas parce que le port 80 est occupé par IIS, utiliser le port 8080 et conserver `APP_URL = 'http://localhost:8080/AssurCourt/public'`.
- Avec le port 8080, l'adresse de l'application est `http://localhost:8080/AssurCourt/public/`.
- phpMyAdmin reste accessible depuis le bouton **Admin** de MySQL dans XAMPP ou selon le port configuré localement.
- Si `#2006 - MySQL server has gone away` apparaît, vérifier que MySQL est démarré, reconnecter phpMyAdmin et réimporter `sql/schema.sql` dans une nouvelle session.
- Le devis PDF utilise la fonction **Imprimer > Enregistrer au format PDF** du navigateur.
- L'envoi réel des notifications est volontairement désactivé par défaut. Il exige la configuration d'un serveur mail et `MAIL_ENABLED = true`.

## Parcours de démonstration recommandé

1. Se connecter comme administrateur et présenter le tableau de bord.
2. Consulter le portefeuille clients et les référentiels du catalogue.
3. Ouvrir une demande complète et lancer le calcul multi-compagnies.
4. Comparer les offres puis créer une recommandation motivée.
5. Valider la recommandation comme responsable.
6. Suivre la souscription et créer la police.
7. Présenter les commissions, renouvellements et sinistres.
8. Télécharger les exports CSV et ouvrir le devis imprimable.
9. Terminer par les utilisateurs, rôles et le journal d'audit.
