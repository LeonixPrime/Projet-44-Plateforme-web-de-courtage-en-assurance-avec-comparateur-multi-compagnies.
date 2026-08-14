<?php
require_once __DIR__ . '/../includes/bootstrap.php';
redirect(!empty($_SESSION['user']) ? 'dashboard.php' : 'login.php');

