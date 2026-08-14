<?php
require_once __DIR__.'/../../includes/bootstrap.php'; require_roles(['ADMIN','RESPONSABLE']);
if($_SERVER['REQUEST_METHOD']!=='POST'){http_response_code(405);exit;}
verify_csrf();$id=(int)($_POST['id']??0);
try{$s=Database::connection()->prepare('DELETE FROM clients WHERE id=?');$s->execute([$id]);audit('SUPPRESSION','client',$id);flash('success','Client supprimé.');}
catch(PDOException){flash('danger','Suppression impossible : ce client possède déjà des dossiers liés. Passez-le au statut inactif.');}
redirect('clients/index.php');

