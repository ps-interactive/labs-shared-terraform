-- Creates a temporary in-application stream 
CREATE OR REPLACE STREAM "TEMP_STREAM" (
   "tickerSymbol" VARCHAR(8),
   "tradeType"    VARCHAR(4),
   "price"        DOUBLE,
   "quantity"    INTEGER,
   "id"           INTEGER,
   "ANOMALY_SCORE" DOUBLE);
   
-- Creates an output stream 
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
   "tickerSymbol"        VARCHAR(8),
   "tradeType"        VARCHAR(4),
   "price"        DOUBLE,
   "quantity"    INTEGER,
   "id"           INTEGER,
   "ANOMALY_SCORE"  DOUBLE);
 
-- Compute an anomaly score for each record in the source stream
-- using Random Cut Forest
CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "TEMP_STREAM"
SELECT STREAM source."tickerSymbol", source."tradeType", rcf."price", rcf."quantity", source."id", rcf."ANOMALY_SCORE" FROM
  TABLE(RANDOM_CUT_FOREST(
    CURSOR(SELECT STREAM "price", "quantity" FROM "SOURCE_SQL_STREAM_001")
  )
) AS rcf, SOURCE_SQL_STREAM_001 AS source;

-- Sort records by descending anomaly score, insert into output stream events that have an anomaly score higher than 1
CREATE OR REPLACE PUMP "OUTPUT_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM * FROM "TEMP_STREAM"
WHERE ANOMALY_SCORE > 1
ORDER BY FLOOR("TEMP_STREAM".ROWTIME TO SECOND), ANOMALY_SCORE DESC;
