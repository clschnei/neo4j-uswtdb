# Getting Started

```shell
docker-compose up -d

docker-compose run db bash

cypher-shell -u neo4j -p j4oen -a bolt://db:7687 -f /scripts/load.cql
```

# Making Queries

http://0.0.0.0:7474/browser/

```
user: neo4j
password: j4oen
```

# Sample Queries

```cql
// Any models that have two manufacturers?
match (a:Manufacturer)--(b:Model)--(c:Manufacturer) return *;

// How many projects by year?
match (p:Project) return distinct p.year, count(p) order by p.year;

// How many turbines per year?
match (p:Project)--(t:Turbine) return distinct p.year, count(t) order by p.year;

// Turbines per state
match (t:Turbine) return distinct t.t_state, count(t) order by count(t) desc;

// Average distance between turbines in a project
match (a:Turbine)--(p:Project)--(b:Turbine)
with
  point({ latitude: a.ylat, longitude: a.xlong }) as aPoint,
  point({ latitude: b.ylat, longitude: b.xlong }) as bPoint,
  p,
  a
return
  distinct p.name,
  avg(distance(aPoint, bPoint)) as average_distance,
  count(a)
order by average_distance;
```
