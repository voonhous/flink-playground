SET sql-client.execution.result-mode=tableau;

-- Execute using Flink + Hudi 0.15.x (v6)
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

INSERT INTO hudi_migration_test VALUES
  ('1', 'alice', TIMESTAMP '2024-04-01 10:00:00', '2024-04-01'),
  ('2', 'bob',   TIMESTAMP '2024-04-01 11:00:00', '2024-04-01');


SELECT * FROM hudi_migration_test;
-- Expect: 2 rows


-- Try partition listing
SHOW PARTITIONS hudi_migration_test;
