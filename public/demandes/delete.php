<?php
require_once __DIR__.'/../../includes/bootstrap.php';
require_roles(['ADMIN','RESPONSABLE']);
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit; }
verify_csrf();
$id = (int)($_POST['id'] ?? 0);
try {
    Database::connection()->prepare('DELETE FROM demandes_devis WHERE id=?')->execute([$id]);
    audit('SUPPRESSION', 'demande_devis', $id);
    flash('success', 'Demande supprimée.');
} catch (PDOException) {
    flash('danger', 'Suppression impossible : des offres ou une recommandation sont liées à cette demande.');
}
redirect('demandes/index.php');
