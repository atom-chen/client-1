--�����������
ChatObjectTypes = {
None = 0,
World = 1,   --����
Current = 2, --��ǰ
Society = 3, --����
Private = 4, --˽��
Horn = 5, --����
System = 6,  --ϵͳ
All = 7,     --ȫ��
GM = 8, --gm�ʼ�
Max = 9, 
SytSociety = 10, --����ϵͳ
}

ChatColor = {
[ChatObjectTypes.World] = Config.FontColor["ColorYellow1"],
[ChatObjectTypes.Society] = Config.FontColor["ColorGreen1"],
[ChatObjectTypes.Current] = Config.FontColor["ColorWhite1"],
[ChatObjectTypes.Private] = Config.FontColor["ColorPurple1"],
[ChatObjectTypes.System] = Config.FontColor["ColorRed1"],
[ChatObjectTypes.Horn] = Config.FontColor["ColorOrange1"],
}

--���ͻ��ǽ���
ChatDir = {
Receive = 1, 
Send = 2,
}

--���ѷ���
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

