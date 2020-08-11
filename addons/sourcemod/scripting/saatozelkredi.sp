#include <sourcemod>
#include <store>
#pragma tabsize 0

Handle gecekredi_miktar, gecekredi_sure;
int aktif = 0, saniye;

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
    if(saat >= 0 && saat < 4)
    {
    	aktif = 1;
    	saniye = GetConVarInt(gecekredi_sure);
    	CreateTimer(1.0, sayac, 0, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
   	}
   	else if (saat >= 9 && saat < 12)
   	{
   		aktif = 1;
   		saniye = GetConVarInt(gecekredi_sure);
   		CreateTimer(1.0, sayac, 1, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
   	}
   	else if(aktif == 1)
   	{
   		aktif = 0;
   	}
   	return Plugin_Continue;
}

public Action sayac(Handle timer, any durum)
{
	if(aktif == 1)
	{
		saniye--;
		if(saniye == 0)
		{
			saniye = GetConVarInt(gecekredi_sure);
			if(durum == 0)
			{
				PrintToChatAll(" \x07[SM] \x01Geceye özel kredi etkinliği devam etmektedir.");
			}
			else
			{
				PrintToChatAll(" \x07[SM] \x01Sabaha özel kredi etkinliği devam etmektedir.");
			}
			for(int i = 1; i < MAXPLAYERS ; i++)
			{
				if(IsClientInGame(i) && !IsFakeClient(i))
				{
					PrintToChat(i, " \x07[SM] \x01Bu saatte aktif olduğundan \x04%d \x01kredi kazandın.", GetConVarInt(gecekredi_miktar));
					int yenikredi = Store_GetClientCredits(i) + GetConVarInt(gecekredi_miktar);
					Store_SetClientCredits(i, yenikredi);
				}
			}
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}