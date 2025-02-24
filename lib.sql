-- Library Management System SQL Project

-- 1. Create Database
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- 2. Create Tables

-- Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    Address TEXT
);

-- Books Table
CREATE TABLE Books (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(100) NOT NULL,
    Publisher VARCHAR(100),
    YearPublished YEAR,
    ISBN VARCHAR(20) UNIQUE,
    AvailableCopies INT DEFAULT 1
);

-- Borrowing Records Table
CREATE TABLE BorrowingRecords (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    BookID INT,
    BorrowDate DATE DEFAULT CURRENT_DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- 3. Insert Sample Data

INSERT INTO Users (Name, Email, Phone, Address) VALUES
('Alice Johnson', 'alice@example.com', '1234567890', '123 Main St'),
('Bob Smith', 'bob@example.com', '9876543210', '456 Elm St');

INSERT INTO Books (Title, Author, Publisher, YearPublished, ISBN, AvailableCopies) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', 1925, '9780743273565', 5),
('To Kill a Mockingbird', 'Harper Lee', 'J.B. Lippincott & Co.', 1960, '9780061120084', 3);

-- 4. Borrow Book Procedure
DELIMITER //
CREATE PROCEDURE BorrowBook(IN userID INT, IN bookID INT)
BEGIN
    DECLARE available INT;
    SELECT AvailableCopies INTO available FROM Books WHERE BookID = bookID;
    IF available > 0 THEN
        INSERT INTO BorrowingRecords (UserID, BookID, DueDate) VALUES (userID, bookID, DATE_ADD(CURDATE(), INTERVAL 14 DAY));
        UPDATE Books SET AvailableCopies = AvailableCopies - 1 WHERE BookID = bookID;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies available';
    END IF;
END //
DELIMITER ;

-- 5. Return Book Procedure
DELIMITER //
CREATE PROCEDURE ReturnBook(IN recordID INT)
BEGIN
    DECLARE bookID INT;
    SELECT BookID INTO bookID FROM BorrowingRecords WHERE RecordID = recordID;
    UPDATE BorrowingRecords SET ReturnDate = CURDATE() WHERE RecordID = recordID;
    UPDATE Books SET AvailableCopies = AvailableCopies + 1 WHERE BookID = bookID;
END //
DELIMITER ;

-- 6. Query to Get Borrowed Books
SELECT Users.Name, Books.Title, BorrowingRecords.BorrowDate, BorrowingRecords.DueDate, BorrowingRecords.ReturnDate
FROM BorrowingRecords
JOIN Users ON BorrowingRecords.UserID = Users.UserID
JOIN Books ON BorrowingRecords.BookID = Books.BookID
WHERE BorrowingRecords.ReturnDate IS NULL;
