# CampusCart

A PHP 8+ / MySQL marketplace for student communities. Built for XAMPP.

## Run locally

1. Copy this folder to `C:\xampp\htdocs\CampusCart`.
2. Start Apache and MySQL in XAMPP.
3. In phpMyAdmin, import the single file `campuscart_database.sql`. It contains the schema, product status migration, demo user and sample products, and sold-handover backfill.
4. Check `config.php` for your MySQL settings. The default is XAMPP's `root` account with no password.
5. Visit `http://localhost/CampusCart/`. Create an account using your college email.
6. The imported database includes a demo student account and eight sample listings. Demo login: `demo@campuscart.local` / `CampusCartDemo!26`.
7. To create an administrator, register a separate account, then run `UPDATE users SET role='admin' WHERE email='your-admin-email@example.edu';` in phpMyAdmin. Sign in with that account and open `http://localhost/CampusCart/admin/`.

Product image uploads are stored in `uploads/`. Gemini description generation and help chat use deterministic local responses until `GEMINI_API_KEY` is configured in `config.php`; no AI key is required for core use.

## Included

New and edited student listings stay private with `pending review` status until an administrator approves them in `http://localhost/CampusCart/admin/review.php`. Approval publishes the product in the marketplace; rejection tells the student they can edit and resubmit. Students have a dedicated dashboard at `http://localhost/CampusCart/student/`. Administrators sign in at `http://localhost/CampusCart/admin/login.php` and use the separate console at `/admin/`. Student and admin sessions use separate cookies, so both accounts can stay signed in at once in different tabs. The admin console includes listing moderation, report review, and user role/email-verification management. Payments are arranged between students, as specified in the project synopsis.

## Notes

Set `verified=1` only after implementing your institution's email verification provider. The starter application does not claim to send verification mail. Configure HTTPS, mail delivery, backups, and a non-root database user before deploying publicly.
