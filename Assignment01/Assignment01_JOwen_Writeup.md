Jonathan Owen
April 17, 2022
IT FDN 130 A Sp 22
Assignment 01

# Databases and Tables

## Introduction

This first module of the Spring 2022 Foundations of Databases and SQL programming served as an introduction to databases and the SQL language. The first assignment introduced the basic process for creating a database, creating tables within a database, and populate tables with data. Other vital concepts were discussed, including the importance of primary keys within tables and the first three rules of normalization, which will aid in designing and constructing an effective and well-thought-out relational database. This document will discuss a key takeaway from the first module: the difference between databases and tables. 

## Databases

Databases can be thought of as a collection of data that has been collected or created to serve a business process. This description may be an oversimplification. In reality, a database is a system that allows for the creation, reading, updating, or deletion of stored data[^1]. A database will most likely contain different data sets that may be linked through a defined relationship. An example would be a data set containing customer details such as name and address and a second data set containing products and quantities purchased. These two data sets can then be linked by creating a data set of orders that could track which product was purchased by which customer. 

## Tables

A table is a collection of sets of related data. Ideally, this data will not contain any duplicate data. A table is comprised of rows and columns. Each column will have a defined data type, such as an integer or string (varchar is one option), and a label to allow a user to identify and reference the data stored in each column. A row is a set of data stored across each column and is directly related. For example, following on from the examples used above, the data set containing the customer details would be defined as a table with a row of the data containing each customer's name. When creating a table, the rules of normalization should be followed in order to ensure the following; that there is no duplication of data, data is stored in its smallest unit of meaning (referred to in class as an 'atomic value'), and the table rows may be uniquely identified by the use of a primary key. 

## Databases vs. Tables

Tables are the building blocks of databases. A table is a single file within which data is stored, while a database is an architecture that allows for the management of multiple tables and the data contained within them. An example of a table is a spreadsheet, this is great for storing one type of data, but when attempting to track multiple types of data, the spreadsheet can become large and difficult to maintain. 

In the previous customer details and product orders example, if this information is stored in a spreadsheet, the customer details would be duplicated on each line of purchased product information. This duplicated customer data might be workable until a detail about the customer changes. Then, every row where the customer appears must be updated, significantly increasing the possibility of an error being introduced in the data. Two spreadsheets could solve the data duplication problem, one for products purchased and one to track customer details. Unfortunately, a user would need to manually go back and forth between two files to determine which customer goes with each purchased product. In this situation, a database would shine. 

A database would allow a user to efficiently work with the two files containing the customer details and purchased products, allowing the user to quickly determine who ordered what without flipping between two files. Additionally, it would allow for updating customer details in just one location, significantly reducing the possibility of introducing a data error.

## Summary

When designed and built well, databases are a powerful tool for storing large volumes of data while reducing or eliminating duplicate data. In addition, a well-designed database could increase the confidence that stored data is correct and improve the efficiency when viewing records. While tables are an excellent method for storing small and limited sets of data, their power and usefulness are greatly increased when combined with and related to other tables within a database.



[1]  Kimani, D. (2012, August 1). *Introduction to Databases*. Techopedia.Com. https://www.techopedia.com/6/28832/enterprise/databases/introduction-to-databases
