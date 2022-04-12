#!/usr/bin/env bash

ADDRESS=$1

if [ -z "$ADDRESS" ]; then
  ADDRESS="localhost:9200"
fi

# Check that Elasticsearch is running
curl -H 'Content-Type: application/json' -s "http://$ADDRESS" &>/dev/null
if [ $? != 0 ]; then
  echo "Unable to contact Elasticsearch at $ADDRESS"
  echo "Please ensure Elasticsearch is running and can be reached at http://$ADDRESS/"
  exit 1
fi

echo "WARNING, this script will delete the 'get-together' and the 'myindex' indices and re-index all data!"
echo "Press Control-C to cancel this operation."
echo
echo "Press [Enter] to continue."
read -r

# Delete the old index, swallow failures if it doesn't exist
curl -H 'Content-Type: application/json' -s -XDELETE "$ADDRESS/get-together_group" >/dev/null
curl -H 'Content-Type: application/json' -s -XDELETE "$ADDRESS/get-together_event" >/dev/null

# Create the next index using mapping_group.json
echo "Creating 'get-together' index..."
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group" -d@$(dirname $0)/mapping_group.json
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event" -d@$(dirname $0)/mapping_event.json

# Wait for index to become yellow
curl -H 'Content-Type: application/json' -s "$ADDRESS/get-together_group/_health?wait_for_status=yellow&timeout=10s" >/dev/null
echo
echo "Done creating 'get-together' index."

echo
echo "Indexing data..."

echo "Indexing groups..."
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group/_doc/1" -d'{
  "name": "Denver Clojure",
  "organizer": ["Daniel", "Lee"],
  "description": "Group of Clojure enthusiasts from Denver who want to hack on code together and learn more about Clojure",
  "created_on": "2012-06-15",
  "tags": ["clojure", "denver", "functional programming", "jvm", "java"],
  "members": ["Lee", "Daniel", "Mike"],
  "location_group": "Denver, Colorado, USA"
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group/_doc/2" -d'{
  "name": "Elasticsearch Denver",
  "organizer": "Lee",
  "description": "Get together to learn more about using Elasticsearch, the applications and neat things you can do with ES!",
  "created_on": "2013-03-15",
  "tags": ["denver", "elasticsearch", "big data", "lucene", "solr"],
  "members": ["Lee", "Mike"],
  "location_group": "Denver, Colorado, USA"
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group/_doc/3" -d'{
  "name": "Elasticsearch San Francisco",
  "organizer": "Mik",
  "description": "Elasticsearch group for ES users of all knowledge levels",
  "created_on": "2012-08-07",
  "tags": ["elasticsearch", "big data", "lucene", "open source"],
  "members": ["Lee", "Igor"],
  "location_group": "San Francisco, California, USA"
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group/_doc/4" -d'{
  "name": "Boulder/Denver big data get-together",
  "organizer": "Andy",
  "description": "Come learn and share your experience with nosql & big data technologies, no experience required",
  "created_on": "2010-04-02",
  "tags": ["big data", "data visualization", "open source", "cloud computing", "hadoop"],
  "members": ["Greg", "Bill"],
  "location_group": "Boulder, Colorado, USA"
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_group/_doc/5" -d'{
  "name": "Enterprise search London get-together",
  "organizer": "Tyler",
  "description": "Enterprise search get-togethers are an opportunity to get together with other people doing search.",
  "created_on": "2009-11-25",
  "tags": ["enterprise search", "apache lucene", "solr", "open source", "text analytics"],
  "members": ["Clint", "James"],
  "location_group": "London, England, UK"
}'

echo
echo "Done indexing groups."

echo "Indexing events..."

curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/100" -d'{
  "group_id": "1",
  "host": ["Lee", "Troy"],
  "title": "Liberator and Immutant",
  "description": "We will discuss two different frameworks in Clojure for doing different things. Liberator is a ring-compatible web framework based on Erlang Webmachine. Immutant is an all-in-one enterprise application based on JBoss.",
  "attendees": ["Lee", "Troy", "Daniel", "Tom"],
  "date": "2013-09-05T18:00",
  "location_event": {
    "name": "Stoneys Full Steam Tavern",
    "geolocation": "39.752337,-105.00083"
  },
  "reviews": 4
}'
echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/101" -d'{
  "group_id": "1",
  "host": "Sean",
  "title": "Sunday, Surly Sunday",
  "description": "Sort out any setup issues and work on Surlybird issues. We can use the EC2 node as a bounce point for pairing.",
  "attendees": ["Daniel", "Michael", "Sean"],
  "date": "2013-07-21T18:30",
  "location_event": {
    "name": "IRC, #denofclojure"
  },
  "reviews": 2
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/102" -d'{
  "group_id": "1",
  "host": "Daniel",
  "title": "10 Clojure coding techniques you should know, and project openbike",
  "description": "What are ten Clojure coding techniques that you wish everyone knew? We will also check on the status of Project Openbike.",
  "attendees": ["Lee", "Tyler", "Daniel", "Stuart", "Lance"],
  "date": "2013-07-11T18:00",
  "location_event": {
    "name": "Stoneys Full Steam Tavern",
    "geolocation": "39.752337,-105.00083"
  },
  "reviews": 3
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/103" -d'{
  "group_id": "2",
  "host": "Lee",
  "title": "Introduction to Elasticsearch",
  "description": "An introduction to ES and each other. We can meet and greet and I will present on some Elasticsearch basics and how we use it.",
  "attendees": ["Lee", "Martin", "Greg", "Mike"],
  "date": "2013-04-17T19:00",
  "location_event": {
    "name": "Stoneys Full Steam Tavern",
    "geolocation": "39.752337,-105.00083"
  },
  "reviews": 5
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/104" -d'{
  "group_id": "2",
  "host": "Lee",
  "title": "Queries and Filters",
  "description": "A get together to talk about different ways to query Elasticsearch, what works best for different kinds of applications.",
  "attendees": ["Lee", "Greg", "Richard"],
  "date": "2013-06-17T18:00",
  "location_event": {
    "name": "Stoneys Full Steam Tavern",
    "geolocation": "39.752337,-105.00083"
  },
  "reviews": 1
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/105" -d'{
  "group_id": "2",
  "host": "Lee",
  "title": "Elasticsearch and Logstash",
  "description": "We can get together and talk about Logstash - http://logstash.net with a sneak peek at Kibana",
  "attendees": ["Lee", "Greg", "Mike", "Delilah"],
  "date": "2013-07-17T18:30",
  "location_event": {
    "name": "Stoneys Full Steam Tavern",
    "geolocation": "39.752337,-105.00083"
  },
  "reviews": null
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/106" -d'{
  "group_id": "3",
  "host": "Mik",
  "title": "Social management and monitoring tools",
  "description": "Shay Banon will be there to answer questions and we can talk about management tools.",
  "attendees": ["Shay", "Mik", "John", "Chris"],
  "date": "2013-03-06T18:00",
  "location_event": {
    "name": "Quid Inc",
    "geolocation": "37.798442,-122.399801"
  },
  "reviews": 5
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/107" -d'{
  "group_id": "3",
  "host": "Mik",
  "title": "Logging and Elasticsearch",
  "description": "Get a deep dive for what Elasticsearch is and how it can be used for logging with Logstash as well as Kibana!",
  "attendees": ["Shay", "Rashid", "Erik", "Grant", "Mik"],
  "date": "2013-04-08T18:00",
  "location_event": {
    "name": "Salesforce headquarters",
    "geolocation": "37.793592,-122.397033"
  },
  "reviews": 3
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/108" -d'{
  "group_id": "3",
  "host": "Elyse",
  "title": "Piggyback on Elasticsearch training in San Francisco",
  "description": "We can piggyback on training by Elasticsearch to have some Q&A time with the ES devs",
  "attendees": ["Shay", "Igor", "Uri", "Elyse"],
  "date": "2013-05-23T19:00",
  "location_event": {
    "name": "NoSQL Roadshow",
    "geolocation": "37.787742,-122.398964"
  },
  "reviews": 5
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/109" -d'{
  "group_id": "4",
  "host": "Andy",
  "title": "Hortonworks, the future of Hadoop and big data",
  "description": "Presentation on the work that hortonworks is doing on Hadoop",
  "attendees": ["Andy", "Simon", "David", "Sam"],
  "date": "2013-06-19T18:00",
  "location_event": {
    "name": "SendGrid Denver office",
    "geolocation": "39.748477,-104.998852"
  },
  "reviews": 2
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/110" -d'{
  "group_id": "4",
  "host": "Andy",
  "title": "Big Data and the cloud at Microsoft",
  "description": "Discussion about the Microsoft Azure cloud and HDInsight.",
  "attendees": ["Andy", "Michael", "Ben", "David"],
  "date": "2013-07-31T18:00",
  "location_event": {
    "name": "Bing Boulder office",
    "geolocation": "40.018528,-105.275806"
  },
  "reviews": 1
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/111" -d'{
  "group_id": "4",
  "host": "Andy",
  "title": "Moving Hadoop to the mainstream",
  "description": "Come hear about how Hadoop is moving to the main stream",
  "attendees": ["Andy", "Matt", "Bill"],
  "date": "2013-07-21T18:00",
  "location_event": {
    "name": "Courtyard Boulder Louisville",
    "geolocation": "39.959409,-105.163497"
  },
  "reviews": 4
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/112" -d'{
  "group_id": "5",
  "host": "Dave Nolan",
  "title": "real-time Elasticsearch",
  "description": "We will discuss using Elasticsearch to index data in real time",
  "attendees": ["Dave", "Shay", "John", "Harry"],
  "date": "2013-02-18T18:30",
  "location_event": {
    "name": "SkillsMatter Exchange",
    "geolocation": "51.524806,-0.099095"
  },
  "reviews": 3
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/113" -d'{
  "group_id": "5",
  "host": "Dave",
  "title": "Elasticsearch at Rangespan and Exonar",
  "description": "Representatives from Rangespan and Exonar will come and discuss how they use Elasticsearch",
  "attendees": ["Dave", "Andrew", "David", "Clint"],
  "date": "2013-06-24T18:30",
  "location_event": {
    "name": "Alumni Theatre",
    "geolocation": "51.51558,-0.117699"
  },
  "reviews": 3
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "$ADDRESS/get-together_event/_doc/114" -d'{
  "group_id": "5",
  "host": "Yann",
  "title": "Using Hadoop with Elasticsearch",
  "description": "We will walk through using Hadoop with Elasticsearch for big data crunching!",
  "attendees": ["Yann", "Bill", "James"],
  "date": "2013-09-09T18:30",
  "location_event": {
    "name": "SkillsMatter Exchange",
    "geolocation": "51.524806,-0.099095"
  },
  "reviews": 2
}'

echo
echo "Done indexing events."

# Refresh so data is available
curl -H 'Content-Type: application/json' -s -XGET "$ADDRESS/get-together_event/_refresh"

echo
echo "Done indexing data."
echo

echo
echo "Creating Templates."
curl -H 'Content-Type: application/json' -s -XPUT "http://$ADDRESS/_template/logging_index_all" -d'{
  "index_patterns": "logstash-09-*",
  "order": 1,
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "date": {
        "type": "date",
        "store": false
      }
    }
  },
  "aliases": {
    "november": {}
  }
}'

echo
curl -H 'Content-Type: application/json' -s -XPUT "http://$ADDRESS/_template/logging_index" -d '{
    "index_patterns" : "logstash-*",
    "order" : 0,
    "settings" : {
        "number_of_shards" : 2,
        "number_of_replicas" : 1
   },
    "mappings" : {
      "properties": {
        "date": {
          "type": "date",
          "store": false
        }
      }
    }
}'
echo
echo "Done Creating Templates."

echo
echo "Adding Dynamic Mapping"
curl -H 'Content-Type: application/json' -s -XDELETE "http://$ADDRESS/myindex" >/dev/null
curl -H 'Content-Type: application/json' -s -XPUT "http://$ADDRESS/myindex" -d'
{
    "mappings" : {
        "properties" : {
        }
    }
}'
echo
echo "Done Adding Dynamic Mapping"

echo
echo "Adding Aliases"
curl -H 'Content-Type: application/json' -s -XDELETE "http://$ADDRESS/november_2014_invoices" >/dev/null
curl -H 'Content-Type: application/json' -s -XDELETE "http://$ADDRESS/december_2014_invoices" >/dev/null
curl -H 'Content-Type: application/json' -s -XPUT "http://$ADDRESS/november_2014_invoices" -d'{}'
echo
curl -H 'Content-Type: application/json' -s -XPUT "http://$ADDRESS/december_2014_invoices" -d'
{
    "mappings" : {
        "properties" : {
            "revenue" : { "type" : "integer" }
        }
    }
}'

echo

curl -H 'Content-Type: application/json' -s -XPOST "http://$ADDRESS/_aliases" -d'
{
    "actions": [
        {
            "add": {
                "index": "november_2014_invoices",
                "alias": "2014_invoices"
            }
        },
        {
            "add": {
                "index": "december_2014_invoices",
                "alias": "2014_invoices"
            }
        },
        {
            "remove": {
                "index": "myindex",
                "alias": "december_2014_invoices"
            }
        }
    ]
}'

echo
echo "Done Adding Aliases"

echo "Adding Filter Alias"
curl -H 'Content-Type: application/json' -s -XPOST "http://$ADDRESS/_aliases" -d '
{
    "actions" : [
        {
            "add" : {
                 "index" : "december_2014_invoices",
                 "alias" : "bigmoney",
                 "filter" :
                 {
                    "range" :
                    {
                      "revenue" :
                      {
                        "gt" : 1000
                      }

                    }
                 }
            }
        }
    ]
}'
echo
echo "Done Adding Filter Alias"

echo
echo "Adding Routing Alias"
curl -H 'Content-Type: application/json' -s -XPOST "http://$ADDRESS/_aliases" -d '
{
    "actions" : [
        {
            "add" : {
                 "index" : "december_2014_invoices",
                 "alias" : "2014_invoices",
                 "search_routing" : "en,es",
                 "index_routing" : "en"
            }
        }
    ]
}'
echo
echo "Done Adding Routing Alias"

echo
