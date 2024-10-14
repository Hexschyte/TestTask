IF EXISTS (SELECT * FROM sys.databases WHERE name = 'TestDB')
BEGIN
    RETURN;
END

CREATE DATABASE TestDB;
PRINT 'Database TestDB created.';

CREATE table Product (
    ID uniqueidentifier PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL, 
    Description TEXT,
    CONSTRAINT UQ_Product_Name UNIQUE (Name) 
);
GO

CREATE INDEX IDX_Pr_Name ON Product (Name) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);

CREATE table ProductVersion (
    ID uniqueidentifier PRIMARY KEY,
    ProductID uniqueidentifier NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description TEXT,
    CreatingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Width INT NOT NULL,
    Height INT NOT NULL,
    Length INT NOT NULL,
    CONSTRAINT FK_ProductVersion_Product FOREIGN KEY (ProductID) REFERENCES Product(ID) ON DELETE CASCADE,
    CONSTRAINT CHK_Positive CHECK (Width > 0 AND Height > 0 AND Length > 0)
);
GO

CREATE INDEX IDX_PrVer_Name ON ProductVersion (Name) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
CREATE INDEX IDX_PrVer_CDate ON ProductVersion (CreatingDate) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
CREATE INDEX IDX_PrVer_Wdth ON ProductVersion (Width) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
CREATE INDEX IDX_PrVer_Hght ON ProductVersion (Height) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
CREATE INDEX IDX_PrVer_Lgth ON ProductVersion (Length) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO

CREATE TABLE EventLog (
    ID uniqueidentifier PRIMARY KEY, 
    EventDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Description TEXT
);

CREATE INDEX IDX_EventLog_EventDate ON EventLog (EventDate) WITH (ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON);
GO

CREATE TRIGGER trg_product_audit
ON Product
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product created: ', Name)
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product updated: ', Name)
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product deleted: ', Name)
        FROM DELETED;
    END
END
GO

CREATE TRIGGER trg_productversion_audit
ON ProductVersion
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product version created: ', Name)
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM INSERTED) AND EXISTS (SELECT * FROM DELETED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product version updated: ', Name)
        FROM INSERTED;
    END

    IF EXISTS (SELECT * FROM DELETED) AND NOT EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO EventLog (Description)
        SELECT CONCAT('Product version deleted: ', Name)
        FROM DELETED;
    END
END
GO

CREATE PROCEDURE SearchProductVersions
    @productName NVARCHAR(255),
    @versionName NVARCHAR(255),
    @minVolume INT,
    @maxVolume INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        pv.ID AS ProductVersionID,
        p.Name AS ProductName,
        pv.Name AS ProductVersionName,
        pv.Width, 
        pv.Height, 
        pv.Length,
        (pv.Width * pv.Height * pv.Length) AS Volume
    FROM ProductVersion pv
    JOIN Product p ON pv.ProductID = p.ID
    WHERE p.Name LIKE '%' + @productName + '%'
      AND pv.Name LIKE '%' + @versionName + '%'
      AND (pv.Width * pv.Height * pv.Length) BETWEEN @minVolume AND @maxVolume;
END
GO

INSERT INTO Product (ID, Name, Description)
VALUES 
(NEWID(), 'Product 1', 'Description of Product 1'),
(NEWID(), 'Product 2', 'Description of Product 2'),
(NEWID(), 'Product 3', 'Description of Product 3'),
(NEWID(), 'Product 4', 'Description of Product 4'),
(NEWID(), 'Product 5', 'Description of Product 5'),
(NEWID(), 'Product 6', 'Description of Product 6'),
(NEWID(), 'Product 7', 'Description of Product 7'),
(NEWID(), 'Product 8', 'Description of Product 8'),
(NEWID(), 'Product 9', 'Description of Product 9'),
(NEWID(), 'Product 10', 'Description of Product 10');
GO


INSERT INTO ProductVersion (ID, ProductID, Name, Description, Width, Height, Length)
VALUES
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 1'), 'Version 1.0', 'Description for Version 1.0', 10, 20, 30),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 2'), 'Version 1.1', 'Description for Version 1.1', 15, 25, 35),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 3'), 'Version 2.0', 'Description for Version 2.0', 20, 30, 40),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 4'), 'Version 2.1', 'Description for Version 2.1', 12, 22, 32),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 5'), 'Version 3.0', 'Description for Version 3.0', 25, 35, 45),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 6'), 'Version 3.1', 'Description for Version 3.1', 18, 28, 38),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 7'), 'Version 4.0', 'Description for Version 4.0', 14, 24, 34),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 8'), 'Version 4.1', 'Description for Version 4.1', 16, 26, 36),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 9'), 'Version 5.0', 'Description for Version 5.0', 22, 32, 42),
(NEWID(), (SELECT ID FROM Product WHERE Name = 'Product 10'), 'Version 5.1', 'Description for Version 5.1', 28, 38, 48);