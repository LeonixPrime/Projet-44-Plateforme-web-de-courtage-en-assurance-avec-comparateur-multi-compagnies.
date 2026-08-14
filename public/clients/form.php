<?php
require_once __DIR__.'/../../includes/bootstrap.php'; require_roles(['ADMIN','RESPONSABLE','AGENT']);
$db=Database::connection(); $id=max(0,(int)($_GET['id']??$_POST['id']??0)); $errors=[];
$client=['type_client'=>'particulier','nom'=>'','prenom'=>'','raison_sociale'=>'','date_naissance'=>'','email'=>'','telephone'=>'','adresse'=>'','ville'=>'','profession'=>'','statut'=>'prospect'];
if($id){$s=$db->prepare('SELECT * FROM clients WHERE id=?');$s->execute([$id]);$client=$s->fetch();if(!$client){http_response_code(404);exit('Client introuvable.');}}
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf(); foreach(array_keys($client) as $field){if(isset($_POST[$field]))$client[$field]=trim((string)$_POST[$field]);}
 if(!in_array($client['type_client'],['particulier','entreprise'],true))$errors[]='Type de client invalide.';
 if($client['type_client']==='particulier'&&($client['nom']===''||$client['prenom']===''))$errors[]='Le nom et le prénom sont obligatoires.';
 if($client['type_client']==='entreprise'&&$client['raison_sociale']==='')$errors[]='La raison sociale est obligatoire.';
 if($client['telephone']==='')$errors[]='Le téléphone est obligatoire.';
 if($client['email']!==''&&!filter_var($client['email'],FILTER_VALIDATE_EMAIL))$errors[]='Adresse e-mail invalide.';
 if(!in_array($client['statut'],['prospect','actif','inactif'],true))$errors[]='Statut invalide.';
 if(!$errors){
  $values=['agent'=>$_SESSION['user']['id'],'type'=>$client['type_client'],'nom'=>$client['nom']?:null,'prenom'=>$client['prenom']?:null,'raison'=>$client['raison_sociale']?:null,'naissance'=>$client['date_naissance']?:null,'email'=>$client['email']?:null,'telephone'=>$client['telephone'],'adresse'=>$client['adresse']?:null,'ville'=>$client['ville']?:null,'profession'=>$client['profession']?:null,'statut'=>$client['statut']];
  if($id){$values['id']=$id;$sql='UPDATE clients SET agent_id=:agent,type_client=:type,nom=:nom,prenom=:prenom,raison_sociale=:raison,date_naissance=:naissance,email=:email,telephone=:telephone,adresse=:adresse,ville=:ville,profession=:profession,statut=:statut WHERE id=:id';}
  else{$numero='CLI-'.date('Y').'-'.str_pad((string)((int)$db->query('SELECT COALESCE(MAX(id),0)+1 FROM clients')->fetchColumn()),4,'0',STR_PAD_LEFT);$values['numero']=$numero;$sql='INSERT INTO clients(agent_id,numero_client,type_client,nom,prenom,raison_sociale,date_naissance,email,telephone,adresse,ville,profession,statut) VALUES(:agent,:numero,:type,:nom,:prenom,:raison,:naissance,:email,:telephone,:adresse,:ville,:profession,:statut)';}
  $db->prepare($sql)->execute($values);$savedId=$id?:((int)$db->lastInsertId());audit($id?'MODIFICATION':'CREATION','client',$savedId);flash('success',$id?'Client modifié.':'Client créé.');redirect('clients/index.php');
 }
}
$title=$id?'Modifier le client':'Nouveau client';require __DIR__.'/../../includes/header.php';
?>
<div class="row justify-content-center"><div class="col-xl-9"><div class="d-flex justify-content-between mb-3"><h1 class="h3"><?= e($title) ?></h1><a href="index.php" class="btn btn-outline-secondary">Retour</a></div>
<?php if($errors): ?><div class="alert alert-danger"><ul class="mb-0"><?php foreach($errors as $error): ?><li><?= e($error) ?></li><?php endforeach; ?></ul></div><?php endif; ?>
<form method="post" class="card card-body shadow-sm needs-validation" novalidate><?= csrf_field() ?><input type="hidden" name="id" value="<?= $id ?>">
<div class="row g-3"><div class="col-md-4"><label class="form-label">Type *</label><select class="form-select" name="type_client" id="typeClient"><option value="particulier" <?= $client['type_client']==='particulier'?'selected':'' ?>>Particulier</option><option value="entreprise" <?= $client['type_client']==='entreprise'?'selected':'' ?>>Entreprise</option></select></div><div class="col-md-4"><label class="form-label">Statut *</label><select class="form-select" name="statut"><?php foreach(['prospect'=>'Prospect','actif'=>'Actif','inactif'=>'Inactif'] as $v=>$l): ?><option value="<?= $v ?>" <?= $client['statut']===$v?'selected':'' ?>><?= $l ?></option><?php endforeach ?></select></div>
<div class="col-md-4 enterprise-field"><label class="form-label">Raison sociale *</label><input class="form-control" name="raison_sociale" value="<?= e($client['raison_sociale']) ?>"></div>
<div class="col-md-6 person-field"><label class="form-label">Prénom *</label><input class="form-control" name="prenom" value="<?= e($client['prenom']) ?>"></div><div class="col-md-6 person-field"><label class="form-label">Nom *</label><input class="form-control" name="nom" value="<?= e($client['nom']) ?>"></div>
<div class="col-md-6"><label class="form-label">Téléphone *</label><input class="form-control" name="telephone" value="<?= e($client['telephone']) ?>" required></div><div class="col-md-6"><label class="form-label">E-mail</label><input type="email" class="form-control" name="email" value="<?= e($client['email']) ?>"></div>
<div class="col-md-4 person-field"><label class="form-label">Date de naissance</label><input type="date" class="form-control" name="date_naissance" value="<?= e($client['date_naissance']) ?>"></div><div class="col-md-4"><label class="form-label">Ville</label><input class="form-control" name="ville" value="<?= e($client['ville']) ?>"></div><div class="col-md-4 person-field"><label class="form-label">Profession</label><input class="form-control" name="profession" value="<?= e($client['profession']) ?>"></div><div class="col-12"><label class="form-label">Adresse</label><input class="form-control" name="adresse" value="<?= e($client['adresse']) ?>"></div></div>
<div class="mt-4 text-end"><button class="btn btn-primary px-4">Enregistrer</button></div></form></div></div>
<?php require __DIR__.'/../../includes/footer.php'; ?>

