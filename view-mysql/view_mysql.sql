-- [Thực hành] View trong MySQL
-- Dùng CSDL classicmodels đã import từ bài trước.
-- Một file chung chứa đầy đủ các bước và kết quả chạy thực tế.
USE `classicmodels`;

-- 1. Tạo view gồm mã khách hàng, tên khách hàng và điện thoại.
CREATE VIEW `customer_views` AS
SELECT `customerNumber`, `customerName`, `phone`
FROM `customers`;

-- 2. Truy vấn dữ liệu từ view.
SELECT * FROM `customer_views` ORDER BY `customerNumber`;
SELECT COUNT(*) AS `SoKhachHangTrongView` FROM `customer_views`;

-- 3. Thay đổi định nghĩa view: thêm tên người liên hệ và lọc thành phố Nantes.
CREATE OR REPLACE VIEW `customer_views` AS
SELECT `customerNumber`, `customerName`, `contactFirstName`, `contactLastName`, `phone`
FROM `customers`
WHERE `city` = 'Nantes';

SELECT * FROM `customer_views` ORDER BY `customerNumber`;
SELECT COUNT(*) AS `SoKhachHangNantes` FROM `customer_views`;
SHOW CREATE VIEW `customer_views`;

-- 4. Xoá view, không xoá bảng customers hay dữ liệu khách hàng.
DROP VIEW `customer_views`;

-- Kiểm tra: số view còn lại phải là 0; bảng customers vẫn có dữ liệu.
SELECT COUNT(*) AS `SoViewConLai`
FROM `information_schema`.`VIEWS`
WHERE `TABLE_SCHEMA` = 'classicmodels' AND `TABLE_NAME` = 'customer_views';
SELECT COUNT(*) AS `SoKhachHangSauKhiXoaView` FROM `customers`;

-- CREATE OR REPLACE VIEW thay đổi định nghĩa view, không phải UPDATE dữ liệu.
-- Sau khi chạy toàn bộ file, customer_views đã bị xoá theo bước cuối của đề.

-- KẾT QUẢ THỰC TẾ: MySQL 8.4.11, classicmodels mẫu.
-- View ban đầu: 122 khách hàng. View Nantes: 2 khách hàng (103, 119).
-- Sau DROP VIEW: 0 view customer_views; bảng customers còn 122 khách hàng.
-- Log console nguyên bản bên dưới, đặt trong comment.

/*
--------------
-- [Th?c h?nh] View trong MySQL
--------------

--------------
-- D?ng CSDL classicmodels ?? import t? b?i tr??c.
--------------

--------------
-- M?t file chung ch?a ??y ?? c?c b??c v? k?t qu? ch?y th?c t?.
--------------

--------------
-- 1. T?o view g?m m? kh?ch h?ng, t?n kh?ch h?ng v? ?i?n tho?i.
--------------

--------------
CREATE VIEW `customer_views` AS
SELECT `customerNumber`, `customerName`, `phone`
FROM `customers`
--------------

--------------
-- 2. Truy v?n d? li?u t? view.
--------------

--------------
SELECT * FROM `customer_views` ORDER BY `customerNumber`
--------------

+----------------+------------------------------------+--------------------+
| customerNumber | customerName                       | phone              |
+----------------+------------------------------------+--------------------+
|            103 | Atelier graphique                  | 40.32.2555         |
|            112 | Signal Gift Stores                 | 7025551838         |
|            114 | Australian Collectors, Co.         | 03 9520 4555       |
|            119 | La Rochelle Gifts                  | 40.67.8555         |
|            121 | Baane Mini Imports                 | 07-98 9555         |
|            124 | Mini Gifts Distributors Ltd.       | 4155551450         |
|            125 | Havel & Zbyszek Co                 | (26) 642-7555      |
|            128 | Blauer See Auto, Co.               | +49 69 66 90 2555  |
|            129 | Mini Wheels Co.                    | 6505555787         |
|            131 | Land of Toys Inc.                  | 2125557818         |
|            141 | Euro+ Shopping Channel             | (91) 555 94 44     |
|            144 | Volvo Model Replicas, Co           | 0921-12 3555       |
|            145 | Danish Wholesale Imports           | 31 12 3555         |
|            146 | Saveley & Henriot, Co.             | 78.32.5555         |
|            148 | Dragon Souveniers, Ltd.            | +65 221 7555       |
|            151 | Muscle Machine Inc                 | 2125557413         |
|            157 | Diecast Classics Inc.              | 2155551555         |
|            161 | Technics Stores Inc.               | 6505556809         |
|            166 | Handji Gifts& Co                   | +65 224 1555       |
|            167 | Herkku Gifts                       | +47 2267 3215      |
|            168 | American Souvenirs Inc             | 2035557845         |
|            169 | Porto Imports Co.                  | (1) 356-5555       |
|            171 | Daedalus Designs Imports           | 20.16.1555         |
|            172 | La Corne D'abondance, Co.          | (1) 42.34.2555     |
|            173 | Cambridge Collectables Co.         | 6175555555         |
|            175 | Gift Depot Inc.                    | 2035552570         |
|            177 | Osaka Souveniers Co.               | +81 06 6342 5555   |
|            181 | Vitachrome Inc.                    | 2125551500         |
|            186 | Toys of Finland, Co.               | 90-224 8555        |
|            187 | AV Stores, Co.                     | (171) 555-1555     |
|            189 | Clover Collections, Co.            | +353 1862 1555     |
|            198 | Auto-Moto Classics Inc.            | 6175558428         |
|            201 | UK Collectables, Ltd.              | (171) 555-2282     |
|            202 | Canadian Gift Exchange Network     | (604) 555-3392     |
|            204 | Online Mini Collectables           | 6175557555         |
|            205 | Toys4GrownUps.com                  | 6265557265         |
|            206 | Asian Shopping Network, Co         | +612 9411 1555     |
|            209 | Mini Caravy                        | 88.60.1555         |
|            211 | King Kong Collectables, Co.        | +852 2251 1555     |
|            216 | Enaco Distributors                 | (93) 203 4555      |
|            219 | Boards & Toys Co.                  | 3105552373         |
|            223 | Nat?rlich Autos                    | 0372-555188        |
|            227 | Heintze Collectables               | 86 21 3555         |
|            233 | Qu?bec Home Shopping Network       | (514) 555-8054     |
|            237 | ANG Resellers                      | (91) 745 6555      |
|            239 | Collectable Mini Designs Co.       | 7605558146         |
|            240 | giftsbymail.co.uk                  | (198) 555-8888     |
|            242 | Alpha Cognac                       | 61.77.6555         |
|            247 | Messner Shopping Network           | 069-0555984        |
|            249 | Amica Models & Co.                 | 011-4988555        |
|            250 | Lyon Souveniers                    | +33 1 46 62 7555   |
|            256 | Auto Associ?s & Cie.               | 30.59.8555         |
|            259 | Toms Spezialit?ten, Ltd            | 0221-5554327       |
|            260 | Royal Canadian Collectables, Ltd.  | (604) 555-4555     |
|            273 | Franken Gifts, Co                  | 089-0877555        |
|            276 | Anna's Decorations, Ltd            | 02 9936 8555       |
|            278 | Rovelli Gifts                      | 035-640555         |
|            282 | Souveniers And Things Co.          | +61 2 9495 8555    |
|            286 | Marta's Replicas Co.               | 6175558555         |
|            293 | BG&E Collectables                  | +41 26 425 50 01   |
|            298 | Vida Sport, Ltd                    | 0897-034555        |
|            299 | Norway Gifts By Mail, Co.          | +47 2212 1555      |
|            303 | Schuyler Imports                   | +31 20 491 9555    |
|            307 | Der Hund Imports                   | 030-0074555        |
|            311 | Oulu Toy Supplies, Inc.            | 981-443655         |
|            314 | Petit Auto                         | (02) 5554 67       |
|            319 | Mini Classics                      | 9145554562         |
|            320 | Mini Creations Ltd.                | 5085559555         |
|            321 | Corporate Gift Ideas Co.           | 6505551386         |
|            323 | Down Under Souveniers, Inc         | +64 9 312 5555     |
|            324 | Stylish Desk Decors, Co.           | (171) 555-0297     |
|            328 | Tekni Collectables Inc.            | 2015559350         |
|            333 | Australian Gift Network, Co        | 61-7-3844-6555     |
|            334 | Suominen Souveniers                | +358 9 8045 555    |
|            335 | Cramer Spezialit?ten, Ltd          | 0555-09555         |
|            339 | Classic Gift Ideas, Inc            | 2155554695         |
|            344 | CAF Imports                        | +34 913 728 555    |
|            347 | Men 'R' US Retailers, Ltd.         | 2155554369         |
|            348 | Asian Treasures, Inc.              | 2967 555           |
|            350 | Marseille Mini Autos               | 91.24.4555         |
|            353 | Reims Collectables                 | 26.47.1555         |
|            356 | SAR Distributors, Co               | +27 21 550 3555    |
|            357 | GiftsForHim.com                    | 64-9-3763555       |
|            361 | Kommission Auto                    | 0251-555259        |
|            362 | Gifts4AllAges.com                  | 6175559555         |
|            363 | Online Diecast Creations Co.       | 6035558647         |
|            369 | Lisboa Souveniers, Inc             | (1) 354-2555       |
|            376 | Precious Collectables              | 0452-076555        |
|            379 | Collectables For Less Inc.         | 6175558555         |
|            381 | Royale Belge                       | (071) 23 67 2555   |
|            382 | Salzburg Collectables              | 6562-9555          |
|            385 | Cruz & Sons Co.                    | +63 2 555 3587     |
|            386 | L'ordine Souveniers                | 0522-556555        |
|            398 | Tokyo Collectables, Ltd            | +81 3 3584 0555    |
|            406 | Auto Canal+ Petit                  | (1) 47.55.6555     |
|            409 | Stuttgart Collectable Exchange     | 0711-555361        |
|            412 | Extreme Desk Decorations, Ltd      | 04 499 9555        |
|            415 | Bavarian Collectables Imports, Co. |  +49 89 61 08 9555 |
|            424 | Classic Legends Inc.               | 2125558493         |
|            443 | Feuer Online Stores, Inc           | 0342-555176        |
|            447 | Gift Ideas Corp.                   | 2035554407         |
|            448 | Scandinavian Gift Ideas            | 0695-34 6555       |
|            450 | The Sharp Gifts Warehouse          | 4085553659         |
|            452 | Mini Auto Werke                    | 7675-3555          |
|            455 | Super Scale Inc.                   | 2035559545         |
|            456 | Microscale Inc.                    | 2125551957         |
|            458 | Corrida Auto Replicas, Ltd         | (91) 555 22 82     |
|            459 | Warburg Exchange                   | 0241-039123        |
|            462 | FunGiftIdeas.com                   | 5085552555         |
|            465 | Anton Designs, Ltd.                | +34 913 728555     |
|            471 | Australian Collectables, Ltd       | 61-9-3844-6555     |
|            473 | Frau da Collezione                 | +39 022515555      |
|            475 | West Coast Collectables Co.        | 3105553722         |
|            477 | Mit Vergn?gen & Co.                | 0621-08555         |
|            480 | Kremlin Collectables, Co.          | +7 812 293 0521    |
|            481 | Raanan Stores, Inc                 | + 972 9 959 8555   |
|            484 | Iberia Gift Imports, Corp.         | (95) 555 82 82     |
|            486 | Motor Mint Distributors Inc.       | 2155559857         |
|            487 | Signal Collectibles Ltd.           | 4155554312         |
|            489 | Double Decker Gift Stores, Ltd     | (171) 555-7555     |
|            495 | Diecast Collectables               | 6175552555         |
|            496 | Kelly's Gift Shop                  | +64 9 5555500      |
+----------------+------------------------------------+--------------------+
--------------
SELECT COUNT(*) AS `SoKhachHangTrongView` FROM `customer_views`
--------------

+----------------------+
| SoKhachHangTrongView |
+----------------------+
|                  122 |
+----------------------+
--------------
-- 3. Thay ??i ??nh ngh?a view: th?m t?n ng??i li?n h? v? l?c th?nh ph? Nantes.
--------------

--------------
CREATE OR REPLACE VIEW `customer_views` AS
SELECT `customerNumber`, `customerName`, `contactFirstName`, `contactLastName`, `phone`
FROM `customers`
WHERE `city` = 'Nantes'
--------------

--------------
SELECT * FROM `customer_views` ORDER BY `customerNumber`
--------------

+----------------+-------------------+------------------+-----------------+------------+
| customerNumber | customerName      | contactFirstName | contactLastName | phone      |
+----------------+-------------------+------------------+-----------------+------------+
|            103 | Atelier graphique | Carine           | Schmitt         | 40.32.2555 |
|            119 | La Rochelle Gifts | Janine           | Labrune         | 40.67.8555 |
+----------------+-------------------+------------------+-----------------+------------+
--------------
SELECT COUNT(*) AS `SoKhachHangNantes` FROM `customer_views`
--------------

+-------------------+
| SoKhachHangNantes |
+-------------------+
|                 2 |
+-------------------+
--------------
SHOW CREATE VIEW `customer_views`
--------------

+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
| View           | Create View                                                                                                                                                                                                                                                                                                                                                                                            | character_set_client | collation_connection |
+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
| customer_views | CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `customer_views` AS select `customers`.`customerNumber` AS `customerNumber`,`customers`.`customerName` AS `customerName`,`customers`.`contactFirstName` AS `contactFirstName`,`customers`.`contactLastName` AS `contactLastName`,`customers`.`phone` AS `phone` from `customers` where (`customers`.`city` = 'Nantes') | utf8mb4              | utf8mb4_0900_ai_ci   |
+----------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
--------------
-- 4. Xo? view, kh?ng xo? b?ng customers hay d? li?u kh?ch h?ng.
--------------

--------------
DROP VIEW `customer_views`
--------------

--------------
-- Ki?m tra: s? view c?n l?i ph?i l? 0; b?ng customers v?n c? d? li?u.
--------------

--------------
SELECT COUNT(*) AS `SoViewConLai`
FROM `information_schema`.`VIEWS`
WHERE `TABLE_SCHEMA` = 'classicmodels' AND `TABLE_NAME` = 'customer_views'
--------------

+--------------+
| SoViewConLai |
+--------------+
|            0 |
+--------------+
--------------
SELECT COUNT(*) AS `SoKhachHangSauKhiXoaView` FROM `customers`
--------------

+--------------------------+
| SoKhachHangSauKhiXoaView |
+--------------------------+
|                      122 |
+--------------------------+
--------------
-- CREATE OR REPLACE VIEW thay ??i ??nh ngh?a view, kh?ng ph?i UPDATE d? li?u.
--------------

--------------
-- Sau khi ch?y to?n b? file, customer_views ?? b? xo? theo b??c cu?i c?a ??.
--------------


*/