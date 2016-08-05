unit uLaunchMgr;

interface

uses classes, SysUtils, superobject, uMD5, ShellAPI, Windows, StrUtils;

function GetLibraries(jsonfile: String; getArgu: Boolean = False): TStringList;

procedure GetShareFiles(source_path: string; var List: Tstringlist);

function getVersions(path: String): TStringList;

function ReplaceArgus(mcArguments, auth_player_name, version_name,
    game_directory, assets_root, asset_index_name, auth_uuid,
    auth_access_token, user_properties, user_type, version_type: String):
    string;

function launch(GamePath, UserName, MaxMemory, Javaw: String): Boolean; stdcall;

var
  version:String;
  id: String;
  assets: String;
  mainClass: String;
  version_type: String;
  auth_uuid: String;
  inheritsFrom: String;
  jar: String;
  minecraftArguments: String;

implementation

function GetLibraries(jsonfile: String; getArgu: Boolean = False): TStringList;
var
  I: Integer;
  jo: ISuperObject;
  ja: TSuperArray;
begin
  Result := TStringList.Create;

  if Not FileExists(jsonfile) then
  begin
    //outputdebugstring ('JSON�ļ�['+ExtractFileName(jsonfile)+']������ !');
    Exit;
  end;
  with TStringList.Create do
  begin
    LoadFromFile(jsonfile);
    jo := SO(Text);
  end;

  ja := jo.A['libraries'];
  for I := 0 to ja.Length-1 do
  begin
    Result.Add(ja.O[I].S['name']);
  end;  

  if getArgu then
  begin
    minecraftArguments := jo.S['minecraftArguments'];
    id := jo.S['id'];
    assets := jo.S['assets'];
    mainClass := jo.S['mainClass'];
    version_type := jo.S['type'];
    try
      inheritsFrom := jo.S['inheritsFrom'];
    except
    end;
    auth_uuid := 'e92d68bd1dfc06c65192888711a052f6';
  end;
end;

//******************************************************************************
// �����ļ���,��ȡ����jar�ļ�
//******************************************************************************
procedure GetShareFiles(source_path: string; var List: Tstringlist);
  procedure FindAll(const Path: string; var List: Tstringlist);
  var
   sr: TSearchRec;
   fr: Integer;
   temp_str: string;
  begin
     fr := FindFirst(Path + '\*.*', faAnyFile, sr);
    while fr = 0 do
    begin
      if ((sr.Attr and faDirectory) = faDirectory) and (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        FindAll(Path + '\' + sr.Name, List); //�ݹ������һ��Ŀ¼
      end
      else
       if (sr.Name <> '.') and (sr.Name <> '..') then
       begin
        if ExtractFileExt(sr.Name) = '.jar' then
         List.Append(Path + '\' + sr.name);
       end;
     temp_str := sr.name;
     FindNext(sr);
     if temp_str = sr.Name then
       break;
    end;
    SysUtils.FindClose(sr);
  end;
begin
  FindAll(source_path, List);
end;

//******************************************************************************
// ��ȡVersionĿ¼�ڵ��ļ���
//******************************************************************************
function getVersions(path: String): TStringList;
var
   SearchRec:TSearchRec;
   found:integer;
begin
  Result := TStringList.Create;
  found:=FindFirst(path+'\*.*',faAnyFile,SearchRec);
  while found=0 do
  begin
    if(SearchRec.Name<>'.') and (SearchRec.Name<>'..') and (SearchRec.Attr = faDirectory) then
    begin
      Result.Add(SearchRec.Name);
    end;
    found:=FindNext(SearchRec);
  end;
  SysUtils.FindClose(SearchRec);
end;

//******************************************************************************
// �滻 minecraftArguments �еĲ���
//******************************************************************************
function ReplaceArgus(mcArguments, auth_player_name, version_name,
    game_directory, assets_root, asset_index_name, auth_uuid,
    auth_access_token, user_properties, user_type, version_type: String):
    string;
begin
  //forge --username ${auth_player_name} --version ${version_name} --gameDir ${game_directory} --assetsDir ${assets_root} --assetIndex ${assets_index_name} --uuid ${auth_uuid} --accessToken ${auth_access_token} --userProperties ${user_properties} --userType ${user_type} --tweakClass cpw.mods.fml.common.launcher.FMLTweaker
  //������ --username ${auth_player_name} --version ${version_name} --gameDir ${game_directory} --assetsDir ${assets_root} --assetIndex ${assets_index_name} --uuid ${auth_uuid} --accessToken ${auth_access_token} --userType ${user_type} --versionType ${version_type}
  mcArguments := StringReplace(mcArguments, '${auth_player_name}', auth_player_name, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${version_name}', version_name, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${game_directory}', game_directory, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${assets_root}', assets_root, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${assets_index_name}', asset_index_name, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${auth_uuid}', auth_uuid, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${auth_access_token}', auth_access_token, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${user_properties}', user_properties, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${user_type}', user_type, [rfReplaceAll]);
  mcArguments := StringReplace(mcArguments, '${version_type}', version_type, [rfReplaceAll]);
  Result := mcArguments;
end;

//******************************************************************************
// ������Ϸ
//******************************************************************************
function launch(GamePath, UserName, MaxMemory, Javaw: String): Boolean;
var
  I, J: Integer;
  str: String;
  runparam: String;
  jsonPath: String;
  mcArgu: String;
  lst_version, lst_libraries, lst_json, lst: TStringList;
begin
  Result := False;
  if gamepath = '' then Exit;
  jar := '';
  //��ȡ���а汾,Ĭ������forge�汾
  GamePath := GamePath+'\.minecraft\';
  lst_version := getVersions(gamepath+'versions');
  if lst_version.Count = 1 then
    version := lst_version[0]
  else
    for I := lst_version.Count-1 downto 0 do
    begin
      if AnsiContainsText(lst_version[I], 'forge') then
      begin
        version := lst_version[I];
        Break;
      end;
    end;
  //����Json,��ȡ���в���

  jsonPath := gamepath+'versions\'+version+'\'+version+'.json';
  lst_json := GetLibraries(jsonPath, True);
  if inheritsFrom <> '' then
  begin
    jsonPath := gamepath+'versions\'+inheritsFrom+'\'+inheritsFrom+'.json';
    lst_json.AddStrings( GetLibraries(jsonPath) );
  end;

  lst := TStringList.Create;
  for I := 0 to lst_json.Count-1 do
  begin
    lst.Clear;
    ExtractStrings([':'], [':'], pChar(lst_json[I]), lst);
    str := StringReplace(lst[0], '.', '\', [rfReplaceAll]);
    str := str + '\'+lst[1]+ '\'+lst[2];
    lst_json[I] := str;
  end;
  lst.Free;

  lst_libraries := TStringList.Create;
  GetShareFiles(gamepath+'libraries', lst_libraries);
  for I := lst_json.Count-1 downto 0 do
  begin
    for J := lst_libraries.Count-1 downto 0 do
    begin
      if AnsiContainsText(lst_libraries[J], 'windows') then Continue;
      if AnsiContainsText(lst_libraries[J], lst_json[I]) then
      begin
        jar := lst_libraries[J] +';'+ jar;
      end;
    end;
  end;
  lst_libraries.Free;
  if inheritsFrom = '' then
    jar := jar+ gamePath+'versions\'+id+'\'+id+'.jar'
  else
    jar := jar+ gamePath+'versions\'+inheritsFrom+'\'+inheritsFrom+'.jar';

  //���� �滻minecraftArguments
  auth_uuid := MD5Print(MD5String(auth_uuid));
  mcArgu := ReplaceArgus(minecraftArguments, username, ID, gamepath, gamepath+'assets', assets, auth_uuid, auth_uuid, '{}', 'legacy', version);
  runparam := '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump'
                +' -XX:+UseG1GC -XX:-UseAdaptiveSizePolicy -XX:-OmitStackTraceInFastThrow'
                +' -Xmn128M -Xmx'+maxMemory+'M'
                +' -Djava.library.path='+gamepath+'versions\'+version+'\'+version+'-natives'
                +' -Dfml.ignoreInvalidMinecraftCertificates=true -Dfml.ignorePatchDiscrepancies=true'
                +' -cp '+jar
                +' '+mainClass+' '+ mcArgu
                +' --height 480 --width 854';
  //OutputDebugString(pChar('mclaunch:'+str));
  ShellExecute(0, nil, pChar(javaw), pChar(runparam), pChar(GamePath), SW_SHOWNORMAL);
  Result := True;
end;

end.
