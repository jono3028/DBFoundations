Jonathan Owen
May 24, 2022
IT FDN 130 A Sp 22
Assignment 06
<https://github.com/jono3028/DBFoundations>

## Introduction
Performing individual queries on a database is a method to extract useful information from a database. However, repeatedly typing a simple or complex query is not a productive use of time. Views, functions, and stored procedures may be used to increase usability and simplify interactions with a database. This paper will discuss the views and their usage in a SQL database and the differences between views, functions, and stored procedures.

## When To Use A View
Views are a helpful tool in simplifying database usage and provide a level of security through abstraction. Views may be used to prevent a user from directly accessing manipulating tables and their data. 
A base view may be created for a table; this type of view will generally represent a table in its entirety and return all the respective table columns.  
A reporting view may be created to partition data by limiting the columns accessed on a table, limiting the returned rows, or simplifying a complex query. Permissions may be granted on views to add a level of security. An example of this is when a table contains sensitive information. Two views may be created, one which returns the columns of sensitive info while the other does not. Permissions may be set so that users that do not have permission to view sensitive information will receive an error if they try and use the view that returns the restricted columns.

## Views, Functions, and Stored Procedures
Views, functions, and stored procedures are all similar but are best suited for different situations. 
### Views
With few exceptions, views are read-only. Views are handy when extracting information from a database. Views are an ideal way to save complex or frequently used queries within a database and allow them to be used by other users. However, views are limited because they do not accept parameters, resulting in non-dynamic queries. 
### Functions
Functions may be created to return a single value or a table of values. Functions are similar to views, with the exception that they accept parameters allowing for dynamic queries. Functions are handy when returning a single value; this is called a scalar function. A scalar function use case is when a column of a query requires custom formatting. One or multiple values from the query may be passed into the function where the desired algorithm would be performed with the result returned as the rows column entry.  
### Stored Procedures
Stored procedures are similar to views, but similar to a function they accept parameters. Stored procedures are an excellent way to store a complex dynamic query within a database so that it can be shared with other users. An added benefit to stored procedures is that they may modify the database, unlike views, which are generally read-only. An example of the use of a stored procedure is if you were required to remove a user and all their associated data from a database. Due to foreign key constraints the data may need to be removed in a particular order from multiple tables; a stored procedure can bundle all the necessary delete statements into a single command. 

## Summary
Views, functions, and stored procedures all have similarities but are best suited for specific use cases within SQL. However, when used appropriately, they can all contribute to the reduction of duplicate code, which will aid in keeping a database maintainable and allow other developers to contribute more effectively and efficiently.