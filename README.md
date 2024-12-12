
# Raxon's Server - ND_Death

 Discord : https://discord.gg/VHDbgpnBbR

Welcome to **Raxon's Server**! This repository contains the **ND_Death** script for **FiveM**. The script manages player death events, EMS notifications, and admin revive commands to enhance roleplay immersion on your server.

## Features

- **Death Handling**: Detects when a player dies and manages respawn mechanics.
- **EMS Notifications**: Notifies EMS with location details when a player is down.
- **CPR Command**: Allows authorized players (NHS/EMS) to perform CPR on downed players.
- **Admin Revive**: Provides a command for admins to revive players.
- **Custom Notifications**: Integration with ModernHUD for stylish notifications.
- **Bleed-Out Timer**: Automatic respawn after a set duration if no help arrives.
- **Debug Logging**: Console messages for easy debugging and monitoring.

## Commands

- **Admin Revive Command**:
  ```
  /adrev [playerID]
  ```
  - Revives the specified player. Requires admin permissions.

- **Call NHS Command**:
  ```
  /callnhs
  ```
  - Notifies EMS of a downed player at your current location.

- **CPR Command**:
  ```
  /cpr [playerID]
  ```
  - Performs CPR on a specified player. Only available to EMS/NHS roles.

## Configuration

### Default Settings

- **Respawn Time**: Set the bleed-out timer in `Config.respawnTime`.
- **EMS Departments**: Define EMS roles in `Config.MedDept`.

Example configuration:

```lua
Config.respawnTime = 300 -- Time in seconds before automatic respawn
Config.MedDept = {"NHS", "EMS"} -- Jobs allowed to use the CPR command
```

## Installation

1. **Clone or Download** this repository to your `resources` folder:
   ```bash
   git clone https://github.com/yourusername/ND_Death.git
   ```

2. **Add to `server.cfg`**:
   ```cfg
   ensure ND_Death
   ```

3. **Restart the Server**:
   ```bash
   restart ND_Death
   ```

## Dependencies

- **ND_Core**: Required for core server functions.
- **oxmysql**: For database interactions.
- **ModernHUD** (optional): For enhanced notifications.

## How It Works

1. **Death Detection**: The script detects when a player’s health reaches zero.
2. **EMS Notification**: Sends an EMS call with the player’s location.
3. **CPR and Revive**:
   - EMS can perform CPR on players.
   - Admins can use `/adrev` to revive any player.
4. **Respawn System**: Players respawn after the bleed-out timer expires or when revived.

## Contribution

We welcome contributions! If you have ideas, enhancements, or bug fixes, feel free to create a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

## Contact

- **Discord**: [Join Our Community](https://discord.gg/raxons-server)
- **Website**: [raxons-server.com](https://www.raxons-server.com)

---

Stay safe and enjoy **Raxon's Server**! ⚙️ 🚑

![Banner](https://via.placeholder.com/728x90.png?text=Raxon's+Server)




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


ORIGINAL

# ND_Death 

![ND_PanicButton (1)](https://github.com/lucaswydx/ND_Death/assets/112611821/3b32047b-0efa-4fdb-9884-f65675facff7)

**ND_Death** is a script for ND-Framework's FiveM game server that enhances the player experience by providing features related to player death, EMS notifications, and respawn mechanics. It allows server administrators to configure various aspects of the player's death and revival process.

## Features

- **Player Down State**: When a player's health drops below a certain threshold, they enter a downed state, displaying a timer until they can respawn.
- **EMS Notification**: When a player is downed, medical departments (EMS) are notified to respond to the player's location for revival.
- **Automatic EMS Notification**: Option to automatically notify EMS when a player is downed and in need of medical attention.
- **CPR Animation**: Players can initiate a CPR animation to revive downed players.
- **Admin Revive Command**: Admins can instantly revive players using their player ID.
- **CPR Command**: Medical department members can initiate CPR on players to revive them.
- **Customizable Respawn Timer**: Configure the amount of time a player has to respawn after being downed.
- **Customizable Respawn Text**: Customize the text displayed to players when they are downed.
- **Integration with ND_Core**: Utilizes the ND_Core framework for seamless integration and enhanced functionality.
- **Integration with ModernHUD**: Integrated with ModernHUD for enhanced visual notifications. If ModernHUD is not available, notifications are sent via chat messages.

## Updates and Fixes

- [List any updates and fixes here.]

## Commands

- `/callems`: Manually notify EMS about a downed player's location. If the ModernHUD resource is available, it will show a notification; otherwise, it will use chat messages.

- `/adrev [targetPlayerId]`: Admins can use this command to revive a player instantly. Replace `[targetPlayerId]` with the player's ID.

- `/cpr [targetPlayerId]`: Medical department members can use this command to initiate CPR on a player. Replace `[targetPlayerId]` with the player's ID.

## Configurables

The behavior and features of the ND_Death script can be customized through the provided configuration file (`config.lua`). The following configurables are available:

- `respawnKey`: Set the keybind for respawning the player (default is `38` which corresponds to the `E` key).
- `respawnTime`: Set the time in seconds that players have to respawn after being downed.
- `respawnText`: Customize the text displayed to players when they are downed with no respawn timer.
- `respawnTextWithTimer`: Customize the text displayed to players when they are downed with a respawn timer. Use `%d` as a placeholder for the remaining seconds.
- `respawnLocations`: Define a list of possible respawn locations with coordinates and heading.
- `bleedoutTime`: Set the time in seconds for the player's bleed out duration before respawn.
- `AutoNotify`: Enable or disable automatic EMS notification when a player is downed.
- `MedDept`: Define the list of job departments that are considered part of the medical team.

An example of adding respawn locations:

```lua
respawnLocations = {
    { x = 298.29, y = -584.26, z = 43.26, h = 61.98 }, -- Example respawn location
    { x = 1839.21, y = 3673.5, z = 34.26, h = 198.93 }, -- Another example respawn location
    -- Add more respawn locations here
},

## Dependencies

- [ND_Core](https://github.com/ND-Framework/ND-Core): ND_Core provides essential functionalities for seamless integration.
- [ND_Characters](https://github.com/ND-Framework/ND_Characters): ND_Characters provides essential functionalities for Job Notifcations and Admin Permissions.

# Optionals

- [ModernHUD](https://andyyy.tebex.io/): Integrated with ModernHUD for visual notifications.

## Installation

1. Ensure you have the required dependencies installed.
2. Copy the contents of this repository into your server's resources folder.
3. Configure the script by modifying the `config.lua` file.
4. Add `ensure ND_Death` to your server.cfg. **Make sure you start it after ND_Core and ND_Characters.**

## Support and Contribution

For support, bug reports, or feature requests, please create an issue on this repository. Contributions are welcome, and pull requests are encouraged.

- [Discord](https://discord.gg/andys-development-857672921912836116)

Enjoy the enhanced player experience with ND_Death!

### Authors
- [Lucas Wyatt](https://github.com/lucaswydx)
- [TheStoicBear](https://github.com/TheStoicBear)
