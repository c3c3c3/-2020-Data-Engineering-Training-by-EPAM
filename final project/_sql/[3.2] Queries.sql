#--1.
SELECT parent_label_name, 
	   performer_name, 
	   number_of_copies_sold, 
	   sales_by_label, 
	   TO_char(number_of_copies_sold/sales_by_label *100,'999.99')||'%' AS percent_from_label_sales
FROM 
	(SELECT *, RANK () OVER (ORDER BY sales_by_label DESC) AS lbl_rnk
	 FROM 
		(SELECT l.parent_label_name,
	   			p.performer_name, 
	   			sum(s.copies_sold) AS number_of_copies_sold,
	   			sum(sum(s.copies_sold)) OVER (PARTITION BY l.parent_label_name) AS sales_by_label,
	   			count(s.song_id ) AS cnt,
	   			RANK () OVER (PARTITION BY l.parent_label_name 
	   			ORDER BY count(s.song_id) DESC) AS pfr_within_label_rnk
		FROM sales s 
			JOIN performers p ON p.performer_id=s.performer_id 
			JOIN songs sn ON s.song_id=sn.song_id 
			JOIN times t ON s.time_id=t.time_id 
			JOIN labels l ON l.label_id=sn.song_label_id 
		GROUP BY l.parent_label_name, p.performer_name) tab
	WHERE number_of_copies_sold/sales_by_label * 100>20 AND pfr_within_label_rnk<4
) foo 
WHERE lbl_rnk<4
ORDER BY 5;


#--2.
WITH sell_art 
AS 
	(SELECT performer_id
	FROM 
		(SELECT p.performer_id, 
	   			sum(s.copies_sold) AS sold,
	   			count(p.performer_id) AS cnt,
	   			sum(sum(s.copies_sold)) OVER (PARTITION BY l.parent_label_name) AS sales_by_label
		FROM sales s 
			JOIN performers p ON p.performer_id=s.performer_id 
			JOIN songs sn ON s.song_id=sn.song_id 
			JOIN times t ON s.time_id=t.time_id 
			JOIN labels l ON l.label_id=sn.song_label_id 
		GROUP BY l.parent_label_name, p.performer_id) tab
	    WHERE sales_by_label > 5000000)
SELECT song_id, 
	   performer_name, max(time_one) AS first_week, max(time_two) AS second_week, max(time_three) AS third_week,
       max(time_one)+max(time_two)+max(time_three) AS total
FROM
(
	SELECT sn.song_id, sn.song_title, p.performer_name,
		   FIRST_VALUE (sum(s.copies_sold)) OVER sum_w AS time_one,
			NTH_VALUE (sum(s.copies_sold), 2) OVER sum_w AS time_two,
			LAST_VALUE (sum(s.copies_sold)) OVER sum_w AS time_three
	FROM sales s 
		JOIN performers p ON p.performer_id=s.performer_id 
		JOIN songs sn ON s.song_id=sn.song_id 
		JOIN times t ON s.time_id=t.time_id 
		JOIN labels l ON l.label_id=sn.song_label_id
	WHERE t.time_id IN ('2014-10-05' , '2014-10-12','2014-10-19') AND sn.song_type='SOLO'
		AND p.performer_id IN (SELECT * FROM sell_art)
	GROUP BY  t.time_id, sn.song_id, p.performer_name
--#WINDOW SECTION FOR BETTER REEADABILITY
	WINDOW sum_w AS (PARTITION BY sn.song_id ORDER BY t.time_id
			         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)) tab 
GROUP BY song_id, performer_name
HAVING max(time_one)+max(time_two)+max(time_three) IS NOT NULL ;


#--3.
SELECT song_producer, percentage
FROM
	(SELECT sn.song_producer, 
			t.calendar_half_year , 
			sum (s.copies_sold ) AS sales,
			lag(sum(s.copies_sold )) OVER lag_w AS prev_period,
			((lag(sum(s.copies_sold )) OVER lag_w)-sum (s.copies_sold ))*100/lag(sum(s.copies_sold )) 
			OVER lag_w ||'%' AS percentage
	FROM  sales s 
			JOIN performers p ON p.performer_id=s.performer_id 
			JOIN songs sn ON s.song_id=sn.song_id 
			JOIN times t ON s.time_id=t.time_id 
			JOIN labels l ON l.label_id=sn.song_label_id
	WHERE t.calendar_month_desc IN ('2014-1','2014-3','2014-5','2014-8','2014-10','2014-12')
	GROUP BY sn.song_producer,
		 	 t.calendar_half_year
	WINDOW lag_w AS (PARTITION BY song_producer ORDER BY t.calendar_half_year )) tab 
WHERE prev_period>sales
ORDER BY 1;
