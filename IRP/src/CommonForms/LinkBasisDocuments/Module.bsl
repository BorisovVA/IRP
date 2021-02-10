
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	ThisObject.MainFilter = Parameters.Filter;
	ThisObject.Mode = "LinkExists";
	For Each Row In Parameters.TablesInfo.ItemListRows Do
		NewRow = ThisObject.ItemListRows.Add();
		FillPropertyValues(NewRow, Row);
		NewRow.Picture = 3;
	EndDo;
		
	FillDocumentsTree(Parameters.SelectedRowInfo.SelectedRow, 
		Parameters.SelectedRowInfo.FilterBySelectedRow);
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	AttachIdleHandler("ExpandAllTrees", 1, True);
EndProcedure

&AtClient
Procedure ExpandAllTrees() Export
	RowIDInfoClient.ExpandTree(Items.DocumentsTree, ThisObject.DocumentsTree.GetItems());
	RowIDInfoClient.ExpandTree(Items.ResultsTree, ThisObject.ResultsTree.GetItems());
EndProcedure

&AtClient
Procedure ExistingRowsOnActivateRow(Item)
	SelectedRowInfo = RowIDInfoClient.GetSelectedRowInfo(Items.ItemListRows.CurrentData);
	FillDocumentsTree(SelectedRowInfo.SelectedRow, SelectedRowInfo.FilterBySelectedRow);
	RowIDInfoClient.ExpandTree(Items.DocumentsTree, ThisObject.DocumentsTree.GetItems());
EndProcedure

&AtClient
Procedure DocumentsTreeOnActivateRow(Item)
	SetButtonsEnabled();		
EndProcedure

&AtClient
Procedure SetButtonsEnabled()
	Items.Link.Enabled = IsCanLink().IsCan;
EndProcedure

&AtServer
Procedure FillDocumentsTree(SelectedRow, FilterBySelectedRow);
	FullFilter = New Structure();
	For Each KeyValue In ThisObject.MainFilter Do
		FullFilter.Insert(KeyValue.Key, KeyValue.Value);
	EndDo;
	
	If FilterBySelectedRow <> Undefined Then
		For Each KeyValue In FilterBySelectedRow Do
			FullFilter.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;
	
	BasisesTable = RowIDInfo.GetBasisesForSalesInvoice(FullFilter);
	
	TopLevelTable = BasisesTable.Copy(,"Basis");
	TopLevelTable.GroupBy("Basis");
	
	ThisObject.DocumentsTree.GetItems().Clear();
	
	For Each TopLevelRow In TopLevelTable Do
		TopLevelNewRow = ThisObject.DocumentsTree.GetItems().Add();
		TopLevelNewRow.Basis = TopLevelRow.Basis;
		TopLevelNewRow.Level = 1;
		TopLevelNewRow.PictureLevel1 = 0;
		
		SecondLevelRows = BasisesTable.FindRows(New Structure("Basis", TopLevelNewRow.Basis));
		
		For Each SecondLevelRow In SecondLevelRows Do
			SecondLevelNewRow = TopLevelNewRow.GetItems().Add();
			FillPropertyValues(SecondLevelNewRow, SecondLevelRow);
			
			SecondLevelNewRow.Level   = 2;
			SecondLevelNewRow.PictureLevel2 = 3;
			
			If SelectedRow <> Undefined Then
				UnitFactorFrom = Catalogs.Units.GetUnitFactor(SecondLevelRow.BasisUnit, SecondLevelRow.Quantity);
				UnitFactorTo = Catalogs.Units.GetUnitFactor(SelectedRow.Unit, SelectedRow.Quantity);
				SecondLevelNewRow.Quantity = ?(UnitFactorTo = 0, 0, SecondLevelRow.Quantity * UnitFactorFrom / UnitFactorTo);
				SecondLevelNewRow.Unit = SelectedRow.Unit;
			Else
				SecondLevelNewRow.Quantity = SecondLevelRow.Quantity;
				SecondLevelNewRow.Unit = SecondLevelRow.BasisUnit;
			EndIf;
		EndDo;
	EndDo;
EndProcedure

&AtClient
Procedure Ok(Command)
	ArrayOfRowIDInfo = New Array();
	For Each TopLevelRow In ThisObject.ResultsTree.GetItems() Do
		For Each SecondLevelRow In TopLevelRow.GetItems() Do
			NewRowIDInfo = New Structure();
			NewRowIDInfo.Insert("Key"          , SecondLevelRow.Key);
			NewRowIDInfo.Insert("RowID"        , SecondLevelRow.RowID);
			NewRowIDInfo.Insert("Quantity"     , SecondLevelRow.Quantity);
			NewRowIDInfo.Insert("Basis"        , SecondLevelRow.Basis);
			//NewRowIDInfo.Insert("CurrentStep"  , SecondLevelRow.CurrentStep);
			//NewRowIDInfo.Insert("NextStep"     , SecondLevelRow.NextStep);
			NewRowIDInfo.Insert("RowRef"       , SecondLevelRow.RowRef);
			ArrayOfRowIDInfo.Add(NewRowIDInfo);
		EndDo;
	EndDo;
	Close(ArrayOfRowIDInfo);
EndProcedure

&AtClient
Procedure Cancel(Command)
	Close(Undefined);	
EndProcedure

#Region Link

&AtClient
Procedure Link(Command)
	LinkInfo = IsCanLink();
	If Not LinkInfo.IsCan Then
		Return;
	EndIf;
	
	Filter = New Structure();
	Filter.Insert("Key"   , LinkInfo.Key);
	Filter.Insert("Level" , 1);
	TreeRowID = RowIDInfoClient.FindRowInTree(Filter, ThisObject.ResultsTree);
	If TreeRowID = Undefined Then
		TopLevelRow = ThisObject.ResultsTree.GetItems().Add();
	Else
		TopLevelRow = ThisObject.ResultsTree.FindByID(TreeRowID);
	EndIf;
	
	FillPropertyValues(TopLevelRow, LinkInfo);
	TopLevelRow.Level = 1;
	TopLevelRow.PictureLevel1 = 3;
	TopLevelRow.RowID = "";
	TopLevelRow.RowRef = Undefined;
	
	SecondLevelNewRow = TopLevelRow.GetItems().Add();		
	FillPropertyValues(SecondLevelNewRow, LinkInfo);
	SecondLevelNewRow.Level = 2;
	SecondLevelNewRow.PictureLevel2 = 0;
	
	SetButtonsEnabled();
	RowIDInfoClient.ExpandTree(Items.ResultsTree, ThisObject.ResultsTree.GetItems());
EndProcedure

&AtClient
Function IsCanLink()
	Result = New Structure("IsCan", False);
	
	ExistingRowsCurrentData = Items.ItemListRows.CurrentData;
	If ExistingRowsCurrentData = Undefined Then
		Return Result;
	EndIf;
	
	DocumentsTreeCurrentData = Items.DocumentsTree.CurrentData;
	If DocumentsTreeCurrentData = Undefined Then
		Return Result;
	EndIf;
	
	If DocumentsTreeCurrentData.Level = 2 Then
		Filter = New Structure();
		Filter.Insert("Key"   , ExistingRowsCurrentData.Key);
		Filter.Insert("RowID" , DocumentsTreeCurrentData.RowID);
		Filter.Insert("Basis" , DocumentsTreeCurrentData.Basis);
		If RowIDInfoClient.FindRowInTree(Filter, ThisObject.ResultsTree) <> Undefined Then
			Return Result;
		Else
			Result.IsCan = True;
			Result.Insert("Item"     , ExistingRowsCurrentData.Item);
			Result.Insert("ItemKey"  , ExistingRowsCurrentData.ItemKey);
			Result.Insert("Store"    , ExistingRowsCurrentData.Store);
			Result.Insert("Quantity" , ExistingRowsCurrentData.Quantity);
			Result.Insert("Unit"     , ExistingRowsCurrentData.Unit);
			Result.Insert("RowRef"   , DocumentsTreeCurrentData.RowRef);
	
			Result.Insert("Key"      , ExistingRowsCurrentData.Key);
			Result.Insert("Basis"    , DocumentsTreeCurrentData.Basis);
			Result.Insert("RowID"    , DocumentsTreeCurrentData.RowID);
		EndIf;
	EndIf;
	Return Result;
EndFunction

#EndRegion








