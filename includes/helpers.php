<?php
declare(strict_types=1);

function e(?string $value): string
{
    return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function redirect(string $path): never
{
    header('Location: ' . APP_URL . '/' . ltrim($path, '/'));
    exit;
}

function flash(string $type, string $message): void
{
    $_SESSION['flash'][] = ['type' => $type, 'message' => $message];
}

function consume_flashes(): array
{
    $items = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $items;
}

function audit(string $action, string $entity, ?int $entityId = null, ?string $details = null): void
{
    $stmt = Database::connection()->prepare(
        'INSERT INTO journal_audit (utilisateur_id, action, entite, entite_id, details, adresse_ip, user_agent)
         VALUES (:user, :action, :entity, :entity_id, :details, :ip, :agent)'
    );
    $stmt->execute([
        'user' => $_SESSION['user']['id'] ?? null,
        'action' => $action,
        'entity' => $entity,
        'entity_id' => $entityId,
        'details' => $details,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? null,
        'agent' => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255),
    ]);
}

