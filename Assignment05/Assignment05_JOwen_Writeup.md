Jonathan Owen
May 16, 2022
IT FDN 130 A Sp 22
Assignment 05

## Introduction

The join clause is a powerful tool in the SQL query library. The SQL join allows users to leverage the data in multiple tables in a single select statement. Depending upon the desired information a user would like to extract from a database, there are different types of joins that may be used. This paper will discuss the types of joins available and the data returned by each.

## Using SQL Joins

Joins are used in SQL queries when the desired data being returned is held in multiple tables. Additionally, to prevent the storage of duplicate data, a value that may be common across multiple rows in a table may be pulled out and stored in a separate table. A join would relate the two tables allowing the data to be presented by a single query to the user. 

## The Three Basic Joins

### Inner

The inner join is used to return the data from tables only when there are matches on the keys defined to join the tables. If there are no matches on the keys specified in the join clause, then no data will be returned. 

### Outer

The outer join will only return data from the joined table when there is a match. With this join, all the values from one or both of the joined tables are returned, depending upon the type of outer join specified by the LEFT, RIGHT, and FULL keywords. These keywords are optional, but when not included, the default action is that of a LEFT OUTER JOIN. 

When a LEFT join is specified, all the data from the table located on the left side of the JOIN keyword will be included in the results regardless of if there is matching data in the Joined table. Likewise, when a RIGHT join is specified all the data from the table on the right of the JOIN keyword will be included regardless of if there is a matching value on the table listed to the left of the JOIN keyword. When there is no matching value in the table which has been joined, the missing values will be presented as null.

The FULL join is just like the LEFT and RIGHT join, but all the data from both tables will be returned, as the name suggests. If there is no match, the missing data will be presented as null values. 

### Cross

The cross join is a rarely used join type. Unlike the inner and outer joins, the cross join does not require matching keys to be specified. This join will return all possible row combinations between the joined tables. Due to the nature of the cross join, the join can yield a considerable number of results. The number of results will be table1RowCount * table2RowCount[^1].

## The Self Join

A self-join occurs when a table is joined onto itself, this join can be any of the three basic join types listed above. A use for a self-join is when hierarchical data is being retrieved from a table. A typical example of using a self-join is when queuing a table containing employee names where there is a column containing the ID of the employee's manager. In this example, the table would be joined back on itself on the values managerID = employeeID.

## Summary

Joining tables in SQL queries allow a user to unleash a wealth of information stored in a database in a single select statement. With the join clause, data may be easily and efficiently stored in a database by reducing or eliminating the need to store duplicate data in multiple tables while allowing the data to be presented as one congruent data set.

[^1]: *SQL cross join*. (2022, April 13). W3resource. https://www.w3resource.com/sql/joins/cross-join.php
