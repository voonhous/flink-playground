-- NB-CC demo
SET 'execution.checkpointing.interval' = '30s';


CREATE TABLE sourceT (
  uuid varchar(20),
  name varchar(10),
  age int,
  ts timestamp(3),
  `partition` as 'par1'
) WITH (
  'connector' = 'datagen',
  'rows-per-second' = '200'
);

create table t1_2(
  uuid varchar(20),
  name varchar(10),
  age int,
  ts timestamp(3),
  `partition` varchar(20)
)
with (
  'connector' = 'hudi',
  'path' = '/opt/flink/examples/hudi_demo/t1',
  'table.type' = 'MERGE_ON_READ',
  'index.type' = 'BUCKET',
  'hoodie.write.concurrency.mode' = 'NON_BLOCKING_CONCURRENCY_CONTROL',
  'write.tasks' = '2',
  'compaction.schedule.enabled' = 'false',
  'compaction.async.enabled' = 'false',
  'clean.async.enabled' = 'false'
);

insert into t1_2 select * from sourceT;
