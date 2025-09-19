match (d:Document)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
with c.SubjectCategory as category, count(distinct d) as numdoc, sum(toInteger(d.N_Cit_NoSelf)) as totalCitazioni, avg(toInteger(d.N_Cit_NoSelf)) as avg_cit
return category, totalCitazioni, numdoc, avg_cit
order by totalCitazioni desc
limit 20;

match (d:Document)-[:HAS]->(t:Topic)
with t.TopicScopus as topic, 
     count(distinct d) as numdoc, 
     sum(toInteger(d.N_Cit_NoSelf)) as totalCitazioni, 
     avg(toInteger(d.N_Cit_NoSelf)) as avg_cit
return topic, totalCitazioni, numdoc, avg_cit
order by totalCitazioni desc
limit 20;

match (d:Document)-[:HAS]->(k:KeyWord)
with k.KeyWordAU as keyword, 
     count(distinct d) as numdoc, 
     sum(toInteger(d.N_Cit_NoSelf)) as totalCitazioni, 
     avg(toInteger(d.N_Cit_NoSelf)) as avg_cit
return keyword, totalCitazioni, numdoc, avg_cit
order by totalCitazioni desc
limit 20;

match (a:Author)-[:WRITE]->(d:Document)
with a, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, citazioni, i
where size([c in citazioni where c >= i]) >= i
return a.Author_name as autore, max(i) as H_index
order by H_index desc
limit 20;

match (a:Author)-[:WRITE]->(d:Document)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
with a, c.SubjectCategory as category, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, category, citazioni, i
where size([c in citazioni where c >= i]) >= i
with a, category, max(i) as H_index
return category, avg(H_index) as avg_H_index, max(H_index) as max_H_index
order by avg_H_index desc
limit 20;

match (a:Author)-[:WRITE]->(d:Document)-[:HAS]->(k:KeyWord)
with a, k.KeyWordAU as keyword, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, keyword, citazioni, i
where size([c in citazioni where c >= i]) >= i
with a, keyword, max(i) as H_index
return keyword, avg(H_index) as avg_H_index, max(H_index) as max_H_index
order by avg_H_index desc
limit 20;

match (a:Author)-[:WRITE]->(d:Document)
with a, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, citazioni, i
where size([c in citazioni where c >= i]) >= i
with a, max(i) as H_index

// calcolo collaborazioni locali e internazionali
match (a)-[:WRITE]->(d:Document)
with a, H_index, d
return a.Author_name as autore,
       H_index,
       sum(count { match (d)-[:HAS_COLLABORATION]->() return 1 }) as local_collab,
       sum(count { match (d)-[:HAS_INTERNATIONAL_COLLABORATION]->() return 1 }) as international_collab
order by H_index desc, international_collab desc
limit 20;

// calcolo H-index per autore
// trova top 50 autori per H-index
match (a:Author)-[:WRITE]->(d:Document)
with a, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, citazioni, i
where size([c in citazioni where c >= i]) >= i
with a, max(i) as H_index
order by H_index desc
limit 50

// coautori forti: almeno 2 pubblicazioni in comune
match (a)-[:WRITE]->(d:Document)<-[:WRITE]-(co:Author)
where a <> co
with a, H_index, co, count(d) as shared_docs
where shared_docs >= 2

// calcolo H-index medio dei coautori forti
match (co)-[:WRITE]->(d2:Document)
with a, H_index, co, shared_docs, collect(toInteger(d2.N_Cit_NoSelf)) as citazioni_co
unwind range(1, size(citazioni_co)) as i
with a, H_index, co, shared_docs, citazioni_co, i
where size([c in citazioni_co where c >= i]) >= i
with a, H_index, co, shared_docs, max(i) as H_index_co
with a, H_index, avg(H_index_co) as avg_H_index_coautori_forti
return a.Author_name as autore,
       H_index,
       round(avg_H_index_coautori_forti,1) as avg_H_index_coautori_forti
order by H_index desc, avg_H_index_coautori_forti desc
limit 20;

match (a:Author)-[:ASSOCIATED_WITH]->(s:SSD)-[:PART_OF]->(ar:Area)
where a.H_index is not null
with ar.Area_Full_Name as area, collect(a.H_index) as h_indexes, count(distinct a) as num_author
unwind h_indexes as h
return area, num_author,
       avg(h) as avg_H_index_autori,
       max(h) as max_H_index_autori,
       min(h) as min_H_index_autori
order by avg_H_index_autori desc;

match (a:Author)-[:ASSOCIATED_WITH]->(s:SSD)
where a.H_index is not null
with s.SSD_abbr as SSD, collect(a.H_index) as h_indexes, count(distinct a) as num_author, collect(a.Author_name) as authors
unwind h_indexes as h
return SSD, num_author, authors,
       avg(h) as avg_H_index_autori,
       max(h) as max_H_index_autori,
       min(h) as min_H_index_autori
order by avg_H_index_autori desc;

// H-index per autori UNIMORE
match (a:Author)-[:WRITE]->(d:Document)
match (a)-[:WORKS_IN]->(:Department)
with a, collect(toInteger(d.N_Cit_NoSelf)) as citazioni
unwind range(1, size(citazioni)) as i
with a, citazioni, i
where size([c in citazioni where c >= i]) >= i
with a, max(i) as H_index

// calcolo collaborazioni locali e internazionali
match (a)-[:WRITE]->(d:Document)
where (a)-[:WORKS_IN]->(:Department)
optional match (d)-[:HAS_COLLABORATION]->()
with a, H_index, count(*) as local_collab
optional match (d)-[:HAS_INTERNATIONAL_COLLABORATION]->()
return a.Author_name as autore,
       H_index,
       local_collab,
       count(*) as international_collab
order by H_index desc, international_collab desc
limit 20;

//evoluzione temporale 
match (d:Document)-[:PUBLISHED_IN]->()-[:BELONGS_TO_CATEGORY]->(c:Category)
return c.SubjectCategory as category, d.YearOfPublication as anno, count(d) as numDocs
order by category, anno asc;

match (d:Document)
return d.YearOfPublication as year, count(d) as numDocs
order by year;

