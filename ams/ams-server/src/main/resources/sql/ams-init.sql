CREATE TABLE `catalog_metadata`
(
    `catalog_id`         int(11) NOT NULL AUTO_INCREMENT,
    `catalog_name`       varchar(64) NOT NULL,
    `display_name`       varchar(64) DEFAULT NULL,
    `catalog_type`       varchar(64) NOT NULL,
    `storage_configs`    mediumtext,
    `auth_configs`       mediumtext,
    `catalog_properties` mediumtext,
    PRIMARY KEY (`catalog_id`),
    UNIQUE KEY `catalog_metadata_catalog_name_uindex` (`catalog_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `container_metadata`
(
    `name`       varchar(64) NOT NULL,
    `type`       varchar(64) NOT NULL,
    `properties` mediumtext,
    PRIMARY KEY (`name`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `database_metadata`
(
    `db_id`        int(11) NOT NULL AUTO_INCREMENT,
    `catalog_name` varchar(64) NOT NULL,
    `db_name`      varchar(64) NOT NULL,
    PRIMARY KEY (`db_id`),
    UNIQUE KEY `database_name_uindex` (`catalog_name`,`db_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `file_info_cache`
(
    `primary_key_md5`   varchar(64) NOT NULL,
    `table_identifier`   varchar(64) NOT NULL,
    `add_snapshot_id`    bigint(20) NOT NULL,
    `parent_snapshot_id` bigint(20) NOT NULL,
    `delete_snapshot_id` bigint(20) DEFAULT NULL,
    `inner_table`        varchar(64)          DEFAULT NULL,
    `file_path`          varchar(400)         NOT NULL,
    `file_type`          varchar(64)          DEFAULT NULL,
    `file_size`          bigint(20) DEFAULT NULL,
    `file_mask`          bigint(20) DEFAULT NULL,
    `file_index`         bigint(20) DEFAULT NULL,
    `spec_id`            bigint(20) DEFAULT NULL,
    `record_count`       bigint(20) DEFAULT NULL,
    `partition_name`     varchar(256)         DEFAULT NULL,
    `action`             varchar(64)          DEFAULT NULL,
    `commit_time`        timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `watermark`          timestamp  NULL DEFAULT NULL,
    PRIMARY KEY (`primary_key_md5`),
    KEY  `table_snap_index` (`table_identifier`,`add_snapshot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `optimize_file`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Auto increment id',
    `optimize_type` varchar(5)  NOT NULL COMMENT 'Optimize type: Major, Minor',
    `trace_id`      varchar(40) NOT NULL COMMENT 'Optimize task unique id',
    `file_type`     varchar(16) NOT NULL COMMENt 'File type: BASE_FILE, INSERT_FILE, EQ_DELETE_FILE, POS_DELETE_FILE',
    `is_target`     tinyint(4) DEFAULT '0' COMMENT 'Is file newly generated by optimizing',
    `file_content`  varbinary(60000) DEFAULT NULL COMMENT 'File bytes after serialization',
    PRIMARY KEY (`id`),
    KEY             `compact_task_id` (`optimize_type`,`trace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'Optimize files for Optimize task';

CREATE TABLE `optimize_history`
(
    `history_id`                     bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'History auto increment id',
    `catalog_name`                  varchar(64) NOT NULL COMMENT 'Catalog name',
    `db_name`                       varchar(64) NOT NULL COMMENT 'Database name',
    `table_name`                    varchar(64) NOT NULL COMMENT 'Table name',
    `optimize_range`                varchar(10) NOT NULL COMMENT 'Optimize Range: Table, Partition, Node',
    `visible_time`                  datetime(3) DEFAULT NULL COMMENT 'Latest visible time',
    `commit_time`                   datetime(3) DEFAULT NULL COMMENT 'Commit time',
    `plan_time`                     datetime(3) DEFAULT NULL COMMENT 'First plan time',
    `duration`                      bigint(20) DEFAULT NULL COMMENT 'Execute cost time',
    `total_file_cnt_before`         int(11) NOT NULL COMMENT 'Total file cnt before optimizing',
    `total_file_size_before`        bigint(20) NOT NULL COMMENT 'Total file size in bytes before optimizing',
    `insert_file_cnt_before`        int(11) NOT NULL COMMENT 'Insert file cnt before optimizing',
    `insert_file_size_before`       bigint(20) NOT NULL COMMENT 'Insert file size in bytes before optimizing',
    `delete_file_cnt_before`        int(11) NOT NULL COMMENT 'Delete file cnt before optimizing',
    `delete_file_size_before`       bigint(20) NOT NULL COMMENT 'Delete file size in bytes before optimizing',
    `base_file_cnt_before`          int(11) NOT NULL COMMENT 'Base file cnt before optimizing',
    `base_file_size_before`         bigint(20) NOT NULL COMMENT 'Base file size in bytes before optimizing',
    `pos_delete_file_cnt_before`    int(11) NOT NULL COMMENT 'Pos-Delete file cnt before optimizing',
    `pos_delete_file_size_before`   bigint(20) NOT NULL COMMENT 'Pos-Delete file size in bytes before optimizing',
    `total_file_cnt_after`          int(11) NOT NULL COMMENT 'Total file cnt after optimizing',
    `total_file_size_after`         bigint(20) NOT NULL COMMENT 'Total file cnt after optimizing',
    `snapshot_id`                   bigint(20) DEFAULT NULL COMMENT 'Snapshot id after commit',
    `total_size`                    bigint(20) DEFAULT NULL COMMENT 'Total size of the snapshot',
    `added_files`                   int(11) DEFAULT NULL COMMENT 'Added files cnt of the snapshot',
    `removed_files`                 int(11) DEFAULT NULL COMMENT 'Removed files cnt of the snapshot',
    `added_records`                 bigint(20) DEFAULT NULL COMMENT 'Added records of the snapshot',
    `removed_records`               bigint(20) DEFAULT NULL COMMENT 'Removed records of the snapshot',
    `added_files_size`              bigint(20) DEFAULT NULL COMMENT 'Added files size of the snapshot',
    `removed_files_size`            bigint(20) DEFAULT NULL COMMENT 'Removed files size of the snapshot',
    `total_files`                   bigint(20) DEFAULT NULL COMMENT 'Total file size of the snapshot',
    `total_records`                 bigint(20) DEFAULT NULL COMMENT 'Total records of the snapshot',
    `partition_cnt`                 int(11) NOT NULL COMMENT 'Partition cnt for this optimizing',
    `partitions`                    text COMMENT 'Partitions',
    `max_change_transaction_id` mediumtext COMMENT 'Max change transaction id of these tasks',
    `optimize_type`                 varchar(10) NOT NULL COMMENT 'Optimize type: Major, Minor',
    PRIMARY KEY (`history_id`),
    KEY                             `table_name_record` (`catalog_name`,`db_name`,`table_name`,`history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'History of optimizing after each commit';

CREATE TABLE `optimize_job`
(
    `job_id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `job_name`             varchar(1024) DEFAULT NULL,
    `queue_id`             int(11) DEFAULT NULL,
    `queue_name`           varchar(1024) DEFAULT NULL,
    `job_start_time`       varchar(1024) DEFAULT NULL,
    `job_fail_time`        varchar(1024) DEFAULT NULL,
    `job_status`           varchar(16)   DEFAULT NULL,
    `core_number`          int(11) DEFAULT NULL,
    `memory`               bigint(30) DEFAULT NULL,
    `parallelism`          int(11) DEFAULT NULL,
    `jobmanager_url`       varchar(1024) DEFAULT NULL,
    `optimizer_instance`   blob,
    `optimizer_state_info` mediumtext,
    `container`            varchar(50)   DEFAULT '',
    `update_time` timestamp not null default CURRENT_TIMESTAMP,
    PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `optimize_group`
(
    `group_id`   int(11) NOT NULL AUTO_INCREMENT  COMMENT 'Optimize group unique id',
    `name`       varchar(50) NOT NULL  COMMENT 'Optimize group name',
    `properties` mediumtext  COMMENT 'Properties',
    `container`  varchar(100) DEFAULT NULL  COMMENT 'Container: local, flink',
    PRIMARY KEY (`group_id`),
    UNIQUE KEY `uniqueName` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'Group to divide optimize resources';

CREATE TABLE `optimize_task`
(
    `trace_id`                  varchar(40) NOT NULL COMMENT 'Optimize task uuid',
    `optimize_type`                 varchar(10) NOT NULL COMMENT 'Optimize type: Major, Minor',
    `catalog_name`              varchar(64) NOT NULL COMMENT 'Catalog name',
    `db_name`                   varchar(64) NOT NULL COMMENT 'Database name',
    `table_name`                varchar(64) NOT NULL COMMENT 'Table name',
    `partition`                 varchar(128)  DEFAULT NULL COMMENT 'Partition',
    `task_group`                varchar(40)   DEFAULT NULL COMMENT 'Group of task, task of one group should commit together',
    `max_change_transaction_id` bigint(20) NOT NULL DEFAULT '-1' COMMENT 'Max change transaction id',
    `create_time`               datetime(3) DEFAULT NULL COMMENT 'Task create time',
    `properties`                text COMMENT 'Task properties',
    `queue_id`                  int(11) NOT NULL COMMENT 'Task group id',
    `insert_files`              int(11) DEFAULT NULL COMMENT 'Insert file cnt',
    `delete_files`              int(11) DEFAULT NULL COMMENT 'Delete file cnt',
    `base_files`                int(11) DEFAULT NULL COMMENT 'Base file cnt',
    `pos_delete_files`          int(11) DEFAULT NULL COMMENT 'Pos-Delete file cnt',
    `insert_file_size`          bigint(20) DEFAULT NULL COMMENT 'Insert file size in bytes',
    `delete_file_size`          bigint(20) DEFAULT NULL COMMENT 'Delete file size in bytes',
    `base_file_size`            bigint(20) DEFAULT NULL COMMENT 'Base file size in bytes',
    `pos_delete_file_size`      bigint(20) DEFAULT NULL COMMENT 'Pos-Delete file size in bytes',
    `source_nodes`              varchar(2048) DEFAULT NULL COMMENT 'Source nodes of task',
    `is_delete_pos_delete`      tinyint(4) DEFAULT NULL COMMENT 'Delete pos delete files or not',
    `task_history_id`           varchar(40)   DEFAULT NULL COMMENT 'Task history id',
    `status`        varchar(16)   DEFAULT NULL  COMMENT 'Optimize Status: Init, Pending, Executing, Failed, Prepared, Committed',
    `pending_time`  datetime(3) DEFAULT NULL COMMENT 'Time when task start waiting to execute',
    `execute_time`  datetime(3) DEFAULT NULL COMMENT 'Time when task start executing',
    `prepared_time` datetime(3) DEFAULT NULL COMMENT 'Time when task finish executing',
    `report_time`   datetime(3) DEFAULT NULL COMMENT 'Time when task report result',
    `commit_time`   datetime(3) DEFAULT NULL COMMENT 'Time when task committed',
    `job_type`      varchar(16)   DEFAULT NULL COMMENT 'Job type',
    `job_id`        varchar(32)   DEFAULT NULL COMMENT 'Job id',
    `attempt_id`    varchar(40)   DEFAULT NULL COMMENT 'Attempt id',
    `retry`         int(11) DEFAULT NULL COMMENT 'Retry times',
    `fail_reason`   varchar(4096) DEFAULT NULL COMMENT 'Error message after task failed',
    `fail_time`     datetime(3) DEFAULT NULL COMMENT 'Fail time',
    `new_file_size` bigint(20) DEFAULT NULL COMMENT 'File size generated by task executing',
    `new_file_cnt`  int(11) DEFAULT NULL COMMENT 'File cnt generated by task executing',
    `cost_time`     bigint(20) DEFAULT NULL COMMENT 'Task Execute cost time',
    PRIMARY KEY (`trace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'Optimize task basic information';

CREATE TABLE `snapshot_info_cache`
(
    `table_identifier`   varchar(64) NOT NULL,
    `snapshot_id`        bigint(20) NOT NULL,
    `parent_snapshot_id` bigint(20) NOT NULL,
    `action`             varchar(64)          DEFAULT NULL,
    `inner_table`        varchar(64)          NOT NULL,
    `commit_time`        timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`table_identifier`,`inner_table`,`snapshot_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `table_metadata`
(
    `catalog_name`    varchar(64) NOT NULL,
    `db_name`         varchar(64) NOT NULL,
    `table_name`      varchar(64) NOT NULL,
    `primary_key`     varchar(256) DEFAULT NULL,
    `sort_key`        varchar(256) DEFAULT NULL,
    `table_location`  varchar(256) DEFAULT NULL,
    `base_location`   varchar(256) DEFAULT NULL,
    `delta_location`  varchar(256) DEFAULT NULL,
    `properties`      text,
    `meta_store_site` mediumtext,
    `hdfs_site`       mediumtext,
    `core_site`       mediumtext,
    `hbase_site`      mediumtext,
    `auth_method`     varchar(32)  DEFAULT NULL,
    `hadoop_username` varchar(64)  DEFAULT NULL,
    `krb_keytab`      text,
    `krb_conf`        text,
    `krb_principal`   text,
    `current_tx_id`   bigint(20) DEFAULT NULL,
    PRIMARY KEY `table_name_index` (`catalog_name`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `optimize_table_runtime`
(
    `catalog_name`               varchar(64) NOT NULL COMMENT 'Catalog name',
    `db_name`                    varchar(64) NOT NULL COMMENT 'Database name',
    `table_name`                 varchar(64) NOT NULL COMMENT 'Table name',
    `current_snapshot_id`        bigint(20) NOT NULL DEFAULT '-1' COMMENT 'Base table current snapshot id',
    `latest_major_optimize_time` mediumtext COMMENT 'Latest Major Optimize time for all partitions',
    `latest_minor_optimize_time` mediumtext COMMENT 'Latest Minor Optimize time for all partitions',
    `latest_task_history_id`     varchar(40) DEFAULT NULL COMMENT 'Latest task history id',
    `optimize_status`            varchar(20) DEFAULT 'Idle' COMMENT 'Table optimize status: MajorOptimizing, MinorOptimizing, Pending, Idle',
    `optimize_status_start_time` datetime(3) DEFAULT NULL COMMENT 'Table optimize status start time',
    `current_change_snapshotId`  bigint(20) DEFAULT NULL COMMENT 'Change table current snapshot id',
    PRIMARY KEY `table_name_index` (`catalog_name`,`db_name`,`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'Optimize running information of each table';

CREATE TABLE `optimize_task_history`
(
    `catalog_name`    varchar(64) NOT NULL COMMENT 'Catalog name',
    `db_name`         varchar(64) NOT NULL COMMENT 'Database name',
    `table_name`      varchar(64) NOT NULL COMMENT 'Table name',
    `task_history_id` varchar(40) DEFAULT NULL COMMENT 'Task history id',
    `start_time`      datetime(3) DEFAULT NULL COMMENT 'Task start time',
    `end_time`        datetime(3) DEFAULT NULL COMMENT 'Task end time',
    `cost_time`       bigint(20) DEFAULT NULL COMMENT 'Task cost time',
    `queue_id`        int(11) DEFAULT NULL COMMENT 'Task queue id',
    `task_group_id`   varchar(40) DEFAULT NULL COMMENT 'Task group id',
    KEY               `task_group_id_index` (`task_history_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT 'History of each optimize task';

CREATE TABLE `table_transaction_meta`
(
    `table_identifier` varchar(256) NOT NULL,
    `transaction_id`   bigint(20) NOT NULL,
    `signature`        varchar(256) NOT NULL,
    `commit_time`      timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`table_identifier`,`transaction_id`),
    UNIQUE KEY `signature_unique` (`table_identifier`,`signature`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `api_tokens` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `apikey` varchar(256) NOT NULL COMMENT 'openapi client public key',
    `secret` varchar(256) NOT NULL COMMENT 'The key used by the client to generate the request signature',
    `apply_time` datetime DEFAULT NULL COMMENT 'apply time',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE KEY `account_unique` (`apikey`) USING BTREE COMMENT 'account unique'
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='Openapi  secret';


