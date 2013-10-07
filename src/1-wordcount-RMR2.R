#!/usr/bin/env Rscript

#
# Example 1: wordcount
#
# Tally the number of occurrences of each word in a text
#
# from https://github.com/RevolutionAnalytics/RHadoop/wiki/Tutorial
#

library(rmr2)
Sys.getenv('HADOOP_CMD')
Sys.getenv('HADOOP_STREAMING')
# Sys.setenv(HADOOP_CMD="/usr/bin/hadoop-0.20")
Sys.setenv(HADOOP_CMD="/usr/bin/hadoop")
Sys.setenv(HADOOP_STREAMING="/usr/lib/hadoop-0.20-mapreduce/contrib/streaming/hadoop-streaming-2.0.0-mr1-cdh4.3.0.jar")


# Set "LOCAL" variable to T to execute using rmr's local backend.
# Otherwise, use Hadoop (which needs to be running, correctly configured, etc.)

LOCAL=F

if (LOCAL)
{
  rmr.options(backend = 'local')
  
  # we have smaller extracts of the data in this project's 'local' directory
  hdfs.data.root = 'data/local/wordcount'
  hdfs.data = file.path(hdfs.data.root, 'all-shakespeare-1000')
  
  hdfs.out.root = 'out/wordcount'
  
  hdfs.out = file.path(hdfs.out.root, 'out')
  
  if (!file.exists(hdfs.out))
    dir.create(hdfs.out.root, recursive=T)
  
} else {
  rmr.options(backend = 'hadoop')
  
  # assumes 'wordcount' and wordcount/data exists on HDFS under user's home directory
  # (e.g., /user/cloudera/wordcount/ & /user/cloudera/wordcount/data/)
  
  hdfs.data.root = 'wordcount'
  hdfs.data = file.path(hdfs.data.root, 'data')
  
  # unless otherwise specified, directories on HDFS should be relative to user's home
  hdfs.out.root = hdfs.data.root
  hdfs.out = file.path(hdfs.out.root, 'out')
}


# map = function(k,v) {
# 	lapply(
# 		strsplit(x = v, split = '\\W')[[1]], # '\\W' is regular expression speak for "non-word character"
# 				function(w) keyval(w,1)
# 		)
# }

pattern = " "

wc.map = 
  function(., lines) {
    keyval(
      unlist(
        strsplit(
          x = lines,
          split = pattern)),
      1)}

# reduce = function(k,vv) {
# 	keyval(k, sum(unlist(vv)))
# }
wc.reduce =
  function(word, counts ) {
    keyval(word, sum(counts))}

# wordcount = function (input, output = NULL) {
# 	mapreduce(input = input ,
# 			  output = output,
# 			  input.format = "text",
# 			  map = map,
# 			  reduce = reduce,
# 			  combine = T)}
wordcount = 
  function(
    input, 
    output = NULL, 
    pattern = " "){
    mapreduce(
      input = input ,
      output = output,
      input.format = "text",
      map = wc.map,
      reduce = wc.reduce,
      combine = T)}

out = wordcount(hdfs.data, hdfs.out)

df = as.data.frame( from.dfs(out) )
colnames(df) = c('word', 'count')

# sort by count:
df = df[order(-df$count),]

print(head(df))
