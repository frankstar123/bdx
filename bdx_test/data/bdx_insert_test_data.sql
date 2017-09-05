
DECLARE @FK int =0;

DELETE FROM rep_bdx_riskdata where PolicyRef = 'HOWA01HN01';

INSERT INTO [dbo].[rep_bdx_ledger] ( [timestamp],[method],[version],[branch],[key],[clientRef],[policyRef],[suffix],[policyType],[transType],[dateRaised],[processed])
     VALUES
(GETDATE(), 'Create',null,0,'TESTDATA','HOAW01','HOAW01HN01',1,'HN','New Business',GETDATE(), 0);

SET @FK = @@IDENTITY;		  

INSERT INTO [dbo].[rep_bdx_riskdata]
(		[LedgerID],[Branch],[ClientRef],[PolicyRef],[RecordNumber],[Name],[InsurerPolicyRef],[Insurer],	  [PolicyType],[Version],[DateOfEntry],[InceptionDate],[EffectiveDate],[ChangeReason],[TransType],[RiskAddress],[PostCode],[YearOfAccount],[HomeBuildingsSI],[HomeBuildingsPrem],[HomeContentsSI],[HomeContentsPrem],[HomePersonalPossSI],[HomePersonalPossPrem],[FineArtSI],[FineArtPrem],[LegalExpensesSI],[LegalExpensesPrem],[TravelPrem],[BrokerageAmount],[NetPremium],[TotalPremium],[IPT],[AmountDueToInsurers])
 VALUES
	-- New Business Transaction
	(@FK,0,'HOWA01','HOWA01HN01',1,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 1, GETDATE(), '01/08/2017', '01/08/2017','Create','New Business','All Location(s)', 		'N/A', 		2017,0,0,0,0,0,0,0,0,0,0,190,100,2900,3000,360,3260),
	(@FK,0,'HOWA01','HOWA01HN01',2,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 1, GETDATE(), '01/08/2017', '01/08/2017','Create','New Business','16 Ringway, NE62 5XT', 	'NE62 5XT', 2017,2500000,2500,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0),	
	(@FK,0,'HOWA01','HOWA01HN01',3,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 1, GETDATE(), '01/08/2017', '01/08/2017','Create','New Business','44 Gairloch Drive', 	'NE38 0DS', 2017,4000000,2500,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0),
	(@FK,0,'HOWA01','HOWA01HN01',1,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 2, GETDATE(), '01/08/2017', '15/08/2017','Create','Endorsement','All Location(s)', 		'N/A', 		2017,0,0,0,0,0,0,0,0,0,0,190,0,1650,1650,198,1848),
	(@FK,0,'HOWA01','HOWA01HN01',2,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 2, GETDATE(), '01/08/2017', '15/08/2017','Create','Endorsement','16 Ringway, NE62 5XT', 	'NE62 5XT', 2017,2500000,2500,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0),	
	(@FK,0,'HOWA01','HOWA01HN01',3,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 2, GETDATE(), '01/08/2017', '15/08/2017','Create','Endorsement','44 Gairloch Drive', 	'NE38 0DS', 	2017,2000000,1250,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0),
	(@FK,0,'HOWA01','HOWA01HN01',1,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 3, GETDATE(), '01/08/2017', '01/09/2017','Create','Endorsement','All Location(s)', 		'N/A', 		2017,0,0,0,0,0,0,0,0,0,0,0,0,-167.2,-167.2,-22.8,-190),
	(@FK,0,'HOWA01','HOWA01HN01',2,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 3, GETDATE(), '01/08/2017', '01/09/2017','Create','Endorsement','16 Ringway, NE62 5XT', 	'NE62 5XT', 2017,2500000,2500,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0),	
	(@FK,0,'HOWA01','HOWA01HN01',3,'Andrew Howard','ABC12345','Catlin HNW', 'HN', 3, GETDATE(), '01/08/2017', '01/09/2017','Create','Endorsement','44 Gairloch Drive', 	'NE38 0DS', 	2017,2000000,1250,100000,200,5000,25,20000,175,0,0,0,0,0,0,0,0)
GO



