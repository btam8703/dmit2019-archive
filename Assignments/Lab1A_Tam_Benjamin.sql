--Drop Table Special_Order_Detail;
--Drop Table Rental_Invoice_Detail;
--Drop Table Rental_Item_Copy;
--Drop Table Special_Order;
--Drop Table Rental_Item;
--Drop Table Rental_Invoice;
--Drop Table Supplier;
--Drop Table Special_Order_Item;
--Drop Table Customer;
--Drop Sequence Seq_Customer;
--Drop Sequence Seq_Invoice;
--Drop Sequence Seq_Item;
--Drop Sequence Seq_Order;
--Delete From Rental_Invoice_Detail;
--Delete From Special_Order_Detail;
--Delete From Rental_Item_Copy;
--Delete From Rental_Invoice;
--Delete From Special_Order;
--Delete From Special_Order_Item;
--Delete From Rental_Item;
--Delete From Supplier;
--Delete From Customer;

Create Table Customer 
(
	Customer_Number Number(6,0)		Constraint PK_CUSCustomer_Number Primary Key 
									Constraint NN_CUSCustomer_Number Not Null,
	First_Name Varchar2(25)			Constraint NN_CUSFirst_Name Not Null,
	Last_Name Varchar2(30)			Constraint NN_CUSLast_Name Not Null,
	Area_Code Number(3,0)			Default(780)
									Constraint NU_CUSArea_Code Null
                                    Constraint CK_CUSArea_Code3DigitsLong Check (REGEXP_LIKE(Area_Code, '[0-9]{3}')),
    Phone_Number Number(7,0)		Constraint NU_CUSPhone_Number Null,
	Street_Address Varchar2(35) 	Constraint NU_CUSStreet_Address Null,
	City Varchar2(25) 				Constraint NU_CUSCity Null,
	Province Char(2)				Default('AB')
                                    Constraint NU_CUSProvince Null
                                    Constraint CK_CUSProvince2CapitalLetters Check (REGEXP_LIKE(Province, '[A-Z]{2}')),									
	Postal_Code Char(6)				Constraint NU_CUSPostal_Code Null,
	Email_Address Varchar2(75)		Constraint NN_CUSEmail_Address Not Null,
	Membership_Date Date			Default SYSDATE
                                    Constraint NN_CUSMembership_Date Not Null,
	Current_Status_YN Char(1) 		Default('Y')
									Constraint NN_CUSCurrent_Status_YN Not Null
									Constraint CK_CUSCurrent_Status_YN_YesNo Check (REGEXP_LIKE(Current_Status_YN, '[Y|N]'))									
);

Create Table Special_Order_Item 
(
	Item_Number Number(6,0) 		Constraint PK_SOIItem_Number Primary Key
									Constraint NN_SOIItem_Number Not Null,
	Description Varchar2(80)		Constraint NN_SOIDescription Not Null,
	Item_Cost	Number(7,2) 		Constraint NU_SOIItem_Cost Null
									Constraint CK_SOIItem_CostGr0 Check (Item_Cost > 0)								
);

Create Table Supplier
(
	Supplier_Number Number(4,0) 	Constraint PK_SUPSupplier_Number Primary Key
									Constraint NN_SUPSupplier_Number Not Null,
	Supplier_Name Varchar2(50)		Constraint NN_SUPSupplier_Name Not Null,
	Active_YN Char(1)				Default('Y')
									Constraint NN_SUPActive_YN Not Null
									Constraint CK_SUPActive_YN_YesNo Check (REGEXP_LIKE(Active_YN, '[Y|N]'))									
);

Create Table Rental_Invoice 
(
	Invoice_Number Number(5,0)		Constraint PK_RINInvoice_Number Primary Key
									Constraint NN_RINInvoice_Number Not Null,
	Customer_Number Number(6,0)		Constraint NN_RINCustomer_Number Not Null,
	Invoice_Date Date				Default SYSDATE
									Constraint NN_RINInvoice_Date Not Null,
                                    Constraint FK_RINCustomer_Number Foreign Key (Customer_Number) References Customer(Customer_Number)
);

Create Table Rental_Item 
(
	Rental_Item_Number Number(4,0)	Constraint PK_RITRental_Item_Number Primary Key 
									Constraint NN_RITRental_Item_Number Not Null,
	Supplier_Number Number (4,0)	Constraint NN_RITSupplier_Number Not Null,
	Description Varchar2(80)		Constraint NN_RITDescription Not Null,
	Rental_Duration Number(2,0)		Constraint NN_RITRental_Duration Not Null,
	Rental_Rate Number(4,2)			Default(4.40)
									Constraint NN_RITRental_Rate Not Null
									Constraint CK_RITRental_RateGr0 Check (Rental_Rate > 0),
	Overdue_Rental_Rate Number(4,2) Default(3.83)
									Constraint NN_RITOverdue_Rental_Duration Not Null
									Constraint CK_RITOverdue_Rental_RateGr0 Check (Overdue_Rental_Rate > 0),
                                    Constraint FK_RITSupplier_Number Foreign Key (Supplier_Number) References Supplier(Supplier_Number)
);

Create Table Special_Order
(
	Order_Number Number(8,0)		Constraint PK_SOROrder_Number Primary Key
									Constraint NN_SOROrder_Number Not Null,
	Customer_Number Number(6,0)		Constraint NN_SORSupplier_Number Not Null,
	Order_Date Date					Default SYSDATE
									Constraint NN_SOROrder_Date Not Null,
	Received_Date Date				Default SYSDATE
									Constraint NU_SORReceived_Date Null,
	Picked_Up_Date Date				Default SYSDATE
									Constraint NU_SORPicked_Up_Date Null,
                                    Constraint FK_SORCustomer_Number Foreign Key (Customer_Number) References Customer(Customer_Number),
									Constraint CK_SORPicked_Up_DateReceived_D Check (Picked_Up_Date > Received_Date)
);

Create Table Rental_Item_Copy 
(
	Bar_Code Char(8)				Constraint PK_RICBar_Code Primary Key
									Constraint NN_RICBar_Code Not Null
                                    Constraint CK_RICBar_CodeCorrectFormat Check (REGEXP_LIKE(Bar_Code, '[1-9][0-9]{3}-[0-9]{2}[1-9]|[0-9][1-9][0-9]')),			
	Rental_Item_Number Number(4,0)	Constraint NN_RICRental_Item_Number Not Null,
	Purchase_Cost Number (6,2) 		Constraint NU_RICPurchase_Cost Null
									Constraint CK_RICPurchase_CostGr0 Check (Purchase_Cost > 0),
                                    Constraint FK_RICRental_Item_Number Foreign Key (Rental_Item_Number) References Rental_Item(Rental_Item_Number)
);

Create Table Rental_Invoice_Detail 
(
	Invoice_Number Number(5,0)		Constraint NN_RIDInvoice_Number Not Null,
	Bar_Code Char(8)				Constraint NN_RIDBar_Code Not Null,
	Date_Returned Date				Default SYSDATE
									Constraint NU_RIDDate_Returned Null,
	Rental_Duration Number(2,0)		Constraint NN_RIDRental_Duration Not Null,
	Original_Rental_Rate Number(4,2)Default(4.40)
									Constraint NN_RIDOriginal_Rental_Rate Not Null
									Constraint CK_RIDOriginal_Rental_RateGr0 Check (Original_Rental_Rate > 0),
	Overdue_Paid_YN Char(1)			Default ('N')
									Constraint NU_RIDOverdue_Paid_YN Null
									Constraint CK_RIDOverdue_Paid_YN_YesNo Check (REGEXP_LIKE(Overdue_Paid_YN, '[Y|N]')),	
	Overdue_Rental_Rate Number(4,2)	Default(3.83)
									Constraint NU_RIDOverdue_Rental_Rate Null
									Constraint CK_RIDOverdue_Rental_RateGr0 Check (Overdue_Rental_Rate > 0),
                                    Constraint PK_RIDInvoice_NumberBar_Code Primary Key (Invoice_Number, Bar_Code),
                                    Constraint FK_RIDInvoice_Number Foreign Key (Invoice_Number) References Rental_Invoice(Invoice_Number),
                                    Constraint FK_RIDBar_Code Foreign Key (Bar_Code) References Rental_Item_Copy(Bar_Code)
);

Create Table Special_Order_Detail 
(
	Order_Number Number(8,0)		Constraint NN_SODOrder_Number Not Null,
	Item_Number Number(6,0)			Constraint NN_SODItem_Number Not Null,
	Quantity Number(5,0)			Constraint NN_SODQuantity Not Null
									Constraint CK_SODQuantityNotNeg Check (Quantity >= 0),
	Sales_Price Number(7,2)			Constraint NN_SODSales_Price Not Null
									Constraint CK_SODSales_PriceGr0 Check (Sales_Price > 0),
                                    Constraint PK_SODOrder_NumberItem_Number Primary Key (Order_Number, Item_Number),
                                    Constraint FK_SODOrder_Number Foreign Key (Order_Number) References Special_Order(Order_Number),
                                    Constraint FK_SODItem_Number Foreign Key (Item_Number) References Special_Order_Item(Item_Number)
);

Create Sequence Seq_Customer 
    Start With 750
    Increment By 10
    Nocache;
    
Create Sequence Seq_Invoice
    Start With 25700
    Increment By 1
    Nocache;
    
Create Sequence Seq_Item
    Start With 9000
    Increment By 100
    Nocache;

Create Sequence Seq_Order
    Start With 500
    Increment By 5
    Nocache;
