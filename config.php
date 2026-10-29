<?php
declare(strict_types=1);
// Set these in your environment or edit them for your local XAMPP installation.
const DB_HOST = '127.0.0.1';
const DB_NAME = 'campuscart';
const DB_USER = 'root';
const DB_PASS = '';
const GEMINI_API_KEY = ''; // Optional. Keep real keys out of source control.
const APP_NAME = 'CampusCart';
const UPLOAD_DIR = __DIR__ . '/uploads';
const MAX_UPLOAD_BYTES = 5_000_000;

// Keep student and administrator authentication isolated in separate browser
// cookies. Both cookies are available throughout this CampusCart installation.
function campuscart_session(string $name): void {
    if (session_status() === PHP_SESSION_ACTIVE) return;
    session_name($name);
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/CampusCart/',
        'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}
