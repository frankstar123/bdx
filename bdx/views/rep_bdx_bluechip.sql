	select a.ClientRef, a.PolicyRef, a.name, a.InsurerPolicyRef, a.Insurer, 'All Location(s)' as RiskAddress, a.EffectiveDate, a.version, A.TransType, YearOfAccount,
	SUM(a.HomeBuildingsSI) As HomeBuildingsPrem,
	SUM(A.HomeBuildingsPrem) as HomeBuildingsPrem,
	SUM(A.HomeContentsSI) as HomeContentsSI,
	SUM(A.HomeContentsPrem) as HomeContentsPrem,
	SUM(A.HomePersonalPossSI) as HomePersonalPossSI,
	SUM(A.HomePersonalPossPrem) as HomePersonalPossPrem,
	SUM(A.FineArtSI) as FineArtSI,
	SUM(A.FineArtPrem) as FineArtPrem,
	SUM(a.brokerageamount)  as BrokerageAmount,
	SUM(a.netpremium) as NetPremium,
	SUM(a.TotalPremium) as TotalPremium,
	SUM(a.IPT) as IPT,
	SUM(A.AmountDueToInsurers) as AmountDueToInsurers,
	SUM(a.TravelPrem) as TravelPrem
	from rep_bdx_riskdata a  
	group by a.PolicyRef, a.name, a.InsurerPolicyRef, a.Insurer,  a.EffectiveDate, a.version, a.TransType, a.ClientRef, a.YearOfAccount
