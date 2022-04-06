// Dataset for the person list control.  See onLoad ... createDataset() below.
 
 
 
var listProviderDbSetup = [
 
    ["person_id",           "PersonID", false, 20],
 
    ["name_full_formatted", "Name",     true,  100]
 
    ];
 
 
 
// Global
 
var lstPrsnl;
 
var btnSearch;
 
var btnRemove;
 
var displayMode;
 
 
 
function ccpsProviderSelectionSetup(_lstPrsnl, _btnSearch, _btnRemove, _displayMode)
 
{
 
    lstPrsnl    = _lstPrsnl;
 
    btnSearch   = _btnSearch;
 
    btnRemove   = _btnRemove;
 
    displayMode = _displayMode;
 
 
 
    // Set the event handlers
 
    btnSearch.onClick       = onProviderSearchClick;
 
    lstPrsnl.onQueryValue   = onProviderQueryValue;
 
    btnRemove.onClick       = onProviderRemoveClick;
 
    //lstPrsnl.onMouseOver  = onProviderMouseOver;
 
    //lstPrsnl.onMouseOut   = onProviderMouseOut;
 
 
 
    // Define list dataset
 
    createDataset(lstPrsnl, listProviderDbSetup);
 
 
 
    btnRemove.enabled = false;
 
}
 
 
 
function onProviderSearchClick(sender)
 
{
 
    // Load form into a local variable
 
    var theDialogForm  = loadForm("Provider_Selection_Lite");
 
 
 
    // Check if the dialog form loaded
 
    if (theDialogForm != null) {
 
 
 
        // Show the form
 
        if (theDialogForm.showForm(true) == 1) {
 
 
 
            // User pressed the OK button
 
            // Person Search: person_id, name, orgs, services, aliases, positions
 
            // Alias Search : person_id, alias, name, orgs, services, aliases, positions
 
 
 
            var selected = theDialogForm.lstResults.getNextSelection(-1);
 
            var personID = theDialogForm.lstResults.getField(selected,0);
 
            var personName
 
 
 
            if(theDialogForm.txtAlias.value > "" && theDialogForm.cboAliasType.value > 0) {
 
                personName = theDialogForm.lstResults.getField(selected,2);
 
            }
 
            else {
 
                personName = theDialogForm.lstResults.getField(selected,1);
 
            }
 
 
 
            if (personID != 0) {
 
 
 
                // Add to the person list box
 
                // displayMode 1: limit to 1 PRSNL
 
                if(displayMode == 1) {
 
                    lstPrsnl.clear();
 
                }
 
                var rn = lstPrsnl.getNextRecord();
 
                if (rn > -1) {
 
                    lstPrsnl.setField(rn, 0, personID);
 
                    lstPrsnl.setField(rn, 1, personName);
 
 
 
                    lstPrsnl.updateDisplay();
 
                    btnRemove.enabled = true;
 
                    lstPrsnl.selectAll(false);
 
                    lstPrsnl.selectRecord(rn,true);
 
                }
 
            }
 
        }
 
    }
 
}
 
 
 
function onProviderQueryValue(sender)
 
{
 
    var bMulti = false;
 
    var sArg = "";
 
    var rcCount = lstPrsnl.recordCount;
 
 
 
    // If more than one item is in the list then create a multi item VALUE statement.
 
    if (rcCount > 1) {
 
        sArg = "VALUE (";
 
        bMulti = true;
 
    }
 
 
 
    // Build key value using the person id of all persons in the list box
 
    for (rn = 0; rn < rcCount; rn++) {
 
        if (rn > 0) sArg += ",";
 
 
 
        sArg += lstPrsnl.getField(rn, 0);
 
    }
 
 
 
    if (bMulti)
 
        sArg += ")";
 
 
 
    return sArg;
 
}
 
 
 
function onProviderRemoveClick(sender)
 
{
 
    if (lstPrsnl.selectedRecordCount > 0) {
 
        lstPrsnl.deleteSelectedRecords();
 
    }
 
 
 
    var rn1 = lstPrsnl.recordCount;
 
 
 
    if(rn1 > 0) {
 
        lstPrsnl.selectAll(false);
 
        lstPrsnl.selectRecord(rn1-1,true);
 
    }
 
    else {
 
        sender.enabled = false;
 
    }
 
 
 
    lstPrsnl.statusText = '';
 
}
 
 
 
/*function onProviderMouseOver(sender)
 
{
 
    sender.statusText = "Person ID(s): " + sender.value;
 
}
 
 
 
function onProviderMouseOut(sender)
 
{
 
    sender.statusText = '';
 
}*/
