<?php
require_once __DIR__ . '/../../includes/bootstrap.php'; require_roles(['ADMIN','RESPONSABLE','AGENT']);
$db=Database::connection(); $q=trim((string)($_GET['q']??'')); $statut=(string)($_GET['statut']??'');
$page=max(1,(int)($_GET['page']??1)); $perPage=20; $where=[]; $params=[];
if ($q!=='') { $where[]="(c.numero_client LIKE :q OR c.nom LIKE :q OR c.prenom LIKE :q OR c.raison_sociale LIKE :q OR c.telephone LIKE :q)"; $params['q']='%'.$q.'%'; }
if (in_array($statut,['prospect','actif','inactif'],true)) { $where[]='c.statut=:statut'; $params['statut']=$statut; }
$sqlWhere=$where?' WHERE '.implode(' AND ',$where):'';
$count=$db->prepare('SELECT COUNT(*) FROM clients c'.$sqlWhere); $count->execute($params); $total=(int)$count->fetchColumn(); $pages=max(1,(int)ceil($total/$perPage)); $page=min($page,$pages);
$stmt=$db->prepare("SELECT c.*, CONCAT(u.prenom,' ',u.nom) agent FROM clients c LEFT JOIN utilisateurs u ON u.id=c.agent_id $sqlWhere ORDER BY c.created_at DESC LIMIT :limit OFFSET :offset");
foreach($params as $key=>$value) $stmt->bindValue(':'.$key,$value); $stmt->bindValue(':limit',$perPage,PDO::PARAM_INT); $stmt->bindValue(':offset',($page-1)*$perPage,PDO::PARAM_INT); $stmt->execute(); $clients=$stmt->fetchAll();
$title='Clients'; require __DIR__.'/../../includes/header.php';
?>
<div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3"><div><h1 class="h3 mb-1">Portefeuille clients</h1><p class="text-secondary mb-0"><?= $total ?> résultat(s)</p></div><a class="btn btn-primary" href="form.php">+ Ajouter</a></div>
<form class="card card-body mb-3" method="get"><div class="row g-2"><div class="col-md-8"><input class="form-control" name="q" value="<?= e($q) ?>" placeholder="Nom, numéro client ou téléphone"></div><div class="col-md-2"><select class="form-select" name="statut"><option value="">Tous les statuts</option><?php foreach(['prospect'=>'Prospect','actif'=>'Actif','inactif'=>'Inactif'] as $v=>$l): ?><option value="<?= $v ?>" <?= $statut===$v?'selected':'' ?>><?= $l ?></option><?php endforeach ?></select></div><div class="col-md-2"><button class="btn btn-dark w-100">Rechercher</button></div></div></form>
<div class="card"><div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr><th>Numéro</th><th>Client</th><th>Contact</th><th>Ville</th><th>Statut</th><th class="text-end">Actions</th></tr></thead><tbody>
<?php if(!$clients): ?><tr><td colspan="6" class="text-center py-5 text-secondary">Aucun client trouvé.</td></tr><?php endif; ?>
<?php foreach($clients as $c): $display=$c['type_client']==='entreprise'?$c['raison_sociale']:trim($c['prenom'].' '.$c['nom']); ?><tr><td class="fw-semibold"><?= e($c['numero_client']) ?></td><td><?= e($display) ?><div class="small text-secondary"><?= e($c['type_client']) ?></div></td><td><?= e($c['telephone']) ?><div class="small"><?= e($c['email']) ?></div></td><td><?= e($c['ville']) ?></td><td><span class="badge text-bg-<?= $c['statut']==='actif'?'success':($c['statut']==='prospect'?'warning':'secondary') ?>"><?= e($c['statut']) ?></span></td><td class="text-end"><a class="btn btn-sm btn-outline-primary" href="form.php?id=<?= (int)$c['id'] ?>">Modifier</a> <form method="post" action="delete.php" class="d-inline" data-confirm="Supprimer ce client ?"><?= csrf_field() ?><input type="hidden" name="id" value="<?= (int)$c['id'] ?>"><button class="btn btn-sm btn-outline-danger">Supprimer</button></form></td></tr><?php endforeach; ?>
</tbody></table></div></div>
<?php if($pages>1): ?><nav class="mt-3"><ul class="pagination"><?php for($i=1;$i<=$pages;$i++): ?><li class="page-item <?= $i===$page?'active':'' ?>"><a class="page-link" href="?<?= http_build_query(['q'=>$q,'statut'=>$statut,'page'=>$i]) ?>"><?= $i ?></a></li><?php endfor; ?></ul></nav><?php endif; ?>
<?php require __DIR__.'/../../includes/footer.php'; ?>

