Dim tipo, args

Set args = WScript.Arguments

tipo = args(0)

    DIM objShare
    DIM objEveryColl
    
    set objShare = Wscript.CreateObject("HNetCfg.HNetShare.1")
    if(IsObject(objShare) = FALSE ) then
      WScript.Quit  
    end if
    
    set objEveryColl = objShare.EnumEveryConnection
    
    if (IsObject(objEveryColl) = TRUE) then
    
    DIM objNetConn
    dim str
    for each objNetConn in objEveryColl
      DIM objShareCfg
      set objShareCfg = objShare.INetSharingConfigurationForINetConnection(objNetConn)
      if (IsObject(objShareCfg) = TRUE) then
        DIM objNCProps
        set objNCProps = objShare.NetConnectionProps(objNetConn)
        if (IsObject(objNCProps) = TRUE) then
          'WScript.Echo "Name: "   & objNCProps.Name
          'WScript.Echo "Guid: "   & objNCProps.Guid
          'WScript.Echo "DeviceName: " & objNCProps.DeviceName
          'WScript.Echo "Status: "     & objNCProps.Status
          'WScript.Echo "MediaType: "  & objNCProps.MediaType
          'WScript.Echo ""

if tipo = "Hosted" then
 if objNCProps.DeviceName = "Microsoft Hosted Network Virtual Adapter" then
  str = str & " |" & objNCProps.Name & "| "
 end if
else
 if tipo = "NotHosted" then
  if objNCProps.DeviceName <> "Microsoft Hosted Network Virtual Adapter" and  objNCProps.Status = 2 then
  str = str & " |" & objNCProps.Name & "| "
  end if
 end if
end if
        end if
        
      end if
    next
 WScript.Echo (str)
    end if