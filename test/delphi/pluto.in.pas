unit FindTH;

interface

uses
  Classes, windows, Dialogs, ComCtrls, CompEx, SysUtils, YTools, YTypes,
  clock, plutoconst, StdCtrls, Masks, Forms, XReg;

const
  RegMoleVersion = '1.1';

type
  TFindThreadProgress = (fpNone, fpEvery512th, fpEach);

  TRegFindThread = class(TThread)
  private
    SearchText: string;
    SearchFor: TSearchOptions;
    Progress: TFindThreadProgress;
    FindNodeText: string;
    TimeElapsed: Double;
    syncIcon: Integer;
    syncStatusText: string;
    CurrentPath: string;
    KeysScanned: Integer;
    Mask: TMask;
    dwordVal: DWORD;
    SearchForValues: Boolean;

    procedure Find;

    //Synchronizers
    procedure Start;
    procedure Add;
    procedure UpdateStatus;
    procedure Finish;
  protected
    procedure Execute; override;
  public
    SpecialPath: string;
    FindNode: TTreeNode;
    ListTV: TTreeView;
    ObjectsFound, KeysFound, ValuesFound, DataFound: Integer;
    Ranges: TRanges;
    destructor Destroy; override;
    constructor CreateIt(PriorityLevel: TThreadPriority; s: string;
      SearchFor: TSearchOptions; Progress: TFindThreadProgress);
  end;

implementation

uses
  ValuesU, StrUtils;

{ TRegFindThread }

procedure TRegFindThread.Add;
var
  Node: TTreeNode;
begin
  with ListTV do begin
    //Items.BeginUpdate;
    Node := TTreeNode.Create(Items);
    SetTNImage(Node, syncIcon);
    Items.AddNode(Node, FindNode, Copy(CurrentPath, 1, 255), nil,
      naAddChildFirst);
    if not FindNode.Expanded and (FindNode.Count = 1) then //First Node
      FindNode.Expand(False);
    //Items.EndUpdate;
  end;
end;

constructor TRegFindThread.CreateIt(PriorityLevel: TThreadPriority; s: string;
  SearchFor: TSearchOptions; Progress: TFindThreadProgress);
begin
  inherited Create(True);      // Create thread suspended
  Priority := PriorityLevel; // Set Priority Level
  FreeOnTerminate := True; // Thread Free Itself when terminated

  SearchText := s;
  Ranges := nil;
  Self.SearchFor := SearchFor;
  Self.Progress := Progress;
end;

destructor TRegFindThread.Destroy;
begin
  if Assigned(FindNode) then
    FindNode.Data := nil;
  inherited;
end;

procedure TRegFindThread.Execute;
begin
  Synchronize(Start);
  Find;
  Synchronize(Finish);
end;

procedure TRegFindThread.Find;
var
  SpecialKey: HKEY;

  procedure Add(const Path: string; const Icon: Integer);
  var
    zCurrentPath: string;
  begin
    zCurrentPath := CurrentPath;

    CurrentPath := Path;
    syncIcon := Icon;
    Synchronize(Self.Add);

    CurrentPath := zCurrentPath;
  end;

  procedure AddValueName(const ValueName: string; Typ: TRegDataType);
  begin
    Add(CurrentPath + '\\' + ValueName, IconOfDataType(Typ));
  end;

  procedure AddValueData(const ValueName: string; Context: TRegContext);
  begin
    Add(CurrentPath + '\\' + ValueName + ' = ' + DataPreviewOfContext(Context),
      IconOfDataType(Context.Typ));
  end;

  function FoundInStr(const Data: string): Boolean;
  begin
    Result := False;
    if SearchText = '' then
      Exit;

    if (Data = '') and not (sfWildCards in SearchFor) then
      Exit;

    if sfWildCards in SearchFor then begin
      if Assigned(Mask) then
        Result := Mask.Matches(Data);
    end else begin
      {if not (sfFileNames in SearchFor) then begin
        if TextBegin(SearchText, UntilChar(Data, '~')) and FileExists(Data) then
          Result :=  SameFileName(SearchText, GetFileNew(Data));
        Exit;
      end; }

      if [sfParts, sfIgnoreCase] <= SearchFor then
        if SfUseLocales in SearchFor then
          Result := 0<PosEx(SearchText, AnsiLowerCase(Data))
        else
          Result := 0<PosExText(SearchText, Data)
      else if sfParts in SearchFor then
        Result := 0<PosEx(SearchText, Data)
      else if sfIgnoreCase in SearchFor then
        if SfUseLocales in SearchFor then
          Result := (AnsiLowerCase(Data) = SearchText)
        else
          Result := SameText(Data, SearchText)
      else
        Result := (SearchText = Data);
    end;
  end;

  function FoundInByteA(const Data: TByteA): Boolean;
  begin
    Result := FoundInStr(StrOfByteA(Data));
  end;

  procedure ScanValues(Key: HKEY; Info: TRegKeyInfo);
  var
    i: Integer;
    MaxLen, NameLen, Len, Typ: Cardinal;
    Buffer: PByte;
    ValueName: PChar;

    procedure ScanValue(const ValueName: string; const Typ: TRegDataType;
      const Data: string);
    begin
      if (sfSpecialTypes in SearchFor) and not InRanges(Ranges, Typ) then
        Exit;

      case Typ of
        rdString, rdExpandString: if sfString in SearchFor then begin
          if FoundInStr(Data) then begin
            Inc(DataFound);
            AddValueData(ValueName,
              RegContext(Typ, TByteA(Copy(Data, 1, Length(Data)-1))));
          end;
        end;

        rdCardinal, rdCardBigEndian: if sfDWord in SearchFor then begin
          if (Length(Data) >= SizeOf(Cardinal)) and
          (dwordVal = PCardinal(Copy(Data, 1, SizeOf(Cardinal)))^) then begin
            Inc(DataFound);
            AddValueData(ValueName,
              RegContext(Typ, ByteAOfStr(Data)));
          end;
        end;

      else
        if sfOtherTypes in SearchFor then begin
          if FoundInStr(Data) then begin
            Inc(DataFound);
            AddValueData(ValueName,
              RegContext(Typ, ByteAOfStr(Data)));
          end;
        end;
      end;
    end;

  begin
    MaxLen := Info.MaxValueLen + 1; //Include Nullbyte

    Buffer := nil;
    if sfValueData in SearchFor then
      GetMem(Buffer, Info.MaxDataLen);

    GetMem(ValueName, MaxLen);
    for i := 0 to Info.NumValues-1 do begin
      NameLen := MaxLen;
      Len := Info.MaxDataLen;
      if not Success(RegEnumValue(Key, i, ValueName, NameLen, nil, @Typ,
       Buffer, @Len)) then
        Continue;

      if sfValueNames in SearchFor then
        if FoundInStr(ValueName) then begin
          Inc(ValuesFound);
          AddValueName(ValueName, Typ);
        end;

      if sfValueData in SearchFor then
        ScanValue(ValueName, Typ, string(Copy(TByteA(Buffer), 0, Len)));
    end;

    FreeMem(ValueName, MaxLen);
    if sfValueData in SearchFor then
      FreeMem(Buffer, Info.MaxDataLen);
  end;

  procedure ScanKey(Key: HKEY; const KeyName: string = '');
  var
    p: PChar;
    i, z: Integer;
    l, Len: DWORD;
    NewKey: HKEY;
    Info: TRegKeyInfo;
  begin
    if Terminated then Exit;

    Inc(KeysScanned);
    if Progress <> fpNone then
      if (Progress = fpEach) or
       ((Progress = fpEvery512th) and ((KeysScanned and $1FF) = 0)) then begin
        syncStatusText := '(' + IntToStr(KeysScanned) + ' k) ' + CurrentPath;
        Synchronize(UpdateStatus);
      end;

    with Info do
      if not Success(RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys,
       @MaxSubKeyLen, nil, @NumValues, @MaxValueLen, @MaxDataLen,
       nil, nil)) then
        Exit;

    if (Info.NumValues > 0) and SearchForValues then
      ScanValues(Key, Info);

    if Info.NumSubKeys <= 0 then
      Exit;

    Len := Info.MaxSubKeyLen + 1;
    GetMem(p, Len);

    for i := 0 to Info.NumSubKeys-1 do begin
      l := Len;
      RegEnumKeyEx(Key, i, p, l, nil, nil, nil, nil);
      if sfKeys in SearchFor then
        if FoundInStr(p) then begin
          Inc(KeysFound);
          Add(CurrentPath + '\' + p, iconKeyMiddle);
        end;

      if Success(RegOpenKey(Key, p, NewKey)) then begin
        z := Length(CurrentPath);
        CurrentPath := CurrentPath + '\' + p;

        try
          ScanKey(NewKey, p);
        finally
          RegCloseKey(NewKey);
        end;

        SetLength(CurrentPath, z);
      end;

      if Terminated then Break;
    end;

    FreeMem(p, Len);
  end;

begin
  with TClock.Create do begin
    FindNode.Text := FindNodeText + ': ';

    try
      if sfHKU in SearchFor then begin
        CurrentPath := 'HKU';
        ScanKey(HKEY_USERS);
      end;
      if sfHKLM in SearchFor then begin
        CurrentPath := 'HKLM';
        ScanKey(HKEY_LOCAL_MACHINE);
      end;
      if sfHKDD in SearchFor then begin
        CurrentPath := 'HKDD';
        ScanKey(HKEY_DYN_DATA);
      end;

      if SpecialPath <> '' then begin
        if Success(RegOpenKey(HKEYOfStr(ExRegRoot(SpecialPath)),
         PChar(ExRegKey(SpecialPath)), SpecialKey)) then begin
          CurrentPath := LWPSolve(SpecialPath);
          ScanKey(SpecialKey);
          RegCloseKey(SpecialKey);
        end else
          ShowMessage('Could not open' + EOL +
                      Quote(SpecialPath));
      end;
    except
      syncStatusText := '(' + IntToStr(KeysScanned) + ' k) ' + CurrentPath +
        'Error --> Terminated.';
      Synchronize(UpdateStatus);
      Sleep(1000);
    end;

    TimeElapsed := SecondsPassed;
  Free; end;
end;

function StrOfSearchOptions(const Options: TSearchOptions): string;

  procedure Add(const s: string);
  begin
    Result := Result + s;
  end;

  procedure AddOption(const Option: string; const Flag: TSearchVar;
    const Optional: Boolean = False);
  begin
    if Flag in Options then
      Add(Option)
    else
      if not Optional then
        Add('^' + Option);
  end;

begin
  Result := '';

  Add('[');
  AddOption('H', sfAsHex, True);
  AddOption('W ', sfWildcards, True);

  AddOption('C', sfIgnoreCase);
  AddOption('L', sfUseLocales);
  AddOption('P ', sfParts);

  AddOption('K', sfKeys);
  AddOption('N', sfValueNames);
  AddOption('D ', sfValueData);

  AddOption('S', sfString);
  AddOption('D', sfDWORD);
  AddOption('O', sfOtherTypes);
  AddOption('?', sfSpecialTypes);

  Add('] [');

  if [sfHKU, sfHKLM, sfHKDD] <= Options then
    Add('ALL')
  else begin
    AddOption('HKU ', sfHKU, True);
    AddOption('HKLM ', sfHKLM, True);
    AddOption('HKDD ', sfHKDD, True);
    Result := TrimRight(Result);
  end;

  Add(']');
end;

procedure TRegFindThread.Start;
begin
  Mask := nil;
  KeysFound := 0;
  ValuesFound := 0;
  DataFound := 0;
  KeysScanned := 0;

  //Prepare for options
  if sfAsHex in SearchFor then begin
    SearchText := string(ByteAOfHex(SearchText));
    SearchFor := SearchFor - [sfDWord, sfIgnoreCase];
  end else begin
    if SfUseLocales in SearchFor then
      SearchText := AnsiLowerCase(SearchText);

    dwordVal := 0;
    if sfDWord in SearchFor then
      if IsValidInteger(SearchText) then
        dwordVal := StrToInt(SearchText)
      else
        Exclude(SearchFor, sfDWord);

    if sfWildCards in SearchFor then
      try
        Mask := TMask.Create(SearchText);
      except
        Mask.Free;
        Mask := nil;
      end;
  end;

  SearchForValues := (sfValueNames in SearchFor)
                  or (sfValueData in SearchFor);

  FindNodeText := 'Find ' + Quote(FriendlyStr(SearchText)) + ' ' +
    StrOfSearchOptions(SearchFor);

  with ListTV.Items do begin
    BeginUpdate;
    FindNode := AddChildObject(nil, FindNodeText + '...', nil);
    FindNode.Data := Self;
    SetTNImage(FindNode, iconHostReg);
    EndUpdate;
  end;
end;

procedure TRegFindThread.UpdateStatus;
begin
  FindNode.Text := FindNodeText + ' ' + syncStatusText;
end;

procedure TRegFindThread.Finish;
var
  Found: string;
begin
  ObjectsFound := KeysFound + ValuesFound + DataFound;

  Found := StrNumerus(ObjectsFound, 'object', 'objects', 'No');
  if ObjectsFound < 2 then
    Found := Found + ' found.'
  else begin
    Found := Found + ' found: ';
    if KeysFound > 0 then
      Found := Found + StrNumerus(KeysFound, 'KeyName, ', 'KeyNames, ', 'No');
    if ValuesFound > 0 then
      Found := Found + StrNumerus(ValuesFound, 'ValueName, ', 'ValueNames, ',
        'No');
    if DataFound > 0 then
      Found := Found + StrNumerus(DataFound, 'Data', 'Datas', 'No');

    if RightStr(Found, 2) = ', ' then
      Delete(Found, Length(Found) - 1, 2);
  end;

  FindNode.Text := FindNodeText + Format(' OK (%0.1f s) %s',
    [TimeElapsed, Found]);
end;

end.
unit FindWinU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Clipbrd, NewPanels, plutoconst, FindTH, YTools,
  PrefTools, Menus, XReg, RangeEdit;

type
  TFindWin = class(TForm)
    ListTV: TTreeView;
    FindP: TPanel;
    FindE: TEdit;
    ColorPanel1: TColorPanel;
    ResultsPopup: TPopupMenu;
    Copy1: TMenuItem;
    ColorPanel2: TColorPanel;
    FindPrefP: TPanel;
    CommonGB: TGroupBox;
    Label4: TLabel;
    SfWildCardsCB: TCheckBox;
    SfPartsCB: TCheckBox;
    SfIgnoreCaseCB: TCheckBox;
    SfAsHexCB: TCheckBox;
    SfAsDWord: TCheckBox;
    SfUseLocalesCB: TCheckBox;
    FindGB: TGroupBox;
    SfHKUCB: TCheckBox;
    SfHKLMCB: TCheckBox;
    SfHKDDCB: TCheckBox;
    SfRootKeyRB: TRadioButton;
    SfCurKeyRB: TRadioButton;
    SfCLSIDCB: TCheckBox;
    SfInterfaceCB: TCheckBox;
    SfKeysCb: TCheckBox;
    SfValuesCB: TCheckBox;
    SfDataCB: TCheckBox;
    SfStringCB: TCheckBox;
    SfOtherCB: TCheckBox;
    SfDWordCB: TCheckBox;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    ThreadPriorityComB: TComboBox;
    ProgressRG: TRadioGroup;
    Panel5: TPanel;
    BorderPanel1: TBorderPanel;
    MoleLogoI: TImage;
    TypeRangeE: TRangeEdit;
    SfTypesCB: TCheckBox;
    Panel1: TPanel;
    TransparentCB: TPrefCheckBox;
    StayOnTopCB: TPrefCheckBox;
    FindB: TButton;
    FindPrefB: TButton;
    procedure FindBClick(Sender: TObject);
    procedure ListTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FindEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActivateIt(Sender: TObject);
    procedure DeActivateIt(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SfWildCardsCBClick(Sender: TObject);
    procedure StayOnTopCBClick(Sender: TObject);
    procedure SfRootKeysUpdate(Sender: TObject);
    procedure FindPrefBClick(Sender: TObject);

    procedure CloseFindPrefP;
    procedure OpenFindPrefP;
    procedure FindEChange(Sender: TObject);
    procedure SfDataCBClick(Sender: TObject);
    procedure ListTVDblClick(Sender: TObject);
    procedure SfAsHexCBClick(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SfIgnoreCaseCBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SfTypesCBClick(Sender: TObject);
  end;

const
  fpbOpen = 0;
  fpbCloseCaption = 'Params &<<';

  fpbClosed = 1;
  fpbOpenCaption = 'Params &>>';

var
  FindWin: TFindWin;

implementation

uses plutomain, PrefU, ValuesU;

{$R *.DFM}

procedure TFindWin.FindBClick(Sender: TObject);
var
  SearchFor: TSearchOptions;
  FindThread: TRegFindThread;

  procedure AddOption(CheckBox: TCustomCheckBox; Flag: TSearchVar);
  begin
    with CheckBox as TCheckBox do
      if Enabled and Checked then
        Include(SearchFor, Flag);
  end;

begin
  SearchFor := [];

  AddOption(SfKeysCB, sfKeys);

  AddOption(SfValuesCB, sfValueNames);
  AddOption(SfDataCB, sfValueData);

  AddOption(SfStringCB, sfString);
  AddOption(SfDWordCB, sfDWord);
  AddOption(SfOtherCB, sfOtherTypes);

  if SfRootKeyRB.Checked then begin
    AddOption(SfHKUCB, sfHKU);
    AddOption(SfHKLMCB, sfHKLM);
    AddOption(SfHKDDCB, sfHKDD);
  end;

  AddOption(SfAsHexCB, sfAsHex);
  AddOption(SfWildCardsCB, sfWildCards);
  AddOption(SfPartsCB, sfParts);
  AddOption(SfIgnoreCaseCB, sfIgnoreCase);
  AddOption(SfUseLocalesCB, sfUseLocales);

  {AddOption(SfCLSIDCB, sfCLSID);
  AddOption(SfInterfaceCB, sfInterface);}

  if SfTypesCB.Checked and not TypeRangeE.RangeMaximal then
    Include(SearchFor, sfSpecialTypes);

  FindThread := TRegFindThread.CreateIt(
    TThreadPriority(ThreadPriorityComB.ItemIndex), FindE.Text, SearchFor,
      TFindThreadProgress(ProgressRG.ItemIndex));

  FindThread.ListTV := ListTV;

  if sfSpecialTypes in SearchFor then
    FindThread.Ranges := TypeRangeE.Value;

  if SfCurKeyRB.Checked then
    FindThread.SpecialPath :=
      LWPSolve(StrOfRegPath(CurKey(uhNonSystemShortcuts)));

  FindThread.Resume;
  CloseFindPrefP;
end;

procedure TFindWin.ListTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node: TTreeNode;

  procedure TerminateFindThread;
  var
    FindThread: TRegFindThread;
  begin
    if (Node.Level = 0) then begin
      FindThread := TRegFindThread(Node.Data);
      if not Assigned(FindThread) then
        Node.Delete
      else
        try
          FindThread.Terminate;
        except
          Node.Text := 'Error: couldn''t terminate thread!';
        end;
    end else
      Node.Delete;
  end;

begin
  Node := ListTV.Selected;
  if not Assigned(Node) then
    Exit;

  case Key of
    VK_F12: if Assigned(Node.Parent) then
      Node.Parent.AlphaSort;

    VK_RETURN: ListTVDblClick(Sender);

    VK_DELETE: TerminateFindThread;
  end;
end;

procedure TFindWin.FindEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    FindBClick(Sender);

  if Key = VK_UP then begin
    CloseFindPrefP;
    Key := 0;
  end else if Key = VK_Down then begin
    OpenFindPrefP;
    Key := 0;
  end;
end;

procedure TFindWin.ActivateIt(Sender: TObject);
begin
  ActivateThis(Sender);
end;

procedure TFindWin.DeActivateIt(Sender: TObject);
begin
  DeActivateThis(Sender);
end;

procedure TFindWin.FormDeactivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    DeActivateThis(ActiveControl);

  AlphaBlend := TransparentCB.Checked;
end;

procedure TFindWin.FormActivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    ActivateThis(ActiveControl);

  AlphaBlend := False;
end;

procedure TFindWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
  MainWin.FormKeyDown(Sender, Key, Shift);
end;

procedure TFindWin.SfWildCardsCBClick(Sender: TObject);
begin
  SfPartsCB.Enabled := not SfWildcardsCB.Checked;
  SfIgnoreCaseCB.Enabled := not SfWildcardsCB.Checked;
  SfUseLocalesCB.Enabled := SfIgnoreCaseCB.Checked and not SfWildcardsCB.Checked;
end;

procedure TFindWin.StayOnTopCBClick(Sender: TObject);
begin
  if StayOnTopCB.Checked then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TFindWin.SfRootKeysUpdate(Sender: TObject);
begin
  with SfRootKeyRB do begin
    SfHKLMCB.Enabled := Checked;
    SfHKUCB.Enabled := Checked;
    SfHKDDCB.Enabled := Checked;
  end;
end;

procedure TFindWin.FindPrefBClick(Sender: TObject);
begin
  case FindPrefB.Tag of
    fpbOpen:
      CloseFindPrefP;
    fpbClosed:
      OpenFindPrefP;
  else
    ShowMessage('Fehler: FindPrefB hat unbekanntes Tag');
  end;
end;

procedure TFindWin.CloseFindPrefP;
begin
  with FindPrefB do begin
    Tag := fpbClosed;
    Caption := fpbOpenCaption;
  end;
  FindPrefP.Visible := False;
  ListTV.Repaint;
end;

procedure TFindWin.OpenFindPrefP;
begin
  with FindPrefB do begin
    Tag := fpbOpen;
    Caption := fpbCloseCaption;
  end;
  FindPrefP.Visible := True;
  ListTV.Repaint;
end;

procedure TFindWin.FindEChange(Sender: TObject);
begin
  if IsValidInteger(FindE.Text) then
    SfDWORDCB.Caption := 'D&WORD OK'
  else
    SfDWORDCB.Caption := 'D&WORD ??';

  SfAsHexCB.Enabled := (FindE.Text <> '')
    and not CharIn(FindE.Text, AllChars - HexadecimalChars - [' ']);
  SfAsDWord.Enabled := SfAsHexCB.Enabled and (Length(TrimAll(FindE.Text)) < 8);
end;

procedure TFindWin.SfDataCBClick(Sender: TObject);
begin
  with SfDataCB do begin
    SfStringCB.Enabled := Checked;
    SfDWordCB.Enabled := Checked;
    SfOtherCB.Enabled := Checked;
  end;
end;

procedure TFindWin.ListTVDblClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := ListTV.Selected;
  if not Assigned(Node) or (Node.Level = 0) then
    Exit;

  MainWin.GotoKey(UntilLastChar(Node.Text, '='))
end;

procedure TFindWin.SfAsHexCBClick(Sender: TObject);
begin
  with SfAsHexCB do begin
    SfIgnoreCaseCB.Enabled := Checked;
    SfWildCardsCB.Enabled := Checked;
  end;
end;

procedure TFindWin.Copy1Click(Sender: TObject);
var
  Node: TTreeNode;
begin
  Node := ListTV.Selected;
  if not Assigned(Node) then
    Exit;

  Clipboard.AsText := Node.Text;
end;

procedure TFindWin.SfIgnoreCaseCBClick(Sender: TObject);
begin
  SfUseLocalesCB.Enabled := SfIgnoreCaseCB.Checked;
end;

procedure TFindWin.FormCreate(Sender: TObject);
var
  ImageFile: string;
begin
  Caption := 'Pluto.RegMole ' + RegMoleVersion +
    ' - The fastest registry search engine for Win9x';

  ImageFile := PlutoDir + 'mole.bmp';
  if FileExists(ImageFile) then
    MoleLogoI.Picture.LoadFromFile(ImageFile);

  Width := Screen.WorkAreaWidth - 100;

  CloseFindPrefP;
end;

procedure TFindWin.FormShow(Sender: TObject);
begin
  Top := Screen.WorkAreaHeight - 450;
  Height := Screen.WorkAreaHeight - Top;
  Left := (Screen.WorkAreaWidth - Width) div 2;
end;

procedure TFindWin.SfTypesCBClick(Sender: TObject);
begin
  TypeRangeE.Enabled := SfTypesCB.Checked;
end;

end.
unit Plutoconst;

interface

uses ComCtrls, Classes, XReg, UniKey, YTools;

var
  Started: Boolean = False;
  MurphyMode: Boolean = False;
  PlutoKey: TUniKey;

const
  Version = '1.6 -nium Alpha';
  Overnight = True;
  Codename = 'Phoenix';
  //Generation.Version-Release-Beta
  //                   GG.VVRRBB
  VersionNum: Double =  1.600000;
  //Must be Double!

const
  iconKey =         0;

  iconFirstHKEY =   2;
  iconHKLM =        iconFirstHKEY;
  iconHKU =         iconFirstHKEY + 2;

  iconFirstShortcut = iconFirstHKEY + 4;
  iconHKCC =        iconFirstShortcut;
  iconHKCU =        iconFirstShortcut +  2;
  iconHKCR =        iconFirstShortcut +  4;
  iconHKDD =        iconFirstShortcut +  6;
  iconHKPD =        iconFirstShortcut +  8;
  iconHKWM =        iconFirstShortcut + 10;
  iconHKWU =        iconFirstShortcut + 12;
  iconShortcut =    iconFirstShortcut + 14;
  nHKeyIcons =      16;

  iconFirstType =   iconFirstShortcut + nHKeyIcons;
  iconNone =        iconFirstType +  0;
  iconString =      iconFirstType +  1;
  iconExpandString =iconFirstType +  2;
  iconBinary =      iconFirstType +  3;
  iconCardinal =    iconFirstType +  4;
  iconCardBigEndian=iconFirstType +  5;
  iconLink =        iconFirstType +  6;
  iconMultiString = iconFirstType +  7;
  iconResList =     iconFirstType +  8;
  iconFullResDesc = iconFirstType +  9;
  iconResReqList =  iconFirstType + 10;
  iconUnknownType = iconFirstType + 11;
  nTypeIcons =      12;

  iconFirstValue = iconFirstType + nTypeIcons;
  iconValueElse = iconFirstValue;
  iconValueEdit = iconFirstValue + 1;
  iconValueEditBinary = iconFirstValue + 2;
  iconValueZeromize = iconFirstValue + 3;
  iconValueDublicate = iconFirstValue + 4;
  iconMainValue = iconFirstValue + 5;
  iconTakeAsMainValue = iconFirstValue + 6;
  nValueIcons =     7;

  iconFirstKey =    iconFirstValue + nValueIcons;
  iconKeyInfos =    iconFirstKey;
  iconSubKey =   iconFirstKey + 1;
  iconKeyDublicate = iconFirstKey + 2;
  iconKeyFind = iconFirstKey + 3;
  iconKeyTrace = iconFirstKey + 4;
  nKeyIcons = 5;

  iconFirstContextMenues = iconFirstKey + nKeyIcons;
  iconRename = iconFirstContextMenues;
  iconDelete = iconFirstContextMenues + 1;
  nContextMenuesIcon = 2;

  iconFirstIni =    iconFirstContextMenues + nContextMenuesIcon;
  iconIniSection =  iconFirstIni;
  nIniIcons =       1;

  iconFirstHost =   iconFirstIni + nIniIcons;
  iconHostReg =     iconFirstHost;
  iconHostIni =     iconFirstHost + 1;
  iconHostUni =     iconFirstHost + 2;
  iconHostUni2 =    iconFirstHost + 3;
  nHostIcons =      4;

  iconFirstOther =  iconFirstHost + nHostIcons;

  iconSortArrowAsc =   iconFirstOther + 0;
  iconSortArrowDesc =  iconFirstOther + 1;
  iconKeyMiddle =      iconFirstOther + 2;
  iconLock =           iconFirstOther + 3;

  //iconDefect =      iconFirstOther;

  { WorkWin.ChangeImages }
  iconFirstChange =  0;
  iconCKeyPlus =     iconFirstChange;
  iconCKeyMinus =    iconFirstChange + 1;
  iconCValuePlus =   iconFirstChange + 2;
  iconCValueMinus =  iconFirstChange + 3;
  iconCContext =     iconFirstChange + 4;
  iconOldContext =   iconFirstChange + 5;
  iconNewContext =   iconFirstChange + 6;
  iconGroup =        iconFirstChange + 7;
  iconGroupBlinking =   iconFirstChange + 8;
  nChangeIcons =    7;

  DefaultValueFlag = Pointer(1);
  MultiEditFlag = Pointer(2);
  
  NoValueCaption = '[No Value]';

  EditControlFlag = 100;

  MaxPreviewLen = 255;
  RegMaxDataSize = $FFFF; //64 KB

const
  BoolStrFileName = 'Boolean Strings.txt';
  ShortcutsFileName = 'Shortcuts.ini';
  StandardShortcutsFileName = 'StandardShortcuts.ini';
  SisyFilterFileName = 'sisy filter.txt';

  clDarkGray = $00404040;
  clBrightRed = $00BBBBFF;
  clVeryBrightRed = $00DDDDFF;
  clBrightBlue = $00FFBBBB;
  clBrightGreen = $00BBFFBB;
  clCyan = $00FFFF44;
  clBrightCyan = $00FFFFBB;
  clVeryBrightCyan = $00FFFFDD;
  clBrightYellow = $00BBFFFF;
  clVeryBrightYellow = $00DDFFFF;
  clBrightPurple = $00FFBBFF;
  clBrightSilver = $00DDDDDD;
  clGold = $0055CCEE;

  clVeryBrightBlue = $00FFDDDD;

type
  TValueListColumn = (vlcName, vlcSize, vlcType, vlcData);

const
  ValueListColumnRange = [Low(TValueListColumn)..High(TValueListColumn)];

type
  TSearchVar = (sfKeys, sfValueNames, sfValueData,
                sfAsHex, sfAsDWord,
                sfWildCards, sfParts, sfIgnoreCase, SfUseLocales,
                sfHKU, sfHKLM, sfHKDD,// sfCLSID, sfInterface,
                sfString, sfDWord, sfOtherTypes, sfSpecialTypes);

  TSearchOptions = set of TSearchVar;

  //be carefull: used in with!
  TKeyShortcut = record
    Alias: string;
    RealPath: string;
    Node: TTreeNode;
  end;
  PKeyShortcut = ^TKeyShortcut;
  TShortcutA = array of TKeyShortcut;

  TOpenNode = function (Reg: TXRegistry; Node: TTreeNode): Boolean;
  TCheckNode = procedure (Node: TTreeNode; OnlyOnce: Boolean = True);

  //NodeInfo System
  TNodeFlag = (nfDefect, nfReadOnly, nfChecked,
    nfCopy, nfCut, nfPaste);
  TNodeFlags = set of TNodeFlag;

  TUniHostType = (uhNone,
                  uhReg, uhIni, uhRegFile,
                  uhUserShortcut, uhStandardShortcut, uhSystemShortcut);
  TUniHostTypes = set of TUniHostType;

const
  uhShortcuts = [uhUserShortcut, uhStandardShortcut, uhSystemShortcut];
  uhNonSystemShortcuts = [uhUserShortcut, uhStandardShortcut];

  NodeFlagStrings: array[TNodeFlag] of string = (
    'nfDefect', 'nfReadOnly', 'nfChecked',
    'nfCopy', 'nfCut', 'nfPaste');

  HostTypeStrings: array[TUniHostType] of string = ('uhNone',
    'uhReg', 'uhIni', 'uhRegFile',
    'uhUserShortcut', 'uhStandardShortcut', 'uhSystemShortcut');

type
  TNodeInfo = packed class
  public
    HostType: TUniHostType;
    Flags: TNodeFlags;
    constructor Create(HostType: TUniHostType = uhNone; Flags: TNodeFlags = []);

    procedure IncludeFlag(Flag: TNodeFlag);
    procedure ExcludeFlag(Flag: TNodeFlag);

    function IsHost: Boolean;
    function IsShortcut: Boolean;

    function ReadOnly: Boolean;
    function Checked: Boolean;
    function Defect: Boolean;
  end;

function NodeInfo(Node: TTreeNode): TNodeInfo;
procedure ReportStatus(const s: string);

const
  PlatformStrings: array[0..2] of string =
    ('VER_PLATFORM_WIN32s', 'VER_PLATFORM_WIN32_WINDOWS', 'VER_PLATFORM_WIN32_NT');

var
  PlutoDir: string = '';

implementation

uses SysUtils;

function NodeInfo(Node: TTreeNode): TNodeInfo;
begin
  if not Assigned(Node) then begin
    Result := nil;
  Exit end;

  if not Assigned(Node.Data) then
    Node.Data := TNodeInfo.Create;
  Result := TNodeInfo(Node.Data);
end;

{ TNodeInfo }

constructor TNodeInfo.Create(HostType: TUniHostType; Flags: TNodeFlags);
begin
  inherited Create;
  Self.HostType := HostType;
  Self.Flags := Flags;
end;

function TNodeInfo.Checked: Boolean;
begin
  Result := nfChecked in Flags;
end;

function TNodeInfo.ReadOnly: Boolean;
begin
  Result := nfReadOnly in Flags;
end;

function TNodeInfo.Defect: Boolean;
begin
  Result := nfDefect in Flags;
end;

procedure TNodeInfo.IncludeFlag(Flag: TNodeFlag);
begin
  Include(Flags, Flag);
end;

procedure TNodeInfo.ExcludeFlag(Flag: TNodeFlag);
begin
  Exclude(Flags, Flag);
end;

function TNodeInfo.IsHost: Boolean;
begin
  Result := HostType <> uhNone;
end;

function TNodeInfo.IsShortcut: Boolean;
begin
  Result := HostType in uhShortcuts;
end;

function GetPlutoDir: string;
begin
  Result := LWPSlash(GetParam('-imports=', MyDir));
  if not DirectoryExists(Result) then begin
    ReportStatus('PlutoDir "' + Result + '" not found -> setting to default (MyDir).');
    Result := MyDir;
  end;
  ReportStatus('PlutoDir=' + Result);
end;

var
  ReportSL: TStringList;
  ReportFileName: string;

procedure ReportStatus(const s: string);
begin
  ReportSL.Add(s);
  try
    ReportSL.SaveToFile(ReportFileName);
  except end;
end;

initialization
  ReportFileName := MyDir + 'loadreport.txt';
  ReportSL := TStringList.Create;
  PlutoDir := GetPlutoDir;

end.
//winampviscolor <viscolor.txt>:
unit plutomain;
{$DEFINE UNIKEY}
{$DEFINE CYCFS}

{===============================================================================

   cYcnus.Pluto 1.57 Beta 14
   by Murphy

   ©2000-2003 by cYcnus
   visit www.cYcnus.de

   murphy@cYcnus.de (Kornelius Kalnbach)
   
   this programm is published under the terms of the GPL

===============================================================================}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ImgList, ComCtrls, ExtCtrls, Menus, Clipbrd, IniFiles,
  ShellAPI, Grids,
  //Components
  NewPanels,
  //Units
  YTools, YTypes, UniKey, XReg,
  //Pluto
  Plutoconst,
  SpyTH, SisyphusTH;

const
  NoPreBlinkHint = #1;

type
  TMainWin = class(TForm)
    StatusBar: TStatusBar;
    StatusBarPU: TPopupMenu;
    CopyPath: TMenuItem;
    InsertPath: TMenuItem;
    ShowRealPathMI: TMenuItem;
    PathP: TPanel;
    N1: TMenuItem;
    MainMenu1: TMainMenu;
    Desktop1: TMenuItem;
    Pluto1: TMenuItem;
    RegEdit1: TMenuItem;
    Free1: TMenuItem;
    BigVal1: TMenuItem;
    Hilfe1: TMenuItem;
    History1: TMenuItem;
    SplashScreen1: TMenuItem;
    wwwcYcnusde1: TMenuItem;
    Credits1: TMenuItem;
    Optionen1: TMenuItem;
    PrefMI: TMenuItem;
    EditBoolStrMI: TMenuItem;
    N4: TMenuItem;
    ImageList1: TImageList;
    Plutoini1: TMenuItem;
    About1: TMenuItem;
    kornycYcnusde1: TMenuItem;
    ools1: TMenuItem;
    NotePad1: TMenuItem;
    RegEdit2: TMenuItem;
    SysEdit1: TMenuItem;
    WordPad1: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    Suchen1: TMenuItem;
    Find1: TMenuItem;
    File1: TMenuItem;
    ExitPluto1: TMenuItem;
    OpenProgramFolder1: TMenuItem;
    N6: TMenuItem;
    OpenWinDir1: TMenuItem;
    HintBlinkT: TTimer;
    FindCLSID1: TMenuItem;
    Clipboard1: TMenuItem;
    GotoCLSID1: TMenuItem;
    CommandLineParameters1: TMenuItem;
    plutocYcnusde1: TMenuItem;
    N7: TMenuItem;
    heinzcYcnusde1: TMenuItem;
    kornycYcnusde2: TMenuItem;
    N8: TMenuItem;
    ExternalHexEditMI: TMenuItem;
    Cleanup1: TMenuItem;
    DeleteTempFolder1: TMenuItem;
    Debug1: TMenuItem;
    CurrentDir1: TMenuItem;
    RepairPluto155bBug1: TMenuItem;
    BackupRegistryscanreg1: TMenuItem;
    Username1: TMenuItem;
    SupportMI: TMenuItem;
    MurphyMI: TMenuItem;
    ToDoMI: TMenuItem;
    Beta1: TMenuItem;
    UniKeycYcnusde1: TMenuItem;
    YToolscYcnusde1: TMenuItem;
    YPanelscYcnusde1: TMenuItem;
    Usedenginescomponents1: TMenuItem;
    PrefToolscYcnusde1: TMenuItem;
    BugReportsRequests1: TMenuItem;
    murphycYcnusde1: TMenuItem;
    Credits2: TMenuItem;
    News1: TMenuItem;
    cYcnus1: TMenuItem;
    Contact1: TMenuItem;
    N2: TMenuItem;
    IjustwantCONTACT1: TMenuItem;
    N9: TMenuItem;
    AnotherPluto1: TMenuItem;
    UniKeyDemoMI: TMenuItem;
    Path1: TMenuItem;
    RegisterPlugIns1: TMenuItem;
    UniPluginOD: TOpenDialog;
    SwapLM_CUB: TButton;
    PathE: TEdit;
    ShowLoadreport1: TMenuItem;
    KillPluto1: TMenuItem;
    ShowPlatform1: TMenuItem;
    MSConfig1: TMenuItem;
    TimetoRelaxMI: TMenuItem;
    N10: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InsertPathClick(Sender: TObject);

    procedure StatusBarResize(Sender: TObject);
    procedure StatusBarDblClick(Sender: TObject);
    procedure StatusBarUpdate;
    procedure CopyPathClick(Sender: TObject);

    procedure SetStatus;
    procedure GotoKey(Key: string);
    procedure FindCLSID;
    procedure GotoCLSID;
    procedure UserGotoKey;
    procedure ShowRealPathMIClick(Sender: TObject);
    procedure PathEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PathEChange(Sender: TObject);
    procedure PathEExit(Sender: TObject);

    procedure AppActivate(Sender: TObject);
    procedure PathEKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActivateIt(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Pluto1Click(Sender: TObject);
    procedure RegEdit1Click(Sender: TObject);
    procedure Free1Click(Sender: TObject);
    procedure BigVal1Click(Sender: TObject);
    procedure SplashScreen1Click(Sender: TObject);
    procedure HistoryClick(Sender: TObject);
    procedure Credits1Click(Sender: TObject);

    function Greeting(Name: string = NoPreBlinkHint): string;
    procedure PrefMIClick(Sender: TObject);
    procedure EditBoolStrMIClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SisyTerminate(Sender: TObject);
    procedure OnSisyChange(Sender: TSisyThread; Change: TSisyChange);
    procedure OnSisyValuePlus(Sender: TSisyThread; Change: TSisyChange);
    procedure OnSisyValueMinus(Sender: TSisyThread; Change: TSisyChange);
    procedure OnSisyContextChange(Sender: TSisyThread; Change: TSisyChange);

    procedure Plutoini1Click(Sender: TObject);
    procedure RegEdit2Click(Sender: TObject);
    procedure SysEdit1Click(Sender: TObject);
    procedure NotePad1Click(Sender: TObject);
    procedure WordPad1Click(Sender: TObject);
    procedure OpenWinDir1Click(Sender: TObject);
    procedure OpenProgramFolder1Click(Sender: TObject);
    procedure ExitPluto1Click(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);

    procedure Load;
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure PathEKeyPress(Sender: TObject; var Key: Char);
    procedure HintBlinkTTimer(Sender: TObject);
    procedure FindCLSID1Click(Sender: TObject);
    procedure GotoCLSID1Click(Sender: TObject);
    procedure CommandLineParameters1Click(Sender: TObject);
    procedure WebLinkMIClick(Sender: TObject);
    procedure DeleteTempFolder1Click(Sender: TObject);
    procedure CurrentDir1Click(Sender: TObject);
    procedure RepairPluto155bBug1Click(Sender: TObject);
    procedure BackupRegistryscanreg1Click(Sender: TObject);
    procedure SisyStarted(Sender: TObject);
    procedure StopHintBlinking;
    procedure Username1Click(Sender: TObject);
    procedure SupportMIClick(Sender: TObject);
    procedure ToDoMIClick(Sender: TObject);
    procedure MailLinkMIClick(Sender: TObject);
    procedure IjustwantCONTACT1Click(Sender: TObject);
    procedure ExternalHexEditMIClick(Sender: TObject);
    procedure AnotherPluto1Click(Sender: TObject);
    procedure Path1Click(Sender: TObject);
    procedure RegisterPlugIns1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SwapLM_CUBClick(Sender: TObject);
    procedure ShowLoadreport1Click(Sender: TObject);
    procedure KillPluto1Click(Sender: TObject);
    procedure ShowPlatform1Click(Sender: TObject);
    procedure MSConfig1Click(Sender: TObject);
    procedure TimetoRelaxMIClick(Sender: TObject);
  private
    DoAutoComplete: Boolean;
    MainWinLoaded: Boolean;
    DontSavePrefs: Boolean;
    PreBlinkHint: string;
  end;

var
  MainWin: TMainWin;

  StatusBar: TStatusBar;
  MainReg: TXRegistry;

  SpyThread: TRegSpyThread;
  Sisys: TList;

function TempDir: string;
function PlutoUniPath: string;
function PlutoIniFileName: string;

function PathOfNode(Node: TTreeNode): string;
function CurKey(AllowedShortcutTypes: TUniHostTypes = []): TRegPath;

procedure ArrangePlutoStyle;
procedure ArrangeRegEdStyle;
procedure ArrangeFreeStyle;
procedure ArrangeBigValStyle;

procedure ActivateThis(Sender: TObject);
procedure DeActivateThis(Sender: TObject);

procedure SwapFonts(Sender: TWinControl);

procedure AddHint(const Hint: string; Blinking: Boolean = False);
procedure AddToLastHint(Appendix: string);
procedure ChangeLastHint(NewHint: string);

implementation

uses
  //Forms
  FindWinU, valuesU, TreeU, WorkU, splash, PrefU,
  //Units
  Clock, Start, keybrd, CompEx, Colors, FindAllThread,
  PrefTools;

{$R *.DFM}

var
  SavedPlutoIniFileName: string = '';

procedure AddHint(const Hint: string; Blinking: Boolean = False);
begin
  if Assigned(WorkWin) then
    WorkWin.AddAHint(Hint);

  with MainWin do begin
    StopHintBlinking;

    if Blinking then begin
      HintBlinkT.Enabled := True;
      if PreBlinkHint = NoPreBlinkHint then
        PreBlinkHint := StatusBar.Panels[0].Text;
      StatusBar.Panels[0].Text := WorkWin.LastHint;
    end;
  end;
end;

procedure AddToLastHint(Appendix: string);
begin
  with WorkWin.HintLB.Items do begin
    if Count = 0 then
      Exit;

    Strings[Count-1] := Strings[Count-1] + Appendix;
  end;
  Application.ProcessMessages;
//  Sleep(1000);
end;

procedure ChangeLastHint(NewHint: string);
begin
  with WorkWin.HintLB.Items do begin
    if Count = 0 then
      Exit;

    Strings[Count-1] := NewHint;
  end;
  Application.ProcessMessages;
//  Sleep(1000);
end;

function CurKey(AllowedShortcutTypes: TUniHostTypes = []): TRegPath;
var
  s: string;
  Item: TListItem;
begin
  if Assigned(RegTV.Selected) then begin
    s := PathOfNode(RegTV.Selected);
    if AllowedShortcutTypes <> [] then
      s := TraceKey(s, AllowedShortcutTypes);
    Result.Root := ExRegRoot(s);
    Result.Key := ExRegKey(s);

    Item := ValueList.ItemFocused;
    if Assigned(Item) then
      Result.Value := RealValueName(Item);
    Result.ValueSet := Assigned(Item);
  end;
end;

function PathOfNode(Node: TTreeNode): string;
begin
  Result := '';

  if not Assigned(Node) then
    Exit;

  if Assigned(Node.Parent) then
    Result := LWPSlash(PathOfNode(Node.Parent)) + Node.Text
  else
    Result := Node.Text;
end;

procedure TMainWin.AppActivate(Sender: TObject);
var
  ActForm: TCustomForm;

  procedure TryShow(Win: TCustomForm);
  begin
    if Assigned(Win) and Win.Visible then
      Win.Show;
  end;

begin
  ActForm := Screen.ActiveCustomForm; //LastActiveForm;
  TryShow(ValuesWin);
  TryShow(WorkWin);
  TryShow(TreeWin);
  TryShow(FindWin);
  TryShow(SplashWin);
  TryShow(MainWin);
  TryShow(ActForm);
end;

procedure TMainWin.FormCreate(Sender: TObject);

  procedure InitHKEYString(var H: THKEYString; const Long, Short: string;
    Handle: Integer = 0; IsDefault: Boolean = False);
  begin
    H.Long := Long;
    H.Short := Short;
    H.Handle := Handle;
    H.IsDefault := IsDefault;
  end;

begin
{$IFDEF UNIKEY}
{$IFDEF CYCFS}
  RegisterUniClass('Y:\programme\unikey\cyc_fs.uni');
{$ENDIF}
{$ENDIF}

  Application.OnActivate := AppActivate;
  PlutoMain.StatusBar := StatusBar;

  //Creating
  MainReg := TXRegistry.Create;

  //Initialize
  Caption := 'cYcnus.Pluto ' + Version;
  PreBlinkHint := NoPreBlinkHint;

  SetLength(HKEYStrings, Length(HKEYStrings) + 2);
  InitHKEYString(HKEYStrings[LastDefaultHKEYString + 1],
    'HKEY_WindowsMachine', 'HKWM');

  InitHKEYString(HKEYStrings[LastDefaultHKEYString + 2],
    'HKEY_WindowsUser', 'HKWU');

  Application.HintHidePause := -1; //that's approximately 136 years :D

  StatusBar.Panels[0].Width := Screen.Width div 6;

  MurphyMI.Visible := MurphyMode;

{$IFDEF UNIKEY}
  UniPluginOD.InitialDir := MyDir;
{$ELSE}
  UniKeyDemoMI.Visible := False;
{$ENDIF}
end;

procedure TMainWin.GotoKey(Key: string);
var
  Full: TregPath;
  Node: TTreeNode;
  keySA: TStrA;
  i: integer;

  function NodeOfRoot(Root: string): TTreeNode;
  var
    i: Integer;
  begin
    Result := nil;
    Root := LongHKEY(Root);

    for i := 0 to RootNodes.Count-1 do
      if SameText(TTreeNode(RootNodes[i]).Text, Root) then begin
        Result := TTreeNode(RootNodes[i]);
      Break; end;

    for i := 0 to High(Shortcuts) do
      if SameText(Shortcuts[i].Alias, Full.Root) then begin
        Result := Shortcuts[i].Node;
      Break; end;
  end;

begin
  keySA := nil;

  //Get FullPath of the Key
  Key := TrimLeft(Key);
  if TextAtPos(Key, 1, 'Reg:') then
    Key := TrimLeft(FromChar(Key, ':'));
  Key := UnQuote(Key);

  Full := RegPathOfStr(Key);
  if Trim(Full.Root) = '' then begin
    AddHint('Empty Path.', True);
  Exit; end;

  //Get Root Node
  Node := NodeOfRoot(Full.Root);
  if not Assigned(Node) then begin
    if not PathE.Focused then
      AddHint('Key not found:' + EOL + Key);
  Exit; end;

  //Create an array of all SubKeys
  keySA := Split(Full.Key, '\');

  //Avoid SmartExpand
  TreeWin.DoSmartExpand := False; begin

    //Open all SubKeys
    for i := 0 to High(keySA) do begin
      //Open the Node if neccessary
      if not Node.Expanded then begin
        if not Node.Selected then
          RegTV.Selected := Node;
        CheckNode(Node, False);
        //TreeWin.RegTVChange(Self, Node);
        Node.Expand(False);
      end;

      //Get Node of the SubKey
      Node := FindNodeText(Node, keySA[i]);
      if not Assigned(Node) then begin
        if not PathE.Focused then
          AddHint('Goto Key not found: ' + KeySA[i], True);
        Exit;
      end;
    end;

  end; TreeWin.DoSmartExpand := True;

  if Node <> RegTV.Selected then begin
    RegTV.Selected := Node;
    TreeWin.RegTVChange(Self, Node);
  end;

  Application.ProcessMessages;

  if Full.ValueSet then
    ValuesWin.FocusItem(Full.Value, not (Active and PathE.Focused))
  else begin
    if not (Active and PathE.Focused) then //if not user is currently editing the path
      TreeWin.FocusControl(RegTV);

    if LastChar(Full.Key) = '\' then
      Node.Expand(False);
  end;
end;

procedure SwapFonts(Sender: TWinControl);

  function OtherFont(N: TFontName): TFontName;
  begin
    Result := 'Courier New';
    if N = Result then
      Result := 'Arial';
  end;

begin
  TEdit(Sender).Font.Name := OtherFont(TTreeView(Sender).Font.Name);
end;

procedure ActivateThis(Sender: TObject);
begin
  if not Assigned(Sender) then
    Exit;

  with TEdit(Sender) do begin
    if Tag <> EditControlFlag then
      Exit;
    Color := RealColor(clVeryBrightBlue);
    Font.Color := clBlack;
  end;
end;

procedure DeActivateThis(Sender: TObject);
begin
  if not Assigned(Sender) then
    Exit;

  with TEdit(Sender) do begin
    if Tag <> EditControlFlag then
      Exit;
    Color := RealColor(clDarkGray);
    Font.Color := clWhite;
  end;
end;

procedure CreateSisyThreads;
var
  i: Integer;

  procedure CreateSisyThread(const Name: string; const KeyName: string;
    Key: HKEY; StatusLabel: TLabel);
  var
    Sisy: TSisyThread;
  begin
    ChangeLastHint('Creating ' + Name + '...');
    Sisy := TSisyThread.CreateIt(Name, KeyName, Key, StatusLabel, PlutoKey);
    Sisy.OnChange := MainWin.OnSisyChange;
//    Sisy.OnSpecialChange[cValuePlus] := MainWin.OnSisyValuePlus;
//    Sisy.OnSpecialChange[cValueMinus] := MainWin.OnSisyValueMinus;
//    Sisy.OnSpecialChange[cContextChange] := MainWin.OnSisyContextChange;
    Sisys.Add(Sisy);
    AddToLastHint('OK');
  end;

begin
  AddHint('Starting Sisyphus ' + SisyVersion + '...');

  Sisys := TSisyList.Create;
  WorkWin.LoadSisyFilter;

  CreateSisyThread('Sisy HKU', 'HKU', HKU, WorkWin.SisyHKUL);
  CreateSisyThread('Sisy HKLM', 'HKLM', HKLM, WorkWin.SisyHKLML);

  ChangeLastHint('Initializing Sisyphus...');
  for i := 0 to Sisys.Count-1 do
    with TSisyThread(Sisys[i]) do begin
      if Name = 'Sisy HKU' then
        with WorkWin.SisyHKUCB do begin
          Settings.KeyName := StrOfUni(Uni.Path);
          Settings.Load;
          Settings.AutoSave := True;
          if Checked then
            Resume;
        end
      else if Name = 'Sisy HKLM' then
        with WorkWin.SisyHKLMCB do begin
          Settings.KeyName := StrOfUni(Uni.Path);
          Settings.Load;
          Settings.AutoSave := True;
          if Checked then
            Resume;
        end;
      OnStarted := MainWin.SisyStarted;
    end;
end;

procedure CreateSpyThread;
begin
  AddHint('Creating SpyThread...');
  SpyThread := TRegSpyThread.CreateIt(tpLowest);
  WorkWin.SpyDelayIEChange(MainWin);
  WorkWin.SpyTestLClick(MainWin);
  AddToLastHint('OK');
end;

procedure ShowParams;
var
  SL: TStringList;
begin
  if Switch('params?') then begin
    SL := TStringList.Create;
    GetParams(SL);
    ShowMessage(SL.Text);
    SL.Free;
  end;
end;

procedure GotoParamKey;
var
  s: string;
begin
  s := ParamStr(1);
  if (s <> '')
   and (s[1] <> '-') then begin //Params have '-' as prefix
    AddHint('Goto Key ' + Quote(s) + '...');
    MainWin.GotoKey(s);
  end else begin
    RegTV.Selected := RegTV.TopItem;
  end;
end;

procedure TMainWin.Load;
begin
  TreeWin.Load;
  WorkWin.LoadBoolStr;

  CreateSpyThread;
  CreateSisyThreads;

  AddHint(Greeting, True);

  ShowParams;
  GotoParamKey;

  if Assigned(SplashWin) and SplashWin.Visible then
    SplashWin.SetFocus;
end;

procedure TMainWin.CopyPathClick(Sender: TObject);
begin
  Clipboard.AsText := StatusBar.Panels[1].Text;
end;

procedure TMainWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in shift) and (Key = VK_F4) then begin
    Key := 0;
    Close;
  Exit; end;

  if ssCtrl in Shift then
    case Key of
      Byte('W'): begin
          MainPC.ActivePage := WorkWin.WorkPage;
          if Assigned(MainPC.ActivePage) then
            WorkWin.FocusControl(TWinControl(ShowPC.ActivePage.Tag))
        end;

      Byte('H'): MainPC.ActivePage := WorkWin.HintPage;

      Byte('L'): MainWin.FindCLSID;
    end;

  if Shift = [] then
    case Key of
      VK_F6: TreeWin.FocusControl(RegTV);

      VK_F7: with ValueList do begin
          ValuesWin.FocusControl(ValueList);
          if (Selected = nil) and (Items.Count > 0) then begin
            Selected := Items[0];
            ItemFocused := Selected;
          end;
        end;

      VK_F8: WorkWin.FocusControl(MainPC);
    end;

  if Key = VK_SCROLL then begin
    TreeWin.CheckRegTVHotTrack;
    ValuesWin.CheckValueListHotTrack;
  end;
end;

procedure TMainWin.StatusBarResize(Sender: TObject);
begin
  with StatusBar do
    Panels[1].Width :=
      Width - (Panels[0].Width + Panels[2].Width + Panels[3].Width);
end;

procedure TMainWin.StatusBarDblClick(Sender: TObject);
begin
  ShowRealPathMIClick(Sender);
end;

procedure TMainWin.InsertPathClick(Sender: TObject);
begin
  GotoKey(Clipboard.AsText);
end;

procedure TMainWin.SetStatus;
begin
  StatusBarUpdate;
end;

procedure TMainWin.StatusBarUpdate;
var
  Inf: TRegKeyInfo;
begin
  OpenCurKey;
  MainReg.GetKeyInfo(Inf);
  MainReg.CloseKey;

  StatusBar.Panels[2].Text := StrNumerus(Inf.NumSubKeys, 'key', 'keys', 'no');
  StatusBar.Panels[3].Text := StrNumerus(Inf.NumValues, 'value', 'values', 'no');

  if ShowRealPathMI.Checked then
    StatusBar.Panels[1].Text := StrOfRegPath(CurKey(uhShortcuts))
  else
    StatusBar.Panels[1].Text := StrOfRegPath(CurKey(uhNonSystemShortcuts));

  if not PathE.Focused then
    PathE.Text := StrOfRegPath(CurKey);
end;

procedure TMainWin.ShowRealPathMIClick(Sender: TObject);
begin
  ShowRealPathMI.Checked := not ShowRealPathMI.Checked;
  StatusBarUpdate;
end;

procedure TMainWin.PathEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Pos: Integer;
  s: string;
begin
  DoAutoComplete := not (Key in [VK_DELETE, VK_BACK, VK_ESCAPE]);
  
  case Key of
    VK_BACK:
      begin
        s := PathE.Text;
        Pos := PathE.SelStart;

        if ssCtrl in Shift then
          repeat
            Dec(Pos);
          until (Pos < 1) or (s[Pos] = '\')
        else if PathE.SelLength = 0 then
          Exit;

        PathE.Text := Copy(s, 1, Pos);
        PathE.SelStart := Length(s);
        Key := 0;
        UserGotoKey;
      end;

    VK_ESCAPE:
      with PathE do begin
        if SelLength = 0 then
          Exit;
        Text := StrOfRegPath(CurKey);
        SelStart := Length(Text);
      end;

    VK_RETURN: begin
      if CurKey.ValueSet then
        ValuesWin.ValueListDblClick(Self);
      Key := 0;
    end;
    
    VK_RIGHT: begin
        if not (ssCtrl in Shift) then
          Exit;

        Key := 0;

        s := PathE.Text;
        Pos := PathE.SelStart + 1;
        repeat
          Inc(Pos);
        until (Pos > Length(s)) or (s[Pos] = '\');

        PathE.SelStart := Pos - 1;
      end;

    VK_LEFT: begin
        if not (ssCtrl in Shift) then
          Exit;

        with PathE do begin
          Key := 0;

          s := Text;
          Pos := SelStart;
          repeat
            Dec(Pos);
          until (Pos < 1) or (s[Pos] = '\');

          if Pos < 1 then
            Pos := 1;

          SelStart := Pos - 1;
        end;
      end;
  end;
end;

procedure TMainWin.UserGotoKey;
begin
  GotoKey(PathE.Text);
end;

procedure TMainWin.PathEChange(Sender: TObject);
var
  Prefix, Suffix, Key, Path, Root: string;
  i, p, Len: Integer;
  SL: TStringList;
  CompleteKind: (ckRoots, ckKeys, ckValues);

  procedure GetRootNames(Strings: TStrings);
  var
    Node: TTreeNode;
  begin
    SL.Clear;
    Node := RegTV.Items.GetFirstNode;
    while Assigned(Node) do begin
      SL.Add(Node.Text);
      Node := Node.GetNextSibling;
    end;
  end;

begin
  if not DoAutoComplete then
    Exit;

  Key := PathE.Text;
  Root := TraceKey(ExRegRoot(Key));

  if not CharIn(Key, '\') then
    CompleteKind := ckRoots
  else if ExRegValueSet(Key) then
    CompleteKind := ckValues
  else
    CompleteKind := ckKeys;

  case CompleteKind of
  ckRoots: begin
    Prefix := '';
    Suffix := Key;
  end;

  ckKeys: begin
    Path := ExRegFullKey(Key);
    Prefix := UntilLastChar(Path, '\');
    Suffix := FromLastChar(Path, '\');
  end;

  ckValues: begin
    p := Pos('\\', Key);
    Prefix := Copy(Key, 1, p - 1);
    Suffix := Copy(Key, p + 2, Length(Key) - p - 1);
  end;

  else
  end;

  SL := TStringList.Create;

  if CompleteKind in [ckKeys, ckValues] then
    with MainReg do begin
      RootKey := HKEYOfStr(ExRegRoot(Root));
      OpenKey(ExRegKey(Root));
      OpenKey(ExRegKey(Prefix));

      if CompleteKind = ckValues then begin
        if not HasValues then
          Exit;
        GetValueNames(SL);
      end else if CompleteKind = ckKeys then begin
        if not HasSubKeys then
          Exit;
        GetKeyNames(SL);
      end;

      CloseKey;
    end
  else begin
    GetRootNames(SL);
  end;

  if Suffix = '' then begin
    if (SL.Count > 0) and not StrIn(SL, '') then
      Suffix := SL[0];
  end else begin
    for i := 0 to SL.Count-1 do
      if TextAtBegin(SL[i], Suffix) then begin
        Suffix := SL[i];
      Break; end;
  end;

  Len := Length(PathE.Text);

  if CompleteKind = ckValues then
    Prefix := Prefix + '\\'
  else if CompleteKind = ckKeys then
    Prefix := Prefix + '\';

  with PathE do begin
    DoAutoComplete := False;  //Avoid Recursion
      Text := Prefix + Suffix;
    DoAutoComplete := True;

    SelStart := Len;
    SelLength := Length(Text) - Len;
  end;

  SL.Free;
end;

procedure TMainWin.PathEExit(Sender: TObject);
begin
  DeActivateThis(PathE);
  DoAutoComplete := False;
end;

procedure ArrangePlutoStyle;
begin
  with ValuesWin do begin
    Height := MainWin.ClientHeight div 3;
    Top := MainWin.ClientHeight - Height - 43;
    Left := 0;
    Width := MainWin.ClientWidth - 4;
    //Align := alBottom;
  end;

  with WorkWin do begin
    Top := 0;
    Width := Max(MainWin.ClientWidth div 3, WorkWin.Constraints.MinWidth);
    Left := ValuesWin.Width - Width;
    Height := MainWin.ClientHeight - 43 - ValuesWin.Height;
    //Align := alRight;
  end;

  with TreeWin do begin
    Top := 0;
    Height := WorkWin.Height;
    Left := 0;
    Width := ValuesWin.Width - WorkWin.Width;
  end;
     
  {TreeWin.Align := alNone;
  WorkWin.Align := alNone;
  ValuesWin.Align := alNone;}
end;

procedure ArrangeFreeStyle;
const
  Space = 10;
begin
  with ValuesWin do begin
    Height := Screen.Height div 3;
    Align := alBottom;
  end;

  with WorkWin do begin
    Width := Max(Screen.WorkAreaWidth div 3, Constraints.MinWidth + 2 * Space);
    Align := alRight;
  end;

  with TreeWin do begin
    Align := alClient;
  end;

  TreeWin.Align := alNone;
  WorkWin.Align := alNone;
  ValuesWin.Align := alNone;

  with ValuesWin do begin
    Height := Height - 2 * Space;
    Width := Width - 2 * Space;
    Top := Top + Space;
    Left := Left + Space;
  end;

  with TreeWin do begin
    Height := Height - 1 * Space;
    Width := Width - 1 * Space;
    Top := Top + Space;
    Left := Left + Space;
  end;

  with WorkWin do begin
    Height := Height - 1 * Space;
    Width := Width - 2 * Space;
    Top := Top + Space;
    Left := Left + Space;
  end;
end;

procedure ArrangeBigValStyle;
var
  MinHeight: Integer;
begin
  MinHeight := WorkWin.Constraints.MinHeight +
               MainWin.Constraints.MinHeight;

  with ValuesWin do begin
    Height := Screen.WorkAreaHeight - Max(Screen.Height div 3, MinHeight);
    Align := alBottom;
  end;

  with WorkWin do begin
    Width := Screen.WorkAreaWidth div 3;
    Align := alRight;
  end;

  with TreeWin do begin
    Align := alClient;
  end;

  TreeWin.Align := alNone;
  WorkWin.Align := alNone;
  ValuesWin.Align := alNone;
end;

procedure ArrangeRegEdStyle;
begin
  with TreeWin do begin
    Width := Screen.WorkAreaWidth div 4;
    Align := alLeft;
  end;

  with ValuesWin do begin
    Align := alClient;
    Align := alNone;
    Height := Height - WorkWin.Constraints.MinHeight;
  end;

  with WorkWin do begin
    Top := ValuesWin.Top + ValuesWin.Height;
    Left := ValuesWin.Left;
    Height := Constraints.MinHeight;
    Width := ValuesWin.Width;
  end;

  TreeWin.Align := alNone;
end;

procedure TMainWin.PathEKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not (Key in [VK_DELETE, VK_BACK, VK_ESCAPE]) then
    UserGotoKey;
end;

procedure TMainWin.ActivateIt(Sender: TObject);
begin
  ActivateThis(Sender);
end;

procedure TMainWin.FormActivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    ActivateThis(ActiveControl);
end;

procedure TMainWin.FormDeactivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    DeActivateThis(ActiveControl);
end;

procedure TMainWin.Pluto1Click(Sender: TObject);
begin
  ArrangePlutoStyle;
end;

procedure TMainWin.RegEdit1Click(Sender: TObject);
begin
  ArrangeRegEdStyle;
end;

procedure TMainWin.Free1Click(Sender: TObject);
begin
  ArrangeFreeStyle;
end;

procedure TMainWin.BigVal1Click(Sender: TObject);
begin
  ArrangeBigValStyle;
end;

procedure TMainWin.SplashScreen1Click(Sender: TObject);
begin
  SplashWin.Show;
end;

procedure TMainWin.HistoryClick(Sender: TObject);
begin
  NotePad(PlutoDir + 'version.txt');
end;

procedure TMainWin.WebLinkMIClick(Sender: TObject);
begin
  Browse('http://' + TMenuItem(Sender).Caption);
end;

procedure TMainWin.SupportMIClick(Sender: TObject);
begin
  Browse('http://cYcnus.de/php/phpbb/viewforum.php?f=1');
end;

procedure TMainWin.Credits1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := PlutoDir + 'credits deluxe.htm';
  if FileExists(FileName) then
    ExecFile(FileName)
  else begin
    FileName := PlutoDir + 'credits.htm';
    if FileExists(FileName) then
      ExecFile(FileName);
  end;
end;

function GetCLSIDFromClipboard: string;
var
  CLSID: string;
begin
  CLSID := BetweenChars(Clipboard.AsText, '{', '}', True);
  if CLSID = '' then begin
    Result := Clipboard.AsText;
    InputQuery('No CLSID in Clipboard.',
      'Use following format:' + EOL +
      '{00000000-0000-0000-0000-000000000000}', Result);
  Exit; end else
    Result := CLSID;
end;

procedure TMainWin.FindCLSID;
var
  CLSID, Desc: string;
begin
  CLSID := GetCLSIDFromClipboard;
  Desc := RegNameOfCLSID(CLSID);
  if Desc <> '' then
    InputQuery('Your CLSID is...', CLSID, Desc)
  else
    ShowMessage('CLSID not found: ' + CLSID + '.');
end;

procedure TMainWin.GotoCLSID;
var
  CLSID, Desc: string;
begin
  CLSID := GetCLSIDFromClipboard;
  Desc := RegNameOfCLSID(CLSID);
  if Desc <> '' then begin
    GotoKey('HKCR\CLSID\' + CLSID);
    TreeWin.FocusControl(RegTV);
  end else
    ShowMessage('CLSID not found: ' + CLSID + '.');
end;

function TMainWin.Greeting(Name: string = NoPreBlinkHint): string;
const
  Alias: array[0..4] of string =
    ('Licenser', 'Murphy', 'Sleeper', 'Leon',  'Great Admin');
  RealNames: array[0..4] of string =
    ('Heinz',    'Korny',  'Sven',    'Simon', 'Korny ;-)');
var
  i: Integer;
  s: string;
begin
  if Name = NoPreBlinkHint then
    Name := PrefWin.UserNameE.Text;
    
  if Trim(Name) = '' then
    s := 'No name?'
  else if SameText(Trim(Name), 'Pluto-User') then
    s := 'Hi!'
  else
    for i := 0 to 4 do
      if SameText(Name, Alias[i]) then begin
        s := 'Hi ' + RealNames[i] + '! This is a cYcnus.EasterEgg';
      Break; end
  else if Length(Name) > 20 then
    s := 'Hi ' + Name +
      '. What a name.'
  else
    s := 'Hi ' + Name + '!';

  Result := s;
end;

procedure TMainWin.PrefMIClick(Sender: TObject);
begin
  PrefWin.Show;
end;

function TempDir: string;
begin
  Result := PlutoDir + 'temp\';
  if not (DirectoryExists(Result) or CreateDir(Result)) then
    Result := PlutoDir;
end;

function PlutoIniFileName: string;

  function Default: string;
  begin
    Result := MyDir + 'pluto.ini';
  end;

begin
  Result := SavedPlutoIniFileName;
  if Result <> '' then
    Exit;

//  Result := Params.ReadString('ini', '');

  if IsValidFileName(Result) then
    Result := PlutoDir + Result
  else
    Result := Default;

  SavedPlutoIniFileName := Result; //Faster in future calls
end;

function PlutoUniPath: string;
begin
  //Result := 'Reg: HKCU\Software\Pluto\';
  Result := 'Ini <' + PlutoIniFileName + '>:';
end;

procedure TMainWin.EditBoolStrMIClick(Sender: TObject);
begin
  NotePad(PlutoDir + BoolStrFileName);
  ShowMessage('Click OK when you finished editing.' + EOL +
              '(Pluto will reload the Boolean Strings.)');
  WorkWin.LoadBoolStr;
end;

procedure TMainWin.SisyStarted(Sender: TObject);
{var
  NextSisyIndex: Integer;
  NextSisy: TSisyThread;          }
begin
  {NextSisy := nil;

  with TSisyThread(Sender) do begin
    //AddHint(Format('%s started after %0.1f seconds', [Name, SecsPerRound]), True);

    with Sisys do begin
      NextSisyIndex := IndexOf(Sender) + 1;
      if NextSisyIndex < Count then
        NextSisy := Items[NextSisyIndex];
    end;

    if Assigned(NextSisy) then
      with NextSisy do
        if not Started and Suspended then
          Resume;
  end; }
end;

procedure TMainWin.SisyTerminate(Sender: TObject);
begin
  if Assigned(Sisys) then
    Sisys.Delete(Sisys.IndexOf(Sender));
  AddHint('Sisyphus ' + Quote(TSisyThread(Sender).Name) + ' destroyed.');
end;

procedure TMainWin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;

  procedure TerminateThread(Thread: TThread; Name: string);
  const
    ThreadTimeOut = 3000;
  begin
    if Assigned(Thread) then
      with Thread do begin
        Priority := tpNormal;
        Terminate;
        while Suspended do Resume; // ensure running
        if 0 <> WaitForSingleObject(Handle, ThreadTimeOut) then begin
          ShowMessage('Timeout: Killing Thread: ' + Name + EOL +
            'This is a critical error and may cause memory leaks and crashes.' + EOL +
            'We recommend to reboot your system before you continue.');
          Windows.TerminateThread(Handle, 0);
        end else
          Thread.Free;
      end;
  end;

begin
  CanClose := False;

  try
    AddHint('Stopping SisyphusThreads...');
    if Assigned(Sisys) then
      for i := 0 to Sisys.Count-1 do
        TSisyThread(Sisys[i]).Suspend;
    AddToLastHint('OK');

    AddHint('Wait for SpyThread...');
    TerminateThread(SpyThread, 'SpyThread');
    AddToLastHint('OK');

    AddHint('Wait for SisyphusThreads...');
    if Assigned(Sisys) then
      for i := 0 to Sisys.Count-1 do begin
        ChangeLastHint('Wait for SisyphusThreads...' + TSisyThread(Sisys[i]).Name);
        TerminateThread(TSisyThread(Sisys[i]), TSisyThread(Sisys[i]).Name);
      end;
    ChangeLastHint('Wait for SisyphusThreads...OK');
  except
    with WorkWin.HintLB.Items do
      ShowMessage('Error while trying to terminate threads.' + EOL +
        'Last Message:' + EOL +
        Strings[Count - 1]);
    CanClose := True;
  end;

  AddHint('Terminating successfull.');
  CanClose := True;
end;

procedure TMainWin.FormClose(Sender: TObject; var Action: TCloseAction);

  procedure TryClose(Win: TCustomForm);
  begin
    if Assigned(Win) and Win.Visible then
      Win.Close;
  end;

begin
  MainReg.Free;

  Action := caFree;

  if DontSavePrefs then
    Exit;

  AddHint('Saving settings...');

  try
    TryClose(WorkWin);
    TryClose(ValuesWin);
    TryClose(TreeWin);
    TryClose(FindWin);
    TryClose(SplashWin);
    TryClose(PrefWin);
  except
    DontSavePrefs := True; //try again without pref saving
  end;

  with PlutoKey.GetKey('Window') do
    try
      WriteBool('Maximized', WindowState = wsMaximized);
      if WindowState = wsNormal then begin
        WriteInteger('Left', Left);
        WriteInteger('Top', Top);
        WriteInteger('Width', Width);
        WriteInteger('Height', Height);
      end;
    finally
      Free;
    end;
end;

procedure TMainWin.Plutoini1Click(Sender: TObject);
begin
  NotePad(PlutoIniFileName);
  ShowMessage('Click OK when you finished editing.' + EOL +
              '(Pluto will reload ' + PlutoIniFileName + ')');
  PrefWin.PrefHost.Load;
end;

procedure TMainWin.RegEdit2Click(Sender: TObject);
begin
  RegEdit;
end;

procedure TMainWin.SysEdit1Click(Sender: TObject);
begin
  SysEdit;
end;

procedure TMainWin.NotePad1Click(Sender: TObject);
begin
  NotePad;
end;

procedure TMainWin.WordPad1Click(Sender: TObject);
begin
  WordPad;
end;

procedure TMainWin.OpenWinDir1Click(Sender: TObject);
begin
  ExploreFolder(WinDir);
end;

procedure TMainWin.OpenProgramFolder1Click(Sender: TObject);
begin
  ExploreFolder(MyDir);
end;

procedure TMainWin.ExitPluto1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainWin.Find1Click(Sender: TObject);
begin
  FindWin.SfRootKeyRB.Checked := True;
  FindWin.Show;
end;

procedure TMainWin.FormPaint(Sender: TObject);
begin
  if Started and not MainWinLoaded then begin
    MainWinLoaded := True;
    Load;
  end;
end;

procedure TMainWin.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  with StatusBar.Canvas do begin
    Brush.Color := clBlack;
    FillRect(Rect);
    with Font do begin
      Name := 'MS Sans Serif';
      Style := [];
      case Panel.Index of
        0: if HintBlinkT.Enabled then
             Color := clBrightRed
           else
             Color := clBrightSilver;
        1: Color := clWhite;
        2: Color := clCyan;
        3: Color := clBrightPurple;
      end;
    end;

    if Panel.Alignment = taRightJustify then
      TextOut(Rect.Right - TextWidth(Panel.Text), Rect.Top, Panel.Text)
    else
      TextOut(Rect.Left, Rect.Top, Panel.Text);
  end;
end;

procedure TMainWin.PathEKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #127 then //Silly key management
    Key := #0;
end;

procedure TMainWin.HintBlinkTTimer(Sender: TObject);
begin
  StatusBar.Panels[0].Text := 'Ready';
  StopHintBlinking;
end;

procedure TMainWin.StopHintBlinking;
begin
  HintBlinkT.Enabled := False;
  PreBlinkHint := NoPreBlinkHint;
end;

procedure TMainWin.FindCLSID1Click(Sender: TObject);
begin
  FindCLSID;
end;

procedure TMainWin.GotoCLSID1Click(Sender: TObject);
begin
  GotoCLSID;
end;

procedure TMainWin.CommandLineParameters1Click(Sender: TObject);
begin
  NotePad(PlutoDir + 'Params.txt');
end;

procedure TMainWin.DeleteTempFolder1Click(Sender: TObject);
begin
  if mrYes = MessageDlg('Deleting ' + Quote(TempDir + '*.*' + EOL, '"') +
                        'Are you sure?', mtConfirmation, [mbYes, mbCancel], 0) then
    DeleteFiles(TempDir + '*.*', False);
end;

procedure TMainWin.CurrentDir1Click(Sender: TObject);
begin
  ShowMessage('MyDir: ' + MyDir + EOL +
              'PlutoDir: ' + PlutoDir + EOL +
              'CurrentDir: ' + GetCurrentDir + EOL +
              'Params: ' + EOL +
              GetParams(EOL));
end;

procedure TMainWin.RepairPluto155bBug1Click(Sender: TObject);
var
  Msg: string;
  Reg: TXRegistry;
begin
  Reg := TXRegistry.Create;

  try
    Reg.RootKey := HKCU;
    Reg.OpenKey('Software');
    Msg := '';
    if Reg.KeyExists('Sisyphus') then
      Msg := Msg + 'HKCU\Software\Sisyphus' + EOL;
    if Reg.KeyExists('Main') then
      Msg := Msg + 'HKCU\Software\Main' + EOL;
    if Reg.KeyExists('Spy') then
      Msg := Msg + 'HKCU\Software\Spy' + EOL;
    if Reg.KeyExists('View') then
      Msg := Msg + 'HKCU\Software\View' + EOL;
    if Msg = '' then begin
      ShowMessage('No bug detected :-)');
    end else begin
      Msg :=
        'Hi folks!' + EOL +
        'We are very sorry: A bug in Pluto made some components in the Edit'  + EOL +
        'window save their values to the regsitry instead of the ini file.' + EOL +
        'If you want to repair that, you have to delete the following keys:' + EOL +
        EOL +
        Msg +
        EOL +
        'This is not dangerous at all, but if you are interested in having' + EOL +
        'a clean registry, you should delete this useless keys.' + EOL +
        EOL +
        'You surely noticed that this key names are rubish because they are' + EOL +
        'in the level that is normally used by programs.' + EOL +
        'If you have programs installed that use this keys for their' + EOL +
        'preferences, you may get problems when deleting the keys!' + EOL +
        EOL +
        'So, now you have to decide what to do:' + EOL +
        EOL +
        'Yes: Delete the keys. You have to confirm the deleting of each key.' + EOL +
        'No: Jump to the Software key and delete manually.' + EOL +
        'Cancel: Do nothing.' + EOL +
        'Yes to All: Delete all keys.';

      case MessageDlg(Msg, mtWarning, [mbYes, mbNo, mbYesToAll, mbCancel], 0) of
        mrYes: begin
          if Reg.KeyExists('Main')
           and (mrYes=MessageDlg('Delete HKU\Software\Main ?',
           mtWarning, [mbYes, mbNo], 0)) then
             Reg.DeleteKey('Main');

          if Reg.KeyExists('Sisyphus')
           and (mrYes=MessageDlg('Delete HKU\Software\Sisyphus ?',
           mtWarning, [mbYes, mbNo], 0)) then
            Reg.DeleteKey('Sisyphus');

          if Reg.KeyExists('Spy')
           and (mrYes=MessageDlg('Delete HKU\Software\Spy ?',
           mtWarning, [mbYes, mbNo], 0)) then
            Reg.DeleteKey('Spy');

          if Reg.KeyExists('View')
           and (mrYes=MessageDlg('Delete HKU\Software\View ?',
           mtWarning, [mbYes, mbNo], 0)) then
            Reg.DeleteKey('View');
        end;

        mrYesToAll: begin
          Reg.DeleteKey('Main');
          Reg.DeleteKey('Sisyphus');
          Reg.DeleteKey('Spy');
          Reg.DeleteKey('View');
        end;

        mrNo: begin
          TreeWin.SetFocus;
          GotoKey('HKCU\Software\');
        end;
      end;
    end;

  finally
    Reg.Free;
  end;
end;

procedure TMainWin.BackupRegistryscanreg1Click(Sender: TObject);
begin
  ExecFile('scanreg');
end;

procedure TMainWin.Username1Click(Sender: TObject);
begin
  ShowMessage(UserName);
end;

procedure TMainWin.ToDoMIClick(Sender: TObject);
begin
  NotePad(PlutoDir + 'ToDo.txt');
end;

procedure TMainWin.MailLinkMIClick(Sender: TObject);
begin
  MailTo(TMenuItem(Sender).Caption);
end;

procedure TMainWin.IjustwantCONTACT1Click(Sender: TObject);
begin
  MailTo('pluto@cYcnus.de');
end;

procedure TMainWin.ExternalHexEditMIClick(Sender: TObject);
begin
  ExecFile(PrefWin.ExternalHexEditE.Text);
end;

procedure TMainWin.AnotherPluto1Click(Sender: TObject);
begin
  ExecFile(Application.ExeName);
end;

procedure TMainWin.Path1Click(Sender: TObject);
begin
{$IFDEF UNIKEY}
  UserUniPath := InputBox('UniKey', 'Input an UniPath.' + EOL +
    EOL +
    'No idea? Try one of these: ' + EOL +
    'WinAmpVisColor <viscolor.txt>:' + EOL +
    'Params:' + EOL +
    'Reg: HKCU' + EOL +
    'Ini <' + MyDir + 'pluto.ini>:' + EOL +
    'Ini <' + MyDir + 'pluto.ini>:[View]' + EOL,
    UserUniPath);
{$ENDIF}
end;

procedure TMainWin.RegisterPlugIns1Click(Sender: TObject);
begin
{$IFDEF UNIKEY}
  if UniPluginOD.Execute then
    RegisterUniClass(UniPluginOD.FileName);
{$ENDIF}
end;
  
procedure TMainWin.FormResize(Sender: TObject);
begin
  ArrangeIcons;
  ArrangePlutoStyle;
  WorkWin.WindowState := wsNormal;
  ValuesWin.WindowState := wsNormal;
  TreeWin.WindowState := wsNormal;
end;

procedure TMainWin.SwapLM_CUBClick(Sender: TObject);
var
  Path: string;
begin
  Path := TraceKey(PathE.Text, uhShortcuts);
  if SwapHKU_HKLM(Path) then begin
    PathE.Text := Path;
    UserGotoKey;
  end;
end;

procedure TMainWin.ShowLoadreport1Click(Sender: TObject);
begin
  NotePad(MyDir + 'loadreport.txt');
end;

procedure TMainWin.KillPluto1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainWin.ShowPlatform1Click(Sender: TObject);
begin
  ShowMessage(Format('Platform: %s' + EOL +
    'Versin: %d.%d Build %d',
    [PlatformStrings[Win32Platform],
     Win32MajorVersion, Win32MinorVersion, Win32BuildNumber]));
end;

procedure TMainWin.MSConfig1Click(Sender: TObject);
begin
  ExecFile('msconfig');
end;

procedure TMainWin.TimetoRelaxMIClick(Sender: TObject);
var
  RelaxFile: string;
begin
  with PlutoKey.GetKey('Main') do
    try
      RelaxFile := ReadString('Relax');
    finally
      Free;
    end;

  if RelaxFile = '' then
    ShowMessage('This menu item can be used for something that lets you relax,' + EOL +
      'for example Diablo2, you favorite song or the latest news about the' + EOL +
      'decreasing AOL member numbers.' + EOL +
      EOL +
      'Feel free to use everything you want.' + EOL +
      'Open the pluto.ini (CTRL+I) and add a new value "Relax" in the "Main"' + EOL +
      'section.' + EOL +
      EOL +
      'And don''t forget:' + EOL +
      'R E L A X ! ! !')
  else
    ExecFile(RelaxFile);
end;

procedure TMainWin.OnSisyChange(Sender: TSisyThread; Change: TSisyChange);

  procedure UpdateValue;
  var
    Reg: TXRegistry;
    Index: Integer;
  begin
    if not SameRegPath(ExRegFullKey(Change.Path), PathOfNode(RegTV.Selected)) then
      Exit;

    Reg := TXRegistry.Create;
    try
      Reg.RootKey := HKEYOfStr(ExRegRoot(Change.Path));
      if Reg.OpenKey(ExRegKey(Change.Path)) then
        with ValuesWin do begin
          Index := FindItemByRealName(ExRegValue(Change.Path));
          if Index > -1 then begin
            if Change.Typ = cValueMinus then
              ValueList.Items.Delete(Index)
            else if Change.Typ = cContextChange then
              UpdateValue(Reg, ValueList.Items[Index]);
          end else if Change.Typ = cValuePlus then
            AddValue(Reg, ExRegValue(Change.Path));
        end;
    finally
      Reg.Free;
    end;
  end;

begin
  AddHint(Sender.Name + ' notified ' + Change.Path);
  if Change.Typ in [cValueMinus, cValuePlus, cContextChange] then
    UpdateValue;
end;

procedure TMainWin.OnSisyValuePlus(Sender: TSisyThread; Change: TSisyChange);
var
  Reg: TXRegistry;
begin
  if not SameRegPath(ExRegFullKey(Change.Path), PathOfNode(RegTV.Selected)) then
    Exit;

  Reg := TXRegistry.Create;
  try
    Reg.RootKey := HKEYOfStr(ExRegRoot(Change.Path));
    if Reg.OpenKey(ExRegKey(Change.Path)) then
      ValuesWin.AddValue(Reg, ExRegValue(Change.Path));
  finally
    Reg.Free;
  end;
end;

procedure TMainWin.OnSisyValueMinus(Sender: TSisyThread; Change: TSisyChange);
var
  Reg: TXRegistry;
  Index: Integer;
begin
  if not SameRegPath(ExRegFullKey(Change.Path), PathOfNode(RegTV.Selected)) then
    Exit;

  Reg := TXRegistry.Create;
  try
    Reg.RootKey := HKEYOfStr(ExRegRoot(Change.Path));
    if Reg.OpenKey(ExRegKey(Change.Path)) then
      with ValuesWin do begin
        Index := FindItemByRealName(ExRegValue(Change.Path));
        if Index > -1 then
          ValueList.Items.Delete(Index);
      end;
  finally
    Reg.Free;
  end;
end;

procedure TMainWin.OnSisyContextChange(Sender: TSisyThread; Change: TSisyChange);
var
  Reg: TXRegistry;
  Index: Integer;
begin
  if not SameRegPath(ExRegFullKey(Change.Path), PathOfNode(RegTV.Selected)) then
    Exit;

  Reg := TXRegistry.Create;
  try
    Reg.RootKey := HKEYOfStr(ExRegRoot(Change.Path));
    if Reg.OpenKey(ExRegKey(Change.Path)) then
      with ValuesWin do begin
        Index := FindItemByRealName(ExRegValue(Change.Path));
        if Index > -1 then
          UpdateValue(Reg, ValueList.Items[Index]);
      end;
  finally
    Reg.Free;
  end;
end;

end.
unit PrefU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, PlutoConst, NewPanels, PrefTools,
  YTools, YTypes, start, XReg, LinkLabel;

type
  TPrefWin = class(TForm)
    PrefPC: TPageControl;
    CommonPage: TTabSheet;
    KeyPage: TTabSheet;
    DataPage: TTabSheet;
    KeysBP: TBorderPanel;
    GroupBox3: TGroupBox;
    MainPrevBP: TBorderPanel;
    GroupBox4: TGroupBox;
    BorderPanel6: TBorderPanel;
    GroupBox6: TGroupBox;
    SortKeysCB: TPrefCheckBox;
    PrefHost: TPrefHost;
    MainPreviewCB: TPrefCheckBox;
    SplashScreenCB: TPrefCheckBox;
    PrefValuesPC: TPageControl;
    StringPage: TTabSheet;
    MultiStringPage: TTabSheet;
    IntPage: TTabSheet;
    BinaryPage: TTabSheet;
    BorderPanel8: TBorderPanel;
    GroupBox8: TGroupBox;
    ShowDwordAsHex: TPrefCheckBox;
    BorderPanel7: TBorderPanel;
    GroupBox7: TGroupBox;
    CountZeroByteCB: TPrefCheckBox;
    BorderPanel1: TBorderPanel;
    GroupBox2: TGroupBox;
    UseExtendedModelCB: TPrefCheckBox;
    BorderPanel2: TBorderPanel;
    GroupBox1: TGroupBox;
    ShowAsBinaryCB: TPrefCheckBox;
    ShowBinaryAsRG: TPrefRadioGroup;
    Smart4BBCB: TPrefCheckBox;
    DWordPreviewL: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    UserNameE: TPrefEdit;
    Label8: TLabel;
    MainPreviewE: TPrefEdit;
    Label12: TLabel;
    DefaultIconPreviewCB: TPrefCheckBox;
    KeyInfoPreviewCB: TPrefCheckBox;
    SelectExternalHexEditOD: TOpenDialog;
    BorderPanel3: TBorderPanel;
    GroupBox9: TGroupBox;
    IntegrationPage: TTabSheet;
    BorderPanel4: TBorderPanel;
    GroupBox5: TGroupBox;
    Label11: TLabel;
    SelectExternalHexEditB: TButton;
    RunExternalHexEditB: TButton;
    ExternalHexEditE: TPrefEdit;
    Label13: TLabel;
    BorderPanel5: TBorderPanel;
    GroupBox10: TGroupBox;
    Label15: TLabel;
    RegisterAppCB: TCheckBox;
    Label3: TLabel;
    Memo1: TMemo;
    ExpandStringsRG: TPrefRadioGroup;
    QuotersE: TPrefEdit;
    Label1: TLabel;
    StringPreviewL: TLabel;
    ShowLineCountCB: TPrefCheckBox;
    ShowTreeViewLinesCB: TPrefCheckBox;
    ValuePage: TTabSheet;
    BorderPanel10: TBorderPanel;
    GroupBox12: TGroupBox;
    ShowListViewGridCB: TPrefCheckBox;
    Label9: TLabel;
    DefaultValueNameE: TPrefEdit;
    Label10: TLabel;
    GotoPlutoKeyB: TButton;
    ColorPanel2: TColorPanel;
    LinkLabel1: TLinkLabel;
    SmartExpandCB: TPrefCheckBox;
    KeysSingleClickCB: TPrefCheckBox;
    ValuesSingleClickCB: TPrefCheckBox;
    ShowProgressCB: TPrefCheckBox;
    ColorPanel1: TColorPanel;
    Label2: TLabel;
    ReloadB: TButton;
    DefaultB: TButton;
    SaveB: TButton;
    procedure PrefPCDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure PrefHostLoaded(Sender: TObject);
    procedure StandardPreviewChange(Sender: TObject);
    procedure DataPreviewChange(Sender: TObject);
    procedure UserNameEChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PrefValuesPCDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure ShowDwordAsHexClick(Sender: TObject);
    procedure MainPreviewEChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActivateIt(Sender: TObject);
    procedure DeActivateIt(Sender: TObject);
    procedure ReloadBClick(Sender: TObject);
    procedure RunExternalHexEditBClick(Sender: TObject);
    procedure SelectExternalHexEditBClick(Sender: TObject);
    procedure ExternalHexEditEChange(Sender: TObject);
    procedure DefaultBClick(Sender: TObject);
    procedure RegisterAppCBClick(Sender: TObject);
    procedure SaveBClick(Sender: TObject);
    procedure StringPreviewChange(Sender: TObject);
    procedure ShowTreeViewLinesCBClick(Sender: TObject);
    procedure ShowListViewGridCBClick(Sender: TObject);
    procedure DefaultValueNameEChange(Sender: TObject);
    procedure LoadPrefs;
    procedure UseExtendedModelCBClick(Sender: TObject);
    procedure IntegrationPageShow(Sender: TObject);
    procedure GotoPlutoKeyBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KeysSingleClickCBClick(Sender: TObject);
    procedure ValuesSingleClickCBClick(Sender: TObject);
    procedure QuotersEChange(Sender: TObject);
    procedure SplashScreenCBClick(Sender: TObject);
    procedure SaveBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  public
    StringQuoterBegin, StringQuoterEnd: string;
  end;

var
  PrefWin: TPrefWin;

implementation

uses
  TreeU, ValuesU, Splash, plutomain, WorkU;

{$R *.dfm}

procedure TPrefWin.PrefPCDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  PC: TPageControl;
  Page: TTabSheet;
begin
  PC := TPageControl(Control);
  Page := PC.Pages[TabIndex];
  with PC.Canvas.Font do begin
    if Page.Caption = 'Common' then
      Color := clWhite
    else if Page.Caption = 'Keys' then
      Color := clBrightCyan
    else if Page.Caption = 'Values' then
      Color := clBrightPurple
    else if Page.Caption = 'Data' then
      Color := clBrightBlue
    else if Page.Caption = 'System' then
      Color := clBrightYellow
    else
      Color := clWhite;
  end;

  with PC.Canvas do
    if Active then begin
      Font.Style := [fsBold];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 5, Rect.Top + 3, Page.Caption);
    end else begin
      Font.Style := [];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 3, Rect.Top + 2, Page.Caption);
    end;
end;

procedure TPrefWin.PrefHostLoaded(Sender: TObject);
begin
  PrefHost.KeyName := PlutoUniPath;
end;

procedure TPrefWin.StandardPreviewChange(Sender: TObject);
begin
  if Started then
    RegTV.Repaint;
end;

procedure TPrefWin.DataPreviewChange(Sender: TObject);
begin
  if not Started then
    Exit;

  ValuesWin.UpdateValues;
  RegTV.Repaint;
end;

procedure TPrefWin.UserNameEChange(Sender: TObject);
begin
  StatusBar.Panels[0].Text := MainWin.Greeting;
end;

procedure TPrefWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
    
  if Key = VK_SCROLL then
    MainWin.FormKeyDown(Sender, Key, Shift);
end;

procedure TPrefWin.FormDeactivate(Sender: TObject);
begin
  if ActiveControl.Tag = EditControlFlag then
    DeActivateThis(ActiveControl);

  AlphaBlendValue := 127;
end;

procedure TPrefWin.FormActivate(Sender: TObject);
begin
  if Started and (ActiveControl.Tag = EditControlFlag) then
    ActivateThis(ActiveControl);

  AlphaBlendValue := 255;
end;

procedure TPrefWin.PrefValuesPCDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  PC: TPageControl;
  Page: TTabSheet;
begin
  PC := TPageControl(Control);
  Page := PC.Pages[TabIndex];
  with PC.Canvas.Font do begin
    if Page = StringPage then
      Color := clBrightRed
    else if Page = MultiStringPage then
      Color := clBrightPurple
    else if Page = IntPage then
      Color := clBrightBlue
    else if Page = BinaryPage then
      Color := clBrightGreen;
  end;

  with PC.Canvas do
    if Active then begin
      Font.Style := [fsBold];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 18 + 5, Rect.Top + 3, Page.Caption);
      PC.Images.Draw(PC.Canvas, Rect.Left + 4, Rect.Top + 2, Page.ImageIndex);
    end else begin
      Font.Style := [];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 18 + 3, Rect.Top + 2, Page.Caption);
      PC.Images.Draw(PC.Canvas, Rect.Left + 1, Rect.Top + 1, Page.ImageIndex);
    end;
end;

procedure TPrefWin.ShowDwordAsHexClick(Sender: TObject);
begin
  DWordPreviewL.Caption := 'Preview: ' + ValuesU.DataPreviewOfContext(
    RegContext(rdCardinal, Reverse(ByteAOfHex(HexOfCard(1234567890, 8)))));
  DataPreviewChange(Self);
end;

procedure TPrefWin.MainPreviewEChange(Sender: TObject);
begin
  if MainPreviewE.Text = '' then
    MainPreviewCB.Caption := '&Show Preview for Default Value'
  else
    MainPreviewCB.Caption := '&Show Preview for ' +
      Quote(MainPreviewE.Text);

  StandardPreviewChange(Self);
end;

procedure TPrefWin.FormCreate(Sender: TObject);
begin
  UserNameE.DefaultValue := UserName;
  MainPreviewEChange(Self);
  PrefPC.ActivePageIndex := 0;
  PrefValuesPC.ActivePageIndex := 0;
end;

procedure TPrefWin.ActivateIt(Sender: TObject);
begin
  ActivateThis(Sender);
end;

procedure TPrefWin.DeActivateIt(Sender: TObject);
begin
  DeActivateThis(Sender);
end;

procedure TPrefWin.ReloadBClick(Sender: TObject);
begin
  LoadPrefs;
end;

procedure TPrefWin.RunExternalHexEditBClick(Sender: TObject);
var
  FileName, TestValue: string;
begin
  FileName := TempDir + '~test.bin';
  TestValue := 'This is only a test.' + EOL +
               'Everything seems to be OK.';
  if SaveByteA(ByteAOfStr(TestValue), FileName) then
    ExecFileWith(ExternalHexEditE.Text, FileName)
  else
    ShowMessage('Could not write into file:' + EOL +
                FileName);
end;

procedure TPrefWin.SelectExternalHexEditBClick(Sender: TObject);
begin
  with SelectExternalHexEditOD do begin
    InitialDir := ExtractPath(ExternalHexEditE.Text);
    FileName := ExtractFileName(ExternalHexEditE.Text);
    if Execute and FileExists(FileName) then
      ExternalHexEditE.Text := FileName;
  end;
end;

procedure TPrefWin.ExternalHexEditEChange(Sender: TObject);
begin
  RunExternalHexEditB.Enabled := FileExists(ExternalHexEditE.Text);
  if Assigned(WorkWin) then
    WorkWin.ExternalEditB.Enabled := RunExternalHexEditB.Enabled;
  if Assigned(MainWin) then
    MainWin.ExternalHexEditMI.Enabled := RunExternalHexEditB.Enabled;
end;

procedure TPrefWin.DefaultBClick(Sender: TObject);
begin
  if mrYes=MessageDlg('Do you really want to reset the preferences' + EOL +
   'to their defaults?' + EOL +
   '(This can not be undone.)', mtWarning, [mbYes, mbCancel], 0) then begin
    CopyFile(PChar(PlutoIniFileName), PChar(PlutoIniFileName + '.backup'), False);
    //PrefHost.KeyName :=  'Ini <' + PlutoIniFileName + '.backup>:';
    //PrefHost.Save;
    //PrefHost.KeyName := PlutoUniPath;
    PrefHost.BackUp;
   end;
end;

procedure TPrefWin.RegisterAppCBClick(Sender: TObject);
begin
  with TXRegistry.Create do
    try
      RootKey := HKLM;
      OpenKey('Software\Microsoft\Windows\CurrentVersion\App Paths');
      if RegisterAppCB.Checked then begin
        OpenKey('pluto.exe', True);
        WriteString('', GetFileNew(Application.ExeName));
      end else
        DeleteKey('pluto.exe');
    finally
      Free;
    end;
end;

procedure TPrefWin.SaveBClick(Sender: TObject);
begin
  PrefHost.Save;
end;

procedure TPrefWin.StringPreviewChange(Sender: TObject);
begin
  StringPreviewL.Caption := 'Preview: ' + ValuesU.DataPreviewOfContext(
    RegContext(rdString, ByteAOfStr('%windir%')));
  DataPreviewChange(Self);
end;

procedure TPrefWin.ShowTreeViewLinesCBClick(Sender: TObject);
begin
  with RegTV do begin
    ShowLines := ShowTreeViewLinesCB.Checked;
    ShowButtons := ShowLines;
  end;
  StandardPreviewChange(Sender);
end;

procedure TPrefWin.ShowListViewGridCBClick(Sender: TObject);
begin
  ValueList.GridLines := ShowListViewGridCB.Checked;
end;

procedure TPrefWin.DefaultValueNameEChange(Sender: TObject);
begin
  DefaultValueCaption := DefaultValueNameE.Text;
  if Started then
    TreeWin.RegTVChange(Self, RegTV.Selected);
end;

procedure TPrefWin.LoadPrefs;
begin
  PrefHost.Load;
end;

procedure TPrefWin.UseExtendedModelCBClick(Sender: TObject);
begin
  WorkWin.MultiStringTypeRG.ItemIndex := Integer(UseExtendedModelCB.Checked);
  DataPreviewChange(Sender);
end;

procedure TPrefWin.IntegrationPageShow(Sender: TObject);
begin
  with TXRegistry.Create do
    try
      RootKey := HKLM;
      OpenKey('Software\Microsoft\Windows\CurrentVersion\App Paths\pluto.exe');
      RegisterAppCB.Checked := SameFileName(GetFileNew(ReadString('')),
        GetFileNew(Application.ExeName));
    finally
      Free;
    end;
end;

procedure TPrefWin.GotoPlutoKeyBClick(Sender: TObject);
begin
  MainWin.GotoKey('HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\pluto.exe');
end;

procedure TPrefWin.FormShow(Sender: TObject);
begin
  PrefHost.Load;
end;

procedure TPrefWin.KeysSingleClickCBClick(Sender: TObject);
begin
  TreeWin.CheckRegTVHotTrack;
end;

procedure TPrefWin.ValuesSingleClickCBClick(Sender: TObject);
begin
  ValuesWin.CheckValueListHotTrack;
end;

procedure TPrefWin.QuotersEChange(Sender: TObject);
var
  QBegin, QEnd: string;
begin
  with QuotersE do begin
    if Text = '' then
      QBegin := ''
    else
      QBegin := Text[1];
    if Length(Text) < 2 then
      QEnd := QBegin
    else
      QEnd := Text[2];
  end;

  if (QBegin <> StringQuoterBegin) or (QEnd <> StringQuoterEnd) then begin
    StringQuoterBegin := QBegin;
    StringQuoterEnd := QEnd;
    StringPreviewChange(Self);
  end;
end;

procedure TPrefWin.SplashScreenCBClick(Sender: TObject);
begin
  if Started and Assigned(SplashWin) then
    SplashWin.SplashScreenCB.Checked := SplashScreenCB.Checked;
end;

procedure TPrefWin.SaveBMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Label2.Font.Color := clBrightRed;
  Application.ProcessMessages;
  Sleep(200);
  Label2.Font.Color := clWhite;
end;

end.
unit RegScanner;

interface

uses
  Windows, SysUtils, Dialogs, Classes,
  YTools, YTypes, XReg, Clock;

type
  TRegScanThread = class;

  TRegScanKeyEvent = procedure (Sender: TRegScanThread; const KeyName: string; Key: HKEY; Info: TRegKeyInfo) of object;
  TRegScanValueEvent = procedure (Sender: TRegScanThread; const ValueName: string; Context: TRegContext) of object;

  TRegScanTask = record
    Root: string;
    Key: HKEY;
  end;
  TRegScanTasks = array of TRegScanTask;

  TRegScanThread = class(TThread)
  private
    Keys, KeysOK, Values, ValuesOK: Integer;
    DoScanValues: Boolean;
    FOnKey: TRegScanKeyEvent;
    FOnValue: TRegScanValueEvent;
    FOnFaileKey: TRegScanKeyEvent;
  protected
    procedure ScanKey(Key: HKEY; const KeyName: string = ''); virtual;
    procedure ScanValues(Key: HKEY; Info: TRegKeyInfo); virtual;

  public
    Path: string;
    CurrentTask: TRegScanTask;
    Tasks: TRegScanTasks;
    destructor Destroy; override;
    procedure Execute; override;
    procedure ScanAll;
    function CurrentPath: string;
  published
    constructor CreateIt(PriorityLevel: TThreadPriority;
      DoScanValues: Boolean = True; Tasks: TRegScanTasks = nil);

    property OnKey: TRegScanKeyEvent read FOnKey write FOnKey;
    property OnValue: TRegScanValueEvent read FOnValue write FOnValue;
    property OnFaileKey: TRegScanKeyEvent read FOnFaileKey write FOnFaileKey;
  end;

implementation

{ TRegScanThread }

constructor TRegScanThread.CreateIt(PriorityLevel: TThreadPriority;
  DoScanValues: Boolean = True; Tasks: TRegScanTasks = nil);
begin
  inherited Create(True);
  Priority := PriorityLevel;
  FreeOnTerminate := False;   
  Self.DoScanValues := DoScanValues;
  Self.Tasks := Tasks;
end;

destructor TRegScanThread.Destroy;
begin
  inherited;
end;

procedure TRegScanThread.ScanAll;
var
  i: Integer;
begin
  Keys := 0;
  KeysOK := 0;
  Values := 0;
  ValuesOK := 0;

  for i := 0 to High(Tasks) do begin
    CurrentTask := Tasks[i];
    with CurrentTask do begin
      Inc(Keys);
      ScanKey(Key);
    end;

    if Terminated then Break;
  end;
end;

procedure TRegScanThread.ScanValues(Key: HKEY; Info: TRegKeyInfo);
var
  i: Integer;
  MaxLen, NameLen, Len, Typ: Cardinal;
  p: PChar;
  Buffer: TByteA;

  procedure ScanValue(ValueName: string; Typ: TRegDataType; Data: TByteA);
  begin
    if Assigned(OnValue) then
      OnValue(Self, ValueName, RegContext(Typ, Data));
    Inc(ValuesOK);
  end;

begin
  MaxLen := Info.MaxValueLen + 1; //Include Nullbyte
  SetLength(Buffer, Info.MaxDataLen);
  GetMem(p, MaxLen);

  Inc(Values, Info.NumValues);
  for i := 0 to Info.NumValues-1 do begin
    NameLen := MaxLen;
    Len := Info.MaxDataLen;
    if Success(RegEnumValue(Key, i, p, NameLen, nil, @Typ, Pointer(Buffer),
     @Len)) then
      ScanValue(Copy(p, 0, NameLen), Typ, Copy(Buffer, 0, Len))
    else
      Yield;
  end;
  FreeMem(p, MaxLen);
end;

procedure TRegScanThread.ScanKey(Key: HKEY; const KeyName: string = '');
var
  i: Integer;
  NewHKEY: HKEY;
  Info: TRegKeyInfo;
  l, Len: DWORD;
  p: PChar;
  z: Integer;
begin
  if Terminated then Exit;

  with Info do begin
    if not Success(RegQueryInfoKey(Key, nil, nil, nil, @NumSubKeys,
     @MaxSubKeyLen, nil, @NumValues, @MaxValueLen, @MaxDataLen,
     nil, nil)) then
      Exit;

    if Assigned(OnKey) then
      OnKey(Self, KeyName, Key, Info);
    if DoScanValues and (NumValues > 0) then
      ScanValues(Key, Info);

    if Info.NumSubKeys > 0 then begin
      Inc(Keys, NumSubKeys);

      Len := MaxSubKeyLen + 1;
      GetMem(p, Len);

      for i := 0 to NumSubKeys-1 do begin
        l := Len;
        RegEnumKeyEx(Key, i, p, l, nil, nil, nil, nil);
        if Success(RegOpenKey(Key, p, NewHKEY)) then begin
          z := Length(Path);
          Path := Path + '\' + p;
          ScanKey(NewHKEY, p);
          RegCloseKey(NewHKEY);
          SetLength(Path, z);
        end else
          if Assigned(OnFaileKey) then
            OnFaileKey(Self, p, Key, Info);

        if Terminated then
          Break;
      end;
      FreeMem(p, Len);
    end;
  end;

  Inc(KeysOK);
end;

procedure TRegScanThread.Execute;
var
  Secs: Double;
begin
  with TClock.Create do begin
    ScanAll;
    Secs := SecondsPassed;
    Free;
  end;

  WriteLn('finished.');
  WriteLn(  Format('Keys:   %6d counted (%3d failed)', [Keys, Keys - KeysOK]));
  if DoScanValues then
    WriteLn(Format('Values: %6d counted (%3d failed)', [Values, Values - ValuesOK]));
  WriteLn('t ' + Format('%.2f', [Secs]) + ' seconds');
  if Secs > 0 then
    WriteLn('r ' + Format('%.0f', [Keys / Secs]) + ' k/s');
end;

function TRegScanThread.CurrentPath: string;
begin
  Result := CurrentTask.Root + Path;
end;

end.
unit RegTV;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TRegTV = class(TTreeView)
  private
    { Private-Deklarationen }
  protected
    { Protected-Deklarationen }
  public
    { Public-Deklarationen }
  published
    { Published-Deklarationen }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('pluto', [TRegTV]);
end;

end.
unit Sisyphus;

interface

uses
  Windows, Classes, SysUtils, XReg, YTools, YTypes, Clock;

type
  TSpyValue = class
    Name: string;
    Next: TSpyValue;
    //DIC: TByteA;
    Typ: TXRegDataType;
    Data: TByteA;
    constructor Create(AName: string);
  end;

  TSpyKey = class
  public
    Parent: TSpyKey;
    Name: string;
    Next: TSpyKey;
    Keys: TSpyKey;
    Values: TSpyValue;
    procedure Spy(AHKEY: HKEY);
    function Path: string;
    constructor Create(AParent: TSpyKey; AName: string);
    destructor Destroy; override;
  end;

var
  Reg: TXRegistry;
  HKLMSpyKey, HKUSpyKey: TSpyKey;
  Started: Boolean = False;

implementation

uses
  Plutomain;

procedure AddChange(M: string);
begin
  Yield;
  //AddHint(M);
end;

{ TSpyValue }

constructor TSpyValue.Create(AName: string);
begin
  Name := AName;
  Next := nil;
end;

{ TSpyKey }

constructor TSpyKey.Create(AParent: TSpyKey; AName: string);
begin
  Name := AName;
  Parent := AParent;

  Next := nil;
  Keys := nil;
  Values := nil;
end;

destructor TSpyKey.Destroy;
var
  Value, NextValue: TSpyValue;
  Key, NextKey: TSpyKey;
begin
  Value := Values;
  while Value <> nil do begin
    NextValue := Value.Next;
    Value.Free;
    Value := NextValue;
  end;

  Key := Keys;
  while Key <> nil do begin
    NextKey := Key.Next;
    Key.Free;
    Key := NextKey;
  end;

  inherited;
end;

function TSpyKey.Path: string;
begin
  if Assigned(Parent) then
    Result := Parent.Path + '\'
  else
    Result := 'Reg: ';

  Result := Result + Name;
end;

procedure TSpyKey.Spy(AHKEY: HKEY);
var
  SL: TStringList;

  procedure CompareValues;
  var
    i: Integer;
    Value, LastValue, NewValue, SearchValue: TSpyValue;
  begin
    //OK, this part is a little bit complicate. So I will comment very much.
    //First, two terms are important:
    //<REAL> means the list of values that will be read from the registry now:
    Reg.GetValueNames(SL);
    //So <REAL> is TStringList.

    //<CURRENT> means the image that was saved before.
    //Here, it is a linear list of TSpyValue objects. That means that you can
    //only get X.Next and not X.Prev! However, I use "X.Prev" to simplify
    //some comments.

    //!!! Comparing means: Make <CURRENT> fit <REAL> !!!

    //If <CURRENT> wasn't saved before, it is just empty.

    //!!! There is no difference in comparing and saving in this method !!!

    //Building means: Comparing with an empty image.

    //We go through <REAL> and make <CURRENT> fit it

    //The following rules are important:
    //Value = "The currently interesting value.
    //LastValue = "The value with X.Next = Value" = "Value.Pref"

    LastValue := nil; // := "Values.Prev"
    Value := Values; // := "LastValue.Next"

    //Now compare step by step
    for i := 0 to SL.Count-1 do begin
      if Assigned(Value) and (SL[i] = Value.Name) then begin
        //cV=  Normally (0.9999) everything's the same
        LastValue := Value;
        Value := Value.Next;
      end else begin //Something's different? Yes, the IMPORTANT rest (0.0001))
        //Because the list finally must exactly fit SL, the "SL[i] value" hast
        //to be inserted right here. But first let's look...

        //Maybe it was just moved? So search for it...
        NewValue := nil;
        if Assigned(Value) then begin
          SearchValue := Value;
          while Assigned(SearchValue.Next) do
            if (SearchValue.Next.Name = SL[i]) then begin
              //cV\
              NewValue := SearchValue.Next;
              AddChange('cV\ ' + Path);
              SearchValue.Next := SearchValue.Next.Next;
            Break; end;
        end;

        if not Assigned(NewValue) then begin
          //cV+  No, not found! So it is new...
          NewValue := TSpyValue.Create(SL[i]);
          AddChange('cV+ ' + Path + '\\' + NewValue.Name);
          with NewValue do begin
            Typ := Reg.GetDataType(SL[i]);
            Data := Reg.ReadBin(SL[i]);
          end;
        end;

        //The new object now must be placed after the last value
        if Assigned(LastValue) then begin
          LastValue.Next := NewValue;
        end else begin
          //If it's the first value, we don't have LastValue defined
          //So we have to set the "Root" to it
          Values := NewValue;
        end;
        //Now the rest of <CURRENT> has to be placed after the new value
        NewValue.Next := Value;
        //And LastValue also has to refreshed: It is "Value.Pref" = NewValue!
        LastValue := NewValue;
      end;
    end;

    //Because the whole <CURRENT> before Value is exactly <REAL>, the rest
    //(if there is one) must have been deleted!

    //So first let's ensure that <CURRENT> ends here:
    if Assigned(LastValue) then begin
      LastValue.Next := nil;
    end else begin
      //Another time: <CURRENT> is empty now, so set Values instead
      Values := nil;
    end;

    //Now, the first value that maybe was "cut" off is Value:
    while Assigned(Value) do begin
      //cV- So, here really something HAS been deleted
      LastValue := Value;
      Value := Value.Next;
      AddChange('cV- ' + Path + '\\' + LastValue.Name);
      LastValue.Free;
    end;
  end;

  procedure CompareData;
  var
    Value: TSpyValue;
    Typ: TXRegDataType;
    Data: TByteA;
  begin
    //So, finally <CURRENT> = <REAL>. That means we now can compare the data:
    Value := Values;
    while Assigned(Value) do begin
      Typ := Reg.GetDataType(Value.Name);
      Data := Reg.ReadBin(Value.Name);
      if Typ <> Value.Typ then begin
        //cT#
        AddChange('cT# ' + Path + '\\' + Value.Name);
        Value.Typ := Typ;
      end;
      if not SameByteA(Data, Value.Data) then begin
        //cD#
        AddChange('cD# ' + Path + '\\' + Value.Name);
        Value.Data := Data;
      end;

      Value := Value.Next;
    end;
  end;

  procedure CompareKeys;
  var
    i: Integer;
    Key, LastKey, NewKey, SearchKey: TSpyKey;
    NewHKEY: HKEY;
  begin
    //OK, this part is a little bit complicate. So I will comment very much.
    //First, two terms are important:
    //<REAL> means the list of keys that will be read from the registry now:
    Reg.GetKeyNames(SL);
    //So <REAL> is TStringList.

    //<CURRENT> means the image that was saved before.
    //Here, it is a linear list of TSpyKey objects. That means that you can
    //only get X.Next and not X.Prev! However, I use "X.Prev" to simplify
    //some comments.

    //!!! Comparing means: Make <CURRENT> fit <REAL> !!!

    //If <CURRENT> wasn't saved before, it is just empty.

    //!!! There is no difference in comparing and saving in this method !!!

    //Building means: Comparing with an empty image.

    //We go through <REAL> and make <CURRENT> fit it

    //The following rules are important:
    //Key = "The currently interesting key.
    //LastKey = "The key with X.Next = Key" = "Key.Pref"

    LastKey := nil; // := "Keys.Prev"
    Key := Keys; // := "LastKey.Next"

    //Now compare step by step
    for i := 0 to SL.Count-1 do begin
      if Assigned(Key) and (SL[i] = Key.Name) then begin
        //cK=  Normally (0.9999) everything's the same
        RegOpenKey(AHKEY, PChar(SL[i]), NewHKEY);
        Key.Spy(NewHKEY);
        LastKey := Key;
        Key := Key.Next;
      end else begin //Something's different? Yes, the IMPORTANT rest (0.0001))
        //Because the list finally must exactly fit SL, the "SL[i] key" hast
        //to be inserted right here. But first let's look...

        //Maybe it was just moved? So search for it...
        NewKey := nil;
        if Assigned(Key) then begin
          SearchKey := Key;
          while Assigned(SearchKey.Next) do
            if (SearchKey.Next.Name = SL[i]) then begin
              //cK\
              NewKey := SearchKey.Next;
              AddChange('cK\ ' + Path);
              SearchKey.Next := SearchKey.Next.Next;
            Break; end;
        end;

        if not Assigned(NewKey) then begin
          //cK+  No, not found! So it is new...
          NewKey := TSpyKey.Create(Self, SL[i]);
          AddChange('cK+ ' + Path + '\' + NewKey.Name);

          RegOpenKey(AHKEY, PChar(SL[i]), NewHKEY);
          NewKey.Spy(NewHKEY);
        end;

        //The new object now must be placed after the last key
        if Assigned(LastKey) then begin
          LastKey.Next := NewKey;
        end else begin
          //If it's the first key, we don't have LastKey defined
          //So we have to set the "Root" to it
          Keys := NewKey;
        end;
        //Now the rest of <CURRENT> has to be placed after the new key
        NewKey.Next := Key;
        //And LastKey also has to refreshed: It is "Key.Pref" = NewKey!
        LastKey := NewKey;
      end;
    end;

    //Because the whole <CURRENT> before Key is exactly <REAL>, the rest
    //(if there is one) must have been deleted!

    //So first let's ensure that <CURRENT> ends here:
    if Assigned(LastKey) then begin
      LastKey.Next := nil;
    end else begin
      //Another time: <CURRENT> is empty now, so set Keys instead
      Keys := nil;
    end;

    //Now, the first key that maybe was "cut" off is Key:
    while Assigned(Key) do begin
      //cV- So, here really something HAS been deleted
      LastKey := Key;
      Key := Key.Next;
      AddChange('cK- ' + Path + '\' + LastKey.Name);
      LastKey.Free;
    end;
  end;


begin
  SL := TStringList.Create;

  try
    Reg.CurrentKey := AHKEY;

    CompareValues;

    CompareData;

    CompareKeys;

  finally
    RegCloseKey(AHKEY);
  end;

  SL.Free;
end;

initialization
  Reg := TXRegistry.Create;
  HKLMSpyKey := TSpyKey.Create(nil, 'HKEY_LOCAL_MACHINE');
  HKUSpyKey := TSpyKey.Create(nil, 'HKEY_USERS');

finalization
  Reg.Free;
  HKLMSpyKey.Free;
  HKUSpyKey.Free;

end.
unit SisyphusTH;

interface

uses
  Windows, Classes, StdCtrls, Dialogs, SysUtils, XReg, YTools, YTypes, Clock,
  ComCtrls, PlutoConst, UniKey, CompEx;

const
  SisyVersion = '1.2 b3';
  StatusPoints = 25;

type
  TSisyChangeType = (cNone, cError,
                     cKeyPlus, cKeyMinus,
                     cValuePlus, cValueMinus,
                     cContextChange);

const
  SisyChangeStrings: array[TSisyChangeType] of string =
                     ('?', 'Error',
                      'cK+', 'cK-',
                      'cV+', 'cV-',
                      'cC');

type
  TSpyValue = class
    Name: string;
    Next: TSpyValue;
    Context: TRegContext;
    constructor Create(const Name: string; Context: TRegContext);
  end;

  TSisyThread = class;

  TSpyKey = class
  public
    Parent: TSpyKey;
    Name: string;
    Next: TSpyKey;
    Keys: TSpyKey;
    Values: TSpyValue;
    procedure Spy(AHKEY: HKEY; Sisy: TSisyThread);
    function Path: string;
    constructor Create(AParent: TSpyKey; AName: string);
    destructor Destroy; override;
  end;

  TSisyChange = class
  public
    Typ: TSisyChangeType;
    Path: string;
    Old, New: TRegContext;
    constructor Create(ATyp: TSisyChangeType; const APath: string;
      AOldContext: TRegContext; ANewContext: TRegContext);
    procedure ReportToPluto;
  end;

  TSisyChangeEvent = procedure (Sender: TSisyThread; Change: TSisyChange) of object;
  TSisyThread = class(TThread)
  private
    Reg: TXRegistry;
    Key: TSpyKey;
    KeyHKEY: HKEY;
    CurrentChange: TSisyChange;
    FOnChange: TSisyChangeEvent;
    FOnSpecialChanges: array[TSisyChangeType] of TSisyChangeEvent;
    procedure FreeKey;
    procedure IncKeyCount;
    procedure IncKeyIndex;
    function GetSpecialChange(ChangeType: TSisyChangeType): TSisyChangeEvent;
    procedure SetSpecialChange(ChangeType: TSisyChangeType;
      const Value: TSisyChangeEvent);
  protected
    procedure AddValueChange(Typ: TSisyChangeType; const Path: string;
      Old, New: TRegContext);
    procedure AddKeyChange(Typ: TSisyChangeType; const Path: string);
    procedure Execute; override;
    procedure ShowInfo;
    procedure NotifyChange;
    procedure ReportCurrentChange;
  public
    CurrentSpyKey: TSpyKey;
    StatusLabel: TLabel;
    Name: string;
    Started: Boolean;
    DoReport: Boolean;
    SecsPerRound: Double;
    InfoForShow: string;
    OnStarted: TNotifyEvent;
    KeyCount: Integer;
    PrevKeyCount: Integer;
    KeyIndex: Integer;
    TheClock: TClock;
    Uni: TUniKey;
    MaxValueCountToScan, MaxKeyCountToScan, MaxDataLenToScan: Cardinal;
    constructor CreateIt(const AName, AKeyName: string; AHKEY: HKEY;
      ALabel: TLabel; AUniKey: TUniKey);
    destructor Destroy; override;

    property OnChange: TSisyChangeEvent read FOnChange write FOnChange;
    property OnSpecialChange[ChangeType: TSisyChangeType]: TSisyChangeEvent
      read GetSpecialChange write SetSpecialChange;
  end;

  TSisyList = class(TList)
  protected
    function GetSisy(Index: Integer): TSisyThread;
    procedure PutSisy(Index: Integer; Sisy: TSisyThread);
  public
    procedure Suspend;
    procedure Resume;
    property Items[Index: Integer]: TSisyThread read GetSisy write PutSisy; default;
  end;

procedure SetSisyChangeState(Node: TTreeNode; Active: Boolean);
function SisyChangeActivated(Node: TTreeNode): Boolean;

var
  SisyFilter: TStringList;

implementation

uses plutomain, workU, ValuesU;

procedure SetSisyChangeState(Node: TTreeNode; Active: Boolean);
begin
  Node.Data := Pointer(not Active);
end;

function SisyChangeActivated(Node: TTreeNode): Boolean;
begin
  Result := Node.Data = Pointer(False);
end;

{ TSisyThread }

constructor TSisyThread.CreateIt(const AName, AKeyName: string;
  AHKEY: HKEY; ALabel: TLabel; AUniKey: TUniKey);
begin
  inherited Create(True);      // Create thread suspended

  Started := False;
  DoReport := True;
  KeyCount := 0;
  FreeOnTerminate := False;     // Thread frees itself not when terminated

  KeyHKEY := AHKEY;
  Name := AName;
  StatusLabel := ALabel;
  StatusLabel.Caption := 'Zzzzzzz...';

  Reg := TXRegistry.Create;
  TheClock := TClock.Create;

  Uni := AUniKey.GetKey(Name);
  Priority := TThreadPriority(Uni.ReadInteger('Priority', Integer(tpLowest)));
  PrevKeyCount := Uni.ReadInteger('KeyCount', 0);

  MaxKeyCountToScan := Cardinal(Uni.ReadInteger('ScanTuner: MaxKeys', -1));
  MaxValueCountToScan := Cardinal(Uni.ReadInteger('ScanTuner: MaxValues', -1));
  MaxDataLenToScan := Cardinal(Uni.ReadInteger('ScanTuner: MaxDataLen', -1));

  Key := TSpyKey.Create(nil, AKeyName);
end;

procedure TSisyThread.FreeKey;
begin
  Reg.Free;
  TheClock.Free;
  Key.Free;
end;

destructor TSisyThread.Destroy;
begin
  Synchronize(FreeKey);
  inherited;
end;

procedure TSisyThread.Execute;
begin
  InfoForShow := Name + ' initializing...';
  Synchronize(ShowInfo);

  TheClock.Restart;
  Started := False;
  while not Terminated do
    try
      KeyIndex := 0;

     { ===================== }
      Key.Spy(KeyHKEY, Self);
     { ===================== }

      if Terminated then
        Continue; //= Exit

      SecsPerRound := TheClock.SecondsPassed;
      TheClock.Restart;
      if not Started then begin
        Started := True;
        Uni.WriteInteger('KeyCount', KeyCount);
        if Assigned(OnStarted) then
          OnStarted(Self);
      end;
    except
      ShowMessage('Error in Sisyphus');
    end;
end;

procedure TSisyThread.AddValueChange(Typ: TSisyChangeType; const Path: string;
  Old, New: TRegContext);

  procedure TryNotify(Event: TSisyCHangeEvent);
  begin

  end;

begin
  if not (Started and DoReport) then
    Exit;

  CurrentChange := TSisyChange.Create(Typ, Path, Old, New);
  Synchronize(ReportCurrentChange);
  Synchronize(NotifyChange);

//  CurrentChange.Free; //this makes Pluto itself
end;

procedure TSisyThread.AddKeyChange(Typ: TSisyChangeType; const Path: string);
begin
  AddValueChange(Typ, Path, ZeroRegContext, ZeroRegContext);
end;

procedure TSisyThread.ShowInfo;
begin
  if Assigned(StatusLabel) then
    StatusLabel.Caption := InfoForShow;
end;

procedure TSisyThread.ReportCurrentChange;
begin
  if Assigned(CurrentChange) then
    CurrentChange.ReportToPluto;
end;

procedure TSisyThread.IncKeyCount;
var
  c: Integer;
begin
  if Started then
    Exit;

  Inc(KeyCount);

  if (KeyCount and $1FF) = 0 then begin
    if KeyCount > PrevKeyCount then
      PrevKeyCount := KeyCount;

    c := 0;
    if PrevkeyCount > 0 then
      c := Round((KeyCount * StatusPoints) / PrevKeyCount);
    InfoForShow := '|' + MulStr('.', c) + MulStr(' ', StatusPoints - c) + '|' +
      Format(' (%0.1f s) %d/%d k ',
        [TheClock.SecondsPassed, KeyCount, PrevKeyCount]);

    Synchronize(ShowInfo);
  end;
end;

procedure TSisyThread.IncKeyIndex;
var
  c: Integer;
begin
  if not Started then
    Exit;

  Inc(KeyIndex);

  if ((KeyIndex and $1FF) = 0) and (KeyCount > 0) then begin
    if KeyIndex > KeyCount then
      KeyCount := KeyIndex;

    c := 0;
    if KeyCount > 0 then
      c := Round((KeyIndex * StatusPoints) / KeyCount);

    InfoForShow := '|' + MulStr(':', c) + MulStr('.', StatusPoints - c) + '|' +
      Format(' (%0.1f s) %d/%d k ', [SecsPerRound, KeyIndex, KeyCount]);

    Synchronize(ShowInfo);
  end;
end;

function TSisyThread.GetSpecialChange(ChangeType: TSisyChangeType):
  TSisyChangeEvent;
begin
  Result := FOnSpecialChanges[ChangeType];
end;

procedure TSisyThread.SetSpecialChange(ChangeType: TSisyChangeType;
  const Value: TSisyChangeEvent);
begin
  FOnSpecialChanges[ChangeType] := Value;
end;

procedure TSisyThread.NotifyChange;
var
  Event: TSisyChangeEvent;
begin
  Event := FOnSpecialChanges[CurrentChange.Typ];
  if Assigned(Event) then
    Event(Self, CurrentChange);

  if Assigned(FOnChange) then
    FOnChange(Self, CurrentChange);
end;

{ TSpyValue }

constructor TSpyValue.Create(const Name: string; Context: TRegContext);
begin
  Self.Name := Name;
  Next := nil;
  Self.Context := Context;
end;

{ TSpyKey }

constructor TSpyKey.Create(AParent: TSpyKey; AName: string);
begin
  Name := AName;
  Parent := AParent;

  Next := nil;
  Keys := nil;
  Values := nil;
end;

destructor TSpyKey.Destroy;
var
  Value, NextValue: TSpyValue;
  Key, NextKey: TSpyKey;
begin
  Value := Values;
  while Assigned(Value) do begin
    NextValue := Value.Next;
    Value.Free;
    Value := NextValue;
  end;

  Key := Keys;
  while Assigned(Key) do begin
    NextKey := Key.Next;
    Key.Free;
    Key := NextKey;
  end;

  inherited;
end;

function TSpyKey.Path: string;
begin
  if Assigned(Parent) then
    Result := Parent.Path + '\'
  else
    Result := '';

  Result := Result + Name;
end;

procedure TSpyKey.Spy(AHKEY: HKEY; Sisy: TSisyThread);
var
  SL: TStringList;
  LastKey: TSpyKey;

  procedure CompareValues;
  var
    i: Integer;
    Value, LastValue, NewValue, SearchValue, SearchValue_Prev: TSpyValue;
  begin
    //OK, this part is a little bit complicate. So I will comment very much.
    //First, two terms are important:
    //<REAL> means the list of values that will be read from the registry now:
    Sisy.Reg.GetValueNames(SL);
    if Cardinal(SL.Count) > Sisy.MaxValueCountToScan then
      Exit;
    //So <REAL> is TStringList.

    //<CURRENT> means the image that was saved before.
    //Here, it is a linear list of TSpyValue objects. That means that you can
    //only get X.Next and not X.Prev! However, I use "X.Prev" to simplify
    //some comments.

    //!!! Comparing means: Make <CURRENT> fit <REAL> !!!

    //If <CURRENT> wasn't saved before, it is just empty.

    //!!! There is no difference in comparing and saving in this method !!!

    //Building means: Comparing with an empty image.

    //We go through <REAL> and make <CURRENT> fit it

    //The following rules are important:
    //Value = "The currently interesting value.
    //LastValue = "The value with X.Next = Value" = "Value.Pref"

    LastValue := nil; // := "Values.Prev"
    Value := Values; // := "LastValue.Next"

    //Now compare step by step
    for i := 0 to SL.Count-1 do begin
      if Assigned(Value) and (SL[i] = Value.Name) then begin
        //cV=  Normally (0.9999) everything's the same
        LastValue := Value;
        Value := Value.Next;
      end else begin //Something's different? Yes, the IMPORTANT rest (0.0001))
        //Because the list finally must exactly fit SL, the "SL[i] value" hast
        //to be inserted right here. But first let's look...

        //Maybe it was just moved? So search for it...
        NewValue := nil;
        if Assigned(Value) then begin
          SearchValue_Prev := Value;
          SearchValue := Value.Next;
          while Assigned(SearchValue) do begin
            if SearchValue.Name = SL[i] then begin //we found our moved value
              SearchValue_Prev.Next := SearchValue.Next; //delete it from <CURRENT>
              NewValue := SearchValue; //save that we found it
            Break end;
            SearchValue_Prev := SearchValue;
            SearchValue := SearchValue.Next;
          end;
        end;

        if not Assigned(NewValue) then begin
          //cV+  No, not found! So it is new...
          NewValue := TSpyValue.Create(SL[i], Sisy.Reg.ReadContext(SL[i]));
          { ================ cV+ ================ }
          if Sisy.Started and Sisy.Reg.ValueReallyExists(SL[i]) then
            Sisy.AddValueChange(cValuePlus, Path + '\\' + NewValue.Name,
              ZeroRegContext, NewValue.Context);
        end;

        //The new object now must be placed after the last value
        if Assigned(LastValue) then
          LastValue.Next := NewValue
        else
          //If it's the first value, we don't have LastValue defined
          //So we have to set the "Root" to it
          Values := NewValue;

        //Now the rest of <CURRENT> has to be placed after the new value
        NewValue.Next := Value;
        //And LastValue also has to refreshed: It is "Value.Pref" = NewValue!
        LastValue := NewValue;
      end;
    end;

    //Because the whole <CURRENT> before Value is exactly <REAL>, the rest
    //(if there is one) must have been deleted!

    //So first let's ensure that <CURRENT> ends here:
    if Assigned(LastValue) then
      LastValue.Next := nil
    else
      //Another time: <CURRENT> is empty now, so set Values instead
      Values := nil;

    //Now, the first value that maybe was "cut" off is Value:
    while Assigned(Value) do begin
      //cV- So, here really something HAS been deleted
      LastValue := Value;
      Value := Value.Next;
      { ================ cV- ================ }
      if Sisy.Started and not Sisy.Reg.ValueReallyExists(LastValue.Name) then
        Sisy.AddValueChange(cValueMinus, Path + '\\' + LastValue.Name,
          LastValue.Context, ZeroRegContext);
      LastValue.Free;
    end;
  end;

  procedure CompareData;
  var
    Value: TSpyValue;
    Context: TRegContext;
    Size: Cardinal;
  begin
    Context := ZeroRegContext; //Initialize
    //So, finally <CURRENT> = <REAL>. That means we now can compare the data:
    Value := Values;
    while Assigned(Value) and not Sisy.Terminated do begin
      Size := Sisy.Reg.GetDataSize(Value.Name);
      if (Size = Cardinal(-1)) or
       (Size <= Sisy.MaxDataLenToScan) then begin
        Context := Sisy.Reg.ReadContext(Value.Name);
        if not SameContext(Context, Value.Context) then begin
          { ================ cC ================ }
          Sisy.AddValueChange(cContextChange, Path + '\\' + Value.Name,
            Value.Context, Context);
          Value.Context := Context;
        end;
      end;

      Value := Value.Next;
    end;
  end;

  procedure CompareKeys;
  var
    i: Integer;
    Key, LastKey, NewKey, SearchKey, SearchKey_Prev: TSpyKey;
    SavedDoReport: Boolean;
    NewHKEY: HKEY;
  begin
    //OK, this part is a little bit complicate. So I will comment very much.
    //First, two terms are important:
    //<REAL> means the list of keys that will be read from the registry now:

    Sisy.Reg.GetKeyNames(SL);
    if Cardinal(SL.Count) > Sisy.MaxKeyCountToScan then
      Exit;
    //So <REAL> is TStringList.

    //<CURRENT> means the image that was saved before.
    //Here, it is a linear list of TSpyKey objects. That means that you can
    //only get X.Next and not X.Prev! However, I use "X.Prev" to simplify
    //some comments.

    //!!! Comparing means: Make <CURRENT> fit <REAL> !!!

    //If <CURRENT> wasn't saved before, it is just empty.

    //!!! There is no difference in comparing and saving in this method !!!

    //Building means: Comparing with an empty image.

    //We go through <REAL> and make <CURRENT> fit it

    //The following rules are important:
    //Key = "The currently interesting key.
    //LastKey = "The key with X.Next = Key" = "Key.Pref"

    LastKey := nil; // := "Keys.Prev"
    Key := Keys; // := "LastKey.Next"

    //Now compare step by step
    for i := 0 to SL.Count-1 do begin
      if Assigned(Key) and (SL[i] = Key.Name) then begin
        //cK=  Normally (0.9999) everything's the same
        if Success(RegOpenKey(AHKEY, PChar(SL[i]), NewHKEY)) then
          try
            Key.Spy(NewHKEY, Sisy);
          finally
            RegCloseKey(NewHKEY);
          end;
        if Sisy.Terminated then
          Exit;

        LastKey := Key;
        Key := Key.Next;
      end else begin //Something's different? Yes, the IMPORTANT rest (0.0001))
        //Because the list finally must exactly fit SL, the "SL[i] key" has
        //to be inserted right here. But first let's look...

        //Maybe it was just moved? So search for it...
        NewKey := nil;
        if Assigned(Key) then begin
          SearchKey_Prev := Key;
          SearchKey := Key.Next;
          while Assigned(SearchKey) do begin
            if SearchKey.Name = SL[i] then begin //we found our moved key
              SearchKey_Prev.Next := SearchKey.Next; //delete it from <CURRENT>
              NewKey := SearchKey; //save that we found it
            Break end;
            SearchKey_Prev := SearchKey;
            SearchKey := SearchKey.Next;
          end;
        end;

        if not Assigned(NewKey) then begin //if we didn't find it
          //cK+ No, not found! So it is new...
          NewKey := TSpyKey.Create(Self, SL[i]);
          Sisy.IncKeyCount;
          Sisy.Reg.CurrentKey := AHKEY;
          { ================ cK+ ================ }
          if Sisy.Started and Sisy.Reg.KeyExists(SL[i]) then
            Sisy.AddKeyChange(cKeyPlus, Path + '\' + NewKey.Name);

          SavedDoReport := Sisy.DoReport;
          if Success(RegOpenKey(AHKEY, PChar(SL[i]), NewHKEY)) then
            try
              Sisy.DoReport := False;
              NewKey.Spy(NewHKEY, Sisy); //<-- recursion itself
            finally
              RegCloseKey(NewHKEY);
              Sisy.DoReport := SavedDoReport;
            end;

          if Sisy.Terminated then
            Exit;
        end;

        //The new key now must be placed after the last key
        if Assigned(LastKey) then
          LastKey.Next := NewKey
        else
          //If it's the first key, we don't have LastKey defined
          //So we have to set the "Root" to it
          Keys := NewKey;

        //Now the rest of <CURRENT> has to be placed after the new key
        NewKey.Next := Key;
        //And LastKey also has to refreshed: It is "Key.Pref" = NewKey!
        LastKey := NewKey;
      end;
    end;

    //Because the whole <CURRENT> before Key is exactly <REAL>, the rest
    //(if there is one) must have been deleted!

    //So first let's ensure that <CURRENT> ends here:
    if Assigned(LastKey) then
      LastKey.Next := nil
    else
      //Another time: <CURRENT> is empty now, so set Keys instead
      Keys := nil;

    //Now, the first key that maybe was "cut" off is Key:
    while Assigned(Key) do begin
      //cV- So, here really something HAS been deleted
      LastKey := Key;
      Key := Key.Next;
      Sisy.Reg.CurrentKey := AHKEY;
      { ================ cK- ================ }
      if Sisy.Started and not Sisy.Reg.KeyExists(LastKey.Name) then
        Sisy.AddKeyChange(cKeyMinus, Path + '\' + LastKey.Name);
      LastKey.Free;
    end;
  end;


begin
  if Sisy.Terminated or (AHKEY = 0) then
    Exit;
  LastKey := Sisy.CurrentSpyKey;
  Sisy.CurrentSpyKey := Self;

  Sisy.IncKeyIndex;

  SL := TStringList.Create;
  try
    Sisy.Reg.CurrentKey := AHKEY;
    CompareValues;
    if Sisy.Started then CompareData;
    CompareKeys;
  finally
    Sisy.Reg.CurrentKey := 0;
    SL.Free;
    Sisy.CurrentSpyKey := LastKey;
  end;
end;

{ TSisyChange }

constructor TSisyChange.Create(ATyp: TSisyChangeType; const APath: string;
  AOldContext: TRegContext; ANewContext: TRegContext);
begin
  inherited Create;
  Typ := ATyp;
  Path := APath;
  Old := AOldContext;
  New := ANewContext;
end;

procedure TSisyChange.ReportToPluto;
var
  Node, RootNode: TTreeNode;
  Root, SubPath: string;
  NewNode: Boolean;
  i: Integer;

  function IconOfSisyChangeType(Typ: TSisyChangeType): Integer;
  begin
    Result := -1;
    case Typ of
      //cNone, cError: Result := -1;
      cKeyPlus..cContextChange: Result := Integer(Typ) - 2;
    end;
  end;

  function FindNode(Text: string): TTreeNode;
  begin
    Result := WorkWin.SisyTV.Items.GetFirstNode;
    while Assigned(Result) do begin
      if SameText(Result.Text, Text) then
        Exit;
      Result := Result.GetNextSibling;
    end;
  end;

begin
  if not WorkWin.SisyListCB.Checked then
    Exit;

  if Typ in [cContextChange, cValueMinus, cValuePlus] then begin
    Root := ExRegFullKey(Path);
    SubPath := ExRegValue(Path);
  end else begin
    Root := UntilLastChar(ExRegFullKey(Path), '\');
    SubPath := FromLastChar(ExRegFullKey(Path), '\');
  end;

  with WorkWin do
    for i := 0 to SisyFilter.Count-1 do begin
      if TextAtPos(Root, 1, SisyFilter[i]) then begin
        //show that it's working
        with FilterChangesB do begin
          Caption := 'Filter..!';
          Repaint;
          Caption := 'Filter...';
          Repaint;
        end;
      Exit; end;
    end;

  with WorkWin.SisyTV.Items do begin
    BeginUpdate;
    try
      RootNode := FindNode(Root);
      NewNode := not Assigned(RootNode);
      if NewNode then begin
        RootNode := AddChild(nil, Root);
        RootNode.ImageIndex := iconGroup;
      end else if not SisyChangeActivated(RootNode) then begin
        EndUpdate;
      Exit end;

      Node := AddChildObject(RootNode, SubPath, Self);
      Node.ImageIndex := IconOfSisyChangeType(Typ);
      if Typ = cContextChange then begin
        AddChild(Node, DataPreviewOfContext(Old)).ImageIndex := iconOldContext;
        AddChild(Node, DataPreviewOfContext(New)).ImageIndex := iconNewContext;
      end;
    finally
      EndUpdate;
    end;
  end;

  if NewNode and WorkWin.SisyExpandGroupsCB.Checked then
    RootNode.Expand(False);

  if not RootNode.Expanded then
    RootNode.ImageIndex := iconGroupBlinking;
end;

{ TSisyList }

function TSisyList.GetSisy(Index: Integer): TSisyThread;
begin
  Result := Get(Index);
end;

procedure TSisyList.PutSisy(Index: Integer; Sisy: TSisyThread);
begin
  Put(Index, Sisy);
end;

procedure TSisyList.Resume;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    Items[i].Resume;
end;

procedure TSisyList.Suspend;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    Items[i].Resume;
end;

initialization
  SisyFilter := TStringList.Create;
  SisyFilter.Sorted := True;
  SisyFilter.Duplicates := dupIgnore;

finalization
  SisyFilter.Free;

end.
unit splash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ImgList, YTools, IniFiles, LinkLabel, PrefTools,
  PlutoConst;

type
  TSplashWin = class(TForm)
    Image1: TImage;
    StartB: TButton;
    SplashScreenCB: TPrefCheckBox;
    LinkLabel1: TLinkLabel;
    LinkLabel2: TLinkLabel;
    LogoL: TLabel;
    procedure StartBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SplashScreenCBClick(Sender: TObject);
  end;

var
  SplashWin: TSplashWin;

implementation

uses plutomain, TreeU, WorkU, PrefU;

{$R *.DFM}

procedure TSplashWin.StartBClick(Sender: TObject);
begin
  Close;
end;

procedure TSplashWin.FormShow(Sender: TObject);
const
  Messages: array[0..12] of string = ('Let''s see...',
                                      'Ready',
                                      'Hello World!',
                                      'Start',
                                      'OK',
                                      'Pluto!',
                                      'Go Go Go',
                                      'Everything''s OK',
                                      'Yes!',
                                      'God save the Queen',
                                      'Oh yeah',
                                      'Yabadabadoo!',
                                      'Don''t worry, be happy!'
                                      );
var
  ImageFile: string;
begin
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;

  StartB.Caption := Messages[Random(Length(Messages))];
  SplashWin.SplashScreenCB.Load;

  Caption := 'cYcnus.Pluto ' + Version + ' says ' + MainWin.Greeting;

  try
    ImageFile := PlutoDir + 'logo deluxe.bmp';
    if FileEx(ImageFile) then begin
      with Image1.Picture do
        if Graphic = nil then
          LoadFromFile(ImageFile);
      if not Switch('MurphyMode') then
        LogoL.Visible := False;
      Exit;
    end;

    ImageFile := PlutoDir + 'logo.bmp';
    if FileEx(ImageFile) then begin
      with Image1.Picture do
        if Graphic = nil then
          LoadFromFile(ImageFile);
    end;
  except
    ShowMessage('Could not load Splash Screen image!');
  end;
end;

procedure TSplashWin.FormCreate(Sender: TObject);
begin
  Hide;
  Randomize;
end;

procedure TSplashWin.FormHide(Sender: TObject);
begin
  //Image1.Picture.Bitmap.FreeImage;
end;

procedure TSplashWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TSplashWin.SplashScreenCBClick(Sender: TObject);
begin
  if Started then
    PrefWin.SplashScreenCB.Checked := SplashScreenCB.Checked;
end;

end.
unit SpyTH;

interface

uses
  Classes, Windows, Dialogs, ComCtrls, CompEx, SysUtils, YTools, clock,
  plutoconst, StdCtrls, forms, XReg, stringcomp;

type
  TChildren = array of TTreeNode;

  TRegSpyThread = class(TThread)
  private
    Reg: TXRegistry;
    CurNode: TTreeNode;
    Dead: Boolean;
    Dif: TSLComp;
    CurChildren: TChildren;
  protected
    procedure Execute; override;

    procedure SaveCheckNode;
    procedure SaveGetDif;
    procedure SaveDeleteDead;
    procedure SaveGetChildren;
    procedure SaveAddNew;
  public
    Restart: Boolean;
    Mess: string;
    Delay: Integer;
    function Alive(Node: TTreeNode): Boolean;
    procedure Spy;
    procedure Reload(Node: TTreeNode);
    procedure ReloadValues;
    procedure AddTrace(Trace: string);
    constructor CreateIt(PriorityLevel: TThreadPriority);
    destructor Destroy; override;
  end;

implementation

uses plutomain, TreeU, WorkU, ValuesU;

{ TRegSpyThread }

constructor TRegSpyThread.CreateIt(PriorityLevel: TThreadPriority);
begin
  inherited Create(True);      // Create thread suspended
  Priority := PriorityLevel;   // Set Priority Level
  FreeOnTerminate := False;     // Thread frees itself when terminated
  Reg := TXRegistry.Create;
  Delay := 100;
end;

procedure TRegSpyThread.Execute;
begin
  while not Terminated do begin
    Restart := False;
    try
      if not Terminated then
        Sleep(Delay);
      if not Terminated then
        Spy;
    except end;
  end;
end;

function TRegSpyThread.Alive(Node: TTreeNode): Boolean;
begin
  Result := False;

  if Restart then
    Exit;

  if Terminated then
    Exit;

  if Assigned(Node) then
    try
      if (Node.Text = '') then
        Exit;

      if not Assigned(Node) then
        Exit;

      Result := True;
    except
      Exit;
    end;
end;

procedure TRegSpyThread.SaveCheckNode;
begin
  Dead := not Alive(CurNode);
  if Dead then
    Exit;

  CheckNode(CurNode, False);
end;

procedure TRegSpyThread.SaveGetDif;
var
  Real, Cur: TStringList;
begin
  Dead := not Alive(CurNode);
  if Dead then
    Exit;

  dif := nil;
  
  if not CurNode.Expanded then begin
    Dead := True;
  Exit; end;

  if not OpenNodeOK(Reg, CurNode) then
    Exit;

  Real := TStringList.Create;

  Reg.GetKeyNames(Real);
  Reg.CloseKey;

  Cur := GetChildNames(CurNode);

  if (Cur.Count = 0) and (Real.Count = 0) then
    Dead := True;

  dif := TSLComp.Create(Cur, Real, False);

  Cur.Free;
  Real.Free;
end;

procedure TRegSpyThread.SaveDeleteDead;
var
  TN: TTreeNode;
  i: Integer;
begin
  Dead := not Alive(CurNode);
  if Dead then
    Exit;

  if not Assigned(dif) or not Assigned(dif.OnlyA) then
    Exit;

  if CurNode.Expanded then
    for i := 0 to dif.OnlyA.Count-1 do begin
      TN := FindNode(CurNode, dif.OnlyA[i]);
      if Assigned(TN) then begin
        RegTV.Selected := GetNextBest(TN);
        TN.Delete;
        AddTrace('Key deleted: ' + dif.OnlyA[i]);
      end;
    end
  else
    Exit;
end;

procedure TRegSpyThread.SaveGetChildren;
var
  i: Integer;
  TN: TTreeNode;
begin
  Dead := not Alive(CurNode);
  if Dead then
    Exit;

  CurChildren := nil;
  SetLength(CurChildren, CurNode.Count);

  i := 0;
  TN := CurNode.GetFirstChild;
  while Assigned(TN) do begin
    if i <= High(CurChildren) then
      CurChildren[i] := TN
    else
      ShowMessage('Error: Too much children');
    Inc(i);
    TN := CurNode.GetNextChild(TN)
  end;
end;

procedure TRegSpyThread.SaveAddNew;
var
  i: Integer;
begin
  Dead := not Alive(CurNode);
  if Dead then
    Exit;

  if not Assigned(Dif) or not Assigned(Dif.OnlyB) or (Dif.OnlyB.Count = 0) then
    Exit;

  for i := 0 to Dif.OnlyB.Count-1 do begin  //Erstellt/hinbenannt
    RegTV.Items.AddChild(CurNode, Dif.OnlyB[i]);
    AddTrace('New Key: ' + dif.OnlyB[i]);
    MainWin.StatusBarUpdate;
    //AddHint('Neuer Schlüssel: ' + CurNode.Text + '\' + Dif.OnlyB[i]);
  end;
end;

procedure TRegSpyThread.Reload(Node: TTreeNode);
var
  i: Integer;
  TN: TTreeNode;
  zCurNode: TTreeNode;
  MyChildren: TChildren;
begin
  if Terminated or Restart then
    Exit;

  CurNode := Node;

  zCurNode := CurNode;
  try
    //Mess := 'SaveCheckNode';
    Synchronize(SaveCheckNode);
    if Dead or Terminated then
      Exit;

    //Mess := 'SaveGetDif';
    Synchronize(SaveGetDif);
    if Dead or Terminated then
      Exit;

    //Mess := 'SaveDeleteDead';
    Synchronize(SaveDeleteDead);
    if Dead or Terminated then
      Exit;

    //Mess := 'SaveGetChildren';
    Synchronize(SaveGetChildren);
    if Dead or Terminated then
      Exit;

    //Mess := 'SaveGetChildren';
    Synchronize(SaveAddNew);
    if Dead or Terminated then
      Exit;

    Dif.Free;

    //Mess := 'MyChildren';
    SetLength(MyChildren, Length(CurChildren));
    for i := 0 to High(MyChildren) do
      MyChildren[i] := CurChildren[i];

    for i := 0 to High(MyChildren) do begin
      TN := MyChildren[i];
      if Alive(TN) then
        //if TN.Expanded then
        //if NodeVisible(TN) then
          Reload(TN);
        //else
         //Break;
      if Restart or Terminated then
        Break;
    end;
    MyChildren := nil;

  except
    if Terminated then
      Exit;
    AddHint('Error in Spy: ' + Mess);
    WorkWin.Label7.Caption := 'ERROR';
  end;
  CurNode := zCurNode;
end;

function FindItemByRealName(LV: TListView; Text: string): TListItem;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to LV.Items.Count-1 do
    if LV.Items[i].Caption = Text then begin
      Result := LV.Items[i];
    Exit; end;
  for i := 0 to LV.Items.Count-1 do
    if SameText(RealValueName(LV.Items[i]), Text) then begin
      Result := LV.Items[i];
    Break; end;
end;

procedure TRegSpyThread.ReloadValues;
var
  Item: TListItem;
  Real, Cur: TStringList;
  Dif: TSLComp;
  i: integer;
begin
  if Terminated or Restart then
    Exit;

  if not OpenNodeOK(Reg, RegTV.Selected) then
    Exit;

  Real := TStringList.Create;
  Reg.GetValueNames(Real);

  Cur := TStringList.Create;
  with ValueList.Items do
    for i := 0 to Count-1 do
      Cur.Add(RealValueName(Item[i]));

  Dif := TSLComp.Create(Cur, Real, False);
  Real.Free;
  Cur.Free;

  for i := 0 to Dif.OnlyA.Count-1 do begin //Gelöscht/wegbenannt
    Item := FindItemByRealName(ValueList, Dif.OnlyA[i]);
    if Assigned(Item) then begin
      Item.Delete;
      AddTrace('Value deleted: ' + Dif.OnlyA[i]);
    end;
  end;

  for i := 0 to ValueList.Items.Count-1 do begin    //Daten
    Item := ValueList.Items[i];
    {if Item.SubItems.Count < 2 then begin
      ShowMessage('Fehler in Sync.');
    Exit end; }
    if ValuesWin.UpdateValue(Reg, Item) then
      AddTrace('Value Changed: ' + Item.Caption + ' = ' +
        ValueDataPreview(Reg.ReadContext(RealValueName(Item))));
  end;

  for i := 0 to dif.OnlyB.Count-1 do begin  //Erstellt/hinbenannt
    ValuesWin.AddValue(Reg, dif.OnlyB[i]);
    AddTrace('New Value: ' + Dif.OnlyB[i]);
  end;

  Reg.CloseKey;
  Dif.Free;
end;

procedure TRegSpyThread.Spy;
var
  i: Integer;
  a: Real;
begin
  with TClock.Create do begin
    for i := 0 to RootNodes.Count-1 do
      Reload(TTreeNode(RootNodes[i]));
    for i := 0 to High(Shortcuts) do
      Reload(Shortcuts[i].Node);
    Synchronize(ReloadValues);
    a := SecondsPassed * 1000;
  Free; end;

  if a > 0 then
    WorkWin.Label7.Caption := 'Spy: ' + Format('%0.2f', [a]) + ' s';
end;

procedure TRegSpyThread.AddTrace(Trace: string);
begin
  with WorkWin do
    if ListTracesCB.Checked then
      SpyLB.Items.Add(Trace);
end;

destructor TRegSpyThread.Destroy;
begin
  Dif.Free;
  Reg.Free;
  inherited;
end;

end.
unit TreeU;
{$DEFINE UNIKEY}
{$DEFINE CYCFS}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Menus, Clipbrd, keybrd, Dialogs, YTools, PlutoConst, CompEx,
  IniFiles, XReg, Colors, Clock,
  ToolWin, RegFiles {$IFDEF UNIKEY}, UniKey, ImgList {$ENDIF};

type
  TTreeWin = class(TForm)
    RegTVPU: TPopupMenu;
    NewSubKeyMI: TMenuItem;
    NewKeyMI: TMenuItem;
    CreateShortcutMI: TMenuItem;
    TraceMI: TMenuItem;
    N3: TMenuItem;
    DeleteMI: TMenuItem;
    DublicateMI: TMenuItem;
    N4: TMenuItem;
    FindMI: TMenuItem;
    RegTV: TTreeView;
    PastePathMI: TMenuItem;
    N1: TMenuItem;
    InsertPathMI: TMenuItem;
    RenameMI: TMenuItem;
    CopyPathMI: TMenuItem;
    CutPathMI: TMenuItem;
    EditShortcutMI: TMenuItem;
    N2: TMenuItem;
    Export1: TMenuItem;
    SubKeylist1: TMenuItem;
    ValueNameslist1: TMenuItem;
    KeyInfosMI: TMenuItem;
    N5: TMenuItem;
    ExportAsReg: TMenuItem;
    ExportD: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure RegTVClick(Sender: TObject);
    procedure RegTVChange(Sender: TObject; Node: TTreeNode);
    procedure RegTVChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure RegTVCollapsing(Sender: TObject; Node: TTreeNode; var AllowCollapse: Boolean);
    procedure RegTVCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure RegTVDblClick(Sender: TObject);
    procedure RegTVDeletion(Sender: TObject; Node: TTreeNode);
    procedure RegTVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure RegTVDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure RegTVEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure RegTVEditing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
    procedure RegTVEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure RegTVEnter(Sender: TObject);
    procedure RegTVExpanded(Sender: TObject; Node: TTreeNode);
    procedure RegTVExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure RegTVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure RegTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RegTVMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure RegTVStartDrag(Sender: TObject; var DragObject: TDragObject);

    function CreateKey(Subkey: Boolean): Boolean;
    procedure CloneKey;
    procedure DeleteKey;
    procedure NewShortcut;
    procedure MoveKey(const Src, Trg: TRegPath; CopyWanted: Boolean);
    procedure MoveValues(SrcNode, TrgNode: TTreeNode; CopyWanted: Boolean);

    procedure NewSubKeyMIClick(Sender: TObject);
    procedure NewKeyMIClick(Sender: TObject);
    procedure CreateShortcutMIClick(Sender: TObject);
    procedure TraceMIClick(Sender: TObject);
    procedure DeleteMIClick(Sender: TObject);
    procedure DublicateMIClick(Sender: TObject);
    procedure FindMIClick(Sender: TObject);
    procedure RegTVPUPopup(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RegTVKeyPress(Sender: TObject; var Key: Char);
    procedure RegTVAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure RenameMIClick(Sender: TObject);
    procedure CopyPathMIClick(Sender: TObject);
    procedure InsertPathMIClick(Sender: TObject);
    procedure RegTVGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure CheckRegTVHotTrack;
    procedure PasteKeyMIClick(Sender: TObject);
    procedure CutPathMIClick(Sender: TObject);

    procedure OpenNextLevel(Node: TTreeNode);
    procedure EditShortcutMIClick(Sender: TObject);
    procedure SubKeylist1Click(Sender: TObject);
    procedure ValueNameslist1Click(Sender: TObject);
    procedure KeyInfosMIClick(Sender: TObject);
    function GetKeyInfos: string;
    procedure ExportAsRegClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Load;
    procedure Reg4WriterTerminate(Sender: TObject);
  private
    DragNode: TTreeNode;
    NoAsterisk: Boolean; //To prevent NumPadMULTIPLY and asterisk errors
    UserCopyKeyFlag: Boolean;
    SpaceCount: Integer; //EasterEgg
  public
    CantWrite: Boolean;
    DoSmartExpand: Boolean;
  end;

procedure CheckNode(Node: TTreeNode; OnlyOnce: Boolean = True;
  TakeNodeSelected: Boolean = False);

function AddShortcut(Alias, RealPath: string; Icon: Integer;
  AHostType: TUniHostType = uhUserShortcut; WriteIni: Boolean = False): TTreeNode;
function ShortcutIndex(Node: TTreeNode): Integer;

function TraceKey(const Path: string; AllowedShortcutTypes: TUniHostTypes =
  uhNonSystemShortcuts): string;

type
  TOpenNodeMode = (onNodeNil, onError, onReadOnly, onFull);

const
  onOK = [onFull, onReadOnly];

function OpenNode(Reg: TXRegistry; Node: TTreeNode): TOpenNodeMode;
function OpenNodeOK(Reg: TXRegistry; Node: TTreeNode): Boolean;
function OpenCurKey: Boolean;
function OpenCurParent: Boolean;

var
  TreeWin: TTreeWin;

  RegTV: TTreeView; //Shortcut for other units, equals TreeWin.RegTV

{$IFDEF UNIKEY}
  UserUniPath: string {$IFDEF CYCFS} = 'cYcFS <y:\programme\cYcFS\test>'{$ENDIF};
{$ENDIF}
  Shortcuts: TShortcutA;
  RootNodes: TList; //list of TTreeNode;

implementation

uses
  PlutoMain, ValuesU, FindWinU, WorkU, PrefU, ShellEx, Types;

{$R *.dfm}

{$IFDEF UNIKEY}
function UniOfNode(Node: TTreeNode): TUniKey;
var
  UniPath: TUniPath;
begin
  UniPath := UniOfStr(UserUniPath);
  UniPath.Path := Join(Copy(NodePath(Node), 1, MaxInt), '/');
  Result := TUniKey.CreateU(UniPath, reTryToSolve);
end;
{$ENDIF}      

procedure TTreeWin.FormCreate(Sender: TObject);
begin
  TreeU.RegTV := RegTV;

  DragNode := nil;
  NoAsterisk := False;
  DoSmartExpand := True;
  UserCopyKeyFlag := True;
  SpaceCount := 0; //EasterEgg

  RegTV.Items.Clear;
  CheckRegTVHotTrack;

  KeyInfosMI.ImageIndex := iconKeyInfos;

  NewSubKeyMI.ImageIndex := iconSubKey;
  NewKeyMI.ImageIndex := iconKey;
  CreateShortcutMI.ImageIndex := iconShortcut;

  RenameMI.ImageIndex := iconRename;
  DeleteMI.ImageIndex := iconDelete;
  DublicateMI.ImageIndex := iconKeyDublicate;

  FindMI.ImageIndex := iconKeyFind;
  TraceMI.ImageIndex := iconKeyTrace;
end;

procedure TTreeWin.RegTVClick(Sender: TObject);
begin
  if KeyIsDown(VK_CONTROL) then begin
    TraceMIClick(Sender);
  Exit; end;
end;

procedure TTreeWin.RegTVChange(Sender: TObject; Node: TTreeNode);
var
  Reg: TXRegistry;
  OpenRe: TOpenNodeMode;

{$IFDEF UNIKEY}
  Uni: TUniKey;
  ValueNames: TStringList;
  Item: TListItem;
  i: Integer;

  procedure AppendSubItemData(SubItems: TStrings; Uni: TUniKey;
    const ValueName: string);
  var
    SL: TStringList;

    procedure Add(const s: string);
    begin
      SubItems.Append(s);
    end;

  begin
    SL := nil;
    try
      Add('beta');

      case Uni.GetDataType(ValueName) of

      udString, udExpandString: begin
        Add('String');
        Add(Uni.ReadString(ValueName));
      end;

      udCardinal, udCardBigEndian, udInteger: begin
        Add('Numeric');
        Add(IntToStr(Uni.ReadInteger(ValueName)));
      end;

      udBinary, udNone: begin
        Add('Binary');
        Add(FriendlyStr(Uni.ReadBinary(ValueName)));
      end;

      udBoolean: begin
        Add('Boolean');
        Add(StrOfBool(Uni.ReadBool(ValueName)));
      end;

      udStringList: begin
        Add('List');
        if not Assigned(SL) then
          SL := TStringList.Create
        else
          SL.Clear;
        Uni.ReadStringList(ValueName, SL);
        Add(Join(SL, MultiStringSeparator));
      end;

      udColor: begin
        Add('Color');
        Add(ColorToString(Uni.ReadColor(ValueName)));
      end;

      else
        Add('Unsupported Data Type: ' +
        IntToStr(Cardinal(Uni.GetDataType(ValueName))));
      end; //case

    finally
      SL.Free;
    end;
  end;


{$ENDIF}

begin
  SpaceCount := 0; //Easteregg

  CheckNode(Node, False);
  CantWrite := False;

  try
    SpyThread.Suspend;
    Reg := TXRegistry.Create;
    try

{$IFDEF UNIKEY}
      if RootOfNode(Node).ImageIndex = iconHostUni then begin
        ValueNames := TStringList.Create;
        ValueList.Clear;

        Uni := UniOfNode(Node);
        {Uni := CreateUniSubKey(UserUniPath, Copy(NodePath(Node), 1, MaxInt),
          reFaile); }
        if Assigned(Uni) then
        try
          Uni.GetValueNames(ValueNames);

          for i := 0 to ValueNames.Count-1 do begin
            Item := ValuesWin.AddValue(Reg, ValueNames[i], False);
            Item.ImageIndex := iconHostUni2;
            AppendSubItemData(Item.SubItems, Uni, ValueNames[i]);
          end;

        finally
          Uni.Free;
          ValueNames.Free;
        end;

      end else begin
{$ENDIF}

      OpenRe := OpenNode(Reg, Node);
      if OpenRe in onOK then begin
        ValuesWin.LoadValues(Reg);
        if OpenRe = onReadOnly then begin
          AddHint('Read only', True);
          CantWrite := True;
        end;
      end else if OpenRe = onError then begin
        ValueList.Clear;
        CantWrite := True;
        if Node.Level = 0 then begin
          AddHint('Shortcut target not found', True);
        end else
          AddHint('Key not found: ' + Node.Text, True);
      end;

{$IFDEF UNIKEY}
      end;
{$ENDIF}

    finally
      Reg.Free;
    end;

    CantWrite := CantWrite or not Assigned(Node)
      or NodeInfo(           Node ).ReadOnly  //Node itself
      or NodeInfo(RootOfNode(Node)).ReadOnly  //or host
      or (SameText(CurKey(uhNonSystemShortcuts).Root, 'HKEY_DYN_DATA'));

    MainWin.SetStatus;
    WorkWin.InfoMemo.Text := GetKeyInfos;
  finally
    SpyThread.Restart := True;
    SpyThread.Resume;
  end;
end;

procedure TTreeWin.RegTVChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  CantWrite := False;
  AllowChange := Assigned(Node);
 // CheckNode(Node, True);
end;

procedure TTreeWin.RegTVCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  SpyThread.Restart := True;
  Node.DeleteChildren;
  RegTVChange(Sender, Node);
end;

procedure TTreeWin.RegTVCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Info: TNodeInfo;
begin
  {if Node.Text = '' then begin
    ShowMessage('Error: Key has empty name.');
    Node.Delete;
  Exit; end;}

  Info := NodeInfo(Node);
  with TTreeView(Sender).Canvas.Font do begin
    if Info.Defect then begin
      Style := [];
      Color := $AAAAAA
    end else begin
      case Info.HostType of

      uhReg: begin
        Style := [fsBold];
        Color := clCyan;
      end;

      {uhIni: begin
        Style := [fsBold];
        Color := clBrightYellow;
      end;

      uhRegFile: begin
        Style := [fsBold];
        Color := clBrightGreen;
      end; }

      uhSystemShortcut: begin
        Style := [];
        Color := clBrightCyan;
      end;

      uhStandardShortcut: begin
        Style := [fsBold];
        Color := $EEEEEE;
      end;

      uhUserShortcut: begin
        Style := [];
        Color := $EEEEEE;
      end;

      else
        Style := [];
        if Info.ReadOnly then
          Color := clBrightRed
        else
          Color := clWhite;
      end;

    end;
  end;
end;

procedure TTreeWin.RegTVDblClick(Sender: TObject);
var
  Node: TTreeNode;
  MouseX: Integer;
  NodeRect: TRect;
begin
  Node := RegTV.Selected;
  if not Assigned(Node) then
    Exit;

  MouseX := RegTV.ScreenToClient(Mouse.CursorPos).X;
  NodeRect := Node.DisplayRect(True);
  if MouseX > NodeRect.Right then begin
    with ValuesWin do begin
      FocusItem(PrefWin.MainPreviewE.Text);
      ValueListDblClick(Self);
    end;
  end;
end;

procedure TTreeWin.RegTVDeletion(Sender: TObject; Node: TTreeNode);
begin
  if Assigned(SpyThread) then
    SpyThread.Restart := True;
  if Node.Selected then
    RegTV.Selected := GetNextBest(Node);
  NodeInfo(Node).Free;
end;

procedure TTreeWin.RegTVDragDrop(Sender, Source: TObject; X, Y: Integer);

  procedure DragKey;
  var
    Src, Trg: TRegPath;
    Node: TTreeNode;
  begin
    Src := RegPathOfStr(TraceKey(PathOfNode(DragNode)));
    Trg := RegPathOfStr(TraceKey(PathOfNode(RegTV.DropTarget)));
    Trg.Key := Trg.Key + '\' + DragNode.Text;

    MoveKey(Src, Trg, KeyIsDown(VK_CONTROL));

    Node := RegTV.DropTarget;
    if Node.Expanded then
      Node.Collapse(False);
    Node.Expanded := False;
    CheckNode(Node, False, True);
    Node.Expand(False);
  end;

  procedure DragValues;
  begin
    MoveValues(RegTV.Selected, RegTV.DropTarget, KeyIsDown(VK_CONTROL));
  end;

begin
  if Source is TTreeView then
    DragKey
  else if Source is TListView then
    DragValues;
end;

procedure TTreeWin.RegTVDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := False;
  if not Assigned(RegTV.DropTarget) then
    Exit;

  if Source is TTreeView then begin
    if not Assigned(DragNode) then
      Exit;
    if not KeyIsDown(VK_CONTROL) then begin
      if (DragNode = RegTV.DropTarget)
       or RegTV.DropTarget.HasAsParent(DragNode) then
        Exit; //avoid recursive moving
    end;
  end else if Source is TListView then begin
    //accept
  end;
  Accept := True;
end;

procedure TTreeWin.RegTVEdited(Sender: TObject; Node: TTreeNode; var S: string);
var
  old, tmp: string;
  i: Integer;
  Shortcut: PKeyShortcut;
begin
  if s = Node.Text then
    Exit;

  Old := Node.Text;

  if NodeInfo(Node).HostType = uhUserShortcut then begin
    i := ShortcutIndex(Node);
    if i = -1 then begin
      ShowMessage('Shortcut not found!');
      s := old;
    Exit; end;

    Shortcut := @Shortcuts[i];
    Shortcut.Alias := s;

    with TIniFile.Create(PlutoDir + 'Shortcuts.ini') do
      try
        DeleteKey('Shortcuts', Old);
        WriteString('Shortcuts', Shortcut.Alias, Shortcut.RealPath);
      finally
        Free;
      end;
    Node.Text := s;
    RegTVChange(Self, Node);
  Exit; end;

  if s = '' then begin
    ShowMessage('KeyNames cannot be empty.');
    s := old;
  Exit; end;

  SpyThread.Suspend;
  SpyThread.Restart := True;
  Node.Text := s;

  if Length(s) > RegMaxKeyLen then begin
    s := Copy(s, 1, RegMaxKeyLen);
    if MessageDlg(
     'The maximum size of a key name is ' + IntToStr(RegMaxKeyLen) + ' characters.' + EOL +
     'Shorten the key name to:' + EOL +
     Quote(StringWrap(s, 80)),
     mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then begin
      s := Old;
      SpyThread.Resume;
      Exit;
    end;
  end;

  if CharIn(s, [#0..#31, '\']) then begin
    s := ReplaceChars(s, [#0..#31], '#');
    s := ReplaceChars(s, '\', '-');

    if MessageDlg('The following characters are not allowed in KeyNames:' + EOL +
     '- Control chars (0-31)' + EOL +
     '- ' + Quote('\') + EOL +
     'The following name is allowed:' + EOL +
     s + EOL +
     'Use this name instead?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then begin
      s := Old;
      SpyThread.Resume;
      Exit;
    end;
  end;

  try
    OpenCurParent;
    if not SameText(s, Old) then begin
      if not MainReg.KeyExists(s) or
       (mrIgnore = MessageDlg(
         'Key already exists.' + EOL +
         'Click Ignore to overwrite the key.',
         mtConfirmation, [mbCancel, mbIgnore], 0)
       ) then begin
        MainReg.DeleteKey(s);
        MainReg.MoveKey(Old, s, True);
        Node.Text := Old;
      end else begin
        s := Old;
      end;
    end else begin  //change CharCase
      tmp := MainReg.GetFreeKeyName;
      AddHint('Forced change of case using temporary key ' + Quote(tmp));
      MainReg.MoveKey(Old, tmp, True);
      MainReg.MoveKey(tmp, s, True);
    end;
  finally
    MainReg.CloseKey;
  end;

  Node.Text := s;
  SpyThread.Resume;
  RegTVChange(Sender, Node);
end;

procedure TTreeWin.RegTVEditing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  CheckNode(Node, False);
  if RegTV.Selected <> Node then
    Exit;
  AllowEdit := (NodeInfo(Node).HostType in [uhNone, uhUserShortcut])
               and (not CantWrite)
               and OpenCurKey;
  MainReg.CloseKey;
end;

procedure TTreeWin.RegTVEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  DragNode := nil;
end;

procedure TTreeWin.RegTVEnter(Sender: TObject);
begin
  if not Started then
    Exit;
  ValueList.ItemFocused := nil;
  MainWin.SetStatus;
end;

procedure TTreeWin.RegTVExpanded(Sender: TObject; Node: TTreeNode);
begin
  if not DoSmartExpand or not PrefWin.SmartExpandCB.Checked then
    Exit;

  if not Assigned(Node) then
    Exit;

  RegTVChange(Sender, Node);

  //SmartExpand
  if (Node.Count > 0) and (ValueList.Items.Count = 0) then begin
    RegTV.Selected := Node.GetFirstChild;
    RegTVChange(Sender, RegTV.Selected);
  end;

  if Node.Count = 1 then
    Node.GetFirstChild.Expand(False);
end;

procedure TTreeWin.RegTVExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  SL: TStringList;
  Reg: TXRegistry;
  Clock: TClock;
{$IFDEF UNIKEY}
  Uni: TUniKey;
{$ENDIF}

  procedure AddKeys(TreeView: TTreeView; Node: TTreeNode; SL: TStrings);
  var
    i: Integer;
  begin
    for i := 0 to SL.Count-1 do
      TreeView.Items.AddNode(TTreeNode.Create(TreeView.Items), Node, SL[i],
        nil, naAddChild);
  end;

  procedure AddKeysProgressive(TreeView: TTreeView; Node: TTreeNode;
    SL: TStrings);
  var
    i, delta: Integer;
    GaugeRect, FullRect: TRect;
    GaugeWidth: Integer;
  begin
    delta := SL.Count div 100;
    GaugeWidth := 100;
    with TreeView.Canvas do begin
      FullRect := Node.DisplayRect(True);
      with FullRect do begin
        Left := Right + 40;
        Right := Left + GaugeWidth + 2;
        Inc(Top, 5);
        Dec(Bottom, 5);
      end;
      with Pen do begin
        Width := 1;
        Style := psSolid;
      end;
      Pen.Color := clBrightBlue;
      Brush.Style := bsClear;
      Rectangle(FullRect);
      Pen.Style := psClear;
    end;

    GaugeRect := FullRect;
    with GaugeRect do begin
      Inc(Left);
      Inc(Top);
      Dec(Bottom);
    end;

    for i := 0 to SL.Count-1 do begin
      TreeView.Items.AddNode(TTreeNode.Create(TreeView.Items), Node, SL[i],
        nil, naAddChild);

      if ((i + 1) mod delta) = 0 then begin
        with TreeView.Canvas do begin
          GaugeRect.Right := GaugeRect.Left + (GaugeWidth * i) div SL.Count;
          Brush.Color := GadientAqua(90 + Round(100 * ((i+1) / SL.Count)));
          FillRect(GaugeRect);
        end;
      end;
    end;

    with TreeView.Canvas do begin
      Pen.Color := clVeryBrightBlue;
      Pen.Style := psSolid;
      Brush.Color := GadientAqua(200);
      Rectangle(FullRect);
      Brush.Style := bsClear;
    end;
  end;

begin
  if Node.Expanded then
    Exit;

  SpyThread.Suspend;
  SL := TStringList.Create;
  Clock := TClock.Create;

  try

{$IFDEF UNIKEY}
    if RootOfNode(Node).ImageIndex = iconHostUni then begin
      Uni := UniOfNode(Node);
      if Assigned(Uni) then
        try
          Uni.GetKeyNames(SL);
        finally
          Uni.Free;
        end;

    end else begin
{$ENDIF}

    Reg := TXRegistry.Create;
    try
      if OpenNodeOK(Reg, Node) then
        Reg.GetKeyNames(SL);
    finally
      Reg.Free;
    end;

{$IFDEF UNIKEY}
    end;
{$ENDIF}

    Node.DeleteChildren;
    if PrefWin.ShowProgressCB.Checked and (SL.Count > 100) then
      AddKeysProgressive(RegTV, Node, SL)
    else
      AddKeys(RegTV, Node, SL);

    if PrefWin.SortKeysCB.Checked then
      Node.AlphaSort;

    if MurphyMode then begin
      Clock.Stop;
      AddHint(Format('[MM] Key opened after %0.2f s.', [Clock.SecondsPassed]));
    end;
  finally
    Clock.Free;
    SL.Free;
    SpyThread.Resume;
  end;
end;

procedure TTreeWin.RegTVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TTreeWin.RegTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node: TTreeNode;
begin
  if Key = VK_SCROLL then
    CheckRegTVHotTrack;

  if RegTV.IsEditing then
    Exit;

  Node := RegTV.Selected;
  if not Assigned(Node) then
    Exit;

  if ssShift in Shift then
    case Key of
      VK_DOWN: begin
        Node := Node.GetNextSibling;
        if Assigned(Node) then
          RegTV.Selected := Node;
      Key := 0; end;

      VK_UP: begin
        Node := Node.GetPrevSibling;
        if Assigned(Node) then
          RegTV.Selected := Node;
      Key := 0; end;

      VK_RIGHT: Key := VK_MULTIPLY;
      VK_LEFT: Key := VK_DIVIDE;
    end;

  if Assigned(Node.Parent) then begin
    case Key of
      VK_END:
        begin
          RegTV.Selected := Node.Parent.GetLastChild;
        Key := 0; end;

      VK_HOME:
        begin
          RegTV.Selected := Node.Parent.GetFirstChild;
        Key := 0; end;
    end;
  end;

  case Key of
    0: Exit;
    VK_RETURN: ValuesWin.FocusControl(ValueList);
    VK_DELETE: DeleteMIClick(Sender);
    VK_SPACE: begin
      JumpToSel(RegTV);
      Inc(SpaceCount);
      if SpaceCount > 10 then begin
        ShowMessage('YES!');
        SpaceCount := 0;
      end;
    end;
    VK_F9: SwapFonts(RegTV);

    VK_F12:
      if ssShift in Shift then begin
        if Assigned(Node.Parent) then Node.Parent.AlphaSort;
      end else
        if Node.Expanded then Node.AlphaSort;

    VK_LEFT, VK_SUBTRACT:
      begin
        if Node.Expanded then
          Node.Collapse(False)
        else if Assigned(Node.Parent) then
          RegTV.Selected := Node.Parent;
      Key := 0; end;

    VK_RIGHT, VK_ADD:
      begin
        if not Node.HasChildren then
          TreeWin.RegTV.Items.AddChild(Node, '');
        if Node.Expanded then
          RegTV.Selected := Node.GetFirstChild
        else
          Node.Expand(False);
      Key := 0; end;

    VK_MULTIPLY:
      begin
        NoAsterisk := True;
        OpenNextLevel(Node);
        JumpToSel(RegTV);
        AddHint('Press the Multiply Key again to open the next level.');
      Key := 0; end;

    VK_DIVIDE:
      begin
        DoSmartExpand := False;
        Node.Collapse(true);
        DoSmartExpand := True;
      Key := 0; end;
  end;

  if ssctrl in Shift then
    case Key of
      Ord('C'): CopyPathMIClick(Sender);
      Ord('X'): CutPathMIClick(Sender);
      Ord('V'): PasteKeyMIClick(Sender);
    end;
end;

procedure TTreeWin.RegTVMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  RelX, RelY: Integer;
  NodeRect: TRect;
begin
  CheckRegTVHotTrack;

  if not Active then
    Exit;

  RelX := RegTV.ScreenToClient(Mouse.CursorPos).X;
  RelY := RegTV.ScreenToClient(Mouse.CursorPos).Y;
  Node := RegTV.GetNodeAt(RelX, RelY);
  if not Assigned(Node) then
    Exit;

  if not Node.Selected then
    Node.Selected := True;

  if Button = mbLeft then begin
    NodeRect := RegTV.Selected.DisplayRect(True);
    if RegTV.HotTrack
     or (RelX < NodeRect.Left) and (RelX > NodeRect.Left - 20) then begin
      //4px more to the left (friendlier for the user)
      if not Node.HasChildren then
        RegTV.Items.AddChild(Node, '');
      DoSmartExpand := False;
      with Node do
        if not Expanded then
          Expand(False)
        else
          Collapse(False);
      DoSmartExpand := True;
    end;
  end;
end;

procedure TTreeWin.RegTVStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  DragNode := RegTV.Selected;
  if NodeInfo(DragNode).IsHost then
    DragNode := nil;
end;

function OpenNodeError(Reg: TXRegistry; Node: TTreeNode;
  out Mode: TOpenNodeMode): Integer;
var
  Key: string;
begin
  Result := ERROR_SUCCESS;
  Mode := onNodeNil;
  if not Assigned(Node) then
    Exit;

  Reg.CloseKey;
  Key := TraceKey(PathOfNode(Node));
  Reg.RootKey := HKEYOfStr(ExRegRoot(Key));
  Result := Reg.OpenKeyError(ExRegKey(Key), False, True);
  if Success(Result) then
    if Reg.RootKey = HKDD then
      Mode := onReadOnly
    else
      Mode := onFull
  else if Reg.OpenKeyReadOnly(ExRegKey(Key)) then
    Mode := onReadOnly
  else
    Mode := onError;
end;

function OpenNode(Reg: TXRegistry; Node: TTreeNode): TOpenNodeMode;
begin
  OpenNodeError(Reg, Node, Result);
end;

function OpenNodeOK(Reg: TXRegistry; Node: TTreeNode): Boolean;
begin
  Result := OpenNode(Reg, Node) in onOK;
end;

function OpenCurKey: Boolean;
begin
  Result := OpenNodeOK(MainReg, RegTV.Selected);
end;

function OpenCurParent: Boolean;
begin
  Result := Assigned(RegTV.Selected)
    and OpenNodeOK(MainReg, RegTV.Selected.Parent);
end;

function TTreeWin.CreateKey(Subkey: Boolean): Boolean;
var
  Node, NewNode: TTreeNode;
  KeyName: string;
  i: integer;
begin
  Result := False;

  if CantWrite then
    Exit;

  Node := RegTV.Selected;
  if not Assigned(Node) then
    Exit;

  if not Subkey then begin
  //key shall be created on same level...
    if Node.Level = 0 then begin
      Node := RegTV.Selected;
      if TraceKey(PathOfNode(Node)) <> PathOfNode(Node) then
      //check for shortcut: shortcuts are unequal to their trace
        if mrOK = MessageDlg(
                  'You are trying to create a Key in the shortcut''s level.' + EOL +
                  'Pluto needs to jump to the target of the shortcut to do this.',
                  mtConfirmation, [mbOK, mbCancel], 0) then begin
          MainWin.GotoKey(TraceKey(PathOfNode(Node)));
          Node := RegTV.Selected.Parent;
        end else Exit
      else begin
        ShowMessage('Key is a HKEY.' + EOL +
                    'It is not possible to create Keys on HKEY level.');
      Exit; end;
    end else
      Node := Node.Parent; //set reference key to parent
  end;

  try

    case OpenNode(MainReg, Node) of

    onFull: begin
      KeyName := 'New';  //find best free name
      i := 0;
      while MainReg.KeyExists(KeyName) do begin
        Inc(i);
        KeyName := 'New ' + IntToStr(i);
      end;

      Result := MainReg.CreateKey(KeyName) and MainReg.KeyExists(KeyName);
      // ^-- CREATE KEY

      if not Result then // <-- FAILED
        ShowMessage('Could not create key!');
    end;

    onReadOnly: ShowMessage('Key is read-only.');

    else
      ShowMessage('Error: Couldn''t open key.');

    end; //case

  finally
    MainReg.CloseKey;
  end;

  if not Result then
    Exit;

  if not Node.Expanded then begin   //find the node, if Parent not Expanded
    CheckNode(Node, False);
    DoSmartExpand := False;
    Node.Expand(False);
    DoSmartExpand := True;
    NewNode := FindNode(Node, KeyName);
  end else
    NewNode := RegTV.Items.AddChild(Node, KeyName); //else create a new node

  Result := Assigned(NewNode);
  if not Result then
    ShowMessage('Error: Could not find created key.');

  if Result then begin
    RegTV.Selected := NewNode;
    RegTV.Selected.EditText;
  end;
end;

procedure TTreeWin.CloneKey;
var
  Node: TTreeNode;
  Full: TRegPath;
  MainKey, SubKey, NewKey, zKey: string;
  i: integer;
begin
  Node := RegTV.Selected;

  if CantWrite then
    Exit;

  if NodeInfo(Node).IsHost then
    Exit;

  Full := CurKey(uhNonSystemShortcuts);
  MainKey := LWPSolve(Full.Key);
  SubKey := FromLastChar(MainKey, '\');
  MainKey := UntilLastChar(MainKey, '\');
  if SubKey = '' then begin //Directly beyound HKEY
    SubKey := MainKey;
    MainKey := '';
  end;

  try
    MainReg.RootKey := HKEYOfStr(Full.Root);
    if not MainReg.OpenKey(MainKey, False) then begin
      ShowMessage('Error: Couldn''t not open Key: ' + MainKey);
    Exit end;
    if Copy(SubKey, 1, 3) <> 'New' then
      NewKey := 'New ' + SubKey
    else
      NewKey := SubKey;

    zKey := Trim(FromLastChar(NewKey, ' '));

    i := StrToIntDef(zKey, 0);
    if IsValidInteger(zKey) then
      zKey := Trim(UntilLastChar(NewKey, ' '))
    else
      zKey := NewKey;
        
    while MainReg.KeyExists(NewKey) do begin
      Inc(i);
      NewKey := zKey + ' ' + IntToStr(i);
    end;

    MainReg.MoveKey(SubKey, NewKey, False);
  finally
    MainReg.CloseKey;
  end;

  Node := RegTV.Items.Add(Node, NewKey);
  RegTV.Selected := Node;
  Node.EditText;
end;

procedure TTreeWin.NewShortcut;
var
  Node, ShortCutNode: TTreeNode;
  ScName, ScRealPath: string;
  i: Integer;
begin
  Node := RegTV.Selected;
  if not Assigned(Node) then
    Exit;

  if Node.Level = 0 then
    ScName := 'new ' + Node.Text
  else
    ScName := '' + Node.Text;

  ScRealPath := TraceKey(PathOfNode(Node));
  if not InputQuery('New shortcut to ', ScRealPath, ScName) then
    Exit;

  for i := 0 to High(ShortCuts) do
    if SameText(ScName, ShortCuts[i].Alias) then begin
      ShowMessage('Name already in use.');
      NewShortcut;
    Exit; end;

  ShortCutNode := AddShortcut(ScName, ScRealPath, iconShortcut, uhUserShortcut,
    True);
  CheckNode(Node, False);
  RegTV.Selected := ShortCutNode;
end;

function AddShortcut(Alias, RealPath: string; Icon: Integer;
  AHostType: TUniHostType = uhUserShortcut;
  WriteIni: Boolean = False): TTreeNode;
var
  Last: Integer;
begin
  RealPath := TraceKey(RealPath); //Important: do this BEFORE adding a new,
                                  //empty shortcut to ShortCuts

  SetLength(ShortCuts, Length(ShortCuts) + 1);
  Last := High(Shortcuts);
  ShortCuts[Last].Alias := Alias;
  ShortCuts[Last].RealPath := RealPath;

  Result := RegTV.Items.Add(nil, Alias);
  ShortCuts[Last].Node := Result;

  if Alias = 'HKEY_WindowsMachine' then
    Icon := iconHKWM
  else if Alias = 'HKEY_WindowsUser' then
    Icon := iconHKWU;
  SetTNImage(Result, Icon);

  NodeInfo(Result).HostType := AHostType;

  if WriteIni then
    with TIniFile.Create(PlutoDir + 'Shortcuts.ini') do
      try
        WriteString('Shortcuts', Alias, RealPath);
      finally
        Free;
      end;
end;

procedure TTreeWin.DeleteKey;
var
  i: Integer;
  Node, Node2: TTreeNode;
begin
  Node := RegTV.Selected;


  i := ShortcutIndex(Node);
  if (i > -1) then begin
    if (mrYes = MessageDlg('This is a Pluto shortcut to a real key.'#13#10 +
     'Do you really want to delete the shortcut?',
     mtConfirmation, [mbYes, mbCancel], 0)) then begin
      SpyThread.Suspend;
      SpyThread.Restart := True;
      with TIniFile.Create(PlutoDir + 'Shortcuts.ini') do
        try
          DeleteKey('Shortcuts', Shortcuts[i].Alias);
        finally
          Free;
        end;
      Shortcuts[i] := Shortcuts[High(Shortcuts)];
      SetLength(Shortcuts, Length(Shortcuts)-1);
      RegTV.Selected := GetNextBest(Node);
      Node.Delete;
      RegTVChange(Self, RegTV.Selected);
      SpyThread.Resume;
    end;
  Exit; end;

  if CantWrite then
    Exit;

  if NodeInfo(Node).IsHost then
    Exit;

  SpyThread.Suspend;
  SpyThread.Restart := True;

  Node2 := GetNextBest(Node);

  if MessageDlg('Do you really want to delete this key?', mtConfirmation,
   [mbYes, mbCancel], 0) = mrYes then
    try
      if OpenCurParent then begin
        if not MainReg.DeleteKey(Node.Text) then //<-- DELETE KEY
          ShowMessage('Key could not be deleted.')
        else begin
          RegTV.Selected := Node2;
          if Assigned(Node.Parent) and (Node2 = Node.Parent) then
            Node.Parent.Collapse(False);
          Node.Delete;
        end;
      end;
    finally
      MainReg.CloseKey;
    end;

  RegTVChange(Self, Node2);

  SpyThread.Resume;
end;

procedure TTreeWin.MoveKey(const Src, Trg: TRegPath; CopyWanted: Boolean);
var
  TrgReg: TXRegistry;
begin
  with MainReg do begin
    RootKey := HKEYOfStr(Src.Root);
    OpenKey('');

    if not KeyExists(Src.Key) then begin
      ShowMessage('Source not found.');
    Exit; end;
  end;

  TrgReg := TXRegistry.Create;
  with TrgReg do begin
    RootKey := HKEYOfStr(Trg.Root);
    OpenKey('');
    if KeyExists(Trg.Key) then begin
      ShowMessage('Target already existing.');
      TrgReg.Free;
    Exit; end;
  end;

  if not CopyWanted then
    if mrYes <> MessageDlg('From source: ' + StrOfRegPath(Src) + EOL +
                           'To target: ' + StrOfRegPath(Trg) + EOL +
                           'Do you really want to move this key?',
                           mtConfirmation, [mbYes, mbCancel], 0)
    then
      Exit;

  try
    MainReg.MoveKey(Src.Key, TrgReg, Trg.Key, not CopyWanted); //<-- MOVE KEY
  except
  end;

  if not TrgReg.OpenKey(Trg.Key, False) then
    ShowMessage('Could not move key!')
  else
    if not CopyWanted then
      DragNode.Delete;


  TrgReg.Free;

  MainReg.CloseKey;
end;

procedure TTreeWin.MoveValues(SrcNode, TrgNode: TTreeNode;
  CopyWanted: Boolean);
var
  SrcReg, TrgReg: TXRegistry;
  i: Integer;
  ValueName: string;
  AnswerToAll: Integer;

  function AskForReplacing(const ValueName: string): Integer;
  begin
    if AnswerToAll = -1 then begin
      Result := MessageDlg(
        'Value ' + Quote(ValueName) + 'already exists in target key.' + EOL +
        'Do you want to replace it?',
        mtWarning, [mbNo, mbYes, mbNoToAll, mbYesToAll, mbAbort], 0);
      if Result in [mrNoToAll, mrYesToAll] then begin
        if Result = mrYesToAll then
          Result := mrYes
        else if Result = mrNoToAll then
          Result := mrNo;
        AnswerToAll := Result;
      end;
    end else Result := AnswerToAll;
  end;

begin
  AnswerToAll := -1;

  if not CopyWanted then
    if mrYes<>MessageDlg(
     Format(
      'Do you really want to move %s' + EOL +
      'from: %s' + EOL +
      'to: %s',
      [StrNumerus(ValueList.SelCount, 'value', 'values'),
       PathOfNode(SrcNode), PathOfNode(TrgNode)]
     ), mtConfirmation, [mbYes, mbAbort], 0) then
      Exit;

  SrcReg := TXRegistry.Create;
  try
    if not (OpenNode(SrcReg, SrcNode) in onOK) then
      MessageDlg('Couldn''t open source key: ' + PathOfNode(SrcNode),
        mtError, [mbOK], 0);

    TrgReg := TXRegistry.Create;
    try
      if not (OpenNode(TrgReg, TrgNode) in onOK) then
        MessageDlg('Couldn''t open target key: ' + PathOfNode(TrgNode),
          mtError, [mbOK], 0);

      with ValueList.Items do begin
        for i := 0 to Count-1 do begin
          if not Item[i].Selected then
            Continue;
          ValueName := RealValueName(Item[i]);

          if TrgReg.ValueExists(ValueName) then begin
            case AskForReplacing(ValueName) of
              mrYes: ;
              mrNo: Continue;
              mrAbort: Break;
            end;
          end;

          TrgReg.WriteContext(ValueName, SrcReg.ReadContext(ValueName));
          if not CopyWanted then
            SrcReg.DeleteValue(ValueName);
        end;
      end;

    finally
      TrgReg.Free;
    end;

  finally
    SrcReg.Free;
  end;

  if not CopyWanted then
    ValuesWin.Reload;
end;

procedure TTreeWin.NewSubKeyMIClick(Sender: TObject);
begin
  CreateKey(True);
end;

procedure TTreeWin.NewKeyMIClick(Sender: TObject);
begin
  CreateKey(False);
end;

procedure TTreeWin.CreateShortcutMIClick(Sender: TObject);
begin
  NewShortcut;
end;

procedure TTreeWin.TraceMIClick(Sender: TObject);
begin
  if NodeInfo(RegTV.Selected).IsShortcut then
    MainWin.GotoKey(TraceKey(PathOfNode(RegTV.Selected)));
end;

procedure TTreeWin.DeleteMIClick(Sender: TObject);
begin
  if not RegTV.IsEditing then
    DeleteKey;
end;

procedure TTreeWin.DublicateMIClick(Sender: TObject);
begin
  CloneKey;
end;

procedure TTreeWin.FindMIClick(Sender: TObject);
begin
  FindWin.SfCurKeyRB.Checked := True;
  FindWin.Show;
end;

procedure TTreeWin.RegTVPUPopup(Sender: TObject);
begin
  RegTVChange(Sender, RegTV.Selected);
  with NodeInfo(RegTV.Selected) do begin
    NewSubKeyMI.Enabled := not CantWrite;
    NewKeyMI.Enabled := not CantWrite and (not IsHost or IsShortcut);
    DublicateMI.Enabled := not CantWrite and not IsHost;

    with DeleteMI do
      if HostType = uhUserShortcut then begin
        Caption := '&Delete Shortcut';
        Enabled := True;
      end else begin
        Caption := '&Delete';
        Enabled := not CantWrite and not IsHost;
      end;

    RenameMI.Enabled := not CantWrite and (HostType in [uhNone, uhUserShortcut]);
    TraceMI.Visible := IsShortcut;
    EditShortcutMI.Visible := HostType = uhUserShortcut;
  end;
end;

procedure CheckNode(Node: TTreeNode; OnlyOnce: Boolean = True;
  TakeNodeSelected: Boolean = False);
var
  CurIcon, NewIcon: Integer;
  Reg: TXRegistry;
  OpenMode: TOpenNodeMode;
  Info: TNodeInfo;
{$IFDEF UNIKEY}
  Uni: TUniKey;
{$ENDIF}
  KeyHasChildren: Boolean;

  procedure SetShortcutIcon(Node: TTreeNode);
  var
    Full: string;
    i: Integer;
  begin
    Full := TraceKey(PathOfNode(Node));
    for i := Low(Shortcuts) to High(Shortcuts) do
      if Full = Shortcuts[i].RealPath then begin
        CurIcon := Shortcuts[i].Node.ImageIndex;
      Exit; end;
    if Node.ImageIndex in [iconShortcut, iconShortcut + 1] then
      CurIcon := iconKey + (CurIcon - iconShortcut);
  end;

begin
  if not Assigned(Node) then
    Exit;

  Info := NodeInfo(Node);
  if OnlyOnce and Info.Checked then
    Exit;

  CurIcon := Node.ImageIndex;
  if (CurIcon > iconFirstType) then begin
{$IFDEF UNIKEY}
    if RootOfNode(Node).ImageIndex <> iconHostUni then begin
      SetShortcutIcon(Node);
      CurIcon := (CurIcon div 2) * 2;
    end;
{$ELSE}
    Exit;
{$ENDIF}
  end else begin
    SetShortcutIcon(Node);
    CurIcon := (CurIcon div 2) * 2;
  end;
  NewIcon := CurIcon;

  Info.ExcludeFlag(nfDefect);
  Info.ExcludeFlag(nfReadOnly);

{$IFDEF UNIKEY}
  KeyHasChildren := False;

  if RootOfNode(Node).ImageIndex = iconHostUni then begin
    Uni := UniOfNode(Node);
    if Assigned(Uni) then
      try
        KeyHasChildren := Uni.HasKeys;
        if usReadOnly >= Uni.Skills then
          OpenMode := onReadOnly
        else
          OpenMode := onFull;
      finally
        Uni.Free;
      end
    else
      OpenMode := onError;
  end else begin
{$ENDIF}
  Reg := TXRegistry.Create;
  try
    OpenMode := OpenNode(Reg, Node);
    KeyHasChildren := Reg.HasSubKeys;
  finally
    Reg.Free;
  end;
{$IFDEF UNIKEY}
  end;
{$ENDIF}

  if OpenMode = onReadOnly then
    Info.IncludeFlag(nfReadOnly);

  if OpenMode in onOK then begin
    //OK, could open
    if not Node.Expanded then begin  //Collapsed
      if KeyHasChildren then begin  //HasSubKeys
        if not Node.HasChildren then begin
          //Update: Ensure HasChildren
          if TakeNodeSelected or Node.Selected then
            TreeWin.RegTV.Items.AddChild(Node, '');
        end;
        //Ensure Plus-Icon
        NewIcon := CurIcon + 1;
      end else begin
        //Has still Children?
        if Node.HasChildren then
          Node.DeleteChildren;
      end;

    end else begin             //Expanded
      //HasSubKeys?
      if KeyHasChildren then begin
        //OK
        NewIcon := CurIcon + 1;
      end else begin
        //not OK --> update
        Node.Collapse(True);
        Node.DeleteChildren;
      end;
    end;

  //not OK, couldn't open
  end else begin //defect
    if Node.HasChildren then
      Node.DeleteChildren;
    Info.IncludeFlag(nfDefect);
  end;

  if Node.ImageIndex <> iconHostUni then //don't change icon of UniHosts
    Node.ImageIndex := NewIcon;

  Info.IncludeFlag(nfChecked);
end;

procedure TTreeWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MainWin.FormKeyDown(Sender, Key, Shift);
end;

function ShortcutIndex(Node: TTreeNode): Integer;
//If Node is a Shortcut,
//S. returns its index in the Shortcuts array
//else -1
begin
  if Node.Level > 0 then begin
    Result := -1;
  Exit; end;

  for Result := 0 to High(Shortcuts) do
    if Shortcuts[Result].Node = Node then begin
      Exit;
    end;

  Result := -1;
end;

function TraceKey(const Path: string; AllowedShortcutTypes: TUniHostTypes =
  uhNonSystemShortcuts): string;
var
  i: Integer;
  isAim: Boolean;

  function NodeOkForTracing(Node: TTreeNode): Boolean;
  begin
    Result := Assigned(Node) and
      (NodeInfo(Node).HostType in AllowedShortcutTypes);
  end;

begin
  Result := MakeLongHKEY(Path);
  repeat
    isAim := True;
    for i := 0 to High(ShortCuts) do begin
      with Shortcuts[i] do
        if NodeOkForTracing(Node) and
         SameText(UntilChar(Result, '\'), Alias) then begin
          if Alias = RealPath then
            Break;
          Delete(Result, 1, Length(Alias));
          Result := RealPath + Result;
          isAim := False;
        Break; end;
    end;
  until isAim;
end;

procedure TTreeWin.RegTVKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '*') and NoAsterisk then begin
    Key := #0;
    NoAsterisk := False;
  end;
end;

procedure TTreeWin.RegTVAdvancedCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
  var PaintImages, DefaultDraw: Boolean);
var
  Rect: TRect;
  MainValueName: string;
  Reg: TXRegistry;
  Info: TRegKeyInfo;
  PreviewPosX: Integer;

  procedure DefaultIconPreview(Reg: TXRegistry);
  var
    Icon: HICON;
    IconFile: string;
  begin
    if (Node.Level = 0) and not RegTV.ShowLines then
      Exit;

    IconFile := Reg.ReadDefaultIcon;
    if IconFile = '' then
      Exit;

    Icon := GetIconFromFile(ExpandString(IconFile));
    if Icon = 0 then
      Exit;

    with Rect do begin
      Dec(Left, TTreeView(Sender).Indent + 16);
      DrawIconEx(Sender.Canvas.Handle, Left, Top,
                 Icon, 16, 16,
                 0, 0, DI_NORMAL);
      DestroyIcon(Icon);
    end;
  end;

  procedure AddPreview(const PreviewText: string; Color: TColor);
  begin
    with Sender.Canvas do begin
      SetTextColor(Handle, Color);
      ExtTextOut(Handle, PreviewPosX, Rect.Top + 1, TextFlags, nil,
        PChar(PreviewText), Length(PreviewText), nil);
      Inc(PreviewPosX, TextWidth(PreviewText));
    end;
  end;

begin
  if Stage <> cdPostPaint then
    Exit;

  MainValueName := PrefWin.MainPreviewE.Text;

  Rect := Node.DisplayRect(True);
  PreviewPosX := Rect.Right + 5;

  Reg := TXRegistry.Create(KEY_READ);
  try
    if OpenNodeOK(Reg, Node) then begin
//      Sender.Canvas.Font.Style := [];
      if PrefWin.KeyInfoPreviewCB.Checked and Reg.GetKeyInfo(Info) then
        with Info do begin
          if NumSubKeys > 0 then
            AddPreview(IntToStr(NumSubKeys) + 'k  ', clCyan);
          if NumValues > 0 then
            AddPreview(IntToStr(NumValues) + 'v  ', clBrightPurple);
        end;

      if PrefWin.MainPreviewCB.Checked then
        if Reg.ValueReallyExists(MainValueName) then
          AddPreview(DataPreviewOfContext(Reg.ReadContext(MainValueName)), $00AAFFFF);
                                                         {clBrightYellow}
      if PrefWin.DefaultIconPreviewCB.Checked then
        DefaultIconPreview(Reg);
    end;
  finally
    Reg.Free;
  end;

  {if nfCopy in NodeInfo(Node).Flags then begin
    //Node.StateIndex := 2;
    Brush.Style := bsClear;
    with Font do begin
      Style := [fsItalic, fsBold];
      Color := clRed;
    end;
    //TextOut(Rect.Left - 10, Rect.Top + 3, 'c');
  end;}
end;

procedure TTreeWin.RenameMIClick(Sender: TObject);
begin
  RegTV.Selected.EditText;
end;

procedure TTreeWin.CopyPathMIClick(Sender: TObject);
begin
  UserCopyKeyFlag := True;
  MainWin.CopyPathClick(Sender);
end;

procedure TTreeWin.InsertPathMIClick(Sender: TObject);
begin
  MainWin.InsertPathClick(Sender);
end;

procedure TTreeWin.RegTVGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  if not NodeInfo(Node).Checked then
    CheckNode(Node);
end;

procedure TTreeWin.CheckRegTVHotTrack;
const
  FindCursorOfSwitch: array[Boolean] of TCursor = (crArrow, crHandPoint);
var
  NewHotTrack: Boolean;
begin
  NewHotTrack := ScrollON xor PrefWin.KeysSingleClickCB.Checked;
  if NewHotTrack = RegTV.HotTrack then Exit;

  with RegTV do begin
    HotTrack := NewHotTrack;
    Cursor := FindCursorOfSwitch[HotTrack];
    Mouse.CursorPos := Mouse.CursorPos; //update cursor
  end;
end;

procedure TTreeWin.PasteKeyMIClick(Sender: TObject);
var
  Src, Trg: TRegPath;
  Node: TTreeNode;
begin
  Src := RegPathOfStr(Clipboard.AsText);
  Trg := CurKey(uhNonSystemShortcuts);
  Trg.Key := Trg.Key + '\' + FromLastChar(Src.Key, '\', True);

  MoveKey(Src, Trg, UserCopyKeyFlag);

  Node := RegTV.Selected;
  if Node.Expanded then
    Node.Collapse(False);
  Node.Expanded := False;
  CheckNode(Node, False);
  Node.Expand(False);

  if not UserCopyKeyFlag then
    RegTV.Repaint; // CheckNode(Node, False);

  UserCopyKeyFlag := True;
end;

procedure TTreeWin.CutPathMIClick(Sender: TObject);
begin
  UserCopyKeyFlag := False;
  MainWin.CopyPathClick(Sender);
end;

procedure TTreeWin.OpenNextLevel(Node: TTreeNode);

  procedure ExpandKeys(Node: TTreeNode);
  begin
    CheckNode(Node, False, True);
    if not Node.HasChildren then
      Exit;
    if not Node.Expanded then
      Node.Expand(False)
    else begin
      Node := Node.GetFirstChild;
      while Assigned(Node) do begin
        ExpandKeys(Node);
      Node := Node.GetNextSibling; end;
    end;
  end;

begin
  DoSmartExpand := False;
  ExpandKeys(Node);
  DoSmartExpand := True;
end;

procedure TTreeWin.EditShortcutMIClick(Sender: TObject);
var
  NewPath: string;
  i: Integer;
  Node: TTreeNode;
  Shortcut: PKeyShortcut;
begin
  Node := RegTV.Selected;
  if NodeInfo(Node).HostType <> uhUserShortcut then
    Exit;

  i := ShortcutIndex(Node);
  if i = -1 then
    Exit;

  with TIniFile.Create(PlutoDir + 'Shortcuts.ini') do
    try
      NewPath := ReadString('Shortcuts', Shortcuts[i].Alias, '');
    finally
      Free;
    end;

  if not InputQuery('Edit Shortcut', 'Shortcut to...', NewPath) then
    Exit;

  Node.Collapse(False);
  Shortcut := @Shortcuts[i];
  Shortcut.RealPath := TraceKey(NewPath);
  with TIniFile.Create(PlutoDir + 'Shortcuts.ini') do
    try
      WriteString('Shortcuts', Shortcut.Alias, Shortcut.RealPath);
    finally
      Free;
    end;

  RegTVChange(Self, Node);
end;

procedure TTreeWin.SubKeylist1Click(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  if OpenCurKey then
  try
    MainReg.GetKeyNames(SL);
    if PrefWin.SortKeysCB.Checked then
      SL.Sort;
    Clipboard.AsText := SL.Text;
  finally
    MainReg.CloseKey;
    SL.Free;
  end;
end;

procedure TTreeWin.ValueNameslist1Click(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  if OpenCurKey then
  try
    MainReg.GetValueNames(SL);
      if PrefWin.SortKeysCB.Checked then
        SL.Sort;
      Clipboard.AsText := SL.Text;
  finally
    MainReg.CloseKey;
    SL.Free;
  end;
end;

procedure TTreeWin.KeyInfosMIClick(Sender: TObject);
begin
  MessageDlg(GetKeyInfos, mtInformation, [mbOK], 0);
end;

function TTreeWin.GetKeyInfos: string;
const
  sErrorMsg = 'Error! No: %d Msg: %s';

var
  Node: TTreeNode;
  Reg: TXRegistry;
  Mode: TOpenNodeMode;
  Error: Integer;
  Info: TNodeInfo;
  Flag: TNodeFlag;

  procedure Add(const S: string);
  begin
    Result := Result + S;
  end;

  procedure AddLn(const S: string = '');
  begin
    Add(S + EOL);
  end;

  procedure AddNodeInfo(Key: HKEY);
  var
    KeyInfo: TRegKeyInfo;
    Res: Integer;
    KeyAge: TDateTime;
  begin
    FillChar(KeyInfo, SizeOf(TRegKeyInfo), 0);
    with KeyInfo do begin
      Res := RegQueryInfoKey(Reg.CurrentKey, nil, nil, nil, @NumSubKeys,
        @MaxSubKeyLen, nil, @NumValues, @MaxValueLen,
        @MaxDataLen, nil, @LastWriteTime);

      if Res = ERROR_SUCCESS then begin
        Add(Format(
          'Subkeys: %0:d' + EOL +
          'Values: %2:d' + EOL +
          'Max subkeys length: %1:d' + EOL +
          'Max value name length: %3:d' + EOL +
          'Max data length: %4:d' + EOL +
          '',
          [NumSubKeys, MaxSubKeyLen, NumValues, MaxValueLen, MaxDataLen]));
        KeyAge := DateTimeOfFileTime(LastWriteTime);
        if KeyAge > 0 then
          AddLn('Last write time: ' + DateTimeToStr(KeyAge));
      end else
        AddLn('Couldn''t get key info.' + EOL +
          'Error Code: ' + IntToStr(Res) + EOL +
          'Message: ' + SysErrorMessage(Res));
    end;
  end;

begin
  Result := '';
  Node := RegTV.Selected;

  Reg := TXRegistry.Create(KEY_READ);
  try
    try
      Error := OpenNodeError(Reg, RegTV.Selected, Mode);

      case Mode of
      onFull: AddLn('Full Access');
      onReadOnly: AddLn('Read only');
      onError:
        AddLn(Format(sErrorMsg, [Error, SysErrorMessage(Error)]));
      onNodeNil: AddLn('Node is nil!');

      else
        AddLn('Unknown Mode: ' + IntToStr(Integer(Mode)));
      end;

      if Mode in onOK then
        AddNodeInfo(Reg.CurrentKey);

    except
      on E: Exception do begin
        Error := GetLastError;
        if Error <> ERROR_SUCCESS then
          AddLn(Format('Error! No: %d Msg: %s', [Error, SysErrorMessage(Error)]))
        else
          AddLn(E.Message);
      end;
    end;
  finally
    Reg.Free;
  end;

  if MurphyMode then begin
    AddLn('[MM] ImageIndex: ' + IntToStr(Node.ImageIndex));
    Info := NodeInfo(Node);

    if Info.HostType in [uhNone..High(HostTypeStrings)] then
      AddLn('[MM] HostType: ' + HostTypeStrings[Info.HostType])
    else
      AddLn('[MM] Unknown HostType: ' + IntToStr(Integer(Info.HostType)));
    Add('[MM] Flags: ');
    for Flag := Low(TNodeFlag) to High(TNodeFlag) do
      if Flag in Info.Flags then
        Add(NodeFlagStrings[Flag] + ' ');
    AddLn;
  end;
end;

procedure TTreeWin.ExportAsRegClick(Sender: TObject);
var
  Node: TTreeNode;
  Reg: TXRegistry;

  procedure ExportAsReg4(Reg: TXRegistry; const FileName: string);
  var
    Reg4Writer: TReg4Writer;
  begin
    Reg4Writer := TReg4Writer.Create(tpNormal, FileName,
     TraceKey(PathOfNode(Node)), Reg.DeliverKey);
    with Reg4Writer do begin
      OnTerminate := Reg4WriterTerminate;
      try
        AddHint(Format('starting .reg-export: %s...',
          [Root + '\' + Path]));
        Resume;
      except
        Free;
      end;
    end;
    AddToLastHint('started.');
  end;


  procedure ExportAsHive(Reg: TXRegistry; const FileName: string);
  begin
    if Reg.SaveKey('', FileName) then
      AddHint('hive export successfull.')
    else
      AddHint(Format('hive export failed: %s',
        [SysErrorMessage(LastSuccessRes)]));
  end;

begin
  Node := RegTV.Selected;
  with ExportD do begin
    FileName := MakeValidFileName(Node.Text, 'key');

    if Execute then begin
      Reg := TXRegistry.Create;
      try
        if OpenNodeOK(Reg, Node) then begin
          if FileExists(FileName) and (mrYes=MessageDlg(
           'File already exists.' + EOL +
           'Delete existing file?',
           mtWarning, [mbYes, mbNo], 0)) then begin
            FileSetAttr(FileName, 0);
            DeleteFile(FileName);
          end;
          case FilterIndex of
          1: ExportAsReg4(Reg, FileName);
          2: ExportAsHive(Reg, FileName);
          else
            ShowMessage(Format('Wrong Filter: %d', [FilterIndex]));
          end;
        end;
      finally
        Reg.Free;
      end;
    end;
  end;
end;

procedure TTreeWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Action := caNone;
end;

procedure TTreeWin.Load;
var
  NodeHKLM, NodeHKU, NodeHKDD, NodeHKPD: TTreeNode;
  NodeHostReg: TTreeNode;

  procedure LoadShortcuts(FileName: string; HostType: TUniHostType);
  var
    i: Integer;
    SL: TStringList;
    ShortcutIni: TIniFile;
  begin
    if not FileEx(FileName) then begin
      AddToLastHint('not found:');
      AddHint(FileName);
    Exit end;

    ShortcutIni := TIniFile.Create(FileName);
    SL := TStringList.Create;

    try
      ShortcutIni.ReadSectionValues('Shortcuts', SL);
      for i := 0 to SL.Count-1 do
        AddShortcut(SL.Names[i], SL.Values[SL.Names[i]], iconShortcut,
          HostType);
      AddToLastHint('OK');
    finally
      SL.Free;
      ShortcutIni.Free;
    end;
  end;

begin
  NodeHostReg := nil;

  AddHint('Creating Hosts...');
  RootNodes := TList.Create;
  ChangeLastHint('Creating Hosts...HKEY_LOCAL_MACHINE');
  NodeHKLM := RegTV.Items.AddChild(NodeHostReg, 'HKEY_LOCAL_MACHINE');
  SetTNImage(NodeHKLM, iconHKLM);
  NodeInfo(NodeHKLM).HostType := uhReg;
  RootNodes.Add(NodeHKLM);

  ChangeLastHint('Creating Hosts...HKEY_USERS');
  NodeHKU := RegTV.Items.AddChild(NodeHostReg, 'HKEY_USERS');
  SetTNImage(NodeHKU, iconHKU);
  NodeInfo(NodeHKU).HostType := uhReg;
  RootNodes.Add(NodeHKU);

  ChangeLastHint('Creating Hosts...HKEY_CURRENT_USER');
  if RegRealPath('HKEY_CURRENT_USER') = 'HKEY_CURRENT_USER' then
  //could not dereference hkcu
    AddShortcut('HKEY_CURRENT_USER', 'HKEY_CURRENT_USER',
      iconHKCU, uhReg)
  else
    AddShortcut('HKEY_CURRENT_USER', RegRealPath('HKEY_CURRENT_USER'),
      iconHKCU, uhSystemShortcut);

  ChangeLastHint('Creating Hosts...HKEY_CURRENT_CONFIG');
  AddShortcut('HKEY_CURRENT_CONFIG', RegRealPath('HKEY_CURRENT_CONFIG'),
    iconHKCC, uhSystemShortcut);

  ChangeLastHint('Creating Hosts...HKEY_CLASSES_ROOT');
  AddShortcut('HKEY_CLASSES_ROOT', RegRealPath('HKEY_CLASSES_ROOT'),
    iconHKCR, uhSystemShortcut);

  MainReg.RootKey := HKEY_DYN_DATA;
  if MainReg.OpenKeyReadOnly('') then begin
    MainReg.CloseKey;
    ChangeLastHint('Creating Hosts...HKEY_DYN_DATA');
    NodeHKDD := RegTV.Items.AddChild(nil, 'HKEY_DYN_DATA');
    NodeInfo(NodeHKDD).HostType := uhReg;
    NodeInfo(NodeHKDD).IncludeFlag(nfReadOnly);
    SetTNImage(NodeHKDD, iconHKDD);
    RootNodes.Add(NodeHKDD);
  end;

  MainReg.RootKey := HKEY_PERFORMANCE_DATA;
  if MainReg.OpenKeyReadOnly('') then begin
    MainReg.CloseKey;
    ChangeLastHint('Creating Hosts...HKEY_PERFORMANCE_DATA');
    NodeHKPD := RegTV.Items.AddChild(nil, 'HKEY_PERFORMANCE_DATA');
    NodeInfo(NodeHKPD).HostType := uhReg;
    SetTNImage(NodeHKPD, iconHKPD);
    RootNodes.Add(NodeHKPD);
  end;

  ChangeLastHint('Creating Host...OK');

  AddHint('Loading Standard Shortcuts...');
  LoadShortcuts(PlutoDir + StandardShortcutsFileName, uhStandardShortcut);

  AddHint('Loading User Shortcuts...');
  LoadShortcuts(PlutoDir + ShortcutsFileName, uhUserShortcut);

{$IFDEF UNIKEY}
  AddShortcut('Uni', '', iconHostUni);
{$ENDIF}
end;

procedure TTreeWin.Reg4WriterTerminate(Sender: TObject);
begin
  with Sender as TRegFileWriter do
    AddHint(Format('.reg-export finished (%0.2f s): %s',
      [Clk.SecsPassed, Root + '\' + Path]));
end;

end.
unit valuesU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Menus, Clipbrd, XReg, CompEx, Math, YTools, Dialogs, YTypes,
  PlutoConst, keybrd, ImgList, clock;

type
  TValuesWin = class(TForm)
    ValueListPU: TPopupMenu;
    NewStringMI: TMenuItem;
    NewDWORDMI: TMenuItem;
    NewBinaryMI: TMenuItem;
    ConvertToMI: TMenuItem;
    ConvStringMI: TMenuItem;
    ConvDWORDMI: TMenuItem;
    ConvBinaryMI: TMenuItem;
    ValueList: TListView;
    DeleteMI: TMenuItem;
    N1: TMenuItem;
    RenameMI: TMenuItem;
    NewElseMI: TMenuItem;
    NewMultiStringMI: TMenuItem;
    REGNONE1: TMenuItem;
    LINK1: TMenuItem;
    NewExpandStringMI: TMenuItem;
    N3BINARY1: TMenuItem;
    N4DWORD1: TMenuItem;
    N4DWORDLITTLEEDIAN1: TMenuItem;
    NewBigEndianMI: TMenuItem;
    N6LINK1: TMenuItem;
    N7MULTISZ1: TMenuItem;
    RESOURCELIST1: TMenuItem;
    N9FULLRESOURCEDESCRIPTOR1: TMenuItem;
    ARESOURCEREQUIREMENTSLIST1: TMenuItem;
    NewDefaultValueMI: TMenuItem;
    EditMI: TMenuItem;
    EditBinaryMI: TMenuItem;
    N3: TMenuItem;
    CopyDataPreviewMI: TMenuItem;
    DublicateMI: TMenuItem;
    MultiString1: TMenuItem;
    ZeromizeMI: TMenuItem;
    N4: TMenuItem;
    CopyPathMI: TMenuItem;
    TakeAsMainValueMI: TMenuItem;
    SelectAllMI: TMenuItem;
    InvertSelectionMI: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure InitListColumnTags;

    procedure NewStringMIClick(Sender: TObject);
    procedure NewDWORDMIClick(Sender: TObject);
    procedure NewBinaryMIClick(Sender: TObject);
    procedure ConvertValue(Sender: TObject);

    procedure CreateValue(Typ: TRegDataType);
    procedure ZeromizeValue;
    procedure DeleteValue;
    procedure CloneValue;
    function TryRenameValue(OldName: string; var NewName: string): Boolean;

    procedure ValueListChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ValueListCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ValueListDblClick(Sender: TObject);
    procedure ValueListEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure ValueListEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure ValueListKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ValueListResize(Sender: TObject);

    function UpdateValue(Reg: TXRegistry; Item: TListItem): Boolean;
    procedure UpdateValues(SelectedOnly: Boolean = False);
    procedure Reload(JumpToNewValue: Boolean = False; ValueName: string = '');
    procedure LoadValues(Reg: TXRegistry);

    function AddValue(Reg: TXRegistry; const ValueName: string; AppendInfos: Boolean = True): TListItem;
    procedure ValueListPUPopup(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ValueListDeletion(Sender: TObject; Item: TListItem);
    procedure DeleteMIClick(Sender: TObject);
    procedure RenameMIClick(Sender: TObject);
    procedure NewBigEndianMIClick(Sender: TObject);
    procedure NewExpandStringMIClick(Sender: TObject);
    procedure NewMultiStringMIClick(Sender: TObject);
    procedure NewStrangeTypeMIClick(Sender: TObject);
    procedure NewDefaultValueMIClick(Sender: TObject);
    procedure ValueListChanging(Sender: TObject; Item: TListItem; Change: TItemChange; var AllowChange: Boolean);
    procedure ValueListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditBinaryMIClick(Sender: TObject);
    procedure EditMIClick(Sender: TObject);
    procedure ValueListCustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ValueListCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ValueListColumnClick(Sender: TObject; Column: TListColumn);
    procedure DublicateMIClick(Sender: TObject);
    procedure CopyDataPreviewMIClick(Sender: TObject);
    procedure CopyDataPreview;
    procedure ZeromizeMIClick(Sender: TObject);
    procedure CopyPathMIClick(Sender: TObject);

    function FindItemByRealName(const ValueName: string): Integer;

    function FocusItem(ARealValueName: string;
      FocusValueList: Boolean = False): Boolean;
    procedure TakeAsMainValueMIClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ValueListClick(Sender: TObject);
    procedure CheckValueListHotTrack;
    procedure SelectAllMIClick(Sender: TObject);
    procedure InvertSelectionMIClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    ValueLabelClicked: Boolean;
    SortBy: TValueListColumn;
    SortByColumn: TListColumn;
    SubItemIndex: array[TValueListColumn] of Integer;
  public
    ValueNames: TStringList;
    ValuesCommon: Boolean;
    ValueCommonType: TRegDataType;
 end;

var
  ValuesWin: TValuesWin;
  ValueList: TListView;

  DefaultValueCaption: string = '';

function ItemIsDefaultValue(Item: TListItem): Boolean;
function RealValueName(Item: TListItem): string;
procedure SetRealValueName(Item: TListItem; Caption: string);
function IconOfDataType(Typ: TRegDataType): Integer;
function IsMainValue(Item: TListItem): Boolean;

function ColorOfDataType(DataType: TRegDataType;
  DefaultColor: TColor = clWhite): TColor;
function DataPreviewOfContext(Context: TRegContext): string;

function ValueDataSize(Context: TRegContext): string;
function ValueDataType(Context: TRegContext): string;
function ValueDataPreview(Context: TRegContext): string;
function ValueTypeIcon(Context: TRegContext): Integer;

function StrOfRegDataType(Typ: TRegDataType): string;

implementation

uses PlutoMain, TreeU, WorkU, PrefU;

{$R *.dfm}

function ItemIsDefaultValue(Item: TListItem): Boolean;
begin
  Result := Item.Data = Pointer(DefaultValueFlag);
end;

function RealValueName(Item: TListItem): string;
begin
  if ItemIsDefaultValue(Item) then
    Result := ''
  else
    Result := Item.Caption;
end;

procedure SetRealValueName(Item: TListItem; Caption: string);
begin
  if Caption = '' then begin
    Item.Caption := DefaultValueCaption;
    Item.Data := Pointer(DefaultValueFlag);
  end else begin
    Item.Caption := Caption;
    Item.Data := nil;
  end;
end;

function IsMainValue(Item: TListItem): Boolean;
begin
  Result := False;
  if csDestroying in PrefWin.ComponentState then
    Exit;
    
  Result := RealValueName(Item) = PrefWin.MainPreviewE.Text;
end;

function ColorOfDataType(DataType: TRegDataType;
  DefaultColor: TColor = clWhite): TColor;
begin
       if DataType in rdStringTypes then Result := clBrightRed
  else if DataType =  rdMultiString then Result := clBrightPurple
  else if DataType in rdCardTypes   then Result := clBrightBlue
  else if DataType =  rdBinary      then Result := clBrightGreen
  else Result := DefaultColor;
end;

function StrOfRegDataType(Typ: TRegDataType): string;
const
  RegDataTypeStrings: array[rdNone..rdLastType] of string = (
    'NONE',
    'SZ',
    'EXPAND_SZ',
    'BINARY',
    'DWORD',
    'DWORD_BIG_ENDIAN',
    'LINK',
    'MULTI_SZ',
    'RESOURCE_LIST',
    'FULL_RESOURCE_DESCRIPTOR',
    'RESOURCE_REQUIREMENTS_LIST',
    'QUAD_WORD'
  );
begin
  if Typ in [rdNone..rdLastType] then
    Result := RegDataTypeStrings[Typ]
  else
    Result := IntToStr(Typ);
end;

procedure TValuesWin.NewStringMIClick(Sender: TObject);
begin
  CreateValue(rdString);
end;

procedure TValuesWin.NewDWORDMIClick(Sender: TObject);
begin
  CreateValue(rdCardinal);
end;

procedure TValuesWin.NewBinaryMIClick(Sender: TObject);
begin
  CreateValue(rdBinary);
end;

procedure TValuesWin.CreateValue(Typ: TRegDataType);
var
  Item: TListItem;
  ValueName: string;
  i: Integer;
  SL: TStringList;
begin
  if csDestroying in (TreeWin.ComponentState + MainWin.ComponentState) then
    Exit;
    
  if TreeWin.CantWrite then
    Exit;

  with MainReg do begin
    try
      OpenCurKey;

      ValueName := 'New'; // find free name
      i := 0;
      while ValueExists(ValueName) do begin
        Inc(i);
        ValueName := 'New ' + IntToStr(i);
      end;

      case Typ of
        rdString: begin
            WriteString(ValueName, '');
          end;
        rdExpandString: begin
            WriteExpandString(ValueName, '');
          end;
        rdCardinal: begin
            WriteCardinal(ValueName, 0);
          end;
        rdCardBigEndian: begin
            WriteCardinal(ValueName, 0, True);
          end;
        rdMultiString: begin
            SL := TStringList.Create;
            WriteMultiString(ValueName, SL);
            SL.Free;
          end;
        rdBinary: begin
            WriteBin(ValueName, nil);
          end;
        else
          WriteBinType(ValueName, nil, Typ);
      end;

      if not ValueExists(ValueName) then begin
        ShowMessage('Could not create Value.');
        CloseKey;
      Exit; end;

      ValuesWin.AddValue(MainReg, ValueName);
    finally
      CloseKey;
    end;
  end;

  Item := FindItem(ValueList, ValueName);

  if not Assigned(Item) then begin
    ShowMessage('Error, Value not found: ' + ValueName);
  Exit; end;

  SelectItemOnly(ValueList, Item);
  MainWin.StatusBarUpdate;
  ValueLabelClicked := True;
  Item.EditCaption;
end;

procedure TValuesWin.FormCreate(Sender: TObject);
begin
  ValuesU.ValueList := ValueList;

  DefaultValueCaption := PrefWin.DefaultValueNameE.Text;
  ValueLabelClicked := False;
  SortBy := vlcName;
  SortByColumn := nil;

  ValueListResize(Sender);
  ValueList.Items.Clear;
  CheckValueListHotTrack;

  ValueNames := TStringList.Create;
  ValuesCommon := False;
  ValueCommonType := 0;

  NewDefaultValueMI.ImageIndex := iconMainValue;
  NewStringMI.ImageIndex := iconString;
  NewDWORDMI.ImageIndex := iconCardinal;
  NewBinaryMI.ImageIndex := iconBinary;
  NewMultiStringMI.ImageIndex := iconMultiString;
  NewElseMI.ImageIndex := iconValueElse;

  DublicateMI.ImageIndex := iconValueDublicate;
  DeleteMI.ImageIndex := iconDelete;
  ZeromizeMI.ImageIndex := iconValueZeromize;

  EditMI.ImageIndex := iconValueEdit;
  EditBinaryMI.ImageIndex := iconValueEditBinary;
  RenameMI.ImageIndex := iconRename;

  TakeAsMainValueMI.ImageIndex := iconTakeAsMainValue;
end;

procedure TValuesWin.ConvertValue(Sender: TObject);
{var
  Allow: Boolean;
  OldActive: Integer;  }
begin
{  TargetPage := ShowPC.Pages[TMenuItem(Sender).Tag];

  OldActive := ShowPC.ActivePageIndex;
  ShowPC.ActivePageIndex := TMenuItem(Sender).Tag;
  WorkWin.ShowPCChanging(Sender, Allow);
  if not Allow then
    ShowPC.ActivePageIndex := OldActive; }
end;

function ValueDataSize(Context: TRegContext): string;
var
  Typ: TRegDataType;
  Size: Integer;
//  ValueName: string;
//  SL: TStringList;
begin
  Result := '';

  if csDestroying in PrefWin.ComponentState then
    Exit;

//  ValueName := RealValueName(Item);
  Typ := Context.Typ;
  Size := Length(Context.Data);

  if Typ in rdStringTypes then
    if not PrefWin.CountZeroByteCB.Checked then
      Dec(Size);
      
  if Typ = rdMultiString then
    if PrefWin.ShowLineCountCB.Checked then begin
      Size := CharCount(StrOfByteA(Context.Data), #0) - 2;
{      SL := TStringList.Create;
      try
        Reg.ReadMultiString(ValueName, SL, PrefWin.UseExtendedModelCB.Checked);
        Size := SL.Count;
      finally
        SL.Free;
      end;    }
      Result := '#';
    end;

  Result := Result + IntToStr(Size);
end;

function ValueDataType(Context: TRegContext): string;
begin
  Result := StrOfRegDataType(Context.Typ);
end;

function DataPreviewOfContext(Context: TRegContext): string;

  function DWORDPreview(Value: Integer): string;
  begin
    if PrefWin.ShowDwordAsHex.Checked then
      Result := IntToStr(Value) + ' = $' + IntToHex(Value, 8)
    else
      Result := IntToStr(Value)
  end;

  function BinaryPreview(Context: TRegContext): string;
  var
    z: string;

    function DWORDStringOfByteA(a: TByteA; AddBinary: Boolean = False): string;
    var
      piece: TByteA;
      i: Integer;
    begin
      Result := '';

      i := 0;
      while (i <= High(a)) and (Length(Result) < MaxPreviewLen) do begin
        piece := Copy(a, i, 4);
        if AddBinary then
          Result := Result + FriendlyStr(piece) + '=';
        SetLength(piece, 4);
        Result := Result + IntToStr(PInteger(piece)^) + '  ';
        Inc(i, SizeOf(Integer));
      end;
    end;

  begin
    with Context do begin
      Data := Copy(Data, 0, MaxPreviewLen);
      case PrefWin.ShowBinaryAsRG.ItemIndex of
        0: z := FriendlyStr(Data);
        1: z := DWORDStringOfByteA(Data);
        2: z := DWORDStringOfByteA(Data, True);
        3: z := BinOfByteA(Data, 8, '  ');
        4: z := HexOfByteA(Data, 0);
        5: z := HexOfByteA(Data, 1);
        6: z := HexOfByteA(Data, 2);
        7: z := HexOfByteA(Data, 4);
      end;
    end;

    Result := Copy(z, 1, MaxPreviewLen);
  end;

  function StringPreview(Context: TRegContext): string;
  var
    s: string;
    Expanded: string;
    DoExpand: Boolean;
  begin
    s := PChar(Context.Data);
    with PrefWin do
      Result := StringQuoterBegin + FriendlyStr(s) + StringQuoterEnd;
    if s = '' then
      Exit;

    case PrefWin.ExpandStringsRG.ItemIndex of
      0: DoExpand := False;
      1: DoExpand := (Context.Typ = rdExpandString) and (CharCount(s, '%') >= 2);
      2: DoExpand := True;
    else
      ShowMessage('Error: Unknown PrefWin.ExpandStringsRG.ItemIndex!');
      PrefWin.ExpandStringsRG.ItemIndex := 0;
      Exit;
    end;

    if DoExpand then begin
      Expanded := ExpandString(s);
      if s <> Expanded then
        Result := Result + '   <' + Expanded + '>';
    end;
  end;

  function IntegerPreview(Context: TRegContext): string;
  begin
    if Length(Context.Data) >= SizeOf(Cardinal) then begin
      Result := DWORDPreview(PInteger(Context.Data)^);
    end else
      Result := BinaryPreview(Context);
  end;

  function MultiStringPreview(Context: TRegContext): string;
  var
    z: string;
    SL: TStringList;
    i: Integer;
  begin
    z := '';

    SL := TStringList.Create;
    try
      RegMultiStringOfByteA(Context.Data, SL, PrefWin.UseExtendedModelCB.Checked);

      for i := 0 to SL.Count-1 do
        z := z + SL[i] + '   ';
    finally
      SL.Free;
    end;

    Result := Copy(FriendlyStr(z), 1, MaxPreviewLen);
  end;

begin
  Result := '';

  if csDestroying in PrefWin.ComponentState then
    Exit;

  if (Context.Data = nil) or (Length(Context.Data) > RegMaxDataSize) then
    Exit;

  if Length(Context.Data) > MaxPreviewLen then
    SetLength(Context.Data, MaxPreviewLen);

  if PrefWin.ShowAsBinaryCB.Checked then begin
    Result := BinaryPreview(Context);
  Exit; end;

  case Context.Typ of
    rdExpandString, rdString: Result := StringPreview(Context);
    rdCardinal, rdCardBigEndian: Result := IntegerPreview(Context);
    rdMultiString: Result := MultiStringPreview(Context);
  else
    if PrefWin.Smart4BBCB.Checked and (Length(Context.Data) = 4) then
      Result := IntegerPreview(Context)
    else
      Result := BinaryPreview(Context);
  end;
end;

function ValueDataPreview(Context: TRegContext): string;
begin
  Result := DataPreviewOfContext(Context);
end;

function IconOfDataType(Typ: TRegDataType): Integer;
begin
  if Typ in [rdNone..rdLastType] then
    Result := iconFirstType + Ord(Typ)
  else
    Result := iconUnknownType;
end;

function ValueTypeIcon(Context: TRegContext): Integer;
begin
  Result := IconOfDataType(Context.Typ);
end;

function TValuesWin.UpdateValue(Reg: TXRegistry; Item: TListItem): Boolean;
//Return Value: True if something has changed
var
  Size, Typ, Data: string;
  Icon: Integer;
  Context: TRegContext;
begin
  Result := False;
  if not Assigned(Item) then
    Exit;

  Context := Reg.ReadContext(RealValueName(Item));
  Data := ValueDataPreview(Context);
  Size := ValueDataSize(Context);
  Typ := ValueDataType(Context);
  Icon := ValueTypeIcon(Context);

  if Icon <> Item.ImageIndex then begin
    Item.ImageIndex := Icon;
    Result := True;
  end;

  while Item.SubItems.Count < Integer(High(TValueListColumn)) do
    Item.SubItems.Add('');

  if Size <> Item.SubItems[SubItemIndex[vlcSize]] then begin
    Result := True;
    Item.SubItems[SubItemIndex[vlcSize]] := Size;
  end;

  if Typ <> Item.SubItems[SubItemIndex[vlcType]] then begin
    Result := True;
    Item.SubItems[SubItemIndex[vlcType]] := Typ;
  end;

  if (Data <> Item.SubItems[SubItemIndex[vlcData]]) then begin
    Result := True;
    Item.SubItems[SubItemIndex[vlcData]] := Data;
    if IsMainValue(Item) then
      RegTV.Repaint;
  end;
end;

procedure AppendNewValueInfos(Item: TListItem; Context: TRegContext);
begin
  Item.ImageIndex := ValueTypeIcon(Context);
  with Item.SubItems do begin
    Append(ValueDataSize(Context));
    Append(ValueDataType(Context));
    Append(ValueDataPreview(Context));
  end;
end;

function TValuesWin.AddValue(Reg: TXRegistry; const ValueName: string;
  AppendInfos: Boolean = True): TListItem;
begin
  Result := ValueList.Items.AddItem(nil, -1);
  Result.Indent := -1;
  SetRealValueName(Result, ValueName);
  if AppendInfos then
    AppendNewValueInfos(Result, Reg.ReadContext(ValueName));
end;

procedure TValuesWin.ValueListChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  ValueName: string;
  Reg: TXRegistry;

  function ComputeValuesCommon(Reg: TXRegistry; var DataType: TRegDataType): Boolean;
  var
    i: Integer;
    ItemType: TRegDataType;
  begin
    Result := False;

    i := 0;
    DataType := 0;
    while i < ValueList.Items.Count do begin
      Item := ValueList.Items[i];
      if not Item.Selected then begin
        Inc(i);
      Continue; end;

      ValueName := RealValueName(Item);
      if Reg.ValueReallyExists(ValueName) then begin

        ItemType := Reg.GetDataType(ValueName);
        if not Result then begin
          DataType := ItemType;
          Result := True;
        end else if ItemType <> DataType then begin
          Result := False;
          DataType := 0;
        Break; end;

        with ValueNames do
          if Item.Focused then
            Insert(0, ValueName)
          else
            Add(ValueName);

      end else begin
        ShowMessage('Value has been deleted!');
        DataType := 0;
        Result := False;
        Reload;
      Break; end;

      Inc(i);
    end;
  end;

begin
  if not Assigned(Item) or ValueList.IsEditing or not ValueList.Enabled then
    Exit;

  if Change <> ctState then
    Exit;

  if csDestroying in WorkWin.ComponentState then
    Exit;

  if (ValueList.SelCount = 0) then begin
    ValueNames.Clear;
    WorkWin.ReInitShowPC;
  Exit; end;

  if not Item.Focused then
    Exit;

  WorkWin.ReInitShowPC;

  ValueNames.Clear;
  Reg := TXRegistry.Create;
  try
    if OpenNodeOK(Reg, RegTV.Selected) then begin
      ValuesCommon := ComputeValuesCommon(Reg, ValueCommonType);
      if ValuesCommon then
        WorkWin.ShowValues(Reg);
    end;
  finally
    Reg.Free;
  end;

  if csDestroying in MainWin.ComponentState then
    Exit;

  if ActiveControl = ValueList then
    MainWin.SetStatus;
end;

procedure TValuesWin.ValueListCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with ValueList.Canvas.Font do begin
    if Item.Focused then
      Style := Style + [fsBold];
    if ItemIsDefaultValue(Item) then
      Color := clBrightYellow
    else
      Color := ColorOfDataType(TRegDataType(Item.ImageIndex - iconFirstType));
  end;
end;

procedure TValuesWin.ValueListDblClick(Sender: TObject);
begin
  ValueListChange(Sender, ValueList.ItemFocused, ctState);
  MainPC.ActivePage := WorkWin.WorkPage;

  if not Assigned(ValueList.ItemFocused) then
    Exit;

  if csDestroying in WorkWin.ComponentState then
    Exit;

  WorkWin.EditData;
end;

procedure TValuesWin.ValueListEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  if not ValueLabelClicked then begin
    AllowEdit := False;
  Exit; end;

  if ItemIsDefaultValue(Item) then //unschön, aber beste Lösung bisher
    Keyboard.SimKey(VK_DELETE);
end;

procedure TValuesWin.ValueListEdited(Sender: TObject; Item: TListItem;
  var S: string);
var
  Old: string;
  OldCaption: string;
begin
  OldCaption := Item.Caption;
  Old := RealValueName(Item);

  if s = Old then begin
    if ItemIsDefaultValue(Item) then
      s := DefaultValueCaption;
  Exit; end;

  SpyThread.Suspend;
  try
    Item.Caption := s;

    if TryRenameValue(Old, s) then begin
      SetRealValueName(Item, s); //Sichere Zuweisung des Standard-Flags
      s := Item.Caption; //Anschließend externer Aufruf "Item.Caption := s"!
    end else begin
      s := OldCaption;
    end;

  finally
    SpyThread.Restart := True;
    SpyThread.Resume;
  end;
end;

procedure TValuesWin.ValueListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  T: string;
  Item: TListItem;
begin
  if ValueList.IsEditing then
    Exit;

  if csDestroying in TreeWin.ComponentState then
    Exit;
    
  Item := ValueList.ItemFocused;

  case Key of
    VK_SPACE: JumpToSel(ValueList);

    VK_F9: SwapFonts(ValueList);

    VK_F5: Reload;

    VK_F12: begin //Sort
        if Assigned(Item) then
          T := Item.Caption;
        ValueList.SortType := TSortType(2 - (Integer(ValueList.SortType)));
        if ValueList.SortType = stNone then
          TreeWin.RegTVChange(Sender, RegTV.Selected);
        ValueList.ItemFocused := FindItem(ValueList, T);
        if Assigned(ValueList.ItemFocused) then
          ValueList.ItemFocused.MakeVisible(True);
      end;

    VK_DELETE: DeleteMIClick(Sender);

    VK_RETURN: ValueListDblCLick(Sender);

    Ord('C'):
      if not ValueList.IsEditing then
        CopyPathMIClick(Sender);

    VK_SCROLL: CheckValueListHotTrack;
  end;
end;

procedure TValuesWin.ValueListResize(Sender: TObject);
begin
  with ValueList do
    Columns[3].Width := ClientWidth - (0 +
      Columns[0].Width + Columns[1].Width + Columns[2].Width);
end;

procedure TValuesWin.DeleteValue;
var
  Item, NewSel: TListItem;
  YesToAll: Boolean;
  i: Integer;

  procedure DeleteIt(Item: TListItem);
  begin
    OpenCurKey;
    if MainReg.DeleteValue(RealValueName(Item))
     and not MainReg.ValueReallyExists(RealValueName(Item)) then begin
      Item.Delete;
    end else begin
      ShowMessage('Could not delete Value ' + Quote(RealValueName(Item)));
      Inc(i);
    end;
    MainReg.CloseKey;

    if IsMainValue(Item) then
      RegTV.Repaint;
  end;

begin
  SpyThread.Suspend;

  NewSel := GetNextBestNotSelected(ValueList.ItemFocused);

  YesToAll := False;
  i := 0;
  while i < ValueList.Items.Count do begin
    Item := ValueList.Items[i];
    if not Item.Selected then begin
      Inc(i);
    Continue; end;

    if YesToAll then
      DeleteIt(Item)
    else begin
      case MessageDlg('Do you really want to delete the Value ' +
        Quote(RealValueName(Item)) + '?',
           mtConfirmation, [mbYes, mbYesToAll, mbNo, mbCancel], 0) of
        mrYes: DeleteIt(Item);
        mrYesToAll: YesToAll := True;
        mrCancel: Exit;
        mrNo: begin
          Item.Selected := False;
          NewSel := Item;
        end;
      end;
    end;
  end;

  if Assigned(NewSel) then begin
    ValueList.ItemFocused := NewSel;
    NewSel.Selected := True;
  end else
    WorkWin.ReInitShowPC;

  SpyThread.Restart := True;
  SpyThread.Resume;
end;

procedure TValuesWin.ZeromizeValue;
var
  Item: TListItem;
  YesToAll: Boolean;
  i: Integer;

  procedure ZeromizeIt(Item: TListItem);
  begin
    with MainReg do begin
      OpenCurKey;
      ZeromizeValue(RealValueName(Item));
      UpdateValue(MainReg, Item);
      CloseKey;
    end;
  end;

begin
  SpyThread.Suspend;

  YesToAll := False;
  i := 0;
  while i < ValueList.Items.Count do begin
    Item := ValueList.Items[i];
    if not Item.Selected then begin
      Inc(i);
    Continue; end;

    if YesToAll then
      ZeromizeIt(Item)
    else
      case MessageDlg('Do you really want to zeromize ValueData of ' +
        Quote(RealValueName(Item)) + ' ?',
        mtConfirmation, [mbYes, mbYesToAll, mbNo, mbCancel], 0) of

      mrYes: begin
        ZeromizeIt(Item);
        Inc(i);
      end;

      mrYesToAll: begin
                    YesToAll := True;
                    ZeromizeIt(Item);
                  end;
      mrCancel: Exit;
      end;
      
    if IsMainValue(Item) then
      RegTV.Repaint;
  end;


  SpyThread.Resume;
end;

procedure TValuesWin.ValueListPUPopup(Sender: TObject);
var
  Writable, ValueOK, OnlyOneValue, OneValueOK: Boolean;
  Item: TListItem;
begin
  if Assigned(ValueList.ItemFocused) then
    ValueList.ItemFocused.Selected := True;

  if csDestroying in (TreeWin.ComponentState + PrefWin.ComponentState) then
    Exit;

  Writable := not TreeWin.CantWrite;
  NewDefaultValueMI.Visible := Writable;
  NewStringMI.Visible := Writable;
  NewDWORDMI.Visible := Writable;
  NewBinaryMI.Visible := Writable;
  NewMultiStringMI.Visible := Writable;
  NewElseMI.Visible := Writable;

  ValueOK := Writable and (ValueList.ItemFocused <> nil);
  OnlyOneValue := ValueList.SelCount = 1;
  OneValueOK := OnlyOneValue and ValueOK;

  EditMI.Visible := ValueOK;
  EditBinaryMI.Visible := ValueOK;
  DublicateMI.Visible := OneValueOK;
  CopyPathMI.Visible := OnlyOneValue;
  CopyDataPreviewMI.Visible := OnlyOneValue;
  TakeAsMainValueMI.Visible := OnlyOneValue;
  RenameMI.Visible := OneValueOK;
  DeleteMI.Visible := ValueOK;
  ZeromizeMI.Visible := ValueOK;

  Item := ValueList.ItemFocused;
  if not Assigned(Item) then
    Exit;

  TakeAsMainValueMI.Checked := RealValueName(Item) = PrefWin.MainPreviewE.Text;
end;

procedure TValuesWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ValueList.IsEditing then
    Exit;

  if csDestroying in MainWin.ComponentState then
    Exit;
  MainWin.FormKeyDown(Sender, Key, Shift);
end;

procedure TValuesWin.ValueListDeletion(Sender: TObject; Item: TListItem);
begin
  if Assigned(SpyThread) then
    SpyThread.Restart := True;

  if csDestroying in WorkWin.ComponentState then
    Exit;

  if Assigned(ShowPC.ActivePage)
   and Item.Selected and Item.Focused then begin
    ValueList.ItemFocused := GetNextBest(Item);
    WorkWin.ReInitShowPC;
  end;
end;

procedure TValuesWin.DeleteMIClick(Sender: TObject);
begin
  if ValueList.IsEditing then
    Exit;

  DeleteValue;
end;

procedure TValuesWin.RenameMIClick(Sender: TObject);
begin
  if Assigned(ValueList.ItemFocused) then begin
    ValueLabelClicked := True;
    ValueList.ItemFocused.EditCaption;
    ValueLabelClicked := False;
  end;
end;

procedure TValuesWin.NewBigEndianMIClick(Sender: TObject);
begin
  CreateValue(rdCardBigEndian);
end;

procedure TValuesWin.NewExpandStringMIClick(Sender: TObject);
begin
  CreateValue(rdExpandString);
end;

procedure TValuesWin.NewMultiStringMIClick(Sender: TObject);
begin
  CreateValue(rdMultiString);
end;

procedure TValuesWin.NewStrangeTypeMIClick(Sender: TObject);
begin
  CreateValue(TRegDataType(TMenuItem(Sender).Tag));
end;

procedure TValuesWin.NewDefaultValueMIClick(Sender: TObject);
var
  DefaultItem: TListItem;
  i: Integer;
begin
  if csDestroying in (TreeWin.ComponentState + MainWin.ComponentState) then
    Exit;
  if TreeWin.CantWrite then
    Exit;

  with MainReg do begin
    try
      OpenCurKey;

      if StandardValueExists then begin
        ShowMessage('Default Value already exists.');
        CloseKey;
      Exit; end;

      WriteString('', '');

      if not StandardValueExists then begin
        ShowMessage('Could not create Default Value.');
        CloseKey;
      Exit; end;

      ValuesWin.AddValue(MainReg, '');
    finally
      CloseKey;
    end;
  end;

  with ValueList.Items do begin
    DefaultItem := nil;
    for i := 0 to Count-1 do
      if ItemIsDefaultValue(Item[i]) then
        Break;

    if i < Count then
      DefaultItem := Item[i];
  end;

  if not Assigned(DefaultItem) then
    ShowMessage('Error: Lost Default Value!')
  else begin
    SelectItemOnly(ValueList, DefaultItem);
    MainWin.StatusBarUpdate;
    ValueListDblClick(Sender);
  end;
end;

procedure TValuesWin.ValueListChanging(Sender: TObject; Item: TListItem;
  Change: TItemChange; var AllowChange: Boolean);
begin
  if Item = nil then
    AllowChange := False;
end;

procedure TValuesWin.ValueListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ValueLabelClicked := False;
  with ValueList do
    if ([htOnIcon, htOnLabel] * GetHitTestInfoAt(X, Y)) <> [] then
      ValueLabelClicked := True;
end;

procedure TValuesWin.EditBinaryMIClick(Sender: TObject);
begin
  if csDestroying in WorkWin.ComponentState then
    Exit;

  WorkWin.ShowAsBinary := True;
  ValueListChange(Sender, ValueList.ItemFocused, ctState);
  ValueListDblClick(Sender);
end;

procedure TValuesWin.EditMIClick(Sender: TObject);
begin
  ValueListDblClick(Sender);
end;

procedure TValuesWin.ValueListCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  with ValueList.Canvas.Font do begin
    Style := [];
    if SubItem = 1 then
      Color := clSilver
    else
      Color := ColorOfDataType(TRegDataType(Item.ImageIndex - iconFirstType));
  end;
end;

procedure TValuesWin.ValueListCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  case SortBy of
    vlcName: Compare := AnsiCompareText(RealValueName(Item1), RealValueName(Item2));
    vlcSize: Compare := Integer(
      StrToIntDef(Item1.SubItems[SubItemIndex[vlcSize]], -1) >
      StrToIntDef(Item2.SubItems[SubItemIndex[vlcSize]], -1));
    vlcData: Compare := Integer(Item1.SubItems[SubItemIndex[vlcData]] >
      Item2.SubItems[SubItemIndex[vlcData]]);
    vlcType: Compare := Integer(Item1.ImageIndex > Item2.ImageIndex);
  end;

  if Assigned(SortByColumn)
   and (SortByColumn.ImageIndex = iconSortArrowDesc) then
    Compare := 1 - Compare;
end;

procedure TValuesWin.ValueListColumnClick(Sender: TObject; Column: TListColumn);
begin
  case Column.ImageIndex of
    iconSortArrowAsc: Column.ImageIndex := iconSortArrowDesc;
    iconSortArrowDesc: Column.ImageIndex := -1;
  else
    if Assigned(SortByColumn) then
      SortByColumn.ImageIndex := -1;
    if TValueListColumn(Column.Tag) in ValueListColumnRange then
      SortBy := TValueListColumn(Column.Tag)
    else
      ShowMessage('Unknown Column Tag');
    Column.ImageIndex := iconSortArrowAsc;
  end;

  if Column.ImageIndex = -1 then
    ValueList.SortType := stNone
  else begin
    ValueList.SortType := stData;
    SortByColumn := Column;
  end;

  Update;
  ValueList.AlphaSort;
end;

procedure TValuesWin.CloneValue;
var
  OldName, NewName: string;

  function GetNewName(Reg: TXRegistry; const OldName: string): string;
  var
    i: Integer;
    Prefix: string;
  begin
    if OldName = '' then
      Result := 'New Default Value'
    else if Copy(OldName, 1, 4) <> 'New ' then
      Result := 'New ' + OldName
    else
      Result := OldName;

    Prefix := Result;
    i := 1;
    while Reg.ValueExists(Result) do begin
      Result := Prefix + ' ' + IntToStr(i);
      Inc(i);
    end;
  end;

begin
  if csDestroying in TreeWin.ComponentState then
    Exit;

  if TreeWin.CantWrite then
    Exit;

  OldName := RealValueName(ValueList.ItemFocused);

  try
    OpenCurKey;

    NewName := GetNewName(MainReg, OldName);
    MainReg.CopyValue(OldName, NewName);
    AddValue(MainReg, NewName);
  finally
    MainReg.CloseKey;
  end;
end;

procedure TValuesWin.DublicateMIClick(Sender: TObject);
begin
  CloneValue;
end;

procedure TValuesWin.CopyDataPreviewMIClick(Sender: TObject);
begin
  if ValueList.IsEditing then
    Exit;

  CopyDataPreview;
end;

procedure TValuesWin.CopyDataPreview;
begin
  OpenCurKey;
  Clipboard.AsText := DataPreviewOfContext(MainReg.ReadContext(
    RealValueName(ValueList.ItemFocused)));
  MainReg.CloseKey;
end;

procedure TValuesWin.UpdateValues(SelectedOnly: Boolean = False);
var
  i: Integer;
  Reg: TXRegistry;
begin
  if not Started then
    Exit;

  SpyThread.Suspend;

  Reg := TXRegistry.Create;
  try
    if OpenNodeOK(Reg, RegTV.Selected) then
      with ValueList.Items do begin
        for i := 0 to Count-1 do begin
          if SelectedOnly and not Item[i].Selected then
            Continue;
          UpdateValue(Reg, Item[i]);
        end;
      end;
  finally
    Reg.Free;
  end;

  SpyThread.Resume;
end;

function TValuesWin.TryRenameValue(OldName: string;
  var NewName: string): Boolean;
var
  x: string;
begin
  Result := False;
  if OldName = NewName then
    Exit;

  if (Length(NewName) > RegMaxValueNameLen) then begin
    NewName := Copy(NewName, 1, RegMaxValueNameLen);
    if MessageDlg(
     'The maximum size of a value name is ' + IntToStr(RegMaxValueNameLen) + ' characters.' + EOL +
     'Shorten the value name to:' + EOL +
     Quote(StringWrap(NewName, 80)),
     mtConfirmation, [mbOK, mbCancel], 0) <> mrOK then
      Exit;
  end;

  if CharIn(NewName, [#0..#31]) then begin
    NewName := ReplaceChars(NewName, [#0..#31], '#');
    if MessageDlg('The following chars are not allowed in ValueNames:' + EOL +
     '- Control chars (#0..#31)' + EOL +
     'The following name is allowed:' + EOL +
     NewName + EOL +
     'Use this name instead?',
     mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;
  end;

  if not OpenCurKey then
    Exit;

  if SameText(OldName, NewName) then begin //CharCase ändern
    x := MainReg.GetFreeValueName;
    MainReg.RenameValue(OldName, x);
    MainReg.RenameValue(x, NewName);
  end else begin
    if not MainReg.ValueReallyExists(NewName) then begin
      MainReg.RenameValue(OldName, NewName);
    end else begin
      if NewName = '' then
        ShowMessage('Default value already exists.')
      else
        ShowMessage('Value ' + Quote(NewName) + ' already exists.');
    Exit; end;
  end;
  MainReg.CloseKey;

  if TextIn(NewName, 'default') then
    AddHint('You can create default values by empty string ValueNames.');
    
  Result := True;
end;

procedure TValuesWin.ZeromizeMIClick(Sender: TObject);
begin
  ZeromizeValue;
end;

procedure TValuesWin.CopyPathMIClick(Sender: TObject);
begin
  if ValueList.IsEditing then
    Exit;

  if csDestroying in MainWin.ComponentState then
    Exit;

  MainWin.CopyPathClick(Sender);
end;

function TValuesWin.FindItemByRealName(const ValueName: string): Integer;
begin
  with ValueList.Items do begin
    for Result := 0 to Count-1 do
      if SameText(RealValueName(Item[Result]), ValueName) then
        Exit;
  end;
  Result := -1;
end;

function TValuesWin.FocusItem(ARealValueName: string;
  FocusValueList: Boolean = False): Boolean;
var
  i: Integer;
begin
  with ValueList do begin
    i := FindItemByRealName(ARealValueName);

    if (i > -1) and (i < Items.Count) then
      Selected := Items[i]
    else
      Selected := nil;

    ItemFocused := Selected;

    Result := Assigned(Selected);
    if Result then
      JumpToSel(ValueList);

    if FocusValueList then
      FocusControl(ValueList);
  end;
end;

procedure TValuesWin.TakeAsMainValueMIClick(Sender: TObject);
var
  Item: TListItem;
  ValueName: string;
begin
  if csDestroying in PrefWin.ComponentState then
    Exit;

  Item := ValueList.ItemFocused;
  if not Assigned(Item) then
    Exit;

  ValueName := RealValueName(Item);
  with PrefWin.MainPreviewE do
    if ValueName = Text then
      Text := ''
    else
      Text := ValueName;
end;

procedure TValuesWin.InitListColumnTags;
var
  i: Integer;
begin
  for i := 0 to ValueList.Columns.Count-1 do
    with ValueList.Columns.Items[i] do begin
      Tag := -1;
      if Caption = 'Name' then
        Tag := Integer(vlcName)
      else if Caption = 'Size' then
        Tag := Integer(vlcSize)
      else if Caption = 'Type' then
        Tag := Integer(vlcType)
      else if Caption = 'Data' then
        Tag := Integer(vlcData)
      else
        ShowMessage(Format('Error: Unknown ValueList.Columns[%d].Caption = "%s"',
          [Index, Caption]));
      if Tag > -1 then
        SubItemIndex[TValueListColumn(Tag)] := Index - 1;
    end;
end;

procedure TValuesWin.FormShow(Sender: TObject);
begin
  InitListColumnTags;
end;

procedure TValuesWin.Reload(JumpToNewValue: Boolean = False;
  ValueName: string = '');
var
  Sel: TListItem;
  SelIndex: Integer;
  SelRealValueName: string;
begin
  if csDestroying in TreeWin.ComponentState then
    Exit;

  SelIndex := -1;
  if JumpToNewValue then
    SelRealValueName := ValueName
  else begin
    Sel := ValueList.ItemFocused;
    if Assigned(Sel) then
      SelIndex := Sel.Index;

    if SelIndex > -1 then
      SelRealValueName := RealValueName(ValueList.Items[SelIndex]);
  end;

  TreeWin.RegTVChange(Self, RegTV.Selected);

  if SelIndex > -1 then
    if not FocusItem(SelRealValueName, True) then begin
      SelIndex := GetBestIndex(ValueList, SelIndex);
      if SelIndex > -1 then
        with ValueList do begin
          Selected := Items[SelIndex];
          ItemFocused := Selected;
        end;
    end;
end;

procedure TValuesWin.LoadValues(Reg: TXRegistry);
var
  SL: TStringList;
  i: Integer;
  Clock: TClock;
begin
  if csDestroying in WorkWin.ComponentState then
    Exit;

  with ValueList.Items do begin
    Clock := TClock.Create(1, tfSecs);
    ValueList.Enabled := False;
    BeginUpdate;
    try
      Clear;
      WorkWin.ReInitShowPC;

      SL := TStringList.Create;
      try
        Reg.GetValueNames(SL);
        for i := 0 to SL.Count-1 do
          ValuesWin.AddValue(Reg, SL[i]);
      finally
        SL.Free;
      end;

    finally
      EndUpdate;
      ValueList.Enabled := True;
      Clock.Stop;
      if MurphyMode then
        AddHint(Format('Values loaded after %0.2f secs.', [Clock.SecsPassed]));
      Clock.Free;
    end;
  end;
end;

procedure TValuesWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Action := caNone;
end;

procedure TValuesWin.ValueListClick(Sender: TObject);
begin
  CheckValueListHotTrack;
  if ValueList.HotTrack then
    ValueListDblClick(Sender);
end;

procedure TValuesWin.CheckValueListHotTrack;
const
  StyleOfSwitch: array[Boolean] of TListHotTrackStyles = (
    [], [htHandPoint, htUnderlineHot] );
var
  NewHotTrack: Boolean;
begin
  if csDestroying in PrefWin.ComponentState then
    Exit;

  NewHotTrack := ScrollON xor PrefWin.ValuesSingleClickCB.Checked;
  if NewHotTrack = ValueList.HotTrack then Exit;
  
  with ValueList do begin
    HotTrack := NewHotTrack;
    HotTrackStyles := StyleOfSwitch[HotTrack];
    Mouse.CursorPos := Mouse.CursorPos;
  end;
end;

procedure TValuesWin.SelectAllMIClick(Sender: TObject);
var
  i: Integer;
begin
  with ValueList.Items do
    for i := 0 to Count-1 do
      Item[i].Selected := True;
end;

procedure TValuesWin.InvertSelectionMIClick(Sender: TObject);
var
  i: Integer;
begin
  with ValueList.Items do
    for i := 0 to Count-1 do
      Item[i].Selected := not Item[i].Selected;
end;

procedure TValuesWin.FormDestroy(Sender: TObject);
begin
  ValueNames.Free;
end;

end.
unit WorkU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, NewPanels, Grids, Clipbrd,
  IntEdit, ExtCtrls, Menus, YTools, CompEx, PlutoConst,
  XReg, Clock, Colors, ShellAPI, IniFiles, Math,
  keybrd, Buttons, YTypes, LinkLabel, start,
  PrefTools, ImgList, PHexMemo, PipelineTh, DropSource, DropTarget,
  CrackTools;

type
  TColorStringFmt = (csfThreeSpacedDecimals);

  TWorkWin = class(TForm)
    StringPU: TPopupMenu;
    SpaceMI: TMenuItem;
    FileMI: TMenuItem;
    FileOpenD: TOpenDialog;
    MainPC: TPageControl;
    HintPage: TTabSheet;
    Splitter1: TSplitter;
    HintLB: TListBox;
    InfoMemo: TMemo;
    WorkPage: TTabSheet;
    WorkP: TPanel;
    ShowPC: TPageControl;
    StringPage: TTabSheet;
    BorderPanel1: TBorderPanel;
    StringE: TEdit;
    OKStringB: TButton;
    BoolStrCB: TCheckBox;
    CancelStringB: TButton;
    StringAsColorP: TPanel;
    StringAsFileP: TBorderPanel;
    IconImage: TImage;
    IntPage: TTabSheet;
    BorderPanel5: TBorderPanel;
    OKIntB: TButton;
    CardBoolCB: TCheckBox;
    CancelIntB: TButton;
    BinaryPage: TTabSheet;
    BorderPanel6: TBorderPanel;
    Panel2: TPanel;
    Label5: TLabel;
    OffsetHE: THexEdit;
    OKBinaryB: TButton;
    CancelBinaryB: TButton;
    StringTypeRG: TRadioGroup;
    SpyPage: TTabSheet;
    BorderPanel2: TBorderPanel;
    SpyResumeB: TButton;
    SpySuspendB: TButton;
    SpyLB: TListBox;
    Label4: TLabel;
    Label7: TLabel;
    CardTypeRG: TRadioGroup;
    MultiStringPage: TTabSheet;
    BorderPanel7: TBorderPanel;
    OKMultiStringB: TButton;
    CancelMultiStringB: TButton;
    MultiStringM: TMemo;
    DataTypeComB: TComboBox;
    CardinalE: TCardEdit;
    ColorDlg: TColorDialog;
    MultiStringOpenD: TOpenDialog;
    MultiStringSaveD: TSaveDialog;
    MultiStringPU: TPopupMenu;
    LadenMI: TMenuItem;
    SpeichernMI: TMenuItem;
    Hinzufgen1: TMenuItem;
    N1: TMenuItem;
    SisyPage: TTabSheet;
    SpyClearTracesB: TButton;
    Label11: TLabel;
    HexEdit1: THexEdit;
    Label12: TLabel;
    Label13: TLabel;
    SortMultiStringMI: TMenuItem;
    SpyTestL: TLabel;
    Panel3: TPanel;
    CurValueE: TEdit;
    BorderPanel8: TBorderPanel;
    BorderPanel9: TBorderPanel;
    SisyTV: TTreeView;
    TabImages: TImageList;
    ChangeImages: TImageList;
    Panel7: TPanel;
    ColorPanel1: TColorPanel;
    Splitter2: TSplitter;
    SpyDelayIE: TPrefIntEdit;
    ListTracesCB: TPrefCheckBox;
    Panel5: TPanel;
    Panel8: TPanel;
    SisyExpandGroupsCB: TPrefCheckBox;
    ClearChangesB: TButton;
    FilterChangesB: TButton;
    SisyTVPU: TPopupMenu;
    SisyGotoKeyMI: TMenuItem;
    SisyDeleteChangeMI: TMenuItem;
    SisyActivateChangeMI: TMenuItem;
    N3: TMenuItem;
    SisyCopyPathMI: TMenuItem;
    N4: TMenuItem;
    Panel9: TPanel;
    ExternalEditB: TButton;
    LoadExternalB: TButton;
    ReloadStringB: TButton;
    BinaryHM: TPHexMemo;
    PipelineCB: TCheckBox;
    ReloadDWordB: TButton;
    ReloadBinaryB: TButton;
    ReloadMultiStringB: TButton;
    DescL: TLabel;
    SisyHKUCB: TPrefCheckBox;
    SisyHKLMCB: TPrefCheckBox;
    SisyHKUL: TLabel;
    SisyHKLML: TLabel;
    SisyListCB: TPrefCheckBox;
    CardSpecial0B: TButton;
    CardSpecial1B: TButton;
    CardSpecial_1B: TButton;
    CardSpecial7FB: TButton;
    SisyPU: TPopupMenu;
    Idle1: TMenuItem;
    Lowest1: TMenuItem;
    Lower1: TMenuItem;
    Normal1: TMenuItem;
    Higher1: TMenuItem;
    Highes1: TMenuItem;
    SisyShowCurrentPathMI: TMenuItem;
    N5: TMenuItem;
    MultiStringTypeRG: TRadioGroup;
    SeparatorE: TEdit;
    Label1: TLabel;
    MultiStringCountL: TLabel;
    DropFileTarget: TDropFileTarget;
    CryptoPage: TTabSheet;
    BorderPanel3: TBorderPanel;
    CryptoE: TEdit;
    OKCryptoB: TButton;
    CancelCryptoB: TButton;
    ReloadCryptoB: TButton;
    CryptoTypeRG: TRadioGroup;
    Label2: TLabel;
    LinkLabel2: TLinkLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpyResumeBClick(Sender: TObject);
    procedure SpySuspendBClick(Sender: TObject);
    procedure ArrPlutoBClick(Sender: TObject);
    procedure ArrRegEdBClick(Sender: TObject);
    procedure ArrFreeBClick(Sender: TObject);
    procedure ArrBigValBClick(Sender: TObject);

    procedure SpaceMIClick(Sender: TObject);
    procedure FileMIClick(Sender: TObject);
    procedure HintLBClick(Sender: TObject);
    procedure MainPCDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure ValueMIClick(Sender: TObject);
    procedure StringEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StringEChange(Sender: TObject);
    procedure OKStringBClick(Sender: TObject);
    procedure BoolStrCBClick(Sender: TObject);
    procedure CardinalEChange(Sender: TObject);
    procedure CardBoolCBClick(Sender: TObject);
    procedure CardinalEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OKIntBClick(Sender: TObject);
    procedure ShowPCChange(Sender: TObject);
    procedure ShowPCChanging(Sender: TObject; var AllowChange: Boolean);
    procedure ShowPCDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure ShowPCMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure OKBinaryBClick(Sender: TObject);
    procedure HexGrid1Click(Sender: TObject);
    procedure HexGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BoolStrPopup(Sender: TObject);
    procedure StringPageEnter(Sender: TObject);
    procedure IntPageEnter(Sender: TObject);
    procedure BinaryPageEnter(Sender: TObject);
    procedure ReInitShowPC;
    procedure ActivateIt(Sender: TObject);
    procedure DeActivateIt(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure MultiStringMChange(Sender: TObject);
    procedure OKMultiStringBClick(Sender: TObject);
    procedure StringAsColorPDblClick(Sender: TObject);
    procedure MultiStringMEnter(Sender: TObject);
    procedure LadenMIClick(Sender: TObject);
    procedure SpeichernMIClick(Sender: TObject);
    procedure Hinzufgen1Click(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure HexGrid1Enter(Sender: TObject);
    procedure SpyClearTracesBClick(Sender: TObject);
    procedure SpyLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    //procedure BinLMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BinLClick(Sender: TObject);
    procedure HexGrid1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ValueViewChanged(Sender: TObject);
    procedure HexEdit1Change(Sender: TObject);
    procedure SortMultiStringMIClick(Sender: TObject);
    procedure SpyTestLClick(Sender: TObject);
    procedure FocusForEditing;
    procedure CurValueEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CurValueEEnter(Sender: TObject);

    procedure AddAHint(const Hint: string);
    procedure SisyTVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure SisyTVDblClick(Sender: TObject);
    procedure SisyTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SisyCBClick(Sender: TObject);
    procedure BinaryHMLineChange(NewLine: Cardinal);
    procedure OffsetHEChange(Sender: TObject);
    procedure SpyDelayIEChange(Sender: TObject);
    procedure SisyTVExpanded(Sender: TObject; Node: TTreeNode);
    procedure ClearChangesBClick(Sender: TObject);
    procedure FilterChangesBClick(Sender: TObject);
    procedure SisyTVPUPopup(Sender: TObject);
    procedure SisyActivateChangeMIClick(Sender: TObject);
    procedure SisyDeleteChangeMIClick(Sender: TObject);
    procedure SisyCopyPathMIClick(Sender: TObject);
    procedure ExternalEditBClick(Sender: TObject);
    procedure LoadExternalBClick(Sender: TObject);
    procedure ReloadBClick(Sender: TObject);
    procedure PipelineCBClick(Sender: TObject);
    procedure BinaryHMEnter(Sender: TObject);
    procedure xUseExtendedModelCBClick(Sender: TObject);
    procedure SeparatorEChange(Sender: TObject);
    procedure HintLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DWORDSpecialBClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SisyPUPopup(Sender: TObject);
    procedure SisyPriorityMIClick(Sender: TObject);
    procedure SisyShowCurrentPathMIClick(Sender: TObject);
    procedure DropFileTargetDrop(Sender: TObject; ShiftState: TShiftState;
      Point: TPoint; var Effect: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure IconImageDblClick(Sender: TObject);
    procedure SisyTVCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure SisyTVMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OKCryptoBClick(Sender: TObject);
    procedure CryptoEKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    PipelineThread: TPipelineThread;
    BoolStr: array of array[Boolean] of string;
    HexEditAutoChange: Boolean;
    TargetPage: TTabSheet;
    procedure DeleteChange(Node: TTreeNode);
    procedure DeactivateChange(Node: TTreeNode);
    procedure CopySelectedChangeName;
    procedure ClearChanges;
  public
    ShowAsBinary: Boolean;
    function LastHint: string;
    function LoadBoolStr: Boolean;
    function LoadSisyFilter: Boolean;
    procedure ShowValues(Reg: TXRegistry);
    procedure UpdateWriteButtons;
    procedure EditData;
  end;

var
  WorkWin: TWorkWin;
  ShowPC: TPageControl;
  MainPC: TPageControl;

implementation

uses TreeU, ValuesU, plutomain, splash, SisyphusTH, PrefU, ShellEx;

{$R *.dfm}

function ColorOfString(s: string; Format: TColorStringFmt;
  Default: TColor = clBlack): TColor;
var
  SA: TStrA;
  i: Integer;
begin
  Result := Default;
  SA := nil;

  case Format of
    csfThreeSpacedDecimals: begin
      SA := Split(s, ' ');
      if Length(SA) <> 3 then
        Exit;
      for i := 0 to 2 do
        if not (IsValidInteger(SA[i]) and (StrToIntDef(SA[i], -1) in [0..255])) then
          Exit;
      Result := ColorOfRGB(StrToIntDef(SA[0], 0),
                           StrToIntDef(SA[1], 0),
                           StrToIntDef(SA[2], 0));
    end;
  end;
end;

function StringOfColor(Color: TColor; Format: TColorStringFmt): string;
var
  RGB: TRGB;
begin
  Result := '';

  RGB := RGBOfColor(Color);
  case Format of
    csfThreeSpacedDecimals: begin
      with RGB do
        Result := IntToStr(R) + ' ' + IntToStr(G) + ' ' + IntToStr(B);
    end;
  end;
end;

function TWorkWin.LastHint: string;
begin
  with HintLB.Items do
    if Count > 0 then
      Result := Strings[Count-1]
    else
      Result := '';
end;

procedure TWorkWin.AddAHint(const Hint: string);
begin
  if not Assigned(HintLB) then
    Exit;

  with HintLB.Items do begin
    if Count > 0 then begin
      if StrAtBegin(LastHint, Hint) then begin //same hint again
        with HintLB do
          Tag := Tag + 1;
        Strings[Count-1] := Format('%s (%d)', [Hint, HintLB.Tag]);
      Exit end else
        HintLB.Tag := 1;
    end;
    Add(Hint);
  end;
  Application.ProcessMessages; //draw
//  Sleep(1000); //wait to read hints
end;

procedure TWorkWin.ReInitShowPC;
begin
  with CurValueE do begin
    Text := NoValueCaption;
    Font.Color := clSilver;
    Enabled := False;
  end;

  ShowPC.ActivePage := nil;

  StringE.Text := '';
  StringTypeRG.ItemIndex := 0;

  MultiStringTypeRG.Buttons[1].Enabled := False;

  CardinalE.Value := 0;
  CardTypeRG.ItemIndex := 0;

  BinaryHM.Data := nil;
  PipelineCB.Checked := False;

  DataTypeComB.ItemIndex := Integer(rdBinary);

  MultiStringM.Clear;
end;

procedure TWorkWin.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MainWin.FormKeyDown(Sender, Key, Shift);
end;

procedure TWorkWin.SpyResumeBClick(Sender: TObject);
begin
  SpyThread.Resume;
  SpyTestLClick(Sender);
end;

procedure TWorkWin.SpySuspendBClick(Sender: TObject);
begin
  SpyThread.Suspend;
  SpyTestLClick(Sender);
end;

procedure TWorkWin.ArrPlutoBClick(Sender: TObject);
begin
  ArrangePlutoStyle;
end;

procedure TWorkWin.ArrRegEdBClick(Sender: TObject);
begin
  ArrangeRegEdStyle;
end;

procedure TWorkWin.ArrFreeBClick(Sender: TObject);
begin
  ArrangeFreeStyle;
end;

procedure TWorkWin.ArrBigValBClick(Sender: TObject);
begin
  ArrangeBigValStyle;
end;

procedure TWorkWin.SpaceMIClick(Sender: TObject);
begin
  StringE.Text := '';
end;

procedure TWorkWin.HintLBClick(Sender: TObject);
begin
  StatusBar.Panels[0].Text := GetSel(HintLB);
  WorkWin.InfoMemo.Text := StatusBar.Panels[0].Text;
end;

procedure TWorkWin.MainPCDrawTab(Control: TCustomTabControl; TabIndex: Integer;
  const Rect: TRect; Active: Boolean);
var
  PC: TPageControl;
  Page: TTabSheet;
begin
  PC := TPageControl(Control);
  Page := PC.Pages[TabIndex];
  with PC.Canvas.Font do begin
    if Page.Caption = 'Hint' then
      Color := clBrightRed
    else if Page.Caption = 'Edit' then
      Color := clBrightGreen
    else if Page.Caption = 'Spy' then
      Color := clBrightBlue
    else if Page.Caption = 'Sisyphus' then
      Color := clBrightCyan
    else
      Color := clWhite;
  end;

  with PC.Canvas do
    if Active then begin
      Font.Style := [fsBold];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 18 + 5, Rect.Top + 3, Page.Caption);
      PC.Images.Draw(PC.Canvas, Rect.Left + 4, Rect.Top + 2, Page.ImageIndex);
    end else begin
      Font.Style := [];
      Brush.Color := clDarkGray;
      FillRect(Rect);
      TextOut(Rect.Left + 18 + 3, Rect.Top + 2, Page.Caption);
      PC.Images.Draw(PC.Canvas, Rect.Left + 1, Rect.Top + 1, Page.ImageIndex);
    end;
end;

procedure TWorkWin.ValueMIClick(Sender: TObject);
begin
  StringE.Text := UntilStr(TMenuItem(Sender).Caption,' = ');
  OKStringBClick(Sender);
end;

procedure TWorkWin.StringEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    OKStringBClick(Sender);
    ValuesWin.FocusControl(ValueList);
  end;
  if key = VK_ESCAPE then
    CancelBClick(Sender);
end;

procedure TWorkWin.StringEChange(Sender: TObject);
var
  i: Integer;
  State: TCheckBoxState;
  Desc: string;
begin
  IconImage.Picture := nil;

  with StringAsColorP do begin
    Color := ColorOfString(StringE.Text, csfThreeSpacedDecimals, -1);
    Visible := Color <> -1;
  end;

  try
    with IconImage.Picture.Icon do begin
      ReleaseHandle;
      Handle := GetIconFromFile(StringE.Text);
      StringAsFileP.Visible := Handle <> 0;
    end;
  except
  end;

  State := cbGrayed;
  for i := 0 to High(BoolStr) do begin
    if StringE.Text = BoolStr[i][False] then
      State := cbUnchecked
    else if StringE.Text = BoolStr[i][True] then
      State := cbChecked
    else
      Continue;
    Break;
  end;

  BoolStrCB.Visible := State in [cbChecked, cbUnchecked];
  BoolStrCB.State := State;

  Desc := StringE.Text;
  Desc := RegNameOfCLSID(Desc);
  with DescL do begin
    Visible := (Desc <> '');
    if Visible then
      Caption := 'CLSID is: ' + Desc;
  end;
end;

procedure TWorkWin.OKStringBClick(Sender: TObject);
var
  i: Integer;
begin
  try
    OpenCurKey;
    with ValuesWin.ValueNames do
      for i := 0 to Count-1 do begin
        case StringTypeRG.ItemIndex of
          0: MainReg.WriteString(Strings[i], StringE.Text);
          1: MainReg.WriteExpandString(Strings[i], StringE.Text);
        end;
      end;
    ValuesWin.UpdateValues(True);
  finally
    MainReg.CloseKey;
  end;
  ValuesWin.ValueListDblClick(Sender);
end;

procedure TWorkWin.BoolStrCBClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to High(BoolStr) do begin
    if (BoolStr[i, False] = StringE.Text)
     or (BoolStr[i, True] = StringE.Text) then
      Break;
  end;
  
  if i > High(BoolStr) then
    Exit;

  StringE.Text := BoolStr[i][BoolStrCB.Checked];
end;

procedure TWorkWin.CardinalEChange(Sender: TObject);
begin
  HexEditAutoChange := True;
  with CardBoolCB do begin
    Enabled := True;
    case CardinalE.Value of
      1: Checked := True;
      0: Checked := False;
    else
      Enabled := False;
    end;
  end;
  HexEdit1.Value := CardinalE.Value;
  HexEditAutoChange := False;
end;

procedure TWorkWin.CardBoolCBClick(Sender: TObject);
begin
  if HexEditAutoChange then
    Exit;
  CardinalE.Value := Ord(CardBoolCB.Checked);
end;

procedure TWorkWin.CardinalEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    OKIntBClick(Sender);
    ValuesWin.FocusControl(ValueList);
  end;
  
  if key = VK_ESCAPE then
    CancelBClick(Sender);
end;

procedure TWorkWin.OKIntBClick(Sender: TObject);
var
  i: Integer;
  
  procedure Write4BB(const ValueName: string; Value: Cardinal);
  var
    Typ: TRegDataType;
  begin
    if MainReg.ValueReallyExists(ValueName) then
      Typ := MainReg.GetDataType(ValueName)
    else
      Typ := rdBinary;

    if Typ in rdCardTypes then
      Typ := rdBinary;

    MainReg.WriteBinType(ValueName, ByteAOfInt(CardinalE.Value), Typ);
  end;

begin
  try
    OpenCurKey;
    with ValuesWin.ValueNames do
      for i := 0 to Count-1 do begin
        case CardTypeRG.ItemIndex of
          0: MainReg.WriteCardinal(Strings[i], CardinalE.Value);
          1: MainReg.WriteCardinal(Strings[i], CardinalE.Value, True);
          2: Write4BB(Strings[i], CardinalE.Value);
        end;
      end;
    ValuesWin.UpdateValues(True);
  finally
    MainReg.CloseKey;
  end;
end;

procedure TWorkWin.ShowPCChange(Sender: TObject);
begin
  FocusControl(TObject(ShowPC.ActivePage.Tag) as TWinControl);
end;

procedure TWorkWin.ShowPCChanging(Sender: TObject; var AllowChange: Boolean);

  function ByteAOfDWORD(a: DWORD): TByteA;
  begin
    SetLength(Result, SizeOf(DWORD));
    Move(a, Pointer(Result)^, SizeOf(DWORD));
  end;

var
  SourcePage: TTabSheet;
  ValueName: string;
begin
  SourcePage := ShowPC.ActivePage;
  if SourcePage = IntPage then begin

    if TargetPage = StringPage then begin
      AddHint('Converting: DWORD --> String');
      StringE.Text := CardinalE.Text;
    end else if TargetPage = BinaryPage then begin
      AddHint('Converting: DWORD --> Binary');
      BinaryHM.Data := ByteAOfDWORD(CardinalE.Value);
    end else
      AllowChange := False;

  end else if SourcePage = StringPage then begin
    if TargetPage = IntPage then begin
      if IsValidCardinal(StringE.Text) then begin
        AddHint('Converting: String --> DWORD');
        CardinalE.Text := StringE.Text;
      end else begin
        AddHint('This no valid DWORD; Converting aborted.', True);
        AllowChange := False;
      end;
    end else if TargetPage = BinaryPage then begin
      AddHint('Converting: String --> Binary');
      BinaryHM.Data := TByteA(StringE.Text);
    end else if TargetPage = MultiStringPage then begin
      AddHint('Converting: String --> MultiString');
      if SeparatorE.Text = '' then
        MultiStringM.Text := StringE.Text;
      SeparatorEChange(Sender);
    end else
      AllowChange := False;

  end else if SourcePage = BinaryPage then begin
    if TargetPage = StringPage then begin
      AddHint('Converting: Binary --> String');
      StringE.Text := FriendlyStr(string(BinaryHM.Data));
    end else if TargetPage = IntPage then begin
      if Length(BinaryHM.Data) >= SizeOf(DWORD) then begin
        AddHint('Converting: Binary --> DWORD');
        CardinalE.Value := PDWORD(BinaryHM.Data)^;
      end else begin
        AddHint('Binary value not long enough (4 Byte); Converting aborted.', True);
        AllowChange := False;
      end;
    end else if TargetPage = CryptoPage then begin
      if ValuesWin.ValueNames.Count = 1 then begin
        ValueName := ValuesWin.ValueNames[0];
        with CryptoTypeRG do begin
          ItemIndex := -1;
          if SameText(ValueName, 'ScreenSave_Data') then begin
            ItemIndex := 0;
            CryptoE.Text := DecodeScreenSaver(BinaryHM.Data);
          end else if SameText(ValueName, 'parm1enc')
           or SameText(ValueName, 'parm2enc') then begin
            ItemIndex := 1;
            CryptoE.Text := DecodeSharedFolder(BinaryHM.Data);
          end;
        end;
        if CryptoTypeRG.ItemIndex = -1 then
          AllowChange := False;
      end;
    end else
      AllowChange := False;

  end else if SourcePage = MultiStringPage then begin
    if TargetPage = StringPage then begin
      AddHint('Converting: MultiString --> String ');
      if SeparatorE.Text = '' then
        StringE.Text := MultiStringM.Text
      else
        StringE.Text := Join(MultiStringM.Lines, SeparatorE.Text);
    //end else if TargetPage = BinaryPage then begin
    end else
      AllowChange := False;

  end else
    AllowChange := False;
end;

procedure TWorkWin.ShowPCDrawTab(Control: TCustomTabControl; TabIndex: Integer;
  const Rect: TRect; Active: Boolean);
var
  PC: TPageControl;
  Page: TTabSheet;
begin
  PC := TPageControl(Control);
  Page := PC.Pages[TabIndex];
  with PC.Canvas.Font do begin
    if Page = StringPage then
      Color := clBrightRed
    else if Page = MultiStringPage then
      Color := clBrightPurple
    else if Page = IntPage then
      Color := clBrightBlue
    else if Page = BinaryPage then
      Color := clBrightGreen
    else if Page = CryptoPage then
      Color := clBrightCyan;
  end;

  with PC.Canvas do begin
    if Active then
      Brush.Color := clGray
    else
      Brush.Color := clDarkGray;
    FillRect(Rect);
    TextOut(Rect.Left + 18 + 3, Rect.Top, Page.Caption);
    MainWin.ImageList1.Draw(Control.Canvas, Rect.Left - 1, Rect.Top - 1, Page.ImageIndex);
  end;
end;

procedure TWorkWin.ShowPCMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with ShowPC do
    if htOnItem in GetHitTestInfoAt(X, Y) then
      TargetPage := Pages[IndexOfTabAt(X, Y)];
end;

procedure TWorkWin.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  WorkU.ShowPC := ShowPC;
  WorkU.MainPC := MainPC;

  //Zeromize
  ShowPC.ActivePage := nil;
  InfoMemo.Text := '';
  MultiStringM.Clear;
  SisyTV.Items.Clear;
  CurValueE.Text := NoValueCaption;
  HexEditAutoChange := False;
  TargetPage := nil;

  //Tagging
  StringPage.Tag := Integer(StringE);
  IntPage.Tag := Integer(CardinalE);
  BinaryPage.Tag := Integer(BinaryHM);
  MultiStringPage.Tag := Integer(MultiStringM);
  ShowAsBinary := False;

  if not Win9x then
    CryptoPage.TabVisible := False;

  MainPC.ActivePage := HintPage;
  ShowPC.ActivePage := nil;

  DropFileTarget.register(StringE);

  with StringTypeRG do
    for i := 0 to ControlCount-1 do
      (Controls[i] as TRadioButton).OnKeyDown := StringEKeyDown;

  ExternalEditB.Enabled := FileEx(PrefWin.ExternalHexEditE.Text);

  PipelineThread := TPipelineThread.CreateIt(tpIdle, '', BinaryHM);
  PipelineThread.OnChange := LoadExternalBClick;
end;

procedure TWorkWin.OKBinaryBClick(Sender: TObject);
var
  Typ: Cardinal;
  i: Integer;
begin
  try
    Typ := StrToIntDef(UntilChar(DataTypeComB.Text, ' '), Integer(rdBinary));
    OpenCurKey;
    with ValuesWin.ValueNames do
      for i := 0 to Count-1 do
        MainReg.WriteBinType(Strings[i], BinaryHM.Data, Typ);
    ValuesWin.UpdateValues(True);
  finally
    MainReg.CloseKey;
  end;
end;

procedure TWorkWin.HexGrid1Click(Sender: TObject);
begin
  {with BinaryHM do begin
    with BinL, Font do
      if ActiveByte < ByteCount then
        Color := clBrightGreen
      else begin
        Color := clSilver;
        Caption := '00000000';
      end;
    BinL.Caption := IntToBinFill(CurrentByte, 8);
  end; }
end;

procedure TWorkWin.HexGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_RETURN then begin
    OKBinaryBClick(Sender);
    ValuesWin.FocusControl(ValueList);
  end;
  if key = VK_ESCAPE then
    CancelBClick(Sender);
end;

procedure TWorkWin.BoolStrPopup(Sender: TObject);
begin
  StringE.Text := TMenuItem(Sender).Caption;
end;

procedure TWorkWin.StringPageEnter(Sender: TObject);
begin
  FocusControl(StringE);
end;

procedure TWorkWin.IntPageEnter(Sender: TObject);
begin
  FocusControl(CardinalE);
end;

procedure TWorkWin.BinaryPageEnter(Sender: TObject);
begin
  FocusControl(BinaryHM);
end;

procedure TWorkWin.ActivateIt(Sender: TObject);
begin
  ActivateThis(Sender);
end;

procedure TWorkWin.DeActivateIt(Sender: TObject);
begin
  DeActivateThis(Sender);
end;

procedure TWorkWin.FormDeactivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    TEdit(ActiveControl).OnExit(Sender);
end;

procedure TWorkWin.FormActivate(Sender: TObject);
begin
  if Assigned(ActiveControl) and (ActiveControl.Tag = EditControlFlag) then
    TEdit(ActiveControl).OnEnter(Sender);
end;

procedure TWorkWin.MultiStringMChange(Sender: TObject);
begin
  MultiStringCountL.Caption := StrNumerus(MultiStringM.Lines.Count,
                                          'Line', 'Lines', 'No');
end;

procedure TWorkWin.OKMultiStringBClick(Sender: TObject);
var
  UseExtendedModel: Boolean;
  i: Integer;
  JoinedText: string;
begin
  if (MultiStringTypeRG.ItemIndex = 1) then begin
    if ValuesWin.ValueCommonType = rdMultiString then
      if mrYes<>MessageDlg('Do you want to change the type of this value?' + EOL +
       'MultiString --> String', mtWarning, [mbYes, mbCancel], 0) then
        Exit;

    try
      OpenCurKey;
      JoinedText := Join(MultiStringM.Lines, SeparatorE.Text);
      with ValuesWin.ValueNames do
        for i := 0 to Count-1 do
          MainReg.WriteString(Strings[i], JoinedText);
      ValuesWin.UpdateValues(True);
    finally
      MainReg.CloseKey;
    end;
  Exit; end;

  UseExtendedModel := True;
  if ContainsEmptyLines(MultiStringM.Lines) then
    case MessageDlg('This text contains empty lines.' + EOL +
                    'These are not allowed in the standard MultiString model.' + EOL +
                    'Do you want to delete them?' + EOL +
                    EOL +
                    'Yes: Delete empty lines' + EOL +
                    'No: Use the Extended Model',
                    mtWarning, [mbYes, mbNo, mbCancel], 0) of

    mrNo: UseExtendedModel := True;

    mrYes: begin
      with MultiStringM do begin
        Lines.BeginUpdate;
        DeleteEmptyLines(Lines);
        Lines.EndUpdate;
      end;
    end;

    else Exit;
    
    end;

  try
    OpenCurKey;
    with ValuesWin.ValueNames do
      for i := 0 to Count-1 do begin
        if MainReg.GetDataType(Strings[i]) <> rdMultiString then
          if mrYes <> MessageDlg('Do you want to change the type of this value?' + EOL +
           '--> MultiString', mtWarning, [mbYes, mbCancel], 0) then
            Exit;
        if UseExtendedModel then
          MainReg.WriteStringList(Strings[i], MultiStringM.Lines)
        else
          MainReg.WriteMultiString(Strings[i], MultiStringM.Lines);
      end;
    ValuesWin.UpdateValues(True);
  finally
    MainReg.CloseKey;
  end;

  ValuesWin.ValueListDblClick(Sender);
end;

procedure TWorkWin.StringAsColorPDblClick(Sender: TObject);
begin
  if ColorDlg.Execute then
    StringE.Text := StringOfColor(ColorDlg.Color, csfThreeSpacedDecimals);
end;

procedure TWorkWin.MultiStringMEnter(Sender: TObject);
begin
  MultiStringM.SelectAll;
  ActivateIt(MultiStringM);
end;

procedure TWorkWin.LadenMIClick(Sender: TObject);
begin
  with MultiStringOpenD do begin
    InitialDir := ExtractFileDrive(MyDir);
    if Execute then
      MultiStringM.Lines.LoadFromFile(FileName);
  end;
end;

procedure TWorkWin.SpeichernMIClick(Sender: TObject);
begin
  with MultiStringSaveD do begin
    InitialDir := ExtractFileDrive(MyDir);
    if Execute then
      MultiStringM.Lines.SaveToFile(FileName);
  end;
end;

procedure TWorkWin.Hinzufgen1Click(Sender: TObject);
var
  SL: TStringList;
begin
  with MultiStringOpenD do begin
    InitialDir := ExtractFileDrive(MyDir);
    if Execute then begin
      SL := TStringList.Create;
      SL.LoadFromFile(FileName);
      MultiStringM.Lines.AddStrings(SL);
      SL.Free;
    end;
  end;
end;

procedure TWorkWin.CancelBClick(Sender: TObject);
begin
  ValuesWin.FocusControl(ValueList);
  ValuesWin.ValueListChange(Sender, ValueList.Selected, ctState);
end;

procedure TWorkWin.HexGrid1Enter(Sender: TObject);
begin
  HexGrid1Click(Sender);
end;

procedure TWorkWin.SpyClearTracesBClick(Sender: TObject);
begin
  SpyLB.Clear;
end;

procedure TWorkWin.SpyLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssShift in Shift) and (key = VK_DELETE) then begin
    key := 0;
    SpyLB.Clear;
  Exit; end;

  if key = VK_F9 then begin
    key := 0;
    SwapFonts(SpyLB);
  Exit; end;
end;

procedure TWorkWin.BinLClick(Sender: TObject);
begin
 // with HexGrid1 do
 //   Byt[ActiveByte] := IntOfBin(BinL.Caption);
end;

procedure TWorkWin.HexGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //HexGrid1Click(Sender);
end;

procedure TWorkWin.ValueViewChanged(Sender: TObject);
var
  i: Integer;
begin
  if not Started then
    Exit;

  SpyThread.Suspend;
  OpenCurKey;
  for i := 0 to ValueList.Items.Count-1 do
    ValuesWin.UpdateValue(MainReg, ValueList.Items[i]);

  MainReg.CloseKey;
  SpyThread.Resume;
end;

procedure TWorkWin.HexEdit1Change(Sender: TObject);
begin
  if not HexEditAutoChange then
    CardinalE.Value := HexEdit1.Value;
end;

procedure TWorkWin.SortMultiStringMIClick(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  with SL do begin
    Assign(MultiStringM.Lines);
    Sort;
  end;
  MultiStringM.Lines.Assign(SL);
  SL.Free;
end;

procedure TWorkWin.SpyTestLClick(Sender: TObject);
begin
  SpyTestL.Caption := StrOfBool(SpyThread.Suspended, 'No Spy.', 'Spy active.');
end;

procedure TWorkWin.FocusForEditing;
begin
  FocusControl(MainPC);
end;

function TWorkWin.LoadBoolStr: Boolean;
var
  SL: TStringList;
  FileName: string;
  i, p: Integer;
begin
  Result := True;

  AddHint('Loading Boolean Strings...');

  FileName := PlutoDir + BoolStrFileName;
  if not FileEx(FileName) then begin
    AddToLastHint('not found:');
    AddHint(FileName);
    Result := False;
  end else begin
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FileName);
      DeleteCommentLines(SL);
      BoolStr := nil;
      SetLength(BoolStr, SL.Count);
      for i := 0 to SL.Count-1 do begin
        //Split the string by the '|'-sign
        p := Pos('|', SL[i]);
        BoolStr[i][False] := Copy(SL[i], 1, p-1);
        BoolStr[i][True] := Copy(SL[i], p+1, Length(SL[i]) - p);
      end;
    finally
      SL.Free;
      AddToLastHint('OK');
    end;
  end;
end;

function TWorkWin.LoadSisyFilter: Boolean;
var
  SL: TStringList;
  FileName: string;
  i: Integer;
begin
  Result := True;

  FileName := PlutoDir + SisyFilterFileName;
  if not FileEx(FileName) then
    Result := False
  else begin
    AddHint('Loading Sisyphus Filter Settings...');
    SL := TStringList.Create;
    try
      SL.LoadFromFile(FileName);
      DeleteCommentLines(SL, '#');
      for i := 0 to SL.Count-1 do
        SL[i] := TrimLeft(SL[i]);

      SisyFilter.Clear;
      SisyFilter.AddStrings(SL);
    finally
      SL.Free;
      AddToLastHint('OK');
    end;
  end;
end;

procedure TWorkWin.SisyTVGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := Node.ImageIndex;
end;

procedure TWorkWin.SisyTVDblClick(Sender: TObject);
var
  Node: TTreeNode;
  Path: string;
begin
  Node := SisyTV.Selected;
  if not Assigned(Node) then
    Exit;

  Path := RootOfNode(Node).Text;

  if Node.Level > 0 then begin
    if Node.Level = 2 then
      Node := Node.Parent;
    if Node.HasChildren then
      Path := Path + '\\' + Node.Text //Value
    else
      Path := Path + '\' + Node.Text  //SubKey
  end;

  MainWin.GotoKey(Path);
end;

procedure TWorkWin.DeleteChange(Node: TTreeNode);
var
  SubNode: TTreeNode;

  procedure FreeSisyChangeNode(Node: TTreeNode);
  begin
    try
      with (TObject(Node.Data) as TSisyChange) do
        Free;
    except
      ReportFmt('errors', 'Context could not be freed: "%s"', [Node.Text]);
    end;

    Node.Delete;
  end;

begin
  if not Assigned(Node) then
    Exit;

  if Node.Level = 2 then
    Node := Node.Parent;

  if Node.Level = 0 then begin
    SisyTV.Selected := GetNextBest(RootOfNode(Node));
    SubNode := Node.GetFirstChild;
    while Assigned(SubNode) do begin
      FreeSisyChangeNode(SubNode);
    SubNode := Node.GetFirstChild; end;
    Node.Delete;
  end else begin
    SisyTV.Selected := GetNextBest(Node);
    FreeSisyChangeNode(Node);
  end;
end;

procedure TWorkWin.DeactivateChange(Node: TTreeNode);
begin
  Node := RootOfNode(Node);

  if not Assigned(Node) then
    Exit;

  if SisyChangeActivated(Node) then begin
    SetSisyChangeState(Node, False);
    Node.Cut := True;
  end else begin
    SetSisyChangeState(Node, True);
    Node.Cut := False;
  end;
  SisyTV.Repaint;
end;

procedure TWorkWin.CopySelectedChangeName;
var
  Node: TTreeNode;
begin
  Node := SisyTV.Selected;
  if not Assigned(Node) then
    Exit;

  Clipboard.AsText := Node.Text;
end;

procedure TWorkWin.SisyTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Node: TTreeNode;
begin
  Node := RootOfNode(SisyTV.Selected);
  if not Assigned(Node) then
    Exit;

  {if Key = VK_RETURN then
    SisyTVDblCLick(Sender);

  if Key = VK_DELETE then
    if (ssCtrl in Shift) and (Key = VK_DELETE) then
      DeactivateChange(Node)
    else
      DeleteChange(Node);

  if (ssCtrl in Shift) and (Char(Key) = 'C') then
    CopySelectedChangeName;}
end;

procedure TWorkWin.SisyCBClick(Sender: TObject);
begin
  if not Started then
    Exit;

  with TCheckBox(Sender), TSisyThread(Sisys[Tag]) do begin
    if Checked then
      Resume
    else
      Suspend;
  end;
end;

procedure TWorkWin.CurValueEEnter(Sender: TObject);
begin
  CurValueE.Text := RealValueName(ValueList.ItemFocused);
  CurValueE.SelectAll;
end;

procedure TWorkWin.CurValueEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  procedure RenameValue(NewName: string);
  var
    Item: TListItem;
  begin
    Item := ValueList.ItemFocused;
    if ValuesWin.TryRenameValue(CurKey.Value, NewName) then
      SetRealValueName(Item, NewName);
  end;

begin
  if Key = VK_RETURN then begin
    SpyThread.Suspend;
    try
      RenameValue(CurValueE.Text);
      ValuesWin.ValueListDblClick(Self);
      FocusControl(CurValueE);
    finally
      SpyThread.Restart := True;
      SpyThread.Resume;
    end;
    Key := 0;
    //CurValueE.SelectAll;
  end else if Key = VK_ESCAPE then begin
    ValuesWin.ValueListDblClick(Self);
  end;
end;

procedure TWorkWin.BinaryHMLineChange(NewLine: Cardinal);
begin
  OffsetHE.Value := BinaryHM.Pos;
 // BinaryAsIntL.Value := Integer(BinaryHM.CurentCard);
end;

procedure TWorkWin.OffsetHEChange(Sender: TObject);
begin
  BinaryHM.Pos := OffsetHE.Value;
end;

procedure TWorkWin.SpyDelayIEChange(Sender: TObject);
begin
  if Assigned(SpyThread) then
    SpyThread.Delay := SpyDelayIE.Value;
end;

procedure TWorkWin.SisyTVExpanded(Sender: TObject; Node: TTreeNode);
begin
  if Node.ImageIndex = 8 then
    Node.ImageIndex := 7;
end;

procedure TWorkWin.ClearChanges;
var
  Node: TTreeNode;
begin
  with SisyTV.Items do begin
    Node := GetFirstNode;
    while Assigned(Node) do begin
      DeleteChange(Node);
      Node := GetFirstNode;
    end;
  end;
end;

procedure TWorkWin.ClearChangesBClick(Sender: TObject);
begin
  if mrOK <> MessageDlg('Do you really want to clear all changes?',
   mtWarning, [mbOK, mbCancel], 0) then
    Exit;

  ClearChanges;
end;

procedure TWorkWin.FilterChangesBClick(Sender: TObject);
begin
  NotePad(PlutoDir + SisyFilterFileName);
  ShowMessage('Click OK when you finished editing.' + EOL +
              '(Pluto will reload the filter settings then.)');
  LoadSisyFilter;
end;

procedure TWorkWin.SisyTVPUPopup(Sender: TObject);
var
  KeySelected: Boolean;
  Node: TTreeNode;
begin
  Node := SisyTV.Selected;
  KeySelected := Assigned(Node);

  SisyGoToKeyMI.Enabled := KeySelected;
  SisyDeleteChangeMI.Enabled := KeySelected;
  SisyActivateChangeMI.Enabled := KeySelected;
  SisyCopyPathMI.Enabled := KeySelected;
  if not KeySelected then
    Exit;

  SisyActivateChangeMI.Checked := SisyChangeActivated(RootOfNode(Node));
end;

procedure TWorkWin.SisyActivateChangeMIClick(Sender: TObject);
begin
  DeactivateChange(SisyTV.Selected)
end;

procedure TWorkWin.SisyDeleteChangeMIClick(Sender: TObject);
begin
  DeleteChange(SisyTV.Selected)
end;

procedure TWorkWin.SisyCopyPathMIClick(Sender: TObject);
begin
  CopySelectedChangeName;
end;

procedure TWorkWin.FileMIClick(Sender: TObject);
var
  s: string;
begin
  with FileOpenD do begin
    s := ExtractPath(StringE.Text);
    if s <> '' then
      InitialDir := s
    else
      InitialDir := MyDir;

    s := ExtractFileName(StringE.Text);
    s := DeleteChars(s, '/');
    if s <> '' then
      FileName := s;

    if Execute then
      StringE.Text := FileName;
  end;
end;

procedure TWorkWin.ExternalEditBClick(Sender: TObject);
var
  FileName: string;
begin
  FileName := TempDir + '~' + DeleteChars(CurValueE.Text, FileNameEnemies) +
    '.bin';
  if SaveByteA(BinaryHM.Data, FileName) then
    ExecFileWith(PrefWin.ExternalHexEditE.Text, FileName)
  else
    ShowMessage('Could not write into file:' + EOL + FileName);

  PipelineThread.FileName := FileName;
end;

procedure TWorkWin.LoadExternalBClick(Sender: TObject);
var
  FileName: string;
  Data: TByteA;
  i: Integer;
begin
  Data := nil;

  FileName := TempDir + '~' + CurValueE.Text + '.bin';
  if not FileEx(FileName) then begin
    {ShowMessage('File not found:' + EOL +
                FileName);}
    Exit;
  end;

  Data := LoadByteA(FileName);
  if Length(Data) = Length(BinaryHM.Data) then begin
    for i := 0 to High(Data) do
      if Data[i] <> BinaryHM.Data[i] then begin
        BinaryHM.Data := Data;
        Exit;
      end;
  end else
    BinaryHM.Data := Data;
end;

procedure TWorkWin.PipelineCBClick(Sender: TObject);
begin
  with PipelineThread, PipelineCB do
    if Checked then begin
      if Suspended then
        Resume;
    end else
      if not Suspended then
        Suspend;
end;

procedure TWorkWin.ReloadBClick(Sender: TObject);
begin
  ValuesWin.ValueListDblClick(Self);
end;

procedure TWorkWin.BinaryHMEnter(Sender: TObject);
begin
  PipelineCB.Checked := False;
end;

procedure TWorkWin.xUseExtendedModelCBClick(Sender: TObject);
begin
  PrefWin.UseExtendedModelCB.Load;
end;

procedure TWorkWin.SeparatorEChange(Sender: TObject);
begin
  if not SeparatorE.Enabled then
    Exit;

  if SeparatorE.Text = '' then begin
    if StringE.Text = '' then
      Exit
    else
      MultiStringM.Text := StringE.Text;
    MultiStringTypeRG.Buttons[1].Enabled := False;
    MultiStringTypeRG.ItemIndex := 0;
  end else begin
    if StringE.Text = '' then
      StringE.Text := Join(MultiStringM.Lines, SeparatorE.Text);
    MultiStringTypeRG.Buttons[1].Enabled := True;
    MultiStringTypeRG.ItemIndex := 1;
    Split(StringE.Text, SeparatorE.Text, MultiStringM.Lines, False);
  end;
end;

procedure TWorkWin.HintLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Byte('C')) and (ssCtrl in Shift) then
    with HintLb do
      if ItemIndex >= 0 then
        Clipboard.AsText := Items[ItemIndex];
end;

procedure TWorkWin.DWORDSpecialBClick(Sender: TObject);
begin
  CardinalE.Value := StrToIntDef((Sender as TButton).Caption, 0);
end;

procedure TWorkWin.Button1Click(Sender: TObject);
begin
  ShowPC.SelectNextPage(True);
end;

procedure TWorkWin.SisyPUPopup(Sender: TObject);
begin
  with SisyPU, TSisyThread(Sisys[PopupComponent.Tag]) do
    Items[Integer(Priority)].Checked := True;
end;

procedure TWorkWin.SisyPriorityMIClick(Sender: TObject);
begin
  with TSisyThread(Sisys[SisyPU.PopupComponent.Tag]) do begin
    Priority := TThreadPriority(TMenuItem(Sender).MenuIndex);
    if Priority <= tpNormal then
      Uni.WriteInteger('Priority', Integer(Priority));
  end;
end;

procedure TWorkWin.SisyShowCurrentPathMIClick(Sender: TObject);
begin
  with SisyPU, TSisyThread(Sisys[PopupComponent.Tag]) do begin
    Suspend;
    ShowMessage(CurrentSpyKey.Path);
    Resume;
  end;
end;

procedure TWorkWin.DropFileTargetDrop(Sender: TObject;
  ShiftState: TShiftState; Point: TPoint; var Effect: Integer);
begin
  StringE.Text := DropFileTarget.Files[0];
end;

procedure TWorkWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Action := caNone;
  DropFileTarget.Unregister;
  ClearChanges;
end;

procedure TWorkWin.FormResize(Sender: TObject);
begin
  Realign;
end;

procedure TWorkWin.IconImageDblClick(Sender: TObject);
var
  Filename: string;
begin
  FileName := GetFileNew(StringE.Text);
  if FileName <> '' then
    ExecFile(FileName);
end;

procedure TWorkWin.ShowValues(Reg: TXRegistry);
var
  MainValueName: string;
  ValueCommonType: TRegDataType;

  procedure ShowValueAsBinary(const ValueName: string;
    Smart4BB: Boolean = True);
  begin
    if Smart4BB
     and PrefWin.Smart4BBCB.Checked
     and (Reg.GetDataSize(ValueName) = 4) then begin
      CardinalE.Value := Reg.ReadCardinal(ValueName);
      CardTypeRG.ItemIndex := 2;
      ShowPC.ActivePage := IntPage;
    Exit; end;
    BinaryHM.Data := Reg.ReadBin(ValueName);
    DataTypeComB.ItemIndex := ValueCommonType;
    if IsValidDataType(ValueCommonType) then
      DataTypeComB.ItemIndex := ValueCommonType
    else begin
      DataTypeComB.Text := IntToStr(ValueCommonType);
      AddHint('Value has unknown data type (' + DataTypeComB.Text + '): ' +
        Quote(ValueName));
    end;
    ShowPC.ActivePage := BinaryPage;
  end;

begin
  with ValuesWin do begin
    if not Assigned(ValueNames) or (ValueNames.Count = 0) then
      raise EReadError.Create('ValueNameList error');
    MainValueName := ValueNames[0];
  end;
  ValueCommonType := ValuesWin.ValueCommonType;

  with CurValueE do begin
    Enabled := True;
    if ValuesWin.ValueNames.Count = 1 then
      Text := MainValueName
    else
      Text := Copy(ValuesWin.ValueNames.CommaText, 1, 255);

    Font.Color := ColorOfDataType(ValueCommonType);
  end;

  if KeyIsDown(VK_MENU) or ShowAsBinary then begin
    ShowValueAsBinary(MainValueName, False);
  end else if ValueCommonType in rdStringTypes then begin
    StringE.Text := Reg.ReadString(MainValueName);
    case ValueCommonType of
      rdString: StringTypeRG.ItemIndex := 0;
      rdExpandString: StringTypeRG.ItemIndex := 1;
    end;
    ShowPC.ActivePage := StringPage;
  end else if ValueCommonType in rdCardTypes then begin
    CardinalE.Value := Reg.ReadCardinal(MainValueName);
    case ValueCommonType of
      rdCardinal: StringTypeRG.ItemIndex := 0;
      rdCardBigEndian: StringTypeRG.ItemIndex := 1;
    end;
    ShowPC.ActivePage := IntPage;
  end else if ValueCommonType = rdMultiString then begin
    MultiStringM.Clear;
    Reg.ReadMultiString(MainValueName, MultiStringM.Lines, PrefWin.UseExtendedModelCB.Checked);
    SeparatorEChange(Self);
    MultiStringTypeRG.ItemIndex := 0;
    ShowPC.ActivePage := MultiStringPage;
  end else begin
    ShowValueAsBinary(MainValueName);
  end;

  ShowAsBinary := False;

  UpdateWriteButtons;
end;

procedure TWorkWin.UpdateWriteButtons;
const
  BtnTextOfMultiEdit: array[Boolean] of string = ('Write', 'Write all');
var
  BtnText: string;
begin
  BtnText := BtnTextOfMultiEdit[ValuesWin.ValueNames.Count > 1];
  OKStringB.Caption := BtnText;
  OKIntB.Caption := BtnText;
  OKMultiStringB.Caption := BtnText;
  OKBinaryB.Caption := BtnText;
end;

procedure TWorkWin.EditData;
begin
  AddHint('Edit');
  MainPC.ActivePage := WorkPage;

  with ShowPC do
    if ActivePage = nil then
      Exit
    else if ActivePage = WorkWin.StringPage then begin
      FocusControl(StringE);
      StringE.SelectAll;
    end
    else if ActivePage = WorkWin.IntPage then
      FocusControl(CardinalE)
    else if ActivePage = WorkWin.MultiStringPage then
      FocusControl(MultiStringM)
    else if ActivePage = WorkWin.BinaryPage then
      FocusControl(BinaryHM)
    else
      ShowMessage('Error: ShowPC.ActivePage!');
end;

procedure TWorkWin.SisyTVCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with TTreeView(Sender).Canvas.Font do begin
    if Node.Cut then
      Color := $AAAAAA
    else
      Color := clWhite;
  end;
end;

procedure TWorkWin.SisyTVMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  RelX, RelY: Integer;
begin
  with SisyTV do begin
    RelX := ScreenToClient(Mouse.CursorPos).X;
    RelY := ScreenToClient(Mouse.CursorPos).Y;
    Node := GetNodeAt(RelX, RelY);
  end;
  if not Assigned(Node) then
    Exit;

  if not Node.Selected then
    Node.Selected := True;
end;

procedure TWorkWin.OKCryptoBClick(Sender: TObject);
var
  i: Integer;
begin
  try
    OpenCurKey;
    with ValuesWin.ValueNames do
      for i := 0 to Count-1 do begin
        case CryptoTypeRG.ItemIndex of
          0: MainReg.WriteBin(Strings[i], EncodeScreenSaver(CryptoE.Text));
          1: MainReg.WriteBin(Strings[i], EncodeSharedFolder(CryptoE.Text));
        end;
      end;
    ValuesWin.UpdateValues(True);
  finally
    MainReg.CloseKey;
  end;
  ValuesWin.ValueListDblClick(Sender);
end;

procedure TWorkWin.CryptoEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    OKCryptoBClick(Sender);
    ValuesWin.FocusControl(ValueList);
  end;
  if Key = VK_ESCAPE then
    CancelBClick(Sender);
end;

end.
