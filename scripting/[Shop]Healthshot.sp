#include <sourcemod>
#include <shop>
#include <sdktools>
#include <sdktools_hooks>

public Plugin myinfo =
{
		name =  "[Shop]Healthshot" ,
		author =  "ZIFON" ,
		description =  "https://github.com/ZIFON" ,
		version =  "1.0" ,
		url =  "https://github.com/ZIFON"
};

CategoryId gcategory_id;
ItemId g_iID;
bool g_bSpecialGrenade[MAXPLAYERS+1];
ConVar CVARB, CVARS;

public void OnPluginStart()
{
		HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_PostNoCopy);
		HookEvent("player_spawned",Event_PlayerSpawn);
		HookEvent("weapon_fire",Healthshot);
		AutoExecConfig(true, "shop_Healthshot");

		(CVARB = CreateConVar("sm_shop_Healthshot", "450", "Цена покупки.", _, true, 0.0)).AddChangeHook(ChangeCvar_Buy);
		(CVARS = CreateConVar("sm_shop_Healthshot_sell_price", "200", "Цена продажи.", _, true, 0.0)).AddChangeHook(ChangeCvar_Sell);

		if(Shop_IsStarted()) Shop_Started();
}

public void Shop_Started()
{
		gcategory_id = Shop_RegisterCategory("ability", "Способности", "");

		if (Shop_StartItem(gcategory_id, "shop_Healthshot"))
			{
				Shop_SetInfo("Шприц", "Шприц", CVARB.IntValue, CVARS.IntValue, Item_BuyOnly, 0);
				Shop_SetCallbacks(_, _, _, _, _, _, ItemBuyCallback);
				Shop_EndItem();
			}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast){
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bSpecialGrenade[i] = false;
		}
}
public Action Healthshot(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && IsPlayerAlive(client) && g_bSpecialGrenade[client])
		{
			char buffer[128];
			event.GetString("weapon",buffer,sizeof(buffer));
			if(StrEqual(buffer,"weapon_healthshot"))
			{
					g_bSpecialGrenade[client] = false;
			}
		}
	return Plugin_Continue;
}


public void ChangeCvar_Buy(ConVar convar, const char[] oldValue, const char[] newValue)
{
		Shop_SetItemPrice(g_iID, convar.IntValue);
}

public void ChangeCvar_Sell(ConVar convar, const char[] oldValue, const char[] newValue)
{
		Shop_SetItemSellPrice(g_iID, convar.IntValue);
}
public void OnItemRegistered(CategoryId category_id, const char[] sCategory, const char[] sItem, ItemId item_id)
{
		g_iID = item_id;
}
public void Event_OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && g_bSpecialGrenade[client])
		g_bSpecialGrenade[client] = false;
}


public bool ItemBuyCallback(int client, CategoryId category_id, const char[] category, ItemId item_id, const char[] item, ItemType type, int price, int sell_price, int value, int gold_price, int gold_sell_price){

	if (!IsPlayerAlive(client))
	{
		PrintToChat(client, " \x04[\x05Shop\x04] \x02Вы должны быть живы.");
	}
	else if (g_bSpecialGrenade[client])
	{
		PrintToChat(client, " \x04[\x05Shop\x04] \x02Вы еще не использовали предыдущий шприц.");
	}
	else
	{
		PrintToChat(client, " \x04[\x05Shop\x04] \x06Вы успешно приобрели шприц.");
		g_bSpecialGrenade[client] = true;
		GivePlayerItem(client, "weapon_healthshot");
		return true;
	}
	return false;

}