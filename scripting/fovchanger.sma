#include <amxmodx>
#include <reapi>
#include <hamsandwich>
#include <cstrike_const>
#include <nvault>

/* !!! WARNING !!!
* You are about to witness the shittiest code ever written in the history of humanity!
* I didn't care enough to make it look nice
* or learn Pawn syntax properly so I just put a bunch of shit together and hoped it worked,
* so prepare for what you are about to see.
* Also, I kind of went insane while finishing the 1.0.0 release.
* 
* ReAPI Fov Changer
* Goals:
*   - (1) Store FOV in a database (so you don't have to set it every time)
*   - (2) Command for changing and resetting FOV
*/

#pragma semicolon 1

#define PLUGIN_VERSION "1.0.0"
#define PREFIX "[FOV]"

new g_pCvarStore;

new nStoreEnabled = 0;

new g_hNVault;

new fovPlayers[MAX_PLAYERS+1];  // option for storing FOV in RAM if you are stupid and don't use nVault

public plugin_init() {
    new szWeapon[32];

    register_plugin("[ReAPI] FOV Changer", PLUGIN_VERSION, "sh0tx");
    create_cvar("amx_fovchanger_version", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY | FCVAR_UNLOGGED, "FOV Changer Version");
    g_pCvarStore = create_cvar("amx_fovchanger_store", "1", FCVAR_SERVER | FCVAR_SPONLY, "(Recommended) Store players' FOV in nVault? 1: yes | 0: no", true, 0.0, true, 1.0);

    nStoreEnabled = get_pcvar_num(g_pCvarStore);

    // loop through all base weapons
    for (new i = CSW_NONE + 1; i <= CSW_LAST_WEAPON; i++) {
        if (i == CSW_GLOCK) { // unused by game
            continue;
        }

        get_weaponname(i, szWeapon, charsmax(szWeapon));
        //server_print("[FOV Changer] Registered Ham_Item_Deploy: %s", szWeapon);
        RegisterHam(Ham_Item_Deploy, szWeapon, "fw_WeaponDeployPost", true);    // ham ham ham bur bur bur ger ger ger hambur burger ham
        RegisterHam(Ham_Weapon_Reload, szWeapon, "fw_WeaponDeployPost", false);
    }

    // database stuff
    if (nStoreEnabled == 1) {
        g_hNVault = nvault_open("reapifov");
    }

    //register_event("CurWeapon", "PersistFov", "b", "1=0");
    //register_clcmd("/fov", "Cmd_SetFov");

    return PLUGIN_HANDLED;
}

public plugin_end() {
    if (nStoreEnabled == 1) {
        nvault_close(g_hNVault);
    }
}

// Persist the FOV by retrieving from database
// this gets fired on Ham_Item_Deploy
public fw_WeaponDeployPost(const pEntity) {
    new szAuthId[32];  // no MAX_AUTHID_LENGTH
    new szFov[4];
    new iFov;

    static pPlayer;
    pPlayer = get_member(pEntity, m_pPlayer);

    if (nStoreEnabled == 1) {
        get_user_authid(pPlayer, szAuthId, charsmax(szAuthId));
        nvault_get(g_hNVault, szAuthId, szFov, charsmax(szFov));
    }
    else {
        num_to_str(fovPlayers[pPlayer], szFov, charsmax(szFov)); // ??????????
    }

    iFov = str_to_num(szFov);

    set_member_s(pPlayer, m_iFOV, iFov);
    
    //set_member_s(pPlayer, m_iFOV, iFov);
}

// X IS CURRENT WEAPON YES
public IsScopedWeaponCykaBlyat(x) {
    if (x == CSW_SCOUT || x == CSW_AUG || x == CSW_SG550 || x == CSW_AWP || x == CSW_G3SG1 || x == CSW_SG552) {   // I ALMOST FORGOT THIS IS A IF CHECK BLYAT
        return true;
    }
    else {
        return false;
    }
}   

// Change FOV for player entity <id> to FOV value <fov>
public ChangeFov(id, fov) {
    new nFovSet;
    new szAuthId[32];  // no MAX_AUTHID_LENGTH
    new szFov[4];

    nFovSet = set_member_s(id, m_iFOV, fov);

    if (nFovSet == 1) {
        if (nStoreEnabled == 1) {
            get_user_authid(id, szAuthId, charsmax(szAuthId));  // since when did we use charsmax() instead of sizeof() to determine array size
            num_to_str(fov, szFov, charsmax(szFov));
            nvault_set(g_hNVault, szAuthId, szFov);
        }
        else {
            fovPlayers[id] = fov;
        }

        if (fov == 0) {
            client_print_color(id, print_team_default, "^4%s^1 Reset FOV", PREFIX);
        }
        else {
            client_print_color(id, print_team_default, "^4%s^1 Set FOV to: %i", PREFIX, fov);
        }
    }
}

/*
public client_authorized(id) {
    if (!is_user_bot(id)) {
        PersistFov(id);
    }
}
*/

public client_command(id) {
    new szCmd[12];   // make 16 if needed or smth idk

    new szArg1[4];
    new szArg2[4];

    new nFov;

    // szCmd will be: /fov <num>
    read_argv(1, szCmd, charsmax(szCmd));
    //client_print(id, print_chat, "szCmd: %s", szCmd);

    // if anyone complains we can make the command case sensitive
    if (strfind(szCmd, "/fov", true) != -1) {
        // separate szCmd "/fov, <int>"
        strtok2(szCmd, szArg1, charsmax(szArg1), szArg2, charsmax(szArg2));
        nFov = str_to_num(szArg2);

        //client_print(id, print_chat, "szArg1: %s", szArg1);
        //client_print(id, print_chat, "szArg2: %s", szArg2);
        //client_print(id, print_chat, "nFov: %i", nFov);

        ChangeFov(id, nFov);

        /*
        new nReqFov = read_argv_int(2);  // Requested FOV from argument | NOTE: read_argv_int(1) returns the number after "/fov " so dont fuck with it ok thx
        client_print(id, print_chat, "nReqFov: %i", nReqFov);
        ChangeFOV(id, nReqFov);
        */
    }

    return PLUGIN_CONTINUE;
}
