<?php
declare(strict_types=1);
function create_contract_commission(PDO $db,int $contractId,int $subscriptionId,string $date,float $base): void{
 $s=$db->prepare('SELECT p.id produit_id,p.compagnie_id FROM souscriptions su JOIN offres_devis o ON o.id=su.offre_id JOIN produits_assurance p ON p.id=o.produit_id WHERE su.id=?');$s->execute([$subscriptionId]);$p=$s->fetch();if(!$p)return;
 $s=$db->prepare("SELECT * FROM baremes_commission WHERE compagnie_id=? AND (produit_id IS NULL OR produit_id=?) AND statut='actif' AND date_debut<=? AND (date_fin IS NULL OR date_fin>=?) ORDER BY (produit_id IS NOT NULL) DESC LIMIT 1");$s->execute([$p['compagnie_id'],$p['produit_id'],$date,$date]);$b=$s->fetch();if(!$b)return;
 $amount=$b['type_calcul']==='pourcentage'?$base*(float)$b['taux']/100:(float)$b['montant_fixe'];$db->prepare('INSERT INTO commissions(contrat_id,bareme_id,base_calcul,taux_applique,montant,date_exigibilite) VALUES(?,?,?,?,?,?)')->execute([$contractId,$b['id'],$base,$b['taux'],$amount,$date]);
}
