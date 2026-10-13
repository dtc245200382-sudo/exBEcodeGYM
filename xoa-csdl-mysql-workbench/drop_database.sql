-- [Thuc hanh] Xoa CSDL tren MySQL Workbench
-- Cach 1 (giao dien): SCHEMAS -> chuot phai my_database
-- -> Drop Schema -> Drop Now -> Refresh de kiem tra.
-- Cach 2: Chay cau lenh SQL duoi day trong New Query Tab.
-- Luu y: DROP DATABASE xoa toan bo du lieu; sao luu truoc khi chay.

-- Kiem tra CSDL truoc khi xoa.
SHOW DATABASES LIKE 'my_database';

-- Xoa CSDL theo de bai. IF EXISTS cho phep chay lai khi CSDL da bi xoa.
DROP DATABASE IF EXISTS `my_database`;

-- Ket qua can dat: khong con dong nao tra ve.
SHOW DATABASES LIKE 'my_database';
