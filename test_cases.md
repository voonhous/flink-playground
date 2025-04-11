# Flink State upgrade test

## 0.15.0 -> 1.0.1 / 1.0.1 -> 1.0.2 FLINK_STATE upgrade
```shell
./bin/sql-client.sh -f examples/test_scripts/flink_state_demo.sql

flink stop job-id 

./bin/sql-client.sh \
  -Dexecution.savepoint.path=/opt/flink/examples/hudi_demo/savepoints/savepoint-abc \
  -Dexecution.savepoint.ignore-unclaimed-state=false \
  -f examples/test_scripts/flink_state_demo.sql
```

## NBCC 1.0.1 -> 1.0.2 upgrade

```shell
./bin/sql-client.sh -f examples/test_scripts/nbcc_demo.sql

flink stop job-id 

./bin/sql-client.sh \
  -Dexecution.savepoint.path=/opt/flink/examples/hudi_demo/savepoints/savepoint-abc \
  -Dexecution.savepoint.ignore-unclaimed-state=false \
  -f examples/test_scripts/nbcc_demo_0.sql


./bin/sql-client.sh \
  -Dexecution.savepoint.path2=/opt/flink/examples/hudi_demo/savepoints/savepoint-xyz \
  -Dexecution.savepoint.ignore-unclaimed-state=false \
  -f examples/test_scripts/nbcc_demo_1.sql
```
