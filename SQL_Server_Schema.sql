/*
Project: Enterprise Geochemical Database Management System

Author: Behrouz Darvishzad

Technologies:
- SQL Server
- Python ETL
- Power BI

Description:
Implementation of a normalized geochemical database containing 1.6+ million analytical measurements,
dimension tables, fact tables, reporting views,
and QA/QC analytical layers.

Phase 3: SQL Server Implementation and Data Migration
*/
-- Create a dedicated SQL schema to organize all geochemical tables inside the database.
USE USGS_Geochemistry;
GO

CREATE SCHEMA geo;
GO
-- Create the Elements dimension table that will be referenced by analytical results through a foreign key.
CREATE TABLE geo.Elements
(
    ElementID INT PRIMARY KEY,
    ElementName VARCHAR(20) NOT NULL
);

--Store analytical methods in a separate table and link them to analytical results through a foreign key.
CREATE TABLE geo.Methods
(
    MethodID INT PRIMARY KEY,
    MethodName VARCHAR(20) NOT NULL
);

-- Store QA/QC and laboratory reporting flags separately and link them to analytical results through foreign keys.
CREATE TABLE geo.Qualifiers
(
    QualifierID INT PRIMARY KEY,

    QualifierCode VARCHAR(5) NOT NULL UNIQUE,

    QualifierDescription VARCHAR(100) NULL
);

-- Create the parent table of the entire database.
CREATE TABLE geo.Samples
(
    LAB_ID VARCHAR(8) PRIMARY KEY,

    STATE VARCHAR(50),
    COUNTRY VARCHAR(50),

    LATITUDE FLOAT,
    LONGITUDE FLOAT,

    DATE_SUB DATE,

    PRIMECLASS VARCHAR(50),
    XNDRYCLASS VARCHAR(50),

    SPEC_NAME VARCHAR(100),

    GEOL_AGE VARCHAR(100),

    STRATGRPHY VARCHAR(255),

    MINERALZTN VARCHAR(255),

    ALTERATION VARCHAR(255)
);

-- Create the central fact table and establish the foreign key relationships. Create the ChemistryResults table and connect it to the Samples, Elements, and Methods tables.
CREATE TABLE geo.ChemistryResults
(
    ResultID BIGINT PRIMARY KEY,

    LAB_ID VARCHAR(8) NOT NULL,

    ElementID INT NOT NULL,

    MethodID INT NOT NULL,

    QualifierID INT NULL,

    Value FLOAT NOT NULL,

    CONSTRAINT FK_ChemistryResults_Samples
        FOREIGN KEY (LAB_ID)
        REFERENCES geo.Samples(LAB_ID),

    CONSTRAINT FK_ChemistryResults_Elements
        FOREIGN KEY (ElementID)
        REFERENCES geo.Elements(ElementID),

    CONSTRAINT FK_ChemistryResults_Methods
        FOREIGN KEY (MethodID)
        REFERENCES geo.Methods(MethodID),

    CONSTRAINT FK_ChemistryResults_Qualifiers
        FOREIGN KEY (QualifierID)
        REFERENCES geo.Qualifiers(QualifierID)
);

/* Confirm that the SQL Server schema matches the database design. The final database 
-- preserves all analytical measurements, metadata, methods, and QA/QC qualifier 
 information within a fully normalized relational structure.
*/
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'geo'
ORDER BY TABLE_NAME;


--Data Migration Validation
SELECT COUNT(*) AS ElementsCount
FROM geo.Elements;

SELECT COUNT(*) AS MethodsCount
FROM geo.Methods;

SELECT COUNT(*) AS QualifiersCount
FROM geo.Qualifiers;

SELECT COUNT(*) AS SamplesCount
FROM geo.Samples;

SELECT COUNT(*) AS ChemistryResultsCount
FROM geo.ChemistryResults;



--Phase 4: SQL Reporting Layer
/*Transform the normalized SQL Server database into a reporting-ready data model for 
analytics, QA/QC reporting, and Power BI integration.
The normalized relational model successfully stores geochemical measurements, sample 
metadata, analytical methods, and laboratory qualifiers across multiple tables. However, 
analysts and reporting tools should not be required to manually join these tables for
every query.
This phase creates SQL views that simplify data access while preserving the underlying 
relational architecture.
*/

-- Combine all tables into a single analysis-friendly dataset for Power BI and SQL reporting.
CREATE VIEW geo.vw_ChemistryResults
AS
SELECT
    cr.ResultID,
    cr.LAB_ID,

    e.ElementName,
    m.MethodName,
    q.QualifierCode,

    cr.Value,

    s.STATE,
    s.COUNTRY,
    s.LATITUDE,
    s.LONGITUDE,

    s.PRIMECLASS,
    s.SPEC_NAME,
    s.GEOL_AGE

FROM geo.ChemistryResults cr

LEFT JOIN geo.Elements e
    ON cr.ElementID = e.ElementID

LEFT JOIN geo.Methods m
    ON cr.MethodID = m.MethodID

LEFT JOIN geo.Qualifiers q
    ON cr.QualifierID = q.QualifierID

LEFT JOIN geo.Samples s
    ON cr.LAB_ID = s.LAB_ID;

/* Transform the normalized SQL Server database into a reporting-ready analytical model.
While the relational database structure is optimized for data storage and integrity, 
reporting tools such as Power BI require simplified datasets that minimize complex joins.
This phase creates SQL views, reporting queries, and performance optimizations that 
support geochemical analysis, QA/QC reporting, and business intelligence applications.
*/

--Verify that the view works correctly and returns the expected data.
SELECT TOP 10 *
FROM geo.vw_ChemistryResults;

/* The reporting view was successfully created and validated.
The view combines analytical results, sample metadata, analytical methods, elements, 
and laboratory qualifiers into a single reporting-ready dataset.
This structure simplifies querying and provides a direct source for Power BI dashboards 
and analytical reporting without requiring complex table joins.
*/

-- Improve query performance.Create indexes on the most frequently used foreign keys and reporting fields.

CREATE INDEX IX_ChemistryResults_LAB_ID
ON geo.ChemistryResults (LAB_ID);

CREATE INDEX IX_ChemistryResults_ElementID
ON geo.ChemistryResults (ElementID);

CREATE INDEX IX_ChemistryResults_MethodID
ON geo.ChemistryResults (MethodID);

CREATE INDEX IX_ChemistryResults_QualifierID
ON geo.ChemistryResults (QualifierID);

/*The reporting view was successfully created and tested.
The view combines analytical measurements, sample metadata, analytical methods, 
geochemical elements, and laboratory qualifiers into a single reporting-ready dataset.
This reporting layer provides a simplified interface for SQL analysis and Power BI 
integration while preserving the underlying normalized database structure.
*/

--Create the first business-oriented reporting query.
--Identify the most frequently analyzed geochemical elements in the database.
SELECT TOP 10
    e.ElementName,
    COUNT(*) AS NumberOfAnalyses
FROM geo.ChemistryResults cr
INNER JOIN geo.Elements e
    ON cr.ElementID = e.ElementID
GROUP BY e.ElementName
ORDER BY NumberOfAnalyses DESC;
/*The analytical results indicate that major rock-forming elements represent the most 
frequently analyzed constituents within the database.
Elements such as K2O, Na2O, P2O5, SiO2, CaO, and Al2O3 account for the highest number of 
laboratory measurements, reflecting their importance in geochemical characterization and 
petrological interpretation.
This query demonstrates the ability of the relational database to efficiently summarize 
large-scale analytical datasets using SQL.
*/

--Create the first QA/QC reporting query.
--Measure the frequency of laboratory qualifier flags within the database.
SELECT
    q.QualifierCode,
    COUNT(*) AS NumberOfOccurrences
FROM geo.ChemistryResults cr
INNER JOIN geo.Qualifiers q
    ON cr.QualifierID = q.QualifierID
GROUP BY q.QualifierCode
ORDER BY NumberOfOccurrences DESC;

/*Laboratory qualifier reporting is dominated by the "L" code, accounting for 89,245 
occurrences, followed by "<" with 6,281 occurrences.
These results demonstrate the importance of preserving qualifier information within 
the relational database, as QA/QC flags represent a significant component of the analytical dataset and provide valuable context for data interpretation and reporting.
*/

--Create a business-oriented reporting query for spatial coverage.
--Identify the states with the highest number of analytical results.

SELECT TOP 10
    STATE,
    COUNT(*) AS NumberOfAnalyses
FROM geo.vw_ChemistryResults
GROUP BY STATE
ORDER BY NumberOfAnalyses DESC;
/*The analytical results are concentrated in a small number of states, with Alaska (AK) 
containing the highest number of geochemical analyses, followed by Washington (WA), 
Hawaii (HI), Montana (MT), and New Mexico (NM).
This query demonstrates how the relational database can be used to evaluate spatial 
coverage, identify high-density sampling regions, and support regional geochemical investigations.
*/

--Create a Power BI-ready summary view.
--Provide a clean dataset for dashboards without querying 1.6 million records directly.
CREATE VIEW geo.vw_StateSummary
AS
SELECT
    STATE,
    COUNT(*) AS NumberOfAnalyses,
    COUNT(DISTINCT LAB_ID) AS NumberOfSamples
FROM geo.vw_ChemistryResults
GROUP BY STATE;
/*A reporting view was created to summarize analytical activity by state.
The view provides a simplified dataset for reporting and dashboard development by 
aggregating analytical measurements and unique sample counts at the state level.
This structure is optimized for Power BI and executive-level reporting, allowing rapid 
identification of regions with the highest analytical coverage.
*/

--Create a second Power BI-ready view focused on geochemical elements.
--Provide a summary dataset showing analytical activity by element.
CREATE VIEW geo.vw_ElementSummary
AS
SELECT
    e.ElementName,
    COUNT(*) AS NumberOfAnalyses,
    COUNT(DISTINCT cr.LAB_ID) AS NumberOfSamples,
    AVG(cr.Value) AS AverageValue
FROM geo.ChemistryResults cr
INNER JOIN geo.Elements e
    ON cr.ElementID = e.ElementID
GROUP BY e.ElementName;

/* A reporting view was created to summarize analytical activity by geochemical element.
The view provides a simplified dataset containing analysis counts, sample counts, and 
average analytical values for each element. This structure is optimized for dashboard 
development and geochemical reporting in Power BI.
*/

--Test the new reporting view
--Verify that the aggregated element statistics are being calculated correctly.
SELECT TOP 10 *
FROM geo.vw_ElementSummary
ORDER BY NumberOfAnalyses DESC;

/*The Element Summary view successfully aggregates analytical measurements by geochemical 
element.
The results indicate that K2O, Na2O, P2O5, SiO2, and CaO are among the most frequently 
analyzed constituents in the database. In addition to analysis counts, the view provides 
sample coverage and average analytical values, making it suitable for reporting and dashboard development.
This view serves as a key data source for Power BI visualizations and geochemical summary 
reporting.
*/

--Create the final Power BI-ready summary view.
--Provide a dataset for monitoring QA/QC qualifier usage across the database.

CREATE VIEW geo.vw_QualifierSummary
AS
SELECT
    q.QualifierCode,
    COUNT(*) AS NumberOfOccurrences
FROM geo.ChemistryResults cr
INNER JOIN geo.Qualifiers q
    ON cr.QualifierID = q.QualifierID
GROUP BY q.QualifierCode;

/* A reporting view was created to summarize QA/QC qualifier activity across the database.
The view provides a simplified representation of laboratory reporting flags and qualifier 
usage, supporting data quality assessment, QA/QC monitoring, and dashboard development.
Together, the reporting views created in Phase 4 provide a complete analytical layer for 
geochemical reporting and Power BI integration.
*/
