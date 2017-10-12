--聊天对象类型
ChatObjectTypes = {
None = 0,
World = 1,   --世界
Current = 2, --当前
Society = 3, --公会
Private = 4, --私聊
Horn = 5, --喇叭
System = 6,  --系统
All = 7,     --全部
GM = 8, --gm邮件
Max = 9, 
SytSociety = 10, --公会系统
}

ChatColor = {
[ChatObjectTypes.World] = Config.FontColor["ColorYellow1"],
[ChatObjectTypes.Society] = Config.FontColor["ColorGreen1"],
[ChatObjectTypes.Current] = Config.FontColor["ColorWhite1"],
[ChatObjectTypes.Private] = Config.FontColor["ColorPurple1"],
[ChatObjectTypes.System] = Config.FontColor["ColorRed1"],
[ChatObjectTypes.Horn] = Config.FontColor["ColorOrange1"],
}

--发送还是接收
ChatDir = {
Receive = 1, 
Send = 2,
}

--朋友分组
PeerGroupType = {
None = 0,
TemporaryFriend = 4,
Friend = 3,
Enemy = 2,
BlackList = 1,
}

WhisperOperateType = {
getPeerList = 1,
addOnePeer = 2,
deleteOnePeer = 3,
privateChat = 4,
}
	
ChatCode = 
{
Success = 1, 
Error = 2, 
Cancel = 3,
}

