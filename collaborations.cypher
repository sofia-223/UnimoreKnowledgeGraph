match (d:Document)-[:HAS_COLLABORATION]->(:LocalCollaboration)
match (d)-[:HAS]->(k:KeyWord)
with k.KeyWordAU as Keyword, count(distinct d) as NumLocalCollab
return Keyword, NumLocalCollab
order by NumLocalCollab desc
limit 20;


match (d:Document)-[:HAS_INTERNATIONAL_COLLABORATION]->(:InternationalCollaboration)
match (d)-[:HAS]->(k:KeyWord)
with k.KeyWordAU as Keyword, count(distinct d) as NumInternationalCollab
return Keyword, NumInternationalCollab
order by NumInternationalCollab desc
limit 20;

match (d:Document)-[:HAS_INTERNATIONAL_COLLABORATION]->(:InternationalCollaboration)
match (d)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
with c.SubjectCategory as Category, count(distinct d) as NumInternationalCollab
return Category, NumInternationalCollab
order by NumInternationalCollab desc
limit 20;

match (d:Document)-[:HAS_COLLABORATION]->(:LocalCollaboration)
match (d)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
with c.SubjectCategory as Category, count(distinct d) as NumLocalCollab
return Category, NumLocalCollab
order by NumLocalCollab desc
limit 20;

match (d:Document)-[:HAS_INTERNATIONAL_COLLABORATION]->(:InternationalCollaboration)
match (d)-[:HAS]->(t:Topic)
with t.TopicScopus as Topic, count(distinct d) as NumInternationalCollab
return Topic, NumInternationalCollab
order by NumInternationalCollab desc
limit 20;

match (d:Document)-[:HAS_COLLABORATION]->(:LocalCollaboration)
match (d)-[:HAS]->(t:Topic)
with t.TopicScopus as Topic, count(distinct d) as NumLocalCollab
return Topic, NumLocalCollab
order by NumLocalCollab desc
limit 20;

call gds.graph.project(
  'local-collab',
  ['Document', 'LocalCollaboration'],
  {
    HAS_COLLABORATION: {
      type: 'HAS_COLLABORATION',
      orientation: 'UNDIRECTED'
    }
  }
);

call gds.degree.stream('local-collab')
yield nodeId, score
with gds.util.asNode(nodeId) as n, score
where 'Document' in labels(n)
return n.Title as document, score as numCollaborazioni
order by numCollaborazioni desc
limit 20;

call gds.graph.project(
  'intl-collab',
  ['Document', 'InternationalCollaboration'],
  {
    HAS_INTERNATIONAL_COLLABORATION: {
      type: 'HAS_INTERNATIONAL_COLLABORATION',
      orientation: 'UNDIRECTED'
    }
  }
);

call gds.degree.stream('intl-collab')
yield nodeId, score
with gds.util.asNode(nodeId) as n, score
where 'Document' in labels(n)
return n.Title as document, score as numCollaborazioniInternazionali
order by numCollaborazioniInternazionali desc
limit 20;

call gds.betweenness.stream('local-collab')
yield nodeId, score
with gds.util.asNode(nodeId) as n, score
where 'Document' in labels(n)
return n.Title as document, score as betweenness
order by betweenness desc
limit 20;


match (d:Document)-[:PUBLISHED_IN]->(:Source)-[:BELONGS_TO_CATEGORY]->(c:Category)
with c.SubjectCategory as Category, collect(d) as Docs
// conta quanti di questi documenti hanno collaborazioni internazionali
with Category, 
     size(Docs) as TotalDocs,
     size([doc in Docs where (doc)-[:HAS_INTERNATIONAL_COLLABORATION]->(:InternationalCollaboration) | doc]) as IntlCollabDocs
return Category, TotalDocs, IntlCollabDocs, 
       toFloat(IntlCollabDocs)/TotalDocs*100 as PercentInternationalCollab
order by PercentInternationalCollab desc
limit 20
