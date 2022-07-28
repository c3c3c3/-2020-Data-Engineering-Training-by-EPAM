# -2020-Data-Engineering-Training-by-EPAM
contains SQL code related to training itself &amp; final project on data analysis (more details in .readme file)

Within training, the following topics were covered: DB Fundamentals, DB Basics, SQL for Analysis.

Final project:

  technology: DBMS: PostgreSQL / SQL for analysis (aggregations, multiple joins, CTEs, window frames, fact and dimension scheme)
  / domain: music, sales
  / topis: American iTunes TOP-10 sales 2013-2017
  / source data: kworb.net, riaa.com, en.wikipedia.org
  / 3 business tasks:
	
1) for top 3 labels (by number of units sold within the entire timeframe), pick the performers (1 per label) who spent the greatest number of weeks in top-10. Consider the artists making more than 20% of label units.
2) within specified timeframe, choose the perfomer with sales of their 1 best-selling song. The artist must meet the condition that their labels made over 5M copies sold in 2013-2017.
3) define song producers who conveyed negative growth (in terms of numbers of units sold) in the 2nd half of 2014 in comparison to the 1st half
-visualisation: Excel built-in tools
