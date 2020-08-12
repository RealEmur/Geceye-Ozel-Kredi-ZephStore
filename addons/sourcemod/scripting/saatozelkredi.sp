#include <sourcemod>
#include <store>
#pragma tabsize 0

ConVar gecekredi_miktar, gecekredi_sure;
int aktif = 0;

public void OnPluginStart()
{
	gecekredi_miktar = CreateConVar("gecekredi_miktar", "100", "Kaç kredi verileceğini yazınız.");
	gecekredi_sure = CreateConVar("gecekredi_sure", "600", "Kaç saniyede bir kredi verileceğini yazınız.");
	
	AutoExecConfig(true, "gecekredi", "emur");
	CreateTimer(1.0, kontrolcu, _, TIMER_REPEAT);
}


public Action kontrolcu(Handle timer)
{
	char buffer[64];
    FormatTime(buffer, sizeof(buffer), "%H", GetTime()); 
    int saat = StringToInt(buffer);
    if((saat >= 0 && saat < 4) || (saat >= 9 && saat < 12))
    {
    	if(aktif == 0)
    	{
    		aktif = 1;
    		CreateTimer(gecekredi_sure.FloatValue, sayac, _, TIMER_REPEAT);
    	}	
   	}
   	else
   	{
		aktif = 0;
   	}
   	return Plugin_Continue;
}

public Action sayac(Handle timer)
{
	if(aktif == 1)
	{
		PrintToChatAll(" \x07[SM] \x01Saate özel kredi etkinliği devam etmektedir.");
		for(int i = 1; i < MAXPLAYERS ; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				PrintToChat(i, " \x07[SM] \x01Bu saatte aktif olduğundan \x04%d \x01kredi kazandın.", GetConVarInt(gecekredi_miktar));
				int yenikredi = Store_GetClientCredits(i) + GetConVarInt(gecekredi_miktar);
				Store_SetClientCredits(i, yenikredi);
			}
		}
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Stop;
	}
}
