﻿#language: en
@tree
@Positive
@Movements
@MovementsOpeningEntry

Feature: check Opening entry movements


Background:
	Given I launch TestClient opening script or connect the existing one



Scenario: _042900 preparation (Opening entry)
	When set True value to the constant
	And I close TestClient session
	Given I open new TestClient session or connect the existing one
	* Load info
		When Create information register Barcodes records
		When Create catalog Companies objects (own Second company)
		When Create catalog Agreements objects
		When Create catalog ObjectStatuses objects
		When Create catalog ItemKeys objects
		When Create catalog ItemTypes objects
		When Create catalog Units objects
		When Create catalog Items objects
		When Create catalog PriceTypes objects
		When Create catalog Specifications objects
		When Create chart of characteristic types AddAttributeAndProperty objects
		When Create catalog AddAttributeAndPropertySets objects
		When Create catalog AddAttributeAndPropertyValues objects
		When Create catalog Currencies objects
		When Create catalog Companies objects (Main company)
		When Create catalog Stores objects
		When Create catalog Partners objects
		When Create catalog Companies objects (partners company)
		When Create information register PartnerSegments records
		When Create catalog PartnerSegments objects
		When Create chart of characteristic types CurrencyMovementType objects
		When Create catalog TaxRates objects
		When Create catalog Taxes objects	
		When Create information register TaxSettings records
		When Create information register PricesByItemKeys records
		When Create catalog IntegrationSettings objects
		When Create information register CurrencyRates records
		When Create catalog BusinessUnits objects
		When Create catalog ExpenseAndRevenueTypes objects
		When Create catalog Companies objects (second company Ferron BP)
		When Create catalog PartnersBankAccounts objects
		When update ItemKeys
		When Create catalog SerialLotNumbers objects
		When Create catalog CashAccounts objects
	* Add plugin for taxes calculation
		Given I open hyperlink "e1cib/list/Catalog.ExternalDataProc"
		If "List" table does not contain lines Then
				| "Description" |
				| "TaxCalculateVAT_TR" |
			When add Plugin for tax calculation
		When Create information register Taxes records (VAT)
	* Tax settings
		When filling in Tax settings for company
	When Create Document discount
	* Add plugin for discount
		Given I open hyperlink "e1cib/list/Catalog.ExternalDataProc"
		If "List" table does not contain lines Then
				| "Description" |
				| "DocumentDiscount" |
			When add Plugin for document discount
			When Create catalog CancelReturnReasons objects
	* Load documents
		When Create document OpeningEntry objects
		And I execute 1C:Enterprise script at server
			| "Documents.OpeningEntry.FindByNumber(1).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(2).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(3).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(4).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(5).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(8).GetObject().Write(DocumentWriteMode.Posting);" |
			| "Documents.OpeningEntry.FindByNumber(9).GetObject().Write(DocumentWriteMode.Posting);" |
		And I close all client application windows
		


Scenario: _042901 check Opening entry movements by the Register  "R4010 Actual stocks"
	And I close all client application windows
	* Select Opening entry
		Given I open hyperlink "e1cib/list/Document.OpeningEntry"
		And I go to line in "List" table
			| 'Number'  |
			| '2' |
	* Check movements by the Register  "R4010 Actual stocks" 
		And I click "Registrations report" button
		And I select "R4010 Actual stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Opening entry 2 dated 07.09.2020 21:26:35' | ''            | ''                    | ''          | ''           | ''          |
			| 'Document registrations records'            | ''            | ''                    | ''          | ''           | ''          |
			| 'Register  "R4010 Actual stocks"'           | ''            | ''                    | ''          | ''           | ''          |
			| ''                                          | 'Record type' | 'Period'              | 'Resources' | 'Dimensions' | ''          |
			| ''                                          | ''            | ''                    | 'Quantity'  | 'Store'      | 'Item key'  |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 01'   | '38/Yellow' |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 01'   | '36/Red'    |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | 'L/Green'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | '38/Yellow' |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | '36/Red'    |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '200'       | 'Store 02'   | '36/18SD'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '300'       | 'Store 01'   | '36/18SD'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '400'       | 'Store 01'   | 'XS/Blue'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '400'       | 'Store 02'   | 'S/Yellow'  |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '500'       | 'Store 01'   | 'XS/Blue'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '500'       | 'Store 01'   | 'L/Green'   |
		And I close all client application windows

Scenario: _042902 check Opening entry movements by the Register  "R4011 Free stocks"
	And I close all client application windows
	* Select Opening entry
		Given I open hyperlink "e1cib/list/Document.OpeningEntry"
		And I go to line in "List" table
			| 'Number'  |
			| '2' |
	* Check movements by the Register  "R4011 Free stocks" 
		And I click "Registrations report" button
		And I select "R4011 Free stocks" exact value from "Register" drop-down list
		And I click "Generate report" button
		Then "ResultTable" spreadsheet document is equal
			| 'Opening entry 2 dated 07.09.2020 21:26:35' | ''            | ''                    | ''          | ''           | ''          |
			| 'Document registrations records'            | ''            | ''                    | ''          | ''           | ''          |
			| 'Register  "R4011 Free stocks"'             | ''            | ''                    | ''          | ''           | ''          |
			| ''                                          | 'Record type' | 'Period'              | 'Resources' | 'Dimensions' | ''          |
			| ''                                          | ''            | ''                    | 'Quantity'  | 'Store'      | 'Item key'  |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 01'   | '38/Yellow' |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 01'   | '36/Red'    |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | 'L/Green'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | '38/Yellow' |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '100'       | 'Store 02'   | '36/Red'    |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '200'       | 'Store 02'   | '36/18SD'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '300'       | 'Store 01'   | '36/18SD'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '400'       | 'Store 01'   | 'XS/Blue'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '400'       | 'Store 02'   | 'S/Yellow'  |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '500'       | 'Store 01'   | 'XS/Blue'   |
			| ''                                          | 'Receipt'     | '07.09.2020 21:26:35' | '500'       | 'Store 01'   | 'L/Green'   |
		And I close all client application windows