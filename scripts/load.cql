MATCH (n) DETACH DELETE n;

// First we create our constraints:
//  * faster import
//  * prevent duplicate nodes
//  * ensure partial schema

// Turbine
create constraint on (t:Turbine) assert t.case_id is unique;
create constraint on (t:Turbine) assert exists (t.case_id);

// Project
create constraint on (p:Project) assert p.name is unique;
create constraint on (p:Project) assert exists (p.name);

// ImageSource
create constraint on (i:ImageSource) assert i.name is unique;
create constraint on (i:ImageSource) assert exists (i.name);

// Model
create constraint on (m:Model) assert m.name is unique;
create constraint on (m:Model) assert exists (m.name);

// Manufacturer
create constraint on (m:Manufacturer) assert m.name is unique;
create constraint on (m:Manufacturer) assert exists (m.name);

// Load our turbines via CSV:

// Set the url via "reference"
with 'https://gist.githubusercontent.com/clschnei/1a0442b8a29040a48a348d9f7f653498/raw/fd30f7bfc555c1cc1335485c76f5cca34000aab6/uswtdb_v2_3_20200109.csv' as url

// Row headers made available for easy attribute reference
load csv with headers
  from url as row

  // "merge" will help prevent duplicate node creations
  merge (t:Turbine { case_id: row.case_id })

  set
    // "+=" syntax will add all properties of "row" into the node
    t += row,
    t.xlong = toFloat(row.xlong),
    t.ylat = toFloat(row.ylat)

  return count(t);

// Create Manufacturer + Model nodes and relationships

match (t:Turbine)
  // ensure that we have information available
  where t.t_manu is not null and t.t_model is not null

  // Again, using "merge" to prevent duplicates
  merge (mo:Model { name: t.t_model })
  merge (ma:Manufacturer { name: t.t_manu })

  // By virtue of having the new nodes available to reference
  // we can immediately bind these new relationships
  merge (t)-[:MATERIAL]->(mo)
  merge (t)-[:MATERIAL]->(ma)
  merge (mo)-[:MADE_BY]->(ma)

  return count(mo), count(ma);

// Create ImageSource + Project nodes and relationships

match (t:Turbine)
  merge (i:ImageSource { name: t.t_img_srce })
  merge (t)-[it:IMAGE_TAKEN]->(i)
  return count(i);

match (t:Turbine)
  merge (p:Project { name: t.p_name })
  merge (t)-[b:BUILT]->(p)
  set p.year = t.p_year
  return count(p);


docker-compose run db bash

cypher-shell -u neo4j -p j4oen -a bolt://db:7687 -f /scripts/load.cql
