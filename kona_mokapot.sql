-- =========================================
-- KONA MOKAPOT COFFEE DB
-- =========================================

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

-- =========================================
-- MEMBER 2: DATA MANIPULATION (DML) - NG QI XUAN
-- =========================================

-- 1. Insert Sample Data
INSERT INTO MenuCategory VALUES (1, 'Coffee');
INSERT INTO MenuCategory VALUES (2, 'Pastry');
INSERT INTO MenuCategory VALUES (3, 'Tea');
INSERT INTO MenuCategory VALUES (4, 'Seasonal');
INSERT INTO MenuCategory VALUES (5, 'Merchandise');
INSERT INTO MenuCategory VALUES (6, 'Sides');

INSERT INTO Supplier VALUES (1, 'Local Beans Co', '0123456789', 'Kuala Lumpur');
INSERT INTO Supplier VALUES (2, 'Dairy Fresh', '0139988776', 'Selangor');
INSERT INTO Supplier VALUES (3, 'Baker’s Delight', '0175544332', 'Kuala Lumpur');
INSERT INTO Supplier VALUES (4, 'Global Roasters', '0112233445', 'Selangor');
INSERT INTO Supplier VALUES (5, 'Paper & Co', '0199988776', 'Selangor');

INSERT INTO Ingredient VALUES (1, 'Coffee Beans', 50, 'kg', 1);
INSERT INTO Ingredient VALUES (2, 'Milk', 100, 'Liters', 2);
INSERT INTO Ingredient VALUES (3, 'Sugar', 20, 'kg', 1);
INSERT INTO Ingredient VALUES (4, 'Flour', 30, 'kg', 3);

INSERT INTO Staff VALUES (1, 'Aina', 'Barista', '0192233445');
INSERT INTO Staff VALUES (2, 'Zul', 'Manager', '0112233445');
INSERT INTO Staff VALUES (3, 'Raju', 'Cleaner', '0165544332');
INSERT INTO Staff VALUES (4, 'Siti', 'Barista', '0188877665');
INSERT INTO Staff VALUES (5, 'Wei Kang', 'Barista', '0171122334');
INSERT INTO Staff VALUES (6, 'Fatimah', 'Supervisor', '0125566778');
INSERT INTO Staff VALUES (7, 'Kevin', 'Part-timer', '0134455667');

-- Attendance logic based on 2 shifts (8am-4pm-12:30am)
INSERT INTO StaffAttendance VALUES (1, 1, TO_TIMESTAMP('2023-11-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO StaffAttendance VALUES (2, 3, TO_TIMESTAMP('2023-11-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-02 00:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO StaffAttendance VALUES (3, 2, TO_TIMESTAMP('2023-11-02 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO StaffAttendance VALUES (4, 5, TO_TIMESTAMP('2023-11-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-03 00:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO StaffAttendance VALUES (5, 7, TO_TIMESTAMP('2023-11-03 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-03 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Payment VALUES (1, 'Cash', 15.00);
INSERT INTO Payment VALUES (2, 'E-Wallet', 19.50);
INSERT INTO Payment VALUES (3, 'Credit Card', 8.00);
INSERT INTO Payment VALUES (4, 'Cash', 25.50);
INSERT INTO Payment VALUES (5, 'GrabPay', 12.50);
INSERT INTO Payment VALUES (6, 'Debit Card', 45.00);
INSERT INTO Payment VALUES (7, 'TNG eWallet', 22.00);
INSERT INTO Payment VALUES (8, 'Cash', 6.00);

INSERT INTO MenuItem VALUES (1, 'Latte', 7.50, 1);
INSERT INTO MenuItem VALUES (2, 'Cappuccino', 9.50, 1);
INSERT INTO MenuItem VALUES (3, 'Iced Peach Tea', 10.00, 3);
INSERT INTO MenuItem VALUES (4, 'Chocolate Muffin', 8.00, 2);
INSERT INTO MenuItem VALUES (5, 'Caramel Macchiato', 12.50, 1);
INSERT INTO MenuItem VALUES (6, 'Matcha Latte', 11.00, 3);
INSERT INTO MenuItem VALUES (7, 'Hot Chocolate', 9.00, 1);
INSERT INTO MenuItem VALUES (8, 'Mokapot Tumbler', 45.00, 5);
INSERT INTO MenuItem VALUES (9, 'Garlic Bread', 6.00, 6);

INSERT INTO MenuIngredient VALUES (1, 1, 0.02);
INSERT INTO MenuIngredient VALUES (2, 1, 0.02);
INSERT INTO MenuIngredient VALUES (2, 2, 0.20);
INSERT INTO MenuIngredient VALUES (5, 7, 0.05); 
INSERT INTO MenuIngredient VALUES (6, 6, 0.01); 
INSERT INTO MenuIngredient VALUES (7, 8, 0.02);

INSERT INTO CustomerOrder VALUES (1, SYSTIMESTAMP, 1, 1);
INSERT INTO CustomerOrder VALUES (2, SYSTIMESTAMP - INTERVAL '1' HOUR, 3, 2);
INSERT INTO CustomerOrder VALUES (3, SYSTIMESTAMP - INTERVAL '2' HOUR, 1, 3);
INSERT INTO CustomerOrder VALUES (4, SYSTIMESTAMP - INTERVAL '30' MINUTE, 3, 4);
INSERT INTO CustomerOrder VALUES (5, SYSTIMESTAMP - INTERVAL '1' DAY, 5, 5);
INSERT INTO CustomerOrder VALUES (6, SYSTIMESTAMP - INTERVAL '1' DAY, 2, 6);
INSERT INTO CustomerOrder VALUES (7, SYSTIMESTAMP - INTERVAL '5' HOUR, 1, 7);
INSERT INTO CustomerOrder VALUES (8, SYSTIMESTAMP - INTERVAL '10' MINUTE, 6, 8);

INSERT INTO OrderItem VALUES (1, 1, 2);
INSERT INTO OrderItem VALUES (2, 2, 1);
INSERT INTO OrderItem VALUES (2, 3, 1);
INSERT INTO OrderItem VALUES (3, 4, 1);
INSERT INTO OrderItem VALUES (4, 1, 3);
INSERT INTO OrderItem VALUES (5, 5, 1);
INSERT INTO OrderItem VALUES (6, 8, 1); 
INSERT INTO OrderItem VALUES (7, 6, 2); 
INSERT INTO OrderItem VALUES (8, 9, 1);

COMMIT;

-- 2. Update stock based on MySyarikat invoice arrivals
UPDATE Ingredient 
SET StockLevel = StockLevel + 50 
WHERE IngredientName = 'Coffee Beans';

-- End-of-day stock adjustment for perishables (Milk)
UPDATE Ingredient 
SET StockLevel = StockLevel - 10 
WHERE IngredientID = 2;

COMMIT;

-- 3. Deletions (Removing non-essential staff or contracts)
DELETE FROM Staff WHERE StaffID = 4;

COMMIT;


-- member 3: join operations
-- [Completed by Ivan Ooi Jian Chao]
SELECT 
    o.OrderID,
    o.OrderDateTime,
    s.StaffName,
    m.FoodName,
    oi.Quantity,
    m.FoodPrice,
    (oi.Quantity * m.FoodPrice) AS ItemTotal
FROM CustomerOrder o
JOIN Staff s ON o.StaffID = s.StaffID
JOIN OrderItem oi ON o.OrderID = oi.OrderID
JOIN MenuItem m ON oi.MenuID = m.MenuID
ORDER BY o.OrderID;

SELECT 
    s.StaffID,
    s.StaffName,
    COUNT(o.OrderID) AS TotalOrdersHandled,
    SUM(p.PaymentAmount) AS TotalSalesHandled
FROM Staff s
JOIN CustomerOrder o ON s.StaffID = o.StaffID
JOIN Payment p ON o.PaymentID = p.PaymentID
GROUP BY s.StaffID, s.StaffName
ORDER BY TotalSalesHandled DESC;

SELECT 
    m.MenuID,
    m.FoodName,
    c.CategoryName,
    SUM(oi.Quantity) AS TotalQuantitySold
FROM MenuItem m
JOIN OrderItem oi ON m.MenuID = oi.MenuID
JOIN MenuCategory c ON m.CategoryID = c.CategoryID
GROUP BY m.MenuID, m.FoodName, c.CategoryName
ORDER BY TotalQuantitySold DESC;

-- member 4: aggregate and group functions
-- [To be completed by Member 4]
SELECT COUNT(OrderID) AS TotalOrders
FROM CustomerOrder;

SELECT SUM(PaymentAmount) AS TotalSales
FROM Payment;


-- member 5: queries & testing
-- [To be completed by Member 5]
SELECT FoodName
FROM MenuItem
WHERE MenuID IN (
    SELECT MenuID
    FROM OrderItem
    GROUP BY MenuID
    HAVING SUM(Quantity) > 1
);



