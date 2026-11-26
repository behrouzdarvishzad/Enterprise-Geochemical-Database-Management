## Enterprise Geochemical Database Management System
This project demonstrates the design and implementation of an enterprise-scale geochemical database management system using Python, SQL Server, and Power BI.

The project uses publicly available geochemical datasets from the United States Geological Survey (USGS) National Geochemical Database (NGDB). The objective was to transform legacy DBF files into a modern analytical platform capable of supporting data management, reporting, QA/QC workflows, and business intelligence applications.

### Overview
This project transforms legacy USGS geochemical data into an enterprise database and reporting platform.

The workflow includes:

**Python ETL --> SQL Server Database --> Power BI Dashboards**

### Technologies
- Python
- SQL Server
- Power BI
- Pandas
- SQLAlchemy

### Project Results
- Migrated more than 1.6 million analytical measurements into SQL Server.
- Designed a fully normalized relational geochemical database.
- Implemented dimension tables, fact tables, primary keys, and foreign key relationships.
- Created reporting views optimized for Power BI dashboards.
- Developed QA/QC reporting and analytical summary layers.
- Implemented indexing strategies to improve query performance.
