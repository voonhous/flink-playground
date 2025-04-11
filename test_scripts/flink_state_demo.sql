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

CREATE TABLE t1(
  uuid varchar(20),
  name varchar(10),
  age int,
  ts timestamp(3),
  `partition` varchar(20)
) WITH (
  'connector' = 'hudi',
  'path' = '/opt/flink/examples/hudi_demo/t1',
  'table.type' = 'MERGE_ON_READ',
  'index.type' = 'FLINK_STATE',
  'write.tasks' = '2'
);

INSERT INTO t1 SELECT * FROM sourceT;

