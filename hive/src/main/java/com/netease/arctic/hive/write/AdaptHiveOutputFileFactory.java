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

package com.netease.arctic.hive.write;

import com.netease.arctic.io.ArcticFileIO;
import com.netease.arctic.io.writer.OutputFileFactory;
import com.netease.arctic.io.writer.TaskWriterKey;
import org.apache.iceberg.FileFormat;
import org.apache.iceberg.PartitionSpec;
import org.apache.iceberg.StructLike;
import org.apache.iceberg.encryption.EncryptedOutputFile;
import org.apache.iceberg.encryption.EncryptionManager;
import org.apache.iceberg.io.OutputFile;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

/**
 * For Keyed adapt hive with partitions the dir construct is :
 *    ${table_location}
 *            -| change
 *            -| base
 *            -| hive_data
 *                 -| ${partition_name1}
 *                 -| ${partition_name2}
 *                            -| txid=${txid}
 *
 * For Keyed adapt hive without partitions the dir construct is :
 *    ${table_location}
 *            -| change
 *            -| base
 *            -| hive_data
 *                  -| txid=${txid}
 *
 * For UnKeyed adapt hive with partitions the dir construct is :
 *    ${table_location}
 *            -| base
 *            -| hive_data
 *                 -| ${partition_name1}
 *                 -| ${partition_name2}
 *                            -| ${timestamp_uuid}
 *
 * For Keyed adapt hive without partitions the dir construct is :
 *    ${table_location}
 *            -| base
 *            -| hive_data
 *                  -| ${timestamp_uuid}
 */
public class AdaptHiveOutputFileFactory implements OutputFileFactory {

  private final String baseLocation;
  private final PartitionSpec partitionSpec;
  private final FileFormat format;
  private final ArcticFileIO io;
  private final EncryptionManager encryptionManager;
  private final int partitionId;
  private final long taskId;
  private final long transactionId;

  private final String unKeyedTmpDir = System.currentTimeMillis() + "_" + UUID.randomUUID();

  private final String keyedTmpDir;

  private final AtomicLong fileCount = new AtomicLong(0);

  public AdaptHiveOutputFileFactory(
      String baseLocation,
      PartitionSpec partitionSpec,
      FileFormat format,
      ArcticFileIO io,
      EncryptionManager encryptionManager,
      int partitionId,
      long taskId,
      long transactionId) {
    this.baseLocation = baseLocation;
    this.partitionSpec = partitionSpec;
    this.format = format;
    this.io = io;
    this.encryptionManager = encryptionManager;
    this.partitionId = partitionId;
    this.taskId = taskId;
    this.transactionId = transactionId;
    keyedTmpDir = "txid=" + transactionId;
  }


  private String generateFilename(TaskWriterKey key) {
    if (key.getTreeNode() != null) {
      return format.addExtension(
          String.format("%d-%s-%d-%05d-%d-%010d", key.getTreeNode().getId(), key.getFileType().shortName(),
              transactionId, partitionId, taskId, fileCount.incrementAndGet()));
    } else {
      return format.addExtension(
          String.format("%s-%05d-%d-%010d",
              key.getFileType().shortName(), partitionId, taskId, fileCount.incrementAndGet()));
    }
  }

  private String fileLocation(StructLike partitionData, String fileName, TaskWriterKey key) {
    if (partitionSpec.isUnpartitioned()) {
      if (key.getTreeNode() == null) {
        return String.format("%s/%s/%s", baseLocation, unKeyedTmpDir, fileName);
      } else {
        return String.format("%s/%s/%s", baseLocation, keyedTmpDir, fileName);
      }
    } else {
      if (key.getTreeNode() == null) {
        return String.format("%s/%s/%s/%s", baseLocation, partitionSpec.partitionToPath(partitionData),
            unKeyedTmpDir, fileName);
      } else {
        return String.format("%s/%s/%s/%s", baseLocation, partitionSpec.partitionToPath(partitionData),
            keyedTmpDir, fileName);
      }
    }
  }

  public EncryptedOutputFile newOutputFile(TaskWriterKey key) {
    String fileLocation = fileLocation(key.getPartitionKey(), generateFilename(key), key);
    OutputFile outputFile = io.newOutputFile(fileLocation);
    return encryptionManager.encrypt(outputFile);
  }
}
