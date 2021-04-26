-----------Q3
-----------a)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Jay' and Last_Name = 'Smith';
/*
730	Jay	Smith	N
731	Jay	Smith	N
*/

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 730 and Customer_Number = 731;
--No data returned

Begin
PR_Q3('Jay', 'Smith');
End;
/*
Error starting at line : 56 in command -
Begin
PR_Q3('Jay', 'Smith');
End;
Error report -
ORA-20611: Unexpected error in PR_Q3 ORA-20700: Multiple customers found with the same name Jay Smith
ORA-06512: at "ORCL2_12.PR_Q3", line 51
ORA-06512: at line 2
*/

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 730 and Customer_Number = 731;
--No data returned

-----------b)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Test' and Last_Name = 'Test';
--No data returned - customer does not exist

Begin
PR_Q3('Test', 'Test');
End;
/*
Error starting at line : 75 in command -
Begin
PR_Q3('Test', 'Test');
End;
Error report -
ORA-20611: Unexpected error in PR_Q3 ORA-20500: No customer found - Test Test
ORA-06512: at "ORCL2_12.PR_Q3", line 51
ORA-06512: at line 2
*/

Select RIN.Invoice_Number, RIN.Customer_Number
From Rental_Invoice RIN, Customer CUS
Where RIN.Customer_Number = CUS.Customer_Number
And CUS.First_Name = 'Test' and CUS.Last_Name = 'Test';
--No data returned

-----------c)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Ken' and Last_Name = 'Smith';
-- 740	Ken	Smith	N

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 740;
--No data returned

Begin 
PR_Q3('Ken', 'Smith');
End;
/*
Error starting at line : 98 in command -
Begin 
PR_Q3('Ken', 'Smith');
End;
Error report -
ORA-20611: Unexpected error in PR_Q3 ORA-20800: Customer status is set to N for Ken Smith
ORA-06512: at "ORCL2_12.PR_Q3", line 51
ORA-06512: at line 2
*/

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 740
--No data returned - insert prevented


-----------d)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Help' and Last_Name = 'Me';
--749	Help	Me	Y

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 749;
--25732	749

Begin
PR_Q3('Help', 'Me');
End;
--PL/SQL procedure successfully completed.

Select Invoice_Number, Customer_Number
From Rental_Invoice
Where Customer_Number = 749;
/*
25732	749
25733	749
*/




-----------Q4
-----------a)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Test' and Last_Name = 'Test';
--No data returned - customer does not exist

Select PKG_Q4.FN_Q4 ('Test', 'Test')
From Dual;
/*
ORA-20500: No customer found - Test Test
ORA-06512: at "ORCL2_12.PKG_Q4", line 34
*/

Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where Customer_Number = 999;
--No data returned - customer does not exist

Select PKG_Q4.FN_Q4 (999)
From Dual;
/*
ORA-20501: No customer found with the number - 999
ORA-06512: at "ORCL2_12.PKG_Q4", line 82
*/



-----------b)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Jay' and Last_Name = 'Smith';
/*
730	Jay	Smith	N
731	Jay	Smith	N
*/

Select PKG_Q4.FN_Q4 ('Jay', 'Smith')
From Dual;
/*
ORA-20700: Multiple customers found with the name - Jay Smith
ORA-06512: at "ORCL2_12.PKG_Q4", line 32
*/

-----------c)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Ken' and Last_Name = 'Smith';
--740	Ken	Smith	N

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number
From Customer CUS, Rental_Invoice RIN, Rental_Invoice_Detail RID
Where CUS.Customer_Number = RIN.Customer_Number
And RIN.Invoice_Number = RID.Invoice_Number
And Lower(CUS.First_Name) = Lower('Ken') and Lower(CUS.Last_Name) = Lower('Smith')
And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(RID.Date_Returned)
And Lower(RID.Overdue_Paid_YN) = Lower('N');
--No data returned - customer has no outstanding rental invoices

Select PKG_Q4.FN_Q4 ('Ken', 'Smith')
From Dual;
--740 - Ken Smith has no outstanding rentals

Select PKG_Q4.FN_Q4 (740)
From Dual;
--740 - Ken Smith has no outstanding rentals

-----------d)
Select Customer_Number, First_Name, Last_Name, Current_Status_YN
From Customer
Where First_Name = 'Dave' and Last_Name = 'Brown';
--120	Dave	Brown	Y

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number
From Customer CUS, Rental_Invoice RIN, Rental_Invoice_Detail RID
Where CUS.Customer_Number = RIN.Customer_Number
And RIN.Invoice_Number = RID.Invoice_Number
And Lower(CUS.First_Name) = Lower('Dave') and Lower(CUS.Last_Name) = Lower('Brown')
And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(RID.Date_Returned)
And Lower(RID.Overdue_Paid_YN) = Lower('N');
/*
23100	05-APR-20	2	08-APR-20	120
20210	04-NOV-19	2	07-NOV-19	120
*/

Select PKG_Q4.FN_Q4 ('Dave', 'Brown')
From Dual;
--120 - Dave Brown has the following outstanding rentals:  20210 23100

Select PKG_Q4.FN_Q4 (120)
From Dual;
--120 - Dave Brown has the following outstanding rentals:  20210 23100

-----------Q4
-----------a)
--Overdue Rentals
Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 746
And RID.Date_Returned IS NULL
And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(CURRENT_TIMESTAMP);
/*
25730	31-MAY-19	1300-001	7		746
25730	31-MAY-19	1300-002	7		746
25730	31-MAY-19	1400-001	7		746
25730	31-MAY-19	1400-002	7		746
25730	31-MAY-19	2210-001	7		746
*/

Insert into Rental_Invoice_Detail
	(Invoice_Number, Bar_Code, Date_Returned, Rental_Duration, Original_Rental_Rate, Overdue_Paid_Yn, Overdue_Rental_Rate) 
Values
	(25730, '2210-001', null, 7, 3.75, 'N', Null); 
/*
Error starting at line : 219 in command -
Insert into Rental_Invoice_Detail
	(Invoice_Number, Bar_Code, Date_Returned, Rental_Duration, Original_Rental_Rate, Overdue_Paid_Yn, Overdue_Rental_Rate) 
Values
	(25730, '2210-001', null, 7, 3.75, 'N', Null)
Error report -
ORA-20011: Customer 746 cannot have more than 5 overdue rentals
ORA-06512: at "ORCL2_12.TR_Q5", line 50
ORA-04088: error during execution of trigger 'ORCL2_12.TR_Q5'
*/

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 746
And RID.Date_Returned IS NULL
And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(CURRENT_TIMESTAMP);
/*
25730	31-MAY-19	1300-001	7		746	N
25730	31-MAY-19	1300-002	7		746	N
25730	31-MAY-19	1400-001	7		746	N
25730	31-MAY-19	1400-002	7		746	N
25730	31-MAY-19	2210-001	7		746	N
*/

-----------b)
--Outstanding Rentals
Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 750
And Lower(RID.Overdue_Paid_YN) = Lower('N')
And (Trunc(RIN.Invoice_Date) + RID.Rental_Duration) < Trunc(RID.Date_Returned);
/*
25735	04-NOV-19	1400-002	7	23-OCT-20	750	N
25735	04-NOV-19	2210-001	7	23-OCT-20	750	N
25735	04-NOV-19	2210-006	7	23-OCT-20	750	N
*/

Insert into Rental_Invoice_Detail
	(Invoice_Number, Bar_Code, Date_Returned, Rental_Duration, Original_Rental_Rate, Overdue_Paid_Yn, Overdue_Rental_Rate) 
Values
	(25735, '2210-005', To_Date('23-Oct-2020 10:03:42', 'DD-Mon-YYYY HH24:MI:SS'), 7, 3.75, 'N', Null); 
/*
Error starting at line : 263 in command -
Insert into Rental_Invoice_Detail
	(Invoice_Number, Bar_Code, Date_Returned, Rental_Duration, Original_Rental_Rate, Overdue_Paid_Yn, Overdue_Rental_Rate) 
Values
	(25735, '2210-005', To_Date('23-Oct-2020 10:03:42', 'DD-Mon-YYYY HH24:MI:SS'), 7, 3.75, 'N', Null)
Error report -
ORA-20010: Customer 750 cannot have more than 3 outstanding rentals
ORA-06512: at "ORCL2_12.TR_Q5", line 48
ORA-04088: error during execution of trigger 'ORCL2_12.TR_Q5'
*/

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 750
And Lower(RID.Overdue_Paid_YN) = Lower('N')
And (Trunc(RIN.Invoice_Date) + RID.Rental_Duration) < Trunc(RID.Date_Returned);

/*
25735	04-NOV-19	1400-002	7	23-OCT-20	750	N
25735	04-NOV-19	2210-001	7	23-OCT-20	750	N
25735	04-NOV-19	2210-006	7	23-OCT-20	750	N
*/

-----------c)
--Working 
Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 751
And Lower(RID.Overdue_Paid_YN) = Lower('N')
And (Trunc(RIN.Invoice_Date) + RID.Rental_Duration) < Trunc(RID.Date_Returned);
--No data - customer has no outstanding rentals

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 751
And RID.Date_Returned IS NULL
And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(CURRENT_TIMESTAMP);
--No data - customer has no overdue rentals

Select RID.Invoice_Number, RIN.Invoice_Date, RID.Bar_Code, RID.Rental_Duration, RID.Date_Returned, RIN.Customer_Number, RID.Overdue_Paid_YN
From Rental_Invoice_Detail RID, Rental_Invoice RIN
Where RID.Invoice_Number = RIN.Invoice_Number 
And RIN.Customer_Number = 751;
--25739	23-OCT-20	2210-005	7	23-OCT-20	751	N

Insert into Rental_Invoice_Detail
	(Invoice_Number, Bar_Code, Date_Returned, Rental_Duration, Original_Rental_Rate, Overdue_Paid_Yn, Overdue_Rental_Rate) 
Values
	(25739, '2230-004', To_Date('23-Oct-2020 10:03:42', 'DD-Mon-YYYY HH24:MI:SS'), 7, 3.75, 'N', Null); 
/*
25739	23-OCT-20	2210-005	7	23-OCT-20	751	N
25739	23-OCT-20	2230-004	7	23-OCT-20	751	N
*/
    