# ReAPI FOV Changer
Plugin to change Field of View in CS1.6 using ReAPI. <br />
FOV can be changed using the command `/fov <number>`. <br />
FOV can be stored in nVault so users don't have to set their FOV every time they join the server. <br />

<img src="https://github.com/sh0tx-amxx/reapi_fovchanger/blob/main/amxgif1.gif?raw=true" alt="functionality">

### Cvars
- `amx_fovchanger_version` - Plugin version, do not edit.
- `amx_fovchanger_store <0/1>` - Store players' FOV in nVault? 1: yes | 0: no - Default: 1

### Bugs
- Breaks snipers' scoping ability (you can scope but it's bugged)
- Reloading with custom weapons causes FOV to change
- FOV min/max limit is not yet implemented
