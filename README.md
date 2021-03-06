# Bdx Scripts

This runs witin Infocentre. The trigger runs against the BRCLEDGER table and inserts data into *bdx_riskdata* and *bdx_ledger*

MS SQL Does not have the ability (in our version) to do CREATE or ALTER thus all scripts are saved as *CREATE*

## Installation Instructions

### Setup
Follow the instructions below to setup Bbx within OGI
##### Functions 
Create the functions within Infocentre

    bdx\functions\GetAddress.sql
    bdx\functions\GetFullName.sql
    bdx\procedures\bdxManagement.sql


#### Tables
Create the holding tables for ledger and riskdata

    bdx\tables\rep_bdx_ledger.sql  Contains the transaction details that caused a change in ledger
    bdx\tables\rep_bdx_riskdata.sql Contains the actual risk data and version at the time of the change

#### Triggers
Create the trigger on the ledger table 
    bdx\triggers\trigger_brcledger.sql 
__Creates a trigger on **brcledger** that on create captures the data at that point in time and versions it__

#### Add trigger creation to the Infocentre post refresh scripts.
The contents of 'bdx\triggers\trigger_brcledger.sql' should be copied to OpenGI start

## Testing 
To test the trigger the easiest thing to do is create an empty copy of the ledger table:
    bdx_test\tables\rep_bdx_ledger_test.sql
__Creates a rep_bdx_ledger_test table which is a structure copy of the brcledger table__

    bdx_test\triggers\trigger_rep_bdx_ledger_oncreate.sql
__Create trigger on the table rep_bdx_ledger_test to test the trigger calling bdxManagement procedure__

### How to test 

    insert into  rep_bdx_ledger_test select top(1) *  from brcledger where  PolRef@ like 'TEST01FE%'` 
__change polref to an appropriate policy. As of version 1 on __FE__ was enabled__


    The output will just show the number of the rows inserted:

    (1 row(s) affected)  This is the row being inserted into rep_bdx_ledger_test from the sql above (top (1))

    (1 row(s) affected)  2nd insert is always a single row into the rep_bdx_ledger, 
    this gives information on the transaction that caused the trigger to fire but kept seperately 
    in this table just in case there's an amendment on the record.

    (1 row(s) affected) This row is an insert into rep_bdx_riskdata - All Locations

    (1 row(s) affected) This will be the first property / risk for the policy

    (1 row(s) affected) This will repeat for each risk details for each property


    
