-- Part 1: Querying the World and Chinook Databases
-- World Database

-- Easy
-- 1. List all countries in South America.
	SELECT Name
	FROM country
	WHERE Continent = 'South America';

-- 2. Find the population of ‘Germany’.
	SELECT Population
	FROM country
	WHERE Name = 'Germany';

-- 3. Retrieve all cities in the country ‘Japan’.
	SELECT Name
	FROM city
	WHERE CountryCode = (SELECT Code FROM country WHERE Name = 'Japan');

-- Medium
-- 4. Find the 3 most populated countries in the ‘Africa’ region.
	SELECT Name
	FROM country
	WHERE Continent = 'Africa'
	ORDER BY Population DESC LIMIT 3;

-- 5. Retrieve the country and its life expectancy where the population is between 1 and 5 million.
	SELECT Name, LifeExpectancy
	FROM country
	WHERE Population BETWEEN 1000000 AND 5000000;

-- 6. List countries with an official language of ‘French’.
	SELECT c.Name
	FROM country c
	JOIN countrylanguage cl ON c.Code = cl.CountryCode
	WHERE cl.language = 'French' AND cl.IsOfficial = 'T';


-- Chinook Database
-- Easy
-- 7. Retrieve all album titles by the artist ‘AC/DC’
	SELECT al.Title
	FROM Album al
	JOIN Artist ar ON al.ArtistId = ar.ArtistId
	WHERE ar.Name = 'AC/DC';

-- 8. Find the name and email of customers located in ‘Brazil’
	SELECT FirstName, LastName, Email
	FROM Customer
	WHERE Country = 'Brazil';

-- 9. List all playlists in the dataset
	SELECT Name
	FROM Playlist;

-- Medium
-- 10. Find the total number of tracks in the ‘Rock’ genre.
	SELECT COUNT(*) AS TotalTracks
	FROM Track t
	JOIN Genre g ON t.GenreId = g.GenreId
	WHERE g.Name = 'Rock';

-- 11. List all employees who report to ‘Nancy Edwards’.
	SELECT e.FirstName, e.LastName
	FROM Employee e
	JOIN Employee m ON e.ReportsTo = m.EmployeeId
	WHERE m.FirstName = 'Nancy' AND m.LastName = 'Edwards';

-- 12. Calculate the total sales per customer by summing the total amount of invoices.
	SELECT c.FirstName, c.LastName, SUM(i.Total) AS TotalSales
	FROM Customer c
	JOIN Invoice i ON c.CustomerId = i.CustomerId
	GROUP BY c.CustomerId, c.FirstName, c.LastName
	ORDER BY TotalSales DESC;



-- Part 2: Create Your Own Database

-- 1. Design Your Database
	-- Create the database
	CREATE DATABASE books_and_booze;
	-- Use the database
	USE books_and_booze;

-- 2. Create the Tables
	-- Create the Books table
	CREATE TABLE Books (
		BookID INT PRIMARY KEY AUTO_INCREMENT,
		Title VARCHAR(100) NOT NULL,
		Author VARCHAR(100) NOT NULL,
		PublicationYear YEAR NOT NULL
	);

	-- Create the Wines table
	CREATE TABLE Wines (
		WineID INT PRIMARY KEY AUTO_INCREMENT,
		Name VARCHAR(100) NOT NULL,
		Variety VARCHAR(50) NOT NULL,
		Vintage YEAR NOT NULL
	);

	-- Create the BookPrices table to track book price history
	CREATE TABLE BookPrices (
		BookPriceID INT PRIMARY KEY AUTO_INCREMENT,
		BookID INT,
		Price DECIMAL(10, 2) NOT NULL,
		EffectiveDate DATE NOT NULL,
		FOREIGN KEY (BookID) REFERENCES Books(BookID)
	);

	-- Create the WinePrices table to track wine price history
	CREATE TABLE WinePrices (
		WinePriceID INT PRIMARY KEY AUTO_INCREMENT,
		WineID INT,
		Price DECIMAL(10, 2) NOT NULL,
		EffectiveDate DATE NOT NULL,
		FOREIGN KEY (WineID) REFERENCES Wines(WineID)
	);

	-- Create the Orders table (TotalPrice based on quantity and product price at time of order)
	CREATE TABLE Orders (
		OrderID INT PRIMARY KEY AUTO_INCREMENT,
		OrderDate DATE NOT NULL,
		BookID INT,
		WineID INT,
		Quantity INT NOT NULL,
		TotalPrice DECIMAL(10, 2) NOT NULL,
		FOREIGN KEY (BookID) REFERENCES Books(BookID),
		FOREIGN KEY (WineID) REFERENCES Wines(WineID)
	);

-- 3. Insert Data

	-- Insert data into Books table
	INSERT INTO Books (Title, Author, PublicationYear) VALUES
	('The Book Thief', 'Markus Zusak', 2007),
	('Blue Sisters', 'Coco Mellors', 2024),
	('Lets Not Do That Again', 'Grant Ginder', 2022),
	('Hell and Other Destinations', 'Madeleine Albright', 2020),
	('One Day', 'David Nicholls', 2010);

	-- Insert data into Wines table
	INSERT INTO Wines (Name, Variety, Vintage) VALUES
	('Chardonnay', 'White', 2020),
	('Merlot', 'Red', 2018),
	('Cabernet Sauvignon', 'Red', 2019),
	('Pinot Noir', 'Red', 2021),
	('Sauvignon Blanc', 'White', 2022);

	-- Insert data into BookPrices table
	INSERT INTO BookPrices (BookID, Price, EffectiveDate) VALUES
	(1, 7.50, '2024-01-01'),
	(2, 24.00, '2024-01-01'),
	(3, 12.50, '2024-01-01'),
	(4, 9.00, '2024-01-01'),
	(5, 11.50, '2024-01-01');

	-- Insert data into WinePrices table
	INSERT INTO WinePrices (WineID, Price, EffectiveDate) VALUES
	(1, 15.99, '2024-01-01'),
	(2, 18.50, '2024-01-01'),
	(3, 20.00, '2024-01-01'),
	(4, 22.00, '2024-01-01'),
	(5, 14.00, '2024-01-01');

	-- Insert data into Orders table
	INSERT INTO Orders (OrderDate, BookID, WineID, Quantity, TotalPrice) VALUES
	('2024-09-01', 1, NULL, 2, 15.00),  -- 2 copies of The Book Thief
	('2024-09-02', NULL, 2, 1, 18.50),  -- 1 bottle of Merlot
	('2024-09-03', 3, 4, 1, 34.50),     -- 1 copy of Lets Not Do That Again and 1 bottle of Pinot Noir
	('2024-09-04', 5, 1, 3, 44.97),     -- 3 copies of One Day and 1 bottle of Chardonnay
	('2024-09-05', NULL, 3, 2, 40.00);  -- 2 bottles of Cabernet Sauvignon

-- 4. Write Queries
	-- Query 1: All Book Titles and Their Most Recent Prices
	SELECT b.Title, p.Price
	FROM Books b
	JOIN BookPrices p ON b.BookID = p.BookID
	WHERE p.EffectiveDate = (SELECT MAX(EffectiveDate) FROM BookPrices WHERE BookID = b.BookID);

	-- Query 1: Biggest Orders (by Price) and Contents 
	SELECT o.OrderID, o.OrderDate, b.Title AS BookTitle, w.Name AS WineName, o.Quantity, o.TotalPrice
	FROM Orders o
	LEFT JOIN Books b ON o.BookID = b.BookID
	LEFT JOIN Wines w ON o.WineID = w.WineID
	ORDER BY o.TotalPrice DESC;

	-- Query 3: Current Wine Prices
	SELECT w.Name, p.Price
	FROM Wines w
	JOIN WinePrices p ON w.WineID = p.WineID
	WHERE p.EffectiveDate = (SELECT MAX(EffectiveDate) FROM WinePrices WHERE WineID = w.WineID);