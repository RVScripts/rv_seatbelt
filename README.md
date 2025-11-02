# 🚗 RV SCRIPTS – Seatbelt Script v1.0.0

A realistic and optimized **seatbelt system** for FiveM that prevents players from exiting vehicles, adds realistic crash ejections, and includes automatic seatbelt fastening for emergency vehicles.

Works with **ESX**, **QBCore**, **ox_lib**, and **Standalone** servers.  
Lightweight, zero lag, and no server-side dependencies.

---

## ⚙️ Features

- `/seatbelt` command and **B key** to toggle seatbelt  
- Prevents exiting the vehicle while seatbelt is on  
- **Realistic ejection** through the windshield when crashing without a seatbelt  
- **Emergency vehicles auto-fastened** (police, ambulance, firetruck)  
- Independent seatbelts for driver and passengers  
- Smart 6-second notifications (green/red)  
- Automatic framework detection (ESX / QBCore / ox_lib / standalone)  
- 0.00ms idle performance  

---

## 🧩 Framework Support

| Framework | Supported | Notes |
|------------|------------|--------|
| **ESX** | ✅ | Works with ESX v1, v1.2, Legacy |
| **QBCore** | ✅ | Uses QBCore.Functions.Notify |
| **ox_lib / ox_core** | ✅ | Optional notify integration |
| **Standalone** | ✅ | Uses GTA native text feed |

---

## 🛠️ Commands & Keybinds

| Command / Key | Description |
|----------------|-------------|
| `/seatbelt` | Toggle seatbelt ON/OFF |
| **B** | Default toggle key (can be changed in Key Bindings → FiveM) |

> The script uses `RegisterKeyMapping`, so players can freely change the key in their FiveM settings.

---

## 🚓 Emergency Vehicles

- Automatically fastens seatbelt for **police**, **ambulance**, and **firetruck** vehicles.  
- Cannot be unbuckled while inside emergency vehicles.  
- Player can still exit the vehicle normally.

You can add custom emergency models in:
```lua
local emergencyWhitelist = {
  -- [`yourVehicleModel`] = true,
}

## 🎥 YouTube Video

🎬 **Watch the showcase video:**  
👉 [Click here to watch on YouTube](https://www.youtube.com/watch?v=g6nKu7XgAFg)

> *(Replace `YOUR_VIDEO_ID` with your actual YouTube video link once uploaded.)*

