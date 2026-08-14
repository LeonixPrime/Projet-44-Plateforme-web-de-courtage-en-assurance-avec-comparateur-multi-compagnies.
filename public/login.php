<?php
require_once __DIR__ . '/../includes/bootstrap.php';
if (!empty($_SESSION['user'])) redirect('dashboard.php');
$error = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $email = filter_input(INPUT_POST, 'email', FILTER_VALIDATE_EMAIL);
    $password = (string)($_POST['password'] ?? '');
    if (!$email || $password === '' || !login_user($email, $password)) {
        $error = 'Identifiants incorrects.';
    } else {
        redirect('dashboard.php');
    }
}
$title = 'Connexion'; require __DIR__ . '/../includes/header.php';
?>
<div class="row justify-content-center mt-5"><div class="col-12 col-md-7 col-lg-4">
<div class="card shadow border-0"><div class="card-body p-4 p-lg-5">
<div class="text-center mb-4"><div class="logo-mark">AC</div><h1 class="h3 mt-3">Bienvenue sur AssurCourt</h1><p class="text-secondary">Courtage et comparaison multi-compagnies</p></div>
<?php if ($error): ?><div class="alert alert-danger"><?= e($error) ?></div><?php endif; ?>
<form method="post" novalidate><?= csrf_field() ?>
<div class="mb-3"><label class="form-label" for="email">Adresse e-mail</label><input class="form-control" id="email" name="email" type="email" required autofocus></div>
<div class="mb-4"><label class="form-label" for="password">Mot de passe</label><input class="form-control" id="password" name="password" type="password" required></div>
<button class="btn btn-primary w-100">Se connecter</button></form>
</div></div></div></div>
<?php require __DIR__ . '/../includes/footer.php'; ?>

