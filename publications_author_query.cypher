match (d:Document)-[:HAS]-(t:Topic)
return t.TopicScopus, count(d) as numdoc
order by numdoc desc


match (d:Document)-[:PUBLISHED_IN]-(s)-[:BELONGS_TO_CATEGORY]-(c:Category)
return c.SubjectCategory as cat, count(d) as numdoc
order by numdoc desc

match (d:Document)-[:HAS]-(k:KeyWord)
return k.KeyWordAU, count(d) as numdoc
order by numdoc desc

match (d:Document)-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]-(s:SSD)
return s.SSD_abbr, s.SSD_id, count(d) as num
order by num desc

match (d:Document)-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]-(s:SSD)-[:PART_OF]-(ar:Area)
return ar.Area_Full_Name, ar.Area_id, count(d) as num
order by num desc

//numero di autori coinvolti


match (d:Document)-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
return ar.Area_Full_Name as Area, count(distinct a) as NumAuthors
order by NumAuthors desc

match (a:Author)-[:WRITE]->(d:Document)-[:HAS]->(k:KeyWord)
return k.KeyWordAU as Keyword, count(distinct a) as NumAuthors
order by NumAuthors desc

match (a:Author)-[:WRITE]-(d:Document)-[:HAS]-(t:Topic)
return t.TopicScopus as Topic, count(distinct a) as NumAuthors
order by NumAuthors desc

match (a:Author)-[:WRITE]->(d:Document)-[:PUBLISHED_IN]->(s)-[:BELONGS_TO_CATEGORY]->(c:Category)
return c.SubjectCategory as Category, count(distinct a) as NumAuthors
order by NumAuthors desc

