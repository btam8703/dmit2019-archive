Create or Replace Procedure PR_Q3
    (P_FirstName Varchar2, P_LastName Varchar2)
Authid Current_User
As
    V_Customer_Number Number(6,0);
    V_Invoice_Number Number(5,0);
    V_Invoice_Date Date;
    V_CheckCustomerStatus Char(1);

Begin
    Begin
        Select Current_Status_YN, Customer_Number
        Into V_CheckCustomerStatus, V_Customer_Number
        From Customer
        Where Lower(First_Name) = Lower(P_FirstName) And Lower(Last_Name) = Lower(P_LastName)
        Group by Current_Status_YN, Customer_Number;
    Exception
        When Too_Many_Rows Then
            Raise_Application_Error(-20700, 'Multiple customers found with the same name ' || P_FirstName || ' ' || P_LastName);
        When No_Data_Found Then
            Raise_Application_Error(-20500, 'No customer found - ' || P_FirstName || ' ' || P_LastName);
        When Others Then
            Raise_Application_Error(-20600, 'Error with PR_Q3 customer check ' || SQLERRM);
    End;
    If lower(V_CheckCustomerStatus) = lower('N') Then
        Raise_Application_Error(-20800, 'Customer status is set to N for ' || P_FirstName || ' ' || P_LastName);
    Else
        Begin
        Select Seq_Invoice.NEXTVAL, CURRENT_TIMESTAMP
        Into V_Invoice_Number, V_Invoice_Date
        From Dual;
        Exception
            When Others Then
                Raise_Application_Error(-20605, 'Error with PR_Q3 sequence and timestamp select ' || SQLERRM);
        End;
        
        Begin
        Insert Into Rental_Invoice
            (Invoice_Number, Customer_Number, Invoice_Date)
        Values 
            (V_Invoice_Number, V_Customer_Number, V_Invoice_Date);
        Exception
            When Others Then    
                Raise_Application_Error(-20603, 'Error with PR_Q3 insert' || SQLERRM);
        End;
    End If;
Exception
    When Others Then
        Raise_Application_Error(-20611, 'Unexpected error in PR_Q3 ' || SQLERRM);
End PR_Q3;
/
Show Errors;





Create or Replace Package PKG_Q4
Authid Current_User
As
    Function FN_Q4
        (P_FirstName Varchar2, P_LastName Varchar2)
    Return Varchar2;
    
    Function FN_Q4
        (P_Customer_Number Number)
    Return Varchar2;
End PKG_Q4;
/
Show Errors;

Create or Replace Package Body PKG_Q4
As
    Function FN_Q4
        (P_FirstName Varchar2, P_LastName Varchar2)
    Return Varchar2
    As
    
    V_Customer_Number Number(6,0);
    V_CheckCustomerCount Number(2,0);
    V_Invoice_Number Number(5,0);
    V_Output 	Varchar2(500);
    

	Cursor C_Rental_Invoice Is Select RID.Invoice_Number
                            From Customer CUS, Rental_Invoice RIN, Rental_Invoice_Detail RID
                            Where CUS.Customer_Number = RIN.Customer_Number
                            And Lower(CUS.First_Name) = Lower(P_FirstName) and Lower(CUS.Last_Name) = Lower(P_LastName)
                            And RIN.Invoice_Number = RID.Invoice_Number
                            And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(RID.Date_Returned)
                            And Lower(RID.Overdue_Paid_YN) = Lower('N')
                            Order by CUS.Customer_Number;
    Begin
        Begin
            Select Count(Customer_Number), Customer_Number
            Into V_CheckCustomerCount, V_Customer_Number
            From Customer
            Where Lower(First_Name) = Lower(P_FirstName) And Lower(Last_Name) = Lower(P_LastName)
            Group by Current_Status_YN, Customer_Number;
        Exception
            When Too_Many_Rows Then
                Raise_Application_Error(-20700, 'Multiple customers found with the name - ' || P_FirstName || ' ' || P_LastName);
            When No_Data_Found Then
                Raise_Application_Error(-20500, 'No customer found - ' || P_FirstName || ' ' || P_LastName);
            When Others Then
                Raise_Application_Error(-20600, 'Error with FKG_Q4 FN_Q4 customer check ' || SQLERRM);
        End;
        Open C_Rental_Invoice;
            Fetch C_Rental_Invoice Into V_Invoice_Number;
            If C_Rental_Invoice%NotFound Then 
                V_Output := V_Customer_Number || ' - ' || P_FirstName || ' ' || P_LastName || ' has no outstanding rentals';
            Else
                V_Output := V_Customer_Number || ' - ' || P_FirstName || ' ' || P_LastName || ' has the following outstanding rentals: ';
                While C_Rental_Invoice%Found Loop
                    V_Output := V_Output || ' ' || to_char(V_Invoice_Number);
                    Fetch C_Rental_Invoice Into V_Invoice_Number;
                End Loop;
            End If;
        Close C_Rental_Invoice;
        Return V_Output;
    End FN_Q4;
    
    Function FN_Q4
        (P_Customer_Number Number)
    Return Varchar2
    As
    
    V_First_Name Varchar2(25);
    V_Last_Name Varchar2(30);
    V_Invoice_Number Number(5,0);
    V_Output 	Varchar2(500);
    

	Cursor C_Rental_Invoice Is Select RID.Invoice_Number
                            From Customer CUS, Rental_Invoice RIN, Rental_Invoice_Detail RID
                            Where CUS.Customer_Number = RIN.Customer_Number
                            And RIN.Invoice_Number = RID.Invoice_Number
                            And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(RID.Date_Returned)
                            And Lower(RID.Overdue_Paid_YN) = Lower('N')
                            And RIN.Customer_Number = P_Customer_Number
                            Order by CUS.Customer_Number;
    Begin
        Begin
            Select First_Name, Last_Name
            Into V_First_Name, V_Last_Name
            From Customer
            Where P_Customer_Number = Customer_Number
            Group by First_Name, Last_Name;
        Exception
            When No_Data_Found Then
                Raise_Application_Error(-20501, 'No customer found with the number - '|| P_Customer_Number);
            When Others Then
                Raise_Application_Error(-20601, 'Error with FKG_Q4 FN_Q4 customer check ' || SQLERRM);
        End;
        Open C_Rental_Invoice;
            Fetch C_Rental_Invoice Into V_Invoice_Number;
            If C_Rental_Invoice%NotFound Then 
                V_Output := P_Customer_Number || ' - ' || V_First_Name || ' ' || V_Last_Name || ' has no outstanding rentals';
            Else
                V_Output := P_Customer_Number || ' - ' || V_First_Name || ' ' || V_Last_Name || ' has the following outstanding rentals: ';
                While C_Rental_Invoice%Found Loop
                    V_Output := V_Output || ' ' || to_char(V_Invoice_Number);
                    Fetch C_Rental_Invoice Into V_Invoice_Number;
                End Loop;
            End If;
        Close C_Rental_Invoice;
        Return V_Output;
    End FN_Q4;
End PKG_Q4;
/
Show Errors;

Create or Replace Trigger TR_Q5
Before Insert 
On Rental_Invoice_Detail
For Each Row
Declare
    V_OutstandingRentalCheck Number(3,0);
    V_OverdueRentalCheck Number(3,0);
    V_Customer_Number Number(6,0);
    V_Invoice_Number Number(5,0); 
Begin
    V_Invoice_Number := :NEW.Invoice_Number;
    
    Begin
        Select Customer_Number
        Into V_Customer_Number
        From Rental_Invoice
        Where Invoice_Number = V_Invoice_Number;
    Exception
        When Others Then
             Raise_Application_Error(-20001, 'Error with TR_Q5 customer number select ' || SQLERRM);
    End;
    
    Begin
        Select Count(RID.Invoice_Number)
        Into V_OutstandingRentalCheck
        From Rental_Invoice_Detail RID, Rental_Invoice RIN
        Where RID.Invoice_Number = RIN.Invoice_Number 
        And RIN.Customer_Number = V_Customer_Number
        And Lower(RID.Overdue_Paid_YN) = Lower('N')
        And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(RID.Date_Returned);
    Exception
        When Others Then
             Raise_Application_Error(-20005, 'Error with TR_Q5 outstanding rental count' || SQLERRM);
    End;
    
    Begin
        Select Count(RID.Invoice_Number)
        Into V_OverdueRentalCheck
        From Rental_Invoice_Detail RID, Rental_Invoice RIN
        Where RID.Invoice_Number = RIN.Invoice_Number 
        And RIN.Customer_Number = V_Customer_Number
        And RID.Date_Returned IS NULL
        And Trunc(RIN.Invoice_Date) + RID.Rental_Duration < Trunc(CURRENT_TIMESTAMP);
     Exception
        When Others Then
             Raise_Application_Error(-20008, 'Error with TR_Q5 overdue rental count' || SQLERRM);
    End;
    
    If V_OutstandingRentalCheck >= 3 Then
        Raise_Application_Error (-20010, 'Customer ' || V_Customer_Number || ' cannot have more than 3 outstanding rentals');
    Elsif V_OverdueRentalCheck >= 5 Then
        Raise_Application_Error (-20011, 'Customer ' || V_Customer_Number || ' cannot have more than 5 overdue rentals');
    End If;
End TR_Q5;
/
Show Errors;

