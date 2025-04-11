SET sql-client.execution.result-mode=tableau;

-- Re-create the same table in Flink with Hudi 1.0.2
CREATE TABLE hudi_migration_test (
  id STRING,
  name STRING,
  ts TIMESTAMP(3),
  dt STRING
)
PARTITIONED BY (dt)
WITH (
  'connector' = 'hudi',
  'path' = '/opt/flink/examples/hudi_demo/migration_test',
  'table.type' = 'MERGE_ON_READ',
  'write.precombine.field' = 'ts',
  'write.operation' = 'upsert',
  'compaction.async.enabled' = 'false',
  'hoodie.datasource.write.recordkey.field' = 'id',
  'hoodie.datasource.write.partitionpath.field' = 'dt',
  'hoodie.metadata.enable' = 'true'
);

SELECT * FROM hudi_migration_test;
-- Expect: 2 rows

INSERT INTO hudi_migration_test VALUES
  ('3', 'charlie', TIMESTAMP '2024-04-02 09:00:00', '2024-04-02'),
  ('1', 'alice-updated', TIMESTAMP '2024-04-02 10:00:00', '2024-04-01');  -- update existing id

SELECT * FROM hudi_migration_test ORDER BY id;
-- Expect: 3 rows


-- Try partition listing
SHOW PARTITIONS hudi_migration_test;