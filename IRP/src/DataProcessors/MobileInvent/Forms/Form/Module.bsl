&AtClient
Procedure SearchByBarcode(Command, Barcode = "")
	AddInfo = New Structure("MobileModule", ThisObject);
	DocumentsClient.SearchByBarcode(Barcode, DocumentObject, ThisObject, ThisObject, , AddInfo);
EndProcedure

&AtClient
Procedure NotificationProcessing(EventName, Parameter, Source)
	If EventName = "NewBarcode" And IsInputAvailable() Then
		SearchByBarcode(Undefined, Parameter);
	EndIf;
EndProcedure

&AtClient
Procedure InputBarcode(Command)
	Barcode = 0;
	ShowInputNumber(New NotifyDescription("AddBarcodeAfterEnd", ThisForm), Barcode, R().SuggestionToUser_2);
EndProcedure

&AtClient
Procedure AddBarcodeAfterEnd(Number, AdditionalParameters) Export
	If Not ValueIsFilled(Number) Then
		Return;
	EndIf;
	Barcode = Format(Number, "NG=");
	If DocumentObject.Ref.IsEmpty() Then
		DocumentIsSet = False;
		Message = FindAndSetDocument(Barcode, DocumentIsSet);
		If Not DocumentIsSet Then
			CommonFunctionsClientServer.ShowUsersMessage(Message);
		EndIf;
		Return;
	EndIf;
	SearchByBarcode(Undefined, Barcode);
EndProcedure

&AtClient
Procedure SearchByBarcodeEnd(Result, AdditionalParameters) Export

	If DocumentObject.Ref.IsEmpty() Then
		CommonFunctionsClientServer.ShowUsersMessage(R().InfoMessage_025, "DocumentRef");
	EndIf;
	
	For Each Row In AdditionalParameters.FoundedItems Do
		
		If Row.isService Then
			CommonFunctionsClientServer.ShowUsersMessage(R().InfoMessage_026);
			Return;
		EndIf;
		
		NewRow = DocumentObject.ItemList.Add();
		NewRow.Key = New UUID;
		FillPropertyValues(NewRow, Row);
		NewRow.PhysCount = Row.Quantity;
		
		If Row.UseSerialLotNumber And NewRow.SerialLotNumber.IsEmpty() Then
			BarcodeClient.CloseMobileScanner();
			
		EndIf;
	EndDo;
	
	If AdditionalParameters.FoundedItems.Count() Then
		If RuleEditQuantity Then
			BarcodeClient.CloseMobileScanner();
			StartEditQuantity(NewRow.GetID(), True);
		EndIf;
		Write();
	EndIf;

EndProcedure

&AtClient
Procedure ScanBarcodeEndMobile(Barcode, Result, Message, Parameters) Export
	If DocumentObject.Ref.IsEmpty() Then
		Message = FindAndSetDocument(Barcode, Result);

		If Result Then
			BarcodeClient.CloseMobileScanner();
		EndIf;
	Else
		ProcessBarcodeResult = Barcodeclient.ProcessBarcode(Barcode, Parameters);
		If ProcessBarcodeResult Then
			Message = R().S_018;
		Else
			Result = False;
			Message = StrTemplate(R().S_019, Barcode);
		EndIf;
	EndIf;
EndProcedure

&AtClient
Procedure ItemListSelection(Item, RowSelected, Field, StandardProcessing)
	StandardProcessing = False;
	StartEditQuantity(RowSelected);
EndProcedure

&AtClient
Procedure StartEditQuantity(Val RowSelected, AutoMode = False)
	Structure = New Structure();
	ItemListRow = DocumentObject.ItemList.FindByID(RowSelected);
	Structure.Insert("ItemRef", Undefined);
	Structure.Insert("ItemKey", ItemListRow.ItemKey);
	Structure.Insert("SerialLotNumber", ItemListRow.SerialLotNumber);
	Structure.Insert("Quantity", ItemListRow.PhysCount);
	Structure.Insert("RowID", RowSelected);
	Structure.Insert("AutoMode", AutoMode);
	NotifyOnClosing = New NotifyDescription("OnEditQuantityEnd", ThisObject);
	OpenForm("DataProcessor.MobileInvent.Form.RowForm", Structure, ThisObject, , , , NotifyOnClosing);
EndProcedure

&AtClient
Procedure OnEditQuantityEnd(Result, AddInfo) Export
	If Result = Undefined Then
		Return;
	EndIf;
	ItemListRow = DocumentObject.ItemList.FindByID(Result.RowID);
	ItemListRow.SerialLotNumber = Result.SerialLotNumber;
	ItemListRow.PhysCount = Result.Quantity;
	Write();
EndProcedure

&AtClient
Procedure CompleteLocation()
	NotifyDescription = New NotifyDescription("InputQuantityEnd", ThisObject);
	If Not SecondTryToInputQuantity Then
		Write();
		Text = R().QuestionToUser_018;
	Else
		Text = R().InfoMessage_009;
	EndIf;
	ShowInputNumber(NotifyDescription, "", Text);
EndProcedure

&AtClient
Procedure InputQuantityEnd(Quantity, Parameters) Export
	If Quantity <> DocumentObject.ItemList.Total("PhysCount") Then
		If Not SecondTryToInputQuantity Then
			SecondTryToInputQuantity = True;
			CompleteLocation();
		Else
			CommonFunctionsClientServer.ShowUsersMessage(R().InfoMessage_010);
			DocumentObject.ItemList.Clear();
			Write();
		EndIf;
	Else
		SecondTryToInputQuantity = False;
		CommonFunctionsClientServer.ShowUsersMessage(R().InfoMessage_011);
		SaveAndUpdateDocument();
	EndIf;
EndProcedure

&AtServer
Procedure SaveAndUpdateDocument()
	DocumentObject.Status = Catalogs.ObjectStatuses.Complete;
	Write();
	FillDocumentObject(Documents.PhysicalCountByLocation.EmptyRef());
EndProcedure

&AtServer
Function FindAndSetDocument(Number, Result, AddInfo = Undefined)

	Query = New Query();
	Query.Text =
	"SELECT
	|	PhysicalCountByLocation.Ref
	|FROM
	|	Document.PhysicalCountByLocation AS PhysicalCountByLocation
	|WHERE
	|	PhysicalCountByLocation.Number = &Number";

	Query.SetParameter("Number", Number(Number));

	QueryResult = Query.Execute();

	SelectionDetailRecords = QueryResult.Select();

	If SelectionDetailRecords.Next() Then
		FillDocumentObject(SelectionDetailRecords.Ref);
		Result = True;
		Return SelectionDetailRecords.Ref;
	Else
		Result = False;
		Return StrTemplate(R().Error_083, Number);
	EndIf;

EndFunction

&AtClient
Procedure DocumentRefOnChange(Item)
	FillDocumentObject(DocumentRef);
EndProcedure

&AtServer
Procedure FillDocumentObject(DocRef)
	DocumentRef = DocRef;
	If DocumentRef.IsEmpty() Then
		ValueToFormAttribute(Documents.PhysicalCountByLocation.CreateDocument(), "DocumentObject");
		LockFormDataForEdit();
	Else

		If DocRef.Status = Catalogs.ObjectStatuses.Complete Then
			CommonFunctionsClientServer.ShowUsersMessage(StrTemplate(R().InfoMessage_014, DocRef.Number));
			FillDocumentObject(Documents.PhysicalCountByLocation.EmptyRef());
			Return;
		ElsIf Not DocRef.ResponsibleUser.isEmpty() And Not DocRef.ResponsibleUser = SessionParameters.CurrentUser Then
			CommonFunctionsClientServer.ShowUsersMessage(StrTemplate(R().InfoMessage_012, DocRef.Number,
				DocRef.ResponsibleUser));
			FillDocumentObject(Documents.PhysicalCountByLocation.EmptyRef());
			Return;
		EndIf;

		DocObj = DocRef.GetObject();

		ValueToFormAttribute(DocObj, "DocumentObject");

		DocumentObject.ResponsibleUser = SessionParameters.CurrentUser;
		Write();
		Items.ItemListSerialLotNumber.Visible = DocRef.PhysicalInventory.UseSerialLot;
		CommonFunctionsClientServer.ShowUsersMessage(StrTemplate(R().InfoMessage_013, DocObj.Number));
	EndIf;

	RuleEditQuantity = DocumentObject.RuleEditQuantity;
EndProcedure
