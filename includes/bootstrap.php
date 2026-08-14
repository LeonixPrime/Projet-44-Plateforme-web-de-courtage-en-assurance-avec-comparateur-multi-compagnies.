<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/csrf.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/pricing.php';
require_once __DIR__ . '/commissions.php';
require_once __DIR__ . '/notifications.php';

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_name('assurcourt_session');
    session_start([
        'cookie_httponly' => true,
        'cookie_samesite' => 'Lax',
        'cookie_secure' => !empty($_SERVER['HTTPS']),
        'use_strict_mode' => true,
    ]);
}

enforce_session_timeout();
