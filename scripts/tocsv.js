
const helpfulScript = require("./helpful_script.js");
const filePathAndName = "C:/Projects/BlockChainDev/OnChainAsciiApes_Documentation/statistics/csvtest.txt";
const fs = require('fs');

var Results = [
    ["Col1", "Col2", "Col3", "Col4"],
    ["Data", 50, 100, 500],
    ["Data", -100, 20, 100],
];



const dataSeperator = ";";

arryToCsv = async function () {
    var CsvString = "";
    /*Results.forEach(function (RowItem, RowIndex) {
        RowItem.forEach(function (ColItem, ColIndex) {
            CsvString += ColItem + dataSeperator;
        });
        CsvString += "\r\n";
    });
    //CsvString = "data:application/csv," + encodeURIComponent(CsvString);
    console.log(CsvString);
    */
    helpfulScript.addDataToFile(filePathAndName, "123");


    console.log("file written");
}

async function main() {
    arryToCsv();
}


main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });