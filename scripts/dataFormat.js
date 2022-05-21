

exports.arrayToCsvString = function (data, dataSeperator) {
    let combinedArrayData = [];
    for (let i = 0; i < data.length; i++) {
        combinedArrayData.push(data[i]);
    }
    var CsvString = "";
    combinedArrayData.forEach(function (RowItem, RowIndex) {
        RowItem.forEach(function (ColItem, ColIndex) {
            CsvString += ColItem + dataSeperator;
        });
        CsvString += "\r\n";
    });
    return (CsvString);
};