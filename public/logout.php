<?php
require_once __DIR__ . '/../includes/bootstrap.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit; }
verify_csrf(); logout_user(); session_start(); flash('success', 'Vous êtes déconnecté.'); redirect('login.php');

