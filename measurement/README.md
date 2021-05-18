
# Setting up the data

First create a sqlite database file using `askgit`: 

```askgit export askgit-commits-stats-db -e commits -e "SELECT * FROM commits" -e stats -e "SELECT * FROM stats"```

Next, create the views we rely on for the interval queries by running the script:

```cat create-folder-commit-interval-views.sql| sqlite3 askgit-commits-stats-db```

Now the sqlite database is ready to be queried.

# Query the data

One simple option to visualize the data is to use Metabase. Metabase is an application that has the ability to load data from a sqlite file on the local filesystem. You can set up questions (graphs) using the SQL queries in `metabase-queries`, and choose how to visualize them. You can then display them in a dashboard. This might end up looking something like this:

![example metabase dashboard](https://github.com/benjvi/apps-gitops/blob/main/measurement/metabase-dashboard.png)

One note - you may want to also add corresponding panels for Prod Delivery Throughput and Delivery Lead Time. These aren't shown in the image due to lack of data.
