-- Relational Schema Design for E-Commerce Transact Server

-- 1. Customers Master Table (Dimension Layer)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Country VARCHAR(50) NOT NULL,
    CreatedDate DATE NOT NULL
);

-- Indexing for geographic reporting optimization
CREATE INDEX idx_customers_country ON Customers(Country);

-- 2. Products Master Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_Stock CHECK (StockQuantity >= 0)
);

-- Index on Category for fast filtering during analytical queries
CREATE INDEX idx_products_category ON Products(Category);

-- 3. Transactional Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(12, 2) NOT NULL,
    Status VARCHAR(20) NOT NULL, -- Values = {Completed, Pending, Processing, Cancelled}
    CONSTRAINT chk_Amount CHECK (TotalAmount >= 0)
);

-- Partition-friendly index strategy for high volume analytical ingestion clusters
CREATE INDEX idx_orders_date ON Orders(OrderDate);

-- 4. Dependent Order Items Table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Index to Optimize join performance for heavy ingestion workloads
CREATE INDEX idx_orderitems_order ON OrderItems(OrderID);
