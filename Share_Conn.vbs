Dim sPublicConnectionName, sPrivateConnectionName, Args

Set args = WScript.Arguments

sPublicConnectionName = args(0)
sPrivateConnectionName = "Microsoft Hosted Network Virtual Adapter"
bEnable = args(1)
 
    Dim oNetSharingManager, oConnectionCollection, oItem, EveryConnection, objNCProps
   Set oNetSharingManager = wscript.CreateObject("HNetCfg.HNetShare.1")
   Set oConnectionCollection = oNetSharingManager.EnumEveryConnection
    For Each oItem In oConnectionCollection
        Set EveryConnection = oNetSharingManager.INetSharingConfigurationForINetConnection(oItem)
        Set objNCProps = oNetSharingManager.NetConnectionProps(oItem)
        If objNCProps.DeviceName = sPrivateConnectionName Then
            If bEnable Then
                EveryConnection.EnableSharing(1)
            Else
                EveryConnection.DisableSharing()
            End If
        End If
    Next
   Set oConnectionCollection = oNetSharingManager.EnumEveryConnection
    For Each oItem In oConnectionCollection
        Set EveryConnection = oNetSharingManager.INetSharingConfigurationForINetConnection(oItem)
        Set objNCProps = oNetSharingManager.NetConnectionProps(oItem)
        If objNCProps.Name = sPublicConnectionName Then
            If bEnable Then
                EveryConnection.EnableSharing(0)
            Else
                EveryConnection.DisableSharing()
            End If
        End If
    Next

Wscript.Quit
