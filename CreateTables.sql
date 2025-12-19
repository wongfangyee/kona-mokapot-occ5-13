-- =========================
-- KONA MOKAPOT COFFEE DB
-- =========================

-- member 1: database definition (DDL)
-- DROP TABLES (for reset) 
DROP TABLE OrderItem CASCADE CONSTRAINTS;
DROP TABLE CustomerOrder CASCADE CONSTRAINTS;
DROP TABLE MenuIngredient CASCADE CONSTRAINTS;
DROP TABLE MenuItem CASCADE CONSTRAINTS;
DROP TABLE Payment CASCADE CONSTRAINTS;
DROP TABLE StaffAttendance CASCADE CONSTRAINTS;
DROP TABLE Staff CASCADE CONSTRAINTS;
DROP TABLE Ingredient CASCADE CONSTRAINTS;
DROP TABLE Supplier CASCADE CONSTRAINTS;
DROP TABLE MenuCategory CASCADE CONSTRAINTS;

-- create table
-- 1. Menu Category
CREATE TABLE MenuCategory (
    CategoryID NUMBER PRIMARY KEY,
    CategoryName VARCHAR2(50) NOT NULL
);

-- 2. Supplier
CREATE TABLE Supplier (
    SupplierID NUMBER PRIMARY KEY,
    SupplierName VARCHAR2(50) NOT NULL,
    SupplierContact VARCHAR2(15),
    SupplierAddress VARCHAR2(100)
);

-- 3. Ingredient
CREATE TABLE Ingredient (
    IngredientID NUMBER PRIMARY KEY,
    IngredientName VARCHAR2(50) NOT NULL,
    StockLevel NUMBER DEFAULT 0 CHECK (StockLevel >= 0),
    Unit VARCHAR2(10),
    SupplierID NUMBER NOT NULL,
    CONSTRAINT fk_ingredient_supplier
        FOREIGN KEY (SupplierID)
        REFERENCES Supplier(SupplierID)
);

-- 4. Staff
CREATE TABLE Staff (
    StaffID NUMBER PRIMARY KEY,
    StaffName VARCHAR2(50) NOT NULL,
    StaffRole VARCHAR2(20) NOT NULL,
    StaffContact VARCHAR2(15)
);

-- 5. Staff Attendance (1:M)
CREATE TABLE StaffAttendance (
    AttendanceID NUMBER PRIMARY KEY,
    StaffID NUMBER NOT NULL,
    ClockInTime TIMESTAMP NOT NULL,
    ClockOutTime TIMESTAMP,
    CONSTRAINT fk_attendance_staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);

-- 6. Payment
CREATE TABLE Payment (
    PaymentID NUMBER PRIMARY KEY,
    PaymentMethod VARCHAR2(20) NOT NULL,
    PaymentAmount NUMBER NOT NULL CHECK (PaymentAmount > 0)
);

-- 7. Menu Item
CREATE TABLE MenuItem (
    MenuID NUMBER PRIMARY KEY,
    FoodName VARCHAR2(50) NOT NULL,
    FoodPrice NUMBER NOT NULL CHECK (FoodPrice > 0),
    CategoryID NUMBER NOT NULL,
    CONSTRAINT fk_menu_category
        FOREIGN KEY (CategoryID)
        REFERENCES MenuCategory(CategoryID)
);

-- 8. Menu ↔ Ingredient (M:N)
CREATE TABLE MenuIngredient (
    MenuID NUMBER NOT NULL,
    IngredientID NUMBER NOT NULL,
    UsageAmount NUMBER NOT NULL CHECK (UsageAmount > 0),
    PRIMARY KEY (MenuID, IngredientID),
    CONSTRAINT fk_menuingredient_menu
        FOREIGN KEY (MenuID)
        REFERENCES MenuItem(MenuID),
    CONSTRAINT fk_menuingredient_ingredient
        FOREIGN KEY (IngredientID)
        REFERENCES Ingredient(IngredientID)
);

-- 9. Customer Order
CREATE TABLE CustomerOrder (
    OrderID NUMBER PRIMARY KEY,
    OrderDateTime TIMESTAMP NOT NULL,
    StaffID NUMBER NOT NULL,
    PaymentID NUMBER NOT NULL,
    CONSTRAINT fk_order_staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID),
    CONSTRAINT fk_order_payment
        FOREIGN KEY (PaymentID)
        REFERENCES Payment(PaymentID)
);

-- 10. Order Item
CREATE TABLE OrderItem (
    OrderID NUMBER NOT NULL,
    MenuID NUMBER NOT NULL,
    Quantity NUMBER NOT NULL CHECK (Quantity > 0),
    PRIMARY KEY (OrderID, MenuID),
    CONSTRAINT fk_orderitem_order
        FOREIGN KEY (OrderID)
        REFERENCES CustomerOrder(OrderID),
    CONSTRAINT fk_orderitem_menu
        FOREIGN KEY (MenuID)
        REFERENCES MenuItem(MenuID)
);

COMMIT;

-- member 2: data manipulation(DML)
--insert data 
INSERT INTO MenuCategory VALUES (1, 'Coffee');
INSERT INTO MenuCategory VALUES (2, 'Pastry');

INSERT INTO Supplier VALUES (1, 'Local Beans Co', '0123456789', 'Johor');
INSERT INTO Ingredient VALUES (1, 'Coffee Beans', 50, 'kg', 1);

INSERT INTO Staff VALUES (1, 'Aina', 'Barista', '0192233445');

INSERT INTO Payment VALUES (1, 'Cash', 15.00);

INSERT INTO MenuItem VALUES (1, 'Latte', 7.50, 1);

INSERT INTO MenuIngredient VALUES (1, 1, 0.02);

INSERT INTO CustomerOrder VALUES (1, SYSTIMESTAMP, 1, 1);

INSERT INTO OrderItem VALUES (1, 1, 2);

COMMIT;

--update
UPDATE Ingredient
SET StockLevel = StockLevel - 5
WHERE IngredientID = 1;

--delete
DELETE FROM MenuItem
WHERE MenuID = 1;

--member 3: join operations
--join
SELECT o.OrderID, s.StaffName, m.FoodName, oi.Quantity
FROM CustomerOrder o
JOIN Staff s ON o.StaffID = s.StaffID
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN MenuItem m ON oi.MenuID = m.MenuID;

--member 4: aggregate and group functions
--aggregate
SELECT COUNT(OrderID) AS TotalOrders
FROM CustomerOrder;

SELECT SUM(PaymentAmount) AS TotalSales
FROM Payment;


--member 5: queries & testing
--nested query
SELECT FoodName
FROM MenuItem
WHERE MenuID IN (
    SELECT MenuID
    FROM OrderItem
    GROUP BY MenuID
    HAVING SUM(Quantity) > 1
);
