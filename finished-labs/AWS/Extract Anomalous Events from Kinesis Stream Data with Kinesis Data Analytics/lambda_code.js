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