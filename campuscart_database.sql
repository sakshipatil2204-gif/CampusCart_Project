-- CampusCart unified database setup
-- Import this file in phpMyAdmin or run it with the MySQL client.
-- Includes current schema, compatibility migration, demo seed data, and sold-handover backfill.
--

-- ============================================================
-- Source section: schema.sql
-- ============================================================
CREATE DATABASE IF NOT EXISTS campuscart CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campuscart;

CREATE TABLE IF NOT EXISTS users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL,
 email VARCHAR(190) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
 college VARCHAR(150) NOT NULL DEFAULT '', bio VARCHAR(500) NOT NULL DEFAULT '',
 role ENUM('student','admin') NOT NULL DEFAULT 'student', verified TINYINT(1) NOT NULL DEFAULT 0,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS products (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, seller_id INT UNSIGNED NOT NULL,
 title VARCHAR(140) NOT NULL, description TEXT NOT NULL, category VARCHAR(60) NOT NULL,
 item_condition VARCHAR(40) NOT NULL, age VARCHAR(50) NOT NULL DEFAULT '', price DECIMAL(10,2) NOT NULL DEFAULT 0,
 listing_type ENUM('sale','exchange','free') NOT NULL DEFAULT 'sale', image VARCHAR(255) DEFAULT NULL,
 status ENUM('pending_review','available','reserved','sold','removed','rejected') NOT NULL DEFAULT 'pending_review', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(seller_id) REFERENCES users(id) ON DELETE CASCADE, INDEX(status,category), INDEX(title)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS wishlists (user_id INT UNSIGNED NOT NULL, product_id INT UNSIGNED NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(user_id,product_id), FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS conversations (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, product_id INT UNSIGNED NOT NULL, buyer_id INT UNSIGNED NOT NULL, seller_id INT UNSIGNED NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY(product_id,buyer_id), FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE, FOREIGN KEY(buyer_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(seller_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS messages (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, conversation_id INT UNSIGNED NOT NULL, sender_id INT UNSIGNED NOT NULL, body VARCHAR(2000) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(conversation_id) REFERENCES conversations(id) ON DELETE CASCADE, FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS offers (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, product_id INT UNSIGNED NOT NULL, buyer_id INT UNSIGNED NOT NULL, seller_id INT UNSIGNED NOT NULL, amount DECIMAL(10,2) NOT NULL, message VARCHAR(500) NOT NULL DEFAULT '', status ENUM('pending','accepted','rejected','withdrawn') NOT NULL DEFAULT 'pending', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE, FOREIGN KEY(buyer_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(seller_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS transactions (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, product_id INT UNSIGNED NOT NULL, buyer_id INT UNSIGNED NOT NULL, seller_id INT UNSIGNED NOT NULL, offer_id INT UNSIGNED DEFAULT NULL, status ENUM('arranging','completed','cancelled') NOT NULL DEFAULT 'arranging', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(product_id) REFERENCES products(id), FOREIGN KEY(buyer_id) REFERENCES users(id), FOREIGN KEY(seller_id) REFERENCES users(id), FOREIGN KEY(offer_id) REFERENCES offers(id) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS reviews (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, transaction_id INT UNSIGNED NOT NULL, reviewer_id INT UNSIGNED NOT NULL, seller_id INT UNSIGNED NOT NULL, rating TINYINT UNSIGNED NOT NULL, body VARCHAR(1000) NOT NULL DEFAULT '', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, UNIQUE KEY(transaction_id,reviewer_id), FOREIGN KEY(transaction_id) REFERENCES transactions(id) ON DELETE CASCADE, FOREIGN KEY(reviewer_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(seller_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS reports (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, reporter_id INT UNSIGNED NOT NULL, product_id INT UNSIGNED DEFAULT NULL, user_id INT UNSIGNED DEFAULT NULL, reason VARCHAR(500) NOT NULL, status ENUM('open','reviewed','dismissed') NOT NULL DEFAULT 'open', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(reporter_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS notifications (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id INT UNSIGNED NOT NULL, body VARCHAR(500) NOT NULL, link VARCHAR(255) DEFAULT NULL, is_read TINYINT(1) NOT NULL DEFAULT 0, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS saved_searches (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id INT UNSIGNED NOT NULL, query VARCHAR(150) NOT NULL, category VARCHAR(60) NOT NULL DEFAULT '', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;


-- ============================================================
-- Source section: migration_product_review.sql
-- ============================================================
USE campuscart;
ALTER TABLE products
  MODIFY status ENUM('pending_review','available','reserved','sold','removed','rejected')
  NOT NULL DEFAULT 'pending_review';


-- ============================================================
-- Source section: seed_products.sql
-- ============================================================
-- Import after schema.sql to add a local demo seller and sample listings.
-- Demo login: demo@campuscart.local / CampusCartDemo!26
-- Change the demo password before exposing the site beyond your own machine.
USE campuscart;
INSERT INTO users (name,email,password_hash,college,role,verified)
VALUES ('CampusCart Demo','demo@campuscart.local','$2y$10$S80ID4dF.kX1VHk.Q6XlzeXKBmUNbj8LT51McADfhavseKGAHoR3G','CampusCart Demo College','student',1)
ON DUPLICATE KEY UPDATE email=VALUES(email);
INSERT INTO products (seller_id,title,description,category,item_condition,age,price,listing_type)
SELECT seller.id, sample.title, sample.description, sample.category, sample.item_condition, sample.age, sample.price, sample.listing_type
FROM (SELECT id FROM users WHERE email='demo@campuscart.local' LIMIT 1) AS seller
CROSS JOIN (
 SELECT 'Calculus: Early Transcendentals' title,'A clean copy with light notes in the first two chapters. All pages are intact and ready for the next semester.' description,'Textbooks' category,'Good' item_condition,'One year' age,420 price,'sale' listing_type
 UNION ALL SELECT 'Casio scientific calculator','Reliable scientific calculator with a clear display and working buttons. Great for engineering and science courses.','Calculators','Good','Two semesters',550,'sale'
 UNION ALL SELECT 'Desk lamp with warm light','Compact study lamp with adjustable neck. Works well and fits easily on a dorm desk.','Electronics','Like new','Six months',350,'sale'
 UNION ALL SELECT 'A4 ruled notebooks (3)','Three unused notebooks from last term. Passing them on together to another student.','Stationery','Like new','New',90,'sale'
 UNION ALL SELECT 'Campus cycle helmet','Lightweight bicycle helmet with adjustable straps. No cracks; inner padding is clean.','Bicycles','Good','One year',300,'sale'
 UNION ALL SELECT 'Exam preparation flashcards','A set of blank revision cards with a small ring binder. Useful for quick study notes.','Stationery','Good','One semester',0,'free'
 UNION ALL SELECT 'Bluetooth headphones','Over-ear headphones with a comfortable fit and solid battery life. Includes charging cable.','Electronics','Fair','Two years',700,'sale'
 UNION ALL SELECT 'Graphic design textbook — swap','A useful design fundamentals book. Happy to exchange for a beginner photography or typography book.','Textbooks','Good','One year',0,'exchange'
) AS sample
WHERE NOT EXISTS (SELECT 1 FROM products existing WHERE existing.seller_id=seller.id AND existing.title=sample.title);
UPDATE products
SET status='available'
WHERE seller_id=(SELECT id FROM users WHERE email='demo@campuscart.local' LIMIT 1)
  AND title IN ('Calculus: Early Transcendentals','Casio scientific calculator','Desk lamp with warm light','A4 ruled notebooks (3)','Campus cycle helmet','Exam preparation flashcards','Bluetooth headphones','Graphic design textbook — swap');


-- ============================================================
-- Source section: migration_sold_handovers.sql
-- ============================================================
USE campuscart;

-- Backfill a handover for previously sold listings that have a buyer conversation.
-- Select the most recent interested buyer when multiple conversations exist.
INSERT INTO transactions (product_id, buyer_id, seller_id, offer_id, status, created_at)
SELECT p.id,
       (SELECT c.buyer_id
          FROM conversations c
         WHERE c.product_id = p.id AND c.seller_id = p.seller_id
         ORDER BY c.created_at DESC, c.id DESC
         LIMIT 1),
       p.seller_id,
       NULL,
       'arranging',
       CURRENT_TIMESTAMP
  FROM products p
 WHERE p.status = 'sold'
   AND EXISTS (SELECT 1 FROM conversations c WHERE c.product_id = p.id AND c.seller_id = p.seller_id)
   AND NOT EXISTS (SELECT 1 FROM transactions t WHERE t.product_id = p.id);

