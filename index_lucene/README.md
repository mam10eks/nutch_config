# Index Nutch Segments into Lucene index

First you need to adapt the file `index_data.sh`:
* Adapt the variable `CRAWL_DIRECTORIES` that it contains all directories where crawls could be obtained
  * **Please only operate on copies of those directories! Never use the original data. Best approach is to backup regularly your crawls, and use copies of this backups as input for this script**


If you have adapted the `CRAWL_DIRECTORIES` to point to copies of your crawl directories, simply execute
```
./index_data.sh
```

This will do the following:

* Start a prepared solr instance by leveraging a docker image
* Remove all parsing data from the segments
  * **Hence one could experiment safely with different parsing approaches**
* Merge all segments to obtain an overall crawldb
* Inversion of links to obtain an overall linkdb
* Deduplication of documents
  * **Hence one could experiment safely with different deduplication approaches**
* Index all documents into the solr instance
* Shutdown of the solr instance
  * You could obtain the lucene instance from the directory `solr_cores/uni_leipzig_core/data/index`
