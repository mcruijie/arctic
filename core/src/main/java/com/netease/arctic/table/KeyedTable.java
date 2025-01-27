/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.netease.arctic.table;

import com.netease.arctic.op.OverwriteBaseFiles;
import com.netease.arctic.op.RewritePartitions;
import com.netease.arctic.scan.KeyedTableScan;
import org.apache.iceberg.UpdateProperties;
import org.apache.iceberg.UpdateSchema;
import org.apache.iceberg.util.StructLikeMap;
import java.util.Map;

/**
 * Represents an arctic table with keys supported, consist of one {@link ChangeTable} and one {@link BaseTable}.
 */
public interface KeyedTable extends ArcticTable {

  /**
   * Returns the {@link PrimaryKeySpec} of this table
   */
  PrimaryKeySpec primaryKeySpec();

  /**
   * Returns the location of base table store, usually is {@link #location()}/base
   */
  String baseLocation();

  /**
   * Returns the location of change table store,  usually is {@link #location()}/change
   */
  String changeLocation();

  /**
   * Returns the base table store
   */
  BaseTable baseTable();

  /**
   * Returns the base table store
   */
  ChangeTable changeTable();

  default String name() {
    return id().toString();
  }

  /**
   * Create a new {@link KeyedTableScan scan} for this table.
   *
   * @return a table scan for this table
   */
  KeyedTableScan newScan();

  /**
   * Create a new {@link UpdateSchema} to alter the columns of this table and commit the change.
   *
   * @return a new {@link UpdateSchema}
   */
  UpdateSchema updateSchema();

  /**
   * Create a new {@link UpdateProperties} to update table properties and commit the changes.
   *
   * @return a new {@link UpdateProperties}
   */
  UpdateProperties updateProperties();

  /**
   * Allocate a new transaction id from this table
   *
   * @param signature signature for this request. Requests with the same signature will get the same transaction id.
   *                  Requests with signature NULL will always get different transaction id.
   * @return a new transaction id
   */
  long beginTransaction(String signature);

  /**
   * get max transactionId of each partition. use {@link #partitionMaxTransactionId()} instead.
   *
   * @return map of max transactionId of each partition
   */
  @Deprecated
  Map<String, Long> maxTransactionId();

  /**
   * get max transactionId of each partition
   *
   * @return map of max transactionId of each partition
   */
  StructLikeMap<Long> partitionMaxTransactionId();

  @Override
  default boolean isKeyedTable() {
    return true;
  }

  @Override
  default KeyedTable asKeyedTable() {
    return this;
  }

  RewritePartitions newRewritePartitions();

  OverwriteBaseFiles newOverwriteBaseFiles();
}
