--SQL Advance Case Study


--Q1--BEGIN 
	
	select distinct L.State
	from FACT_TRANSACTIONS T 
	inner join DIM_LOCATION L 
	on t.IDLocation=l.IDLocation
	where year(t.Date) > 2004


--Q1--END

--Q2--BEGIN

	
	select top 1 l.Country,l.State,sum(t.Quantity) total_qty 
	from FACT_TRANSACTIONS T 
	inner join DIM_LOCATION L
	on t.IDLocation=l.IDLocation 
	inner join DIM_MODEL M
	on M.IDModel=t.IDModel 
	inner join DIM_MANUFACTURER mf
	on mf.IDManufacturer=m.IDManufacturer
	where l.Country='US' and Mf.Manufacturer_Name='Samsung'
	group by l.Country,l.State
	order by sum(t.Quantity) desc



--Q2--END

--Q3--BEGIN      
	

	select l.State,l.ZipCode,m.Model_Name,count(t.IDCustomer) transaction_no 
	from FACT_TRANSACTIONS T 
	inner join DIM_MODEL M 
	on M.IDModel=T.IDModel
	INNER JOIN DIM_LOCATION L 
	on L.IDLocation=T.IDLocation
	group by l.State,l.ZipCode,m.Model_Name


--Q3--END

--Q4--BEGIN

	select top 1 mf.Manufacturer_Name cellphone,m.Model_Name,m.Unit_price price 
	from DIM_MODEL m inner join DIM_MANUFACTURER mf on 
	mf.IDManufacturer=m.IDManufacturer
	order by Unit_price


--Q4--END

--Q5--BEGIN

	with top5_manufactures
	as(
		select top 5 Mf.Manufacturer_Name,sum(Quantity) total_qty from FACT_TRANSACTIONS T 
		inner join DIM_MODEL M 
		on T.IDModel=M.IDModel
		inner join DIM_MANUFACTURER Mf 
		on M.IDManufacturer=mf.IDManufacturer
		group by mf.Manufacturer_Name
		order by sum(Quantity) desc,avg(TotalPrice) desc
	)
	select mf.Manufacturer_Name,m.Model_Name,sum(t.TotalPrice)/sum(t.Quantity) avg_price
	from FACT_TRANSACTIONS T
	inner join DIM_MODEL M 
	on T.IDModel=M.IDModel
	inner join DIM_MANUFACTURER Mf
	on M.IDManufacturer=mf.IDManufacturer
	where mf.Manufacturer_Name in (select mf.Manufacturer_Name from top5_manufactures)
	group by  mf.Manufacturer_Name,m.Model_Name



--Q5--END

--Q6--BEGIN


	select c.IDCustomer,c.Customer_Name,avg(TotalPrice) avg_amount
	from FACT_TRANSACTIONS T 
	inner join DIM_CUSTOMER C 
	on C.IDCustomer=T.IDCustomer
	where year(t.Date)=2009 
	group by c.IDCustomer,c.Customer_Name
	having avg(TotalPrice) > 500

--Q6--END
	
--Q7--BEGIN 


	select * from(
	SELECT top 5 Model_Name
	FROM DIM_DATE d 
	INNER JOIN FACT_TRANSACTIONS t 
	on d.DATE=t.Date 
	inner join DIM_MODEL m 
	on  m.IDModel=t.IDModel
	where d.YEAR=2008
	group by Model_Name
	order by sum(Quantity)	 desc) x

	intersect

	select* from(
	SELECT top 5 Model_Name
	FROM DIM_DATE d 
	INNER JOIN FACT_TRANSACTIONS t 
	on d.DATE=t.Date 
	inner join DIM_MODEL m 
	on  m.IDModel=t.IDModel
	where d.YEAR=2009
	group by Model_Name
	order by sum(Quantity)	 desc) y
	intersect

	select * from(
	SELECT top 5 Model_Name
	FROM DIM_DATE d 
	INNER JOIN FACT_TRANSACTIONS t 
	on d.DATE=t.Date 
	inner join DIM_MODEL m 
	on  m.IDModel=t.IDModel
	where d.YEAR=2010
	group by Model_Name
	order by sum(Quantity)	 desc) z

	---or

		
		with year_2008
		as (
		SELECT top 5 m.Model_Name
		FROM FACT_TRANSACTIONS d 
		INNER JOIN DIM_DATE t 
		on d.DATE=t.Date 
		inner join DIM_MODEL m 
		on d.IDModel = m.IDModel
	where YEAR=2008
	group by Model_Name
	order by sum(Quantity) desc
	),
	year_2009
	as(
	SELECT top 5 m.Model_Name
		FROM FACT_TRANSACTIONS d 
		INNER JOIN DIM_DATE t 
		on d.DATE=t.Date 
		inner join DIM_MODEL m 
		on d.IDModel = m.IDModel
	where YEAR=2009
	group by Model_Name
	order by sum(Quantity) desc
	),
	year_2010
	as(
	SELECT top 5 m.Model_Name
		FROM FACT_TRANSACTIONS d 
		INNER JOIN DIM_DATE t 
		on d.DATE=t.Date 
		inner join DIM_MODEL m 
		on d.IDModel = m.IDModel
	where YEAR=2010
	group by Model_Name
	order by sum(Quantity) desc)
	select * from year_2008
	intersect
	select * from year_2009
	intersect 
	select * from year_2010

--Q7--END	
--Q8--BEGIN


	with manufacturer 
	as (
	select mf.Manufacturer_Name,sum(TotalPrice) total_sales,year(date) years,
	DENSE_RANK() over(partition by year(date) order by sum(totalprice) desc) ranks
	from FACT_TRANSACTIONS T
	inner join DIM_MODEL M 
	on M.IDModel=T.IDModel 
	inner join DIM_MANUFACTURER mf 
	on mf.IDManufacturer=m.IDManufacturer
	where year(Date) in (2009,2010)
	group by mf.Manufacturer_Name,year(Date)
	)
	select Manufacturer_Name,total_sales from manufacturer
	where ranks=2



--Q8--END
--Q9--BEGIN
	

	select distinct mf.Manufacturer_Name from FACT_TRANSACTIONS T 
	inner join DIM_MODEL M 
	on M.IDModel=T.IDModel
	inner join DIM_MANUFACTURER mf 
	on mf.IDManufacturer=m.IDManufacturer
	where year(date)=2010 
	and mf.Manufacturer_Name not in (select distinct mf.Manufacturer_Name from FACT_TRANSACTIONS T 
	inner join DIM_MODEL M 
	on M.IDModel=T.IDModel
	inner join DIM_MANUFACTURER mf
	on mf.IDManufacturer=m.IDManufacturer
	where year(date)=2009)


--Q9--END

--Q10--BEGIN
	
	with top_10
	as (
		 select top 10 Customer_Name,T.IDCustomer,sum(TotalPrice) prices 
		 from FACT_TRANSACTIONS T join
		 DIM_CUSTOMER C on T.IDCustomer=c.IDCustomer
		 group by Customer_Name,t.IDCustomer
		 order by prices desc
		 ),
	avg_spend 
	as (
		 select a.IDCustomer,year(Date) years,avg(TotalPrice) avg_price,avg(Quantity) avg_qty
		 from top_10 a join FACT_TRANSACTIONS b
		 on a.IDCustomer=b.IDCustomer
		 group by year(Date),a.IDCustomer
		 ),
	prev_revenue 
	as(
		select *,
		lag(avg_price,1) over(partition by IdCustomer order by years) as prev_revenue
		from avg_spend
	  )
	select Customer_Name,years,prev_revenue,(avg_price-prev_revenue)/avg_price*100 as [%change]
	from prev_revenue D join
	DIM_CUSTOMER E on D.IDCustomer=E.IDCustomer
--Q10--END