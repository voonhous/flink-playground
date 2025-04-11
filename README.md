# Intro

This repository is a store of useful scripts used for testing running manual flink tests. The main applications of these scripts are mainly for:

1. Debugging
2. Compatibility/Migration testing 

# Starting the cluster

To increase the number of TaskManager containers (scale) using Docker Compose, you can use the scale key directly inside the `env-compose.yml` file. Or one can override it using the scale with the docker-compose CLI. An example of how to do this is shown below:

```shell
docker-compose up --scale taskmanager=3
```

Once you have executed the `docker-compose up` command, you can navigate to the `flink-web-ui` at **localhost:8082**.

Note, Hudi and Docker images (Flink) are all using Java 8. 


# Building the docker images

Each Docker image file has a naming convention as such:
`flink.Dockerfile.{hudi-version}`

The tag follows the following naming convention:
`hudi_local_tests:flink1.18__hudi_{hudi-version}`

To build the docker images:

```shell
docker build -f docker_files/flink.Dockerfile.1.0.1 -t hudi_local_tests:flink1.18__hudi_1.0.1 .
```

**NOTE**: For flink-bundle jars that have not been released, and you would like to do tests for, you will need to manually compile the flink-bundle-jar, then copy it `/opt/flink/lib` before building as such:

```
# Copy local file into the image
COPY hudi_jars/hudi-flink1.18-bundle-1.0.2.jar /opt/flink/lib/
```

## Missing dependencies

To ensure that the container is lightweight, we are not including the full Hadoop dependencies, i.e. including the entire hadoop library and exporting its path as an env variable.

Instead, we will be copying the required jar dependencies to `/opt/flink` and building the docker images. Should there be any dependency errors, feel free to add the requried jars to the Docker image files and rebuild them.

## Starting the cluster

To start the cluster, modify the Docker-Compose file's image to the Hudi version you are testing on for both `jobmanager` and `taskmaanger`.


```yml
image: hudi_local_tests:flink1.18__hudi_1.0.1
```

Then start the cluster as such:
```shell
sh start.sh
```

## Stopping the cluster

To stop the cluster:
```shell
sh teardown.sh
```

# Mounted Volumes

Mounted volumes on taskmanagers are:
```yml
- ./hudi_demo:/opt/flink/examples/hudi_demo
```

Mounted volumes on jobmanagers are:
```yml
- ./test_scripts:/opt/flink/examples/test_scripts
- ./hudi_demo:/opt/flink/examples/hudi_demo
```

- **hudi_demo**: For storing savepoints and table data
- **test_scripts**: For storing sql testing scripts


# Submitting Jobs

Flink includes a SQL Client CLI, and it's the easiest way to submit SQL jobs directly to your cluster.

## Option 1: Use sql-client CLI inside a container

1. Start your cluster (if not already):

This command starts a cluster with 2 taskmanagers.

```shell
docker-compose up --scale taskmanager=2 -d
```

2. Exec into the JobManager container:

```shell
docker exec -it jobmanager bash
```

3. **Start the SQL Client** inside the container:

```shell
./bin/sql-client.sh
```

4. From here, you can run Flink SQL queries interactively or use the `sql-client.sh` to submit `.sql` or `.jar` jobs (see below).


## Option 2: Submit SQL job from file (non-interactive)

1. Create a SQL file (e.g., myjob.sql):


```sql
CREATE TABLE source (
  id INT,
  name STRING
) WITH (
  'connector' = 'datagen'
);

CREATE TABLE sink (
  id INT,
  name STRING
) WITH (
  'connector' = 'print'
);

INSERT INTO sink SELECT * FROM source;
```

2. Copy it into the container:

```sql
docker cp myjob.sql jobmanager:/opt/myjob.sql
```

3. Run it:

```sql
docker exec -it jobmanager ./bin/sql-client.sh -f /opt/myjob.sql
```

# Stopping jobs

Since savepoint directory is configured, stopping a job will trigger a savepoint save by default
```
flink stop job-id
```

# Restoring jobs from savepoint

One-liner to Run SQL File from Savepoint:
```
./bin/sql-client.sh \
  -Dexecution.savepoint.path=file:///opt/flink/examples/hudi_demo/savepoints/savepoint-123 \
  -Dexecution.savepoint.ignore-unclaimed-state=false \
  -f flink_state_demo.sql
```

# Debugging
If job manager exits with `Exited (239)`, it's likely specific to the application or entrypoint inside the container.

## 1. Check container logs

```shell
docker logs <container_id_or_name>
```
