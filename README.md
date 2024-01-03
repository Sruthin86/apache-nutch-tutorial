# Apache-Nutch

- Nutch is a production ready web crawler that works in tandem with Apache Solr

## Problem Statement

Springshare's search API does search full text but it does not return the matching full text snippet. The full text snippet provides more context to the matched results and this is a feature requested by the Reference & Discovery Services team.

## Docker installation

- Docker is a containerization tool used for developing, packaging and running applications
- Install Docker on the host machine with the [instructions outlined here](https://docs.docker.com/engine/install/)

### Initialize Swarm

- Docker Swarm is a container orchestration tool which consists of multiple services on a given node
- A Docker host can be a manager or a worker node or both in some cases
- Initialize a node of 1 (where the manager and the worker are the same node)

```
  docker swarm init
```

- Build the custom nutch image using

```
docker build ./ -t nutch:msul --no-cache
```

- Build the custom solr image using

```
docker build ./solr -t solr:msul --no-cache
```

- Deploy the Apache Nutch Application using

```
docker stack deploy -c docker-compose.yml nutch-tutorial
```

- Stop the Apache Nutch Docker stack using

```
docker stack rm nutch-tutorial
```

## Getting started with Nutch

- Apache Nutch is a production ready web crawler to fetch, parse and index website data into Apache Solr
- Lifecycle of Apache Nutch crawl [![Lifecycle of an Apache Nutch crawl](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*P8r3uuWkzhlpVgk9.png)](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*P8r3uuWkzhlpVgk9.png)

_Source: [https://medium.com/@mobomo/the-basics-working-with-nutch-e5a7d37af231](https://medium.com/@mobomo/the-basics-working-with-nutch-e5a7d37af231)_

### Glossary

- **Seed**: List of url's that are ready to be fetched and indexed
- **Inject**: Reads the list of url's from the seed file and add them to the list of pages to be crawled. This list is updated with additional metadata in the next steps of the lifecycle.
- **Generate**: Reads the list of injected url's and creates segments based on the eligibility of a page/url.
- **Segment**: Segment is a partition created, which contains the fetch list, content, and the parsed content. The content in segment varies at different stages of the lifecycle.
- **Fetch**: Reads the fetch list from the segments and requests the content for each of the url's in the list.
- **Parse**: Processes the content fetched and primes it for indexing into Solr. This step includes identifying the title, page url, and page body from the fetched content.
- **Index**: Indexes data into a Lucene based search.
- **Lucene**: A java based full-text indexing and searching software.
- **Solr**: A wrapper around Lucene providing a GUI and adding the ability to configure indexing and searching.
- **Hadoop Map Files**: A directory containing 2 files, *data* and *index*. Data file consists of key and values and the index file consists of fraction of the keys. The index file is loaded into the memory for quick lookup.

### Technical Documentation

#### Config updates

- TODO - Move these steps into the Docker file
    - Navigate to `/root/nutch_source/runtime/local/conf` and update the following files
        - Replace the contents of the file  `nutch-site.xml`.

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

- Navigate to `/root/nutch_source/runtime/local/conf/index-writers.xml` and update the url param.

```
 <param name="url" value="http://solr:8983/solr/nutch"/>
```

- Enter the Nutch Docker container using

```
docker exec -it `docker ps -aqf name='nutch-tutorial_nutch'` bash
```

##### Seed
* A text file containing list of url's with one url per line.
* The url's can contain optional metadata  separated by tabs, represented in key=value format
```
https://libguides.lib.msu.edu/ISB202Taylor
https://libguides.lib.msu.edu/ISB202Taylor nutch.score=10 nutch.fetchInterval=2592000
```
##### Inject
- A seeds.txt file is required for this step. This is the starting point for Nutch to crawl the url's
- Inject url's into the db using

```
nutch inject crawl/crawldb urls
```

##### Generate
- Extracts the url's from url's from the seeds file and queues them for fetching.
- After the first crawl Nutch will generate the url's from hyperlinks on the parsed pages.
- Generate a fetch list from the database

```
bin/nutch generate <crawldb> <segments_dir> [-force] [-adddays numDays]

# Example
nutch generate crawl/crawldb crawl/segments
```

##### Fetch
- Crawls the url's from the generate step and fetches the content.
- Fetch url's using

```
nutch fetch [-D...] <segment>

# Example

nutch fetch path/to/the/segment
```
* Number of threads used for fetching can be passed as an argument.
* Increasing the thread count could make the fetch go faster but may overwhelm the server
```
nutch fetch path/to/the/segment -threads 50
```

##### Parse
- Organizes the data scraped by the fetcher.
- Parse the fetched entries using

```
nutch parse [-D...] <segment>

# Example

nutch parse path/to/the/segment
```

- Read the segments parsed. This gives the list of url's identified during the initial crawl

```
nutch readseg -dump crawl/segments/{segment_file} outputdir2 -nocontent -nofetch - nogenerate -noparse -noparsetext

# options for reading segments

-nocontent: Pass this to ignore the content directory.

-nofetch: To ignore the crawl_fetch directory.

-nogenerate: To ignore the crawl_generate directory.

-noparse: To ignore the crawl_parse directory.

-noparsedata: To ignore the parse_data directory.

-noparsetext: To ignore the parse_text directory.
```

##### Updatedb
- Marks the url's for future generate steps.
- Update the the db with additional metadata after fetch

```
nutch updatedb crawl/crawldb path/to/the/segment
```

##### Index
- Index data into Solr

```
nutch index crawl/crawldb/ -linkdb crawl/linkdb/ crawl/segments/{segment_file} -filter -deleteGone
```

### Getting started with Solr

Solr is initialized as a prat of this stack and a `nutch` core is created during container startup. Nutch provides us with a baseline schema for the core which needs to be updated in Solr. Additional configurations can be added to the schema based on requirements

- Copy the Nutch schema into the newly created nutch core inside of the docker container

```
Exec into container using
docker exec -it `docker ps -aqf name='nutch-tutorial_solr'` bash

Schema location: /solr/managed-schema
Container location: /var/solr/data/nutch/conf
```

- Solr is available inside the container on port `8983` and can be accessed by other services in the atck using `http://solr:8983`
- Solr is available on the host machine on  `80` and can be accessed using `http://localhost:80`

