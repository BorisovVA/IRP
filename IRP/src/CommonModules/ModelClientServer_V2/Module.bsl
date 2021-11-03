
// MODEL
// 
// ОБЩИЙ МОДУЛЬ ДЛЯ ВСЕХ ДОКУМЕНТОВ - уровень бизнес логики
// никаких модификаций объектов тут делать нельзя, только запросы к БД и расчеты

#Region ENTRY_POINTS

Procedure PartnerEntryPoint(Parameters, ControllerModule) Export
	EntryPointName = "PartnerEntryPoint";
	InitCache(Parameters, EntryPointName);
	// При изменении Partner могут изменится:
	// LegalName
	// Agreement
	// ManagerSegment - НЕ РЕАЛИЗОВАНО
	
	Chain = GetChain();
	ControllerModule.PartnerEventChain(Parameters, Chain);
	ProceedChain(Parameters, ControllerModule, Chain);
	
	// проверяем что кэш был инициализирован из этой EntryPoint
	// и если это так и мы дошли до конца процедуры то значит что ChainComplete 
	If Parameters.EntryPointName = EntryPointName Then
		ControllerModule.OnChainComplete(Parameters);
	EndIf;
EndProcedure

Procedure LegalNameEntryPoint(Parameters, ControllerModule) Export
	EntryPointName = "LegalNameEntryPoint";
	InitCache(Parameters, EntryPointName);
	// При изменении LegalName никакие другие реквизиты не меняются
	Chain = GetChain();
	ControllerModule.LegalNameEventChain(Parameters, Chain);
	ProceedChain(Parameters, ControllerModule, Chain);
	
	// проверяем что кэш был инициализирован из этой EntryPoint
	// и если это так и мы дошли до конца процедуры то значит что ChainComplete 
	If Parameters.EntryPointName = EntryPointName Then
		ControllerModule.OnChainComplete(Parameters);
	EndIf;
EndProcedure

Procedure AgreementEntryPoint(Parameters, ControllerModule) Export
	EntryPointName = "AgreementEntryPoint";
	InitCache(Parameters, EntryPointName);
	
	// При изменении Agreement могут изменится:
	// Company
	// PriceType - НЕ РЕАЛИЗОВАНО
	// Currency - НЕ РЕАЛИЗОВАНО
	// PriceIncludeTax - НЕ РЕАЛИЗОВАНО
	// Store - НЕ РЕАЛИЗОВАНО
	// DeliveryDate - НЕ РЕАЛИЗОВАНО
	// PaymentTerm - НЕ РЕАЛИЗОВАНО
	// TaxRates - НЕ РЕАЛИЗОВАНО
	
	Chain = GetChain();
	ControllerModule.AgreementEventChain(Parameters, Chain);
	ProceedChain(Parameters, ControllerModule, Chain);
	
	// проверяем что кэш был инициализирован из этой EntryPoint
	// и если это так и мы дошли до конца процедуры то значит что ChainComplete 
	If Parameters.EntryPointName = EntryPointName Then
		ControllerModule.OnChainComplete(Parameters);
	EndIf;
EndProcedure

#EndRegion

Function GetChain()
	Chain = New Structure();
	LegalNameInfo(Chain);
	AgreementInfo(Chain);
	CompanyInfo(Chain);
	PriceTypeInfo(Chain);
	Return Chain;
EndFunction

Procedure ProceedChain(Parameters, ControllerModule, Chain)
	If Chain.LegalName.NeedChange Then
		Results = New Array();
		For Each Param In Chain.LegalName.Parameters Do
			Results.Add(LegalNameChange(Param));
		EndDo;
		ControllerModule.SetLegalName(Parameters, Results);
	EndIf;
	
	If Chain.Agreement.NeedChange Then
		Results = New Array();
		For Each Param In Chain.Agreement.Parameters Do
			Results.Add(AgreementChange(Param));
		EndDo;
		ControllerModule.SetAgreement(Parameters, Results);
	EndIf;
	
	If Chain.Company.NeedChange Then
		Results = New Array();
		For Each Param In Chain.Company.Parameters Do
			Results.Add(CompanyChange(Param));
		EndDo;
		ControllerModule.SetCompany(Parameters, Results);
	EndIf;
	
	If Chain.PriceType.NeedChange Then
		Results = New Array();
		For Each Param In Chain.PriceType.Parameters Do
			Results.Add(PriceTypeChange(Param));
		EndDo;
		ControllerModule.SetPriceType(Parameters, Results);
	EndIf;
EndProcedure

#Region LEGAL_NAME

Procedure LegalNameInfo(Chain)
	LegalName = New Structure();
	LegalName.Insert("NeedChange", False);
	LegalName.Insert("Parameters", New Array());
	Chain.Insert("LegalName", LegalName);
EndProcedure

Function LegalNameParameters() Export
	Parameters = New Structure();
	Parameters.Insert("Key");
	Parameters.Insert("Partner");
	Parameters.Insert("LegalName");
	Return Parameters;
EndFunction

Function LegalNameChange(Parameters)
	Result = New Structure();
	NewLegalName = DocumentsServer.GetLegalNameByPartner(Parameters.Partner, Parameters.LegalName);
	Result.Insert("Value"      , NewLegalName);
	Result.Insert("Parameters" , Parameters);
	Return Result;
EndFunction

#EndRegion

#Region AGREEMENT

Procedure AgreementInfo(Chain)
	Agreement = New Structure();
	Agreement.Insert("NeedChange", False);
	Agreement.Insert("Parameters", New Array());
	Chain.Insert("Agreement", Agreement);
EndProcedure

Function AgreementParameters() Export
	Parameters = New Structure();
	Parameters.Insert("Key");
	Parameters.Insert("Partner");
	Parameters.Insert("Agreement");
	Parameters.Insert("Date");
	Parameters.Insert("AgreementType");
	Return Parameters;
EndFunction

Function AgreementChange(Parameters)
	Result = New Structure();
	AgreementParameters = New Structure();
	AgreementParameters.Insert("Partner"       , Parameters.Partner);
	AgreementParameters.Insert("Agreement"     , Parameters.Agreement);
	AgreementParameters.Insert("CurrentDate"   , Parameters.Date);
	AgreementParameters.Insert("AgreementType" , Parameters.AgreementType);
	NewAgreement = DocumentsServer.GetAgreementByPartner(AgreementParameters);
	Result.Insert("Value"      , NewAgreement);
	Result.Insert("Parameters" , Parameters);
	Return Result;
EndFunction

#EndRegion

#Region COMPANY

Procedure CompanyInfo(Chain)
	Company = New Structure();
	Company.Insert("NeedChange", False);
	Company.Insert("Parameters", New Array());
	Chain.Insert("Company", Company);
EndProcedure

Function CompanyParameters() Export
	Parameters = New Structure();
	Parameters.Insert("Key");
	Parameters.Insert("Agreement");
	Return Parameters;
EndFunction

Function CompanyChange(Parameters)
	Result = New Structure();
	NewCompany = CatAgreementsServer.GetAgreementInfo(Parameters.Agreement).Company;
	Result.Insert("Value"      , NewCompany);
	Result.Insert("Parameters" , Parameters);
	Return Result;
EndFunction

#EndRegion

#Region PRICE_TYPE

Procedure PriceTypeInfo(Chain)
	PriceType = New Structure();
	PriceType.Insert("NeedChange", False);
	PriceType.Insert("Parameters", New Array());
	Chain.Insert("PriceType", PriceType);
EndProcedure

Function PriceTypeParameters() Export
	Parameters = New Structure();
	Parameters.Insert("Key");
	Parameters.Insert("Agreement");
	Return Parameters;
EndFunction

Function PriceTypeChange(Parameters)
	Result = New Structure();
	NewPriceType = CatAgreementsServer.GetAgreementInfo(Parameters.Agreement).PriceType;
	Result.Insert("Value"      , NewPriceType);
	Result.Insert("Parameters" , Parameters);
	Return Result;
EndFunction

#EndRegion

// все измененные данные хранятся в кэше, для возможности откатить изменения, если пользователь откажется от изменений
// кэш инициализируется только один раз внезависимости от того какой именно EntryPoint использован
Procedure InitCache(Parameters, EntryPointName)
	If Not Parameters.Property("Cache") Then
		Parameters.Insert("Cache", New Structure());
		Parameters.Insert("EntryPointName", EntryPointName);
	EndIf;
EndProcedure
