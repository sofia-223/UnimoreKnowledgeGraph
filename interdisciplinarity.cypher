match (d:Document)-[:HAS]->(k:KeyWord)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
with k, d, collect(distinct a) as Authors, collect(distinct s) as SSDs, collect(distinct ar) as Areas
with k.KeyWordAU as Keyword,
     size(collect(distinct d)) as NumDocs,
     avg(size(Authors)) as AvgNumAuthors,
     avg(size(SSDs)) as AvgNumSSDPerDoc,
     avg(size(Areas)) as AvgNumAreasPerDoc
where NumDocs >= 10
return Keyword, NumDocs, AvgNumAuthors, AvgNumSSDPerDoc, AvgNumAreasPerDoc
order by AvgNumAreasPerDoc desc


match (d:Document)-[:HAS]->(t:Topic)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
with t, d, collect(distinct a) as Authors, collect(distinct s) as SSDs, collect(distinct ar) as Areas
with t.TopicScopus as Topic, 
     size(collect(distinct d)) as NumDocs,
     avg(size(SSDs)) as AvgNumSSDPerDoc,
     avg(size(Areas)) as AvgNumAreasPerDoc
where NumDocs >= 10
return Topic, NumDocs, AvgNumSSDPerDoc, AvgNumAreasPerDoc
order by AvgNumSSDPerDoc desc



match (d:Document)-[:HAS]->(t:Topic)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)
with d, t, collect(distinct s) as SSDs
where size(SSDs) > 1
with t.TopicScopus as Topic, count(distinct d) as NumDocs, avg(size(SSDs)) as AvgNumSSD
where NumDocs >= 10
return Topic, NumDocs, AvgNumSSD
order by AvgNumSSD desc



match (d:Document)-[:HAS]->(t:Topic)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
with d, t, collect(distinct ar) as Areas
where size(Areas) > 1
with t.TopicScopus as Topic, count(distinct d) as NumDocs, avg(size(Areas)) as AvgNumAreas
where NumDocs >= 10
return Topic, NumDocs, AvgNumAreas
order by AvgNumAreas desc



match (d:Document)-[:HAS]->(k:KeyWord)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
with d, k, collect(distinct ar) as Areas
where size(Areas) > 1
with k.KeyWordAU as Keyword, count(distinct d) as NumDocs, avg(size(Areas)) as AvgNumAreas
where NumDocs >= 10
return Keyword, NumDocs, AvgNumAreas
order by AvgNumAreas desc



match (d:Document)-[:HAS]->(k:KeyWord)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)
with d, k, collect(distinct s) as SSDs
where size(SSDs) > 1
with k.KeyWordAU as Keyword, count(distinct d) as NumDocs, avg(size(SSDs)) as AvgNumSSD
where NumDocs >= 10
return Keyword, NumDocs, AvgNumSSD
order by AvgNumSSD desc



match (d:Document)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)
with d, c, collect(distinct s) as SSDs
where size(SSDs) > 1
with c.SubjectCategory as Category, count(distinct d) as NumDocs, avg(size(SSDs)) as AvgNumSSD
where NumDocs >= 10
return Category, NumDocs, AvgNumSSD
order by AvgNumSSD desc



match (d:Document)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
match (d)<-[:WRITE]-(a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
with d, c, collect(distinct ar) as Areas
where size(Areas) > 1
with c.SubjectCategory as Category, count(distinct d) as NumDocs, avg(size(Areas)) as AvgNumAreas
where NumDocs >= 10
return Category, NumDocs, AvgNumAreas
order by AvgNumAreas desc
