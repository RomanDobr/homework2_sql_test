-- Создать базу данных test

CREATE DATABASE test;

-- Исполнить этот запрос https://github.com/pthom/northwind_psql/blob/master/northwind.sql

--1. Посчитать количество заказов за все время

SELECT COUNT(*) AS "Общее количество заказов, шт"
FROM public.orders;

--2. Посчитать сумму по всем заказам за все время (учитывая скидки)

SELECT SUM(total_price) AS "Итог:"
FROM (
	SELECT CAST(SUM(od.unit_price * quantity * (1 - discount)) AS NUMERIC(9, 2)) AS "total_price"  
	FROM public.orders AS ord 
		JOIN public.order_details AS od ON ord.order_id = od.order_id
		JOIN public.products AS pro ON pro.product_id = od.product_id
	GROUP BY employee_id
	ORDER BY employee_id ASC
) AS t1;

-- 3. Показать сколько сотрудников работает в каждом городе.

SELECT emp.city AS "Город", COUNT(emp.city) AS "Количество, чел."
FROM public.employees AS emp
GROUP BY emp.city;

-- 4. Выявить самый продаваемый товар в штуках. Вывести имя продукта и его количество.

SELECT prod.product_name AS "Самый продаваемый товар", od.quantity AS "Количество, шт."
FROM public.order_details AS od JOIN public.products prod ON prod.product_id = od.product_id
WHERE quantity IN (	
	SELECT MAX(total_size)
	FROM (
		SELECT od.product_id, od.quantity, MAX(od.quantity) AS "total_size"
		FROM public.order_details AS od
		GROUP BY od.product_id, od.quantity
	) AS t1
);

-- 5. Выявить фио сотрудника, у которого сумма всех заказов самая маленькая

SELECT t3.last_name, t3.first_name
FROM (
	  SELECT t1.last_name, t1.first_name, sum(quantity)
	  FROM (
		SELECT empl.last_name, empl.first_name, od.quantity
		FROM public.orders AS ord 
			JOIN public.order_details AS od ON od.order_id = ord.order_id
			JOIN public.products AS prod ON prod .product_id = od.product_id
			JOIN public.employees AS empl ON empl.employee_id = ord.employee_id
		GROUP BY empl.last_name, empl.first_name, od.quantity) AS t1
	  GROUP BY t1.last_name, t1.first_name) AS t3
WHERE t3.sum IN (		
	  SELECT MIN(t2.sum)
	  FROM (
		SELECT t1.last_name, t1.first_name, sum(quantity)
		FROM (
		SELECT empl.last_name, empl.first_name, od.quantity
		FROM public.orders AS ord 
			JOIN public.order_details AS od ON od.order_id = ord.order_id
			JOIN public.products AS prod ON prod .product_id = od.product_id
			JOIN public.employees AS empl ON empl.employee_id = ord.employee_id
		GROUP BY empl.last_name, empl.first_name, od.quantity) AS t1
	  GROUP BY t1.last_name, t1.first_name ) AS t2
);