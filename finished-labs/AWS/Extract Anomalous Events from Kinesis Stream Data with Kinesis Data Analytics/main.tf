provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
  access_key = ""
  secret_key = ""
}

resource "aws_iam_role" "stock_trades_producer_role" {
  name = "stock_trades_producer_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "stock_trades_producer_function" {
    type = "zip"
    output_path = "${path.module}/stock_trades_producer_lambda.zip"

    source {
        content = <<EOF
const stream = process.env.STREAM_NAME;
const recordsNumber = process.env.RECORDS_NUMBER;
const interval = process.env.INTERVAL;
const percentage = process.env.ANOMALOUS_PERCENTAGE;
const region = process.env.AWS_REGION;
const AWS = require('aws-sdk');
const kinesis = new AWS.Kinesis({region: region});


exports.handler = async (event) => {
    for(let batch = 1; batch <= batches; batch++) {
        let records = [];
        for(let index = 1; index <= recordsNumber; index++) {
            let stockTrade = generateStockTrade(index);
            
            let record = {
                Data: JSON.stringify(stockTrade),
                PartitionKey: stockTrade.tickerSymbol
            };    
            
            records.push(record)
        }
        
        console.log("Producing to Kinesis the following stock trades: \n", records)
        let recordsParams = {
            Records : records,
            StreamName : stream
        };
        
        await kinesis.putRecords(recordsParams).promise();
        await delay(interval);
    }
    return;
};

const TRADE_TYPE = ["BUY", "SELL"] 
const TICKER_SYMBOL = ["AAPL", "XOM", "GOOG", "BRK.A", "MSFT", "WFC", "JNJ", "WMT", "CHL", "GE", "NVS", "PG", "JPM", "RDS.A", "CVX", "PFE", "FB", "VZ", "PTR", "BUD", "ORCL", "KO", "T", "DIS", "AMZN"]
const batches = 800;

const delay = ms => new Promise(res => setTimeout(res, ms));

function generateStockTrade(index) {
    let anomalous = index % ( recordsNumber / percentage ) == 0 ? true : false;

    return {
    "tickerSymbol": TICKER_SYMBOL[Math.floor(Math.random() * TICKER_SYMBOL.length)], 
    "tradeType": TRADE_TYPE[Math.floor(Math.random() * TRADE_TYPE.length)], 
    "price": anomalous ? getAnomalousPrice() : getPrice(),
    "quantity": anomalous ? getAnomalousQuantity() : getQuantity(), 
    "id": Math.floor(Math.random() * 9999) + 1000
    }
}

function getAnomalousPrice() {
    return (Math.random() * (5000 - 100) + 100).toFixed(2)
}

function getPrice() {
    return (Math.random() * 500 + 30).toFixed(2)
}

function getAnomalousQuantity() {
    return Math.floor(Math.random() * 2000) + 500
}

function getQuantity() {
    return Math.floor(Math.random() * 100) + 2
}
        EOF
        
        filename = "index.js"
    }
}

resource "aws_lambda_function" "stock_trades_producer" {
  filename      = "${data.archive_file.stock_trades_producer_function.output_path}"
  function_name = "stock_trades_producer"
  role          = "${aws_iam_role.stock_trades_producer_role.arn}"
  handler       = "index.handler"

  runtime = "nodejs12.x"

  timeout = "900"
  
  environment {
    variables = {
      RECORDS_NUMBER = 100
      INTERVAL = 1000
      ANOMALOUS_PERCENTAGE = 5
    }
  }
}

resource "aws_s3_bucket" "anomalous_stock_trades" {
  bucket = "anomalous-stock-trades"
  acl    = "private"
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3_policy"
  description = "S3 Full Access Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "anomalous_stock_trades_firehose_role" {
  name = "anomalous_stock_trades_firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "s3_policy_attachment"
  roles      = [ "${aws_iam_role.anomalous_stock_trades_firehose_role.name}" ]
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

resource "aws_kinesis_firehose_delivery_stream" "anomalous_stock_trades_firehose_stream" {
  name        = "anomalous_stock_trades_firehose_stream"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.anomalous_stock_trades_firehose_role.arn}"
    bucket_arn = "${aws_s3_bucket.anomalous_stock_trades.arn}"
    buffer_interval    = 60
  }
}
