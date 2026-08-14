<?php
declare(strict_types=1);

function login_user(string $email, string $password): bool
{
    $stmt = Database::connection()->prepare(
        "SELECT u.id, u.nom, u.prenom, u.email, u.mot_de_passe, r.code AS role
         FROM utilisateurs u JOIN roles r ON r.id = u.role_id
         WHERE u.email = :email AND u.statut = 'actif' LIMIT 1"
    );
    $stmt->execute(['email' => mb_strtolower(trim($email))]);
    $user = $stmt->fetch();
    if (!$user || !password_verify($password, $user['mot_de_passe'])) {
        return false;
    }
    session_regenerate_id(true);
    unset($user['mot_de_passe']);
    $_SESSION['user'] = $user;
    $_SESSION['last_activity'] = time();
    Database::connection()->prepare('UPDATE utilisateurs SET derniere_connexion = NOW() WHERE id = ?')->execute([$user['id']]);
    audit('CONNEXION', 'utilisateur', (int)$user['id']);
    return true;
}

function logout_user(): void
{
    if (!empty($_SESSION['user'])) {
        audit('DECONNEXION', 'utilisateur', (int)$_SESSION['user']['id']);
    }
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
    }
    session_destroy();
}

function require_auth(): void
{
    if (empty($_SESSION['user'])) {
        flash('warning', 'Veuillez vous connecter.');
        redirect('login.php');
    }
}

function require_roles(array $roles): void
{
    require_auth();
    if (!in_array($_SESSION['user']['role'], $roles, true)) {
        http_response_code(403);
        exit('Accès interdit.');
    }
}

function enforce_session_timeout(): void
{
    if (!empty($_SESSION['user']) && isset($_SESSION['last_activity']) && time() - (int)$_SESSION['last_activity'] > SESSION_TIMEOUT) {
        logout_user();
        session_start();
        flash('warning', 'Session expirée après 20 minutes d’inactivité.');
        redirect('login.php');
    }
    if (!empty($_SESSION['user'])) {
        $_SESSION['last_activity'] = time();
    }
}

