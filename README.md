# Apache-Nutch

* Nutch is a production ready web crawler that works in tandem with Apache Solr

## Docker installation

* Docker is a containerization tool used for developing, packaging and running applications
* Install Docker on the host machine with the [instructions outlined here](https://docs.docker.com/engine/install/)
### Initialize Swarm

* Docker Swarm is a container orchestration tool which consists of multiple services on a given node
* A Docker host can be a manager or a worker node or both in some cases
* Initialize a node of 1 (where the manager and the worker are the same node) 
```
  docker swarm init
```
* Deploy the Apache Nutch Application using
```
docker stack deploy -c docker-compose.yml nutch-tutorial
```
* Stop the Apache Nutch Docker stack using
```
docker stack rm nutch-tutorial
```
## Getting started

* Apache Nutch is a production ready web crawler to fetch, parse and index website data into Apache Solr
* Lifecycle of  Apache Nutch crawl
![Lifecycle of an Apache Nutch crawl](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*P8r3uuWkzhlpVgk9.png)

[Add image citation here]
* Seed: *TODO
* Crawl: *TODO
* Fetch: Generates a fetch list of all the  pages that are due to be fetched
* Parse: *TODO
* Index: *TODO
* Segment: Segment is a partition created, which contains the actual content that was fetched. It has 4 sub-directories 
### Technical Documentation
#### Config updates
* TODO - Move these steps into the Docker file
	* Navigate to `/root/nutch_source/runtime/local/conf` and update the following files
		* Replace the contents of the file  `nutch-site.xml`. 
		
```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->
<configuration>
<property>
 <name>http.agent.name</name>
 <value>My Nutch Spider</value>
</property>
</configuration>
```

* Navigate to `/root/nutch_source/runtime/local/conf/vim index-writers.xml` and update the url param.  
```
 <param name="url" value="http://solr:8983/solr/nutch"/>
```
* Enter the Nutch Docker container using 
```
docker exec -it `docker ps -aqf name='nutch-tutorial_nutch'` bash
```
* Inject url's into the db using
```
nutch inject crawl/crawldb urls
```
* Generate a fetch list from the database
```
nutch generate crawl/crawldb crawl/segments
```
* Fetch url's using
```
nutch fetch [-D...] <segment>

# Example

nutch fetch path/to/the/segment
```
* Parse the fetched entries using 
```
nutch parse [-D...] <segment>

# Example

nutch fetch path/to/the/segment
```
* Read the segments parsed. This gives the list of url's identified during the initial crawl
```
nutch readseg -dump crawl/segments/{segment_file} outputdir2 -nocontent -nofetch - nogenerate -noparse -noparsetext
```
* Index data into Solr
```
nutch index crawl/crawldb/ -linkdb crawl/linkdb/ crawl/segments/{segment_file} -filter -normalize -deleteGone
```
## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
