USE USGS_Geochemistry;
GO

CREATE SCHEMA geo;
GO

CREATE TABLE geo.Elements
(
    ElementID INT PRIMARY KEY,
    ElementName VARCHAR(20) NOT NULL
);

CREATE TABLE geo.Methods
(
    MethodID INT PRIMARY KEY,
    MethodName VARCHAR(20) NOT NULL
);
