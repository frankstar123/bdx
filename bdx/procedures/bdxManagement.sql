USE [INFOCENTRE-UAT]
GO
/****** Object:  StoredProcedure [dbo].[bdxManagement]    Script Date: 24/08/2017 12:23:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[bdxManagement] (
	@Branch int,
	@PK varchar(28),
	@ClientRef varchar(10),
	@PolicyId varchar(10),
	@Suffix int,
	@PolicyType varchar(2),
	@TransType varchar(14),
	@DateRaised datetime,
	@method varchar(10),
	@yearOfAccount int,
	@OriginalDebt float,
	@IptAmount float,
	@CommissionAmount float)
AS
	BEGIN
		DECLARE @KEYID int;
		DECLARE @Address varchar(max);
		DECLARE @FullName varchar(max);
		DECLARE @VersionId int;
		DECLARE @InceptionDate datetime;
		--RISK RECORD
		DECLARE @Addr1 varchar(30)
		DECLARE @Addr2 varchar(30);
		DECLARE @Addr3 varchar(30);
		DECLARE @Addr4 varchar(30);
		DECLARE @PostCode varchar (15);
		DECLARE @PRN int;
		DECLARE @HomeBuildingsSI int;
		DECLARE @HomeBuildingsPrem decimal(11,2);
		DECLARE @HomeContentsSI int;
		DECLARE @HomeContentsPrem decimal(11,2);
		DECLARE @HomePersonalPossSI int;
		DECLARE @HomePersonalPossPrem decimal(11,2);
		DECLARE @FineArtSI int;
		DECLARE @FineArtPrem decimal(11,2);
		DECLARE @PropertyDamageBuildingsSI int;
		DECLARE @PropertyDamageBuildingsPrem decimal(11,2);
		DECLARE @PropertyDamageContentsSI int;
		DECLARE @PropertyDamageContentsPrem decimal(11,2);
		DECLARE @LossOfRevenueSI int;
		DECLARE @LossOfRevenuePrem decimal(11,2);
		DECLARE @LivestockSI int;
		DECLARE @LivestockPrem decimal(11,2);
		DECLARE @LivestockARMSI int;
		DECLARE @LivestockARMPrem decimal(11,2);
		DECLARE @DiseaseSI int;
		DECLARE @DiseasePrem decimal(11,2);
		DECLARE @EmployersLiabilitySI  int;
		DECLARE @EmployersLiabilityPrem decimal(11,2);
		DECLARE @PublicLiabilitySI int;
		DECLARE @PublicLiabilityPrem decimal(11,2);
		DECLARE @EnvironmentalLiabilitySI int;
		DECLARE @EnvironmentalLiabilityPrem decimal(11,2);
		DECLARE @PersonalAccidentSI int;
		DECLARE @PersonalAccidentPrem decimal(11,2);
		DECLARE @GoodsInTransitSI int;
		DECLARE @GoodsInTransitPrem decimal(11,2);
		DECLARE @AllRisksSI int;
		DECLARE @AllRisksPrem decimal(11,2);
		DECLARE @MoneySI int;
		DECLARE @MoneyPrem decimal(11,2);
		DECLARE @CARSI int;
		DECLARE @CARPrem decimal(11,2);
		DECLARE @TerrorismSI int;
		DECLARE @TerrorismPrem decimal(11,2);
		DECLARE @TotalPremium decimal (11,2);
		DECLARE @TotalIptAmount decimal (11,2);
		DECLARE @TotalCommissionAmount decimal (11,2);
		--POLICY DETAILS 
		DECLARE @InsurerPolicyRef varchar(max);
		DECLARE @InsurerName varchar(max);
		DECLARE @RenewalDate datetime;
		DECLARE @NetPremium decimal (11,2);
		DECLARE @_NetPremium decimal (11,2);

		DECLARE @DueToInsurer decimal (11,2);
		DECLARE @_DueToInsurer decimal (11,2);
		
		--Audit Record for us.
		insert into rep_bdx_ledger([timestamp], method, branch,[key],clientRef,policyRef,suffix,policyType, transType, dateraised, processed)
		values (CURRENT_TIMESTAMP, @method, @Branch, @PK,@ClientRef, @PolicyId, @Suffix,@policyType,@TransType,@DateRaised, 0);
		set @KEYID = SCOPE_IDENTITY(); 
		--Next lets get the details of the risk
		IF(@PolicyType = 'FE') 
			BEGIN
				--Get the highest version of the Policy
				select @VersionId = max(version) from rep_bdx_riskdata where branch = @Branch and clientRef = @ClientRef and policyRef = @PolicyId;
				if(@VersionId is null)
					SET @VersionId = 1; 
				ELSE
					SET @VersionId += 1;
								
				-- NEED to get the information from the dbo.bd_loc1 table
				set @NetPremium = @OriginalDebt-@CommissionAmount;
				set @DueToInsurer = @NetPremium + @IptAmount;
				DECLARE c_Risks cursor for 
					--CURSOR
					SELECT        			a.Addr1#, a.Addr2#,a.Addr3#,a.Addr4#, a.Pcode#,  a.PRN#, 
						b.Item_si1# as 'HomeBuildingsSI', b.Item_Prem1# as 'HomeBuildingsPrem', 
						b.Item_si2# as 'HomeContentsSI', b.Item_Prem2# as 'HomeContentsPrem', 
						b.Item_si3# as 'HomePersonalPossSI', b.Item_Prem3# as 'HomePersonalPossPrem',
						c.Item_si1# AS 'FineArtSI', c.Item_prem1# AS 'FineArtPrem', 
						d.Item_si1# AS 'PropertyDamageBuildingsSI', d.Item_Prem1# As 'PropertyDamageBuildingsPrem',
                        d.Item_si2# AS 'PropertyDamageContentsSI', d.Item_Prem2# as 'PropertyDamageContentsPrem', 
						e.Item_si1# AS 'LossOfRevenueSI', e.Item_prem1# as 'LossOfRevenuePrem',
						f.Item_si1# as 'LivestockSI', f.Item_Prem1# as 'LivestockPrem', 
						f.Item_si2# as 'LivestockARMSI', f.Item_prem2# as 'LivestockARMPrem', 
						f.Item_si3# as 'DiseaseSI', f.Item_prem3# as 'DiseasePrem', 
						g.Item_si1# AS 'EmployersLiabilitySI', g.Item_prem1# AS 'EmployersLiabilityPrem', 
						h.Item_si1# as 'PublicLiabilitySI', h.Item_prem1# as 'PublicLiabilityPrem', 
						i.Item_si1# as 'EnvironmentalLiabilitySI', i.Item_prem1# as 'EnvironmentalLiabilityPrem', 
						j.Item_si1# as 'PersonalAccidentSI', j.Item_prem1# as 'PersonalAccidentPrem', 
						k.Item_si1# as 'GoodsInTransitSI', k.Item_prem1# as 'GoodsInTransitPrem', 
						l.Item_si1# as 'AllRisksSI', l.Item_prem1# as 'AllRisksPrem', 
						m.Item_si1# as 'MoneySI', m.Item_prem1# as 'MoneyPrem', 
						n.Item_si1# as 'CARSI', n.Item_prem1# as 'CARPrem', 
						o.Item_Si1# as 'TerrorismSI',o.Item_Prem1# as 'TerrorismPrem',
						0 as 'GrossPremium',
						0 as 'IptAmount',
						0 as 'BrokerageAmount',
						0 as 'NetPremium',
						0 as 'DueToInsurer'
						FROM            BD_LOC1 AS a LEFT OUTER JOIN
                         BD_SBUA AS e ON a.PolRef@ = e.PolRef@ AND a.PRN# = e.Locationprn# LEFT OUTER JOIN
                         BD_SPRA AS d ON a.PRN# = d.Locationprn# AND a.PolRef@ = d.PolRef@ LEFT OUTER JOIN
                         BD_SANA AS c ON a.PRN# = c.Locationprn# AND a.PolRef@ = c.PolRef@ LEFT OUTER JOIN
                         BD_SHOA AS b ON a.PRN# = b.Locationprn# AND a.PolRef@ = b.PolRef@ LEFT OUTER JOIN
						 BD_SLIA AS f on a.PRN# = f.Locationprn# and a.PolRef@ = f.PolRef@ LEFT OUTER JOIN
						 BD_SEMA AS g on a.PRN# = g.Locationprn# and a.PolRef@ = g.PolRef@ LEFT OUTER JOIN
						 BD_SPUA AS h on a.PRN# = h.Locationprn# and a.PolRef@  = h.PolRef@ LEFT OUTER JOIN
						 BD_SENA as i on a.PRN# = i.Locationprn# and a.PolRef@ = i.PolRef@ LEFT OUTER JOIN
						 BD_SPEA as j on a.PRN# = j.Locationprn# and a.PolRef@ = j.PolRef@ LEFT OUTER JOIN
						 BD_SGOA as k on a.PRN# = k.Locationprn# and a.PolRef@ = k.PolRef@  LEFT OUTER JOIN
						 BD_SBAA as l on a.PRN# = l.Locationprn# and a.PolRef@ = l.PolRef@  LEFT OUTER JOIN
						 BD_SMOA as m on a.PRN# = m.Locationprn# and a.PolRef@ = m.PolRef@ LEFT OUTER JOIN
						 BD_SCOA as n on a.PRN# = n.Locationprn# and a.PolRef@ = n.PolRef@ LEFT OUTER JOIN
						 BD_STEA as o on a.PRN# = o.Locationprn# and a.PolRef@ = o.PolRef@ 
						WHERE        (a.PolRef@ = @PolicyId AND a.B@ = @Branch AND a.Ref@ = @ClientRef)
					UNION
						SELECT        'All Location(s)' AS Addr1#, '' as Addr2#,'' as Addr3#,'' as Addr4# ,'N/A' AS Pcode#, a.PRN#,
						b.Item_si1# as 'HomeBuildingsSI', b.Item_Prem1# as 'HomeBuildingsPrem', 
						b.Item_si2# as 'HomeContentsSI', b.Item_Prem2# as 'HomeContentsPrem', 
						b.Item_si3# as 'HomePersonalPossSI', b.Item_Prem3# as 'HomePersonalPossSI',  
						c.Item_si1# AS 'FineArtSI', c.Item_prem1# AS 'FineArtPrem', 
						d.Item_si1# AS 'PropertyDamageBuildingsSI', d.Item_Prem1# As 'PropertyDamageBuildingsPrem',
                        d.Item_si2# AS 'PropertyDamageContentsSI', d.Item_Prem2# as 'PropertyDamageContentsPrem', 
						e.Item_si1# AS 'LossOfRevenueSI', e.Item_prem1# as 'LossOfRevenuePrem',
						f.Item_si1# as 'LivestockSI', f.Item_Prem1# as 'LivestockPrem', 
						f.Item_si2# as 'LivestockARMSI', f.Item_prem2# as 'LivestockARMPrem', 
						f.Item_si3# as 'DiseaseSI', f.Item_prem3# as 'DiseasePrem', 
						g.Item_si1# AS 'EmployersLiabilitySI', g.Item_prem1# AS 'EmployersLiabilityPrem', 
						h.Item_si1# as 'PublicLiabilitySI', h.Item_prem1# as 'PublicLiabilityPrem', 
						i.Item_si1# as 'EnvironmentalLiabilitySI', i.Item_prem1# as 'EnvironmentalLiabilityPrem', 
						j.Item_si1# as 'PersonalAccidentSI', j.Item_prem1# as 'PersonalAccidentPrem', 
						k.Item_si1# as 'GoodsInTransitSI', k.Item_prem1# as 'GoodsInTransitPrem', 
						l.Item_si1# as 'AllRisksSI', l.Item_prem1# as 'AllRisksPrem', 
						m.Item_si1# as 'MoneySI', m.Item_prem1# as 'MoneyPrem', 
						n.Item_si1# as 'CARSI', n.Item_prem1# as 'CARPrem', 
						o.Item_Si1# as 'TerrorismSI',o.Item_Prem1# as 'TerrorismPrem',
						@OriginalDebt as 'GrossPremium',
						@IptAmount as 'IptAmount',
						@CommissionAmount as 'BrokerageAmount',
						@NetPremium as 'NetPremium',
						@DueToInsurer as 'DueToInsurer'
							FROM            (SELECT        @ClientRef AS Ref@, @PolicyId AS PolRef@, 'All Location(s)' AS Addr1#, '' AS Pcode#, 0 AS PRN#) AS a LEFT OUTER JOIN
                         BD_SBUA AS e ON a.PolRef@ = e.PolRef@ AND a.PRN# = e.Locationprn# LEFT OUTER JOIN
                         BD_SPRA AS d ON a.PRN# = d.Locationprn# AND a.PolRef@ = d.PolRef@ LEFT OUTER JOIN
                         BD_SANA AS c ON a.PRN# = c.Locationprn# AND a.PolRef@ = c.PolRef@ LEFT OUTER JOIN
                         BD_SHOA AS b ON a.PRN# = b.Locationprn# AND a.PolRef@ = b.PolRef@ LEFT OUTER JOIN
						 BD_SLIA AS f on a.PRN# = f.Locationprn# and a.PolRef@ = f.PolRef@ LEFT OUTER JOIN
						 BD_SEMA AS g on a.PRN# = g.Locationprn# and a.PolRef@ = g.PolRef@ LEFT OUTER JOIN
						 BD_SPUA AS h on a.PRN# = h.Locationprn# and a.PolRef@  = h.PolRef@ LEFT OUTER JOIN
						 BD_SENA as i on a.PRN# = i.Locationprn# and a.PolRef@ = i.PolRef@  LEFT OUTER JOIN
						 BD_SPEA as j on a.PRN# = j.Locationprn# and a.PolRef@ = j.PolRef@ LEFT OUTER JOIN
						 BD_SGOA as k on a.PRN# = k.Locationprn# and a.PolRef@ = k.PolRef@ LEFT OUTER JOIN
						 BD_SBAA as l on a.PRN# = l.Locationprn# and a.PolRef@ = l.PolRef@ LEFT OUTER JOIN
						 BD_SMOA as m on a.PRN# = m.Locationprn# and a.PolRef@ = m.PolRef@ LEFT OUTER JOIN
						 BD_SCOA as n on a.PRN# = n.Locationprn# and a.PolRef@ = n.PolRef@ LEFT OUTER JOIN
						 BD_STEA as o on a.PRN# = o.Locationprn# and a.PolRef@ = o.PolRef@ 
						WHERE         (a.PolRef@ = @PolicyId AND a.Ref@ = @ClientRef) -- and e.Locationprn# = 0)
						ORDER BY a.PRN#;
					--CURSOR END
				--Get some meta data for policy
				select @InsurerPolicyRef = [polno#], @InsurerName = [insco#], @RenewalDate = [Rdat#], @InceptionDate = [Idat#] from brpolicy where [PolRef@] = @PolicyId;
				select @FullName = dbo.GetFullName(@clientRef);
				
				open c_Risks; -- 5 risks in the TEST01 (1 All Location)
				fetch next from c_Risks into @Addr1, @Addr2, @Addr3, @Addr4, @PostCode, @PRN, @HomeBuildingsSI, 	@HomeBuildingsPrem,	@HomeContentsSI, @HomeContentsPrem,	@HomePersonalPossSI,@HomePersonalPossPrem,@FineArtSI,@FineArtPrem,@PropertyDamageBuildingsSI,@PropertyDamageBuildingsPrem, --15
						@PropertyDamageContentsSI,@PropertyDamageContentsPrem,@LossOfRevenueSI,	@LossOfRevenuePrem,	@LivestockSI,@LivestockPrem,@LivestockARMSI,@LivestockARMPrem,@DiseaseSI,@DiseasePrem,@EmployersLiabilitySI, --11
						@EmployersLiabilityPrem,@PublicLiabilitySI,@PublicLiabilityPrem,@EnvironmentalLiabilitySI,@EnvironmentalLiabilityPrem,@PersonalAccidentSI, @PersonalAccidentPrem,@GoodsInTransitSI, --8
						@GoodsInTransitPrem,@AllRisksSI,@AllRisksPrem,@MoneySI,@MoneyPrem,@CARSI,@CARPrem,@TerrorismSI,@TerrorismPrem, @TotalPremium, @TotalIptAmount, @TotalCommissionAmount, @_NetPremium, @_DueToInsurer --9
				while @@fetch_status <> -1
				begin
					select @Address = dbo.GetAddress(@Addr1,@Addr2,@Addr3,@Addr4,@PostCode);
					insert into rep_bdx_riskdata(branch,clientRef,policyRef,insurerPolicyRef,Insurer,policyType,version,           DateOfEntry,  InceptionDate,  EffectiveDate, changeReason,TransType,riskAddress, postcode, YearOfAccount, HomeBuildingsSI, HomeBuildingsPrem, HomeContentsSI, HomeContentsPrem, HomePersonalPossSI, HomePersonalPossPrem, FineArtSI, FineArtPrem, 
					PropertyDamageBuildingsSI, PropertyDamageBuildingsPrem, PropertyDamageContentsPrem, PropertyDamageContentsSI, LossOfRevenuePrem, LossOfRevenueSI, LivestockSI, LivestockPrem, LivestockARMSI, LivestockARMPrem, DiseaseSI, DiseasePrem, EmployersLiabilitySI, 
														EmployersLiabilityPrem, PublicLiabilitySI, PublicLiabilityPrem,	EnvironmentalLiabilitySI, EnvironmentalLiabilityPrem, PersonalAccidentSI, PersonalAccidentPrem, GoodsInTransitSI, GoodsInTransitPrem, AllRisksSI, AllRisksPrem, MoneySI, MoneyPrem, CARSI, CARPrem, TerrorismSI, TerrorismPrem, GrossPremium, IPT, BrokerageAmount, NetPremium, AmountDueToInsurers) 
														values
													  (@branch,@clientRef,@PolicyId,@InsurerPolicyRef,@InsurerName, @PolicyType,@VersionId, CURRENT_TIMESTAMP,@InceptionDate, @DateRaised,   @method, @TransType, @Address, @PostCode, @yearOfAccount, @HomeBuildingsSI,@HomeBuildingsPrem,@HomeContentsSI,@HomeContentsPrem,@HomePersonalPossSI,@HomePersonalPossPrem,@FineArtSI,@FineArtPrem,
														@PropertyDamageBuildingsSI,@PropertyDamageBuildingsPrem,@PropertyDamageContentsPrem,@PropertyDamageContentsSI,@LossOfRevenuePrem,@LossOfRevenueSI,@LivestockSI,@LivestockPrem,@LivestockARMSI,@LivestockARMPrem,@DiseaseSI,@DiseasePrem,@EmployersLiabilitySI,@EmployersLiabilityPrem,@PublicLiabilitySI,
														@PublicLiabilityPrem,@EnvironmentalLiabilitySI,@EnvironmentalLiabilityPrem,@PersonalAccidentSI,@PersonalAccidentPrem,@GoodsInTransitSI,@GoodsInTransitPrem,@AllRisksSI,@AllRisksPrem,@MoneySI,@MoneyPrem,@CARSI,@CARPrem,@TerrorismSI,@TerrorismPrem,@TotalPremium, @TotalIptAmount,@TotalCommissionAmount, @_NetPremium, @_DueToInsurer);
					fetch next from c_Risks into @Addr1, @Addr2, @Addr3, @Addr4, @PostCode, @PRN, @HomeBuildingsSI, 	@HomeBuildingsPrem,	@HomeContentsSI, @HomeContentsPrem,	@HomePersonalPossSI,@HomePersonalPossPrem,@FineArtSI,@FineArtPrem,@PropertyDamageBuildingsSI,@PropertyDamageBuildingsPrem,
						@PropertyDamageContentsSI,@PropertyDamageContentsPrem,@LossOfRevenueSI,	@LossOfRevenuePrem,	@LivestockSI,@LivestockPrem,@LivestockARMSI,@LivestockARMPrem,@DiseaseSI,@DiseasePrem,@EmployersLiabilitySI,
						@EmployersLiabilityPrem,@PublicLiabilitySI,@PublicLiabilityPrem,@EnvironmentalLiabilitySI,@EnvironmentalLiabilityPrem,@PersonalAccidentSI, @PersonalAccidentPrem,@GoodsInTransitSI,
						@GoodsInTransitPrem,@AllRisksSI,@AllRisksPrem,@MoneySI,@MoneyPrem,@CARSI,@CARPrem,@TerrorismSI,@TerrorismPrem, @TotalPremium, @TotalIptAmount, @TotalCommissionAmount, @_NetPremium, @_DueToInsurer
				end
				close c_Risks;
				deallocate c_Risks;
			END
		END			
		
		IF(@PolicyType = 'HN')
			--Get Next version number of record
			BEGIN
			select @VersionId = max(version) from rep_bdx_riskdata where branch = @Branch and clientRef = @ClientRef and policyRef = @PolicyId;
			if(@VersionId is null)
				SET @VersionId = 1; 
			ELSE
				SET @VersionId += 1;
							
		
			set @NetPremium = @OriginalDebt-@CommissionAmount;
			set @DueToInsurer = @NetPremium + @IptAmount;

			select @InsurerPolicyRef = [polno#], @InsurerName = [insco#], @RenewalDate = [Rdat#], @InceptionDate = [Idat#] from brpolicy where [PolRef@] = @PolicyId;
			select @FullName = dbo.GetFullName(@clientRef);

			DECLARE c_Risks cursor for 
				select addr1#,addr2#,addr3#,addr4#,pcode#, Bld_si#, bld_prem#, Cnt_si#, Cnt_prem#, V_si#, V_prem#
				from BD_HNH1 
				where (PolRef@ = @PolicyId AND Ref@ = @ClientRef and b@ = @Branch);
			open c_Risks;
										--addr1#, addr2#,addr3#, addr4#, pcode#,    Bld_si#,         bld_prem#,         Cnt_si#,          Cnt_prem#,       V_si#, V_prem#,
			fetch next from c_Risks into @Addr1, @Addr2, @Addr3, @Addr4, @PostCode, @HomeBuildingsSI,@HomeBuildingsPrem,@HomeContentsSI, @HomeContentsPrem, @HomePersonalPossSI, @HomePersonalPossPrem;
			while @@fetch_status <> -1
				BEGIN
					select @Address = dbo.GetAddress(@Addr1,@Addr2,@Addr3,@Addr4,@PostCode);
					insert into rep_bdx_riskdata(branch,clientRef,policyRef,insurerPolicyRef,Insurer,policyType,version,           DateOfEntry,  InceptionDate,    EffectiveDate, changeReason,TransType,riskAddress, postcode, YearOfAccount, HomeBuildingsSI, HomeBuildingsPrem, HomeContentsSI, HomeContentsPrem, HomePersonalPossSI, HomePersonalPossPrem, FineArtSI, FineArtPrem, 
					PropertyDamageBuildingsSI, PropertyDamageBuildingsPrem, PropertyDamageContentsPrem, PropertyDamageContentsSI, LossOfRevenuePrem, LossOfRevenueSI, LivestockSI, LivestockPrem, LivestockARMSI, LivestockARMPrem, DiseaseSI, DiseasePrem, EmployersLiabilitySI, 
														EmployersLiabilityPrem, PublicLiabilitySI, PublicLiabilityPrem,	EnvironmentalLiabilitySI, EnvironmentalLiabilityPrem, PersonalAccidentSI, PersonalAccidentPrem, GoodsInTransitSI, GoodsInTransitPrem, AllRisksSI, AllRisksPrem, MoneySI, MoneyPrem, CARSI, CARPrem, TerrorismSI, TerrorismPrem, GrossPremium, IPT, BrokerageAmount, NetPremium, AmountDueToInsurers) 
														values
													  (@branch,@clientRef,@PolicyId,@InsurerPolicyRef,@InsurerName, @PolicyType,@VersionId, CURRENT_TIMESTAMP,@InceptionDate, @DateRaised,   @method, @TransType, @Address, @PostCode, @yearOfAccount, @HomeBuildingsSI,@HomeBuildingsPrem,@HomeContentsSI,@HomeContentsPrem,@HomePersonalPossSI,@HomePersonalPossPrem,@FineArtSI,@FineArtPrem,
														@PropertyDamageBuildingsSI,@PropertyDamageBuildingsPrem,@PropertyDamageContentsPrem,@PropertyDamageContentsSI,@LossOfRevenuePrem,@LossOfRevenueSI,@LivestockSI,@LivestockPrem,@LivestockARMSI,@LivestockARMPrem,@DiseaseSI,@DiseasePrem,@EmployersLiabilitySI,@EmployersLiabilityPrem,@PublicLiabilitySI,
														@PublicLiabilityPrem,@EnvironmentalLiabilitySI,@EnvironmentalLiabilityPrem,@PersonalAccidentSI,@PersonalAccidentPrem,@GoodsInTransitSI,@GoodsInTransitPrem,@AllRisksSI,@AllRisksPrem,@MoneySI,@MoneyPrem,@CARSI,@CARPrem,@TerrorismSI,@TerrorismPrem,@TotalPremium, @TotalIptAmount,@TotalCommissionAmount, @_NetPremium, @_DueToInsurer);
					fetch next from c_Risks into @Addr1, @Addr2, @Addr3, @Addr4, @PostCode, @PRN, @HomeBuildingsSI, 	@HomeBuildingsPrem,	@HomeContentsSI, @HomeContentsPrem,	@HomePersonalPossSI,@HomePersonalPossPrem,@FineArtSI,@FineArtPrem,@PropertyDamageBuildingsSI,@PropertyDamageBuildingsPrem,
						@PropertyDamageContentsSI,@PropertyDamageContentsPrem,@LossOfRevenueSI,	@LossOfRevenuePrem,	@LivestockSI,@LivestockPrem,@LivestockARMSI,@LivestockARMPrem,@DiseaseSI,@DiseasePrem,@EmployersLiabilitySI,
						@EmployersLiabilityPrem,@PublicLiabilitySI,@PublicLiabilityPrem,@EnvironmentalLiabilitySI,@EnvironmentalLiabilityPrem,@PersonalAccidentSI, @PersonalAccidentPrem,@GoodsInTransitSI,
						@GoodsInTransitPrem,@AllRisksSI,@AllRisksPrem,@MoneySI,@MoneyPrem,@CARSI,@CARPrem,@TerrorismSI,@TerrorismPrem, @TotalPremium, @TotalIptAmount, @TotalCommissionAmount, @_NetPremium, @_DueToInsurer

					fetch next from c_Risks into @Addr1, @Addr2, @Addr3, @Addr4, @PostCode, @HomeBuildingsSI,@HomeBuildingsPrem,@HomeContentsSI, @HomeContentsPrem, @HomePersonalPossSI, @HomePersonalPossPrem
				END
			close c_Risks;
			deallocate c_Risks;
		END