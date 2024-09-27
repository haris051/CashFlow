drop procedure if Exists PROC_CASH_FLOW;
DELIMITER $$
CREATE PROCEDURE `PROC_CASH_FLOW`
								( 
												  
								  P_COMPANY_ID int,
								  P_ENTRY_DATE_FROM TEXT,
								  P_ENTRY_DATE_TO TEXT,
								  P_Year Text
												   
								)
BEGIN

/*Net Operating Income Variables*/

Declare INCOMEAMOUNT Decimal(22,2) default 0;
Declare COSTAMOUNT Decimal(22,2) default 0;
Declare EXPENSEAMOUNT Decimal(22,2) default 0;
Declare GROSSPROFITMONTHLY Decimal(22,2) default 0;
Declare NETOPERATINGMONTHLY DECIMAL(22,2) default 0;


Declare INCOMEAMOUNTYEARLY Decimal(22,2) default 0;
Declare COSTAMOUNTYEARLY DECIMAL(22,2) default 0;
Declare EXPENSEAMOUNTYEARLY DECIMAL(22,2) default 0;
Declare GROSSPROFITYEARLY DECIMAL(22,2) default 0;
Declare NETOPERATINGYEARLY DECIMAL(22,2) default 0;

/*Net Operating Income Variables*/


/*Cash From Operating Activities Variables*/

Declare CurrentTimeBalance_Operation_Activites_Var Decimal(22,2) default 0;
Declare YearToDateBalance_Operation_Activities_Var Decimal(22,2) default 0;

/*Cash From Operating Activites Variables*/

/*Cash Flow From Financing Activities Variables*/

Declare CurrentTimeBalance_Financing_Activities_Processed_From_Var Decimal(22,2) default 0;
Declare YearToDateBalance_Financing_Activities_Processed_From_Var Decimal(22,2) default 0;

Declare CurentTimeBalance_Financing_Activities_Used_For_Var Decimal(22,2) default 0;
Declare YearToDateBalance_Financing_Activities_Used_For_Var Decimal(22,2) default 0;

/*Cash Flow From Financing Activities Variables*/



/*Net Operating Income*/

select SUM(INCOME) as INCOME,SUM(COST) as COST,SUM(EXPENSE) as EXPENSE INTO INCOMEAMOUNT, COSTAMOUNT, EXPENSEAMOUNT
from(

	SELECT 
			IF(C.ACCOUNT_ID = 1,C.Amount,NULL) INCOME,
			IF(C.ACCOUNT_ID = 2,C.AMOUNT,NULL) COST,
			IF(C.ACCOUNT_ID = 5,C.AMOUNT,NULL) EXPENSE,
			IF(C.ACCOUNT_ID = '1' OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5','Balance',null)as Balance
		   
		FROM ( 
        
              select C.Amount,C.ACCOUNT_ID 
			  from(
					select
								SUM(A.BALANCE) AS Amount,
								C.ACCOUNT_ID 
					from 		
								daily_account_balance A 
					inner join	
								accounts_id B 
					ON			
								A.AccountId = B.id 
					inner join 	
								account_type C
					ON 			
								C.id = B.ACCOUNT_TYPE_ID 
					where
								case 
									when 
										P_ENTRY_DATE_FROM <> "" then A.EntryDate   >=  P_ENTRY_DATE_FROM
									ELSE 
									TRUE
								END
							 
					and 
								case 
									when 
										P_ENTRY_DATE_TO <> "" then A.EntryDate    <=  P_ENTRY_DATE_TO
									ELSE 
									TRUE
								END		
					and 
								case 
									when 
										P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID
									ELSE 
									TRUE
								END
					 
								
					group by 
								C.ACCOUNT_ID
				)C where C.ACCOUNT_ID = '1' OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5'
			 )C
    )C group by C.Balance;
	
	
	-- ===================== TOTAL GROSS Monthly=====================
	
	SELECT IFNULL(INCOMEAMOUNT, 0) - IFNULL(COSTAMOUNT, 0) INTO GROSSPROFITMONTHLY;

	-- ===================== TOTAL GROSS Monthly===================== 
	
    	
	-- ===================== NET OPERATING INCOME Monthly =====================

	SELECT IFNULL(GROSSPROFITMONTHLY, 0) - IFNULL(EXPENSEAMOUNT, 0) INTO NETOPERATINGMONTHLY;

	-- ===================== NET OPERATING INCOME Monthly===================== 
	
	
	select SUM(INCOME) as INCOME,SUM(COST) as COST,SUM(EXPENSE) as EXPENSE INTO INCOMEAMOUNTYEARLY,COSTAMOUNTYEARLY,EXPENSEAMOUNTYEARLY
	from(

			SELECT 
					IF(C.ACCOUNT_ID = 1,C.Amount,NULL) INCOME,
					IF(C.ACCOUNT_ID = 2,C.AMOUNT,NULL) COST,
					IF(C.ACCOUNT_ID = 5,C.AMOUNT,NULL) EXPENSE,
					IF(C.ACCOUNT_ID = 1 OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5','Balance',null)as Balance
				   
				FROM ( 
				
					  select C.Amount,C.ACCOUNT_ID from(
							select
										SUM(A.BALANCE) AS Amount,
										C.ACCOUNT_ID 
							from 		
										daily_account_balance A 
							inner join	
										accounts_id B 
							ON			
										A.AccountId = B.id 
							inner join 	
										account_type C
							ON 			
										C.id = B.ACCOUNT_TYPE_ID 
							where
										case 
											when 
												P_YEAR <> "" then A.EntryDate   >=  CONCAT(P_YEAR, '-01-01')
											ELSE 
											TRUE
										END
									 
							and 
										case 
											when 
												P_ENTRY_DATE_TO <> "" then A.EntryDate    <=  P_ENTRY_DATE_TO
											ELSE 
											TRUE
										END		
							and 
										case 
											when 
												P_COMPANY_ID <> "" then B.COMPANY_ID = P_COMPANY_ID
											ELSE 
											TRUE
										END
							 
										
							group by 
										C.ACCOUNT_ID
							)C where C.ACCOUNT_ID = 1 OR C.ACCOUNT_ID = '2' OR C.ACCOUNT_ID = '5'
					)C
		)C group by C.Balance;
	
	
	-- ===================== TOTAL GROSS YEARLY =====================
	
	SELECT IFNULL(INCOMEAMOUNTYEARLY, 0) - IFNULL(COSTAMOUNTYEARLY, 0) INTO GROSSPROFITYEARLY;

	-- ===================== TOTAL GROSS YEARLY ===================== 
	
	
	-- ===================== NET OPERATING INCOME YEARLY =====================

	SELECT IFNULL(GROSSPROFITYEARLY, 0) - IFNULL(EXPENSEAMOUNTYEARLY, 0) INTO NETOPERATINGYEARLY;

	-- ===================== NET OPERATING INCOME YEARLY =====================


    -- ==================== Cash From Operation Activities ===================

		select IFNULL(SUM(A.CurrentTimePeriodBalance),0),
			   IFNULL(SUM(A.YearToDateBalance),0)
			   INTO CurrentTimeBalance_Operation_Activites_Var,
					YearToDateBalance_Operation_Activities_Var
		from
		(
				select 
						case 
							  when IFNULL(A.BalanceFrom,0)>IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Assets' then Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)  
							  when IFNULL(A.BalanceFrom,0)<IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Assets' then Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
							  when IFNULL(A.BalanceFrom,0)=IFNULL(A.BalanceTo,0) then (Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)) * 1
							  when IFNULL(A.BalanceFrom,0)>IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.BalanceFrom,0) as Decimal(22,2)),2) 
							  when IFNULL(A.BalanceFrom,0)<IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.BalanceFrom,0) as Decimal(22,2)),2) 
						End as CurrentTimePeriodBalance,
						case 
							 when IFNULL(A.YearToBalanceTo,0) > IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Assets' then Round(cast(IFNULL(A.YearToBalanceTo,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
							 when IFNULL(A.YearToBalanceTo,0) < IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Assets' then Round(cast(IFNULL(A.YearToBalanceTo,0)  - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
							 when IFNULL(A.YearToBalanceTo,0) = IFNULL(A.BalanceTo,0) then (Round(cast(IFNULL(A.YearToBalanceTo,0)  - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)) * 1
							 when IFNULL(A.YearToBalanceTo,0) > IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.YearToBalanceTo,0) as Decimal(22,2)),2)
							 when IFNULL(A.YearToBalanceTo,0) < IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0)  - IFNULL(A.YearToBalanceTo,0) as Decimal(22,2)),2)
						End as YearToDateBalance
				from 
				(
				select 
						C.ACCOUNT_TYPE_NAME,
						B.DESCRIPTION,
						Sum(A.Balance)  as BalanceTo,
						Sum(if(convert(A.EntryDate,Date)<convert(P_ENTRY_DATE_FROM,Date),A.Balance,Null))  as BalanceFrom,
						Sum(if(convert(A.EntryDate,Date)<=convert(concat(P_YEAR ,'-', '01-01'),Date),A.Balance,NULL)) as YearToBalanceTo
						
				from daily_account_balance A 
				Right join accounts_id B on A.AccountId = B.id 
				inner join account_type C on C.id = B.ACCOUNT_TYPE_ID 
				where Lower(C.ACCOUNT_TYPE_NAME)  in ('current assets','current liabilities') and convert(A.EntryDate,Date) <= convert(P_ENTRY_DATE_TO,Date) and B.COMPANY_ID = P_COMPANY_ID group by B.DESCRIPTION,C.ACCOUNT_TYPE_NAME
				)A
		)A;

	-- ==================== Cash From Operation Activities ===================





	-- ==================== Cash Flow From Financing Activities ===============
	
		
		-- ==================== Processed From ====================================
	
	
			select
			IFNULL(SUM(A.Credit),0) into CurrentTimeBalance_Financing_Activities_Processed_From_Var
			from daily_account_balance A 
			inner join accounts_id B 
			ON A.AccountId = B.id 
			inner join account_type C 
			ON C.id = B.ACCOUNT_TYPE_ID
			where 
				  Convert(A.EntryDate,Date) <= Convert(P_ENTRY_DATE_TO,Date) 
			and   Convert(A.EntryDate,Date) >= Convert(P_ENTRY_DATE_FROM,Date)
			and   B.COMPANY_ID = P_COMPANY_ID
			and   LOWER(C.Account_Type_Name) = 'equity';
			
			select
			IFNULL(SUM(A.Credit),0) into YearToDateBalance_Financing_Activities_Processed_From_Var
			from daily_account_balance A 
			inner join accounts_id B 
			ON A.AccountId = B.id 
			inner join account_type C 
			ON C.id = B.ACCOUNT_TYPE_ID
			where 
				  Convert(A.EntryDate,Date) <= Convert(P_ENTRY_DATE_TO,Date) 
			and   Convert(A.EntryDate,Date) >= Convert(concat(P_YEAR,'-','01-01'),Date)
			and   B.COMPANY_ID = P_COMPANY_ID
			and   LOWER(C.Account_Type_Name) = 'equity';
			
			
					
	
			
		-- ==================== Processed From ====================================
	
	
		-- ==================== Used For ==========================================
		
			select IFNULL(SUM(A.Debit),0) * -1 into CurentTimeBalance_Financing_Activities_Used_For_Var
			from   daily_account_balance A 
			inner join accounts_id B 
			ON A.AccountId = B.id 
			inner join account_type C 
			ON C.id = B.ACCOUNT_TYPE_ID
			where Convert(A.EntryDate,Date) <= Convert(P_ENTRY_DATE_TO,Date)
			and  Convert(A.EntryDate,Date) >= Convert(P_ENTRY_DATE_FROM,Date)
			and  B.COMPANY_ID = P_COMPANY_ID;
				
			
			select IFNULL(SUM(A.Debit),0) * -1 into YearToDateBalance_Financing_Activities_Used_For_Var
			from   daily_account_balance A 
			inner join accounts_id B 
			ON A.AccountId = B.id 
			inner join account_type C 
			ON C.id = B.ACCOUNT_TYPE_ID
			where Convert(A.EntryDate,Date) <= Convert(P_ENTRY_DATE_TO,Date)
			and  Convert(A.EntryDate,Date)  >= Convert(concat(P_YEAR,'-','01-01'),Date)
			and  B.COMPANY_ID = P_COMPANY_ID;
		
		-- ==================== Used For ==========================================
	
	
	
	
	-- ============================================================================


select 'Cash From Operation Activities' as Description,'' as CurrentTimePeriodBalance,'' as YearToDateBalance

Union all


select '&nbsp;&nbsp;&nbsp;&nbsp;Net Operating Income' as Description,NETOPERATINGMONTHLY as CurrentTimePeriodBalance,NETOPERATINGYEARLY as YearToDateBalance

Union All



select 
        concat('&nbsp;&nbsp;&nbsp;&nbsp;',A.DESCRIPTION),
		case 
              when IFNULL(A.BalanceFrom,0)>IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Assets' then Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)  
              when IFNULL(A.BalanceFrom,0)<IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Assets' then Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
              when IFNULL(A.BalanceFrom,0)=IFNULL(A.BalanceTo,0) then (Round(cast(IFNULL(A.BalanceFrom,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)) * 1
              when IFNULL(A.BalanceFrom,0)>IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.BalanceFrom,0) as Decimal(22,2)),2) 
              when IFNULL(A.BalanceFrom,0)<IFNULL(A.BalanceTo,0) and A.ACCOUNT_TYPE_NAME ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.BalanceFrom,0) as Decimal(22,2)),2) 
        End as CurrentTimePeriodBalance,
        case 
			 when IFNULL(A.YearToBalanceTo,0) > IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Assets' then Round(cast(IFNULL(A.YearToBalanceTo,0) - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
             when IFNULL(A.YearToBalanceTo,0) < IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Assets' then Round(cast(IFNULL(A.YearToBalanceTo,0)  - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)
             when IFNULL(A.YearToBalanceTo,0) = IFNULL(A.BalanceTo,0) then (Round(cast(IFNULL(A.YearToBalanceTo,0)  - IFNULL(A.BalanceTo,0) as Decimal(22,2)),2)) * 1
             when IFNULL(A.YearToBalanceTo,0) > IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0) - IFNULL(A.YearToBalanceTo,0) as Decimal(22,2)),2)
             when IFNULL(A.YearToBalanceTo,0) < IFNULL(A.BalanceTo,0) and A.Account_Type_Name ='Current Liabilities' then Round(cast(IFNULL(A.BalanceTo,0)  - IFNULL(A.YearToBalanceTo,0) as Decimal(22,2)),2)
		End as YearToDateBalance
		
from 
(
select 
		C.ACCOUNT_TYPE_NAME,
        B.DESCRIPTION,
		Sum(A.Balance)  as BalanceTo,
        Sum(if(convert(A.EntryDate,Date)<convert(P_ENTRY_DATE_FROM,Date),A.Balance,Null))  as BalanceFrom,
        Sum(if(convert(A.EntryDate,Date)<=convert(concat(P_YEAR ,'-', '01-01'),Date),A.Balance,NULL)) as YearToBalanceTo
        
from daily_account_balance A 
Right join accounts_id B on A.AccountId = B.id 
inner join account_type C on C.id = B.ACCOUNT_TYPE_ID 
where Lower(C.ACCOUNT_TYPE_NAME)  in ('current assets','current liabilities') and convert(A.EntryDate,Date) <= convert(P_ENTRY_DATE_TO,Date) and B.COMPANY_ID = P_COMPANY_ID group by B.DESCRIPTION,C.ACCOUNT_TYPE_NAME
)A

union All 

select 'Cash Flow From Financing Activities' as Description,'' as CurrentTimePeriodBalance,'' as YearToDateBalance

union All 

select '&nbsp;&nbsp;&nbsp;&nbsp;Proceed From' as Description,
		CurrentTimeBalance_Financing_Activities_Processed_From_Var as CurrentTimePeriodBalance,
		YearToDateBalance_Financing_Activities_Processed_From_Var as YearToDateBalance
		

union All 

select '&nbsp;&nbsp;&nbsp;&nbsp;Used For' as Description,
	    CurentTimeBalance_Financing_Activities_Used_For_Var as CurrentTimePeriodBalance,
		YearToDateBalance_Financing_Activities_Used_For_Var as YearToDateBalance
		
		
union All 

select 'Net Difference' as Description,
	    CurrentTimeBalance_Financing_Activities_Processed_From_Var + CurentTimeBalance_Financing_Activities_Used_For_Var as CurrentTimePeriodBalance,
		YearToDateBalance_Financing_Activities_Processed_From_Var + YearToDateBalance_Financing_Activities_Used_For_Var as YearToDateBalance
		
		
Union All 

 

select '' as Description,'' as CurrentTimePeriodBalance,'' YearToDateBalance

Union All

select 'Total' as Description,
		CurrentTimeBalance_Financing_Activities_Processed_From_Var + CurentTimeBalance_Financing_Activities_Used_For_Var + CurrentTimeBalance_Operation_Activites_Var + NETOPERATINGMONTHLY as CurrentTimePeriodBalance,
		YearToDateBalance_Financing_Activities_Processed_From_Var + YearToDateBalance_Financing_Activities_Used_For_Var + YearToDateBalance_Operation_Activities_Var + NETOPERATINGYEARLY as YearToDateBalance

Union All 

select '' as Description,'' as CurrentTimePeriodBalance,'' YearToDateBalance

Union All 

select 'Balance At The Beginning Period' as DESCRIPTION,
	   IFNULL(SUM(A.Balance),0) as CurrentTimePeriodBalance,
	   '' as YearToDateBalance  	   
from   daily_account_balance A 
inner join accounts_id B 
on    A.AccountId = B.id 
inner join account_type C 
on  C.id = B.ACCOUNT_TYPE_ID
where Lower(C.Account_Type_Name) in ('bank','cash on hand')
and  Convert(A.EntryDate,Date) < Convert(P_ENTRY_DATE_FROM,Date)
and  B.COMPANY_ID = P_COMPANY_ID	   

Union all 	 

select 'Balance At The End Of Period' as DESCRIPTION,
	   IFNULL(SUM(A.Balance),0) as CurrentTimePeriodBalance,
	   '' as YearToDateBalance
from   daily_account_balance A 
inner join accounts_id B 
on    A.AccountId = B.id 
inner join account_type C 
on  C.id = B.ACCOUNT_TYPE_ID
where Lower(C.Account_Type_Name) in ('bank','cash on hand')
and  Convert(A.EntryDate,Date) <= Convert(P_ENTRY_DATE_To,Date)	   
and  B.COMPANY_ID = P_COMPANY_ID;

END $$
DELIMITER ;


