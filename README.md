### What it is

My sqlplus script has been designed to dump, in a **concise and complete** text report, all the informations that are needed to tune a SGA-resident SQL statement.  

When tuning (or simply studying) a statement, one typically needs or eagerly wants:

*   the _accessed tables definition_ (columns, indexes, partitions) and their CBO-related statistics
*   the text of referenced views, PL/SQL functions or packages (and sequences, evil triggers, etc)
*   its plan, and for every plan line, its performance measures (i.e. elapsed time, buffer gets, rows returned, etc)
*   peeked bind values and types
*   instance and session parameters, and system statistics
*   wait event profile from ASH (Active Session History)

All these informations are automatically dumped by xplan, sparing us from a lot of tedious and error-prone work.  

You can identify the statement(s) you want in the report by matching a like-expression, or by sql_id, hash_value, module, action, instance_id, parsing user, or a combination of them. E.g.:  

```
SQL>@xplan "select%my_table%" "module=MY_MODULE,parsed_by=WEB_USER"
```

This dumps all select statements that reference my_table, issued by module MY_MODULE and parsed by WEB_USER.  

Please note that since xplan is a sqlplus script, **you don't need to install anything anywhere** - you just need sqlplus and an account with the necessary privileges.  

You can find more details in the main script (xplan.sql) header, and a report example below.

### Report example

A report example from Oracle 11g (from demo script xplan_showcase.sql) - comments surrounded by "**":  

SQL> @xplan "%xplan_test_marker%" ""  

```
**Misc database infos:**
xplan version 2.5.3 23-Aug-2012 (C) Copyright 2008-2012 Alberto Dell'Era, www.adellera.it
db_name=ora11gr2 instance_name=ora11gr2 version=11.2.0.3.0 (compatible = 11.2.0.0.0)

**Instance CBO-related parameters:**
optimizer parameters instance(sys) settings:
------------------------------------------------- --------------------------------------------- ---------------------------------------------
|optimizer param name                 |value    | |optimizer param name             |value    | |optimizer param name        |value         |
------------------------------------------------- --------------------------------------------- ---------------------------------------------
|active_instance_count                |       1 | |optimizer_mode                   |all_rows | |parallel_query_mode         |      enabled |
|bitmap_merge_area_size               | 1048576 | |optimizer_secure_view_merging    |    true | |parallel_threads_per_cpu    |            2 |
|cell_offload_compaction              |ADAPTIVE | |optimizer_use_invisible_indexes  |   false | |pga_aggregate_target        |    204800 KB |
|cell_offload_plan_display            |    AUTO | |optimizer_use_pending_statistics |   false | |query_rewrite_enabled       |         true |
|cell_offload_processing              |    true | |optimizer_use_sql_plan_baselines |    true | |query_rewrite_integrity     |     enforced |
|cpu_count                            |       2 | |parallel_autodop                 |       0 | |result_cache_mode           |       MANUAL |
|cursor_sharing                       |   exact | |parallel_ddl_mode                | enabled | |skip_unusable_indexes       |         true |
|db_file_multiblock_read_count        |     128 | |parallel_ddldml                  |       0 | |sort_area_retained_size     |            0 |
|deferred_segment_creation            |    true | |parallel_degree                  |       0 | |sort_area_size              |        65536 |
|dst_upgrade_insert_conv              |    true | |parallel_degree_limit            |   65535 | |star_transformation_enabled |        false |
|hash_area_size                       |  131072 | |parallel_degree_policy           |  manual | |statistics_level            |      typical |
|is_recur_flags                       |       0 | |parallel_dml_mode                |disabled | |total_cpu_count             |            2 |
|optimizer_capture_sql_plan_baselines |   false | |parallel_execution_enabled       |    true | |total_processor_group_count |            1 |
|optimizer_dynamic_sampling           |       2 | |parallel_force_local             |   false | |transaction_isolation_level |read_commited |
|optimizer_features_enable            |11.2.0.3 | |parallel_max_degree              |       4 | |workarea_size_policy        |         auto |
|optimizer_index_caching              |       0 | |parallel_min_time_threshold      |      10 | ---------------------------------------------
|optimizer_index_cost_adj             |     100 | |parallel_query_default_dop       |       0 |
------------------------------------------------- ---------------------------------------------

**CBO system statistics:**
optimizer system statistics:
---------------------------------------- -------------------------- --------------------------
|system statistic |value               | |system statistic |value | |system statistic |value |
---------------------------------------- -------------------------- --------------------------
|status           |          completed | |cpuspeednw       |1,842 | |ioseektim        |   10 |
|gathering start  |2010-04-15/17:12:00 | |sreadtim         | null | |iotfrspeed       |4,096 |
|gathering stop   |2010-04-15/17:12:00 | |mreadtim         | null | |maxthr           | null |
|cpuspeed         |               null | |mbrc             | null | |slavethr         | null |
---------------------------------------- -------------------------- --------------------------

**Sstatement identity, and miscellaneous infos:**
sql_id=cdcyga72r9f01 hash=3312760833 child_number=0 plan_hash=4202265887 module=SQL*Plus
first_load: 2012/08/25 11:38:28 last_load: 2012/08/25 11:38:28 last_active: 2012/08/25 11:38:42
parsed_by=DELLERA inst_id=1

**Statistics from v$sql ( /exec is the stat value divided by v$sql.executions):**
-------------------------------------------- --------------------------------- --------------------------------------------------
|gv$sql statname |total      |/exec        | |gv$sql statname |total  |/exec | |gv$sql statname         |total     |/exec       |
-------------------------------------------- --------------------------------- --------------------------------------------------
|executions      |         1 |             | |sorts           |     1 |  1.0 | |users_executing         |        0 |         .0 |
|rows_processed  |         1 |         1.0 | |fetches         |     1 |  1.0 | |application wait (usec) |        0 |         .0 |
|buffer_gets     |    63,839 |    63,839.0 | |end_of_fetch_c  |     1 |  1.0 | |concurrency wait (usec) |        0 |         .0 |
|disk_reads      |       160 |       160.0 | |parse_calls     |     1 |  1.0 | |cluster     wait (usec) |        0 |         .0 |
|direct_writes   |         0 |          .0 | |sharable_mem    |34,974 |      | |user io     wait (usec) |1,444,402 |1,444,402.0 |
|elapsed (usec)  |13,971,325 |13,971,325.0 | |persistent_mem  |29,736 |      | |plsql exec  wait (usec) |       11 |       11.0 |
|cpu_time (usec) |12,562,500 |12,562,500.0 | |runtime_mem     |28,700 |      | |java  exec  wait (usec) |        0 |         .0 |
-------------------------------------------- --------------------------------- --------------------------------------------------

**Statement text:**
SELECT /*+ index(t,t_fbi) ordered use_nl(v) xplan_test_marker */ T.RR, PLSQL_FUNC(MAX(T.X)) FROM T, V WHERE UPPER(T.X) >= '0' AND T.X > :B1 AND V.RR
='x' GROUP BY T.RR ORDER BY T.RR

**Names of non-table objects depended on (from v$object_dependency) - full definition at the bottom of the report:**
- depends on view DELLERA.V
- depends on function DELLERA.PLSQL_FUNC

**Peeked binds values, and bind infos:** 
bind_sensitive
peeked binds values: :B1 = 0
peeked binds types : :B1 = number(22)

**Plan (format similar to dbms_xplan one) and most important infos (columns ending with "+" are self statistics):**
------------------------------------------------------------------------------------------------------------------------------
|CR+CU |CR+CU+|Ela       |Ela+      |Id|Operation                  |Name |Table|Erows  |Arows    |Cost  |IoCost|Psta|Psto|IdP|
-last---last---last-------last----------------------------------------------------------last----------------------------------
|63,062|     =|13,099,838|         =| 0|SELECT STATEMENT           |     |     |       |        1|12,894|      |    |    |   |
|63,062|     =|13,099,838|+2,058,481| 1| SORT GROUP BY             |     |     |      1|        1|12,894|12,827|    |    |   |
|63,062|     =|11,041,357|+3,958,949| 2|  NESTED LOOPS             |     |     |999,500|1,000,000|12,852|12,827|    |    |   |
| 1,050|     =|   479,553|    +4,061| 3|   PARTITION RANGE ITERATOR|     |     |  1,000|    1,000|    96|    96|KEY |3   |  3|
| 1,050|+1,000|   475,492|   +31,840| 4|    INDEX UNIQUE SCAN      |T_PK |T    |  1,000|    1,000|    96|    96|KEY |3   |  3|
|    50|    50|   443,652|   443,652| 5|     INDEX RANGE SCAN      |T_FBI|T    |     64|    1,000|    49|    49|KEY |3   |  3|
|62,012|     =| 6,602,855|+3,964,550| 6|   PARTITION RANGE ALL     |     |     |  1,000|1,000,000|    13|    13|1   |3   |  6|
|62,012|62,012| 2,638,305| 2,638,305| 7|    INDEX FAST FULL SCAN   |T_PK |T    |  1,000|1,000,000|    13|    13|1   |3   |  6|
---------------usec-------usec------------------------------------------------------------------------------------------------
.   4 - access[ T.X>:B1 AND T.SYS_NC00004$>='0' ]
.   5 - access[ T.X>:B1 AND T.SYS_NC00004$>='0' ]
.     - filter[ T.SYS_NC00004$>='0' ]
.   7 - filter[ (RR='x' AND X>0) ]

**Wait event profile (from ASH):**
----------------------------------
|ash event              |cnt|%   |
----------------------------------
|cpu                    | 10|76.9|
|db file sequential read|  3|23.1|
----------------------------------

**Main plan statistics:**
 **CR=Consistent Reads, CU=CUrrent reads, diskR=Disk Reads, diskW=Disk Writes, etc.** 
----------------------------------------------------------------------------------------------------
|Id|Starts|CR    |CR+   |CU  |diskR|diskR+|diskW|E0ram|E1ram|Aram |Policy|A01M   |0/1/M|ActTim     |
----last---last---last---last-last--last---last--------------last---------last----------avg---------
| 0|     1|63,062|     =|   0|  103|     =|    0|     |     |     |      |       |     |           |
| 1|     1|63,062|     =|   0|  103|     =|    0|3,072|3,072|2,048|MANUAL|OPTIMAL|1/0/0|132,552,130|
| 2|     1|63,062|     =|   0|  103|     =|    0|     |     |     |      |       |     |           |
| 3|     1| 1,050|     =|   0|   51|     =|    0|     |     |     |      |       |     |           |
| 4|     3| 1,050|+1,000|   0|   51|    +1|    0|     |     |     |      |       |     |           |
| 5|     3|    50|    50|   0|   50|    50|    0|     |     |     |      |       |     |           |
| 6| 1,000|62,012|     =|   0|   52|     =|    0|     |     |     |      |       |     |           |
| 7| 3,000|62,012|62,012|   0|   52|    52|    0|     |     |     |      |       |     |           |
-------------------------------------------------KB----KB----KB-------------------#-----msec--------
note: stats Aram, A01M, 0/1/M, ActTim do not seem to be always accurate.

**Additional plan details (qb_name, alias, column projection information):**
-----------------------------------------------------------------------------------------------
|Id|Qb_name     |ObjAlias|ObjType       |Obj  |BaseObj|Projection                             |
-----------------------------------------------------------------------------------------------
| 0|            |        |              |     |       |                                       |
| 1|SEL$F5BB74E1|        |              |     |       |(#keys=1)T.RR,MAX(T.X)                 |
| 2|            |        |              |     |       |T.X,T.RR                               |
| 3|            |        |              |     |       |T.X,T.RR                               |
| 4|SEL$F5BB74E1|T@SEL$1 |INDEX (UNIQUE)|T_PK |T      |T.X,T.RR                               |
| 5|SEL$F5BB74E1|T@SEL$1 |INDEX         |T_FBI|T      |T.ROWID,T.X,T.RR,T.SYS_NC00004$,T.ROWID|
| 6|            |        |              |     |       |                                       |
| 7|SEL$F5BB74E1|T@SEL$2 |INDEX (UNIQUE)|T_PK |T      |                                       |
-----------------------------------------------------------------------------------------------

**CBO-related parameters different from instance ones:**
WARNING: 6 params in gv$sql_optimizer_env are not the same as instance ones:
---------------------------------- -------------------------------- -------------------------------
|optimizer param name   |value   | |optimizer param name |value   | |optimizer param name |value  |
---------------------------------- -------------------------------- -------------------------------
|_smm_auto_cost_enabled |  false | |sort_area_size       |2000000 | |statistics_level     |   all |
|hash_area_size         |2000000 | |sqlstat_enabled      |   true | |workarea_size_policy |manual |
---------------------------------- -------------------------------- -------------------------------

**Accessed table(s) informations:**
############################################# table DELLERA.T ###
PARTITIONED BY RANGE ( X, PADDING )
IOT

**Accessed table columns definitions and constraints :**
 **Note that the FBI expression for hidden columns is provided**
 **Note the concise index/constraint report on the right**
 **E.g. Index #4 is a Unique index on (X,PADDING)**
 **Index #1 is a non-unique index on (X, UPPER(TO_CHAR("X")), PADDING )**
 **Primary Key is on (X,PADDING)**
 **Unique Constraint U2 is on (PADDING,X)**
 **Unique Constraint U1 is referenced (R) by some FK from another table**
 **Foreign Key R1 is from column RR**
----------------------------------------------------------------------
|Id|IId|V|ColName     |Type                |Null|Expression|1|2|3|4|5|
-------------------------------------------------trunc------------U-U-
| 1|  1|N|X           |NUMBER              |NOT |          |1|1|2|1| |
| 2|  2|N|PADDING     |VARCHAR2 (1200 byte)|NOT |          |3| |1|2|1|
| 3|  3|N|RR          |VARCHAR2 (1 byte)   |yes |          | | | | | |
|  |  4|Y|SYS_NC00004$|VARCHAR2 (40 byte)  |yes |I:UPPER(TO|2| | | | |
|  |  5|Y|SYS_NC00005$|VARCHAR2 (6 byte)   |yes |I:CASE "X"| |2| | | |
----------------------------------------------------------------------
----------------------------------
|Id|IId|V|ColName     |P|U1|U2|R1|
----------------------------------
| 1|  1|N|X           |1|  |2 |  |
| 2|  2|N|PADDING     |2|R1|1 |  |
| 3|  3|N|RR          | |  |  |1 |
|  |  4|Y|SYS_NC00004$| |  |  |  |
|  |  5|Y|SYS_NC00005$| |  |  |  |
----------------------------------
-----------------------------------------------------------------------------------------------------------------------------
|ColName     |Expression (full)                                                                                             |
-----------------------------------------------------------------------------------------------------------------------------
|SYS_NC00004$|I:UPPER(TO_CHAR("X"))                                                                                         |
|SYS_NC00005$|I:CASE "X" WHEN 0 THEN 'pippo' WHEN 1 THEN 'uuiio' WHEN 3 THEN 'uuciio' WHEN 4 THEN 'uuieio' ELSE 'pppppp' END|
-----------------------------------------------------------------------------------------------------------------------------

**Accessed table CBO statistics (for partitions too):**
-------------------------------------------------------------------------------
|Pid|Partition|num_rows|avg_row_len|sample_size|last_analyzed      |parallel  |
-------------------------------------------------------------------------------
|   |         |    1000|        318|       1000|2012/08/22 16:18:38|         1|
|  1|P1       |     100|        316|        100|2012/08/22 16:18:38|          |
|  2|P2       |     100|        318|        100|2012/08/22 16:18:38|          |
|  3|POTHER   |     800|        318|        800|2012/08/22 16:18:38|          |
-------------------------------------------------------------------------------

**Accessed table columns CBO statistics (for partitions too):**
----------------------------------------------------------------------------------------------------------
|ColName     |Partition|ndv  |dens*#rows|num_nulls|#bkts|hist|avg_col_len|sample_size|last_analyzed      |
----------------------------------------------------------------------------------------------------------
|X           |         |1,000|       1.0|        0|  254|HB  |          4|      1,000|2012/08/25 11:38:24|
|PADDING     |         |1,000|       1.0|        0|  254|HB  |        301|      1,000|2012/08/25 11:38:24|
|RR          |         |    1|       0.5|        0|    1|FREQ|          2|      1,000|2012/08/25 11:38:24|
|SYS_NC00004$|         |1,000|       1.0|        0|  254|HB  |          4|      1,000|2012/08/25 11:38:24|
|SYS_NC00005$|         |    4|       0.5|        0|    4|FREQ|          7|      1,000|2012/08/25 11:38:24|
|X           |P1       |  100|       5.0|        0|  100|HB  |          3|        100|2012/08/25 11:38:24|
|X           |P2       |  100|       5.0|        0|  100|HB  |          4|        100|2012/08/25 11:38:24|
|X           |POTHER   |  800|       1.3|        0|  254|HB  |          4|        800|2012/08/25 11:38:24|
|PADDING     |P1       |  100|       5.0|        0|  100|HB  |        301|        100|2012/08/25 11:38:24|
|PADDING     |P2       |  100|       5.0|        0|  100|HB  |        301|        100|2012/08/25 11:38:24|
|PADDING     |POTHER   |  800|       1.3|        0|  254|HB  |        301|        800|2012/08/25 11:38:24|
|RR          |P1       |    1|       5.0|        0|    1|FREQ|          2|        100|2012/08/25 11:38:24|
|RR          |P2       |    1|       5.0|        0|    1|FREQ|          2|        100|2012/08/25 11:38:24|
|RR          |POTHER   |    1|       0.6|        0|    1|FREQ|          2|        800|2012/08/25 11:38:24|
|SYS_NC00004$|P1       |  100|       5.0|        0|  100|HB  |          3|        100|2012/08/25 11:38:24|
|SYS_NC00004$|P2       |  100|       5.0|        0|  100|HB  |          4|        100|2012/08/25 11:38:24|
|SYS_NC00004$|POTHER   |  800|       1.3|        0|  254|HB  |          5|        800|2012/08/25 11:38:24|
|SYS_NC00005$|P1       |    4|       5.0|        0|    4|FREQ|          7|        100|2012/08/25 11:38:24|
|SYS_NC00005$|P2       |    1|       5.0|        0|    1|FREQ|          7|        100|2012/08/25 11:38:24|
|SYS_NC00005$|POTHER   |    1|       0.6|        0|    1|FREQ|          7|        800|2012/08/25 11:38:24|
----------------------------------------------------------------------------------------------------------

**Accessed table index(es) definitions and CBO statistics (for partitions too):**
### index #1: DELLERA.T_FBI
on DELLERA.T ( X, SYS_NC00004$, PADDING )
NONUNIQUE FUNCTION-BASED B+TREE
LOCAL PARTITIONED BY RANGE ( X, PADDING )
---------------------------------------------------------------------------------------------------
|Partition|distinct_keys|num_rows|blevel|leaf_blocks|cluf|sample_size|last_analyzed      |parallel|
---------------------------------------------------------------------------------------------------
|         |        1,000|   1,000|     1|         47|  47|      1,000|2012/08/25 11:38:25|1       |
|P1       |          100|     100|     1|          5|   5|        100|2012/08/25 11:38:25|        |
|P2       |          100|     100|     1|          5|   5|        100|2012/08/25 11:38:25|        |
|POTHER   |          800|     800|     1|         37|  37|        800|2012/08/25 11:38:25|        |
---------------------------------------------------------------------------------------------------
### index #2: DELLERA.T_FBI2
on DELLERA.T ( X, SYS_NC00005$ )
NONUNIQUE FUNCTION-BASED B+TREE
-----------------------------------------------------------------------------------------
|distinct_keys|num_rows|blevel|leaf_blocks|cluf|sample_size|last_analyzed      |parallel|
-----------------------------------------------------------------------------------------
|        1,000|   1,000|     1|         46|  47|      1,000|2012/08/25 11:38:25|1       |
-----------------------------------------------------------------------------------------
### index #3: DELLERA.T_IDX
on DELLERA.T ( PADDING, X )
NONUNIQUE B+TREE
LOCAL PARTITIONED BY RANGE ( X, PADDING )
---------------------------------------------------------------------------------------------------
|Partition|distinct_keys|num_rows|blevel|leaf_blocks|cluf|sample_size|last_analyzed      |parallel|
---------------------------------------------------------------------------------------------------
|         |        1,000|   1,000|     1|         47|  64|      1,000|2012/08/25 11:38:25|1       |
|P1       |          100|     100|     1|          5|  21|        100|2012/08/25 11:38:25|        |
|P2       |          100|     100|     1|          5|   5|        100|2012/08/25 11:38:25|        |
|POTHER   |          800|     800|     1|         37|  38|        800|2012/08/25 11:38:25|        |
---------------------------------------------------------------------------------------------------
### index #4: DELLERA.T_PK
on DELLERA.T ( X, PADDING )
UNIQUE IOT - TOP
LOCAL PARTITIONED BY RANGE ( X, PADDING )
---------------------------------------------------------------------------------------------------
|Partition|distinct_keys|num_rows|blevel|leaf_blocks|cluf|sample_size|last_analyzed      |parallel|
---------------------------------------------------------------------------------------------------
|         |        1,000|   1,000|     1|         47|   0|      1,000|2012/08/25 11:38:25|1       |
|P1       |          100|     100|     1|          5|   0|        100|2012/08/25 11:38:25|        |
|P2       |          100|     100|     1|          5|   0|        100|2012/08/25 11:38:25|        |
|POTHER   |          800|     800|     1|         37|   0|        800|2012/08/25 11:38:25|        |
---------------------------------------------------------------------------------------------------
### index #5: DELLERA.T_UQ_1
on DELLERA.T ( PADDING )
UNIQUE B+TREE
-----------------------------------------------------------------------------------------
|distinct_keys|num_rows|blevel|leaf_blocks|cluf|sample_size|last_analyzed      |parallel|
-----------------------------------------------------------------------------------------
|        1,000|   1,000|     1|         46| 231|      1,000|2012/08/25 11:38:25|1       |
-----------------------------------------------------------------------------------------

**Definition of dependent objects (e.g. accessed views, packages, functions):**
############################################# function DELLERA.PLSQL_FUNC ###
ASSOCIATED STATISTICS:  default selectivity (.001) default cost (cpu=100 io=10 net=1)
function plsql_func (p varchar2)
return varchar2
is
begin
  return p;
end plsql_func;
############################################# view DELLERA.V ###
view columns: #1 X(NUMBER),#2 PADDING(VARCHAR2),#3 RR(VARCHAR2)
select x, padding, rr
  from t
 where x > 0

**Options and Statement text filter SQL-like expression summary:**
OPTIONS: inst_id=1 plan_stats=last access_predicates=Y lines=150 ash_profile_mins=15 module= action= hash= sql_id= parsed_by= child_number=
dbms_xplan=N dbms_metadata=N plan_details=Y plan_env=Y tabinfos=Y objinfos=Y partinfos=Y self=Y order_by= numbers_with_comma=Y
spool_name=xplan_i1.lst spool_files=single
SQL_LIKE="%xplan_test_marker%"

**Licence warning:**
-- Warning: since ash_profile_mins > 0, you are using ASH/AWR; make sure you are licensed to use it.

```