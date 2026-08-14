<?php
require_once __DIR__.'/../../includes/bootstrap.php';
require_roles(['ADMIN','RESPONSABLE','AGENT']);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit; }
verify_csrf();
$id = (int)($_POST['id'] ?? 0);
try {
    $count = generate_quotes(Database::connection(), $id);
    audit('CALCUL_OFFRES', 'demande_devis', $id, $count.' offres générées');
    flash('success', $count.' offre(s) calculée(s) et comparée(s).');
    redirect('demandes/comparateur.php?id='.$id);
} catch (Throwable $e) {
    flash('danger', $e->getMessage());
    redirect('demandes/index.php');
}
