<?php
declare(strict_types=1);

function rule_matches(string $actual, array $rule): bool
{
    $expected = (string)$rule['valeur_comparaison'];
    $second = (string)($rule['valeur_comparaison_2'] ?? '');
    return match ($rule['operateur']) {
        'egal' => mb_strtolower($actual) === mb_strtolower($expected),
        'different' => mb_strtolower($actual) !== mb_strtolower($expected),
        'superieur' => is_numeric($actual) && (float)$actual > (float)$expected,
        'superieur_egal' => is_numeric($actual) && (float)$actual >= (float)$expected,
        'inferieur' => is_numeric($actual) && (float)$actual < (float)$expected,
        'inferieur_egal' => is_numeric($actual) && (float)$actual <= (float)$expected,
        'entre' => is_numeric($actual) && (float)$actual >= (float)$expected && (float)$actual <= (float)$second,
        'contient' => mb_stripos($actual, $expected) !== false,
        default => false,
    };
}

function generate_quotes(PDO $db, int $requestId): int
{
    $stmt = $db->prepare('SELECT * FROM demandes_devis WHERE id=?');
    $stmt->execute([$requestId]);
    $request = $stmt->fetch();
    if (!$request || !in_array($request['statut'], ['complete','comparee'], true)) {
        throw new RuntimeException('Le questionnaire doit être complet avant le calcul.');
    }
    $stmt = $db->prepare('SELECT question_id,valeur_reponse FROM reponses_questionnaire WHERE demande_id=?');
    $stmt->execute([$requestId]);
    $answers = [];
    foreach ($stmt->fetchAll() as $answer) $answers[(int)$answer['question_id']] = (string)$answer['valeur_reponse'];

    $stmt = $db->prepare("SELECT p.* FROM produits_assurance p JOIN compagnies c ON c.id=p.compagnie_id WHERE p.categorie_id=? AND p.statut='actif' AND c.statut='active' AND p.date_debut_validite<=CURRENT_DATE AND (p.date_fin_validite IS NULL OR p.date_fin_validite>=CURRENT_DATE)");
    $stmt->execute([$request['categorie_id']]);
    $products = $stmt->fetchAll();
    if (!$products) throw new RuntimeException('Aucun produit actif pour cette branche.');

    $calculated = [];
    foreach ($products as $product) {
        $premium = (float)$product['prime_base']; $applied = [];
        $stmt = $db->prepare("SELECT * FROM regles_tarifaires WHERE produit_id=? AND statut='active' ORDER BY priorite,id");
        $stmt->execute([$product['id']]);
        foreach ($stmt->fetchAll() as $rule) {
            $actual = $answers[(int)$rule['question_id']] ?? '';
            if ($actual !== '' && rule_matches($actual, $rule)) {
                $impact = (float)$rule['valeur_impact'];
                $premium += $rule['type_impact'] === 'pourcentage' ? $premium * $impact / 100 : $impact;
                $applied[] = $rule['critere'].' '.$rule['operateur'].' '.$rule['valeur_comparaison'];
            }
        }
        $premium = max($premium, (float)$product['prime_minimale']);
        $stmt = $db->prepare('SELECT COUNT(*) nb,COALESCE(AVG(franchise),0) franchise FROM produits_garanties WHERE produit_id=?');
        $stmt->execute([$product['id']]); $coverage = $stmt->fetch();
        $calculated[] = ['product'=>$product,'premium'=>$premium,'guarantees'=>(int)$coverage['nb'],'franchise'=>(float)$coverage['franchise'],'rules'=>$applied];
    }
    $minPremium = min(array_column($calculated,'premium'));
    $maxGuarantees = max(1,max(array_column($calculated,'guarantees')));
    $maxFranchise = max(1,max(array_column($calculated,'franchise')));
    $db->beginTransaction();
    try {
        $up = $db->prepare("INSERT INTO offres_devis(demande_id,produit_id,numero_offre,prime_nette,taxes,frais,prime_totale,score_prix,score_garanties,score_franchise,score_global,date_validite,statut) VALUES(:demande,:produit,:numero,:nette,:taxes,:frais,:total,:prix,:garanties,:franchise,:global,:validite,'valide') ON DUPLICATE KEY UPDATE prime_nette=VALUES(prime_nette),taxes=VALUES(taxes),frais=VALUES(frais),prime_totale=VALUES(prime_totale),score_prix=VALUES(score_prix),score_garanties=VALUES(score_garanties),score_franchise=VALUES(score_franchise),score_global=VALUES(score_global),date_calcul=NOW(),date_validite=VALUES(date_validite),statut='valide'");
        foreach ($calculated as $row) {
            $net = round($row['premium'],2); $taxes=round($net*0.14,2); $fees=3000.00; $total=$net+$taxes+$fees;
            $priceScore=round(100*$minPremium/max(1,$net),2);$guaranteeScore=round(100*$row['guarantees']/$maxGuarantees,2);$franchiseScore=round(100*(1-$row['franchise']/$maxFranchise),2);$global=round(.4*$priceScore+.4*$guaranteeScore+.2*$franchiseScore,2);
            $number='OFF-'.date('Y').'-'.$requestId.'-'.$row['product']['id'];
            $up->execute(['demande'=>$requestId,'produit'=>$row['product']['id'],'numero'=>$number,'nette'=>$net,'taxes'=>$taxes,'frais'=>$fees,'total'=>$total,'prix'=>$priceScore,'garanties'=>$guaranteeScore,'franchise'=>$franchiseScore,'global'=>$global,'validite'=>$request['date_expiration']?:date('Y-m-d',strtotime('+30 days'))]);
            $offerId=(int)$db->lastInsertId();if(!$offerId){$s=$db->prepare('SELECT id FROM offres_devis WHERE demande_id=? AND produit_id=?');$s->execute([$requestId,$row['product']['id']]);$offerId=(int)$s->fetchColumn();}
            $db->prepare('DELETE FROM offres_garanties WHERE offre_id=?')->execute([$offerId]);
            $copy=$db->prepare('INSERT INTO offres_garanties(offre_id,garantie_id,plafond_propose,franchise_proposee,incluse) SELECT ?,garantie_id,plafond,franchise,1 FROM produits_garanties WHERE produit_id=?');$copy->execute([$offerId,$row['product']['id']]);
        }
        $db->prepare("UPDATE demandes_devis SET statut='comparee' WHERE id=?")->execute([$requestId]);$db->commit();return count($calculated);
    } catch (Throwable $e) { if($db->inTransaction())$db->rollBack();throw $e; }
}
